---
name: wire-module-cicd
description: >-
  Wire a New Age module or FastAPI service into shared CI/CD: ci-workflows
  callers, deepilot telemetry, GHCR images, promote to helm-charts, Argo CD
  apps, previews, Grafana/Prometheus probes, and local Compose. Uses auth-service
  as the reference implementation. Invoke with /wire-module-cicd when onboarding
  a repo to pipelines after new-module or when migrating legacy CI.
disable-model-invocation: true
---

# Wire module CI/CD (New Age)

Bring a **service repository** up to the same CI/CD bar as **`auth-service`**
(reference) and **`platform-api`** (API-only variant). This skill does **not**
scaffold business logic — run **`new-module`** or **`design-module`** first when
the repo is empty.

**Living docs:** [plans/CICD-PROGRESS.md](../../plans/CICD-PROGRESS.md),
[ci-workflows/README.md](https://github.com/Deepidoo-s-new-age/ci-workflows/blob/main/README.md),
[helm-charts/docs/deploying.md](https://github.com/Deepidoo-s-new-age/helm-charts/blob/main/docs/deploying.md).

**File-by-file map:** [reference.md](reference.md).

## Choose a profile

| Profile | Reference | When |
|---|---|---|
| **A — API + admin UI** | `auth-service` | FastAPI under `backend/` + Vue admin under `frontend/`, two GHCR images, dual promote |
| **B — API only** | `platform-api` | Single FastAPI tree (`backend/` or repo root), one image, single promote |
| **C — Business module** | A or B + `docs/module.yaml` | Same CI as A/B; Helm names follow `<module-id>-backend` / optional `frontend-web` |

Previews use **`ci-workflows` `preview.yml`** (pin `ci-v1.0.13+`); promote remains **per repo** (helm-charts digest PRs). Copy `ci-workflows/examples/preview-service.yml` or `auth-service` / `platform-api` callers.

## Hard rules

1. Organization **`Deepidoo-s-new-age`** only — reusable workflows refuse other owners.
2. Pin **`ci-workflows`** tags in callers — never `@main` in production callers.
3. **`deepilot`** in `[project].dependencies` (not dev-only). CI runs `python -m deepilot.probe`.
4. **`docs/module.yaml`** filled for business modules; architecture job compares routes.
5. **No secrets in git** — inert placeholders in values; real JWT via `runtime-env` in prod.
6. **Deployments only in `helm-charts`** — service repos push images + open digest PRs, never `kubectl`.
7. Ask the user before creating **GitHub repository secrets** or org settings (tokens).

## Workflow

```
- [ ] 0 — Profile, names, and secrets
- [ ] 1 — Python / uv baseline (if API)
- [ ] 2 — deepilot + /health
- [ ] 3 — GitHub Actions callers (ci-workflows)
- [ ] 4 — Docker / GHCR
- [ ] 5 — Architecture, OpenAPI, coverage
- [ ] 6 — Optional Vue CI
- [ ] 7 — helm-charts (preprod + prod + helmfile)
- [ ] 8 — Observability (values + alerts + uptime probe)
- [ ] 9 — Preview (optional)
- [ ] 10 — Local stack (optional)
- [ ] 11 — Repo hygiene
- [ ] 12 — Verification
```

Do not merge Helm digest PRs or touch production without the user naming blast radius.

---

## Phase 0 — Profile, names, secrets

Collect and fix in the synthesis before editing:

| Field | Example (auth) | Notes |
|---|---|---|
| GitHub repo | `auth-service` | |
| Image base | `auth-service-backend` | GHCR: `ghcr.io/deepidoo-s-new-age/<name>` |
| `DEEPILOT_SERVICE_NAME` | `auth-service` | Matches Prometheus `service_name` |
| K8s release | `auth-service-backend` | `charts/backend` releaseName |
| Ingress host slug | `auth-service` | sslip.io pattern in values |
| DB schema | `auth` | Postgres + migrate job |

**Repository secrets** (create in GitHub → Settings → Secrets):

| Secret | Used by |
|---|---|
| `SCHEMAS_READ_TOKEN` | Clone `deepidoo-contracts`, `deesplay`; BuildKit `github_token`; npm auth for frontend image |
| `HELM_CHARTS_TOKEN` | Promote job — PAT with **only** `helm-charts` Contents + Pull requests (read/write) |

Confirm `GITHUB_TOKEN` can read sibling private repos if `SCHEMAS_READ_TOKEN` is unset in CI.

---

## Phase 1 — Python / uv baseline (if API)

In the directory that holds `pyproject.toml` + `uv.lock` (usually `backend/`):

- Python **3.12**, **uv** `0.12.23`, `uv sync --frozen --all-groups` locally.
- **`deepidoo-contracts`** pinned via **git tag** in `pyproject.toml` / lock (not editable path in prod image).
- **Ruff** + **pytest**; optional **`[tool.importlinter]`** (see `auth-service` `pyproject.toml`).
- **`coverage-baseline.txt`** — one decimal floored %; commit next to `pyproject.toml` when using `coverage_source` in CI.
- **`.env.example`** with inert URLs and `DEEPILOT_*` variables documented.

**Dockerfile** (prod): match `auth-service/backend/Dockerfile` — `python:3.12.15-slim-trixie`, `uv==0.12.23`, `uv sync --frozen --no-dev`, BuildKit secret `github_token`, `CMD` via `.venv/bin/uvicorn` (no `uv run` in image).

---

## Phase 2 — deepilot + `/health`

1. Add `deepilot>=0.1.6` (or current tag) to **dependencies**; git source in `[tool.uv.sources]` if org convention requires it.
2. In `app/main.py` (pattern from `auth-service`):

   - `from deepilot import TelemetrySettings, install, settings_from_env, …`
   - After `FastAPI()` and routers: if `DEEPILOT_SERVICE_NAME` set → `install(app, settings_from_env())`, else local `TelemetrySettings` for dev.
   - Instrument Redis/SQLAlchemy **after** startup DB work (lifespan), not before.

3. Expose **`GET /health`** without requiring live DB for the CI probe (probe does not run lifespan).

4. Local check: `DEEPILOT_CI_PROBE=1 DEEPILOT_SERVICE_NAME=ci uv run python -m deepilot.probe app.main:app`.

---

## Phase 3 — GitHub Actions (`ci-workflows`)

Create `.github/workflows/ci.yml`. Copy structure from **`auth-service/.github/workflows/ci.yml`** (profile A) or **`platform-api/.github/workflows/ci.yml`** (profile B).

**Pin these tags** (update only when [ci-workflows/README](https://github.com/Deepidoo-s-new-age/ci-workflows/blob/main/README.md) says so):

| Job | Workflow | Tag |
|---|---|---|
| `test` | `python-service.yml` | `ci-v1.0.10` |
| `architecture` | `architecture.yml` | `ci-v1.0.9` |
| `security` | `security.yml` | `ci-v1.0.6` |
| `web` (Vue) | `vue-app.yml` | `ci-v1.0.5` |
| `backend-image` | `image.yml` | `ci-v1.0.12` |

**Caller inputs** (adjust per repo):

- `working_directory`: `backend` or `.`
- `checkout_contracts: false` when lockfile uses git tag for contracts
- `coverage_source: app` when ratchet is ready
- `telemetry_app`: `app.main:app` if layout differs

Grant job permissions: `test` → `actions: write`; image jobs → `packages: write`; `web` → `packages: read`.

**Promote job:** copy from reference; set branch `promote/<service>`, values paths, and `HELM_CHARTS_TOKEN` script. Profile A updates **two** digest files; B updates one.

Libraries without FastAPI use **`python-package.yml`** — no deepilot probe.

---

## Phase 4 — Docker / GHCR

- Image name = workflow `image_name` (e.g. `auth-service-backend`).
- `push: true` only on `push` to `main`; PRs build without push.
- `backend-image` `needs: [test, architecture, security]` (+ `web` if present).
- Frontend image (profile A): often a **custom job** in `ci.yml` (clone `deesplay`, npm secret) — see `auth-service` `frontend-image` job; not yet a single reusable workflow for all modules.

Package visibility: org GHCR; cluster needs `ghcr` pull secret (already on shared cluster).

---

## Phase 5 — Architecture, OpenAPI, coverage

For HTTP services:

1. **`docs/module.yaml`** — route groups match FastAPI (business modules).
2. **`docs/openapi.json`** — committed; regenerated in CI (`ci-v1.0.8+` same-commit compare).
3. **`docs/architecture-baseline.txt`** — one waiver per line for known gaps until YAML catches up (foundations use this heavily).
4. Run locally: clone `.github` and run `tools/validate_architecture.py --mode check` with the same paths the architecture workflow uses.

Import-linter: add contracts to `pyproject.toml` when enforcing handler boundaries.

---

## Phase 6 — Optional Vue CI (profile A / module UI)

- `vue-app.yml` with `working_directory: frontend` or `frontend-web`.
- `frontend/.npmrc`: scope registry, `legacy-peer-deps` if needed, `packages_read_token` secret.
- `run_build: false` until clean production build in CI.
- **dependency-cruiser** in web job when `auth-service` pattern is required.

Module **`frontend-web/`** (Deesplay): same job shape; image build may follow `vue-image.yml` when a reusable path exists — until then document deviation.

---

## Phase 7 — `helm-charts`

Edit **`helm-charts`** in a **separate PR** (often opened by promote, but **first deploy** needs manual scaffolding):

1. **Values** — four files per API (+ frontend if any):
   - `environments/preproduction/<image>.values.yaml`
   - `environments/production/<image>.values.yaml`
   - `environments/preview/<image>.values.yaml` (if previews)

   Copy from `auth-service-backend.values.yaml`. Set:
   - `image.repository`, empty or pinned `digest`
   - `env` + **`DEEPILOT_*`** endpoints (`tempo`, `loki`, `prometheus` in namespace)
   - `ingress.host`, `probes.path: /health`
   - `migrate` / `seed` blocks when the image contains Alembic / seed commands

2. **`environments/{preproduction,production}/helmfile.yaml`** — add migrate + backend (+ frontend) releases with `needs` on postgres/redis/telemetry like existing services.

3. **`argocd/apps/applications.yaml`** — `preproduction-<service>` and `production-<service>` Applications (multi-source: backend, optional job seed, optional frontend, `ref: values`). Set **sync-wave** after `platform-api` when the module seeds data that others depend on (see comments on `preproduction-auth-service`).

4. **`helm-charts/.github/workflows/promote-production.yml`** — add checkbox + service list entry when the module reaches production.

5. **Postgres** — if new schema: `charts/postgres` init or app startup `CREATE SCHEMA` (document in values/README).

Run `helm-charts` CI locally if possible: helmfile render / kubeconform per repo docs.

---

## Phase 8 — Observability

1. **Deployment env** — same `DEEPILOT_*` as preproduction values (already in phase 7).

2. **Uptime / blackbox** — `environments/preproduction/prometheus.values.yaml` → `externalProbes`:
   add `{ service: <name>, url: http://<ingress>/health }`.

3. **5xx alert** — `charts/prometheus/rules/server-errors.yaml`:
   duplicate `AuthServiceServerError` rule with `service_name="<DEEPILOT_SERVICE_NAME>"`.

4. **Grafana** — dashboards `service.json`, `errors.json`, `uptime.json` use label `service_name`; new services appear automatically once metrics flow. No JSON edit unless custom panels are required.

5. **Local parity** — `.github/local/otel/` dashboards and `prometheus.yml` probes: add probe + compose env for `DEEPILOT_*` when using **`add-compose-service`**.

---

## Phase 9 — Preview (optional)

Only if the module needs PR namespaces:

1. **`preview.yml`** — copy `ci-workflows/examples/preview-service.yml`, set `service_id`, image names, and optional `build_frontend`; pin `@ci-v1.0.13` after the tag exists.
2. **`argocd/apps/preview-applicationsets.yaml`** — new ApplicationSet (copy `preview-auth-service` block). Each preview namespace is a **preproduction lookalike**: Postgres, Redis, existing foundations at **companion** digests, PR service at **`head_sha`**, migrate+seed, in-cluster service URLs.
3. **`environments/preview/companion-*.values.yaml`** — preproduction digest; promote runs `sync_companion_digests.py` in the service promote job.
4. **`charts/preview-namespace/values.yaml`** / **`preview-sweeper`** — add repo name to allowed set; raise quota if the stack grows.
5. Label **`preview`** on PR; several labeled PRs may run **concurrently** (one namespace each).

**auth-service**: backend + frontend on the PR; **platform-api**: backend on the PR. Both ApplicationSets today also deploy the **other** foundation as companion.

Document in `helm-charts/docs/previews.md` when behavior differs.

---

## Phase 10 — Local stack (optional)

Run **`add-compose-service`** to add API/UI to `.github/local/docker-compose.yml`, `repos.tsv`, `dev-*.yml` overlay, Traefik host, `DEEPILOT_*` in compose env.

---

## Phase 11 — Repo hygiene

- **`CODEOWNERS`** — e.g. `* @Deepidoo-s-new-age/devs`
- **`renovate.json`** — narrow bumps (auth only enables `deepidoo-contracts` + deesplay)
- Remove legacy **`docker.yml`** / duplicate CI if present
- **No repo-local `docker-compose.yml`** once the service is in `helm-charts` and `.github/local` (local = workspace compose + `overlays/dev-*.yml` only)
- README: link to deploying docs and required secrets

---

## Phase 12 — Verification

| Check | How |
|---|---|
| CI green on PR | All reusable jobs pass, including Telemetry |
| Image on `main` | GHCR tag = git sha |
| Promote PR | Opened in `helm-charts` with digest |
| Argo sync | Application Healthy after merge |
| `/health` via Ingress | 200 |
| Grafana Service dashboard | `service_name` dropdown lists the service after traffic |
| Preview | Label `preview` → pr-* URL 200 (if enabled) |

Report **tag pins**, **open PR URLs**, and **debt** (rulesets on Free plan, missing Alembic, preview not configured) separately from completed work.

## Related skills

| Skill | Role |
|---|---|
| `new-module` | Contract + skeleton before CI |
| `add-compose-service` | Local Compose only |
| `setup-local` | Clone workspace |
| `update-module-contract` | After route changes |

## Out of scope unless asked

- GitHub rulesets / branch protection (org plan limits)
- SOPS / External Secrets (phase 9 supply chain)
- `scheduler` Celery worker charts (see RULE-GLOBAL-SCHEDULER)
- Scopes in `auth-service` / Play integration
