FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    fastapi uvicorn sqlmodel \
    pydantic pydantic-settings requests

COPY . .

CMD ["uvicorn", "router:app", "--host", "0.0.0.0", "--port", "8003"]