from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate
from sqlmodel import Session, select
from ..config import settings
from ..database import engine
from ..models import IntakeHistory, Medication
import logging

logger = logging.getLogger(__name__)

# Reuse LLM instance globally (not fresh on every call)
_llm_instance = None

def get_llm():
    """Get or create singleton LLM instance."""
    global _llm_instance
    if _llm_instance is None:
        _llm_instance = ChatGoogleGenerativeAI(
            model="gemini-2.5-flash",
            google_api_key=settings.GOOGLE_API_KEY,
            temperature=0,
        )
    return _llm_instance


def predict_skip_risk(patient_id: int) -> dict:
    """
    Predicts medication skip risk using deterministic heuristics as PRIMARY signal.
    Reserves LLM only for generating human-readable reason string.
    
    NEVER lets LLM output directly determine the risk tier (prevents hallucination downgrade).
    
    Returns: {"risk": "low"|"medium"|"high", "reason": str}
    """
    with Session(engine) as session:
        statement = (
            select(IntakeHistory, Medication.name)
            .join(Medication)
            .where(Medication.patient_id == patient_id)
            .order_by(IntakeHistory.timestamp.desc())
            .limit(20)
        )
        rows = session.exec(statement).all()

    if not rows:
        return {"risk": "low", "reason": "No intake history found."}

    # Extract recent intake records
    intakes = [intake for intake, _ in rows]
    
    # DETERMINISTIC HEURISTICS (primary signal)
    # === Calculate skip rate ===
    total_scheduled = len(intakes)
    skipped_count = sum(1 for intake in intakes if intake.status in ["skipped", "missed", "wrong_pill"])
    skip_rate = skipped_count / total_scheduled if total_scheduled > 0 else 0
    
    # === Calculate recency ===
    # If most recent dose was skipped, higher risk
    recent_skipped = False
    if intakes:
        recent_skipped = intakes[0].status in ["skipped", "missed"]
    
    # === Deterministic risk assignment ===
    # These thresholds are from healthcare literature on adherence
    if skip_rate >= 0.4 or (recent_skipped and skip_rate >= 0.25):
        risk_tier = "high"
    elif skip_rate >= 0.2 or recent_skipped:
        risk_tier = "medium"
    else:
        risk_tier = "low"
    
    # OPTIONAL: Use LLM ONLY to generate human-readable reason
    # (Do NOT use LLM output to override risk_tier)
    reason = _generate_reason_string(patient_id, risk_tier, skip_rate, intakes)
    
    return {"risk": risk_tier, "reason": reason}


def _generate_reason_string(patient_id: int, risk_tier: str, skip_rate: float, intakes: list) -> str:
    """
    Generate human-readable reason string using LLM.
    LLM output is ONLY for description, never for determining risk tier.
    """
    try:
        history_summary = "\n".join(
            f"- {intake.status.upper()} at {intake.timestamp.strftime('%Y-%m-%d %H:%M')}"
            for intake in intakes[:5]  # Last 5 only
        )
        
        llm = get_llm()
        prompt = PromptTemplate.from_template(
            """Given the medication intake history below, write ONE SHORT SENTENCE (max 15 words)
explaining why the patient is at {risk_tier} risk for skipping their next dose.

History (most recent first):
{history}

Skip rate: {skip_rate:.0%}

Example low-risk reason: "Patient took all 5 recent doses on time."
Example medium-risk reason: "Patient skipped 1 of the last 5 doses."
Example high-risk reason: "Patient skipped 3 of the last 5 doses; recent pattern worsening."

Respond with ONLY the one sentence, no quotes, no formatting."""
        )
        
        response = llm.invoke(prompt.format(
            risk_tier=risk_tier,
            history=history_summary,
            skip_rate=skip_rate
        ))
        
        reason = response.content.strip()
        # Fallback if response is too long or empty
        if not reason or len(reason) > 100:
            raise ValueError("Invalid LLM response")
        return reason
        
    except Exception as e:
        logger.warning(f"Failed to generate LLM reason: {e}")
        # Fallback deterministic description
        skipped_count = sum(1 for intake in intakes if intake.status in ["skipped", "missed", "wrong_pill"])
        return f"Skipped {skipped_count} of {len(intakes)} recent doses."