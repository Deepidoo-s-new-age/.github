-- New Age local: one Postgres cluster, one schema per service (no cross-schema FKs).
-- Services still use their own DB users / search_path in app config later.

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS monitor;
CREATE SCHEMA IF NOT EXISTS subscriptions;

COMMENT ON SCHEMA auth IS 'auth-service (ACL, modules, tokens metadata)';
COMMENT ON SCHEMA core IS 'platform-api (organisations, contents, …)';
COMMENT ON SCHEMA monitor IS 'deepi_monitor (alerts, webhooks, status history)';
COMMENT ON SCHEMA subscriptions IS 'deepisubscriptions (billing profile, Stripe mirrors, presence)';

-- Convenience grants for the default local role
GRANT ALL ON SCHEMA auth TO CURRENT_USER;
GRANT ALL ON SCHEMA core TO CURRENT_USER;
GRANT ALL ON SCHEMA monitor TO CURRENT_USER;
GRANT ALL ON SCHEMA subscriptions TO CURRENT_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT ALL ON TABLES TO CURRENT_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA core GRANT ALL ON TABLES TO CURRENT_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA monitor GRANT ALL ON TABLES TO CURRENT_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA subscriptions GRANT ALL ON TABLES TO CURRENT_USER;
