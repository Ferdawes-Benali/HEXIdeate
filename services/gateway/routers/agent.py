import os
import httpx
import logging
from fastapi import APIRouter, Request, HTTPException
from pydantic import BaseModel
from typing import Optional

logger = logging.getLogger(__name__)

AGENT_SERVICE_URL = os.getenv("AGENT_SERVICE_URL", "http://agent-service:8000")

router = APIRouter()


class ChatRequest(BaseModel):
    message: str
    video_input: Optional[str] = None

class ChatResponse(BaseModel):
    reply: str
    status: Optional[str] = None
    safety_alert: Optional[bool] = None


@router.post("/chat", response_model=ChatResponse)
async def chat(body: ChatRequest, request: Request):
    user_id = getattr(request.state, "user_id", None)
    if not user_id:
        raise HTTPException(status_code=401, detail="Unauthenticated.")

    if not body.message or not body.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty.")

    async with httpx.AsyncClient(timeout=30) as client:
        try:
            resp = await client.post(
                f"{AGENT_SERVICE_URL}/invoke",
                json={
                    "user_id": int(user_id),
                    "message": body.message,
                    "video_input": body.video_input,
                },
            )
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Agent service returned {e.response.status_code}: {e}")
            raise HTTPException(status_code=e.response.status_code, detail=str(e))
        except httpx.ConnectError:
            logger.error(f"Cannot connect to agent service at {AGENT_SERVICE_URL}")
            raise HTTPException(status_code=503, detail="Agent service unavailable")
        except Exception as e:
            logger.error(f"Agent service error: {e}")
            raise HTTPException(status_code=503, detail=f"Agent service unavailable: {e}")