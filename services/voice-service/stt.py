"""
stt.py  (voice-service)
─────────────────────────
FastAPI server exposing speech-to-text capabilities to the agent and gateway.

Endpoints
  POST /transcribe          — transcribe audio from base64 or file upload
  POST /transcribe-stream   — streaming transcription
  GET  /health              — liveness probe
"""

from __future__ import annotations

import base64
import logging
import os
from contextlib import asynccontextmanager
from typing import Optional, Literal

import numpy as np
import soundfile as sf
import io
from fastapi import FastAPI, HTTPException, UploadFile, File
from pydantic import BaseModel

logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────
# Singleton STT pipeline (loaded once at startup)
# ──────────────────────────────────────────────

_stt_model: Optional[object] = None


def _load_stt_model():
    """Load the speech-to-text model based on environment configuration."""
    global _stt_model
    
    model_size = os.getenv("STT_MODEL_SIZE", "base")
    model_type = os.getenv("STT_MODEL_TYPE", "whisper")
    
    logger.info(f"Loading STT model: type={model_type}, size={model_size}")
    
    if model_type == "whisper":
        try:
            import whisper
            _stt_model = whisper.load_model(model_size)
            logger.info(f"Whisper model '{model_size}' loaded successfully.")
        except Exception as e:
            logger.error(f"Failed to load Whisper model: {e}")
            raise
    elif model_type == "faster-whisper":
        try:
            from faster_whisper import WhisperModel
            _stt_model = WhisperModel(
                model_size,
                device=os.getenv("STT_DEVICE", "cpu"),
                compute_type=os.getenv("STT_COMPUTE_TYPE", "int8")
            )
            logger.info(f"Faster-Whisper model '{model_size}' loaded successfully.")
        except Exception as e:
            logger.error(f"Failed to load Faster-Whisper model: {e}")
            raise
    else:
        raise ValueError(f"Unknown STT_MODEL_TYPE: {model_type}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _stt_model
    logger.info("Initializing STT service...")
    _load_stt_model()
    logger.info("STT service ready.")
    yield
    logger.info("Shutting down STT service.")
    _stt_model = None


app = FastAPI(title="DwaFi Voice Service - STT", lifespan=lifespan)


# ──────────────────────────────────────────────
# Request / Response schemas
# ──────────────────────────────────────────────

class TranscribeRequest(BaseModel):
    """
    Request body for base64-encoded audio transcription.
    """
    audio_base64: str
    language: Optional[str] = None
    task: Literal["transcribe", "translate"] = "transcribe"
    prompt: Optional[str] = None
    temperature: float = 0.0


class TranscriptionResponse(BaseModel):
    """
    Response containing transcribed text and metadata.
    """
    text: str
    language: str
    duration: Optional[float] = None
    segments: Optional[list] = None


class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    model_type: Optional[str] = None


# ──────────────────────────────────────────────
# Helper functions
# ──────────────────────────────────────────────

def _decode_audio(audio_data: bytes) -> tuple[np.ndarray, int]:
    """
    Decode audio data from bytes to numpy array.
    Supports WAV, MP3, OGG formats via soundfile.
    """
    try:
        audio, samplerate = sf.read(io.BytesIO(audio_data))
        return audio, samplerate
    except Exception as e:
        logger.error(f"Failed to decode audio: {e}")
        raise HTTPException(status_code=400, detail=f"Invalid audio format: {str(e)}")


def _base64_to_audio(audio_base64: str) -> bytes:
    """Decode base64 string to bytes."""
    try:
        return base64.b64decode(audio_base64)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid base64 audio: {str(e)}")


# ──────────────────────────────────────────────
# Endpoints
# ──────────────────────────────────────────────

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Liveness probe endpoint."""
    return HealthResponse(
        status="healthy" if _stt_model else "unhealthy",
        model_loaded=_stt_model is not None,
        model_type=os.getenv("STT_MODEL_TYPE", "whisper")
    )


@app.post("/transcribe", response_model=TranscriptionResponse)
async def transcribe(request: TranscribeRequest):
    """
    Transcribe base64-encoded audio to text.
    
    - **audio_base64**: Base64-encoded audio data (WAV, MP3, OGG)
    - **language**: Source language code (e.g., 'en', 'fr', 'ar') - auto-detected if None
    - **task**: 'transcribe' for speech-to-text or 'translate' to English
    - **prompt**: Optional context prompt to improve transcription
    - **temperature**: Sampling temperature (0.0 = deterministic)
    """
    if not _stt_model:
        raise HTTPException(status_code=503, detail="STT model not loaded")
    
    try:
        # Decode base64 audio
        audio_bytes = _base64_to_audio(request.audio_base64)
        audio_array, samplerate = _decode_audio(audio_bytes)
        
        # Convert to 16kHz mono if needed for Whisper
        if len(audio_array.shape) > 1:
            audio_array = audio_array.mean(axis=1)  # Stereo to mono
        
        # Ensure float32
        audio_array = audio_array.astype(np.float32)
        
        model_type = os.getenv("STT_MODEL_TYPE", "whisper")
        
        if model_type == "whisper":
            import whisper
            
            # Prepare options
            options = {"task": request.task, "temperature": request.temperature}
            if request.language:
                options["language"] = request.language
            if request.prompt:
                options["prompt"] = request.prompt
            
            # Run transcription
            result = _stt_model.transcribe(audio_array, **options)
            
            return TranscriptionResponse(
                text=result["text"].strip(),
                language=result.get("language", request.language or "unknown"),
                duration=result.get("duration"),
                segments=result.get("segments", [])
            )
            
        elif model_type == "faster-whisper":
            # Faster-Whisper API
            segments, info = _stt_model.transcribe(
                audio_array,
                language=request.language,
                task=request.task,
                temperature=request.temperature,
                prompt=request.prompt
            )
            
            # Collect all segments
            transcribed_text = " ".join([seg.text for seg in segments])
            
            return TranscriptionResponse(
                text=transcribed_text.strip(),
                language=info.language if info.language else (request.language or "unknown"),
                duration=info.duration
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Transcription failed: {e}")
        raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")


@app.post("/transcribe-file", response_model=TranscriptionResponse)
async def transcribe_file(
    file: UploadFile = File(...),
    language: Optional[str] = None,
    task: Literal["transcribe", "translate"] = "transcribe",
    prompt: Optional[str] = None,
    temperature: float = 0.0
):
    """
    Transcribe an uploaded audio file to text.
    
    - **file**: Audio file (WAV, MP3, OGG, FLAC)
    - **language**: Source language code (e.g., 'en', 'fr', 'ar')
    - **task**: 'transcribe' or 'translate'
    - **prompt**: Optional context prompt
    - **temperature**: Sampling temperature
    """
    if not _stt_model:
        raise HTTPException(status_code=503, detail="STT model not loaded")
    
    try:
        # Read uploaded file
        audio_bytes = await file.read()
        audio_array, samplerate = _decode_audio(audio_bytes)
        
        # Convert to mono if stereo
        if len(audio_array.shape) > 1:
            audio_array = audio_array.mean(axis=1)
        
        audio_array = audio_array.astype(np.float32)
        
        model_type = os.getenv("STT_MODEL_TYPE", "whisper")
        
        if model_type == "whisper":
            import whisper
            
            options = {"task": task, "temperature": temperature}
            if language:
                options["language"] = language
            if prompt:
                options["prompt"] = prompt
            
            result = _stt_model.transcribe(audio_array, **options)
            
            return TranscriptionResponse(
                text=result["text"].strip(),
                language=result.get("language", language or "unknown"),
                duration=result.get("duration"),
                segments=result.get("segments", [])
            )
            
        elif model_type == "faster-whisper":
            segments, info = _stt_model.transcribe(
                audio_array,
                language=language,
                task=task,
                temperature=temperature,
                prompt=prompt
            )
            
            transcribed_text = " ".join([seg.text for seg in segments])
            
            return TranscriptionResponse(
                text=transcribed_text.strip(),
                language=info.language if info.language else (language or "unknown"),
                duration=info.duration
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"File transcription failed: {e}")
        raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")


@app.post("/transcribe-stream")
async def transcribe_stream():
    """
    Streaming transcription endpoint.
    Placeholder for future WebSocket-based streaming support.
    """
    raise HTTPException(
        status_code=501,
        detail="Streaming transcription not yet implemented"
    )