# Alembic

The French version is [README.fr.md](README.fr.md).

## Purpose

Apply the service’s database migrations as part of the release, using the same image digest as the new pods.

## Problem it resolves

A new pod that expects a column the database does not have crashes. A migration run by hand from a laptop is not the digest that was tested. Each service owns its schema. There is no cross-service foreign key to order migrations for us.

## How we use it

Phase 6. The Helm release runs Alembic as a Job or a Helm hook before the new pods take traffic: `alembic upgrade head`, image set to the digest being promoted. The migration has to tolerate the previous app version still running during the rollout.

## Installation

A Python dependency of each service that owns a database, already in that service’s `pyproject.toml` and `uv.lock`, so it ships inside the service image. The migration Job runs that same image and digest.

## Constraints

A migration that locks a large table or drops a column the old pods still read will take the service down. Expand, then contract, across two releases. The Job uses the service’s env and secrets. It does not get a second database URL.

## Pros

The migration and the code are the same build. A failed migration stops the rollout.

## Cons

A failed Job needs a human to read the logs and decide whether to roll back the digest. The pipeline does not invent a down migration automatically.

## Alternatives

Starting the migration inside every replica’s entrypoint. That races. One Job per release is the pattern.
