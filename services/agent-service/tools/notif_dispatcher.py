import requests
import logging
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from typing import Literal
from config import settings

logger = logging.getLogger(__name__)

retry_strategy = Retry(
    total=3,
    backoff_factor=1,
    status_forcelist=[429, 500, 502, 503, 504],
)
adapter = HTTPAdapter(max_retries=retry_strategy)
http = requests.Session()
http.mount("http://", adapter)
http.mount("https://", adapter)

def dispatch_alert(
    patient_id: int,
    alert_type: Literal["missed_dose", "wrong_pill", "drug_interaction"],
    message: str,
    severity: Literal["low", "medium", "high"] = "medium",
) -> bool:
    """
    Dispatches alert with automatic retries on service instability.
    """
    payload = {
        "patient_id": patient_id,
        "alert_type": alert_type,
        "message": message,
        "severity": severity,
    }

    try:
        response = http.post(
            f"{settings.NOTIFICATION_SERVICE_URL}/dispatch",
            json=payload,
            timeout=10, 
        )
        response.raise_for_status()
        return True
    except requests.exceptions.RetryError:
        logger.error(f"Max retries exceeded for patient {patient_id} alert.")
        return False
    except Exception as e:
        logger.error(f"[notif_dispatcher] Critical failure: {e}")
        return False