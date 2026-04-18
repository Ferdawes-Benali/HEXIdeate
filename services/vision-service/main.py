"""
main.py  (vision-service)
─────────────────────────
FastAPI server exposing the vision pipeline to the agent and gateway.

Endpoints
  POST /verify-intake      — run a full 10-second session from base64 video
  POST /verify-frame       — single-frame analysis (for mobile streaming)
  GET  /health             — liveness probe
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

from .detector import VisionPipeline, VisionOutput

logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────
# Singleton pipeline (loaded once at startup)
# ──────────────────────────────────────────────

_pipeline: Optional[VisionPipeline] = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _pipeline
    logger.info("Loading VisionPipeline …")
    _pipeline = VisionPipeline(
        prescription_source=os.getenv("PRESCRIPTION_PATH"),   # or None → default
        yolo_model_path=os.getenv("YOLO_MODEL", "yolov8n.pt"),
        verify_model_path=os.getenv("VERIFY_MODEL", "model/pill_yolov8n.onnx"),
    )
    logger.info("VisionPipeline ready.")
    yield
    logger.info("Shutting down VisionPipeline.")


app = FastAPI(title="DwaFi Vision Service", lifespan=lifespan)


# ──────────────────────────────────────────────
# Request / Response schemas
# ──────────────────────────────────────────────

class IntakeRequest(BaseModel):
    """
    Accepts a base64-encoded video file or a base64-encoded JPEG frame.
    For the session mode (video), the server decodes the video, runs the
    pipeline on extracted frames, and returns the aggregated result.
    """
    video: Optional[str] = None          # base64-encoded video bytes
    frame: Optional[str] = None          # base64-encoded JPEG for single frame
    duration_s: float = 10.0
    prescription: Optional[dict] = None  # override server-side prescription


class IntakeResponse(BaseModel):
    confirmed: bool
    label: str
    behavior: str
    behavior_score: int
    verified: str
    confidence: float
    feedback: str
    session_duration_s: float


class FrameRequest(BaseModel):
    frame: str           # base64 JPEG
    prescription: Optional[dict] = None


class FrameResponse(BaseModel):
    behavior: str
    behavior_score: int
    med_detected: bool
    verified: str
    verified_name: str
    feedback: str
    confirmed: bool


# ──────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────

def _b64_to_bgr(b64: str) -> np.ndarray:
    """Decode a base64 JPEG/PNG string to a BGR numpy array."""
    raw = base64.b64decode(b64)
    arr = np.frombuffer(raw, dtype=np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    if img is None:
        raise ValueError("Could not decode image from base64 data.")
    return img


def _b64_video_to_frames(b64: str, max_frames: int = 300) -> list[np.ndarray]:
    """
    Write base64 video to a temp file, extract frames with OpenCV.
    Limits to max_frames to avoid OOM on long videos.
    """
    import tempfile, os
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


# ──────────────────────────────────────────────
# Routes
# ──────────────────────────────────────────────

@app.get("/health")
async def health():
    return {"status": "ok", "pipeline_loaded": _pipeline is not None}


@app.post("/verify-intake", response_model=IntakeResponse)
async def verify_intake(req: IntakeRequest):
    """
    Full verification session.
    Accepts either a base64 video (processes frame-by-frame) or triggers
    a live webcam session on the server (dev/test only).
    """
    if _pipeline is None:
        raise HTTPException(503, "Vision pipeline not initialised.")

    # Override prescription if provided per-request (e.g. from gateway)
    if req.prescription:
        from .med_verifier import load_prescription
        _pipeline.verifier.prescription = load_prescription(req.prescription)

    # ── Path A: base64 video ───────────────────
    if req.video:
        try:
            frames = _b64_video_to_frames(req.video)
        except Exception as e:
            raise HTTPException(400, f"Invalid video data: {e}")

        from .behavior_detector import BehaviorResult
        from .med_verifier      import MedVerifyResult
        from .object_detector   import ObjectDetectionResult
        from .detector          import VisionOutput

        behavior_result = BehaviorResult()
        verify_result   = MedVerifyResult()
        obj_result      = ObjectDetectionResult()
        verify_done     = False

        for frame in frames:
            obj_result      = _pipeline.detector.detect(frame)
            behavior_result = _pipeline.behavior.process_frame(frame)
            if not verify_done and obj_result.med_object_present:
                verify_result = _pipeline.verifier.verify(frame)
                if verify_result.confidence >= 0.50:
                    verify_done = True

        confirmed = (
            behavior_result.label == "TAKEN" and
            verify_result.label   == "CORRECT"
        )
        return IntakeResponse(
            confirmed           = confirmed,
            label               = verify_result.matched_name or "unknown",
            behavior            = behavior_result.label,
            behavior_score      = behavior_result.score,
            verified            = verify_result.label,
            confidence          = round(
                (behavior_result.confidence + verify_result.confidence) / 2, 2
            ),
            feedback            = verify_result.feedback or behavior_result.feedback,
            session_duration_s  = len(frames) / 15.0,
        )

    # ── Path B: single JPEG frame ─────────────
    if req.frame:
        try:
            bgr = _b64_to_bgr(req.frame)
        except Exception as e:
            raise HTTPException(400, f"Invalid frame data: {e}")

        result = _pipeline.process_frame(bgr)
        return IntakeResponse(
            confirmed          = result["confirmed"],
            label              = result["verified_name"],
            behavior           = result["behavior"],
            behavior_score     = result["behavior_score"],
            verified           = result["verified"],
            confidence         = 0.0,
            feedback           = result["feedback"],
            session_duration_s = 0.0,
        )

    # ── Path C: live webcam (dev only) ─────────
    output: VisionOutput = _pipeline.run_session(
        duration_s=req.duration_s,
        show_ui=False,
    )
    return IntakeResponse(
        confirmed          = output.confirmed,
        label              = output.verified_med_name or "unknown",
        behavior           = output.behavior_label,
        behavior_score     = output.behavior_score,
        verified           = output.verified_label,
        confidence         = output.to_agent_dict()["confidence"],
        feedback           = output.verify_feedback or output.behavior_feedback,
        session_duration_s = output.session_duration_s,
    )


@app.post("/verify-frame", response_model=FrameResponse)
async def verify_frame(req: FrameRequest):
    """
    Lightweight single-frame endpoint for mobile streaming.
    Flutter app sends JPEG frames at ~5 fps; server returns real-time feedback.
    """
    if _pipeline is None:
        raise HTTPException(503, "Vision pipeline not initialised.")

    try:
        bgr = _b64_to_bgr(req.frame)
    except Exception as e:
        raise HTTPException(400, f"Invalid frame: {e}")

    result = _pipeline.process_frame(bgr)
    return FrameResponse(**result)