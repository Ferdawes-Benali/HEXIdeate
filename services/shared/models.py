"""Shared SQLModel database models"""
from datetime import datetime
from typing import List, Optional
from sqlmodel import SQLModel, Field, Relationship


class Patient(SQLModel, table=True):
    """Patient model"""
    id: Optional[int] = Field(default=None, primary_key=True)
    full_name: str = Field(index=True)
    date_of_birth: datetime
    emergency_contact: str
    emergency_contact_phone: str
    language_preference: str = Field(default="ar")
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    medications: List["Medication"] = Relationship(back_populates="patient", cascade_delete=True)
    alerts: List["Alert"] = Relationship(back_populates="patient", cascade_delete=True)
    intake_history: List["IntakeHistory"] = Relationship(back_populates="patient", cascade_delete=True)
    schedules: List["MedicationSchedule"] = Relationship(back_populates="patient", cascade_delete=True)


class Medication(SQLModel, table=True):
    """Medication model"""
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    generic_name: Optional[str] = None
    dosage: str
    medication_type: str
    patient_id: int = Field(foreign_key="patient.id", index=True)
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    patient: Patient = Relationship(back_populates="medications")
    intakes: List["IntakeHistory"] = Relationship(back_populates="medication", cascade_delete=True)
    schedules: List["MedicationSchedule"] = Relationship(back_populates="medication", cascade_delete=True)
    interactions: List["DrugInteraction"] = Relationship(
        back_populates="medication1",
        sa_relationship_kwargs={"foreign_keys": "DrugInteraction.medication1_id"}
    )


class MedicationSchedule(SQLModel, table=True):
    """Medication schedule model"""
    id: Optional[int] = Field(default=None, primary_key=True)
    medication_id: int = Field(foreign_key="medication.id", index=True)
    patient_id: int = Field(foreign_key="patient.id", index=True)
    time_of_day: str  # Format: "HH:MM"
    frequency: str  # "daily", "twice_daily", "weekly", etc.
    monday: bool = Field(default=False)
    tuesday: bool = Field(default=False)
    wednesday: bool = Field(default=False)
    thursday: bool = Field(default=False)
    friday: bool = Field(default=False)
    saturday: bool = Field(default=False)
    sunday: bool = Field(default=False)
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    medication: Medication = Relationship(back_populates="schedules")
    patient: Patient = Relationship(back_populates="schedules")


class IntakeHistory(SQLModel, table=True):
    """Medication intake history"""
    id: Optional[int] = Field(default=None, primary_key=True)
    medication_id: int = Field(foreign_key="medication.id", index=True)
    patient_id: int = Field(foreign_key="patient.id", index=True)
    scheduled_time: datetime
    actual_time: Optional[datetime] = None
    status: str = Field(default="pending")  # pending, taken, skipped, missed, wrong_time, wrong_pill
    notes: Optional[str] = None
    video_path: Optional[str] = None  # S3 URL or local path to intake video (NEVER raw base64)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    medication: Medication = Relationship(back_populates="intakes")
    patient: Patient = Relationship(back_populates="intake_history")


class DrugInteraction(SQLModel, table=True):
    """Drug interaction record"""
    id: Optional[int] = Field(default=None, primary_key=True)
    medication1_id: int = Field(foreign_key="medication.id", index=True)
    medication2_id: int = Field(foreign_key="medication.id", index=True)
    interaction_severity: str  # "mild", "moderate", "severe", "contraindicated"
    description: str
    recommendation: str
    created_at: datetime = Field(default_factory=datetime.utcnow)

    medication1: Medication = Relationship(back_populates="interactions")


class Alert(SQLModel, table=True):
    """Alert/notification record"""
    id: Optional[int] = Field(default=None, primary_key=True)
    patient_id: int = Field(foreign_key="patient.id", index=True)
    alert_type: str  # drug_interaction, missed_dose, schedule_reminder, etc.
    severity: str  # low, medium, high, critical
    title: str
    message: str
    is_read: bool = Field(default=False)
    is_acknowledged: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    acknowledged_at: Optional[datetime] = None

    patient: Patient = Relationship(back_populates="alerts")


class User(SQLModel, table=True):
    """User account model"""
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(unique=True, index=True)
    email: str = Field(unique=True, index=True)
    hashed_password: str
    role: str  # patient, caregiver, doctor, admin
    patient_id: Optional[int] = Field(foreign_key="patient.id")
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    last_login: Optional[datetime] = None


class SessionMemory(SQLModel, table=True):
    """Session memory/conversation history"""
    id: Optional[int] = Field(default=None, primary_key=True)
    patient_id: int = Field(foreign_key="patient.id", index=True)
    session_id: str = Field(index=True)
    role: str  # user, assistant
    content: str
    data: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
