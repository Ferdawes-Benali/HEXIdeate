import requests
from typing import Literal
from ..config import settings


def dispatch_alert(
    patient_id: int,
    alert_type: Literal["missed_dose", "wrong_pill", "drug_interaction"],
    message: str,
    severity: Literal["low", "medium", "high"] = "medium",
) -> bool:
    """
    Sends a push/SMS alert to the patient's emergency contact via the notification service.
    Returns True on success, False on failure.
    """
    try:
        response = requests.post(
            f"{settings.NOTIFICATION_SERVICE_URL}/dispatch",
            json={
                "patient_id": patient_id,
                "alert_type": alert_type,
                "message": message,
                "severity": severity,
            },
            timeout=8,
        )
        response.raise_for_status()
        return True
    except Exception as e:
        print(f"[notif_dispatcher] Failed to dispatch alert: {e}")
        return False