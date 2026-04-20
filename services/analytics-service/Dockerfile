FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    fastapi uvicorn sqlmodel \
    scikit-learn pandas numpy \
    pydantic pydantic-settings email-validator psycopg2-binary asyncpg

COPY services/shared /app/shared

COPY services/analytics-service /app

RUN mkdir -p model

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8004"]