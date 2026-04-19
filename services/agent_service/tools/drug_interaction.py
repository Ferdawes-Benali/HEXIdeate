import requests
from typing import List, Dict, Optional
from ..config import settings


def check_interactions(med_names: List[str]) -> Optional[List[Dict[str, str]]]:
    """
    Checks drug-drug interactions for a list of medication names.
    
    Returns:
        - List[Dict] with interactions found: [{"pair": "...", "description": "..."}]
        - Empty list [] if check succeeded but no interactions found
        - None if check FAILED (network error, timeout, service down)
    
    CRITICAL: Caller MUST distinguish between [] (safe) and None (indeterminate).
    Returning [] on service failure would create a false safety guarantee.
    """
    if len(med_names) < 2:
        return []

    try:
        response = requests.post(
            f"{settings.NOTIFICATION_SERVICE_URL}/check-interactions",
            json={"medications": med_names},
            timeout=8,
        )
        response.raise_for_status()
        data = response.json()
        return data.get("interactions", [])
    except Exception as e:
        print(f"[drug_interaction] Service error: {e}")
        # CRITICAL: Return None to signal check FAILED, not "no interactions found"
        return None