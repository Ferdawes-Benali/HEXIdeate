FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    fastapi uvicorn sqlmodel \
    pydantic pydantic-settings requests email-validator psycopg2-binary asyncpg

COPY services/shared /app/shared
COPY services/notification-service /app

CMD ["uvicorn", "router:app", "--host", "0.0.0.0", "--port", "8003"]