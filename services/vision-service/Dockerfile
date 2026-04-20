# Use a lightweight Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies for OpenCV and ONNX
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies directly
# Using --no-cache-dir to save space on your disk!
RUN pip install --no-cache-dir \
    fastapi uvicorn opencv-python-headless onnxruntime \
    numpy pillow python-multipart mediapipe \
    ultralytics pytesseract rapidfuzz

# Copy the rest of the application code
COPY . .

# Ensure the model directory exists
RUN mkdir -p /app/model

# Expose the port the service runs on
EXPOSE 8008

# Start the service
CMD ["python", "-m", "uvicorn", "detector:app", "--host", "0.0.0.0", "--port", "8008"]