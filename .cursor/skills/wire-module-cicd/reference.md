# wire-module-cicd — reference map

Canonical implementations: **`auth-service`** (profile A), **`platform-api`** (profile B).

## Service repository — profile A (`auth-service`)

| Path | Purpose |
|---|---|
| `.github/workflows/ci.yml` | `python-service`, `architecture`, `security`, `vue-app`, `image`, custom `frontend-image`, `promote` |
| `.github/workflows/preview.yml` | Thin caller → `ci-workflows` `preview.yml` (`ci-v1.0.13+`); PR label `preview` → GHCR `:sha` |
| `backend/pyproject.toml` | `deepilot`, contracts git pin, ruff, import-linter |
| `backend/uv.lock` | Frozen deps |
| `backend/coverage-baseline.txt` | Coverage ratchet floor |
| `backend/app/main.py` | `install()`, lifespan instrumentation order |
| `backend/Dockerfile` | Prod image, `uv sync --no-dev`, BuildKit `github_token` |
| `backend/.env.example` | `DEEPILOT_*`, DB, Redis |
| `docs/module.yaml` | Architecture validator input (foundations: baseline-heavy) |
| `docs/openapi.json` | Committed OpenAPI |
| `docs/architecture-baseline.txt` | Waived routes until YAML complete |
| `frontend/Dockerfile` | nginx SPA + proxy `/v1` |
| `frontend/.npmrc` | GH Packages for deesplay |
| `CODEOWNERS` | Review ownership |
| `renovate.json` | Dependency bot scope |

### `ci.yml` job graph (auth-service)

```
test ──┐
arch ──┼──► backend-image ──┐
sec ───┤                     ├──► promote (main only)
web ───┘                     │
       frontend-image ───────┘
```

### Promote targets (auth-service)

| File in `helm-charts` |
|---|
| `environments/preproduction/auth-service-backend.values.yaml` |
| `environments/preproduction/auth-service-frontend.values.yaml` |

Branch: `promote/auth-service`.

---

## Service repository — profile B (`platform-api`)

| Path | Notes |
|---|---|
| `.github/workflows/ci.yml` | No `web` / `frontend-image`; `working_directory: .`; single promote |
| `app/main.py` | Same deepilot pattern |
| `Dockerfile` | Context repo root |
| Promote file | `environments/preproduction/platform-api-backend.values.yaml` |
| Branch | `promote/platform-api-backend` |

---

## `ci-workflows` pins (current on `main` services)

| Component | Tag |
|---|---|
| `python-service.yml` | `ci-v1.0.10` |
| `architecture.yml` | `ci-v1.0.9` |
| `security.yml` | `ci-v1.0.6` |
| `vue-app.yml` | `ci-v1.0.5` |
| `image.yml` | `ci-v1.0.12` |

Examples to copy before customization:

- `ci-workflows/examples/python-service.yml`
- `ci-workflows/examples/architecture.yml`
- `ci-workflows/examples/security.yml`
- `ci-workflows/examples/vue-app.yml`
- `ci-workflows/examples/image.yml`

---

## `helm-charts` — auth-service touchpoints

| Path | Purpose |
|---|---|
| `environments/preproduction/auth-service-backend.values.yaml` | Digest, env, migrate/seed, ingress, DEEPILOT |
| `environments/preproduction/auth-service-frontend.values.yaml` | Frontend digest, proxy to backend |
| `environments/production/*` | Same shape; digest from promote workflow |
| `environments/preview/*` | PR values + `companion-*` (preproduction digest); full-stack preproduction lookalike per `pr-*` namespace |
| `environments/preproduction/helmfile.yaml` | `auth-service-backend-migrate`, backend, (frontend in full file) |
| `environments/production/helmfile.yaml` | Production releases |
| `argocd/apps/applications.yaml` | `preproduction-auth-service`, `production-auth-service` |
| `argocd/apps/preview-applicationsets.yaml` | `preview-auth-service` generator |
| `argocd/apps/preview-sweeper.yaml` | Repo allowlist |
| `environments/preproduction/prometheus.values.yaml` | `externalProbes` auth ingress URL |
| `charts/prometheus/rules/server-errors.yaml` | `AuthServiceServerError` alert |
| `charts/grafana/dashboards/*.json` | Generic `service_name` templates |
| `.github/workflows/promote-production.yml` | `auth-service` checkbox |

### Values snippet — telemetry env (cluster)

```yaml
DEEPILOT_SERVICE_NAME: auth-service
DEEPILOT_ENVIRONMENT: preproduction
DEEPILOT_TEMPO_ENDPOINT: http://tempo:4318
DEEPILOT_LOKI_ENDPOINT: http://loki:3100/otlp
DEEPILOT_PROMETHEUS_ENDPOINT: http://prometheus:9090/api/v1/otlp
```

### Argo CD Application sources (preproduction-auth-service)

1. `charts/backend` → `auth-service-backend.values.yaml`
2. `charts/job` → seed (when enabled)
3. `charts/frontend` → `auth-service-frontend.values.yaml`
4. `ref: values` for `$values/...` paths

Sync wave **2** (after `platform-api` wave **1**).

---

## deepilot probe (CI)

Invoked by `python-service.yml` step **Telemetry**:

```bash
DEEPILOT_SERVICE_NAME=ci DEEPILOT_ENVIRONMENT=ci \
  uv run python -m deepilot.probe app.main:app
```

Failures: missing dependency, no `install()`, no span/log on `GET /health` (default path).

Implementation: `deepilot/src/deepilot/probe.py`.

---

## Local stack (`.github/local`)

**Policy:** no `docker-compose.yml` in service repos — only this workspace file + overlays.

| Path | Purpose |
|---|---|
| `local/docker-compose.yml` | All wired apps (auth, platform, modules), Traefik labels |
| `local/overlays/dev-auth.yml` | DEV mounts `contracts` + `deepilot` |
| `local/overlays/dev-platform.yml` | Same pattern for platform-api |
| `local/otel/prometheus.yml` | Blackbox / health probes |
| `local/otel/grafana/dashboards/` | Parity with cluster Grafana JSON |

Skill: **`add-compose-service`**.

---

## Business module naming cheat sheet

When wiring **DeepiVoice**, **DeepiFlow**, etc.:

| Concept | Pattern |
|---|---|
| Repo | `deepivoice`, `deepiflow`, … |
| GHCR image | `<repo>-backend` or match existing convention |
| `DEEPILOT_SERVICE_NAME` | Short product id (`deepivoice`) — stable in metrics |
| Helm release | `<image-name>` without `ghcr.io` prefix |
| Module contract | `docs/module.yaml` **required** for architecture gate |

If the module is **`design_mode: frontend_only`**, stop before phases 1–4 (backend/deepilot) unless the user clears design mode.

---

## Checklist export (paste in PR description)

```markdown
### CI/CD wiring
- [ ] ci.yml pins ci-v1.0.10 / v1.0.9 / v1.0.6 / v1.0.12
- [ ] deepilot in dependencies + install() in main
- [ ] coverage-baseline.txt
- [ ] docs/module.yaml + openapi.json + architecture-baseline.txt
- [ ] Dockerfile prod + SCHEMAS_READ_TOKEN documented
- [ ] HELM_CHARTS_TOKEN + promote job
- [ ] helm-charts values (preprod/prod/preview)
- [ ] helmfile + Argo Application
- [ ] prometheus externalProbes + server-errors rule
- [ ] preview.yml + ApplicationSet (if applicable)
- [ ] `.github/local` compose + `dev-*.yml` (no repo `docker-compose.yml`)
```
