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

Previews use **`ci-workflows` `preview.yml`** (pin **`ci-v1.0.14`**); promote remains **per repo** (helm-charts digest PRs). Copy `ci-workflows/examples/preview-service.yml` or `auth-service` / `platform-api` callers.

## Hard rules

1. Organization **`Deepidoo-s-new-age`** only — reusable workflows refuse other owners.
2. Pin the tag from the table in phase 3 — never `@main`, and never an older `ci-v1.0.*` tag copied from history. Image jobs are **`ci-v1.0.21`**; every other reusable workflow stays **`ci-v1.0.14`**. The tag is created on `ci-workflows` `main` with **Actions → Tag ci release** after that commit merges. A caller that names the tag fails until the tag exists.
3. **`deepilot`** git tag **`v0.1.7`** (or newer) in `[project].dependencies`, not dev-only. `0.1.6` crashes when `httpx` is absent. CI runs `python -m deepilot.probe`.
4. **`deepidoo-contracts`** git tag is the tag on `auth-service` `main` today (`v0.2.0`). Do not copy `v0.1.0` from old progress notes.
5. **`docs/module.yaml`** filled for business modules; architecture job compares routes. If `design_mode: frontend_only`, stop. Do not add backend, images, or Helm until the user clears that flag.
6. **No secrets in git** — inert placeholders in values; real JWT via `runtime-env` in prod.
7. **Deployments only in `helm-charts`** — service repos push images + open digest PRs, never `kubectl`. Delete a repo-local `docker-compose.yml` and any Helm chart inside the module repo once `.github/local` and `helm-charts` own them.
8. Ask the user to create both module repository secrets in phase 0 (`SCHEMAS_READ_TOKEN`, `HELM_CHARTS_TOKEN`). Do not create the tokens, and do not put token values in git. Link the GHCR package to the repository so `packages: write` can push.
9. Caller job ids are **`backend-image`** and **`frontend-image`**. Promote reads `needs.<job>.outputs.digest`.
10. Helm values use an **image digest**. `image.yml` also pushes `:latest`; nothing in values may reference it.
11. **One process per Deployment.** A Celery worker is not the API chart. Scheduler charts stay out of scope (RULE-GLOBAL-SCHEDULER).
12. Do not add this image to `tools/sync_companion_digests.py` `PAIRS` unless other previews run it as a companion. A missing companion file makes every auth and platform promote fail.
13. Read workflows and charts from a current `main` checkout, as a sibling of the service repo. Clone when the directory is missing; otherwise `git checkout main` and `git pull` before use. Stop if that checkout would discard uncommitted work.
    - **`ci-workflows`** — `https://github.com/Deepidoo-s-new-age/ci-workflows.git`, before reading `README.md`, `examples/`, or a reusable workflow.
    - **`helm-charts`** — `https://github.com/Deepidoo-s-new-age/helm-charts.git`, before creating or editing a chart, values file, helmfile release, or Argo app.

## Existing repository

Do this before phase 1 when the repo already has code and is not on this plan:

1. Read `docs/module.yaml`. `design_mode: frontend_only` stops the rest of this skill.
2. Inventory and remove, in the same change, the old pipeline: extra workflows, a second image publisher, a repo `docker-compose.yml`, and in-repo Helm. Deploys stay in `helm-charts`.
3. Match the tree to the workflows. `image.yml` builds `<context>/Dockerfile` unless `dockerfile` is set, and that path must end with `Dockerfile`. UI is `frontend` or `frontend-web`: set `vue-app` `working_directory`, the image `context`, and preview `frontend_context` to that directory.
4. BuildKit secret id must match the Dockerfile. `vue-image.yml` `secret_id` defaults to `github_token` and `mount_secret` defaults to true. Set `mount_secret: false` when the Dockerfile mounts no secret. A `file:` dependency on deesplay sets `clone_deesplay: true` on **both** `vue-image.yml` and preview (`auth-service` does this and mounts no secret). A UI that does not use deesplay leaves `clone_deesplay` false. Do not copy the Trivy, syft, or cosign steps into the caller.
5. Bootstrap gates from the current tree, in order. Measure coverage and commit `coverage-baseline.txt` before `coverage_source`. Put every existing route in `docs/module.yaml` or `docs/architecture-baseline.txt` before the architecture job is required. Commit `docs/openapi.json` from the generator the architecture workflow runs. Fix `pip-audit` and Semgrep by bumping dependencies. Do not disable the security job. Add import-linter only when the boundaries already pass.
6. Wire runtime env the charts need: in-cluster URLs for auth-service and platform-api, JWT via `deepidoo-contracts`, the module Postgres schema, the Redis DB index, and `DEEPILOT_*`. `GET /health` must answer without a database. An empty digest must skip the release (same pattern as the frontend chart) so the first Argo sync is not a crash.
7. Copy migrate and seed blocks only when the image contains those commands.
8. A new preview needs the repo in `PREVIEW_REPOS`, the sweeper ConfigMap (re-embed `tools/preview_sweeper.py`), an ApplicationSet, and a quota check. Foundations at companion digests; this service at `head_sha`.

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

