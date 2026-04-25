FROM python:3.11-slim

WORKDIR /app

COPY services/shared /app/shared

COPY services/agent-service/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir psycopg2-binary pydantic-settings email-validator asyncpg

COPY services/agent-service /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]