"""Router initialization"""
from .patients import router as patients_router
from .agent import router as agent_router
from .analytics import router as analytics_router
from .notifications import router as notifications_router

__all__ = ["patients_router", "agent_router", "analytics_router", "notifications_router"]
