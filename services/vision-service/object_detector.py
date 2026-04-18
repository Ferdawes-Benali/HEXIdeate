"""
object_detector.py
──────────────────
Detects medication-related objects in a video frame using YOLOv8.

Two modes:
  1. COCO model  — detects bottles, cups, pills (class proxies) from the
                   standard 80-class COCO dataset. Zero setup required.
  2. Custom ONNX — plug in `pill_yolov8n.onnx` for pill-specific classes.

The detector returns bounding boxes + class names that the behavior
detector can use to boost the "object_in_hand" score.
"""

import logging
from dataclasses import dataclass, field
from typing import Optional

import cv2
import numpy as np

try:
    from ultralytics import YOLO
    _YOLO_OK = True
except ImportError:
    _YOLO_OK = False
    logging.warning("ultralytics not installed — ObjectDetector will be a no-op.")


# ──────────────────────────────────────────────
# COCO classes that indicate medication context
# ──────────────────────────────────────────────

# Objects whose presence in the frame raises the likelihood of med-taking
MED_RELATED_COCO_CLASSES = {
    "bottle",    # water bottle / medicine bottle
    "cup",       # drinking cup
    "bowl",      # pill organiser proxy
    "cell phone",# sometimes confused with blister packs
    "fork",      # not ideal, but kept for completeness
    "spoon",     # liquid medicine
}

# Classes that strongly indicate a sirop / liquid medicine
LIQUID_MED_CLASSES = {"bottle", "cup"}

# ──────────────────────────────────────────────
# Data structures
# ──────────────────────────────────────────────

@dataclass
class Detection:
    class_name: str
    confidence: float
    box: tuple   # (x1, y1, x2, y2) in pixel coords
    is_med_related: bool = False
    is_liquid_med: bool = False


@dataclass
class ObjectDetectionResult:
    detections: list = field(default_factory=list)
    med_object_present: bool = False
    liquid_med_present: bool = False
    best_confidence: float = 0.0


# ──────────────────────────────────────────────
# Detector
# ──────────────────────────────────────────────

class ObjectDetector:
    """
    Wraps a YOLOv8 model (COCO or custom) for medication-context detection.

    Parameters
    ----------
    model_path : str
        Path to custom ONNX / PT model, or 'yolov8n.pt' to auto-download the
        nano COCO model (requires internet on first run, ~6 MB).
    conf_threshold : float
        Minimum confidence for a detection to be reported.
    use_custom_classes : bool
        If True, every detected class is treated as med-related (custom model).
        If False, only COCO classes in MED_RELATED_COCO_CLASSES count.
    """

    def __init__(
        self,
        model_path: str = "yolov8n.pt",
        conf_threshold: float = 0.35,
        use_custom_classes: bool = False,
    ):
        self.conf_threshold   = conf_threshold
        self.use_custom_classes = use_custom_classes
        self._model = None

        if not _YOLO_OK:
            return

        try:
            self._model = YOLO(model_path)
            logging.info(f"ObjectDetector loaded model: {model_path}")
        except Exception as e:
            logging.warning(f"Could not load YOLO model '{model_path}': {e}")

    # ── Public API ─────────────────────────────

    def detect(self, bgr: np.ndarray) -> ObjectDetectionResult:
        """
        Run detection on a single BGR frame.
        Returns ObjectDetectionResult (safe to call even if model failed to load).
        """
        if self._model is None:
            return ObjectDetectionResult()

        try:
            results = self._model(bgr, conf=self.conf_threshold, verbose=False)[0]
        except Exception as e:
            logging.warning(f"YOLO inference error: {e}")
            return ObjectDetectionResult()

        detections = []
        for box in results.boxes:
            cls_id    = int(box.cls[0])
            cls_name  = results.names[cls_id]
            conf      = float(box.conf[0])
            x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())

            is_med     = (self.use_custom_classes or
                          cls_name.lower() in MED_RELATED_COCO_CLASSES)
            is_liquid  = cls_name.lower() in LIQUID_MED_CLASSES

            detections.append(Detection(
                class_name=cls_name,
                confidence=conf,
                box=(x1, y1, x2, y2),
                is_med_related=is_med,
                is_liquid_med=is_liquid,
            ))

        med_present    = any(d.is_med_related for d in detections)
        liquid_present = any(d.is_liquid_med  for d in detections)
        best_conf      = max((d.confidence for d in detections), default=0.0)

        return ObjectDetectionResult(
            detections=detections,
            med_object_present=med_present,
            liquid_med_present=liquid_present,
            best_confidence=best_conf,
        )

    def draw_boxes(self, bgr: np.ndarray,
                   result: ObjectDetectionResult) -> np.ndarray:
        """
        Draw bounding boxes on the frame for debug / demo.
        Green = med-related, Grey = other.
        """
        for det in result.detections:
            x1, y1, x2, y2 = det.box
            colour = (0, 210, 80) if det.is_med_related else (160, 160, 160)
            cv2.rectangle(bgr, (x1, y1), (x2, y2), colour, 2)
            label = f"{det.class_name} {det.confidence:.0%}"
            cv2.putText(bgr, label, (x1, max(y1 - 8, 0)),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.55, colour, 1)
        return bgr