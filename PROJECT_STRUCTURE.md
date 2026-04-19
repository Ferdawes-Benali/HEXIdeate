# HexIdeate Project Structure

## Overview
A healthcare platform for elderly Tunisian patients featuring medicine identification, safety checks, and voice interaction.

## Directory Structure


```
HexIdeate/
├── infra/                           # Infrastructure configuration
│
├── mobile_app/                      # Flutter mobile application
│   ├── pubspec.yaml                 # Dependencies
│   ├── android/                     # Android-specific config
│   ├── assets/
│   │   ├── images/                  # App images
│   │   ├── models/                  # ML models
│   │   └── translations/            # i18n translations
│   └── lib/
│       ├── main.dart               # Entry point
│       ├── app.dart                # App configuration
│       ├── core/
│       │   ├── api/                # API clients
│       │   ├── constants/          # App constants
│       │   ├── errors/             # Error handling
│       │   └── utils/              # Utility functions
│       ├── data/
│       │   ├── models/             # Data models
│       │   ├── repositories/       # Data access layer
│       │   └── sources/            # Data sources (API, local)
│       ├── logic/
│       │   ├── agent_bloc/         # Agent BLoC
│       │   ├── vision_bloc/        # Vision/Camera BLoC
│       │   └── voice_bloc/         # Voice BLoC
│       └── presentation/
│           ├── screens/
│           │   ├── camera/         # Camera screen
│           │   ├── chat/           # Chat screen
│           │   └── dashboard/      # Dashboard screen
│           └── widgets/            # Reusable widgets
│   └── test/                        # Test files
│
└── services/                        # Backend microservices
    │
    ├── shared/                      # Shared utilities & models
    │   ├── __init__.py
    │   ├── constants.py            # Shared constants (IntakeStatus, feature cols, thresholds)
    │   ├── models.py               # Unified SQLModel database models
    │   ├── config.py               # Centralized configuration & settings
    │   └── schemas.py              # Pydantic schemas for API requests/responses
    │
    ├── agent_service/              # Main AI agent service
    │   ├── __init__.py
    │   ├── agent.py                # Core agent logic & nodes
    │   ├── config.py               # Re-exports shared configuration
    │   ├── database.py             # Database setup
    │   ├── models.py               # Re-exports shared SQLModel models
    │   ├── requirements.txt        # Python dependencies
    │   ├── state.py                # Agent state schema
    │   ├── Dockerfile
    │   │
    │   ├── memory/                 # Memory & RAG systems
    │   │   ├── __init__.py
    │   │   ├── chroma_rag.py       # Chroma vector DB (RAG)
    │   │   └── redis_memory.py     # Redis session memory
    │   │
    │   └── tools/                  # Agent tools/functions
    │       ├── __init__.py
    │       ├── drug_interaction.py # Drug interaction checker
    │       ├── fuzzy_matcher.py    # Fuzzy pill matching
    │       ├── notif_dispatcher.py # Notification handler
    │       ├── ocr_tool.py         # OCR for pill identification
    │       ├── skip_predictor.py   # Predict missed doses
    │       └── voice_generator.py  # TTS voice output
    │
    ├── analytics-service/          # Analytics & ML training
    │   ├── Dockerfile
    │   ├── requirements.txt        # Python dependencies (fastapi, sklearn, pandas, sqlmodel)
    │   ├── predictor.py            # Prediction logic (uses shared models/constants)
    │   └── train.py                # Model training (uses shared models/constants)
    │
    ├── gateway/                    # API Gateway
    │   ├── Dockerfile
    │   ├── main.py                 # Gateway server
    │   │
    │   ├── middleware/
    │   │   ├── auth.py             # Authentication
    │   │   └── rate_limit.py       # Rate limiting
    │   │
    │   └── routers/                # API endpoints (uses shared schemas)
    │       ├── agent.py            # Agent endpoints
    │       ├── analytics.py        # Analytics endpoints
    │       ├── notifications.py    # Notification endpoints
    │       └── patients.py         # Patient endpoints
    │
    ├── notification-service/       # Notifications
    │   ├── Dockerfile
    │   └── router.py               # Notification routing
    │
    └── vision-service/             # Computer vision service
        ├── Dockerfile
        ├── detector.py             # Object detection
        ├── export_onnx.py          # Model export
        └── model/
            └── pill_yolov8n.onnx   # YOLOv8n pill detection model
```

## Key Components

### Mobile App (Flutter)
- **Purpose**: Client interface for elderly patients
- **Language**: Dart
- **BLoCs**: Manage state for agent, vision, and voice features

### Agent Service (Python)
- **Purpose**: Core AI logic for medicine management
- **Framework**: LangChain + Google Gemini LLM
- **Features**:
  - Intent routing (vision, safety check, chat)
  - Drug interaction checking
  - Pill identification via fuzzy matching
  - Patient context loading
  - Intake history logging
- **Language**: Tunisian Arabic (Derja)

### Gateway (Python)
- **Purpose**: API entry point, authentication, rate limiting
- **Routers**: Agent, Auth, Medications, Vision endpoints

### Vision Service (Python)
- **Purpose**: Pill detection and verification
- **Model**: YOLOv8n (ONNX format)

### Other Services
- **Analytics Service**: Training and predictions
- **Notification Service**: Alert dispatching
- **Voice Service**: Speech-to-text and text-to-speech
