# voice-service/Dockerfile

# Build stage
FROM python:3.11-slim AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsndfile1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# Production stage
FROM python:3.11-slim

# Install system dependencies for audio processing
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsndfile1 \
    ffmpeg \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy application code
COPY . .

# Create directory for model caching
RUN mkdir -p /app/models /app/cache

# Environment variables for STT (Speech-to-Text)
ENV STT_MODEL_TYPE=whisper
ENV STT_MODEL_SIZE=base
ENV STT_DEVICE=cpu

# Environment variables for TTS (Text-to-Speech)
ENV TTS_MODEL_TYPE=coqui
ENV TTS_MODEL=en_US-lessac-medium
ENV TTS_DEVICE=cpu

# Expose ports
# STT runs on 8004, TTS runs on 8005 (can be configured)
EXPOSE 8004 8005

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8004/health')" || exit 1

# Run the appropriate service
# To run STT: python -m uvicorn stt:app --host 0.0.0.0 --port 8004
# To run TTS: python -m uvicorn tts:app --host 0.0.0.0 --port 8005
CMD ["python", "-m", "uvicorn", "stt:app", "--host", "0.0.0.0", "--port", "8004"]