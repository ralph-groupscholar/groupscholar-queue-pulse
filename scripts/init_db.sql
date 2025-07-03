CREATE SCHEMA IF NOT EXISTS groupscholar_queue_pulse;

CREATE TABLE IF NOT EXISTS groupscholar_queue_pulse.signals (
  id BIGSERIAL PRIMARY KEY,
  reported_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  source TEXT NOT NULL,
  priority TEXT NOT NULL,
  note TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS signals_priority_idx
  ON groupscholar_queue_pulse.signals (priority);

CREATE INDEX IF NOT EXISTS signals_reported_at_idx
  ON groupscholar_queue_pulse.signals (reported_at DESC);
