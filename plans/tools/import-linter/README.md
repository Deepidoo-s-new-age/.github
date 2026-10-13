# import-linter

The French version is [README.fr.md](README.fr.md).

## Purpose

Fail when Python imports cross a boundary the architecture forbids.

## Problem it resolves

A module that imports `platform-api` application code, or a route handler that imports the SQLAlchemy session and writes SQL, breaks the rule that services talk over HTTP and repositories own SQL. Review can miss that. A contract check does not.

## How we use it

Phase 5, inside `python-service.yml`, after a config exists in the service. Contracts to encode:

- this service does not import another service’s application package;
- route modules do not import the DB session; repositories do.

Existing violations go in a baseline so the first day is not a rewrite. New violations fail.

## Installation

A Python dev dependency of the service, in `pyproject.toml` and `uv.lock`. `uv sync` installs it once the service commits a contract file.

## Constraints

It sees imports, not HTTP calls. A forbidden `httpx` call to another service still needs the architecture validator and review.

## Pros

The rule is a file in the repo, reviewed like code. Fast.

## Cons

Someone can hide an import behind a string. That is rare next to a normal import.

## Alternatives

Semgrep rules for the same imports. import-linter is the tool for layering. Semgrep stays the security scanner. Do not duplicate the layer rules there.
