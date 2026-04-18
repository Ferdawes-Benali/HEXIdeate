import os
from langchain_google_genai import ChatGoogleGenerativeAI
from pydantic import BaseModel, Field
from .config import settings
from typing import Literal
from .state import AgentState
from langchain_core.messages import AIMessage
from .tools.ocr_tool import scan_pill
import requests
from .tools.drug_interaction import check_interactions

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

def vision_node(state: AgentState):
    video_data = state.get("video_input")
    try:
        response = requests.post(
            f"{settings.VISION_SERVICE_URL}/verify-intake",
            json={"video": video_data}
        )
        result = response.json() 
        is_verified = result.get("confirmed", False)
        pill_detected = result.get("label", "unknown")
        if is_verified:
            return {
                "messages": [AIMessage(content=f"Ya3tik es-saha, choftik khdhit {pill_detected}. Klemek dima meryeguel!")],
                "medication_confirmed": True
            }
        else:
            return {
                "messages": [AIMessage(content="Ma najemtech nthabet mel tswira. Aman 3awed thabet el camara fih.")],
                "medication_confirmed": False
            }
    except Exception as e:
        print(f"Communication error with vision-service: {e}")
        return {"messages": [AIMessage(content="Fama mouchkla sghira fel xhadma mte3i. Lahdha taw nchoufha.")]}

def safety_node(state: AgentState):
    """
    Checks for drug-drug interactions and provides safety warnings in Derja.
    """
    new_pills = state.get("identified_pills", [])
    # TODO
    current_meds = state.get("current_medication_list", ["Aspirin"]) 

    if not new_pills:
        return {"messages": [AIMessage(content="Ma lkit hata dwe bech nthabet fih.")]}

    all_meds = list(set(new_pills + current_meds))

    try:
        interactions = check_interactions(all_meds)

        if not interactions:
            response = (
                f"Thabbet fi dwayetka: {', '.join(new_pills)}. "
                "Labes, ma famma hata mouchkel m3a dwayetk lokhrin. Najem nekhdhouhom meryeguel."
            )
            return {"messages": [AIMessage(content=response)]}
        warning_msg = "⚠️ **Red balek!** Famma mouchkel bin dwayetka:\n"
        for issue in interactions:
            warning_msg += f"- {issue['description']}\n"
        
        warning_msg += "\nAnsehik matakhouch el dwe taw w kalem tbibek fisa3."
        
        return {
            "messages": [AIMessage(content=warning_msg)],
            "safety_alert": True # Flag to trigger a notification to family
        }

    except Exception as e:
        print(f"Safety Check Error: {e}")
        return {"messages": [AIMessage(content="Smakhni, ma najemtech nthabet mel safety tawwa. Kallam el tbib khir.")]}