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
import httpx
from graph import invoke_agent
from state import AgentState
from config import settings
from database import init_db
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
@app.on_event("startup")
def on_startup():
    """Run on startup to ensure database tables exist."""
    try:
        logger.info("Initializing database tables...")
        init_db()
        logger.info("Database initialization complete.")
    except Exception as e:
        logger.error(f"Failed to initialize database: {e}")

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
        from langchain_core.messages import HumanMessage
        
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
        
        result_state = invoke_agent(state)
        
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
class DrugCheckRequest(BaseModel):
    medications: List[str]

async def get_rxcui(drug_name: str) -> str:
    """Gets the base Ingredient RxCUI for reliable interaction checks."""
    search_url = f"https://rxnav.nlm.nih.gov/REST/rxcui.json?name={drug_name.strip()}&search=1"
    async with httpx.AsyncClient() as client:
        resp = await client.get(search_url)
        data = resp.json()
        initial_id = data.get("idGroup", {}).get("rxnormId", [None])[0]
        
        if not initial_id:
            return None

    
        prop_url = f"https://rxnav.nlm.nih.gov/REST/rxcui/{initial_id}/related.json?tty=IN+PIN"
        prop_resp = await client.get(prop_url)
        prop_data = prop_resp.json()
        
        try:
            concept_groups = prop_data.get("relatedGroup", {}).get("conceptGroup", [])
            for group in concept_groups:
                concepts = group.get("conceptProperties", [])
                if concepts:
                    return concepts[0].get("rxcui")
        except:
            return initial_id 
            
    return initial_id

@app.post("/check-interactions")
async def drug_interactions(request: DrugCheckRequest):
    meds = request.medications
    if len(meds) < 2:
        return {"interactions": [], "notes": "Need at least two medications."}

    interactions = []
    async with httpx.AsyncClient() as client:
        for i in range(len(meds)):
            for j in range(i + 1, len(meds)):
                drug_a = meds[i]
                drug_b = meds[j]
                
                url = f"https://api.fda.gov/drug/label.json?search=openfda.generic_name:\"{drug_a}\"+AND+drug_interactions:\"{drug_b}\"&limit=1"
                
                try:
                    response = await client.get(url)
                    if response.status_code == 200:
                        data = response.json()
                        label_text = data['results'][0].get('drug_interactions', ["No specific text found"])[0]
                        
                        interactions.append({
                            "pair": f"{drug_a} + {drug_b}",
                            "severity": "See Description", 
                            "description": label_text[:500] + "...",
                            "source": "openFDA"
                        })
                except Exception as e:
                    continue 

    return {"interactions": interactions}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        log_level="info"
    )
