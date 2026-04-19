"""
main.py  (vision-service)
─────────────────────────
FastAPI server for DwaFi vision pipeline — two-phase flow.

Endpoints
  POST /verify-intake   — full session (base64 video / frame / webcam)
  POST /verify-frame    — single-frame streaming (mobile)
  GET  /health          — liveness probe

Phase flow (per session):
  Phase 1 IDENTIFYING → OCR identifies the medicine name → alert fired
  Phase 2 INTAKE      → confirms the patient physically takes it

Environment variables
  YOLO_PILL_MODEL    path to best_model.onnx  (default: model/best_model.onnx)
  YOLO_COCO_MODEL    path to yolov8n.pt       (default: yolov8n.pt)
  PRESCRIPTION_PATH  path to prescription JSON (optional)
"""

from __future__ import annotations

import base64
import logging
import os
from contextlib import asynccontextmanager
from typing import Optional

import cv2
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from .detector import VisionPipeline, VisionOutput, PipelinePhase
from .med_verifier import MedVerifyResult

logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────
# Singleton pipeline
# ──────────────────────────────────────────────

_pipeline: Optional[VisionPipeline] = None


def _on_id_confirmed(result: MedVerifyResult):
    """
    Callback fired by VisionPipeline when Phase 1 locks in CORRECT.
    In production: push result.alert_message to the notification service.
    """
    logger.info("ID CONFIRMED — alert: %s", result.alert_message)
    # TODO: call notification service here
    # e.g. requests.post(NOTIF_URL, json={"message": result.alert_message})


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _pipeline
    logger.info("Loading VisionPipeline …")
    _pipeline = VisionPipeline(
        prescription_source=os.getenv("PRESCRIPTION_PATH"),
        pill_model_path=os.getenv("YOLO_PILL_MODEL", "model/best_model.onnx"),
        coco_model_path=os.getenv("YOLO_COCO_MODEL", "yolov8n.pt"),
        on_id_confirmed=_on_id_confirmed,
    )
    logger.info("VisionPipeline ready.")
    yield
    logger.info("Shutting down.")


app = FastAPI(title="DwaFi Vision Service", lifespan=lifespan)


# ──────────────────────────────────────────────
# Request / Response schemas
# ──────────────────────────────────────────────

class IntakeRequest(BaseModel):
    video:        Optional[str]  = None
    frame:        Optional[str]  = None
    duration_s:   float          = 15.0
    prescription: Optional[dict] = None


class IntakeResponse(BaseModel):
    # Phase 1
    id_label:        str
    id_confidence:   float
    id_med_name:     str
    id_med_dose:     str
    id_feedback:     str
    alert_message:   str
    # Phase 2
    intake_label:    str
    intake_conf:     float
    pill_visible:    bool
    sirop_visible:   bool
    best_class:      str
    intake_feedback: str
    # Behavior
    behavior_label:  str
    behavior_score:  int
    # Meta
    confirmed:       bool
    session_phase:   str
    session_duration_s: float


class FrameRequest(BaseModel):
    frame:          str
    phase:          str   = PipelinePhase.IDENTIFYING
    behavior_score: int   = 0
    prescription:   Optional[dict] = None


class FrameResponse(BaseModel):
    phase:             str
    id_label:          str
    id_confidence:     float
    id_matched_name:   str
    id_matched_dose:   str
    id_feedback:       str
    id_method:         str
    alert_message:     str
    intake_label:      str
    intake_confidence: float
    pill_visible:      bool
    sirop_visible:     bool
    med_class:         str
    intake_feedback:   str
    pill_detected:     bool
    sirop_detected:    bool
    best_class:        str
    best_confidence:   float
    behavior:          str
    behavior_score:    int
    behavior_feedback: str
    confirmed:         bool


# ──────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────

