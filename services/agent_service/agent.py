import os
from langchain_google_genai import ChatGoogleGenerativeAI
from pydantic import BaseModel, Field
from .config import settings
from typing import Literal
from .state import AgentState
from langchain_core.messages import AIMessage,SystemMessage, HumanMessage
import requests
from sqlmodel import Session, select,and_, func
from .database import engine 
from .models import Medication, Patient, Alert,MedicationSchedule,IntakeHistory
from .tools.drug_interaction import check_interactions
from datetime import datetime, timedelta, timezone, time
from .tools.fuzzy_matcher import fuzzy_pill_match
from .memory.redis_memory import get_history, append_message, clear_history
from .memory.chroma_rag import build_rag_context
import logging

logger = logging.getLogger(__name__)
llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    google_api_key=settings.GOOGLE_API_KEY,
    temperature=0
)

class IntentSchema(BaseModel):
    action: Literal["vision_tool", "safety_check", "chat"] = Field(
        description="The next step to take based on user input."
    )

def analyzer(state: AgentState):
    
    system_prompt = (
    "You are an expert Tunisian medical coordinator specializing in the Tunisian dialect (Derja). "
    "Your goal is to accurately classify the intent of elderly patients into one of three technical routes. "
    "\n\n### ROUTES:\n"
    "1. 'vision_tool': User wants to identify a pill, take a photo, or describe what a medicine looks like. "
    "Keywords/Context: 'choufli', 'tsawer', 'warini', 'hal dwe', 'el dwe hedha'.\n"
    "2. 'safety_check': User is worried about mixing medicines, side effects, or if a pill 'suits' their condition. "
    "Keywords/Context: 'yoati m3a', 'mouchkel', 'm3a dwe l-tension', 'yekhi meryeguel?', 'safe'.\n"
    "3. 'chat': General talk, greetings, or basic health advice not requiring tools. "
    "Keywords/Context: 'Asslema', 'Chnouwa el ahwel', 'Chkounek enti?'.\n\n"
    
    "### EXAMPLES:\n"
    "- 'Choufli hal dwe mte3 chnwa?' -> vision_tool\n"
    "- 'Najem nekhou l-aspro m3a dwe l-kalb?' -> safety_check\n"
    "- 'Ya m3alem, dwayeti meryegla?' -> safety_check\n"
    "- 'Asslema ya weldi' -> chat\n\n"
    
    "### CRITICAL RULE:\n"
    "If the user mentions two different medicines or a chronic disease (tension, diabetes/skorr) in a question, "
    "always prioritize 'safety_check'. If they ask you to 'look' or 'see', prioritize 'vision_tool'.\n\n"
    "User Input: ")
    try:
        user_input = state["messages"][-1].content
        if not user_input.strip():
            return {"current_action": "chat"}
        structured_llm = llm.with_structured_output(IntentSchema)
        prediction = structured_llm.invoke(system_prompt + user_input)
        return {"current_action": prediction.action}
    except Exception as e:
        print(f"Routing Error: {e}")
        return {"current_action": "chat"}

