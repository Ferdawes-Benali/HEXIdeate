import requests
from ..config import settings


def scan_pill(image_base64: str) -> dict:
    """
    Sends a base64-encoded image to the vision service for pill label OCR.
    Returns: {"label": str, "confidence": float} or {"label": "unknown", "confidence": 0.0}
    """
    try:
        response = requests.post(
            f"{settings.VISION_SERVICE_URL}/ocr",
            json={"image": image_base64},
            timeout=10,
        )
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print(f"[ocr_tool] Error: {e}")
        return {"label": "unknown", "confidence": 0.0}