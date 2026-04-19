"""
detector.py
───────────
Unified vision pipeline for DwaFi (دوائي).

Two-phase orchestration (mirrors med_verifier.py design):

  ┌──────────────────────────────────────────────┐
  │             Camera / video stream            │
  └───────────────────┬──────────────────────────┘
                      │ BGR frames
              ┌───────▼──────────┐
              │  ObjectDetector  │  best_model.onnx (tablets/capsules)
              │  (two-stage)     │  COCO yolov8n    (bottle/cup → sirop)
              └───────┬──────────┘
                      │ ObjectDetectionResult (.behavior_score_boost)
              ┌───────▼──────────┐
              │ BehaviorDetector │  MediaPipe pose + hands + face
              └───────┬──────────┘
                      │ BehaviorResult (.score for Phase 2)
                      │
            ╔═════════▼══════════════════════════════╗
            ║  PHASE 1 — IDENTIFICATION              ║
            ║  MedVerifier.identify(frame)           ║
            ║  OCR → rapidfuzz → CORRECT/WRONG/UNC  ║
            ║  Fallback: YOLO presence (UNCERTAIN)   ║
            ╚═════════╤══════════════════════════════╝
                      │ MedVerifyResult
                      │
            if CORRECT → fire alert to agent ("C'est ton Doliprane")
                      │
            ╔═════════▼══════════════════════════════╗
            ║  PHASE 2 — INTAKE CONFIRMATION        ║
            ║  MedVerifier.check_intake(frame,       ║
            ║              behavior_score)           ║
            ║  best_model.onnx pill present?         ║
            ║  COCO sirop present?                   ║
            ║  + behavior score → INTAKE_CONFIRMED   ║
            ╚═════════╤══════════════════════════════╝
                      │ IntakeResult
                      ▼
                VisionOutput  ──► agent.py / vision_node
"""

from __future__ import annotations

import time
import logging
from dataclasses import dataclass, field
from typing import Optional, Callable

import cv2
import numpy as np

from .behavior_detector import BehaviorDetector, BehaviorResult
from .med_verifier      import MedVerifier, MedVerifyResult, IntakeResult
from .object_detector   import ObjectDetector, ObjectDetectionResult

logger = logging.getLogger(__name__)


# ──────────────────────────────────────────────
# Pipeline state enum
# ──────────────────────────────────────────────

class PipelinePhase:
    IDENTIFYING = "IDENTIFYING"   # Phase 1: reading the label
    INTAKE      = "INTAKE"        # Phase 2: confirming the patient takes it
    DONE        = "DONE"          # confirmed or timed-out


# ──────────────────────────────────────────────
# Unified output
# ──────────────────────────────────────────────

@dataclass
class VisionOutput:
    """Single payload returned to the agent after one verification session."""

    # Phase 1 — Identification
    id_label:        str   = "UNCERTAIN"   # CORRECT | WRONG | UNCERTAIN
    id_confidence:   float = 0.0
    id_med_name:     str   = ""
    id_med_dose:     str   = ""
    id_feedback:     str   = ""
    id_method:       str   = "none"
    alert_message:   str   = ""           # ready-to-send patient alert

    # Phase 2 — Intake
    intake_label:    str   = "INTAKE_NOT_DETECTED"
    intake_conf:     float = 0.0
    pill_visible:    bool  = False
    sirop_visible:   bool  = False
    best_class:      str   = ""
    intake_feedback: str   = ""

    # Behavior
    behavior_label:  str   = "NOT_TAKEN"
    behavior_score:  int   = 0

    # Meta
    confirmed:       bool  = False   # Phase 1 CORRECT + Phase 2 INTAKE_CONFIRMED
    session_phase:   str   = PipelinePhase.IDENTIFYING
    session_duration_s: float = 0.0

    def to_agent_dict(self) -> dict:
        return {
            "confirmed":       self.confirmed,
            "label":           self.id_med_name or self.best_class or "unknown",
            "id_result":       self.id_label,
            "intake_result":   self.intake_label,
            "behavior":        self.behavior_label,
            "confidence":      round((self.id_confidence + self.intake_conf) / 2, 2),
            "feedback":        self.intake_feedback or self.id_feedback,
            "alert_message":   self.alert_message,
            "pill_type":       self.best_class,
        }


# ──────────────────────────────────────────────
# Pipeline
# ──────────────────────────────────────────────

