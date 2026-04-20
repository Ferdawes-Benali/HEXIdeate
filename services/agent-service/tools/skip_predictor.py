from sqlalchemy import and_
from sqlmodel import Session, select
from database import engine
from models import IntakeHistory, Medication
import logging

# ... imports ...

# Initialize at module level for thread-safety and simplicity
llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash", # Consistent with previous files
    google_api_key=settings.GOOGLE_API_KEY,
    temperature=0,
)

def predict_skip_risk(patient_id: int) -> dict:
    with Session(engine) as session:
        # Explicit join condition is safer
        statement = (
            select(IntakeHistory)
            .join(Medication, IntakeHistory.medication_id == Medication.id)
            .where(Medication.patient_id == patient_id)
            .order_by(IntakeHistory.timestamp.desc())
            .limit(20)
        )
        intakes = session.exec(statement).all()

    if not intakes:
        return {"risk": "low", "reason": "No intake history found."}

    # Deterministic Logic
    total_records = len(intakes)
    # Filter for negative statuses
    skipped_count = sum(1 for i in intakes if i.status in ["skipped", "missed", "wrong_pill"])
    skip_rate = skipped_count / total_records
    
    recent_skipped = intakes[0].status in ["skipped", "missed"]

    # Tier assignment (Deterministic)
    if total_records < 3: # Not enough data for high risk
        risk_tier = "low"
    elif skip_rate >= 0.4 or (recent_skipped and skip_rate >= 0.25):
        risk_tier = "high"
    elif skip_rate >= 0.2 or recent_skipped:
        risk_tier = "medium"
    else:
        risk_tier = "low"

    # Generate the human-friendly string
    reason = _generate_reason_string(risk_tier, skip_rate, intakes)
    
    return {"risk": risk_tier, "reason": reason}

def _generate_reason_string(risk_tier: str, skip_rate: float, intakes: list[IntakeHistory]) -> str:
    try:
        # Limit summary to top 5 for the prompt
        history_summary = "\n".join(
            f"- {i.status.upper()} ({i.timestamp.strftime('%H:%M')})"
            for i in intakes[:5]
        )
        
        prompt = f"""Explain why patient is {risk_tier} risk. 
        History: {history_summary}
        Overall Skip Rate: {skip_rate:.0%}
        Respond in 1 short sentence."""
        
        # Using simple invoke (PromptTemplate is also fine)
        response = llm.invoke(prompt)
        return response.content.strip()
        
    except Exception as e:
        logger.warning(f"LLM Reason Error: {e}")
        return f"Patient has skipped {skip_rate:.0%} of recent doses."