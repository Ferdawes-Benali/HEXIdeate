"""
med_verifier.py
───────────────
Verifies that the medication shown to the camera matches the user's prescription.

Pipeline
  1. Pre-process frame (grayscale, denoise, threshold)
  2. OCR with Tesseract (pytes-seract)
  3. Clean / normalise extracted text
  4. Fuzzy-match against prescription DB (JSON or dict)
  5. Fallback: YOLOv8 package classifier (if OCR score < threshold)

Returns a MedVerifyResult dataclass.
"""

import re
import json
import logging
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

import cv2
import numpy as np

# Graceful imports — warn if optional deps are missing
try:
    import pytesseract
    _TESSERACT_OK = True
except ImportError:
    _TESSERACT_OK = False
    logging.warning("pytesseract not installed — OCR will be skipped.")

try:
    from rapidfuzz import fuzz, process as rfuzz_process
    _RAPIDFUZZ_OK = True
except ImportError:
    _RAPIDFUZZ_OK = False
    logging.warning("rapidfuzz not installed — falling back to exact matching.")

try:
    from ultralytics import YOLO as _YOLO
    _YOLO_OK = True
except ImportError:
    _YOLO_OK = False
    logging.warning("ultralytics not installed — YOLO fallback disabled.")


# ──────────────────────────────────────────────
# Data structures
# ──────────────────────────────────────────────

@dataclass
class MedVerifyResult:
    label: str = "UNCERTAIN"          # CORRECT | WRONG | UNCERTAIN
    confidence: float = 0.0
    ocr_text: str = ""                # raw OCR output
    matched_name: str = ""            # best prescription match
    matched_dose: str = ""
    feedback: str = ""
    method: str = "none"              # ocr | yolo | none


# ──────────────────────────────────────────────
# Prescription store
# ──────────────────────────────────────────────

# Default fallback prescription (replace with DB query from your gateway)
_DEFAULT_PRESCRIPTION = {
    "medications": [
        {"name": "Paracetamol", "aliases": ["Doliprane", "Efferalgan", "Dafalgan"],
         "dose": "500mg", "time": "08:00"},
        {"name": "Aspirin",     "aliases": ["Aspro", "Aspegic"],
         "dose": "100mg", "time": "12:00"},
        {"name": "Lisinopril",  "aliases": ["Zestril", "Prinivil"],
         "dose": "10mg",  "time": "08:00"},
        {"name": "Metformin",   "aliases": ["Glucophage", "Stagid"],
         "dose": "500mg", "time": "08:00"},
        {"name": "Amlodipine",  "aliases": ["Amlor", "Norvasc"],
         "dose": "5mg",   "time": "20:00"},
    ]
}


def load_prescription(source) -> dict:
    """
    Load prescription from:
      - a JSON file path (str / Path)
      - a dict  (already loaded)
      - None    → use built-in default
    """
    if source is None:
        return _DEFAULT_PRESCRIPTION
    if isinstance(source, (str, Path)):
        with open(source, "r", encoding="utf-8") as f:
            return json.load(f)
    if isinstance(source, dict):
        return source
    raise TypeError(f"Unsupported prescription source type: {type(source)}")


# ──────────────────────────────────────────────
# Image pre-processing
# ──────────────────────────────────────────────

def preprocess_for_ocr(bgr: np.ndarray) -> np.ndarray:
    """
    Enhance a medication-package image for better Tesseract accuracy.
    Steps: resize → grayscale → denoise → adaptive threshold
    """
    # Resize to a width of 1280 for higher OCR resolution
    h, w = bgr.shape[:2]
    if w < 1280:
        scale = 1280 / w
        bgr = cv2.resize(bgr, (1280, int(h * scale)), interpolation=cv2.INTER_CUBIC)

    gray  = cv2.cvtColor(bgr, cv2.COLOR_BGR2GRAY)
    denoised = cv2.fastNlMeansDenoising(gray, h=10, templateWindowSize=7,
                                         searchWindowSize=21)
    # Adaptive threshold removes uneven lighting on packaging
    thresh = cv2.adaptiveThreshold(
        denoised, 255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        blockSize=31, C=10
    )
    return thresh