**Ask the user to create both Actions secrets** on the module repository (Settings → Secrets and variables → Actions → Repository secrets). Do this before editing workflows. Do not create the tokens, do not accept a pasted token value, and do not continue past this phase until the user confirms both secrets exist or says they will create them before the first CI run.

| Secret | Token | Permissions | Used by |
|---|---|---|---|
| `SCHEMAS_READ_TOKEN` | **Classic** PAT. A fine-grained token cannot read GitHub Packages. | `repo` and `read:packages`. No `write:packages`. `repo` is required to clone private git dependencies and is broader than those repos. | `contracts_read_token` and `packages_read_token`: clone `deepidoo-contracts`, `deepilot`, `.github`, and `deesplay`; BuildKit `github_token`; npm install of `@deepidoo-s-new-age/*`. `GITHUB_TOKEN` cannot replace it (`read_package` is denied). |
| `HELM_CHARTS_TOKEN` | **Fine-grained** PAT. Resource owner `Deepidoo-s-new-age`. Repository access: **only** `helm-charts`. | Contents read and write. Pull requests read and write. | Promote job only. The image still publishes when this secret is empty; the digest PR does not. |

The same token value may be stored on each module repository. One missing secret fails the jobs in that row only.

---

## Phase 1 — Python / uv baseline (if API)

In the directory that holds `pyproject.toml` + `uv.lock` (usually `backend/`):

- Python **3.12**, **uv** `0.12.23`, `uv sync --frozen --all-groups` locally.
- **`deepidoo-contracts`** pinned via the **git tag `auth-service` uses** (`v0.2.0` on 16 Nov 2026) in `pyproject.toml` / lock (not an editable path in the prod image).
- **Ruff** + **pytest**; optional **`[tool.importlinter]`** (see `auth-service` `pyproject.toml`).
- **`coverage-baseline.txt`** — one decimal floored % from a local run; commit it **before** setting `coverage_source`, or the first CI run fails the ratchet.
- **`.env.example`** with inert URLs and `DEEPILOT_*` variables documented.

**Dockerfile** (prod): match `auth-service/backend/Dockerfile` — `python:3.12.16-slim-trixie`, `apt-get upgrade` before installing git, `uv==0.12.23` only for `uv sync --frozen --no-dev`, then `pip uninstall -y uv`. BuildKit secret `github_token`. `CMD` via `.venv/bin/uvicorn` (no `uv run` in the image). Leave `uv` installed and Trivy fails the image job: 0.12.23 has a fixed critical advisory (`GHSA-hq85-5cpj-mr62`).

---

## Phase 2 — deepilot + `/health`

1. Add `deepilot` at git tag **`v0.1.7`** (or the newer tag `auth-service` pins) to **dependencies** and `[tool.uv.sources]`.
2. In `app/main.py` (pattern from `auth-service`):

   - `from deepilot import TelemetrySettings, install, settings_from_env, …`
   - After `FastAPI()` and routers: if `DEEPILOT_SERVICE_NAME` set → `install(app, settings_from_env())`, else local `TelemetrySettings` for dev.
   - Instrument Redis/SQLAlchemy **after** startup DB work (lifespan), not before.

3. Expose **`GET /health`** without requiring live DB for the CI probe (probe does not run lifespan).

4. Local check: `DEEPILOT_CI_PROBE=1 DEEPILOT_SERVICE_NAME=ci uv run python -m deepilot.probe app.main:app`.

---

## Phase 3 — GitHub Actions (`ci-workflows`)

Clone `ci-workflows` when it is not next to the service repo. When the clone exists, `git checkout main` and `git pull` before reading workflows. Create `.github/workflows/ci.yml` from that checkout. Copy structure from **`auth-service/.github/workflows/ci.yml`** (profile A) or **`platform-api/.github/workflows/ci.yml`** (profile B).

