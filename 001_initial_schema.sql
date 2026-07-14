-- ============================================================
-- Migration 001: Initial Schema
-- ePortfolio database for Tobiah Bower
-- Run: psql -d eportfolio -f 001_initial_schema.sql
-- ============================================================

BEGIN;

-- Track which migrations have been applied
CREATE TABLE IF NOT EXISTS schema_migrations (
    version     VARCHAR(50) PRIMARY KEY,
    applied_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── EDUCATION ──────────────────────────────────────────────
CREATE TABLE education (
    id          SERIAL PRIMARY KEY,
    degree      VARCHAR(120)    NOT NULL,
    field       VARCHAR(120)    NOT NULL,
    institution VARCHAR(120)    NOT NULL,
    gpa         NUMERIC(3,2),
    start_year  SMALLINT        NOT NULL,
    end_year    SMALLINT,           -- NULL = in progress
    honors      TEXT[],             -- array of honor strings
    courses     TEXT[],
    created_at  TIMESTAMPTZ     DEFAULT NOW()
);

-- ── WORK EXPERIENCE ───────────────────────────────────────
CREATE TABLE experience (
    id          SERIAL PRIMARY KEY,
    company     VARCHAR(120)    NOT NULL,
    role        VARCHAR(120)    NOT NULL,
    division    VARCHAR(120),
    location    VARCHAR(80),
    start_date  DATE            NOT NULL,
    end_date    DATE,               -- NULL = current
    is_current  BOOLEAN         DEFAULT FALSE,
    created_at  TIMESTAMPTZ     DEFAULT NOW()
);

CREATE TABLE experience_bullets (
    id              SERIAL PRIMARY KEY,
    experience_id   INT NOT NULL REFERENCES experience(id) ON DELETE CASCADE,
    bullet          TEXT NOT NULL,
    sort_order      SMALLINT DEFAULT 0
);

-- ── PROJECTS ──────────────────────────────────────────────
CREATE TABLE projects (
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(180)    NOT NULL,
    category    VARCHAR(80),        -- e.g. 'Senior Design', 'Research', 'IEEE UCF'
    description TEXT            NOT NULL,
    start_date  DATE,
    end_date    DATE,
    repo_url    VARCHAR(255),
    demo_url    VARCHAR(255),
    is_featured BOOLEAN         DEFAULT FALSE,
    created_at  TIMESTAMPTZ     DEFAULT NOW()
);

CREATE TABLE project_tags (
    id          SERIAL PRIMARY KEY,
    project_id  INT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    tag         VARCHAR(60) NOT NULL
);

CREATE INDEX idx_project_tags_project ON project_tags(project_id);

-- ── RESEARCH / PUBLICATIONS ───────────────────────────────
CREATE TABLE research (
    id              SERIAL PRIMARY KEY,
    title           VARCHAR(255)    NOT NULL,
    lab             VARCHAR(180),
    institution     VARCHAR(120),
    description     TEXT,
    start_date      DATE,
    end_date        DATE,
    status          VARCHAR(40)     DEFAULT 'ongoing',
        -- e.g. 'ongoing', 'submitted', 'published', 'completed'
    venue           VARCHAR(180),   -- conference / journal name
    venue_year      SMALLINT,
    created_at      TIMESTAMPTZ     DEFAULT NOW()
);

CREATE TABLE research_tags (
    id          SERIAL PRIMARY KEY,
    research_id INT NOT NULL REFERENCES research(id) ON DELETE CASCADE,
    tag         VARCHAR(60) NOT NULL
);

-- ── SKILLS ────────────────────────────────────────────────
CREATE TABLE skills (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(80)     NOT NULL,
    category    VARCHAR(60)     NOT NULL,
        -- e.g. 'Programming', 'Domain Expertise', 'Tools', 'Hardware'
    proficiency SMALLINT        CHECK (proficiency BETWEEN 1 AND 100),
    created_at  TIMESTAMPTZ     DEFAULT NOW(),
    UNIQUE(name, category)
);

-- ── CHAT SESSIONS (for the AI chatbot) ───────────────────
CREATE TABLE chat_sessions (
    id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at  TIMESTAMPTZ     DEFAULT NOW(),
    user_agent  TEXT
);

CREATE TABLE chat_messages (
    id          SERIAL PRIMARY KEY,
    session_id  UUID            NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
    role        VARCHAR(10)     NOT NULL CHECK (role IN ('user', 'assistant')),
    content     TEXT            NOT NULL,
    created_at  TIMESTAMPTZ     DEFAULT NOW()
);

CREATE INDEX idx_chat_messages_session ON chat_messages(session_id);

-- ── ACTIVITIES ────────────────────────────────────────────
CREATE TABLE activities (
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(180)    NOT NULL,
    role        VARCHAR(120),
    organization VARCHAR(120),
    start_date  DATE,
    end_date    DATE,
    url         VARCHAR(255),
    created_at  TIMESTAMPTZ     DEFAULT NOW()
);

-- ── RECORD THIS MIGRATION ─────────────────────────────────
INSERT INTO schema_migrations (version) VALUES ('001_initial_schema')
    ON CONFLICT (version) DO NOTHING;

COMMIT;