"""Notification microservice for dispatching alerts"""
import logging
import os
from datetime import datetime, timezone
from typing import Literal, Optional

from fastapi import FastAPI, HTTPException, Depends
from sqlmodel import Session, select
from pydantic import BaseModel
import requests

import sys
sys.path.insert(0, '..')

from shared.config import settings
from shared.database import engine, get_session
from shared.models import Patient, Alert, Medication
from shared.utils import get_logger
from drug_db import find_interactions, normalize_med_name

logger = get_logger(__name__)

# Twilio configuration (optional)
TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID", "")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN", "")
TWILIO_FROM_NUMBER = os.getenv("TWILIO_FROM_NUMBER", "")
FCM_SERVER_KEY = os.getenv("FCM_SERVER_KEY", "")

app = FastAPI(title="MedMind Notification Service", version="1.0.0")


class DispatchRequest(BaseModel):
    patient_id: int
    alert_type: Literal["missed_dose", "wrong_pill", "drug_interaction"]
    message: str
    severity: Literal["low", "medium", "high"] = "medium"
    title: Optional[str] = None


class InteractionCheckRequest(BaseModel):
    medications: list[str]


class InteractionCheckResponse(BaseModel):
    interactions: list[dict]


def _send_sms(to_number: str, body: str) -> bool:
    """Send SMS via Twilio (if configured)."""
    if not all([TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM_NUMBER]):
        logger.info(f"SMS skipped (Twilio not configured). Would send to {to_number}: {body}")
        return True
    try:
        response = requests.post(
            f"https://api.twilio.com/2010-04-01/Accounts/{TWILIO_ACCOUNT_SID}/Messages.json",
            auth=(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN),
            data={"From": TWILIO_FROM_NUMBER, "To": to_number, "Body": body},
            timeout=10,
        )
        return response.status_code == 201
    except Exception as e:
        logger.error(f"SMS error: {e}")
        return False


def _send_push(patient_id: int, title: str, body: str) -> bool:
    """Send push notification via Firebase (if configured)."""
    if not FCM_SERVER_KEY:
        logger.info(f"Push skipped (FCM not configured). Title: {title}")
        return True
    try:
        response = requests.post(
            "https://fcm.googleapis.com/fcm/send",
            headers={
                "Authorization": f"key={FCM_SERVER_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "to": f"/topics/patient_{patient_id}",
                "notification": {"title": title, "body": body},
                "data": {"patient_id": str(patient_id)},
            },
            timeout=10,
        )
        return response.status_code == 200
    except Exception as e:
        logger.error(f"Push error: {e}")
        return False


@app.post("/check-interactions", response_model=InteractionCheckResponse)
def check_interactions(req: InteractionCheckRequest) -> InteractionCheckResponse:
    """
    Check for drug-drug interactions using expanded database (40+ geriatric interactions).
    
    Uses brand-name normalization: "Kardegic" → "aspirin", etc.
    
    CRITICAL: Returns [] (empty list) on success with no interactions.
    Returns [] (not None) so calling service can distinguish from network failure.
    
    Returns:
        InteractionCheckResponse with interactions list (may be empty)
    """
    try:
        logger.info(f"Checking interactions for: {req.medications}")
        
        # Normalize all medication names (brand → generic INN)
        normalized = [normalize_med_name(m) for m in req.medications]
        logger.info(f"Normalized to: {normalized}")
        
        # Find interactions using expanded database
        interactions = find_interactions(normalized)
        
        logger.info(f"Found {len(interactions)} interaction(s)")
        return InteractionCheckResponse(interactions=interactions)
        
    except Exception as e:
        logger.error(f"Interaction check error: {e}")
        raise HTTPException(status_code=500, detail=f"Interaction check failed: {str(e)}")


