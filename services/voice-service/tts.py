
from __future__ import annotations

import base64
import logging
import os
from contextlib import asynccontextmanager
from typing import Optional, Literal

import numpy as np
import soundfile as sf
import io
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

logger = logging.getLogger(__name__)



_tts_model: Optional[object] = None


def _load_tts_model():
    """Load the text-to-speech model based on environment configuration."""
    global _tts_model
    
    model_name = os.getenv("TTS_MODEL", "en_US-lessac-medium")
    model_type = os.getenv("TTS_MODEL_TYPE", "coqui")
    
    logger.info(f"Loading TTS model: type={model_type}, name={model_name}")
    
    if model_type == "coqui":
        try:
            from TTS.api import TTS
            device = os.getenv("TTS_DEVICE", "cpu")
            _tts_model = TTS(model_name, gpu=(device != "cpu"))
            logger.info(f"Coqui TTS model '{model_name}' loaded successfully.")
        except Exception as e:
            logger.error(f"Failed to load Coqui TTS model: {e}")
            raise
    elif model_type == "edge-tts":
        # Edge TTS doesn't require model loading
        logger.info("Edge TTS selected (no model loading required).")
        _tts_model = "edge-tts"
    elif model_type == "gtts":
        logger.info("Google TTS selected (no model loading required).")
        _tts_model = "gtts"
    elif model_type == "pyttsx3":
        import pyttsx3
        _tts_model = pyttsx3.init()
        logger.info("pyttsx3 engine initialized.")
    else:
        raise ValueError(f"Unknown TTS_MODEL_TYPE: {model_type}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _tts_model
    logger.info("Initializing TTS service...")
    _load_tts_model()
    logger.info("TTS service ready.")
    yield
    logger.info("Shutting down TTS service.")
    if hasattr(_tts_model, "stop"):
        _tts_model.stop()
    _tts_model = None


app = FastAPI(title="DwaFi Voice Service - TTS", lifespan=lifespan)


# ──────────────────────────────────────────────
# Request / Response schemas
# ──────────────────────────────────────────────

class SynthesizeRequest(BaseModel):
    """
    Request body for text-to-speech synthesis.
    """
    text: str
    language: Optional[str] = None
    voice_id: Optional[str] = None
    speed: float = 1.0
    pitch: float = 1.0
    output_format: Literal["wav", "mp3", "ogg"] = "wav"


class SynthesizeResponse(BaseModel):
    """
    Response containing base64-encoded audio.
    """
    audio_base64: str
    format: str
    sample_rate: int
    duration: Optional[float] = None


class VoiceInfo(BaseModel):
    """Information about an available voice."""
    id: str
    name: str
    language: str
    gender: Optional[str] = None


class VoicesResponse(BaseModel):
    """Response containing list of available voices."""
    voices: list[VoiceInfo]


class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    model_type: Optional[str] = None


# ──────────────────────────────────────────────
# Helper functions
# ──────────────────────────────────────────────

def _audio_to_base64(audio_data: np.ndarray, sample_rate: int, format: str) -> tuple[str, float]:
    """
    Convert numpy audio array to base64 string.
    Returns (base64_string, duration_in_seconds)
    """
    buffer = io.BytesIO()
    
    if format == "wav":
        sf.write(buffer, audio_data, sample_rate, format="WAV")
    elif format == "mp3":
        # Save as WAV first, then would need conversion
        sf.write(buffer, audio_data, sample_rate, format="WAV")
        # Note: MP3 encoding requires additional library
        logger.warning("MP3 output not fully implemented, returning WAV")
    elif format == "ogg":
        sf.write(buffer, audio_data, sample_rate, format="OGG")
    else:
        sf.write(buffer, audio_data, sample_rate, format="WAV")
    
    buffer.seek(0)
    audio_bytes = buffer.getvalue()
    duration = len(audio_data) / sample_rate
    
    return base64.b64encode(audio_bytes).decode("utf-8"), duration


# ──────────────────────────────────────────────
# Endpoints
# ──────────────────────────────────────────────

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Liveness probe endpoint."""
    return HealthResponse(
        status="healthy" if _tts_model else "unhealthy",
        model_loaded=_tts_model is not None,
        model_type=os.getenv("TTS_MODEL_TYPE", "coqui")
    )


@app.get("/voices", response_model=VoicesResponse)
async def list_voices():
    """
    List available TTS voices.
    Voice availability depends on the TTS model type.
    """
    model_type = os.getenv("TTS_MODEL_TYPE", "coqui")
    
    if model_type == "edge-tts":
        # Microsoft Edge TTS voices
        voices = [
            VoiceInfo(id="en-US-AriaNeural", name="Aria", language="en-US", gender="female"),
            VoiceInfo(id="en-US-GuyNeural", name="Guy", language="en-US", gender="male"),
            VoiceInfo(id="en-US-JennyNeural", name="Jenny", language="en-US", gender="female"),
            VoiceInfo(id="en-US-SaraNeural", name="Sara", language="en-US", gender="female"),
            VoiceInfo(id="fr-FR-DeniseNeural", name="Denise", language="fr-FR", gender="female"),
            VoiceInfo(id="fr-FR-HenriNeural", name="Henri", language="fr-FR", gender="male"),
            VoiceInfo(id="ar-SA-ZahraNeural", name="Zahra", language="ar-SA", gender="female"),
        ]
    elif model_type == "gtts":
        # Google TTS supports all Google Translate languages
        voices = [
            VoiceInfo(id="en", name="English", language="en"),
            VoiceInfo(id="fr", name="French", language="fr"),
            VoiceInfo(id="ar", name="Arabic", language="ar"),
            VoiceInfo(id="es", name="Spanish", language="es"),
            VoiceInfo(id="de", name="German", language="de"),
        ]
    elif model_type == "pyttsx3":
        voices = [
            VoiceInfo(id="default", name="Default System Voice", language="en"),
        ]
    else:
        # Coqui TTS - return default voices
        voices = [
            VoiceInfo(id="default", name="Default", language="en"),
        ]
    
    return VoicesResponse(voices=voices)


@app.post("/synthesize", response_model=SynthesizeResponse)
async def synthesize(request: SynthesizeRequest):
    """
    Synthesize text to speech and return base64-encoded audio.
    
    - **text**: Text to synthesize
    - **language**: Language code (e.g., 'en', 'fr', 'ar') - auto-detected if None
    - **voice_id**: Specific voice to use (model-dependent)
    - **speed**: Speech rate (0.5 - 2.0, default 1.0)
    - **pitch**: Pitch adjustment (0.5 - 2.0, default 1.0)
    - **output_format**: Output format ('wav', 'mp3', 'ogg')
    """
    if not _tts_model:
        raise HTTPException(status_code=503, detail="TTS model not loaded")
    
    if not request.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")
    
    try:
        model_type = os.getenv("TTS_MODEL_TYPE", "coqui")
        
        if model_type == "coqui":
            # Coqui TTS synthesis
            speaker_id = request.voice_id if request.voice_id else None
            
            # Generate speech
            wav = _tts_model.tts(
                text=request.text,
                speaker=speaker_id,
                language=request.language
            )
            
            # Handle list output (multiple speakers)
            if isinstance(wav, list):
                wav = np.array(wav[0]) if wav else np.array([])
            
            audio_base64, duration = _audio_to_base64(
                wav, 
                22050,  # Coqui default sample rate
                request.output_format
            )
            
            return SynthesizeResponse(
                audio_base64=audio_base64,
                format=request.output_format,
                sample_rate=22050,
                duration=duration
            )
            
        elif model_type == "edge-tts":
            import edge_tts
            from edge_tts import VOICES
            
            # Select voice
            if request.voice_id:
                voice = request.voice_id
            elif request.language:
                # Try to find a voice for the requested language
                lang_prefix = request.language.split("-")[0]
                matching = [v for v in VOICES if v["Language"].startswith(lang_prefix)]
                voice = matching[0]["Name"] if matching else "en-US-AriaNeural"
            else:
                voice = "en-US-AriaNeural"
            
            # Create communicate object
            communicate = edge_tts.Communicate(request.text, voice)
            
            # Collect audio data
            audio_data = b""
            async for chunk in communicate.stream():
                if chunk["type"] == "audio":
                    audio_data += chunk["data"]
            
            # Convert to numpy array (16-bit PCM)
            audio_array = np.frombuffer(audio_data, dtype=np.int16).astype(np.float32) / 32768.0
            
            audio_base64, duration = _audio_to_base64(
                audio_array,
                24000,  # Edge TTS sample rate
                request.output_format
            )
            
            return SynthesizeResponse(
                audio_base64=audio_base64,
                format=request.output_format,
                sample_rate=24000,
                duration=duration
            )
            
        elif model_type == "gtts":
            from gtts import gTTS
            
            # Determine language
            lang = request.language if request.language else "en"
            
            # Generate speech
            tts = gTTS(text=request.text, lang=lang, slow=(request.speed < 0.8))
            
            # Save to buffer
            buffer = io.BytesIO()
            tts.write_to_fp(buffer)
            buffer.seek(0)
            
            audio_bytes = buffer.read()
            audio_base64 = base64.b64encode(audio_bytes).decode("utf-8")
            
            # Estimate duration (rough approximation)
            duration = len(request.text) / 15  # ~15 chars/sec for normal speed
            
            return SynthesizeResponse(
                audio_base64=audio_base64,
                format="mp3",
                sample_rate=24000,  # gTTS uses 24kHz
                duration=duration
            )
            
        elif model_type == "pyttsx3":
            # pyttsx3 synthesis
            if request.voice_id:
                voices = _tts_model.getProperty('voices')
                for voice in voices:
                    if voice.id == request.voice_id:
                        _tts_model.setProperty('voice', voice.id)
                        break
            
            _tts_model.setProperty('rate', int(200 * request.speed))  # Default rate is 200
            _tts_model.setProperty('pitch', request.pitch)
            
            # Save to temporary file
            import tempfile
            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
                temp_path = f.name
            
            _tts_model.save_to_file(request.text, temp_path)
            _tts_model.runAndWait()
            
            # Read the generated audio
            audio_array, sample_rate = sf.read(temp_path)
            
            audio_base64, duration = _audio_to_base64(
                audio_array,
                sample_rate,
                request.output_format
            )
            
            # Clean up
            os.remove(temp_path)
            
            return SynthesizeResponse(
                audio_base64=audio_base64,
                format=request.output_format,
                sample_rate=sample_rate,
                duration=duration
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Synthesis failed: {e}")
        raise HTTPException(status_code=500, detail=f"Synthesis failed: {str(e)}")


@app.post("/synthesize-stream")
async def synthesize_stream():
    """
    Streaming synthesis endpoint.
    Placeholder for future WebSocket-based streaming support.
    """
    raise HTTPException(
        status_code=501,
        detail="Streaming synthesis not yet implemented"
    )