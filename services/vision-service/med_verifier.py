"""
med_verifier.py
───────────────
Two-phase medication verification for DwaFi (دوائي).

══════════════════════════════════════════════════════════════════════
PHASE 1 — IDENTIFICATION  (Is this the right medicine?)
══════════════════════════════════════════════════════════════════════
  1a. Pre-process frame  → grayscale / denoise / adaptive-threshold
  1b. Tesseract OCR      → French + English + Arabic  (--psm 6)
  1c. Clean + normalise  → lowercase, strip noise
  1d. rapidfuzz match    → partial_ratio against prescription names + aliases
  1e. Dose cross-check   → regex extract vs prescription dose field

  Result: CORRECT | WRONG | UNCERTAIN
  Side-effect: when CORRECT the caller fires an alert to the patient:
    "✓ C'est bien ton Doliprane 500mg — prends-le maintenant."

  Fallback (OCR confidence < 40 %):
  1f. best_model.onnx detects 'capsules' / 'tablets' in the frame
      → confirms *a* medication is present but CANNOT read the name
      → always returns UNCERTAIN + prompt to show the label more clearly
      → NEVER upgrades to CORRECT (name identification requires OCR)

══════════════════════════════════════════════════════════════════════
PHASE 2 — INTAKE DETECTION  (Did the patient actually take it?)
══════════════════════════════════════════════════════════════════════
  Called only after Phase 1 returned CORRECT.
  2a. best_model.onnx    → confirms a physical pill/capsule is visible
  2b. COCO yolov8n       → sirop proxy (bottle/cup) if no pill found
  2c. behavior_score     → passed in from BehaviorDetector rolling window

  Result: INTAKE_CONFIRMED | INTAKE_UNCERTAIN | INTAKE_NOT_DETECTED
  This result triggers the "taken" log + family notification.

══════════════════════════════════════════════════════════════════════
Public API  (consumed by detector.py / VisionPipeline)
══════════════════════════════════════════════════════════════════════
  verifier = MedVerifier(prescription_source, yolo_model_path)

  # Phase 1 — always run first
  id_result: MedVerifyResult = verifier.identify(frame)

  # Phase 2 — run only when id_result.label == "CORRECT"
  intake_result: IntakeResult = verifier.check_intake(frame, behavior_score)

  # Legacy one-shot wrapper (backward-compatible with existing callers)
  result: MedVerifyResult = verifier.verify(frame)
"""

import re
import json
import logging
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional, List

import cv2
import numpy as np

# ──────────────────────────────────────────────
# Optional dependency guards
# ──────────────────────────────────────────────

try:
    import pytesseract
    _TESSERACT_OK = True
except ImportError:
    _TESSERACT_OK = False
    logging.warning("pytesseract not installed — OCR will be skipped.")

try:
    from rapidfuzz import fuzz
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
# Result dataclasses
# ──────────────────────────────────────────────

@dataclass
class MedVerifyResult:
    """
    Phase 1 result — name identification.

    label:
      CORRECT   → name (and dose) match a prescription entry → fire alert
      WRONG     → name matched but wrong dose → fire warning alert
      UNCERTAIN → not enough info yet → prompt patient to show the label
    """
    label:         str   = "UNCERTAIN"
    confidence:    float = 0.0
    ocr_text:      str   = ""
    matched_name:  str   = ""
    matched_dose:  str   = ""
    feedback:      str   = ""
    method:        str   = "none"       # "ocr" | "yolo_fallback" | "none"
    alert_message: str   = ""          # ready-to-send alert text for agent


@dataclass
class IntakeResult:
    """
    Phase 2 result — physical intake confirmation.

    label:
      INTAKE_CONFIRMED     → pill/sirop physically detected AND behavior says TAKEN
      INTAKE_UNCERTAIN     → medication present but gesture not conclusive yet
      INTAKE_NOT_DETECTED  → no physical medication or gesture seen
    """
    label:          str   = "INTAKE_NOT_DETECTED"
    confidence:     float = 0.0
    pill_visible:   bool  = False   # best_model.onnx confirmed tablets/capsules
    sirop_visible:  bool  = False   # COCO bottle/cup fallback
    med_class:      str   = ""      # "tablets" | "capsules" | "sirop" | ""
    behavior_score: int   = 0       # effective score after boost
    feedback:       str   = ""


# ──────────────────────────────────────────────
# Prescription helpers
# ──────────────────────────────────────────────

