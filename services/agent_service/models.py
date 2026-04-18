from datetime import datetime, time, timezone
from typing import List, Optional
from sqlmodel import SQLModel, Field, Relationship

class Patient(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    full_name: str
    emergency_contact: str
    
    medications: List["Medication"] = Relationship(back_populates="patient")
    alerts: List["Alert"] = Relationship(back_populates="patient")

class Medication(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True) 
    generic_name: Optional[str] = None 
    dosage: str
    patient_id: int = Field(foreign_key="patient.id")
    is_active: bool = True
    
    patient: Patient = Relationship(back_populates="medications")
    intakes: List["IntakeHistory"] = Relationship(back_populates="medication")
    schedules: List["MedicationSchedule"] = Relationship(back_populates="medication")

class MedicationSchedule(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    medication_id: int = Field(foreign_key="medication.id")
    
    scheduled_time: time = Field(description="The time of day for the dose")
    day_of_week: str = Field(default="all")
    
    medication: Medication = Relationship(back_populates="schedules")

class IntakeHistory(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    # Better for SQL tracking:
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    medication_id: int = Field(foreign_key="medication.id")
    status: str 
    video_path: Optional[str] = None
    
    medication: Medication = Relationship(back_populates="intakes")
    alert: Optional["Alert"] = Relationship(back_populates="intake_history")

class Alert(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    patient_id: int = Field(foreign_key="patient.id")
    intake_history_id: Optional[int] = Field(default=None, foreign_key="intakehistory.id")
    
    alert_type: str
    severity: str   
    is_resolved: bool = False
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    
    patient: Patient = Relationship(back_populates="alerts")
    intake_history: Optional[IntakeHistory] = Relationship(back_populates="alert")