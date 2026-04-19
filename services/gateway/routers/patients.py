import os
import httpx
from fastapi import APIRouter, HTTPException, Request
from typing import Optional

import sys
sys.path.insert(0, '..')

from shared.schemas import PatientCreate

AGENT_SERVICE_URL = os.getenv("AGENT_SERVICE_URL", "http://agent-service:8000")

router = APIRouter()


@router.get("/{patient_id}")
async def get_patient(patient_id: int, request: Request):
    async with httpx.AsyncClient(timeout=10) as client:
        try:
            resp = await client.get(f"{AGENT_SERVICE_URL}/patients/{patient_id}")
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as e:
            raise HTTPException(status_code=e.response.status_code, detail=str(e))


@router.post("/")
async def create_patient(body: PatientCreate, request: Request):
    async with httpx.AsyncClient(timeout=10) as client:
        try:
            resp = await client.post(f"{AGENT_SERVICE_URL}/patients", json=body.dict())
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as e:
            raise HTTPException(status_code=e.response.status_code, detail=str(e))


@router.get("/{patient_id}/medications")
async def get_medications(patient_id: int):
    async with httpx.AsyncClient(timeout=10) as client:
        try:
            resp = await client.get(f"{AGENT_SERVICE_URL}/patients/{patient_id}/medications")
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as e:
            raise HTTPException(status_code=e.response.status_code, detail=str(e))