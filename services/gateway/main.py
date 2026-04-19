from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .middleware.auth import AuthMiddleware
from .middleware.rate_limit import RateLimiterMiddleware
from .routers import agent, patients, analytics, notifications

app = FastAPI(title="MedMind API Gateway", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(RateLimiterMiddleware)
app.add_middleware(AuthMiddleware)

app.include_router(agent.router,         prefix="/api/agent",         tags=["Agent"])
app.include_router(patients.router,      prefix="/api/patients",      tags=["Patients"])
app.include_router(analytics.router,     prefix="/api/analytics",     tags=["Analytics"])
app.include_router(notifications.router, prefix="/api/notifications", tags=["Notifications"])


@app.get("/health")
def health():
    return {"status": "ok", "service": "gateway"}