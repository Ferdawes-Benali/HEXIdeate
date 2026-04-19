"""Shared database utilities"""
from sqlalchemy import create_engine
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, Session
from sqlmodel import SQLModel

from .config import settings


# Create sync engine for Session() usage (e.g., in agent_service)
engine = create_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    future=True,
)

# Create async engine for AsyncSession usage (e.g., in gateway)
async_engine = create_async_engine(
    settings.DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://"),
    echo=settings.DEBUG,
    future=True,
)

# Create async session factory
async_session = sessionmaker(
    async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    future=True,
)


async def init_db():
    """Initialize database tables"""
    async with async_engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)


async def get_session() -> AsyncSession:
    """Get async database session"""
    async with async_session() as session:
        yield session
