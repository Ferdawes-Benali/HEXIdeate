"""Agent Service Configuration - re-exports shared settings"""
import sys
sys.path.insert(0, '..')

from shared.config import Settings, settings

__all__ = ["Settings", "settings"]