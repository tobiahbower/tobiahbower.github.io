# backend/app/routes/education.py
from fastapi import APIRouter, Depends
import asyncpg
from app.database import get_db

router = APIRouter()

@router.get("/")
async def list_education(db: asyncpg.Connection = Depends(get_db)):
    rows = await db.fetch("""
        SELECT id, degree, field, institution, gpa,
               start_year, end_year, honors, courses
        FROM education
        ORDER BY end_year DESC NULLS FIRST
    """)
    return [dict(r) for r in rows]