"""Shared configuration and settings for all services"""
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Global application settings"""
    
    # Database
    DATABASE_URL: str = "postgresql://postgres:postgres@postgres:5432/hexideate"
    
    # Redis
    REDIS_URL: str = "redis://redis:6379/0"
    
    # Chroma Vector DB
    CHROMA_HOST: str = "chroma"
    CHROMA_PORT: int = 8000
    
    # Service URLs
    AGENT_SERVICE_URL: str = "http://agent-service:8000"
    VISION_SERVICE_URL: str = "http://vision-service:8000"
    VOICE_SERVICE_URL: str = "http://voice-service:8000"
    ANALYTICS_SERVICE_URL: str = "http://analytics-service:8000"
    NOTIFICATION_SERVICE_URL: str = "http://notification-service:8000"
    DRUG_SERVICE_URL: str = "http://localhost:8000"
    # Google API
    GOOGLE_API_KEY: str = ""
    
    # JWT
    JWT_SECRET_KEY: str = "your-secret-key-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION_HOURS: int = 24
    
    # Logging
    LOG_LEVEL: str = "info"
    
    # Application
    ENVIRONMENT: str = "development"
    DEBUG: bool = False
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
