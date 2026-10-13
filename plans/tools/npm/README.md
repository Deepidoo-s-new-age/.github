# npm, Yarn, and pnpm

The French version is [README.fr.md](README.fr.md).

## Purpose

Install JavaScript dependencies from the lockfile the repo already commits, then audit them.

## Problem it resolves

`npm install` without a lock can change versions between two CI runs. An unaudited lock keeps a known vulnerable package until someone notices.

## How we use it

Phase 0, `vue-app.yml`. The workflow looks at the lockfile in `working_directory`:

| Lockfile | Install |
|---|---|
| `package-lock.json` | `npm ci` |
| `yarn.lock` | `yarn install --frozen-lockfile` |
| `pnpm-lock.yaml` | `pnpm install --frozen-lockfile` |

No lockfile fails the job. Audit fails on high and critical: `npm audit --audit-level=high`, or the Yarn or pnpm equivalent.

`auth-service` frontend uses npm and `package-lock.json`. The job stays off until phase 4, because that lockfile links `file:../../deesplay`. After deesplay is a GitHub Package, the workflow needs `.npmrc` and `NODE_AUTH_TOKEN`.

## Installation

The runner gets Node from `actions/setup-node@v4`. npm ships with that Node. Yarn or pnpm is enabled when the lockfile asks for it, through Corepack or that package manager’s own installer. `npm ci`, or the frozen Yarn or pnpm install, fills `node_modules` on the runner. The API image leaves that tree behind. A frontend image, if one is added later, would carry its own build output.

## Constraints

`npm audit` reports the npm advisory database, not OS packages and not Python. Yarn v1 audit exit codes are a bitmask and can fail for lower severities. Prefer npm for new frontends so the audit command stays the one in this table.

## Pros

The lockfile is the contract. `npm ci` deletes `node_modules` and matches it.

## Cons

Audit noise on transitive packages. Renovate is how the bump happens. The audit is only the gate.

## Alternatives

Running all three package managers in one repo. One lockfile per frontend. The workflow accepts whichever the repo already chose.
