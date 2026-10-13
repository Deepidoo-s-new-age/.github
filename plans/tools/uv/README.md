# uv

The French version is [README.fr.md](README.fr.md).

## Purpose

Install Python, resolve dependencies, and install exactly what `uv.lock` records.

## Problem it resolves

Services already use uv and a lockfile (`auth-service`, `deepidoo-contracts`). A CI job that runs `pip install` from `pyproject.toml` can install different versions than a developer’s machine.

## How we use it

Phase 0, in `python-service.yml` and `python-package.yml`. Pin the setup action `astral-sh/setup-uv@v10.2.0` and uv `0.12.23`. Python 3.12. Command: `uv sync --frozen --all-groups`, then `uv run` for ruff, pytest, and pip-audit. `--frozen` fails if the lockfile is out of date.

Until phase 3, service lockfiles point at `../../contracts`. The workflow clones `deepidoo-contracts` onto that path before `uv sync`.

## Installation

The runner installs it with the GitHub Action `astral-sh/setup-uv@v10.2.0`, pinned to uv `0.12.23` and Python 3.12. Laptops use the same uv. The service image contains the packages `uv sync` resolved, and the uv binary stays on the runner.

## Constraints

The lockfile format must match the pinned uv. A newer lock committed from a developer’s uv can fail `--frozen` on 0.12.23. Bump the pin in the shared workflow when that happens, in one place.

## Pros

Same installer locally and in CI. One lockfile for the app and the dev group.

## Cons

Path dependencies (`editable = "../../contracts"`) need a checkout CI cannot do with `actions/checkout` alone. That goes away when contracts is a published version.

## Alternatives

pip with a requirements file, Poetry, PDM. The repos are already on uv. Do not add a second Python installer.
