import os
import logging
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse
import jwt

logger = logging.getLogger(__name__)

SECRET_KEY = os.getenv("JWT_SECRET", "change-me-in-production")
ALGORITHM = "HS256"

PUBLIC_PATHS = {"/health", "/docs", "/openapi.json", "/redoc"}


class AuthMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        if request.url.path in PUBLIC_PATHS:
            return await call_next(request)

        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            logger.warning(f"Missing/invalid token for {request.url.path}")
            return JSONResponse(status_code=401, content={"detail": "Missing or invalid token."})

        token = auth_header.split(" ", 1)[1]
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            request.state.user_id = payload.get("sub")
            request.state.role = payload.get("role", "patient")
        except jwt.ExpiredSignatureError:
            logger.warning(f"Expired token for {request.url.path}")
            return JSONResponse(status_code=401, content={"detail": "Token expired."})
        except jwt.InvalidTokenError as e:
            logger.warning(f"Invalid token for {request.url.path}: {e}")
            return JSONResponse(status_code=401, content={"detail": "Invalid token."})

        return await call_next(request)