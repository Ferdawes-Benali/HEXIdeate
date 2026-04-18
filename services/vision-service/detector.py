"""
detector.py
───────────
Unified vision pipeline for DwaFi (دوائي).

Orchestrates:
  ┌─────────────────────────────────┐
  │  Camera / video stream          │
  └────────────┬────────────────────┘
               │ BGR frames
       ┌───────▼──────────┐
       │  ObjectDetector  │  (YOLOv8 — pill / bottle / cup)
       └───────┬──────────┘
               │ ObjectDetectionResult
       ┌───────▼──────────┐
       │ BehaviorDetector │  (MediaPipe pose + hands + face)
       └───────┬──────────┘
               │ BehaviorResult
               │
       ┌───────▼──────────┐        triggered on demand
       │  MedVerifier     │  ◄──── (snapshot for OCR / YOLO verify)
       └───────┬──────────┘
               │ MedVerifyResult
               ▼
         VisionOutput   ──► agent.py / vision_node
"""

from __future__ import annotations

import time
import logging
from dataclasses import dataclass, field
from typing import Optional

import cv2
import numpy as np

from .behavior_detector import BehaviorDetector, BehaviorResult
from .med_verifier      import MedVerifier,      MedVerifyResult
from .object_detector   import ObjectDetector,   ObjectDetectionResult

logger = logging.getLogger(__name__)


# ──────────────────────────────────────────────
# Unified output (consumed by agent.py)
# ──────────────────────────────────────────────

@dataclass
class VisionOutput:
    """Single payload returned to the agent after one verification session."""

    # Behavior
    behavior_label:      str   = "NOT_TAKEN"    # TAKEN | UNCERTAIN | NOT_TAKEN
    behavior_confidence: float = 0.0
    behavior_score:      int   = 0
    behavior_feedback:   str   = ""

    # Medication verification
    verified_label:      str   = "UNCERTAIN"    # CORRECT | WRONG | UNCERTAIN
    verified_confidence: float = 0.0
    verified_med_name:   str   = ""
    verified_med_dose:   str   = ""
    verify_feedback:     str   = ""

    # Object detection summary
    med_object_detected: bool  = False
    liquid_med_detected: bool  = False

    # Meta
    confirmed: bool = False      # True only if TAKEN + CORRECT
    session_duration_s: float = 0.0

    def to_agent_dict(self) -> dict:
        """Serialise to the shape expected by vision_node in agent.py."""
        return {
            "confirmed":    self.confirmed,
            "label":        self.verified_med_name or "unknown",
            "behavior":     self.behavior_label,
            "confidence":   round(
                (self.behavior_confidence + self.verified_confidence) / 2, 2
            ),
            "feedback":     self.verify_feedback or self.behavior_feedback,
        }


# ──────────────────────────────────────────────
# Pipeline
# ──────────────────────────────────────────────

