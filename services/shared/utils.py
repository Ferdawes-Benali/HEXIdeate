"""Shared utilities and helpers"""
import logging
from datetime import datetime, timedelta, timezone
from typing import Optional

from .config import settings
from .constants import IntakeStatus


logger = logging.getLogger(__name__)


def get_logger(name: str) -> logging.Logger:
    """Get configured logger"""
    logger = logging.getLogger(name)
    logger.setLevel(settings.LOG_LEVEL.upper())
    
    if not logger.handlers:
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    
    return logger


def calculate_adherence_rate(intakes: list) -> float:
    """Calculate medication adherence rate"""
    if not intakes:
        return 0.0
    
    taken = sum(1 for i in intakes if i.status == IntakeStatus.TAKEN)
    return (taken / len(intakes)) * 100


def is_overdue(scheduled_time: datetime, threshold_minutes: int = 60) -> bool:
    """Check if a scheduled dose is overdue"""
    now = datetime.now(timezone.utc)
    return (now - scheduled_time) > timedelta(minutes=threshold_minutes)


def get_next_dose_time(schedules: list, current_time: Optional[datetime] = None) -> Optional[datetime]:
    """Calculate next dose time from schedules"""
    if not schedules:
        return None
    
    if current_time is None:
        current_time = datetime.now(timezone.utc)
    
    next_dose = None
    for schedule in schedules:
        if not schedule.is_active:
            continue
        
        # Parse time_of_day (HH:MM format)
        hour, minute = map(int, schedule.time_of_day.split(':'))
        dose_time = current_time.replace(hour=hour, minute=minute, second=0)
        
        # If dose time has passed today, check tomorrow
        if dose_time <= current_time:
            dose_time += timedelta(days=1)
        
        if next_dose is None or dose_time < next_dose:
            next_dose = dose_time
    
    return next_dose


def sanitize_string(value: str, max_length: int = 1000) -> str:
    """Sanitize string input"""
    if not isinstance(value, str):
        return ""
    return value.strip()[:max_length]


def format_arabic_name(name: str) -> str:
    """Format Arabic text names"""
    return sanitize_string(name)


def validate_phone_number(phone: str) -> bool:
    """Validate phone number format"""
    # Basic validation for Tunisian numbers
    phone = phone.replace("+", "").replace("-", "").replace(" ", "")
    return phone.isdigit() and (len(phone) == 8 or len(phone) == 12)