_DEFAULT_PRESCRIPTION = {
    "medications": [
        {"name": "Paracetamol", "aliases": ["Doliprane", "Efferalgan", "Dafalgan", "Paraset"],
         "dose": "500mg", "time": "08:00"},
        {"name": "Aspirin",     "aliases": ["Aspro", "Aspegic", "Cardioaspirin"],
         "dose": "100mg", "time": "12:00"},
        {"name": "Lisinopril",  "aliases": ["Zestril", "Prinivil"],
         "dose": "10mg",  "time": "08:00"},
        {"name": "Metformin",   "aliases": ["Glucophage", "Stagid", "Metforal"],
         "dose": "500mg", "time": "08:00"},
        {"name": "Amlodipine",  "aliases": ["Amlor", "Norvasc", "Istin"],
         "dose": "5mg",   "time": "20:00"},
        {"name": "Omeprazole",  "aliases": ["Mopral", "Losec", "Inipomp"],
         "dose": "20mg",  "time": "07:30"},
    ]
}


def load_prescription(source) -> dict:
    """Load prescription from JSON path, dict, or None → built-in default."""
    if source is None:
        return _DEFAULT_PRESCRIPTION
    if isinstance(source, (str, Path)):
        with open(source, "r", encoding="utf-8") as f:
            return json.load(f)
    if isinstance(source, dict):
        return source
    raise TypeError(f"Unsupported prescription source type: {type(source)}")


def _all_names(med: dict) -> List[str]:
    return [n.lower() for n in [med["name"]] + med.get("aliases", [])]



def preprocess_for_ocr(bgr: np.ndarray) -> np.ndarray:
    """Resize → grayscale → denoise → adaptive threshold for best Tesseract accuracy."""
    h, w = bgr.shape[:2]
    if w < 1280:
        scale = 1280 / w
        bgr = cv2.resize(bgr, (1280, int(h * scale)), interpolation=cv2.INTER_CUBIC)
    gray     = cv2.cvtColor(bgr, cv2.COLOR_BGR2GRAY)
    denoised = cv2.fastNlMeansDenoising(gray, h=10, templateWindowSize=7,
                                         searchWindowSize=21)
    thresh   = cv2.adaptiveThreshold(
        denoised, 255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        blockSize=31, C=10,
    )
    return thresh


def extract_text_ocr(bgr: np.ndarray) -> str:
    """Run Tesseract OCR (French + English + Arabic). Returns '' if unavailable."""
    if not _TESSERACT_OK:
        return ""
    processed = preprocess_for_ocr(bgr)
    config    = "--psm 6 -l fra+eng+ara"
    try:
        return pytesseract.image_to_string(processed, config=config)
    except Exception as e:
        logging.warning(f"Tesseract error: {e}")
        return ""


