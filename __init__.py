# backend/app/schemas/resume.py
"""
Pydantic v2 schemas — these define the shape of every API response.
FastAPI validates and serialises all route returns against these.
"""

from __future__ import annotations
from datetime import date, datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict


# ── Base config ───────────────────────────────────────────
class Base(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# ── Education ─────────────────────────────────────────────
class Education(Base):
    id:          int
    degree:      str
    field:       str
    institution: str
    gpa:         Optional[float]
    start_year:  int
    end_year:    Optional[int]
    honors:      list[str]
    courses:     list[str]


# ── Experience ────────────────────────────────────────────
class ExperienceBullet(Base):
    id:         int
    bullet:     str
    sort_order: int


class Experience(Base):
    id:         int
    company:    str
    role:       str
    division:   Optional[str]
    location:   Optional[str]
    start_date: date
    end_date:   Optional[date]
    is_current: bool
    bullets:    list[ExperienceBullet] = []


# ── Projects ──────────────────────────────────────────────
class Project(Base):
    id:          int
    title:       str
    category:    Optional[str]
    description: str
    start_date:  Optional[date]
    end_date:    Optional[date]
    repo_url:    Optional[str]
    demo_url:    Optional[str]
    is_featured: bool
    tags:        list[str] = []


# ── Research ──────────────────────────────────────────────
class Research(Base):
    id:          int
    title:       str
    lab:         Optional[str]
    institution: Optional[str]
    description: Optional[str]
    start_date:  Optional[date]
    end_date:    Optional[date]
    status:      str
    venue:       Optional[str]
    venue_year:  Optional[int]
    tags:        list[str] = []


# ── Skills ────────────────────────────────────────────────
class Skill(Base):
    id:          int
    name:        str
    category:    str
    proficiency: Optional[int]


class SkillGroup(Base):
    category: str
    skills:   list[Skill]


# ── Chat ──────────────────────────────────────────────────
class ChatMessage(BaseModel):
    role:    str   # 'user' | 'assistant'
    content: str


class ChatRequest(BaseModel):
    session_id: Optional[UUID] = None
    message:    str


class ChatResponse(BaseModel):
    session_id: UUID
    reply:      str