class VisionPipeline:
    """
    Full two-phase real-time pipeline.

    Phase 1 (IDENTIFYING): every frame runs OCR identification via
    MedVerifier.identify().  Once the label is confidently read as CORRECT,
    `on_id_confirmed` callback is fired (for the agent to send the patient
    alert) and the pipeline transitions to Phase 2.

    Phase 2 (INTAKE): MedVerifier.check_intake() + BehaviorDetector watch
    the patient physically take the medication.  When INTAKE_CONFIRMED the
    session ends with confirmed=True.

    Parameters
    ----------
    prescription_source  : JSON path | dict | None
    pill_model_path      : path to best_model.onnx
    coco_model_path      : path to yolov8n.pt (sirop fallback only)
    behavior_window      : rolling-window size in frames
    camera_index         : OpenCV camera index
    target_fps           : inference rate cap (mobile-friendly)
    on_id_confirmed      : optional callback(MedVerifyResult) fired when
                           Phase 1 returns CORRECT — use to send the alert
    """

    # How many consecutive CORRECT frames before Phase 1 is locked in
    ID_CONFIRM_FRAMES = 3

    def __init__(
        self,
        prescription_source=None,
        pill_model_path:   str = "model/pill_yolov8n.onnx",
        coco_model_path:   str = "yolov8n.pt",
        behavior_window:   int = 90,
        camera_index:      int = 0,
        target_fps:        int = 15,
        on_id_confirmed:   Optional[Callable[[MedVerifyResult], None]] = None,
    ):
        self.behavior         = BehaviorDetector(window_size=behavior_window)
        self.verifier         = MedVerifier(
            prescription_source,
            yolo_model_path=pill_model_path,
            coco_model_path=coco_model_path,
        )
        self.detector         = ObjectDetector(
            pill_model_path=pill_model_path,
            coco_model_path=coco_model_path,
        )
        self.camera_idx       = camera_index
        self.frame_gap        = 1.0 / target_fps
        self.on_id_confirmed  = on_id_confirmed
        logger.info("VisionPipeline initialised (pill model: %s)", pill_model_path)

    # ── Session API ────────────────────────────

    def run_session(
        self,
        duration_s: float = 15.0,
        show_ui:    bool  = False,
    ) -> VisionOutput:
        """
        Open camera, run full two-phase pipeline for up to `duration_s` seconds.
        Returns VisionOutput.
        """
        cap = cv2.VideoCapture(self.camera_idx)
        if not cap.isOpened():
            logger.error("Camera not accessible.")
            return VisionOutput(id_feedback="Camera not accessible.")

        cap.set(cv2.CAP_PROP_FRAME_WIDTH,  640)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

        start           = time.time()
        last_tick       = start
        phase           = PipelinePhase.IDENTIFYING
        id_confirm_cnt  = 0

        id_result     = MedVerifyResult()
        intake_result = IntakeResult()
        behav_result  = BehaviorResult()
        obj_result    = ObjectDetectionResult()

        try:
            while (time.time() - start) < duration_s:
                now = time.time()
                if (now - last_tick) < self.frame_gap:
                    continue
                last_tick = now

                ok, frame = cap.read()
                if not ok:
                    logger.warning("Dropped frame.")
                    continue

                # ── Object detection (both phases need it) ─────────────────
                obj_result = self.detector.detect(frame)

                # ── Behavior (both phases need score) ─────────────────────
                behav_result = self.behavior.process_frame(
                    frame,
                    yolo_boost=obj_result.behavior_score_boost,
                )

                # ══════════════════════════════════════════════════════════
                #  PHASE 1 — IDENTIFICATION
                # ══════════════════════════════════════════════════════════
                if phase == PipelinePhase.IDENTIFYING:
                    id_result = self.verifier.identify(frame)

                    if id_result.label == "CORRECT":
                        id_confirm_cnt += 1
                        if id_confirm_cnt >= self.ID_CONFIRM_FRAMES:
                            # Locked in — fire the alert and advance to Phase 2
                            logger.info(
                                "Phase 1 confirmed: %s %s",
                                id_result.matched_name, id_result.matched_dose
                            )
                            if self.on_id_confirmed:
                                self.on_id_confirmed(id_result)
                            phase = PipelinePhase.INTAKE
                    else:
                        id_confirm_cnt = 0   # reset streak on non-CORRECT frame

                # ══════════════════════════════════════════════════════════
                #  PHASE 2 — INTAKE CONFIRMATION
                # ══════════════════════════════════════════════════════════
                elif phase == PipelinePhase.INTAKE:
                    intake_result = self.verifier.check_intake(
                        frame,
                        behavior_score=behav_result.score,
                    )
                    if intake_result.label == "INTAKE_CONFIRMED":
                        phase = PipelinePhase.DONE
                        logger.info("Phase 2 confirmed: intake detected.")
                        break   # session complete

                # ── Optional debug UI ──────────────────────────────────────
                if show_ui:
                    display = frame.copy()
                    display = self.detector.draw_boxes(display, obj_result)
                    if phase == PipelinePhase.IDENTIFYING:
                        display = self.verifier.draw_debug(display, id_result)
                    else:
                        display = self.verifier.draw_intake_debug(display, intake_result)
                    display = self.behavior.draw_debug(display, behav_result)
                    _draw_realtime_hints(display, phase, id_result, intake_result,
                                         behav_result, obj_result)
                    cv2.imshow("DwaFi Vision", display)
                    if cv2.waitKey(1) & 0xFF in (ord("q"), 27):
                        break

        finally:
            cap.release()
            if show_ui:
                cv2.destroyAllWindows()
            self.behavior.release()

        elapsed   = round(time.time() - start, 1)
        confirmed = (
            id_result.label     == "CORRECT" and
            intake_result.label == "INTAKE_CONFIRMED"
        )

        return VisionOutput(
            id_label        = id_result.label,
            id_confidence   = id_result.confidence,
            id_med_name     = id_result.matched_name,
            id_med_dose     = id_result.matched_dose,
            id_feedback     = id_result.feedback,
            id_method       = id_result.method,
            alert_message   = id_result.alert_message,
            intake_label    = intake_result.label,
            intake_conf     = intake_result.confidence,
            pill_visible    = intake_result.pill_visible,
            sirop_visible   = intake_result.sirop_visible,
            best_class      = intake_result.med_class or obj_result.best_class,
            intake_feedback = intake_result.feedback,
            behavior_label  = behav_result.label,
            behavior_score  = behav_result.score,
            confirmed       = confirmed,
            session_phase   = phase,
            session_duration_s = elapsed,
        )

    # ── Per-frame API (mobile streaming) ───────

    def process_frame(self, bgr: np.ndarray, phase: str = PipelinePhase.IDENTIFYING,
                      behavior_score: int = 0) -> dict:
        """
        Stateless per-frame call for Flutter/mobile streaming.
        The caller owns the phase state and passes it in each time.

        Parameters
        ----------
        bgr            : camera frame
        phase          : current pipeline phase (IDENTIFYING | INTAKE)
        behavior_score : latest BehaviorDetector score (for Phase 2)

        Returns a lightweight dict for JSON serialisation.
        """
        obj   = self.detector.detect(bgr)
        behav = self.behavior.process_frame(bgr, yolo_boost=obj.behavior_score_boost)

        if phase == PipelinePhase.IDENTIFYING:
            id_res     = self.verifier.identify(bgr)
            intake_res = IntakeResult()
        else:
            id_res     = MedVerifyResult()
            intake_res = self.verifier.check_intake(bgr, behavior_score=behav.score)

        return {
            # Phase info
            "phase":              phase,
            # Phase 1
            "id_label":           id_res.label,
            "id_confidence":      round(id_res.confidence, 2),
            "id_matched_name":    id_res.matched_name,
            "id_matched_dose":    id_res.matched_dose,
            "id_feedback":        id_res.feedback,
            "id_method":          id_res.method,
            "alert_message":      id_res.alert_message,
            # Phase 2
            "intake_label":       intake_res.label,
            "intake_confidence":  round(intake_res.confidence, 2),
            "pill_visible":       intake_res.pill_visible,
            "sirop_visible":      intake_res.sirop_visible,
            "med_class":          intake_res.med_class,
            "intake_feedback":    intake_res.feedback,
            # Object detection
            "pill_detected":      obj.pill_detected,
            "sirop_detected":     obj.sirop_detected,
            "best_class":         obj.best_class,
            "best_confidence":    round(obj.best_confidence, 2),
            # Behavior
            "behavior":           behav.label,
            "behavior_score":     behav.score,
            "behavior_feedback":  behav.feedback,
            # Combined result
            "confirmed":          (
                id_res.label     == "CORRECT" and
                intake_res.label == "INTAKE_CONFIRMED"
            ),
        }


