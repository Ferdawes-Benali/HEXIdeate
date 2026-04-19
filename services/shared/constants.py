"""Shared constants used across services"""
from enum import Enum


class IntakeStatus(str, Enum):
    """Medication intake status"""
    PENDING = "pending"
    TAKEN = "taken"
    SKIPPED = "skipped"
    MISSED = "missed"
    WRONG_TIME = "wrong_time"  # Patient took correct med but wrong time window
    WRONG_PILL = "wrong_pill"  # Patient took wrong medication


class MedicationType(str, Enum):
    """Type of medication"""
    TABLET = "tablet"
    CAPSULE = "capsule"
    LIQUID = "liquid"
    INJECTION = "injection"
    INHALER = "inhaler"
    PATCH = "patch"
    CREAM = "cream"
    OTHER = "other"


class AlertSeverity(str, Enum):
    """Alert severity levels"""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class AlertType(str, Enum):
    """Types of alerts"""
    DRUG_INTERACTION = "drug_interaction"
    MISSED_DOSE = "missed_dose"
    SCHEDULE_REMINDER = "schedule_reminder"
    SIDE_EFFECT = "side_effect"
    ALLERGY_WARNING = "allergy_warning"
    DOSAGE_WARNING = "dosage_warning"


class UserRole(str, Enum):
    """User roles in the system"""
    PATIENT = "patient"
    CAREGIVER = "caregiver"
    DOCTOR = "doctor"
    ADMIN = "admin"


# Feature columns for ML models (used by analytics-service)
# MUST match the features extracted in _fetch_features() and extract_features()
ML_FEATURE_COLUMNS = [
    "total_doses",
    "missed_rate",
    "success_rate",
    "current_streak",
    "days_since_last_miss"
]

# Thresholds for alerts
DRUG_INTERACTION_THRESHOLD = 0.7  # Similarity threshold
MISSED_DOSE_THRESHOLD_MINUTES = 60  # 1 hour after scheduled time
ADHERENCE_WARNING_THRESHOLD = 0.8  # Alert if adherence below 80%
MAX_DAILY_MEDICATIONS = 15  # Maximum safe daily medications

# OCR Confidence thresholds
OCR_CONFIDENCE_THRESHOLD = 0.85
FUZZY_MATCH_THRESHOLD = 0.8

# Cache TTL (seconds)
CACHE_TTL_PATIENT = 3600  # 1 hour
CACHE_TTL_MEDICATIONS = 7200  # 2 hours
CACHE_TTL_SCHEDULE = 1800  # 30 minutes

# Rate limiting
RATE_LIMIT_REQUESTS = 100
RATE_LIMIT_WINDOW_SECONDS = 60

# Pagination defaults
DEFAULT_PAGE_SIZE = 20
MAX_PAGE_SIZE = 100

# Supported languages
SUPPORTED_LANGUAGES = ["ar", "en", "fr"]  # Arabic, English, French
DEFAULT_LANGUAGE = "ar"  # Tunisian Arabic (Derja)
