from datetime import datetime, time
from typing import List, Optional
from sqlmodel import SQLModel, Field, Relationship

class Patient(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    full_name: str
    emergency_contact: str
    
    medications: List["Medication"] = Relationship(back_populates="patient")

class Medication(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True) # e.g., "Zestril"
    generic_name: Optional[str] = None # e.g., "Lisinopril"
    dosage: str
    patient_id: int = Field(foreign_key="patient.id")
    is_active: bool = True
    
    patient: Patient = Relationship(back_populates="medications")
    intakes: List["IntakeHistory"] = Relationship(back_populates="medication")

class IntakeHistory(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    medication_id: int = Field(foreign_key="medication.id")
    status: str # "confirmed", "missed", "wrong_pill"
    video_path: Optional[str] = None # Link to the file in your storage
    
    medication: Medication = Relationship(back_populates="intakes")