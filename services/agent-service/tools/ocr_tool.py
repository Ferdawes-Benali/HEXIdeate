import requests
import logging
from config import settings

logger = logging.getLogger(__name__)

def scan_pill(image_base64: str) -> dict:
    """
    Sends image to vision service. 
    Strictly handles the hand-off to the OCR model.
    """
    if not image_base64:
        return {"label": "unknown", "confidence": 0.0, "error": "empty_image"}

    try:
        response = requests.post(
            f"{settings.VISION_SERVICE_URL}/ocr",
            json={"image": image_base64},
            timeout=12,
        )
        response.raise_for_status()
        data = response.json()

        label = data.get("label", "unknown")
        confidence = data.get("confidence", 0.0)

        return {"label": label, "confidence": confidence}

    except requests.exceptions.Timeout:
        logger.error("Vision service timed out.")
        return {"label": "error_timeout", "confidence": 0.0}
    except Exception as e:
        logger.error(f"[ocr_tool] Vision service failure: {str(e)}")
        return {"label": "unknown", "confidence": 0.0}