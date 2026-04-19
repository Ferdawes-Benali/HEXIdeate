import os
import httpx
import logging
from fastapi import APIRouter, HTTPException

logger = logging.getLogger(__name__)

ANALYTICS_SERVICE_URL = os.getenv("ANALYTICS_SERVICE_URL", "http://analytics-service:8004")

router = APIRouter()


@router.get("/stats/{patient_id}")
async def get_stats(patient_id: int, days: int = 30):
    """Get adherence statistics for a patient over a time period."""
    if patient_id <= 0:
        raise HTTPException(status_code=400, detail="Invalid patient_id.")
    if days <= 0:
        raise HTTPException(status_code=400, detail="days must be > 0.")

    async with httpx.AsyncClient(timeout=10) as client:
        try:
            resp = await client.get(
                f"{ANALYTICS_SERVICE_URL}/stats/{patient_id}",
                params={"days": days},
            )
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Analytics service returned {e.response.status_code}")
            raise HTTPException(status_code=e.response.status_code, detail=str(e))
        except httpx.ConnectError:
            logger.error(f"Cannot connect to analytics service at {ANALYTICS_SERVICE_URL}")
            raise HTTPException(status_code=503, detail="Analytics service unavailable")
        except Exception as e:
            logger.error(f"Analytics service error: {e}")
            raise HTTPException(status_code=503, detail=f"Analytics service unavailable: {e}")


@router.get("/skip-risk/{patient_id}")
async def get_skip_risk(patient_id: int, days_lookback: int = 30):
    """Get skip-risk prediction for a patient."""
    if patient_id <= 0:
        raise HTTPException(status_code=400, detail="Invalid patient_id.")
    if days_lookback <= 0:
        raise HTTPException(status_code=400, detail="days_lookback must be > 0.")

    async with httpx.AsyncClient(timeout=10) as client:
        try:
            resp = await client.post(
                f"{ANALYTICS_SERVICE_URL}/predict-skip-risk",
                json={"patient_id": patient_id, "days_lookback": days_lookback},
            )
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Analytics service returned {e.response.status_code}")
            raise HTTPException(status_code=e.response.status_code, detail=str(e))
        except httpx.ConnectError:
            logger.error(f"Cannot connect to analytics service at {ANALYTICS_SERVICE_URL}")
            raise HTTPException(status_code=503, detail="Analytics service unavailable")
        except Exception as e:
            logger.error(f"Analytics service error: {e}")
            raise HTTPException(status_code=503, detail=f"Analytics service unavailable: {e}")