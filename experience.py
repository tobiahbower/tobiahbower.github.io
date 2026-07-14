# backend/app/routes/experience.py
from fastapi import APIRouter, Depends, HTTPException
import asyncpg
from app.database import get_db

router = APIRouter()


@router.get("/")
async def list_experience(db: asyncpg.Connection = Depends(get_db)):
    """Return all experience records with their bullet points."""
    jobs = await db.fetch("""
        SELECT id, company, role, division, location,
               start_date, end_date, is_current
        FROM experience
        ORDER BY is_current DESC, start_date DESC
    """)

    result = []
    for job in jobs:
        bullets = await db.fetch("""
            SELECT id, bullet, sort_order
            FROM experience_bullets
            WHERE experience_id = $1
            ORDER BY sort_order
        """, job["id"])

        result.append({
            **dict(job),
            "bullets": [dict(b) for b in bullets],
        })
    return result


@router.get("/{experience_id}")
async def get_experience(experience_id: int, db: asyncpg.Connection = Depends(get_db)):
    job = await db.fetchrow("""
        SELECT id, company, role, division, location,
               start_date, end_date, is_current
        FROM experience WHERE id = $1
    """, experience_id)

    if not job:
        raise HTTPException(status_code=404, detail="Experience not found")

    bullets = await db.fetch("""
        SELECT id, bullet, sort_order
        FROM experience_bullets
        WHERE experience_id = $1
        ORDER BY sort_order
    """, experience_id)

    return {**dict(job), "bullets": [dict(b) for b in bullets]}