# ──────────────────────────────────────────────
# Real-time hint overlay
# ──────────────────────────────────────────────

def _draw_realtime_hints(
    frame,
    phase:        str,
    id_res:       MedVerifyResult,
    intake_res:   IntakeResult,
    behav:        BehaviorResult,
    obj:          ObjectDetectionResult,
) -> None:
    hints = []

    if phase == PipelinePhase.IDENTIFYING:
        if not obj.med_object_present:
            hints.append("Hold the medicine box up to the camera")
        elif id_res.label == "UNCERTAIN":
            hints.append("Show the label — I need to read the name")
        elif id_res.label == "CORRECT":
            hints.append(f"✓ {id_res.matched_name} identified — confirming…")
        elif id_res.label == "WRONG":
            hints.append(f"⚠ Wrong dose detected — check the box!")
    else:
        if not intake_res.pill_visible and not intake_res.sirop_visible:
            hints.append("Hold the medicine visible to the camera")
        if behav.label != "TAKEN":
            hints.append("Bring the medication to your mouth")
        if intake_res.label == "INTAKE_CONFIRMED":
            hints.append("✓ Intake confirmed!")

    y = 110
    for hint in hints[:3]:
        cv2.putText(frame, hint, (12, y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.58, (255, 230, 100), 1)
        y += 26