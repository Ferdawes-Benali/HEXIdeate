"""
object_detector.py
──────────────────
Detects medication-related objects in a video frame using a two-stage strategy:

  Stage 1 — Custom ONNX (best_model.onnx)
      Trained on pills/capsules with 93.1 % mAP.
      Classes: { 0: 'capsules', 1: 'tablets' }
      This is the primary detector.  If it fires, we trust it completely.

  Stage 2 — COCO YOLOv8n  (fallback, sirop only)
      Runs ONLY when Stage 1 finds nothing.
      We keep only { 'bottle', 'cup' } detections as a liquid-medicine proxy.
      Everything else (candy, remote, phone …) is discarded.

The result carries a `behavior_score_boost` that the behavior detector adds
directly to the rolling-window score:
    confirmed pill / capsule  → +30
    sirop proxy (bottle/cup)  → +15
    nothing detected          →   0
"""

import logging
from dataclasses import dataclass, field
from typing import Optional, List

import cv2
import numpy as np

try:
    from ultralytics import YOLO
    _YOLO_OK = True
except ImportError:
    _YOLO_OK = False
    logging.warning("ultralytics not installed — ObjectDetector will be a no-op.")


# ──────────────────────────────────────────────
# Class maps
# ──────────────────────────────────────────────

# Classes produced by best_model.onnx
PILL_CLASSES = {"capsules", "tablets"}

# COCO classes accepted as a liquid-med proxy (Stage 2 only)
SIROP_COCO_CLASSES = {"bottle", "cup"}

# Score boosts
BOOST_PILL  = 30
BOOST_SIROP = 15

# ──────────────────────────────────────────────
# Data structures
# ──────────────────────────────────────────────

@dataclass
class Detection:
    class_name:     str
    confidence:     float
    box:            tuple          # (x1, y1, x2, y2) pixels
    is_pill:        bool = False   # confirmed tablet / capsule
    is_sirop_proxy: bool = False   # bottle / cup fallback


@dataclass
class ObjectDetectionResult:
    detections:          List[Detection] = field(default_factory=list)
    med_object_present:  bool  = False   # any confirmed pill or sirop
    pill_detected:       bool  = False   # real tablet / capsule
    sirop_detected:      bool  = False   # liquid-med proxy
    best_class:          str   = ""      # 'tablets' | 'capsules' | 'sirop' | ''
    best_confidence:     float = 0.0
    behavior_score_boost: int  = 0       # fed directly into BehaviorDetector


# ──────────────────────────────────────────────
# Detector
# ──────────────────────────────────────────────

class ObjectDetector:
    """
    Two-stage medication object detector.

    Parameters
    ----------
    pill_model_path : str
        Path to best_model.onnx (custom pill/capsule detector).
    coco_model_path : str
        Path to yolov8n.pt (COCO, used only as sirop fallback).
    conf_threshold : float
        Minimum detection confidence (applied to both models).
    """

    def __init__(
        self,
        pill_model_path: str = "model/best_model.onnx",
        coco_model_path: str = "yolov8n.pt",
        conf_threshold:  float = 0.40,
    ):
        self.conf_threshold = conf_threshold
        self._pill_model = None
        self._coco_model = None

        if not _YOLO_OK:
            logging.error("ultralytics missing — object detection disabled.")
            return

        # Stage 1 — custom pill model
        try:
            self._pill_model = YOLO(pill_model_path, task="detect")
            logging.info(f"ObjectDetector: loaded pill model '{pill_model_path}'")
        except Exception as e:
            logging.warning(f"Could not load pill model '{pill_model_path}': {e}")

        # Stage 2 — COCO fallback
        try:
            self._coco_model = YOLO(coco_model_path)
            logging.info(f"ObjectDetector: loaded COCO model '{coco_model_path}'")
        except Exception as e:
            logging.warning(f"Could not load COCO model '{coco_model_path}': {e}")

    # ── Public API ─────────────────────────────

    def detect(self, bgr: np.ndarray) -> ObjectDetectionResult:
        """
        Run detection on a single BGR frame.
        Always safe to call — returns empty result if models failed to load.
        """
        # ── Stage 1: custom pill detector ─────────────────────────────────
        pill_detections = self._run_pill_model(bgr)
        if pill_detections:
            best = max(pill_detections, key=lambda d: d.confidence)
            return ObjectDetectionResult(
                detections=pill_detections,
                med_object_present=True,
                pill_detected=True,
                sirop_detected=False,
                best_class=best.class_name,
                best_confidence=best.confidence,
                behavior_score_boost=BOOST_PILL,
            )

        # ── Stage 2: COCO sirop fallback ──────────────────────────────────
        sirop_detections = self._run_coco_sirop(bgr)
        if sirop_detections:
            best = max(sirop_detections, key=lambda d: d.confidence)
            return ObjectDetectionResult(
                detections=sirop_detections,
                med_object_present=True,
                pill_detected=False,
                sirop_detected=True,
                best_class="sirop",
                best_confidence=best.confidence,
                behavior_score_boost=BOOST_SIROP,
            )

        return ObjectDetectionResult()

    def draw_boxes(self, bgr: np.ndarray,
                   result: ObjectDetectionResult) -> np.ndarray:
        """Overlay bounding boxes on frame for debug / demo."""
        for det in result.detections:
            x1, y1, x2, y2 = det.box
            if det.is_pill:
                colour = (0, 220, 80)      # green — confirmed pill
            elif det.is_sirop_proxy:
                colour = (0, 180, 255)     # orange — sirop proxy
            else:
                colour = (160, 160, 160)
            cv2.rectangle(bgr, (x1, y1), (x2, y2), colour, 2)
            label = f"{det.class_name} {det.confidence:.0%}"
            cv2.putText(bgr, label, (x1, max(y1 - 8, 0)),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.55, colour, 1)
        return bgr

    # ── Private helpers ────────────────────────

    def _run_pill_model(self, bgr: np.ndarray) -> List[Detection]:
        """Run best_model.onnx — returns only confirmed pill/capsule hits."""
        if self._pill_model is None:
            return []
        try:
            results = self._pill_model(
                bgr, conf=self.conf_threshold, verbose=False
            )[0]
        except Exception as e:
            logging.warning(f"Pill model inference error: {e}")
            return []

        detections = []
        for box in results.boxes:
            cls_id   = int(box.cls[0])
            cls_name = results.names[cls_id].lower()
            conf     = float(box.conf[0])
            if cls_name not in PILL_CLASSES:
                continue           # ignore anything unexpected
            x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
            detections.append(Detection(
                class_name=cls_name,
                confidence=conf,
                box=(x1, y1, x2, y2),
                is_pill=True,
                is_sirop_proxy=False,
            ))
        return detections

    def _run_coco_sirop(self, bgr: np.ndarray) -> List[Detection]:
        """Run COCO model and keep only bottle / cup detections."""
        if self._coco_model is None:
            return []
        try:
            results = self._coco_model(
                bgr, conf=self.conf_threshold, verbose=False
            )[0]
        except Exception as e:
            logging.warning(f"COCO model inference error: {e}")
            return []

        detections = []
        for box in results.boxes:
            cls_id   = int(box.cls[0])
            cls_name = results.names[cls_id].lower()
            conf     = float(box.conf[0])
            if cls_name not in SIROP_COCO_CLASSES:
                continue           # discard everything that isn't bottle/cup
            x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
            detections.append(Detection(
                class_name=cls_name,
                confidence=conf,
                box=(x1, y1, x2, y2),
                is_pill=False,
                is_sirop_proxy=True,
            ))
        return detections