def context_loader(state: AgentState):
    """Load patient context: scheduled medications within ±60 minutes. Fixes midnight wraparound."""
    patient_id = state.get("user_id")
    if not patient_id:
        logger.warning("context_loader: user_id not provided in state")
        return {
            "expected_pill": "Unknown",
            "identified_pills": []
        }
    
    now = datetime.now(timezone.utc)
    # Use full datetime for ±60 minute window (fixes midnight wraparound bug)
    start_window = now - timedelta(minutes=60)
    end_window = now + timedelta(minutes=60)
    current_time_str = now.strftime("%H:%M")
    
    with Session(engine) as session:
        try:
            # Get day-of-week: check if today's day is active in schedule
            day_index = now.weekday()  # 0=Monday, 6=Sunday
            day_fields = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
            current_day_field = day_fields[day_index]
            
            # Convert window times to HH:MM strings for comparison
            start_time_str = start_window.strftime("%H:%M")
            end_time_str = end_window.strftime("%H:%M")
            
            # Handle case where window crosses midnight
            if start_time_str > end_time_str:  # Crossed midnight
                # Two queries: before midnight + after midnight
                statement_pre = (
                    select(Medication)
                    .join(MedicationSchedule)
                    .where(Medication.patient_id == patient_id)
                    .where(Medication.is_active == True)
                    .where(getattr(MedicationSchedule, current_day_field) == True)
                    .where(MedicationSchedule.time_of_day >= start_time_str)
                    .order_by(MedicationSchedule.time_of_day)
                )
                statement_post = (
                    select(Medication)
                    .join(MedicationSchedule)
                    .where(Medication.patient_id == patient_id)
                    .where(Medication.is_active == True)
                    .where(getattr(MedicationSchedule, current_day_field) == True)
                    .where(MedicationSchedule.time_of_day <= end_time_str)
                    .order_by(MedicationSchedule.time_of_day)
                )
                results = session.exec(statement_pre).all() + session.exec(statement_post).all()
            else:
                # Normal case: no midnight crossing
                statement = (
                    select(Medication)
                    .join(MedicationSchedule)
                    .where(Medication.patient_id == patient_id)
                    .where(Medication.is_active == True)
                    .where(getattr(MedicationSchedule, current_day_field) == True)
                    .where(
                        and_(
                            MedicationSchedule.time_of_day >= start_time_str,
                            MedicationSchedule.time_of_day <= end_time_str
                        )
                    )
                    .order_by(MedicationSchedule.time_of_day)
                )
                results = session.exec(statement).all()
            
            # If no medications in current window, get next scheduled today
            if not results:
                fallback_statement = (
                    select(Medication)
                    .join(MedicationSchedule)
                    .where(Medication.patient_id == patient_id)
                    .where(Medication.is_active == True)
                    .where(getattr(MedicationSchedule, current_day_field) == True)
                    .where(MedicationSchedule.time_of_day > current_time_str)
                    .order_by(MedicationSchedule.time_of_day)
                )
                results = session.exec(fallback_statement).all()
            
            # Return first medication as expected_pill
            expected = results[0].name if results else "Unknown"
            return {
                "expected_pill": expected,
                "identified_pills": []
            }
        except Exception as e:
            logger.error(f"context_loader error: {e}")
            return {
                "expected_pill": "Unknown",
                "identified_pills": []
            }

def vision_node(state: AgentState):
    video_data = state.get("video_input")
    expected_pill = state.get("expected_pill")
    patient_id = state.get("user_id")
    
    if not video_data:
        logger.error("vision_node: no video_input provided")
        return {
            "messages": [AIMessage(content="Ma lkit video bech nanalyzou. A3melli tswira oukhra.")],
            "status": "error"
        }
    
    if not patient_id:
        logger.error("vision_node: no user_id provided")
        return {
            "messages": [AIMessage(content="Error: ma najemtech na3ref el patient.")],
            "status": "error"
        }
    
    try:
        response = requests.post(
            f"{settings.VISION_SERVICE_URL}/verify-intake",
            json={"video": video_data},
            timeout=10
        )
        result = response.json()
        
        is_verified = result.get("confirmed", False)
        pill_detected = result.get("label", "unknown")

        if not is_verified:
            return {
                "messages": [AIMessage(content="Ma najemtech na3ref el dwa exact. A3melli tswira oukhra awdheh aman.")],
                "status": "retry"
            }
        with Session(engine) as session:
            db_meds = session.exec(
                select(Medication).where(Medication.patient_id == patient_id, Medication.is_active == True)
            ).all()
            inventory_names = [m.name for m in db_meds] + [m.generic_name for m in db_meds if m.generic_name]
        match_result = fuzzy_pill_match(pill_detected, inventory_names)
        if match_result == "MATCH":
            if expected_pill != "Unknown" and fuzzy_pill_match(pill_detected, [expected_pill]) == "MATCH":
                return {
                    "messages": [AIMessage(content=f"Ya3tik es-saha! Thabta {pill_detected}. Rabi yachfik.")],
                    "identified_pills": [pill_detected],
                    "status": "success"
                }
            else:
                # Out-of-schedule dose: use distinct "wrong_time" status
                return {
                    "messages": [AIMessage(content=f"Choft {pill_detected}. Hedha dwek ama mouch waktou tawa. Thabet fel wa9t ya Haj.")],
                    "identified_pills": [pill_detected],
                    "status": "wrong_time"  # Distinct status for out-of-schedule dose
                }

        elif match_result == "CONFIRM":
            return {
                "messages": [AIMessage(content=f"Choft {pill_detected}. Hedha fih nafs el 'matière active' mte3 dwek. Najem tekhdhou labes.")],
                "identified_pills": [pill_detected],
                "status": "success"
            }

        else:
            return {
                "messages": [AIMessage(content=f"Attention ya Haj! Choft {pill_detected} ama hedha mouch dwek jemla! Thabet m3aya aman la tghalet.")],
                "status": "wrong_pill"
            }

    except Exception as e:
            logger.error(f"vision_node error: {e}")
            return {"messages": [AIMessage(content="Service t3eb chwaya, lahza taw nraja3lek l'khbar.")], "status": "error"}

