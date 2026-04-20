import requests
import logging
import base64
from config import settings

logger = logging.getLogger(__name__)

# Using a Session is faster for microservices as it reuses the TCP connection
_session = requests.Session()

def text_to_speech(text: str, lang: str = "ar-TN") -> bytes | None:
    """
    Returns raw audio bytes. 
    Ensure the caller handles the None case (e.g., skip voice output).
    """
    if not text.strip():
        return None

    try:
        response = _session.post(
            f"{settings.VOICE_SERVICE_URL}/tts",
            json={"text": text, "lang": lang},
            timeout=15, # Voice generation is slow, keep a high timeout
        )
        response.raise_for_status()
        return response.content
    except Exception as e:
        logger.error(f"[voice_generator] TTS failed: {e}")
        return None


def speech_to_text(audio_base64: str, lang: str = "ar-TN") -> str:
    """
    Transcribes audio. If audio is provided as raw bytes elsewhere, 
    consider moving away from base64 to multipart/form-data.
    """
    if not audio_base64:
        return ""

    try:
        response = _session.post(
            f"{settings.VOICE_SERVICE_URL}/stt",
            json={"audio": audio_base64, "lang": lang},
            timeout=20, # Transcription (Whisper/etc) takes time
        )
        response.raise_for_status()
        
        result = response.json()
        transcript = result.get("transcript", "").strip()
        
        # If confidence is provided by your voice-service, check it here
        return transcript

    except Exception as e:
        logger.error(f"[voice_generator] STT failed: {e}")
        return ""