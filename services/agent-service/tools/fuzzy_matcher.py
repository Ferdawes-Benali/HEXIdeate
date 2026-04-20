import re
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate
from config import settings

llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash", 
    google_api_key=settings.GOOGLE_API_KEY,
    temperature=0,
)

def fuzzy_pill_match(detected_name: str, patient_meds: list[str]) -> str:
    normalized_detected = detected_name.strip().lower()
    if any(normalized_detected == m.strip().lower() for m in patient_meds):
        return "MATCH"

    prompt = PromptTemplate.from_template(
        """Act as a licensed Tunisian pharmacist (DPML expert).
Compare the detected OCR text "{detected}" against the patient's medication list: {inventory}.

Rules:
- MATCH: Identical or standard Tunisian generic (e.g., Doliprane/Adol/Paradol).
- CONFIRM: Different brand, same DCI (active ingredient) and strength.
- NO_MATCH: Different therapeutic class or active ingredient.

Return ONLY one word: MATCH, CONFIRM, or NO_MATCH."""
    )

    try:
        chain = prompt | llm
        response = chain.invoke({
            "detected": detected_name, 
            "inventory": ", ".join(patient_meds)
        })
        
        raw_content = response.content.strip().upper()
        match = re.search(r"(MATCH|CONFIRM|NO_MATCH)", raw_content)
        
        return match.group(0) if match else "NO_MATCH"
        
    except Exception as e:
        return "NO_MATCH"