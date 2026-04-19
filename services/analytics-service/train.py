"""
Trains a skip-risk classifier on historical IntakeHistory data.
Saves the model to model/skip_classifier.pkl for use by predictor.py.
"""
import os
import pickle
import logging
import sys
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
from sqlmodel import Session, select, create_engine
from datetime import datetime, timedelta, timezone

# Add parent directory to path for imports
sys.path.insert(0, '..')

from shared.models import Patient, Medication, IntakeHistory
from shared.config import settings

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

DATABASE_URL = os.getenv("DATABASE_URL", settings.DATABASE_URL)
engine = create_engine(DATABASE_URL)


def extract_features(patient_id: int, session: Session) -> dict:
    """Build a feature vector for a single patient from their last 30 days."""
    cutoff = datetime.now(timezone.utc) - timedelta(days=30)

    try:
        rows = session.exec(
            select(IntakeHistory, Medication)
            .join(Medication)
            .where(Medication.patient_id == patient_id)
            .where(IntakeHistory.timestamp >= cutoff)
        ).all()
    except Exception as e:
        logger.error(f"extract_features db error for patient {patient_id}: {e}")
        return None

    if not rows:
        return None

    total = len(rows)
    missed = sum(1 for intake, _ in rows if intake.status == "wrong_pill")
    success = sum(1 for intake, _ in rows if intake.status == "success")
    streak = 0
    for intake, _ in sorted(rows, key=lambda x: x[0].timestamp, reverse=True):
        if intake.status == "success":
            streak += 1
        else:
            break

    return {
        "total_doses": total,
        "missed_rate": missed / total if total > 0 else 0,
        "success_rate": success / total if total > 0 else 0,
        "current_streak": streak,
        "days_since_last_miss": (
            (datetime.now(timezone.utc) - max(
                (i.timestamp for i, _ in rows if i.status == "wrong_pill"),
                default=cutoff,
            )).days
        ),
    }


def build_dataset(session: Session) -> pd.DataFrame:
    """Build training dataset from all patients."""
    try:
        patient_ids = [row.id for row in session.exec(select(Patient)).all()]
        logger.info(f"Found {len(patient_ids)} patients for training")
    except Exception as e:
        logger.error(f"Failed to fetch patients: {e}")
        return pd.DataFrame()

    records = []
    for pid in patient_ids:
        feats = extract_features(pid, session)
        if feats:
            feats["label"] = 1 if feats["missed_rate"] > 0.3 else 0
            records.append(feats)
    
    logger.info(f"Built features for {len(records)} patients")
    return pd.DataFrame(records)


def train():
    os.makedirs("model", exist_ok=True)
    with Session(engine) as session:
        df = build_dataset(session)

    if df.empty or len(df) < 10:
        logger.warning("[train] Not enough data to train. Need at least 10 patients.")
        return

    feature_cols = ["total_doses", "missed_rate", "success_rate", "current_streak", "days_since_last_miss"]
    X = df[feature_cols].values
    y = df["label"].values

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    clf = RandomForestClassifier(n_estimators=100, random_state=42)
    clf.fit(X_train, y_train)

    y_pred = clf.predict(X_test)
    logger.info("Classification Report:\n" + classification_report(y_test, y_pred, target_names=["low_risk", "high_risk"]))

    with open("model/skip_classifier.pkl", "wb") as f:
        pickle.dump(clf, f)
    logger.info("[train] Model saved to model/skip_classifier.pkl")


if __name__ == "__main__":
    train()