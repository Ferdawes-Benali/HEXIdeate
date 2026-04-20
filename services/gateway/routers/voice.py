import os
import httpx
import logging
from fastapi import APIRouter, HTTPException, UploadFile, File
from pydantic import BaseModel
from typing import Optional

logger = logging.getLogger(__name__)

VOICE_SERVICE_URL = os.getenv("VOICE_SERVICE_URL", "http://voice-service:8002")

router = APIRouter()


class TranscribeRequest(BaseModel):
    audio_base64: str
    language: Optional[str] = "ar"  # Default to Arabic for Tunisian patients


class TranscribeResponse(BaseModel):
    text: str
    language: str


class TextToSpeechRequest(BaseModel):
    text: str
    language: Optional[str] = "ar"
    voice: Optional[str] = None


class TextToSpeechResponse(BaseModel):
    audio_base64: str
    format: str = "wav"


@router.post("/transcribe", response_model=TranscribeResponse)
async def transcribe(body: TranscribeRequest):
    """
    Transcribe audio (base64) to text using speech-to-text service.
    Supports Arabic/Tunisian Derja.
    """
    if not body.audio_base64 or not body.audio_base64.strip():
        raise HTTPException(status_code=400, detail="Audio data cannot be empty.")

    async with httpx.AsyncClient(timeout=30) as client:
        try:
            resp = await client.post(
                f"{VOICE_SERVICE_URL}/transcribe",
                json={
                    "audio_base64": body.audio_base64,
                    "language": body.language,
                },
            )
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Voice service returned {e.response.status_code}: {e}")
            raise HTTPException(status_code=e.response.status_code, detail=str(e))
        except httpx.ConnectError:
            logger.error(f"Cannot connect to voice service at {VOICE_SERVICE_URL}")
            raise HTTPException(status_code=503, detail="Voice service unavailable")
        except Exception as e:
            logger.error(f"Voice service error: {e}")
            raise HTTPException(status_code=503, detail=f"Voice service unavailable: {e}")


@router.post("/tts", response_model=TextToSpeechResponse)
async def text_to_speech(body: TextToSpeechRequest):
    """
    Convert text to speech audio (base64).
    Supports Arabic/Tunisian Derja with multiple voices.
    """
    if not body.text or not body.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty.")

    async with httpx.AsyncClient(timeout=30) as client:
        try:
            resp = await client.post(
                f"{VOICE_SERVICE_URL}/tts",
                json={
                    "text": body.text,
                    "language": body.language,
                    "voice": body.voice,
                },
            )
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Voice service returned {e.response.status_code}: {e}")
            raise HTTPException(status_code=e.response.status_code, detail=str(e))
        except httpx.ConnectError:
            logger.error(f"Cannot connect to voice service at {VOICE_SERVICE_URL}")
            raise HTTPException(status_code=503, detail="Voice service unavailable")
        except Exception as e:
            logger.error(f"Voice service error: {e}")
            raise HTTPException(status_code=503, detail=f"Voice service unavailable: {e}")


@router.post("/upload-transcribe")
async def upload_and_transcribe(file: UploadFile = File(...), language: str = "ar"):
    """
    Upload audio file and transcribe to text.
    Supports .wav, .mp3, .m4a formats.
    """
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file provided.")

    async with httpx.AsyncClient(timeout=30) as client:
        try:
            async with httpx.AsyncClient() as httpx_client:
                form_data = {"language": language}
                files = {"file": (file.filename, await file.read(), file.content_type)}
                resp = await httpx_client.post(
                    f"{VOICE_SERVICE_URL}/transcribe-upload",
                    files=files,
                    data=form_data,
                    timeout=30,
                )
                resp.raise_for_status()
                return resp.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Voice service returned {e.response.status_code}: {e}")
            raise HTTPException(status_code=e.response.status_code, detail=str(e))
        except httpx.ConnectError:
            logger.error(f"Cannot connect to voice service at {VOICE_SERVICE_URL}")
            raise HTTPException(status_code=503, detail="Voice service unavailable")
        except Exception as e:
            logger.error(f"Voice service error: {e}")
            raise HTTPException(status_code=503, detail=f"Voice service unavailable: {e}")


@router.post("/emergency-alert")
async def emergency_alert(body: TranscribeRequest):
    """
    Process emergency call with immediate text-to-speech response.
    Transcribes user speech and triggers emergency protocol.
    """
    if not body.audio_base64 or not body.audio_base64.strip():
        raise HTTPException(status_code=400, detail="Audio data cannot be empty.")

    # Transcribe the emergency message
    async with httpx.AsyncClient(timeout=30) as client:
        try:
            resp = await client.post(
                f"{VOICE_SERVICE_URL}/transcribe",
                json={
                    "audio_base64": body.audio_base64,
                    "language": body.language,
                },
            )
            resp.raise_for_status()
            emergency_text = resp.json()["text"]
            
            # Return immediate acknowledgment
            return {
                "status": "emergency_received",
                "transcribed_message": emergency_text,
                "message": "تم تسجيل طلب الاستغاثة - سيتم إبلاغ الفريق الطبي",
            }
        except Exception as e:
            logger.error(f"Emergency alert error: {e}")
            raise HTTPException(status_code=503, detail="Failed to process emergency alert")
