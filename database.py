# backend/app/database.py
"""
Database connection pool using asyncpg for async FastAPI routes.
Synchronous psycopg2 connection for tests and scripts.
"""

import os
from contextlib import asynccontextmanager
from typing import AsyncGenerator

import asyncpg
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.environ.get("DATABASE_URL", "postgresql://localhost/eportfolio")

# Convert psycopg2-style URL to asyncpg-style if needed
_async_url = DATABASE_URL.replace("postgresql://", "postgres://", 1)

_pool: asyncpg.Pool | None = None


async def get_pool() -> asyncpg.Pool:
    global _pool
    if _pool is None:
        _pool = await asyncpg.create_pool(_async_url, min_size=2, max_size=10)
    return _pool


async def close_pool():
    global _pool
    if _pool:
        await _pool.close()
        _pool = None


# ── FastAPI dependency ─────────────────────────────────────
async def get_db() -> AsyncGenerator[asyncpg.Connection, None]:
    """
    Use in route handlers:
        async def my_route(db: asyncpg.Connection = Depends(get_db)):
    """
    pool = await get_pool()
    async with pool.acquire() as conn:
        yield conn