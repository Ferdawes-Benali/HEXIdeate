"""FastAPI server for the Agent Service.

Exposes endpoints for:
- POST /invoke: Run the agent with user input
- GET /health: Health check
"""

import logging
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List

from graph import invoke_agent
from state import AgentState
from config import settings

logger = logging.getLogger(__name__)

app = FastAPI(
    title="MedMind Agent Service",
    description="AI medical assistant agent for elderly Tunisian patients",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class AgentRequest(BaseModel):
    """Request to invoke the agent."""
    user_id: int
    message: str
    video_input: Optional[str] = None  # Base64 video or None


class AgentResponse(BaseModel):
    """Response from the agent."""
    messages: List[dict]
    status: Optional[str] = None
    expected_pill: Optional[str] = None
    identified_pills: List[str] = []
    safety_alert: Optional[bool] = None


@app.get("/health")
def health():
    """Health check endpoint."""
    return {"status": "ok", "service": "agent-service"}


@app.post("/invoke", response_model=AgentResponse)
async def invoke(request: AgentRequest) -> AgentResponse:
    """Invoke the agent with user input.
    
    Args:
        request: AgentRequest with user_id, message, optional video_input
        
    Returns:
        AgentResponse with agent's messages, status, detected pills, etc.
    """
    try:
        # Import here to avoid circular imports
        from langchain_core.messages import HumanMessage
        
        # Build initial state
        state: AgentState = {
            "user_id": request.user_id,
            "messages": [HumanMessage(content=request.message)],
            "video_input": request.video_input,
            "current_action": None,
            "expected_pill": None,
            "identified_pills": [],
            "status": None,
            "safety_alert": False
        }
        
        # Invoke the agent graph
        result_state = invoke_agent(state)
        
        # Extract messages as dicts
        messages = []
        for msg in result_state.get("messages", []):
            messages.append({
                "role": msg.__class__.__name__.lower(),  # "humanmessage", "aimessage", etc.
                "content": msg.content
            })
        
        return AgentResponse(
            messages=messages,
            status=result_state.get("status"),
            expected_pill=result_state.get("expected_pill"),
            identified_pills=result_state.get("identified_pills", []),
            safety_alert=result_state.get("safety_alert")
        )
        
    except Exception as e:
        logger.error(f"Agent invocation failed: {e}")
        raise HTTPException(status_code=500, detail=f"Agent error: {str(e)}")


@app.post("/health-check")
def detailed_health():
    """Detailed health check with service dependencies."""
    try:
        from .database import engine
        from sqlalchemy import text
        
        # Check database
        db_status = "unknown"
        try:
            with engine.begin() as connection:
                connection.execute(text("SELECT 1"))
            db_status = "ok"
        except Exception as db_error:
            logger.warning(f"Database health check failed: {db_error}")
            db_status = "failed"
        
        return {
            "status": "ok",
            "service": "agent-service",
            "database": db_status,
            "google_api_key": "configured" if settings.GOOGLE_API_KEY else "missing"
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(status_code=500, detail=f"Health check error: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        log_level="info"
    )
