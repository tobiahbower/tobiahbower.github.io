#!/usr/bin/env python3
"""Build knowledge artifacts for the portfolio chatbot.

Outputs:
  - data/resume.md      (extracted from PDF)
  - data/knowledge.md   (merged full-context document)
  - data/knowledge.json (structured chunks for future vector RAG)

Usage:
  python scripts/build-knowledge.py
  python scripts/build-knowledge.py --resume path/to/resume.pdf
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_RESUME = ROOT / "assets" / "resume" / "Bower_resume.pdf"
SITE_MD = ROOT / "data" / "site.md"
RESUME_MD = ROOT / "data" / "resume.md"
KNOWLEDGE_MD = ROOT / "data" / "knowledge.md"
KNOWLEDGE_JSON = ROOT / "data" / "knowledge.json"

CHUNK_SIZE = 800
CHUNK_OVERLAP = 100


def extract_pdf_text(pdf_path: Path) -> str:
    try:
        from pypdf import PdfReader
    except ImportError as exc:
        raise SystemExit(
            "pypdf is required. Install with: pip install pypdf"
        ) from exc

    reader = PdfReader(str(pdf_path))
    pages = [page.extract_text() or "" for page in reader.pages]
    text = "\n\n".join(pages).strip()
    if not text:
        raise SystemExit(f"No text extracted from {pdf_path}")
    return text


def normalize_whitespace(text: str) -> str:
    text = text.replace("\r\n", "\n")
    text = re.sub(r"[ \t]+\n", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def chunk_text(text: str, source: str, chunk_size: int = CHUNK_SIZE, overlap: int = CHUNK_OVERLAP) -> list[dict]:
    """Split text into overlapping chunks for future vector indexing."""
    paragraphs = [p.strip() for p in text.split("\n\n") if p.strip()]
    chunks: list[dict] = []
    buffer = ""
    chunk_index = 0

    def flush_buffer() -> None:
        nonlocal buffer, chunk_index
        if not buffer.strip():
            return
        chunks.append(
            {
                "id": f"{source}-{chunk_index}",
                "source": source,
                "text": buffer.strip(),
                "embedding": None,
            }
        )
        chunk_index += 1
        buffer = ""

    for paragraph in paragraphs:
        candidate = f"{buffer}\n\n{paragraph}".strip() if buffer else paragraph
        if len(candidate) <= chunk_size:
            buffer = candidate
            continue

        if buffer:
            flush_buffer()
            if len(paragraph) <= chunk_size:
                buffer = paragraph
                continue

        start = 0
        while start < len(paragraph):
            end = min(start + chunk_size, len(paragraph))
            piece = paragraph[start:end].strip()
            if piece:
                chunks.append(
                    {
                        "id": f"{source}-{chunk_index}",
                        "source": source,
                        "text": piece,
                        "embedding": None,
                    }
                )
                chunk_index += 1
            if end >= len(paragraph):
                break
            start = max(end - overlap, start + 1)

    flush_buffer()
    return chunks


def build_knowledge_json(site_text: str, resume_text: str) -> dict:
    site_chunks = chunk_text(site_text, "site")
    resume_chunks = chunk_text(resume_text, "resume")
    return {
        "version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "retrieval_mode": "full",
        "vector_store": {
            "enabled": False,
            "provider": None,
            "index_name": None,
            "notes": "Set retrieval_mode to 'vector' and enable vector_store when ready.",
        },
        "documents": [
            {"id": "site", "path": "data/site.md", "chunks": site_chunks},
            {"id": "resume", "path": "data/resume.md", "chunks": resume_chunks},
        ],
        "full_context": f"{site_text}\n\n---\n\n# Resume\n\n{resume_text}",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Build chatbot knowledge artifacts.")
    parser.add_argument("--resume", type=Path, default=DEFAULT_RESUME, help="Path to resume PDF")
    args = parser.parse_args()

    if not args.resume.exists():
        raise SystemExit(f"Resume not found: {args.resume}")
    if not SITE_MD.exists():
        raise SystemExit(f"Site content not found: {SITE_MD}")

    resume_text = normalize_whitespace(extract_pdf_text(args.resume))
    site_text = normalize_whitespace(SITE_MD.read_text(encoding="utf-8"))

    RESUME_MD.write_text(f"# Resume\n\n{resume_text}\n", encoding="utf-8")

    knowledge = build_knowledge_json(site_text, resume_text)
    KNOWLEDGE_MD.write_text(knowledge["full_context"] + "\n", encoding="utf-8")
    KNOWLEDGE_JSON.write_text(json.dumps(knowledge, indent=2) + "\n", encoding="utf-8")

    print(f"Wrote {RESUME_MD}")
    print(f"Wrote {KNOWLEDGE_MD}")
    print(f"Wrote {KNOWLEDGE_JSON} ({len(knowledge['documents'][0]['chunks']) + len(knowledge['documents'][1]['chunks'])} chunks)")


if __name__ == "__main__":
    main()