@app.post("/dispatch")
def dispatch_alert(req: DispatchRequest):
    """Dispatch alerts (SMS/push) for medication events."""
    with Session(engine) as session:
        try:
            patient = session.get(Patient, req.patient_id)
            if not patient:
                raise HTTPException(status_code=404, detail="Patient not found.")
            
            if not patient.full_name or not patient.emergency_contact_phone:
                logger.warning(f"Patient {req.patient_id} missing contact info")

            # Create alert record in database with ALL required fields
            alert = Alert(
                patient_id=req.patient_id,
                alert_type=req.alert_type,
                severity=req.severity,
                title=req.title or f"{req.alert_type.replace('_', ' ').title()} Alert",
                message=req.message,
                is_read=False,
                is_acknowledged=False
            )
            session.add(alert)
            session.commit()
            logger.info(f"Alert created: {alert.id} for patient {req.patient_id}")

            severity_emojis = {"low": "ℹ️", "medium": "⚠️", "high": "🚨"}
            emoji = severity_emojis.get(req.severity, "⚠️")
            
            sms_ok = False
            push_ok = False
            
            # Send SMS to emergency contact if available
            if patient.emergency_contact_phone:
                sms_body = f"{emoji} MedMind - {patient.full_name}: {req.message}"
                sms_ok = _send_sms(patient.emergency_contact_phone, sms_body)
            
            # Send push notification
            push_ok = _send_push(req.patient_id, f"{emoji} {alert.title}", req.message)

            return {
                "dispatched": True,
                "alert_id": alert.id,
                "sms_sent": sms_ok,
                "push_sent": push_ok,
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Dispatch error: {e}")
            raise HTTPException(status_code=500, detail=f"Failed to dispatch alert: {e}")


@app.post("/remind/{patient_id}")
def send_dose_reminder(patient_id: int):
    """Called by a scheduler to remind a patient to take their next dose."""
    with Session(engine) as session:
        try:
            patient = session.get(Patient, patient_id)
            if not patient:
                raise HTTPException(status_code=404, detail="Patient not found.")
            
            if not patient.full_name:
                raise HTTPException(status_code=400, detail="Patient name missing.")

            meds = session.exec(
                select(Medication).where(
                    Medication.patient_id == patient_id,
                    Medication.is_active == True,
                )
            ).all()

            if not meds:
                return {"reminded": False, "reason": "No active medications."}

            med_names = ", ".join(m.name for m in meds)
            patient_first_name = patient.full_name.split()[0] if patient.full_name else "Haj"
            message = f"Wakt dwek ya {patient_first_name}! Dwayetk: {med_names}. Rabi yachfik."

            _send_push(patient_id, "⏰ Wakt el dwa!", message)
            if patient.emergency_contact_phone:
                _send_sms(patient.emergency_contact_phone, f"[MedMind] Rappel: {patient.full_name} doit prendre {med_names}.")

            return {"reminded": True, "medications": med_names}
        except Exception as e:
            logger.error(f"Reminder error: {e}")
            raise HTTPException(status_code=500, detail=f"Failed to send reminder: {e}")


@app.get("/patient/{patient_id}/alerts")
def get_patient_alerts(patient_id: int):
    """Get all alerts for a patient."""
    try:
        with Session(engine) as session:
            alerts = session.exec(
                select(Alert)
                .where(Alert.patient_id == patient_id)
                .order_by(Alert.created_at.desc())
            ).all()
            return {"alerts": alerts, "count": len(alerts)}
    except Exception as e:
        logger.error(f"Alert fetch error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch alerts: {str(e)}")


@app.put("/alert/{alert_id}/read")
def mark_alert_read(alert_id: int):
    """Mark alert as read."""
    try:
        with Session(engine) as session:
            alert = session.get(Alert, alert_id)
            if not alert:
                raise HTTPException(status_code=404, detail="Alert not found")
            alert.is_read = True
            session.add(alert)
            session.commit()
            return {"status": "updated", "alert_id": alert_id}
    except Exception as e:
        logger.error(f"Alert update error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update alert: {str(e)}")


@app.put("/alert/{alert_id}/acknowledge")
def acknowledge_alert(alert_id: int):
    """Acknowledge alert (patient has seen it)."""
    try:
        with Session(engine) as session:
            alert = session.get(Alert, alert_id)
            if not alert:
                raise HTTPException(status_code=404, detail="Alert not found")
            alert.is_acknowledged = True
            alert.acknowledged_at = datetime.now(timezone.utc)
            session.add(alert)
            session.commit()
            return {"status": "acknowledged", "alert_id": alert_id}
    except Exception as e:
        logger.error(f"Alert acknowledge error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to acknowledge alert: {str(e)}")


@app.get("/health")
def health():
    """Health check endpoint."""
    return {"status": "ok", "service": "notification-service"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001, log_level="info")