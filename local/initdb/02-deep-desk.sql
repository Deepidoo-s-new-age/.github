-- deep_desk: dedicated role + schema. Its models declare no schema, so the role's
-- search_path routes tables (and alembic_version) into `deep_desk`.
-- Idempotent: re-run on an existing volume with
--   docker exec na-postgres psql -U newage -d new_age -f /docker-entrypoint-initdb.d/02-deep-desk.sql
-- Local-only inert password; never reuse outside the compose stack.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'deep_desk') THEN
    CREATE ROLE deep_desk LOGIN PASSWORD 'deep_desk';
  END IF;
END
$$;

CREATE SCHEMA IF NOT EXISTS deep_desk AUTHORIZATION deep_desk;
ALTER ROLE deep_desk SET search_path = deep_desk;

COMMENT ON SCHEMA deep_desk IS 'deep_desk (device_versions, diagnostic_logs, proactive_check_config)';

GRANT ALL ON SCHEMA deep_desk TO CURRENT_USER;
