import os
import httpx
import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Literal

logger = logging.getLogger(__name__)

NOTIFICATION_SERVICE_URL = os.getenv("NOTIFICATION_SERVICE_URL", "http://notification-service:8003")

router = APIRouter()


class DispatchRequest(BaseModel):
    patient_id: int
    alert_type: Literal["missed_dose", "wrong_pill", "drug_interaction"]
    message: str
    severity: Literal["low", "medium", "high"] = "medium"


@router.post("/dispatch")
async def dispatch(body: DispatchRequest):
    """Dispatch an alert to a patient via SMS/push."""
    if body.patient_id <= 0:
        raise HTTPException(status_code=400, detail="Invalid patient_id.")
    if not body.message or not body.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty.")

    async with httpx.AsyncClient(timeout=10) as client:
        try:
            resp = await client.post(
                f"{NOTIFICATION_SERVICE_URL}/dispatch",
                json=body.dict(),
            )
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Notification service returned {e.response.status_code}")
            raise HTTPException(status_code=e.response.status_code, detail=str(e))
        except httpx.ConnectError:
            logger.error(f"Cannot connect to notification service at {NOTIFICATION_SERVICE_URL}")
            raise HTTPException(status_code=503, detail="Notification service unavailable")
        except Exception as e:
            logger.error(f"Notification service error: {e}")
            raise HTTPException(status_code=503, detail=f"Notification service unavailable: {e}")


@router.post("/remind/{patient_id}")
async def remind(patient_id: int):
    """Send a dose reminder to a patient."""
    if patient_id <= 0:
        raise HTTPException(status_code=400, detail="Invalid patient_id.")

    async with httpx.AsyncClient(timeout=10) as client:
        try:
            resp = await client.post(f"{NOTIFICATION_SERVICE_URL}/remind/{patient_id}")
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Notification service returned {e.response.status_code}")
            raise HTTPException(status_code=e.response.status_code, detail=str(e))
        except httpx.ConnectError:
            logger.error(f"Cannot connect to notification service at {NOTIFICATION_SERVICE_URL}")
            raise HTTPException(status_code=503, detail="Notification service unavailable")
        except Exception as e:
            logger.error(f"Notification service error: {e}")
            raise HTTPException(status_code=503, detail=f"Notification service unavailable: {e}")