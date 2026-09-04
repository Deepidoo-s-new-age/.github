# Future CI validation — module contracts, routes and scopes

No CI control is enabled now. This document describes a later implementation path.

## Goal

Detect architecture drift automatically:

- a route exists but is absent from its module contract;
- an API group or UI route in the YAML lacks `purpose`, `actors`, `access`/`api_groups` or `source`;
- a protected route requires an unknown or unassignable scope;
- a module calls a platform route without declaring it;
- a production UI route has no declared owning module;
- a shared contract breaks consumers without a version change.

## Proposed validator

Create one small Python package/script, for example `tools/validate_architecture.py`, that reads:

1. `{module-repo}/docs/module.yaml` against `contracts/docs/module-contract.TEMPLATE.yaml`;
2. FastAPI OpenAPI documents generated in test mode;
3. `auth-service` permission seed/database export;
4. `playdoo` route metadata exported as JSON;
5. the installed `deepidoo-contracts` version declared by each Python service.

The script should produce deterministic JSON plus a human-readable error list and exit non-zero on violations.

## Checks

### Module schema

- Validate every YAML file against one JSON Schema.
- Enforce unique `module_id`, API route ownership and owned aggregate names.
- Require `purpose`, `actors`, `access`/`api_groups` and `source` on every API group and UI route.
- Require both current and target state when they differ.

### API routes

- Generate OpenAPI without starting production dependencies.
- Compare route prefixes and required authorization metadata with the owning module YAML.
- Reject duplicate ownership or undocumented inter-service routes.

### Permissions

- Extract every `CrudRouter(resource=...)` and explicit scope dependency from `platform-api`.
- Compare with assignable permissions from `auth-service`.
- Verify module grants cover only declared outbound calls.
- Initially warn on missing frontend scopes; make this blocking only after frontend enforcement exists.

### Frontend

- Export Vue route name, path, feature owner, licences, organisation flags and future `requiredScopes`.
- Verify every production module route maps to one module contract.
- Keep licences/flags separate from security scopes.

### Shared contracts

- Compare the public API or generated schema of `deepidoo-contracts` against the previous release.
- Require a major version for breaking changes.
- Test each declared consumer against the candidate package version.

## Suggested rollout

1. Local report-only command with a committed baseline of known gaps.
2. CI warning job on pull requests.
3. Block only newly introduced drift.
4. Remove baseline gaps incrementally.
5. Make all checks blocking once Play route-scope enforcement and permission catalog alignment are complete.

## Placement options later

- Cross-repository validator: a dedicated architecture repository or reusable GitHub Action.
- Repository adapters: small scripts that export OpenAPI/routes/scopes in each repo.
- Central result: one artifact containing module, route and permission graphs.

Do not centralize runtime authorization in this validator. It verifies contracts; `auth-service` remains the runtime authority.
