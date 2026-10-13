# pytest

The French version is [README.fr.md](README.fr.md).

## Purpose

Run the Python tests that decide whether a behavior change is safe to merge.

## Problem it resolves

A green lint job can still ship a broken login or a missing forbidden-scope test. The team rule is that behavior changes have tests, and authorization changes have an allowed case and a forbidden case.

## How we use it

Phase 0. `uv run pytest -q --tb=short` from the service directory. `python-service.yml` sets inert environment variables before import, because `auth-service` builds `Settings()` at import: `JWT_SECRET`, `JWT_ISSUER`, `AUTH_DATABASE_URL`, `WEBAPP_DATABASE_URL`, `REDIS_URL`. Those values never point at a real database. Tests that need Postgres mock the session.

No tests collected is a failure (pytest exit code 5). Coverage ratchet is phase 2: publish `coverage.xml` and fail when the percentage drops. There is no global 80 percent target.

The slow suite stays off the pull request. A nightly job can run integration tests.

## Installation

Packaged like ruff: a dev dependency in the repo’s uv group, installed by `uv sync`. Plugins such as pytest-asyncio stay in that same lockfile.

## Constraints

Tests that open a real database will fail this job. Those belong in a later job with service containers, not in the default path.

## Pros

Same command as the local pre-commit hook (`uv run pytest`). Fast feedback.

## Cons

Unit tests with mocks do not prove the SQL or the HTTP call to `platform-api`. The preproduction smoke in phase 5 covers that path.

## Alternatives

unittest alone. The repos already use pytest and pytest-asyncio.