# ──────────────────────────────────────────────
# OCR extraction
# ──────────────────────────────────────────────

def extract_text_ocr(bgr: np.ndarray) -> str:
    """
    Run Tesseract OCR on the frame.
    Returns raw extracted text, or '' if Tesseract is unavailable.
    """
    if not _TESSERACT_OK:
        return ""
    processed = preprocess_for_ocr(bgr)
    # PSM 6 = assume a uniform block of text (good for packaging labels)
    config = "--psm 6 -l fra+eng+ara"   # French + English + Arabic (Tunisian packaging)
    raw = pytesseract.image_to_string(processed, config=config)
    return raw


def clean_text(raw: str) -> str:
    """
    Normalise OCR output:
      - lowercase
      - collapse whitespace
      - remove non-alphanumeric except spaces and dots
    """
    text = raw.lower()
    text = re.sub(r"[^a-z0-9\s.]", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def extract_dose(text: str) -> str:
    """Pull the first dose pattern (e.g. '500mg', '10 mg') from cleaned text."""
    m = re.search(r"(\d+\.?\d*)\s*(mg|g|ml|mcg|µg|ui|iu)", text)
    return f"{m.group(1)}{m.group(2)}" if m else ""


# ──────────────────────────────────────────────
# Matching logic
# ──────────────────────────────────────────────

def _all_names(med: dict) -> list[str]:
    """Return brand name + all aliases for a prescription entry."""
    names = [med["name"]] + med.get("aliases", [])
    return [n.lower() for n in names]


def match_against_prescription(ocr_text: str, prescription: dict,
                                name_threshold: int = 72) -> MedVerifyResult:
    """
    Fuzzy-match cleaned OCR text against the prescription.

    name_threshold: minimum rapidfuzz ratio (0-100) to call it a match.
    Falls back to substring search if rapidfuzz is not installed.
    """
    cleaned = clean_text(ocr_text)
    if not cleaned:
        return MedVerifyResult(
            label="UNCERTAIN",
            feedback="No text extracted. Show the label clearly.",
            method="ocr",
        )

    ocr_dose = extract_dose(cleaned)
    medications = prescription.get("medications", [])

    best_ratio  = 0
    best_med    = None

    for med in medications:
        names = _all_names(med)
        for name in names:
            if _RAPIDFUZZ_OK:
                # Partial ratio works well when the package has extra text
                ratio = fuzz.partial_ratio(name, cleaned)
            else:
                # Fallback: binary containment check
                ratio = 100 if name in cleaned else 0

            if ratio > best_ratio:
                best_ratio = ratio
                best_med   = med

    if best_med is None or best_ratio < name_threshold:
        return MedVerifyResult(
            label="UNCERTAIN",
            confidence=round(best_ratio / 100, 2),
            ocr_text=ocr_text,
            feedback="Medication not recognised. Move closer and hold steady.",
            method="ocr",
        )

    # Name matched — now check dose
    rx_dose = best_med.get("dose", "").lower().replace(" ", "")
    ocr_dose_clean = ocr_dose.replace(" ", "")
    dose_ok = (rx_dose == ocr_dose_clean) or (not ocr_dose_clean)  # lenient if no dose found

    if dose_ok:
        return MedVerifyResult(
            label="CORRECT",
            confidence=round(best_ratio / 100, 2),
            ocr_text=ocr_text,
            matched_name=best_med["name"],
            matched_dose=best_med.get("dose", ""),
            feedback=f"✓ Correct medication: {best_med['name']} {best_med.get('dose','')}",
            method="ocr",
        )
    else:
        return MedVerifyResult(
            label="WRONG",
            confidence=round(best_ratio / 100, 2),
            ocr_text=ocr_text,
            matched_name=best_med["name"],
            matched_dose=best_med.get("dose", ""),
            feedback=(
                f"⚠ Name matches ({best_med['name']}) but dose differs: "
                f"found {ocr_dose_clean}, expected {rx_dose}."
            ),
            method="ocr",
        )


# ──────────────────────────────────────────────
# YOLO fallback classifier
# ──────────────────────────────────────────────

class YOLOFallback:
    """
    Optional fallback: classify medication packaging using a YOLOv8 model
    when OCR extraction is empty or confidence is very low.
    Swap `model_path` for your pill_yolov8n.onnx or a custom-trained model.
    """

    def __init__(self, model_path: str = "model/pill_yolov8n.onnx"):
        if not _YOLO_OK:
            self._model = None
            return
        try:
            self._model = _YOLO(model_path, task="detect")
        except Exception as e:
            logging.warning(f"Could not load YOLO model: {e}")
            self._model = None

    def predict(self, bgr: np.ndarray, prescription: dict) -> MedVerifyResult:
        if self._model is None:
            return MedVerifyResult(
                label="UNCERTAIN",
                feedback="YOLO model not available.",
                method="yolo",
            )
        results = self._model(bgr, verbose=False)[0]
        if not results.boxes:
            return MedVerifyResult(
                label="UNCERTAIN",
                feedback="No medication packaging detected by camera.",
                method="yolo",
            )

        # Take highest-confidence detection
        idx  = int(results.boxes.cls[results.boxes.conf.argmax()])
        conf = float(results.boxes.conf.max())
        label_name = results.names[idx]

        # Try to match YOLO label against prescription
        synthetic_text = label_name.lower()
        result = match_against_prescription(synthetic_text, prescription,
                                            name_threshold=60)
        result.confidence = round(min(result.confidence, conf), 2)
        result.method = "yolo"
        return result


# ──────────────────────────────────────────────
# Main verifier class
# ──────────────────────────────────────────────

class MedVerifier:
    """
    Full medication verification pipeline.
    Usage:
        verifier = MedVerifier(prescription_source="prescription.json")
        result   = verifier.verify(bgr_frame)
    """

    OCR_CONFIDENCE_FALLBACK = 0.40   # below this → try YOLO

    def __init__(self, prescription_source=None,
                 yolo_model_path: str = "model/pill_yolov8n.onnx"):
        self.prescription = load_prescription(prescription_source)
        self._yolo = YOLOFallback(yolo_model_path)

    def verify(self, bgr: np.ndarray) -> MedVerifyResult:
        """
        Run OCR verification. Falls back to YOLO if OCR confidence is low.
        """
        # ── Step 1: OCR ───────────────────────
        raw_text = extract_text_ocr(bgr)
        result   = match_against_prescription(raw_text, self.prescription)

        # ── Step 2: YOLO fallback ─────────────
        if result.confidence < self.OCR_CONFIDENCE_FALLBACK or not raw_text.strip():
            yolo_result = self._yolo.predict(bgr, self.prescription)
            # Take whichever method is more confident
            if yolo_result.confidence > result.confidence:
                return yolo_result

        return result

    def draw_debug(self, bgr: np.ndarray, result: MedVerifyResult) -> np.ndarray:
        """Overlay OCR and verification result on frame (for demo loop)."""
        colour = (0, 200, 0)   if result.label == "CORRECT" else \
                 (0, 0, 220)   if result.label == "WRONG"   else \
                 (0, 165, 255)

        cv2.putText(bgr, f"MED: {result.label} ({result.confidence:.0%})",
                    (12, bgr.shape[0] - 60),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, colour, 2)
        cv2.putText(bgr, result.feedback,
                    (12, bgr.shape[0] - 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.55, (220, 220, 220), 1)
        return bgr