def safety_node(state: AgentState):
    """
    Safety check node: validates new pills against current medications.
    
    CRITICAL: Distinguishes between:
    - interactions=[] → check succeeded, no interactions found → SAFE
    - interactions=None → check FAILED (network/service down) → INDETERMINATE (ask doctor)
    """
    patient_id = state.get("user_id")
    new_pills = state.get("identified_pills", [])

    if not patient_id:
        logger.error("safety_node: no user_id provided")
        return {"messages": [AIMessage(content="Error: ma najemtech na3ref el patient.")]}

    if not new_pills:
        return {"messages": [AIMessage(content="Ma lkit hata dwe bech nthabet fih.")]}
    
    with Session(engine) as session:
        try:
            statement = select(Medication).where(
                Medication.patient_id == patient_id,
                Medication.is_active == True
            )
            db_meds = session.exec(statement).all()            
            current_med_names = [m.generic_name or m.name for m in db_meds]
            all_meds_to_check = list(set(new_pills + current_med_names))
            
            # CRITICAL: check_interactions() returns:
            # [] = safe (checked and found nothing)
            # None = check FAILED (network error, timeout, etc.)
            interactions = check_interactions(all_meds_to_check)
            
            # If None: check FAILED - cannot guarantee safety
            if interactions is None:
                msg = (
                    "Smakhni ya Haj, ma najemtech nthabet mel safety tawwa "
                    "(service t3eb). Khalih blastha, "
                    "w kalem tbibek qabel ma tekhoudh el dwe. Sihetk akher."
                )
                return {
                    "messages": [AIMessage(content=msg)],
                    "safety_alert": True  # Flag as alert even if not confirmed
                }
            
            # If [] (empty list): check succeeded, no interactions found
            if not interactions:
                response = (
                    f"Thabbet fi dwayetka: {', '.join(new_pills)}. "
                    "Labes, ma famma hata mouchkel m3a dwayetk lokhrin. Najem nekhdhouhom meryeguel."
                )
                return {"messages": [AIMessage(content=response)]}
            
            # If interactions found: create alert with ALL required fields
            warning_msg = "⚠️ **Red balek!** Famma mouchkel bin dwayetka:\n"
            for issue in interactions:
                if isinstance(issue, dict) and "description" in issue:
                    warning_msg += f"- {issue['description']}\n"
            warning_msg += "\nAnsehik matakhouch el dwe taw w kalem tbibek fisa3."
            
            # Create alert with all required fields from shared.models.Alert
            new_alert = Alert(
                patient_id=patient_id,
                alert_type="drug_interaction",
                severity="high",
                title="Drug interaction detected",
                message=warning_msg,
                is_read=False,
                is_acknowledged=False
                # NOTE: is_resolved field does NOT exist in shared.models.Alert
                # Use is_read / is_acknowledged instead
            )
            session.add(new_alert)
            session.commit()
            return {
                "messages": [AIMessage(content=warning_msg)],
                "safety_alert": True 
            }
        except Exception as e:
            session.rollback()
            logger.error(f"Safety Check Error: {e}")
            return {"messages": [AIMessage(content="Smakhni, ma najemtech nthabet mel safety tawwa. Kallam el tbib khir.")]}
