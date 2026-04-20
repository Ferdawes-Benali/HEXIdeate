"""Analytics microservice for skip-risk prediction and statistics"""
import logging
import os
import pickle
from datetime import datetime, timedelta, timezone
from typing import Optional

import numpy as np
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlmodel import func, Session

import sys
sys.path.insert(0, '..')

from shared.config import settings
from shared.database import engine, async_session, get_session
from shared.models import Patient, Medication, IntakeHistory, MedicationSchedule
from shared.schemas import PredictionResponse
from shared.constants import IntakeStatus, ML_FEATURE_COLUMNS
from shared.utils import get_logger

logger = get_logger(__name__)

app = FastAPI(title="HexIdeate Analytics Service", version="1.0.0")


@app.on_event("startup")
async def startup():
    """Initialize database on startup"""
    logger.info("Analytics service starting up...")


@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "ok", "service": "analytics"}


_clf = None


def _load_model():
    """Load the trained skip-risk classifier from disk."""
    global _clf
    model_path = "model/skip_classifier.pkl"
    try:
        if os.path.exists(model_path):
            with open(model_path, "rb") as f:
                _clf = pickle.load(f)
            logger.info("[predictor] Model loaded successfully.")
        else:
            logger.warning("[predictor] No trained model found at %s. Run train.py first.", model_path)
    except Exception as e:
        logger.error("[predictor] Failed to load model: %s", e)
        _clf = None


@app.on_event("startup")
async def load_model_on_startup():
    _load_model()


class SkipRiskRequest(BaseModel):
    patient_id: int
    days_lookback: int = 30


class SkipRiskResponse(BaseModel):
    patient_id: int
    risk: str
    missed_rate: float
    success_rate: float
    current_streak: int
    total_doses: int


class StatsResponse(BaseModel):
    patient_id: int
    period_days: int
    total_doses: int
    success_count: int
    wrong_pill_count: int
    adherence_pct: float


def _fetch_features(patient_id: int, days: int) -> Optional[dict]:
    """
    Fetch intake history and compute features for a patient.
    Feature names match train.py for consistency.
    Safe against division by zero.
    """
    if patient_id <= 0 or days <= 0:
        logger.warning("_fetch_features: invalid patient_id=%s or days=%s", patient_id, days)
        return None

    cutoff = datetime.now(timezone.utc) - timedelta(days=days)

    try:
        with Session(engine) as session:
            rows = session.exec(
                select(IntakeHistory, Medication)
                .join(Medication)
                .where(Medication.patient_id == patient_id)
                .where(IntakeHistory.timestamp >= cutoff)
            ).all()
    except Exception as e:
        logger.error("_fetch_features db error for patient %s: %s", patient_id, e)
        return None

    if not rows:
        logger.debug("_fetch_features: no intake history for patient %s in last %s days", patient_id, days)
        return None

    total = len(rows)
    missed = sum(1 for i, _ in rows if i.status == "wrong_pill")
    success = sum(1 for i, _ in rows if i.status == "success")

    # Compute current streak (consecutive successes from most recent)
    streak = 0
    for intake, _ in sorted(rows, key=lambda x: x[0].timestamp, reverse=True):
        if intake.status == "success":
            streak += 1
        else:
            break

    # Compute days since last miss
    miss_timestamps = [i.timestamp for i, _ in rows if i.status == "wrong_pill"]
    days_since_last_miss = (
        (datetime.now(timezone.utc) - max(miss_timestamps)).days 
        if miss_timestamps else days
    )

    # Use consistent feature names matching train.py
    return {
        "total_doses": total,
        "missed_rate": missed / total if total > 0 else 0.0,
        "success_rate": success / total if total > 0 else 0.0,
        "current_streak": streak,
        "days_since_last_miss": days_since_last_miss,
    }


@app.post("/predict-skip-risk", response_model=SkipRiskResponse)
def predict_skip_risk(req: SkipRiskRequest):
    """Predict skip risk for a patient using the trained model or heuristics."""
    if req.patient_id <= 0:
        raise HTTPException(status_code=400, detail="Invalid patient_id.")
    if req.days_lookback <= 0:
        raise HTTPException(status_code=400, detail="days_lookback must be positive.")

    feats = _fetch_features(req.patient_id, req.days_lookback)
    if feats is None:
        raise HTTPException(status_code=404, detail="No intake history found for patient.")

    risk = "low"
    try:
        if _clf is not None:
            # Use trained model
            X = np.array([[
                feats["total_doses"],
                feats["missed_rate"],
                feats["success_rate"],
                feats["current_streak"],
                feats["days_since_last_miss"],
            ]])
            label = _clf.predict(X)[0]
            risk = "high" if label == 1 else "low"
        else:
            # Fallback to heuristics
            if feats["missed_rate"] > 0.4:
                risk = "high"
            elif feats["missed_rate"] > 0.2:
                risk = "medium"
    except Exception as e:
        logger.error("predict_skip_risk error: %s", e)
        # Fallback to heuristics on any error
        if feats["missed_rate"] > 0.4:
            risk = "high"
        elif feats["missed_rate"] > 0.2:
            risk = "medium"

    return SkipRiskResponse(
        patient_id=req.patient_id,
        risk=risk,
        missed_rate=round(feats["missed_rate"], 3),
        success_rate=round(feats["success_rate"], 3),
        current_streak=feats["current_streak"],
        total_doses=feats["total_doses"],
    )


@app.get("/stats/{patient_id}", response_model=StatsResponse)
def get_stats(patient_id: int, days: int = 30):
    """Get adherence statistics for a patient."""
    if patient_id <= 0:
        raise HTTPException(status_code=400, detail="Invalid patient_id.")
    if days <= 0:
        raise HTTPException(status_code=400, detail="days must be positive.")

    feats = _fetch_features(patient_id, days)
    if feats is None:
        raise HTTPException(status_code=404, detail="No intake history found for patient.")

    # Calculate counts from rates
    success_count = int(feats["success_rate"] * feats["total_doses"])
    wrong_pill_count = int(feats["missed_rate"] * feats["total_doses"])

    return StatsResponse(
        patient_id=patient_id,
        period_days=days,
        total_doses=feats["total_doses"],
        success_count=success_count,
        wrong_pill_count=wrong_pill_count,
        adherence_pct=round(feats["success_rate"] * 100, 1),
    )


@app.get("/health")
def health():
    """Health check endpoint."""
    return {"status": "ok", "model_loaded": _clf is not None}