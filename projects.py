# backend/app/routes/projects.py
from fastapi import APIRouter, Depends, Query
import asyncpg
from app.database import get_db

router = APIRouter()


@router.get("/")
async def list_projects(
    featured: bool | None = Query(None),
    db: asyncpg.Connection = Depends(get_db),
):
    where = "WHERE is_featured = TRUE" if featured else ""
    rows = await db.fetch(f"""
        SELECT p.id, p.title, p.category, p.description,
               p.start_date, p.end_date, p.repo_url, p.demo_url, p.is_featured,
               ARRAY_AGG(pt.tag ORDER BY pt.id) FILTER (WHERE pt.tag IS NOT NULL) AS tags
        FROM projects p
        LEFT JOIN project_tags pt ON pt.project_id = p.id
        {where}
        GROUP BY p.id
        ORDER BY p.is_featured DESC, p.start_date DESC NULLS LAST
    """)
    return [dict(r) for r in rows]


@router.get("/{project_id}")
async def get_project(project_id: int, db: asyncpg.Connection = Depends(get_db)):
    from fastapi import HTTPException
    row = await db.fetchrow("""
        SELECT p.id, p.title, p.category, p.description,
               p.start_date, p.end_date, p.repo_url, p.demo_url, p.is_featured,
               ARRAY_AGG(pt.tag ORDER BY pt.id) FILTER (WHERE pt.tag IS NOT NULL) AS tags
        FROM projects p
        LEFT JOIN project_tags pt ON pt.project_id = p.id
        WHERE p.id = $1
        GROUP BY p.id
    """, project_id)
    if not row:
        raise HTTPException(status_code=404, detail="Project not found")
    return dict(row)