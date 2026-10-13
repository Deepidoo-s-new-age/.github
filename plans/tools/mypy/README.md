# mypy

The French version is [README.fr.md](README.fr.md).

## Purpose

Check Python type annotations and catch calls that pass the wrong shape.

## Problem it resolves

Ruff does not know that a function expects a UUID and received a string. Typed services fail that class of bug before review.

## How we use it

Not in phase 0. `auth-service` and `deepidoo-contracts` have no mypy config today. Add an input `run_mypy` on `python-service.yml`, default false. A repo turns it on when `mypy` is clean on `main` and the config lives in that repo’s `pyproject.toml`.

## Installation

An optional dev dependency in the repo’s uv group, locked in `uv.lock`. `uv sync` installs it in repos that set `run_mypy`. The shared workflow leaves the input off until that config exists.

## Constraints

Turning it on for a repo that has never been typed makes the pull request red for old code. Do not enable it as a surprise.

## Pros

Catches API mismatches between our own modules. Runs inside the existing uv environment.

## Cons

Strict mode is a project of its own. A loose config that ignores almost everything adds time and no signal.

## Alternatives

Pyright. Pick mypy once and use it from uv. Do not run both.
