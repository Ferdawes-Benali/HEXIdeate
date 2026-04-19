FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    fastapi uvicorn sqlmodel \
    scikit-learn pandas numpy \
    pydantic pydantic-settings

COPY . .

RUN mkdir -p model

CMD ["uvicorn", "predictor:app", "--host", "0.0.0.0", "--port", "8004"]