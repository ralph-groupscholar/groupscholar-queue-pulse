#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "DATABASE_URL is not set."
  exit 1
fi

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$(dirname "$0")/init_db.sql"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
INSERT INTO groupscholar_queue_pulse.signals (source, priority, note)
VALUES
  ('email', 'high', 'Award confirmation needed for scholarship decision meeting.'),
  ('slack', 'medium', 'Scholar missing updated transcript; follow-up requested.'),
  ('sms', 'low', 'Reminder sent for upcoming mentor session.'),
  ('email', 'high', 'Financial aid verification request flagged by partner.'),
  ('portal', 'medium', 'Application status change triggered a review follow-up.');
SQL
