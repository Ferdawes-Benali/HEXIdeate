import os
import time
import redis
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse

REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379")
RATE_LIMIT = int(os.getenv("RATE_LIMIT_PER_MINUTE", "60"))

try:
    _redis = redis.from_url(REDIS_URL, decode_responses=True)
    _redis.ping()
    _redis_available = True
except Exception:
    _redis_available = False
    print("[rate_limiter] Redis unavailable — rate limiting disabled.")


class RateLimiterMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        if not _redis_available:
            return await call_next(request)

        # Safe client IP extraction
        client_ip = request.client.host if request.client else "unknown"
        key = f"rl:{client_ip}:{int(time.time() // 60)}"

        try:
            count = _redis.incr(key)
            if count == 1:
                _redis.expire(key, 60)
            if count > RATE_LIMIT:
                return JSONResponse(
                    status_code=429,
                    content={"detail": f"Rate limit exceeded. Max {RATE_LIMIT} req/min."},
                )
        except Exception as e:
            print(f"[rate_limiter] Redis error: {e}")

        return await call_next(request)