def clean_text(raw: str) -> str:
    text = raw.lower()
    text = re.sub(r"[^a-z0-9\s.]", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def extract_dose(text: str) -> str:
    m = re.search(r"(\d+\.?\d*)\s*(mg|g|ml|mcg|µg|ui|iu)", text)
    return f"{m.group(1)}{m.group(2)}" if m else ""


# ──────────────────────────────────────────────
# Phase 1d–e — Name + dose matching (pure OCR path)
# ──────────────────────────────────────────────

def match_against_prescription(
    ocr_text: str,
    prescription: dict,
    name_threshold: int = 72,
) -> MedVerifyResult:
    """
    Fuzzy-match OCR text against every name + alias in the prescription.
    Returns CORRECT / WRONG / UNCERTAIN.
    NEVER calls YOLO — that is the caller's responsibility as a fallback.
    """
    cleaned = clean_text(ocr_text)
    if not cleaned:
        return MedVerifyResult(
            label="UNCERTAIN",
            feedback="No text extracted. Show the medicine label more clearly.",
            method="ocr",
        )

    ocr_dose    = extract_dose(cleaned)
    medications = prescription.get("medications", [])
    best_ratio  = 0
    best_med    = None

    for med in medications:
        for name in _all_names(med):
            ratio = fuzz.partial_ratio(name, cleaned) if _RAPIDFUZZ_OK else (
                100 if name in cleaned else 0
            )
            if ratio > best_ratio:
                best_ratio = ratio
                best_med   = med

    if best_med is None or best_ratio < name_threshold:
        return MedVerifyResult(
            label="UNCERTAIN",
            confidence=round(best_ratio / 100, 2),
            ocr_text=ocr_text,
            feedback="Medication name not recognised. Move closer and hold the label steady.",
            method="ocr",
        )

    # ── Name matched — check dose ──────────────────────────────────────────
    rx_dose        = best_med.get("dose", "").lower().replace(" ", "")
    ocr_dose_clean = ocr_dose.replace(" ", "")
    dose_ok        = (rx_dose == ocr_dose_clean) or (not ocr_dose_clean)

    name = best_med["name"]
    dose = best_med.get("dose", "")

    if dose_ok:
        return MedVerifyResult(
            label="CORRECT",
            confidence=round(best_ratio / 100, 2),
            ocr_text=ocr_text,
            matched_name=name,
            matched_dose=dose,
            feedback=f"✓ Correct: {name} {dose}",
            method="ocr",
            alert_message=(
                f"✓ C'est bien ton {name} {dose}. "
                "Montre le médicament à la caméra et prends-le maintenant."
            ),
        )
    else:
        return MedVerifyResult(
            label="WRONG",
            confidence=round(best_ratio / 100, 2),
            ocr_text=ocr_text,
            matched_name=name,
            matched_dose=dose,
            feedback=f"⚠ Wrong dose: found {ocr_dose_clean}, expected {rx_dose}",
            method="ocr",
            alert_message=(
                f"⚠ Attention! Le médicament scanné ({name}) a une dose différente: "
                f"trouvé {ocr_dose_clean}, prescrit {rx_dose}. "
                "Vérifie avec ton médecin avant de le prendre."
            ),
        )


# ──────────────────────────────────────────────
# Phase 1f — YOLO presence fallback
# (OCR failed; confirm pill is visible; name still UNKNOWN)
# ──────────────────────────────────────────────

_PILL_CLASSES = {"capsules", "tablets"}


class _YOLOPresenceFallback:
    """
    Runs best_model.onnx ONLY when OCR extracted nothing useful.
    Purpose: detect that *a* medication is in frame and prompt the patient
             to present the label so OCR can identify it.

    CRITICAL CONTRACT:
      This class NEVER returns CORRECT.
      Name identification requires readable OCR text.
      A visual match to 'capsule'/'tablet' is not enough to confirm identity.
    """

    def __init__(self, model_path: str):
        self._model = None
        if not _YOLO_OK:
            return
        try:
            self._model = _YOLO(model_path, task="detect")
            logging.info(f"_YOLOPresenceFallback loaded: {model_path}")
        except Exception as e:
            logging.warning(f"Could not load YOLO presence fallback: {e}")

    def detect_presence(self, bgr: np.ndarray) -> MedVerifyResult:
        """Always returns UNCERTAIN — provides a presence hint only."""
        if self._model is None:
            return MedVerifyResult(
                label="UNCERTAIN",
                feedback="Show the medicine label clearly to identify it.",
                method="yolo_fallback",
            )
        try:
            results = self._model(bgr, conf=0.35, verbose=False)[0]
        except Exception as e:
            logging.warning(f"YOLO presence fallback error: {e}")
            return MedVerifyResult(
                label="UNCERTAIN",
                feedback="Show the medicine label clearly to identify it.",
                method="yolo_fallback",
            )

        if not results.boxes or len(results.boxes) == 0:
            return MedVerifyResult(
                label="UNCERTAIN",
                confidence=0.0,
                feedback="No medication visible. Hold the box or blister up to the camera.",
                method="yolo_fallback",
            )

        best_idx = int(results.boxes.conf.argmax())
        cls_name = results.names[int(results.boxes.cls[best_idx])].lower()
        conf     = float(results.boxes.conf[best_idx])

        if cls_name in _PILL_CLASSES:
            # Pill present but unidentified — cap confidence at 0.35 so the
            # pipeline never mistakes this for a CORRECT identification
            return MedVerifyResult(
                label="UNCERTAIN",
                confidence=round(conf * 0.35, 2),
                feedback=(
                    f"I can see a {cls_name[:-1]} ({conf:.0%}). "
                    "Now show the package label so I can read the name."
                ),
                method="yolo_fallback",
            )

        return MedVerifyResult(
            label="UNCERTAIN",
            confidence=0.0,
            feedback="Hold the medicine box closer — I need to read the label.",
            method="yolo_fallback",
        )


# ──────────────────────────────────────────────
# Phase 2 — Physical intake detector
# ──────────────────────────────────────────────

_INTAKE_CONFIRMED_SCORE = 70   # mirrors BehaviorDetector.THRESHOLD_TAKEN
_INTAKE_UNCERTAIN_SCORE = 40   # mirrors BehaviorDetector.THRESHOLD_UNCERTAIN
_SIROP_COCO_CLASSES     = {"bottle", "cup"}


class _IntakeDetector:
    """
    Phase 2: physically confirm the patient is taking the already-identified med.

    Sub-checks (in order):
      A) best_model.onnx   → pill/capsule visible in frame  (+30 score boost)
      B) COCO yolov8n      → sirop proxy (bottle/cup)        (+15 score boost)
      C) behavior_score    → injected by caller from BehaviorDetector

    The name is already confirmed by Phase 1; here we only care about
    the physical act of taking the medication.
    """

    def __init__(self, pill_model_path: str, coco_model_path: str = "yolov8n.pt"):
        self._pill_model = None
        self._coco_model = None
        if not _YOLO_OK:
            return
        try:
            self._pill_model = _YOLO(pill_model_path, task="detect")
            logging.info(f"IntakeDetector pill model: {pill_model_path}")
        except Exception as e:
            logging.warning(f"IntakeDetector: could not load pill model: {e}")
        try:
            self._coco_model = _YOLO(coco_model_path)
            logging.info("IntakeDetector: COCO model loaded for sirop fallback.")
        except Exception as e:
            logging.warning(f"IntakeDetector: could not load COCO model: {e}")

    def check(self, bgr: np.ndarray, behavior_score: int) -> IntakeResult:
        pill_visible  = False
        sirop_visible = False
        med_class     = ""
        best_conf     = 0.0

        # ── A) Pill / capsule check ────────────────────────────────────────
        if self._pill_model is not None:
            try:
                res = self._pill_model(bgr, conf=0.40, verbose=False)[0]
                if res.boxes and len(res.boxes) > 0:
                    best_idx = int(res.boxes.conf.argmax())
                    cls_name = res.names[int(res.boxes.cls[best_idx])].lower()
                    conf     = float(res.boxes.conf[best_idx])
                    if cls_name in _PILL_CLASSES:
                        pill_visible = True
                        med_class    = cls_name
                        best_conf    = conf
            except Exception as e:
                logging.warning(f"IntakeDetector pill check error: {e}")

        # ── B) Sirop fallback ──────────────────────────────────────────────
        if not pill_visible and self._coco_model is not None:
            try:
                res = self._coco_model(bgr, conf=0.40, verbose=False)[0]
                for box in res.boxes:
                    cls_name = res.names[int(box.cls[0])].lower()
                    conf     = float(box.conf[0])
                    if cls_name in _SIROP_COCO_CLASSES:
                        sirop_visible = True
                        med_class     = "sirop"
                        best_conf     = max(best_conf, conf)
                        break
            except Exception as e:
                logging.warning(f"IntakeDetector sirop check error: {e}")

        # ── C) Combine with behavior score ─────────────────────────────────
        effective_score = behavior_score
        if pill_visible:
            effective_score = min(behavior_score + 30, 100)
        elif sirop_visible:
            effective_score = min(behavior_score + 15, 100)

        med_visible = pill_visible or sirop_visible

        # ── Classify ───────────────────────────────────────────────────────
        if effective_score >= _INTAKE_CONFIRMED_SCORE and med_visible:
            return IntakeResult(
                label="INTAKE_CONFIRMED",
                confidence=round(
                    min((effective_score / 100) * 0.7 + best_conf * 0.3, 1.0), 2
                ),
                pill_visible=pill_visible,
                sirop_visible=sirop_visible,
                med_class=med_class,
                behavior_score=effective_score,
                feedback=f"✓ Intake confirmed ({med_class or 'medication'} detected, gesture done).",
            )
        elif effective_score >= _INTAKE_UNCERTAIN_SCORE or med_visible:
            if med_visible and effective_score < _INTAKE_UNCERTAIN_SCORE:
                feedback = "Medication visible — bring it closer to your mouth."
            elif not med_visible:
                feedback = "Hold the medicine up so the camera can see it."
            else:
                feedback = "Keep the gesture steady for a few more seconds."
            return IntakeResult(
                label="INTAKE_UNCERTAIN",
                confidence=round(effective_score / 100, 2),
                pill_visible=pill_visible,
                sirop_visible=sirop_visible,
                med_class=med_class,
                behavior_score=effective_score,
                feedback=feedback,
            )
        else:
            return IntakeResult(
                label="INTAKE_NOT_DETECTED",
                confidence=0.0,
                pill_visible=False,
                sirop_visible=False,
                med_class="",
                behavior_score=effective_score,
                feedback="Please show the medication and bring it to your mouth.",
            )


# ──────────────────────────────────────────────
# Public MedVerifier — exposes both phases
# ──────────────────────────────────────────────

class MedVerifier:
    """
    Two-phase medication verifier.

    Phase 1 — identify(frame) → MedVerifyResult
        OCR (Tesseract, fra+eng+ara) → rapidfuzz fuzzy match against prescription
        → CORRECT / WRONG / UNCERTAIN
        If OCR confidence < 40 %:
            YOLO presence fallback → ALWAYS UNCERTAIN (name cannot be confirmed visually)
        When CORRECT: result.alert_message contains ready-to-send patient alert.

    Phase 2 — check_intake(frame, behavior_score) → IntakeResult
        Only call after Phase 1 returned CORRECT.
        best_model.onnx confirms physical pill/capsule.
        COCO bottle/cup as sirop fallback.
        Combined with BehaviorDetector score.
        → INTAKE_CONFIRMED / INTAKE_UNCERTAIN / INTAKE_NOT_DETECTED

    Legacy helper — verify(frame) → MedVerifyResult
        Runs Phase 1 only. Backward-compatible with existing callers.
    """

    OCR_CONFIDENCE_FALLBACK = 0.40

    def __init__(
        self,
        prescription_source=None,
        yolo_model_path: str = "model/best_model.onnx",
        coco_model_path: str = "yolov8n.pt",
    ):
        self.prescription  = load_prescription(prescription_source)
        self._ocr_fallback = _YOLOPresenceFallback(yolo_model_path)
        self._intake_det   = _IntakeDetector(yolo_model_path, coco_model_path)

    # ── Phase 1 ───────────────────────────────

    def identify(self, bgr: np.ndarray) -> MedVerifyResult:
        """
        Read the medicine label via OCR and match against prescription.

        CORRECT  → name + dose confirmed → caller fires patient alert
        WRONG    → name matches, dose differs → caller fires warning
        UNCERTAIN → OCR failed → prompt patient to show label clearly

        YOLO is used ONLY as a presence hint when OCR yields nothing.
        It NEVER produces a CORRECT result — the name must come from OCR.
        """
        raw_text = extract_text_ocr(bgr)
        result   = match_against_prescription(raw_text, self.prescription)

        if result.confidence < self.OCR_CONFIDENCE_FALLBACK or not raw_text.strip():
            yolo_result = self._ocr_fallback.detect_presence(bgr)
            # Only substitute if YOLO adds more signal
            # but NEVER allow it to raise to CORRECT
            if yolo_result.confidence > result.confidence:
                return yolo_result   # still UNCERTAIN — see _YOLOPresenceFallback contract

        return result

    # ── Phase 2 ───────────────────────────────

    def check_intake(
        self,
        bgr: np.ndarray,
        behavior_score: int = 0,
    ) -> IntakeResult:
        """
        Physically confirm the patient is taking the medication.
        Call ONLY after identify() returned CORRECT.

        Parameters
        ----------
        bgr            : current camera frame
        behavior_score : rolling score from BehaviorDetector (0–100)
        """
        return self._intake_det.check(bgr, behavior_score)

    # ── Legacy wrapper ────────────────────────

    def verify(self, bgr: np.ndarray) -> MedVerifyResult:
        """Backward-compatible wrapper → runs Phase 1 (identify) only."""
        return self.identify(bgr)

    # ── Debug overlays ────────────────────────

    def draw_debug(self, bgr: np.ndarray, result: MedVerifyResult) -> np.ndarray:
        colour = (0, 200, 0)   if result.label == "CORRECT"   else \
                 (0, 0, 220)   if result.label == "WRONG"     else \
                 (0, 165, 255)
        cv2.putText(
            bgr,
            f"ID: {result.label} ({result.confidence:.0%}) [{result.method}]",
            (12, bgr.shape[0] - 60),
            cv2.FONT_HERSHEY_SIMPLEX, 0.72, colour, 2,
        )
        cv2.putText(
            bgr, result.feedback,
            (12, bgr.shape[0] - 30),
            cv2.FONT_HERSHEY_SIMPLEX, 0.52, (220, 220, 220), 1,
        )
        return bgr

    def draw_intake_debug(self, bgr: np.ndarray, result: IntakeResult) -> np.ndarray:
        colour = (0, 200, 0)   if result.label == "INTAKE_CONFIRMED"  else \
                 (0, 165, 255) if result.label == "INTAKE_UNCERTAIN"  else \
                 (0, 0, 220)
        cv2.putText(
            bgr,
            f"INTAKE: {result.label} (score {result.behavior_score})",
            (12, bgr.shape[0] - 90),
            cv2.FONT_HERSHEY_SIMPLEX, 0.72, colour, 2,
        )
        cv2.putText(
            bgr, result.feedback,
            (12, bgr.shape[0] - 60),
            cv2.FONT_HERSHEY_SIMPLEX, 0.52, (220, 220, 220), 1,
        )
        return bgr