def chat_node(state: AgentState):
    """Chat node with memory and RAG integration."""
    patient_id = state.get("user_id")
    patient_name = "el Haj(a)"
    
    with Session(engine) as session:
        patient = session.get(Patient, patient_id)
        if patient:
            patient_name = patient.full_name
    
    # Load conversation history from Redis (last 20 turns)
    history = get_history(patient_id) if patient_id else []
    
    # Build RAG context from user's latest message
    user_input = state["messages"][-1].content if state["messages"] else ""
    rag_context = build_rag_context(user_input, k=4) if user_input else ""
    
    system_prompt = (
    "### ROLE\n"
    "You are 'MedMind', a specialized medical companion for elderly patients in Tunisia. "
    "Your persona is that of a respectful, patient, and knowledgeable 'Tbib el 3ila' (Family Doctor). "
    "You communicate exclusively in warm, authentic Tunisian Derja.\n\n"

    "### PATIENT CONTEXT\n"
    f"- Talking to: {patient_name}\n"
    "- Tone: Use 'Ya Haj' or 'Ya Haja' before their name to show respect (Kadhr). "
    "Be empathetic but avoid overly technical medical jargon unless explaining it simply.\n\n"

    "### COMMUNICATION GUIDELINES\n"
    "1. **Language**: Use natural Derja (e.g., use 'labes', 'chwaya', 'meryeguel', 'rabi yachfik'). "
    "Avoid literal translations from Modern Standard Arabic.\n"
    "2. **Conciseness**: Keep responses short and audible. Elderly users prefer brief, clear sentences "
    "over long paragraphs.\n"
    "3. **Safety First**: If the user describes severe symptoms (chest pain, shortness of breath, "
    "sudden numbness), tell them firmly but kindly to call '190' (SAMU) or their doctor immediately.\n\n"

    "### TASKS\n"
    "- If they greet you: Answer with 'Asslema ya {patient_name}, rabi ya3tik essahha. Kifech najem n3awnek?'\n"
    "- If they ask about meds: Remind them that you are an assistant, not a replacement for their doctor.\n"
    "- If they seem confused: Reassure them and offer to explain things again slowly.\n\n"
    
    "### CONSTRAINT\n"
    "Do not prescribe new medication. Do not argue. Always end medical advice with: "
    "'Dima thabet ma3 tbibek houwa adra b-haltek.' (Always check with your doctor, he knows your case best.)\n\n"
    )
    
    # Add RAG context if available
    if rag_context:
        system_prompt += f"### KNOWLEDGE BASE\n{rag_context}\n\n"
    
    # Convert history dicts to LangChain messages
    past_messages = []
    for msg in history:
        if msg.get("role") == "user":
            past_messages.append(HumanMessage(content=msg.get("content", "")))
        else:
            past_messages.append(AIMessage(content=msg.get("content", "")))
    
    # Build messages: system + history + current
    messages = [SystemMessage(content=system_prompt)] + past_messages + state["messages"]
    
    try:
        response = llm.invoke(messages)
        
        # Store exchange in Redis memory
        if patient_id:
            append_message(patient_id, "user", user_input)
            append_message(patient_id, "assistant", response.content)
        
        return {
            "messages": [response]
        }
    except Exception as e:
        print(f"Chat Error: {e}")
        fallback_msg = f"Asslema ya {patient_name}, ena MedMind. Kifech najem n3awnek l-youm?"
        return {"messages": [AIMessage(content=fallback_msg)]}


def logging_node(state: AgentState):
    """Log intake event to database. Records: success, wrong_time, wrong_pill status."""
    status = state.get("status")
    if status not in ["success", "wrong_time", "wrong_pill"]:
        return state
    
    patient_id = state.get("user_id")
    identified_pills = state.get("identified_pills", [])
    
    if not patient_id:
        logger.warning(f"logging_node: missing patient_id")
        return state
    
    # Use the DETECTED pill (first identified), not the expected one
    pill_name = identified_pills[0] if identified_pills else state.get("expected_pill")
    
    if not pill_name or pill_name == "Unknown":
        logger.warning(f"logging_node: no pill detected/expected for patient {patient_id}")
        return state
    
    with Session(engine) as session:
        try:
            # Find medication by name and patient_id
            med = session.exec(
                select(Medication).where(
                    Medication.name == pill_name,
                    Medication.patient_id == patient_id
                )
            ).first()
            
            if not med:
                logger.warning(f"logging_node: medication '{pill_name}' not found for patient {patient_id}")
                return state
            
            # Map video_input to S3 URL (TODO: real S3 upload in production)
            video_s3_url = None
            if state.get("video_input"):
                # In real implementation: upload to S3, get URL
                logger.info(f"logging_node: video {len(state.get('video_input', ''))} bytes would be uploaded to S3")
                video_s3_url = None  # Placeholder
            
            # Use expected_pill's scheduled time (from context_loader), or current time as fallback
            scheduled_time = datetime.now(timezone.utc)
            actual_time = datetime.now(timezone.utc)
            
            new_entry = IntakeHistory(
                medication_id=med.id,
                patient_id=patient_id,
                scheduled_time=scheduled_time,
                actual_time=actual_time,
                status=status,
                notes=f"Pill: {pill_name}, Status: {status}",
                video_path=video_s3_url
            )
            session.add(new_entry)
            session.commit()
            logger.info(f"logging_node: recorded {pill_name} with status={status} for patient {patient_id}")
        except Exception as e:
            session.rollback()
            logger.error(f"logging_node error: {e}")
    return state