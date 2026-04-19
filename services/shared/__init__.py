"""Shared package"""
from .config import settings, Settings
from .constants import (
    IntakeStatus,
    MedicationType,
    AlertSeverity,
    AlertType,
    UserRole,
    ML_FEATURE_COLUMNS,
)
from .models import (
    Patient,
    Medication,
    MedicationSchedule,
    IntakeHistory,
    DrugInteraction,
    Alert,
    User,
    SessionMemory,
)
from .schemas import (
    PatientResponse,
    MedicationResponse,
    AlertResponse,
    HealthResponse,
)
from .database import engine, async_session, init_db, get_session
from .utils import get_logger, calculate_adherence_rate, is_overdue, get_next_dose_time
from .exceptions import (
    HexIdeateException,
    PatientNotFoundError,
    MedicationNotFoundError,
    DrugInteractionError,
)

__all__ = [
    # Config
    "settings",
    "Settings",
    # Constants
    "IntakeStatus",
    "MedicationType",
    "AlertSeverity",
    "AlertType",
    "UserRole",
    "ML_FEATURE_COLUMNS",
    # Models
    "Patient",
    "Medication",
    "MedicationSchedule",
    "IntakeHistory",
    "DrugInteraction",
    "Alert",
    "User",
    "SessionMemory",
    # Schemas
    "PatientResponse",
    "MedicationResponse",
    "AlertResponse",
    "HealthResponse",
    # Database
    "engine",
    "async_session",
    "init_db",
    "get_session",
    # Utils
    "get_logger",
    "calculate_adherence_rate",
    "is_overdue",
    "get_next_dose_time",
    # Exceptions
    "HexIdeateException",
    "PatientNotFoundError",
    "MedicationNotFoundError",
    "DrugInteractionError",
]
