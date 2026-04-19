# Shared Module Architecture

## Overview

The `services/shared/` module contains all common code used by microservices:
- **Unified database models** (SQLModel)
- **Shared configuration & settings**
- **API request/response schemas** (Pydantic)
- **Utility functions & helpers**
- **Common exceptions**
- **Database utilities**

This ensures:
✅ **Single source of truth** for data models  
✅ **Type safety** across all services  
✅ **Consistency** in API contracts  
✅ **DRY principle** - no code duplication  
✅ **Easy maintenance** - changes propagate to all services  

---

## Directory Structure

```
services/
├── shared/                      # Common module (imported by all services)
│   ├── __init__.py             # Public API exports
│   ├── config.py               # Settings (BaseSettings from pydantic-settings)
│   ├── constants.py            # Enums, thresholds, feature columns
│   ├── models.py               # SQLModel database models (table=True)
│   ├── schemas.py              # Pydantic schemas for requests/responses
│   ├── database.py             # Async database engine, sessions
│   ├── utils.py                # Helper functions (logging, calculations)
│   ├── exceptions.py           # Custom exceptions
│   └── requirements.txt        # Shared dependencies
│
├── agent_service/              # Core AI agent
│   ├── config.py              # Re-exports from shared.config
│   ├── models.py              # Re-exports from shared.models
│   ├── agent.py               # Agent logic (LangGraph)
│   ├── database.py            # Service-specific DB setup
│   ├── state.py               # Agent state schema
│   ├── requirements.txt       # Service-specific + shared
│   ├── memory/
│   │   ├── chroma_rag.py     # Vector DB integration
│   │   └── redis_memory.py   # Session memory
│   └── tools/                 # Agent tools
│       ├── drug_interaction.py
│       ├── fuzzy_matcher.py
│       └── ...
│
├── gateway/                    # API Gateway
│   ├── main.py                # FastAPI app
│   ├── requirements.txt
│   └── routers/
│       ├── patients.py         # Proxy to agent service
│       ├── agent.py            # Proxy to agent service
│       ├── analytics.py        # Proxy to analytics service
│       └── notifications.py    # Proxy to notification service
│
├── analytics-service/          # Predictions & statistics
│   ├── predictor.py           # ML predictions, adherence stats
│   ├── train.py               # Model training (uses shared models)
│   └── requirements.txt
│
└── notification-service/       # Alerts & notifications
    ├── router.py              # Alert dispatch (uses shared models)
    └── requirements.txt
```

---

## How Services Use Shared Module

### 1. Configuration

**All services use the same settings:**

```python
# In any service:
from shared.config import settings

# Access settings:
DATABASE_URL = settings.DATABASE_URL
GOOGLE_API_KEY = settings.GOOGLE_API_KEY
```

### 2. Database Models

**All services reference the same models:**

```python
# In any service:
from shared.models import Patient, Medication, IntakeHistory, Alert

# Create/read/update:
patient = session.query(Patient).get(patient_id)
medications = patient.medications  # Relationships work!
```

### 3. API Schemas

**Request/response validation is consistent:**

```python
# In gateway route:
from shared.schemas import PatientResponse, PatientCreate

@router.post("/patients", response_model=PatientResponse)
async def create_patient(data: PatientCreate):
    # Data validated automatically
    pass
```

### 4. Utilities

**Common functions available to all services:**

```python
# In any service:
from shared.utils import (
    get_logger,
    calculate_adherence_rate,
    is_overdue,
    get_next_dose_time
)

logger = get_logger(__name__)
adherence = calculate_adherence_rate(intakes)
overdue = is_overdue(scheduled_time)
```

### 5. Exceptions

**Standardized error handling:**

```python
# In any service:
from shared.exceptions import PatientNotFoundError, DrugInteractionError

try:
    patient = session.get(Patient, patient_id)
    if not patient:
        raise PatientNotFoundError(f"Patient {patient_id} not found")
except PatientNotFoundError as e:
    logger.error(f"Patient lookup failed: {e}")
```

---

## Service-Specific Configuration

### Agent Service (`agent_service/`)

**Re-exports shared models for easy access:**

```python
# agent_service/config.py
from shared.config import settings

# agent_service/models.py
from shared.models import Patient, Medication, ...
```

**Extends with service-specific features:**
- LangGraph state management (`state.py`)
- Vector DB integration (`memory/chroma_rag.py`)
- Agent tools (`tools/*.py`)

### Analytics Service (`analytics-service/`)

**Uses shared models for database:**

```python
# predictor.py
from shared.models import Patient, IntakeHistory
from shared.schemas import PredictionResponse
from shared.constants import ML_FEATURE_COLUMNS

# Query data, make predictions, return schemas
```

### Notification Service (`notification-service/`)

**Uses shared Alert model:**

```python
# router.py
from shared.models import Alert, Patient
from shared.schemas import AlertResponse

# Create alerts, dispatch notifications
```

### Gateway (`gateway/`)

**Routes to other services via HTTP:**

```python
# routers/patients.py
# Validates with shared schemas
# Calls agent_service via httpx

# routers/analytics.py
# Calls analytics_service via httpx

# routers/notifications.py
# Calls notification_service via httpx
```

---

## Installation & Usage

### Install Shared Module

```bash
# In each service directory:
pip install -r requirements.txt
pip install -e ../shared

# Or manually:
pip install pydantic sqlmodel sqlalchemy redis fastapi httpx
```

### Import in Your Service

```python
# At top of file:
import sys
sys.path.insert(0, '..')

from shared.config import settings
from shared.models import Patient, Medication
from shared.schemas import PatientResponse
from shared.database import get_session
from shared.utils import get_logger
```

