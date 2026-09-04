# New Age — Bugbot / PR automation review rules

Used by Cursor Bugbot and the PR Automation agent. Project `.cursor/rules/*.mdc`
do **not** apply to Bugbot — keep critical checks here.

Global architecture rules (SoT): https://github.com/Deepidoo-s-new-age/.github/tree/main/docs/rules

## Always

- New Age is a workspace of **independent Git repos**, not one build monorepo.
- Dependency order: `contracts` → `auth-service` → `platform-api` → business modules.
- `auth-service` is the only JWT **issuer**. User JWT **validation** goes through `deepidoo-contracts`. Never duplicate decode/issuer/jti logic.
- Inter-service communication uses HTTP + UUIDs. Never import another service's application code. Never access another service's database or create cross-service SQL FKs.
- Never commit secrets, tokens, dumps, kubeconfigs or production data.
- Do not invent a stricter authorization policy than the code implements.
- Prefer least privilege. No wildcards / admin scopes to make a request pass.
- Report current debt separately from the target. Do not claim migration completion falsely.
- Package name is `deepidoo-contracts` — never `deepidoo-schemas` / `schemas` as the shared package.

## Business modules (`docs/module.yaml`)

Applies when the repo is (or should be) a business module (e.g. `play_music_ai`).

- Canonical contract: `{module-repo}/docs/module.yaml`. Template only lives in `contracts/docs/module-contract.TEMPLATE.yaml`.
- Every backend `route_groups` entry needs `prefix`, `purpose` (1–2 sentences), `actors`, `access`, `source` (+ `downstream` when calling another service).
- Every frontend `routes` entry needs `path`, `purpose`, `actors`, `api_groups`, `source`.
- If a group is mixed or unprotected, say so (`mixed_by_endpoint`, `currently_unprotected`) — never invent stricter policy.
- Module `frontend-web/` is a production client when present; `playdoo` is not the mandatory shell for every module.
- When the PR changes routes, scopes, deps or owned data: **update `docs/module.yaml` on the same PR branch**.

## By repository type

### `contracts` / `deepidoo-contracts`

- Shared contracts + user JWT validation only. No HTTP routes, no Casbin, no filled module YAML.
- Breaking public API → major version + consumer migration.

### `auth-service`

- Owns login, refresh, revoke, module tokens, Casbin. No product business workflows.

### `platform-api`

- Owns `/v1` core resources. `CrudRouter` scopes `{resource}:read|write|delete` must be assignable in auth-service.
- No module-specific business workflows.

### `play_music_ai` (and future modules)

- Own module API + data + scopes. Read core via platform-api HTTP only.
- Keep YAML aligned with code (see section above).

### `play`

- Dependency `play` → `playdoo` → `deesplay`. Business UI in playdoo.
- Document `/api/v4` → `/v1` migrations; do not claim frontend JWT scope enforcement exists yet.

### `deesplay`

- Design-system source of truth. No routes, stores, auth or API clients in primitives.

### `helm-charts`

- Environment isolation, pinned images, secrets from secret store, name blast radius for prod changes.

### `persistence`

- No committing sensitive dumps. Respect DB ownership and Redis isolation. Destructive ops require explicit intent.

## Review output style

- Separate **blocking** vs **suggestions**.
- Cite files/paths. Prefer actionable fixes.
- For modules: if YAML drifts, either update it on the PR branch or mark blocking with the exact missing fields.
