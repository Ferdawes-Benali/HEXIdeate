"""Shared exceptions"""


class HexIdeateException(Exception):
    """Base exception for HexIdeate"""
    pass


class PatientNotFoundError(HexIdeateException):
    """Patient not found"""
    pass


class MedicationNotFoundError(HexIdeateException):
    """Medication not found"""
    pass


class DrugInteractionError(HexIdeateException):
    """Drug interaction detected"""
    pass


class InvalidDosageError(HexIdeateException):
    """Invalid dosage"""
    pass


class DatabaseError(HexIdeateException):
    """Database operation error"""
    pass


class ServiceUnavailableError(HexIdeateException):
    """Service unavailable"""
    pass


class AuthenticationError(HexIdeateException):
    """Authentication error"""
    pass


class AuthorizationError(HexIdeateException):
    """Authorization error"""
    pass


class ValidationError(HexIdeateException):
    """Validation error"""
    pass
