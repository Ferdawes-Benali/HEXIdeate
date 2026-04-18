import os
from dotenv import load_dotenv

load_dotenv()

def get_required_env(key: str) -> str:
    value = os.getenv(key)
    if not value:
        raise ValueError(f"Missing required environment variable: {key}")
    return value

class Settings:
    GOOGLE_API_KEY = get_required_env("GOOGLE_API_KEY")
    DATABASE_URL = get_required_env("DATABASE_URL")
    DEBUG_MODE = os.getenv("DEBUG", "False").lower() == "true"

settings = Settings()