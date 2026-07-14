#!/usr/bin/env python3
"""
scripts/migrate.py
------------------
Lightweight migration runner for the ePortfolio PostgreSQL database.

Usage:
    python scripts/migrate.py up           # apply all pending migrations
    python scripts/migrate.py up 001       # apply up to version prefix
    python scripts/migrate.py status       # show applied vs pending
    python scripts/migrate.py seed         # run seed files after migrations

Environment variables (or .env file):
    DATABASE_URL=postgresql://user:pass@localhost:5432/eportfolio
"""

import os
import sys
import glob
import argparse
from pathlib import Path

try:
    import psycopg2
    from psycopg2.extras import RealDictCursor
    from dotenv import load_dotenv
except ImportError:
    print("Missing deps: pip install psycopg2-binary python-dotenv")
    sys.exit(1)

load_dotenv()

BASE_DIR   = Path(__file__).parent.parent
MIGRATIONS = BASE_DIR / "database" / "migrations"
SEEDS      = BASE_DIR / "database" / "seeds"


def get_conn():
    url = os.environ.get("DATABASE_URL")
    if not url:
        raise EnvironmentError("DATABASE_URL not set. Add it to your .env file.")
    return psycopg2.connect(url)


def ensure_migrations_table(conn):
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS schema_migrations (
                version    VARCHAR(50) PRIMARY KEY,
                applied_at TIMESTAMPTZ DEFAULT NOW()
            );
        """)
    conn.commit()


def applied_versions(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT version FROM schema_migrations ORDER BY version;")
        return {row[0] for row in cur.fetchall()}


def run_sql_file(conn, path: Path):
    sql = path.read_text()
    with conn.cursor() as cur:
        cur.execute(sql)
    conn.commit()
    print(f"  ✓  {path.name}")


def cmd_up(args):
    conn = get_conn()
    ensure_migrations_table(conn)
    applied = applied_versions(conn)

    files = sorted(MIGRATIONS.glob("*.sql"))
    pending = [f for f in files if f.stem not in applied]
    if args.version:
        pending = [f for f in pending if f.stem.startswith(args.version)]

    if not pending:
        print("Nothing to migrate — all up to date.")
        return

    print(f"Applying {len(pending)} migration(s):")
    for f in pending:
        run_sql_file(conn, f)

    conn.close()
    print("Done.")


def cmd_seed(args):
    conn = get_conn()
    files = sorted(SEEDS.glob("*.sql"))
    print(f"Running {len(files)} seed file(s):")
    for f in files:
        run_sql_file(conn, f)
    conn.close()
    print("Seeding complete.")


def cmd_status(args):
    conn = get_conn()
    ensure_migrations_table(conn)
    applied = applied_versions(conn)
    files   = sorted(MIGRATIONS.glob("*.sql"))

    print(f"{'STATUS':<10} {'FILE'}")
    print("-" * 50)
    for f in files:
        status = "applied" if f.stem in applied else "PENDING"
        print(f"{status:<10} {f.name}")
    conn.close()


def main():
    parser = argparse.ArgumentParser(description="ePortfolio DB migration runner")
    sub = parser.add_subparsers(dest="command")

    up_p = sub.add_parser("up", help="Apply pending migrations")
    up_p.add_argument("version", nargs="?", help="Apply only up to this prefix")
    up_p.set_defaults(func=cmd_up)

    seed_p = sub.add_parser("seed", help="Run seed files")
    seed_p.set_defaults(func=cmd_seed)

    status_p = sub.add_parser("status", help="Show migration status")
    status_p.set_defaults(func=cmd_status)

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        return

    try:
        args.func(args)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()