def _b64_to_bgr(b64: str) -> np.ndarray:
    raw = base64.b64decode(b64)
    arr = np.frombuffer(raw, dtype=np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    if img is None:
        raise ValueError("Could not decode image from base64 data.")
    return img


def _b64_video_to_frames(b64: str, max_frames: int = 300) -> list[np.ndarray]:
    import tempfile
    raw = base64.b64decode(b64)
    with tempfile.NamedTemporaryFile(suffix=".mp4", delete=False) as tmp:
        tmp.write(raw)
        tmp_path = tmp.name
    try:
        cap    = cv2.VideoCapture(tmp_path)
        frames = []
        while len(frames) < max_frames:
            ok, frame = cap.read()
            if not ok:
                break
            frames.append(frame)
        cap.release()
    finally:
        os.unlink(tmp_path)
    return frames


def _output_to_response(output: VisionOutput) -> IntakeResponse:
    return IntakeResponse(
        id_label        = output.id_label,
        id_confidence   = output.id_confidence,
        id_med_name     = output.id_med_name,
        id_med_dose     = output.id_med_dose,
        id_feedback     = output.id_feedback,
        alert_message   = output.alert_message,
        intake_label    = output.intake_label,
        intake_conf     = output.intake_conf,
        pill_visible    = output.pill_visible,
        sirop_visible   = output.sirop_visible,
        best_class      = output.best_class,
        intake_feedback = output.intake_feedback,
        behavior_label  = output.behavior_label,
        behavior_score  = output.behavior_score,
        confirmed       = output.confirmed,
        session_phase   = output.session_phase,
        session_duration_s = output.session_duration_s,
    )


# ──────────────────────────────────────────────
# Routes
# ──────────────────────────────────────────────

@app.get("/health")
async def health():
    return {"status": "ok", "pipeline_loaded": _pipeline is not None}


@app.post("/verify-intake", response_model=IntakeResponse)
async def verify_intake(req: IntakeRequest):
    if _pipeline is None:
        raise HTTPException(503, "Vision pipeline not initialised.")

    if req.prescription:
        from .med_verifier import load_prescription
        _pipeline.verifier.prescription = load_prescription(req.prescription)

    # ── Path A: base64 video ───────────────────────────────────────────────
    if req.video:
        try:
            frames = _b64_video_to_frames(req.video)
        except Exception as e:
            raise HTTPException(400, f"Invalid video data: {e}")

        from .med_verifier import IntakeResult
        from .behavior_detector import BehaviorResult
        from .object_detector import ObjectDetectionResult

        id_result     = MedVerifyResult()
        intake_result = IntakeResult()
        behav_result  = BehaviorResult()
        obj_result    = ObjectDetectionResult()

        phase          = PipelinePhase.IDENTIFYING
        id_confirm_cnt = 0

        for frame in frames:
            obj_result   = _pipeline.detector.detect(frame)
            behav_result = _pipeline.behavior.process_frame(
                frame, yolo_boost=obj_result.behavior_score_boost
            )
            if phase == PipelinePhase.IDENTIFYING:
                id_result = _pipeline.verifier.identify(frame)
                if id_result.label == "CORRECT":
                    id_confirm_cnt += 1
                    if id_confirm_cnt >= VisionPipeline.ID_CONFIRM_FRAMES:
                        _on_id_confirmed(id_result)
                        phase = PipelinePhase.INTAKE
                else:
                    id_confirm_cnt = 0
            else:
                intake_result = _pipeline.verifier.check_intake(
                    frame, behavior_score=behav_result.score
                )
                if intake_result.label == "INTAKE_CONFIRMED":
                    phase = PipelinePhase.DONE
                    break

        confirmed = (
            id_result.label     == "CORRECT" and
            intake_result.label == "INTAKE_CONFIRMED"
        )
        output = VisionOutput(
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
            session_duration_s = len(frames) / 15.0,
        )
        return _output_to_response(output)

    # ── Path B: single JPEG frame ──────────────────────────────────────────
    if req.frame:
        try:
            bgr = _b64_to_bgr(req.frame)
        except Exception as e:
            raise HTTPException(400, f"Invalid frame data: {e}")
        result_dict = _pipeline.process_frame(bgr)
        output = VisionOutput(
            id_label        = result_dict["id_label"],
            id_confidence   = result_dict["id_confidence"],
            id_med_name     = result_dict["id_matched_name"],
            id_med_dose     = result_dict["id_matched_dose"],
            id_feedback     = result_dict["id_feedback"],
            id_method       = result_dict["id_method"],
            alert_message   = result_dict["alert_message"],
            intake_label    = result_dict["intake_label"],
            intake_conf     = result_dict["intake_confidence"],
            pill_visible    = result_dict["pill_visible"],
            sirop_visible   = result_dict["sirop_visible"],
            best_class      = result_dict["best_class"],
            intake_feedback = result_dict["intake_feedback"],
            behavior_label  = result_dict["behavior"],
            behavior_score  = result_dict["behavior_score"],
            confirmed       = result_dict["confirmed"],
            session_phase   = result_dict["phase"],
            session_duration_s = 0.0,
        )
        return _output_to_response(output)

    # ── Path C: live webcam ────────────────────────────────────────────────
    output = _pipeline.run_session(duration_s=req.duration_s, show_ui=False)
    return _output_to_response(output)


@app.post("/verify-frame", response_model=FrameResponse)
async def verify_frame(req: FrameRequest):
    """Lightweight single-frame endpoint for Flutter streaming."""
    if _pipeline is None:
        raise HTTPException(503, "Vision pipeline not initialised.")
    try:
        bgr = _b64_to_bgr(req.frame)
    except Exception as e:
        raise HTTPException(400, f"Invalid frame: {e}")

    result = _pipeline.process_frame(bgr, phase=req.phase,
                                      behavior_score=req.behavior_score)
    return FrameResponse(**result)