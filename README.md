# Group Scholar Queue Pulse

Group Scholar Queue Pulse is a lightweight ARM64 assembly CLI that logs support-queue signals and summarizes priority volume from a production Postgres database.

## Features
- Log queue signals with source, priority, and note
- Summarize signal volume by priority
- Review recent signals with optional limit
- Production-ready Postgres schema + seed data

## Tech
- Assembly (Apple ARM64)
- libpq (PostgreSQL client library)
- Postgres

## Getting started

### 1) Build
```bash
make
```

### 2) Configure environment
Set a `DATABASE_URL` pointing at the production database.

```bash
export DATABASE_URL="postgres://USER:PASSWORD@HOST:PORT/DBNAME"
```

### 3) Initialize schema + seed data
```bash
./scripts/seed_db.sh
```

### 4) Log signals
```bash
./gs-queue-pulse add "email" "high" "Scholar needs award letter by Friday"
./gs-queue-pulse add "slack" "medium" "Missing FAFSA receipt"
```

### 5) View summary
```bash
./gs-queue-pulse summary
```

### 6) View recent signals
```bash
./gs-queue-pulse recent
./gs-queue-pulse recent 10
```

## Testing
```bash
./scripts/test_cli.sh
```

## Notes
- The database schema uses the `groupscholar_queue_pulse` namespace to avoid collisions.
- Credentials must be provided via environment variables. Do not hardcode secrets.

## Project status
See `ralph-progress.md` for iteration updates.