### Use in Routes

```python
from fastapi import Depends
from shared.database import AsyncSession, get_session
from shared.models import Patient
from shared.schemas import PatientResponse

@router.get("/patients/{patient_id}", response_model=PatientResponse)
async def get_patient(patient_id: int, session: AsyncSession = Depends(get_session)):
    patient = await session.get(Patient, patient_id)
    if not patient:
        raise HTTPException(status_code=404, detail="Not found")
    return patient
```

---

## Database Models

### Patient
- Basic patient info, emergency contacts, language preference
- Relationships: medications, alerts, intake_history, schedules

### Medication
- Medication details: name, generic name, dosage, type
- Relationships: patient, intake_history, drug_interactions

### MedicationSchedule
- When/how often to take each medication
- Tracks day-of-week, time-of-day

### IntakeHistory
- Records of each dose taken/skipped/missed
- Scheduled vs actual time

### DrugInteraction
- Known interactions between medications
- Severity level and recommendations

### Alert
- Notifications: missed doses, interactions, reminders
- Severity and acknowledgment tracking

### User
- User accounts with roles (patient, caregiver, doctor, admin)
- Links to patient records

### SessionMemory
- Conversation history for multi-turn chats
- Patient context retention

---

## Constants & Enums

### Status Enums
```python
IntakeStatus: pending, taken, skipped, missed
AlertSeverity: low, medium, high, critical
AlertType: drug_interaction, missed_dose, reminder, etc.
UserRole: patient, caregiver, doctor, admin
```

### Thresholds
```python
DRUG_INTERACTION_THRESHOLD = 0.7
MISSED_DOSE_THRESHOLD_MINUTES = 60
ADHERENCE_WARNING_THRESHOLD = 0.8
MAX_DAILY_MEDICATIONS = 15
```

### ML Features
```python
ML_FEATURE_COLUMNS = [
    "age", "medication_count", "comorbidity_score",
    "adherence_rate", "days_since_last_dose", ...
]
```

---

## Configuration Files

### `.env` Example

```
DATABASE_URL=postgresql://postgres:password@postgres:5432/hexideate
REDIS_URL=redis://redis:6379/0
CHROMA_HOST=chroma
CHROMA_PORT=8000
GOOGLE_API_KEY=your_key_here
JWT_SECRET_KEY=your_secret_key
ENVIRONMENT=development
LOG_LEVEL=info
```

### Environment-Specific
- **Development**: SQLite OK, can use simpler settings
- **Production**: PostgreSQL required, Chroma cloud recommended
- **Staging**: Full production setup for testing

---

## Best Practices

### ✅ DO

1. **Import from `shared`** - Use shared models and schemas consistently
2. **Validate with schemas** - Always use Pydantic schemas for requests/responses
3. **Use constants** - Reference `THRESHOLDS` and `ENUMS` from constants.py
4. **Async database** - Use async/await patterns with AsyncSession
5. **Use utilities** - Leverage helper functions instead of reimplementing

### ❌ DON'T

1. **Duplicate models** - Don't redefine Patient, Medication, etc.
2. **Hardcode values** - Use constants.py instead
3. **Skip validation** - Always use schemas for API contracts
4. **Ignore exceptions** - Catch specific exceptions from exceptions.py
5. **Create local configs** - Use shared.config.Settings

---

## Service Communication

```
Mobile App
    ↓ HTTPS
[API Gateway] ← ← ←(httpx calls)← ← ← [Microservices]
    ├→ /api/patients        → agent_service
    ├→ /api/agent           → agent_service
    ├→ /api/analytics       → analytics-service
    └→ /api/notifications   → notification-service

All use:
├─ shared.models (SQLModel)
├─ shared.schemas (Pydantic)
├─ shared.config (Settings)
└─ shared.database (AsyncSession)
```

---

## Migration Path

If adding a new service:

1. **Import shared module**: `from shared import models, schemas, config, utils`
2. **Define service-specific logic**: Tools, business logic, algorithms
3. **Expose via API**: Use shared schemas for request/response
4. **Add to gateway**: Create router that calls your service
5. **Document**: Add to this guide

---

## Troubleshooting

### Import Errors
```python
# Make sure path is correct:
import sys
sys.path.insert(0, '..')  # From services/your_service/

from shared.models import Patient
```

### Database Connection Issues
```python
# Check settings:
from shared.config import settings
print(settings.DATABASE_URL)

# Test connection:
from shared.database import engine
async with engine.begin() as conn:
    await conn.execute("SELECT 1")
```

### Schema Validation Errors
```python
# Use response_model with FastAPI:
from shared.schemas import PatientResponse

@router.get("/patients/{id}", response_model=PatientResponse)
async def get(id: int):
    return patient  # Automatically validated!
```

---

## Future Enhancements

- [ ] Add database migrations (Alembic)
- [ ] Add authentication/authorization schemas
- [ ] Add caching layer (Redis integration)
- [ ] Add pagination helpers
- [ ] Add sorting/filtering utilities
- [ ] Add rate limiting schemas
- [ ] Add audit logging

---

## Summary

The shared module is the **backbone** of HexIdeate's microservices:

| Component | File | Purpose |
|-----------|------|---------|
| **Models** | `models.py` | SQLModel tables with relationships |
| **Schemas** | `schemas.py` | Pydantic validation for APIs |
| **Config** | `config.py` | Centralized settings |
| **Database** | `database.py` | Async session management |
| **Utils** | `utils.py` | Common functions (logging, calculations) |
| **Constants** | `constants.py` | Enums, thresholds, ML features |
| **Exceptions** | `exceptions.py` | Custom error types |

**Result**: Coherent, maintainable, type-safe microservices! 🎯
