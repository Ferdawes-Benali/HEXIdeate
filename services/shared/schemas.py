"""Shared Pydantic schemas for API requests/responses"""
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, EmailStr, Field


# Patient Schemas
class PatientBase(BaseModel):
    """Base patient schema"""
    full_name: str
    date_of_birth: datetime
    emergency_contact: str
    emergency_contact_phone: str
    language_preference: str = "ar"


class PatientCreate(PatientBase):
    """Patient creation schema"""
    pass


class PatientUpdate(BaseModel):
    """Patient update schema"""
    full_name: Optional[str] = None
    emergency_contact: Optional[str] = None
    emergency_contact_phone: Optional[str] = None
    language_preference: Optional[str] = None


class PatientResponse(PatientBase):
    """Patient response schema"""
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Medication Schemas
class MedicationBase(BaseModel):
    """Base medication schema"""
    name: str
    generic_name: Optional[str] = None
    dosage: str
    medication_type: str


class MedicationCreate(MedicationBase):
    """Medication creation schema"""
    patient_id: int


class MedicationResponse(MedicationBase):
    """Medication response schema"""
    id: int
    patient_id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Medication Schedule Schemas
class MedicationScheduleBase(BaseModel):
    """Base schedule schema.
    
    Note: time_of_day is stored as HH:MM string (e.g., "09:00", "20:30").
    When creating intake history entries, scheduled_time is computed from
    the patient's reference date + time_of_day as a full datetime.
    """
    time_of_day: str  # HH:MM format, e.g., "09:00"
    frequency: str
    monday: bool = False
    tuesday: bool = False
    wednesday: bool = False
    thursday: bool = False
    friday: bool = False
    saturday: bool = False
    sunday: bool = False


class MedicationScheduleCreate(MedicationScheduleBase):
    """Schedule creation schema"""
    medication_id: int
    patient_id: int


class MedicationScheduleResponse(MedicationScheduleBase):
    """Schedule response schema"""
    id: int
    medication_id: int
    patient_id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


# Intake History Schemas
class IntakeHistoryBase(BaseModel):
    """Base intake history schema"""
    scheduled_time: datetime
    status: str


class IntakeHistoryCreate(IntakeHistoryBase):
    """Intake creation schema"""
    medication_id: int
    patient_id: int
    actual_time: Optional[datetime] = None
    notes: Optional[str] = None


class IntakeHistoryResponse(IntakeHistoryBase):
    """Intake history response schema"""
    id: int
    medication_id: int
    patient_id: int
    actual_time: Optional[datetime] = None
    notes: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


# Alert Schemas
class AlertBase(BaseModel):
    """Base alert schema"""
    alert_type: str
    severity: str
    title: str
    message: str


class AlertCreate(AlertBase):
    """Alert creation schema"""
    patient_id: int


class AlertResponse(AlertBase):
    """Alert response schema"""
    id: int
    patient_id: int
    is_read: bool
    is_acknowledged: bool
    created_at: datetime
    acknowledged_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class AlertUpdate(BaseModel):
    """Alert update schema"""
    is_read: Optional[bool] = None
    is_acknowledged: Optional[bool] = None


# Drug Interaction Schemas
class DrugInteractionBase(BaseModel):
    """Base drug interaction schema"""
    medication1_id: int
    medication2_id: int
    interaction_severity: str
    description: str
    recommendation: str


class DrugInteractionResponse(DrugInteractionBase):
    """Drug interaction response schema"""
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


# User Schemas
class UserBase(BaseModel):
    """Base user schema"""
    username: str
    email: EmailStr
    role: str


class UserCreate(UserBase):
    """User creation schema"""
    password: str
    patient_id: Optional[int] = None


class UserResponse(UserBase):
    """User response schema"""
    id: int
    is_active: bool
    created_at: datetime
    last_login: Optional[datetime] = None

    class Config:
        from_attributes = True


# Session Memory Schemas
class SessionMemoryCreate(BaseModel):
    """Session memory creation schema"""
    patient_id: int
    session_id: str
    role: str
    content: str
    metadata: Optional[str] = None


class SessionMemoryResponse(SessionMemoryCreate):
    """Session memory response schema"""
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


# Agent Schemas
class AgentIntentRequest(BaseModel):
    """Agent intent recognition request"""
    patient_id: int
    message: str
    language: str = "ar"


class AgentIntentResponse(BaseModel):
    """Agent intent response.
    
    Intent values: 'vision_tool', 'safety_check', 'chat'
    (NOT 'vision' - agent uses 'vision_tool'; NOT 'schedule_reminder' - removed from active intents)
    """
    intent: str  # vision_tool, safety_check, chat
    confidence: float
    entities: dict = {}


class DrugSafetyCheckRequest(BaseModel):
    """Drug safety check request"""
    patient_id: int
    medication_ids: List[int]


class DrugSafetyCheckResponse(BaseModel):
    """Drug safety check response"""
    is_safe: bool
    interactions: List[dict] = []
    warnings: List[str] = []
    recommendations: List[str] = []


# Vision Service Schemas
class PillDetectionRequest(BaseModel):
    """Pill detection request"""
    image_data: str  # Base64 encoded image
    confidence_threshold: float = 0.85


class PillDetectionResponse(BaseModel):
    """Pill detection response"""
    detected_pills: List[dict]
    confidence_scores: List[float]
    additional_info: Optional[dict] = None


# Analytics Schemas
class PredictionRequest(BaseModel):
    """Prediction request"""
    patient_id: int
    feature_values: List[float]


class PredictionResponse(BaseModel):
    """Prediction response"""
    prediction: float
    probability: float
    explanation: Optional[str] = None


# Notification Schemas
class NotificationCreate(BaseModel):
    """Notification creation schema"""
    patient_id: int
    title: str
    message: str
    notification_type: str


class NotificationResponse(NotificationCreate):
    """Notification response schema"""
    id: int
    is_sent: bool
    created_at: datetime

    class Config:
        from_attributes = True


# Health Check Schema
class HealthResponse(BaseModel):
    """Health check response"""
    status: str
    service: str
    version: str = "1.0.0"
    timestamp: datetime = Field(default_factory=datetime.utcnow)
