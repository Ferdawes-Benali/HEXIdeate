FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    fastapi uvicorn httpx \
    pyjwt redis pydantic pydantic-settings sqlmodel email-validator psycopg2-binary asyncpg python-multipart python-jose[cryptography] passlib[bcrypt]

COPY services/shared /app/shared
COPY services/gateway /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]