# backend/app/main.py
"""
FastAPI ePortfolio API
----------------------
Runs with: uvicorn app.main:app --reload
Docs at:   http://localhost:8000/docs
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes import education, experience, projects, research, skills, chat

app = FastAPI(
    title="Tobiah Bower — ePortfolio API",
    description="Backend API for the ePortfolio. Serves resume data from PostgreSQL and proxies AI chat.",
    version="1.0.0",
)

# ── CORS ──────────────────────────────────────────────────
# Adjust origins for production (your GitHub Pages URL)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:5173",
        "https://tobiahbower.github.io",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── ROUTERS ───────────────────────────────────────────────
app.include_router(education.router,   prefix="/api/education",   tags=["Education"])
app.include_router(experience.router,  prefix="/api/experience",  tags=["Experience"])
app.include_router(projects.router,    prefix="/api/projects",    tags=["Projects"])
app.include_router(research.router,    prefix="/api/research",    tags=["Research"])
app.include_router(skills.router,      prefix="/api/skills",      tags=["Skills"])
app.include_router(chat.router,        prefix="/api/chat",        tags=["Chat"])


@app.get("/", tags=["Health"])
async def root():
    return {"status": "ok", "message": "ePortfolio API is running"}


@app.get("/api/health", tags=["Health"])
async def health():
    return {"status": "healthy"}