**Pin these tags** (update only when [ci-workflows/README](https://github.com/Deepidoo-s-new-age/ci-workflows/blob/main/README.md) says so):

| Job | Workflow | Tag |
|---|---|---|
| `test` | `python-service.yml` | `ci-v1.0.14` |
| `architecture` | `architecture.yml` | `ci-v1.0.14` |
| `security` | `security.yml` | `ci-v1.0.14` |
| `web` (Vue) | `vue-app.yml` | `ci-v1.0.14` |
| `backend-image` | `image.yml` | `ci-v1.0.21` |
| `frontend-image` | `vue-image.yml` | `ci-v1.0.21` |
| `preview` | `preview.yml` | `ci-v1.0.14` |
| library test | `python-package.yml` | `ci-v1.0.14` |
| library release | `python-release.yml` | `ci-v1.0.14` |
| npm release | `js-package.yml` | `ci-v1.0.14` |

**Caller inputs** (adjust per repo):

- `working_directory`: `backend` or `.`
- `checkout_contracts: false` when lockfile uses git tag for contracts
- `coverage_source: app` when ratchet is ready
- `telemetry_app`: `app.main:app` if layout differs

Grant job permissions: `test` → `actions: write`; image jobs → `contents: read`, `packages: write`, and `id-token: write` (cosign on `main`); `web` → `packages: read`. GitHub keeps the intersection of the caller permissions and the called workflow. Missing `id-token: write` makes the sign step fail after a successful push.

**Promote job:** copy from reference; set branch `promote/<service>`, values paths, and `HELM_CHARTS_TOKEN` script. Profile A updates **two** digest files; B updates one.

Libraries without FastAPI use **`python-package.yml`** — no deepilot probe.

---

## Phase 4 — Docker / GHCR

- Image name = workflow `image_name` (e.g. `auth-service-backend`).
- `push: true` only on `push` to `main`; PRs build without push (`load: true` inside the reusable workflow).
- `backend-image` `needs: [test, architecture, security]` (+ `web` if present).
- Frontend image (profile A): `vue-image.yml`, not a custom job. `auth-service` sets `context: frontend`, `clone_deesplay: true`, `mount_secret: false`. A UI that installs from GitHub Packages keeps `mount_secret: true` and sets `secret_id` to the id the Dockerfile mounts (`github_token` or `npm_token`).
- `ci-v1.0.21` runs Trivy, syft, and cosign after the build. Trivy fails HIGH/CRITICAL findings that have a vendor fix (`--ignore-unfixed`). Upgrade OS packages in the Dockerfile (`apt-get upgrade` or `apk upgrade`) so fixed packages are not left in the base layer. A repository-root `.trivyignore` replaces the action default. syft writes a CycloneDX SBOM and does not fail the job. cosign signs the digest only when `push` is true.
- Do not vendor the supply-chain script or call `.github/actions/supply-chain-image` from the service repo. A relative action path resolves in the caller, which has no such action.

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

- `vue-app.yml` with `working_directory: frontend` or `frontend-web` (the directory that contains `package.json`).
- `frontend/.npmrc`: scope registry, `legacy-peer-deps` if needed, `packages_read_token` secret.
- `run_build: false` until clean production build in CI.
- **dependency-cruiser** in web job when `auth-service` pattern is required.

Module **`frontend-web/`**: same job shape, `vue-image.yml` `@ci-v1.0.21`. Final nginx image: match `auth-service/frontend/Dockerfile` — `nginx:1.30.6-alpine3.24` and `apk upgrade --no-cache`. `nginx:1.27-alpine` fails Trivy on fixed Alpine 3.21 findings. `push: false` on pull requests and `push` only on `main` are inputs of `vue-image.yml`; do not add a second publisher that pushes `:latest`.

---

## Phase 7 — `helm-charts`

Clone `helm-charts` when it is not next to the service repo. When the clone exists, `git checkout main` and `git pull` before creating a chart or values file. Edit that checkout in a **separate PR** (often opened by promote, but **first deploy** needs manual scaffolding):

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

1. **`preview.yml`** — copy `ci-workflows/examples/preview-service.yml`, set `service_id`, image names, `frontend_context` (`frontend` or `frontend-web`), `clone_deesplay`, and optional `build_frontend`; pin `@ci-v1.0.14`. API-only callers leave `build_frontend` false. **Run workflow** must still add the `preview` label (`label` uses `!cancelled()` so a skipped frontend job does not skip it).
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
| CI green on PR | All reusable jobs pass, including Telemetry. Every image `main` publishes was built on the PR (`push: false`) |
| Preview label | API-only **Run workflow** adds the `preview` label |
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
- SOPS / External Secrets (image Trivy, syft, and cosign are in `image.yml` / `vue-image.yml` `@ci-v1.0.21`, not here)
- `scheduler` Celery worker charts (see RULE-GLOBAL-SCHEDULER)
- Scopes in `auth-service` / Play integration
