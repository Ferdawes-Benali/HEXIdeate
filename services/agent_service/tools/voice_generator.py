import requests
from ..config import settings


def text_to_speech(text: str, lang: str = "ar-TN") -> bytes | None:
    """
    Converts text to speech via the voice-service TTS endpoint.
    Returns raw audio bytes (WAV/MP3) or None on failure.
    """
    try:
        response = requests.post(
            f"{settings.VOICE_SERVICE_URL}/tts",
            json={"text": text, "lang": lang},
            timeout=15,
        )
        response.raise_for_status()
        return response.content
    except Exception as e:
        print(f"[voice_generator] TTS error: {e}")
        return None


def speech_to_text(audio_base64: str, lang: str = "ar-TN") -> str:
    """
    Transcribes audio to text via the voice-service STT endpoint.
    Returns transcribed string or empty string on failure.
    """
    try:
        response = requests.post(
            f"{settings.VOICE_SERVICE_URL}/stt",
            json={"audio": audio_base64, "lang": lang},
            timeout=15,
        )
        response.raise_for_status()
        return response.json().get("transcript", "")
    except Exception as e:
        print(f"[voice_generator] STT error: {e}")
        return ""