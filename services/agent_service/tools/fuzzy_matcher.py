from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate
from ..config import settings

llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    google_api_key=settings.GOOGLE_API_KEY,
    temperature=0,
)


def fuzzy_pill_match(detected_name: str, patient_meds: list[str]) -> str:
    """
    Returns: 'MATCH' (identical/known generic), 'CONFIRM' (same DCI), or 'NO_MATCH'.
    """
    prompt = PromptTemplate.from_template(
        """Act as a licensed Tunisian pharmacist expert in the local market (DPML regulations).
Compare the {detected} label from an OCR scan against the patient's {inventory}.

Evaluation Logic:
MATCH: The names are identical, or one is a well-known Tunisian generic of the other (e.g., Clamoxyl vs. Augmentin, or Adol vs. Doliprane).
CONFIRM: The brands differ but share the exact same active ingredient (DCI) and dosage strength.
NO_MATCH: The active ingredients or therapeutic classes are entirely different.

Constraints:
- Account for common OCR misspellings.
- Use your knowledge of Tunisian brand names.
- Return ONLY one of these three words: MATCH, CONFIRM, or NO_MATCH."""
    )

    chain = prompt | llm
    response = chain.invoke({"detected": detected_name, "inventory": ", ".join(patient_meds)})
    result = response.content.strip().upper()
    return result if result in ["MATCH", "CONFIRM", "NO_MATCH"] else "NO_MATCH"