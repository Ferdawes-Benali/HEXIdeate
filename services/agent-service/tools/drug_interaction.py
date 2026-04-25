import requests
import logging
from typing import List, Dict, Optional
from config import settings

logger = logging.getLogger(__name__)

def check_interactions(med_names: List[str]) -> Optional[List[Dict[str, str]]]:
    if len(med_names) < 2:
        return []

    try:
        response = requests.post(
            f"{settings.DRUG_SERVICE_URL}/check-interactions", 
            json={"medications": med_names},
            timeout=8,
        )
        response.raise_for_status()
        data = response.json()
        
        return data.get("interactions", [])

    except requests.exceptions.Timeout:
        logger.error(f"Timeout checking interactions for: {med_names}")
        return None
    except requests.exceptions.RequestException as e:
        logger.error(f"Network/Service error in drug_interaction: {str(e)}")
        return None
    except Exception as e:
        logger.exception(f"Unexpected error: {str(e)}")
        return None