class VisionPipeline:
    """
    Full real-time pipeline.

    Parameters
    ----------
    prescription_source : str | dict | None
        JSON path, dict, or None (uses built-in default prescriptions).
    yolo_model_path : str
        Path to YOLOv8 object-detection model (COCO nano or custom ONNX).
    verify_model_path : str
        Path to YOLOv8 model used as OCR fallback for package recognition.
    behavior_window : int
        Rolling-window size in frames for behavior scoring.
    camera_index : int
        OpenCV camera index (0 = default webcam / phone front camera).
    target_fps : int
        Cap inference rate to avoid overloading mobile CPUs.
    """

    def __init__(
        self,
        prescription_source=None,
        yolo_model_path:    str = "yolov8n.pt",
        verify_model_path:  str = "model/pill_yolov8n.onnx",
        behavior_window:    int = 90,
        camera_index:       int = 0,
        target_fps:         int = 15,
    ):
        self.behavior   = BehaviorDetector(window_size=behavior_window)
        self.verifier   = MedVerifier(prescription_source, verify_model_path)
        self.detector   = ObjectDetector(yolo_model_path)
        self.camera_idx = camera_index
        self.frame_gap  = 1.0 / target_fps

        logger.info("VisionPipeline initialised.")

    # ── One-shot verification (called by agent.py / vision_node) ──────────

    def run_session(
        self,
        duration_s: float = 10.0,
        show_ui:    bool  = False,
    ) -> VisionOutput:
        """
        Open the camera, run the full pipeline for `duration_s` seconds,
        return a VisionOutput.

        `show_ui=True` opens an OpenCV window (useful for development).
        On mobile the Flutter app handles the UI; set show_ui=False.
        """
        cap = cv2.VideoCapture(self.camera_idx)
        if not cap.isOpened():
            logger.error("Camera not accessible.")
            return VisionOutput(behavior_feedback="Camera not accessible.")

        # Set lower resolution for mobile-friendliness
        cap.set(cv2.CAP_PROP_FRAME_WIDTH,  640)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

        start        = time.time()
        last_tick    = start
        verify_result: MedVerifyResult = MedVerifyResult()
        behavior_result: BehaviorResult = BehaviorResult()
        obj_result:  ObjectDetectionResult = ObjectDetectionResult()
        verify_done  = False

        try:
            while (time.time() - start) < duration_s:
                now = time.time()
                # Throttle to target FPS
                if (now - last_tick) < self.frame_gap:
                    continue
                last_tick = now

                ok, frame = cap.read()
                if not ok:
                    logger.warning("Dropped frame.")
                    continue

                # ── Object detection ───────────────────────────────────────
                obj_result = self.detector.detect(frame)

                # Boost behavior score if YOLO sees a med object
                # (we inject the detection into the behavior buffer via the
                #  already-processed FrameEvidence — simplest: just forward
                #  a flag to the next behavior call — done by enriching below)

                # ── Behavior analysis ──────────────────────────────────────
                behavior_result = self.behavior.process_frame(frame)

                # If YOLO confirms a med object, promote object_in_hand score
                # by re-running with a synthetic boost (lightweight approach)
                if obj_result.med_object_present:
                    # Manually nudge the last evidence in the buffer
                    if self.behavior._buffer:
                        ev = self.behavior._buffer[-1]
                        ev.object_in_hand = True
                        ev.raw_score = min(
                            ev.raw_score + 20,
                            100
                        )

                # ── Package verification (once, on first confident frame) ──
                if not verify_done and obj_result.med_object_present:
                    verify_result = self.verifier.verify(frame)
                    if verify_result.confidence >= 0.50:
                        verify_done = True

                # ── Optional debug UI ──────────────────────────────────────
                if show_ui:
                    display = frame.copy()
                    display = self.detector.draw_boxes(display, obj_result)
                    display = self.behavior.draw_debug(display, behavior_result)
                    display = self.verifier.draw_debug(display, verify_result)
                    _draw_realtime_hints(display, behavior_result, verify_result)
                    cv2.imshow("DwaFi Vision", display)
                    if cv2.waitKey(1) & 0xFF in (ord("q"), 27):
                        break

        finally:
            cap.release()
            if show_ui:
                cv2.destroyAllWindows()
            self.behavior.release()

        elapsed = round(time.time() - start, 1)
        confirmed = (
            behavior_result.label == "TAKEN" and
            verify_result.label   == "CORRECT"
        )

        return VisionOutput(
            behavior_label      = behavior_result.label,
            behavior_confidence = behavior_result.confidence,
            behavior_score      = behavior_result.score,
            behavior_feedback   = behavior_result.feedback,
            verified_label      = verify_result.label,
            verified_confidence = verify_result.confidence,
            verified_med_name   = verify_result.matched_name,
            verified_med_dose   = verify_result.matched_dose,
            verify_feedback     = verify_result.feedback,
            med_object_detected = obj_result.med_object_present,
            liquid_med_detected = obj_result.liquid_med_present,
            confirmed           = confirmed,
            session_duration_s  = elapsed,
        )

    # ── Frame-level API (for Flutter/mobile streaming) ─────────────────────

    def process_frame(self, bgr: np.ndarray) -> dict:
        """
        Stateless per-frame call for embedding into a mobile video stream.
        The caller accumulates frames externally.
        Returns a lightweight dict suitable for JSON serialisation.
        """
        obj    = self.detector.detect(bgr)
        behav  = self.behavior.process_frame(bgr)
        verify = MedVerifyResult()

        if obj.med_object_present:
            verify = self.verifier.verify(bgr)

        return {
            "behavior":          behav.label,
            "behavior_score":    behav.score,
            "behavior_feedback": behav.feedback,
            "med_detected":      obj.med_object_present,
            "verified":          verify.label,
            "verified_name":     verify.matched_name,
            "feedback":          verify.feedback or behav.feedback,
            "confirmed":         (behav.label == "TAKEN" and
                                  verify.label == "CORRECT"),
        }


# ──────────────────────────────────────────────
# Real-time hint overlay helper
# ──────────────────────────────────────────────

def _draw_realtime_hints(frame, behav: BehaviorResult,
                          verify: MedVerifyResult) -> None:
    """
    Contextual user-guidance overlay for the demo window.
    Mimics the real-time feedback layer specified in the requirements.
    """
    hints = []

    if not behav.evidence.get("hand_to_mouth_rate", 0):
        hints.append("Bring your hand closer to your mouth")
    if verify.label == "UNCERTAIN":
        hints.append("Show the medicine label to the camera")
    if verify.confidence > 0 and verify.confidence < 0.5:
        hints.append("Move closer — hold the package steady")
    if verify.label == "CORRECT":
        hints.append("✓ Good — medication recognised!")
    if behav.label == "TAKEN":
        hints.append("✓ Intake gesture confirmed")

    y = 110
    for hint in hints[:3]:   # show at most 3 lines
        cv2.putText(frame, hint, (12, y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.58, (255, 230, 100), 1)
        y += 26