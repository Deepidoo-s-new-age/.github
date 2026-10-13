# CI/CD plan — Deepidoo-s-new-age

Implementation plan for the pipeline discussed for this organization.
The French version is [CICD-PLAN.fr.md](CICD-PLAN.fr.md).

Inventory date: 9 October 2026. Re-check repository contents before starting a phase that touches a repo not opened in this workspace.

## 1. Purpose

Build one pipeline for every repository in `Deepidoo-s-new-age`:

- a pull request runs the same checks everywhere;
- `main` publishes one immutable image;
- preproduction and production run that same digest;
- a short-lived environment can be created for a pull request and removed when the pull request closes;
- production promotion is a reviewed change in `helm-charts`.

Service repositories test and publish. They do not deploy.

## 2. Locked decisions

1. **Registry.** An image built from a repository in this organization is `ghcr.io/deepidoo-s-new-age/<service>:<git-sha>`. The workflow uses that repository’s `GITHUB_TOKEN`. A repository that later moves in from `Deepidoo` follows the same rule after the move.
2. **Workflows.** Shared workflows live in `Deepidoo-s-new-age/ci-workflows`, a repository that contains only those workflows. GitHub requires the files under `.github/workflows/` inside that repository. A caller uses `Deepidoo-s-new-age/ci-workflows/.github/workflows/<file>.yml@<tag>`. The workflows are written for this organization’s layout (`backend/`, `frontend/` or `frontend-web/`, `deepidoo-contracts`, FastAPI, Vue, uv). Callers are repositories in `Deepidoo-s-new-age`. The workflows refuse any other `github.repository_owner`. `Deepidoo-s-new-age/.github` keeps the organization profile, the rules, and this plan.
3. **Environments.** `deepidoo-s-new-age/helm-charts` is the only source for preproduction, production, and short-lived environments. That repository does not exist yet. Service repositories do not store a kubeconfig and do not run `kubectl`.
4. **Same caller for every service.** `auth-service` is not a special deploy pilot. It gets the same thin caller as `platform-api` and future modules.
5. **One digest moves forward.** Preproduction and production run the digest that was tested. Promotion does not rebuild the image.
6. **Merge gates are deterministic.** Ruff, types, tests, audits, and the architecture validator decide whether a pull request is green. A review agent comments. A human merges. A human approves production.

`Deepidoo-s-new-age/ci-workflows` is the repository those callers read. Each reusable workflow written in phase 0 must refuse any other `github.repository_owner`. If that repository is private, GitHub also rejects a caller that cannot read it. Keep it readable by every repository in `Deepidoo-s-new-age`. The files must contain no secrets.

## 3. Current state

The shared workflows are on `main` in `Deepidoo-s-new-age/ci-workflows`, `ci.yml` is green, and the tag is `ci-v1.0.0`. Service repositories do not call them yet.

### On GitHub as of 8 October 2026

| Repository | Pipeline |
|---|---|
| `auth-service` | `.github/workflows/docker.yml` tags `ghcr.io/deepidoo/auth-service` and `ghcr.io/deepidoo/auth-service:<sha>`. Pushes fail with `denied: permission_denied: read_package` because the repo is in `Deepidoo-s-new-age` and the image name is in the other organization |
| `platform-api` | `.github/workflows/docker.yml` tags `ghcr.io/deepidoo/platform-api`. Same cross-org denial |
| `deepidoo-contracts` | No workflow. Version `0.1.0`. Consumed as a path or a git checkout, not as a published package |
| `menuboards`, `deep_desk`, `scheduler`, `tickets`, `roadmap`, `epaper` | No `.github/workflows` |
| `messaging`, `call_me_maybe`, `converter` | Empty repositories |
| `Deepidoo/deesplay` | Yarn workspace. Package `@deepidoo/deesplay` at `packages/deesplay`. Version field `1.0.0`. No git tags, no GitHub releases, not on npm |
| `Deepidoo/helm_charts` | Helmfile for the legacy organization. Out of this plan until those workloads move |

`auth-service` frontend is an ACL admin UI (roles, permission matrix, bindings). It is run locally with `npm run dev`. No image contains it. It depends on `file:../../deesplay/packages/deesplay`, and Vite aliases `@deepidoo/deesplay` to that directory. The API image does not include this UI.

Play’s `playdoo` package already pins deesplay by git commit and Yarn workspace (`Deepidoo/deesplay#commit=…&workspace=@deepidoo/deesplay`). That syntax is Yarn-only. `auth-service` uses npm.

Nothing in CI runs lint, tests, secret scanning, coverage, OpenAPI diff, module-contract validation, image signing, an SBOM, Renovate, Helm, preview namespaces, or telemetry. SonarQube is not a merge gate.

## 4. Target

```text
pull request
  → shared CI (lint, types, tests, audit, secret scan, contract check)
  → merge to main
  → image ghcr.io/deepidoo-s-new-age/<service>:<git-sha>
  → pull request in helm-charts that sets that digest on preproduction
  → helmfile apply (preproduction environment)
  → pull request that copies the same digest to production
  → human approval, then helmfile apply
```

A preview namespace installs only the service that changed and points it at preproduction `auth-service` and `platform-api`. A pull request that changes those two, or `deepidoo-contracts`, is the case that deploys more than one release.

## 5. Tools

Use these. Do not add a second program that does the same job. A cheatsheet for each third-party program is in [tools/README.md](tools/README.md). The architecture validator and the Cursor review automation are ours; this plan describes them.

| Job | Tool | Where it runs |
|---|---|---|
| Workflow syntax | actionlint | `ci-workflows` `ci.yml`, created in phase 0 |
| Python format and lint | ruff | `python-service.yml`, `python-package.yml`, phase 0 |
| Python tests | pytest, uv | same, phase 0 |
| Python dependencies | uv lockfile, pip-audit | same, phase 0 |
| Python types | mypy | add when a repo has a clean config. Optional input, default off |
| Python import boundaries | import-linter | `python-service.yml`, after a baseline file exists |
| Secrets in the tree | gitleaks 8.30.1 | every shared workflow, phase 0 |
| Vue install and audit | npm, Yarn, or pnpm from the lockfile | `vue-app.yml`, phase 0 |
| Vue types | vue-tsc | `vue-app.yml` when the binary is installed, phase 0 |
| Vue import boundaries | dependency-cruiser | `vue-app.yml` when a config file exists, phase 0 |
| Frontend tests | the `test` script, Vitest when the repo adds it | `vue-app.yml` |
| OWASP code scan | Semgrep Community Edition: `semgrep scan --config p/owasp-top-ten --config p/python --config p/javascript` | `security.yml`, phase 5. Engine is LGPL 2.1. Registry rules are free for internal use |
| Vulnerable dependencies | pip-audit, `npm audit --audit-level=high`, Renovate | CI and a weekly PR |
| Module contract drift | `tools/validate_architecture.py` as specified in [CI-CONTRACT-VALIDATION.md](../docs/CI-CONTRACT-VALIDATION.md) | pull-request job, warning then blocking |
| API shape drift | oasdiff | same job, against the base branch OpenAPI |
| Package publish | GitHub Packages (Python and npm) | release workflows on a tag |
| Images | GHCR, tag = git sha, digest recorded in Helm | `image.yml` |
| Image contents | syft SBOM, cosign signature, Trivy on the built image | `image.yml`, phase 9. pip-audit does not see Debian packages in the runtime image |
| Deploy description | Helmfile in `helm-charts` | the only cluster writer |
| Apply and drift | Helmfile from a GitHub Environment, then Argo CD once two services deploy this way | `helm-charts` |
| Cluster policy | Kyverno | production cluster, after digests are the only tags |
| Secrets at runtime | SOPS or External Secrets, inert examples in git | `helm-charts` |
| Traces, logs, metrics | OpenTelemetry into Prometheus or Mimir, Loki, Tempo, Grafana | cluster plus each FastAPI app |
| Uptime | Gatus, probed from outside the cluster | same Grafana |
| SLO | Sloth or Pyrra | three user journeys |
| Quality dashboard | SonarQube Community Build | `main` only, optional, not a merge gate |
| Version bumps | Renovate, Release Please (or an equivalent that opens a release PR) | org-wide |
| Review comments | existing Cursor PR automation and Bugbot | already described in [PR-AUTOMATION.md](../docs/PR-AUTOMATION.md) |

SonarQube Community Build is free to self-host. It analyzes the main branch. Pull-request analysis and pull-request decoration require a paid edition. Community Build runs one analysis at a time. Its security rules are shallower than Semgrep, so it stays a quality dashboard and is not the OWASP scanner.

The current list is [OWASP Top 10:2025](https://owasp.org/Top10/2025/). Semgrep Community Edition is the code scanner for this pipeline: one job, no server, and it runs on private repositories. CodeQL is free only for public repositories. `auth-service` and `platform-api` are private, so CodeQL there is GitHub Code Security, which is paid. Community Edition analyzes one function at a time. Cross-file taint tracking is the paid Pro engine, so a bug that passes through several helpers can be missed.

| 2025 risk | Check |
|---|---|
| A01 Broken access control, including SSRF | Allowed and forbidden tests, plus the module-contract validator. Semgrep catches path traversal, open redirects, and obvious SSRF |
| A02 Security misconfiguration | kubeconform, then Kyverno (no floating tags, non-root, resource limits) |
| A03 Software supply chain failures | pip-audit, npm audit, Renovate, and Trivy on the built image |
| A04 Cryptographic failures | Semgrep, plus gitleaks. No JWT secrets in logs |
| A05 Injection | Semgrep. SQL stays in repositories, through SQLAlchemy |
| A06 Insecure design | Architecture validator. No cross-service SQL |
| A07 Authentication failures | auth-service tests and the scope check in the contract validator |
| A08 Software or data integrity failures | cosign, digest pinned in Helm |
| A09 Security logging and alerting failures | OpenTelemetry alerts, plus a Semgrep rule against logging `Authorization`, JWTs, or passwords |
| A10 Mishandling of exceptional conditions | Semgrep for fail-open and empty error handlers. The rest is review and tests |

## 6. Phases

Each phase has a finish line. Start the next phase when that line is true. Do not implement phase 8 in the same change as phase 1.

### Phase 0 — Write the shared workflows and put them on `main`

Create the repository `Deepidoo-s-new-age/ci-workflows` and add these files there, plus a `README.md` that explains how to call them. The repository contains the shared workflows, the example callers below, and that README. Paths are relative to that repository. GitHub loads workflow files from `.github/workflows/` inside a repository, so the reusable workflows use that directory. They are reusable workflows (`workflow_call`). Each one starts by failing when `github.repository_owner` is not `deepidoo-s-new-age`.

| File | Behavior |
|---|---|
| `.github/workflows/python-service.yml` | For a FastAPI service. Default `working_directory` is `backend`. Secret scan with gitleaks 8.30.1 (`--no-git`). Clone `Deepidoo-s-new-age/deepidoo-contracts` at the path recorded in `uv.lock` (today `../../contracts` from `backend/`), using `secrets.contracts_read_token` or the caller `GITHUB_TOKEN`. `astral-sh/setup-uv@v10.2.0` with uv `0.12.23` and Python 3.12. `uv sync --frozen --all-groups`, `ruff check`, `ruff format --check`, `pytest`. Export a requirements file, drop path lines, run `pip-audit`. Pytest receives inert env: `JWT_SECRET=ci-test-secret`, `JWT_ISSUER=deepidoo-auth`, `AUTH_DATABASE_URL`, `WEBAPP_DATABASE_URL`, `REDIS_URL` on localhost. Inputs allow overriding those values and turning the contracts checkout off |
| `.github/workflows/python-package.yml` | Same checks for a uv package at the repo root. No contracts checkout. Used by `deepidoo-contracts` |
| `.github/workflows/vue-app.yml` | Default `working_directory` is `frontend-web`. Detect npm, Yarn, or pnpm from the lockfile and install frozen. Run `lint`, `typecheck`, and `test` only when `package.json` defines them. If there is no `typecheck` script and `vue-tsc` is installed, run `vue-tsc --noEmit`. Run `dependency-cruiser` only when a config file exists. `npm audit --audit-level=high` (or the Yarn/pnpm equivalent). `run_build` defaults to false |
| `.github/workflows/js-package.yml` | Publish one npm package to GitHub Packages on a tag `vX.Y.Z`. The `package.json` name is `@deepidoo-s-new-age/<name>` and its version matches the tag. `working_directory` defaults to `.`; deesplay uses `packages/deesplay`. `install_directory` is the lockfile directory, the repository root for a workspace. Yarn Berry, Yarn classic, npm, or pnpm. `packages: write`. Outputs `name` and `version` |
| `.github/workflows/image.yml` | Build `ghcr.io/deepidoo-s-new-age/<image_name>:<git-sha>`. Refuse any other image name shape. Do not tag `:latest`. Do not deploy. Default context `backend/Dockerfile`, platform `linux/amd64`. Check out `deepidoo-contracts` into `contracts/` and pass it as the BuildKit context named `contracts`, because current Dockerfiles rewrite the path dependency that way. Input `push` defaults to true. Outputs `image` and `digest`. `packages: write` on this workflow |
| `.github/workflows/ci.yml` | Runs on `ci-workflows`: gitleaks, then actionlint 1.7.12 |
| `examples/python-service.yml` | Starter caller: test, then image on `main`, image name left as `your-service` |
| `examples/python-package.yml` | Starter caller for a uv package |
| `examples/vue-app.yml` | Starter caller with `working_directory: frontend-web` |
| `examples/js-package.yml` | Starter release caller for deesplay: tag `vX.Y.Z`, `working_directory: packages/deesplay` |

GitHub lists organization workflow templates only from `Deepidoo-s-new-age/.github`. This plan keeps the starter callers in `ci-workflows/examples/`. A new service copies the matching example into its own `.github/workflows/` directory.

Pin third-party Actions to a known major or exact tag in this first version (`actions/checkout@v4`, `docker/build-push-action@v6`, `docker/login-action@v3`, `docker/setup-buildx-action@v3`, `actions/setup-node@v4`). Commit SHAs come in phase 9.

Service lockfiles still say `editable = "../../contracts"`. The contracts clone has to land at that path. `actions/checkout` cannot write outside `GITHUB_WORKSPACE`, so the test workflow resolves the path and clones with git. The image workflow clones into `./contracts` for the BuildKit context. Drop the token from the git remote after fetch.

Steps:

1. Add the files above in a pull request on `ci-workflows`. This plan stays in `.github`.
2. Confirm `ci.yml` is green (gitleaks, actionlint).
3. Merge.
4. Tag that commit `ci-v1.0.0`.
5. Point the starter callers at `@ci-v1.0.0`, not `@main`. Service repositories pin that tag. Move the tag only when the shared workflow changes on purpose.

Org settings before the first image push (phase 6, not this phase):

- Default visibility for new packages: private.
- Actions can read other repositories in `Deepidoo-s-new-age`, or every service keeps `SCHEMAS_READ_TOKEN` and passes it as `contracts_read_token`.
- `auth-service` already uses the secret name `SCHEMAS_READ_TOKEN`.

Finish line: these workflows are on `main`, `ci.yml` is green, and `ci-v1.0.0` exists. No service repository calls them yet.

### Phase 1 — Prove the caller on `auth-service` without publishing

Add `auth-service/.github/workflows/ci.yml`. It replaces `docker.yml`. It does not publish an image. A `push: true` here would publish `ghcr.io/deepidoo-s-new-age/auth-service:<sha>` as soon as `main` moves, and nothing deploys that digest.

Do not add a `web` job yet. `npm ci` needs `deesplay` on disk, and `frontend/vite.config.ts` aliases `@deepidoo/deesplay` to `../../deesplay/packages/deesplay`. That job returns in phase 4. Leaving it out lets branch protection require `test` alone.

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]
permissions:
  contents: read
jobs:
  test:
    uses: Deepidoo-s-new-age/ci-workflows/.github/workflows/python-service.yml@ci-v1.0.0
    secrets:
      contracts_read_token: ${{ secrets.SCHEMAS_READ_TOKEN }}
  image:
    needs: test
    uses: Deepidoo-s-new-age/ci-workflows/.github/workflows/image.yml@ci-v1.0.0
    with:
      image_name: auth-service
      push: false
    secrets:
      contracts_read_token: ${{ secrets.SCHEMAS_READ_TOKEN }}
```

Steps:

1. Add that caller and delete `.github/workflows/docker.yml` in the same pull request. That removes the push to `ghcr.io/deepidoo/auth-service`.
2. Open a pull request that touches a backend file and confirm ruff, pytest, and pip-audit run.
3. Confirm the image job builds and does not push.

Finish line: an `auth-service` pull request is red when tests fail, and no image is published. Add `packages: write` and `push: true` only in phase 6, and only on pushes to `main`.

`platform-api` is the second caller, same shape, image name `platform-api`, `push: false`. Delete its `docker.yml` in that change. Do this after `auth-service` is green, not in the same pull request.

### Phase 2 — Callers for the other repositories that contain code

For each repository that has a `backend/pyproject.toml` and a `uv.lock`:

```yaml
jobs:
  test:
    uses: Deepidoo-s-new-age/ci-workflows/.github/workflows/python-service.yml@ci-v1.0.0
    secrets:
      contracts_read_token: ${{ secrets.SCHEMAS_READ_TOKEN }}
```

Add the image job with `push: false` only when the repo has a Dockerfile that matches `image.yml` (context `backend/`, BuildKit context `contracts`).

For `deepidoo-contracts`, use `python-package.yml` with `working_directory: .`. No image.

Empty repositories (`messaging`, `call_me_maybe`, `converter`) get a caller when they receive code, copied from `examples/` in `ci-workflows`, not before.

Branch protection on each repo that has a green caller:

- required check: the CI job;
- no direct pushes to `main`;
- `CODEOWNERS` on `deepidoo-contracts` and on `auth-service` for the whole repo, and later on `helm-charts` production values.

Coverage ratchet, in the same phase once pytest is stable:

- publish `coverage.xml`;
- store the current percentage in the repo;
- fail when the number drops;
- do not pick a global 80 percent.

Finish line: every non-empty New Age repo runs the shared CI on pull requests. Images are still not deployed.

### Phase 3 — Publish `deepidoo-contracts`

Today every image build and every service test clones the contracts repository, and `uv.lock` records `../../contracts`.

Steps:

1. Add `release.yml` in `deepidoo-contracts`, triggered on tags `vX.Y.Z`. It reuses `python-package.yml` for the checks, then publishes the package to GitHub Packages.
2. The package name stays `deepidoo-contracts`. The GitHub Packages repository is the organization that owns the repo.
3. A breaking change is a major version, as [ARCHITECTURE.md](../docs/ARCHITECTURE.md) already requires.
4. In one service (`auth-service` first), replace the path source with the published version, regenerate `uv.lock`, and set `checkout_contracts: false` on both the test workflow and the image workflow.
5. Update that service’s Dockerfile so it installs the package from the lockfile. Delete the BuildKit `contracts` context and the `sed` that rewrites `../../contracts`.
6. Repeat for `platform-api` and the other services.
7. Add Renovate so a new contracts version opens one pull request per consumer.

Finish line: a contracts change reaches a service only through a merged version bump, and the image build does not clone `deepidoo-contracts`.

### Phase 4 — Deesplay as a versioned package

Moving the repository into `Deepidoo-s-new-age` does not by itself fix installs.

GitHub Packages requires the npm scope to match the owning organization. Published from this organization, the package name is `@deepidoo-s-new-age/deesplay`. Imports in `auth-service` are `@deepidoo/deesplay/...`. Those imports, `package.json`, and the lockfile change with the new name. Keeping the name `@deepidoo/deesplay` means publishing to a registry that allows that scope.

The package ships TypeScript and Vue source (`exports` point at `.ts` and `.vue`). Vite can compile that from `node_modules`. A separate build step is not required for the first publish.

`frontend/vite.config.ts` aliases `@deepidoo/deesplay` to `../../deesplay/packages/deesplay`. Remove that alias and the `server.fs.allow` entry for that path, or Vite keeps reading the sibling checkout.

Peer ranges in deesplay are ahead of the admin UI: Vue Router 5, vue-i18n 11, Pinia 3, Vuetify 3.11, against Vue Router 4, vue-i18n 10, Pinia 2, Vuetify 3.7 in `auth-service`. The `file:` link does not enforce peers. `npm ci` of a published package can fail until the admin UI matches those peers or the published package declares peers the UI already satisfies.

Workflow work:

1. Add `deesplay/.github/workflows/release.yml` from `examples/js-package.yml`. It runs on tags `vX.Y.Z` and calls `js-package.yml` with `working_directory: packages/deesplay`. `packages/deesplay/package.json` is named `@deepidoo-s-new-age/deesplay` before the first tag.
2. `.npmrc` in the consuming app: `@deepidoo-s-new-age:registry=https://npm.pkg.github.com`.
3. Extend `vue-app.yml` with a `packages_read_token` secret and `NODE_AUTH_TOKEN` so `npm ci` can read GitHub Packages.
4. Put the `web` job back on `auth-service` with `working_directory: frontend`. Leave `run_build` false until `npm run build` (`vue-tsc -b && vite build`) is green locally against the published package.
5. Dependabot or Renovate bumps the deesplay version.

The admin UI stays undeployed until someone adds a frontend image and a Helm release. Phase 4 makes CI able to install and typecheck it. It does not put it on the cluster.

Finish line: `npm ci` in CI installs `@deepidoo-s-new-age/deesplay` at a tag, with no sibling checkout, and the `web` job is green.

### Phase 5 — Architecture and security gates

Implement [CI-CONTRACT-VALIDATION.md](../docs/CI-CONTRACT-VALIDATION.md). The script lives in `.github` as `tools/validate_architecture.py`.

Rollout, in the order that document already gives:

1. Local report plus a committed baseline of known gaps.
2. Pull-request job in warning mode.
3. New drift fails the check. Baseline entries stay allowed until removed on purpose.
4. `oasdiff` against the OpenAPI artifact from the base branch.

Add `security.yml` in `ci-workflows`, next to the other reusable workflows. Run Semgrep Community Edition, not bandit, not CodeQL, and not SonarQube:

```bash
semgrep scan --error --config p/owasp-top-ten --config p/python --config p/javascript
```

Pin the CLI version in the workflow. If the first run is noisy, fail only on findings that are not in a committed baseline. The job covers A04, A05, part of A01, and part of A10. It does not replace the access-control tests or the supply-chain checks in the table above.

Add import-linter contracts:

- a service does not import another service’s application code;
- route handlers do not own SQL.

Add dependency-cruiser for frontends once phase 4 is green: a module UI does not import another service.

Nightly, not on every pull request: one preproduction smoke. Login, call a module, the module calls `platform-api`.

Finish line: a new route missing from `docs/module.yaml` fails CI. Old gaps stay listed in the baseline.

### Phase 6 — `helm-charts` and promotion

Create `deepidoo-s-new-age/helm-charts`. This is the deploy repository. It holds charts, environment values, and the only workflows that talk to the cluster.

Layout:

```text
helm-charts/
  charts/app/          # one chart for a long-running service
  charts/job/          # migrations
  environments/preproduction/<service>.values.yaml
  environments/production/<service>.values.yaml
  environments/preproduction/helmfile.yaml
  environments/production/helmfile.yaml
```

Values pin a digest:

```yaml
image:
  repository: ghcr.io/deepidoo-s-new-age/auth-service
  digest: sha256:…
```

Steps:

1. Cluster `imagePullSecret` that can read packages from `Deepidoo-s-new-age`.
2. First release: `auth-service` API only. Turn `push: true` on pushes to `main`, with `packages: write`, restricted by `if: github.ref == 'refs/heads/main'`.
3. A workflow opens a pull request in `helm-charts` that sets the new digest in `environments/preproduction/auth-service.values.yaml`. The workflow reads the `digest` output of `image.yml`.
4. Merging that pull request runs `helmfile -f environments/preproduction/helmfile.yaml --selector name=auth-service apply` from a GitHub Environment named `preproduction`.
5. Alembic runs as a Helm hook or a Job in the same release, using the same digest, before new pods take traffic. The migration must tolerate the previous version still running.
6. Production is a second pull request that copies the same digest into `environments/production/`. The GitHub Environment `production` requires one reviewer.
7. Rollback is `helm rollback <release>` or a pull request that restores the previous digest.
8. Repeat for `platform-api`.
9. After two services deploy this way, install Argo CD to watch `helm-charts` and apply. The GitHub Environment then stops holding a long-lived kubeconfig. Until Argo exists, the kubeconfig secret lives only on `helm-charts`.

Finish line: preproduction and production run a digest that appears in a merged values file, and both run the same digest after promotion. No service repository contains `kubectl`.

### Phase 7 — Preview environments

A preview is a namespace `pr-<repo>-<number>` in the same cluster.

- Trigger: pull request label `preview`, or a `workflow_dispatch`.
- Install the service that changed, plus its frontend when that frontend has an image.
- Point the service at preproduction `auth-service` and `platform-api`.
- Deploy a copy of auth or platform only when the pull request changes those repositories or `deepidoo-contracts`.
- Ingress host `pr-<repo>-<number>.preview.<domain>`. Replace `_` in the repository name with `-`, because a DNS label cannot contain `_`. `deep_desk` pull request 12 is `pr-deep-desk-12.preview.<domain>`.
- Resource quota on the namespace.
- Fixture user, not a production dump.
- On pull request close, `helmfile destroy` that release.
- A daily job deletes namespaces older than 96 hours.

DNS records, all aimed at the cluster ingress. Opening a pull request does not create a record.

| Name | Use |
|---|---|
| `<service>.<domain>` | Production. One record per deployed service |
| `<service>.preproduction.<domain>` | Preproduction. One record per deployed service |
| `*.preview.<domain>` | Every preview. One wildcard covers `pr-menuboards-12.preview.<domain>` and `pr-deep-desk-12.preview.<domain>` |

TLS certificates use the same names. One certificate, or one SAN list, covers the production names. A second covers the preproduction names. A wildcard certificate covers `*.preview.<domain>`. cert-manager can issue that wildcard with a DNS-01 challenge.

Finish line: a labeled pull request yields a URL, and closing the pull request removes the namespace.

### Phase 8 — Telemetry and uptime

Do this after phase 6. A dashboard is easier to trust when each pod has a digest.

1. OpenTelemetry in `auth-service`, `platform-api`, then modules. Export traces, metrics, and logs to one collector.
2. Grafana reads Prometheus or Mimir, Loki, and Tempo.
3. One dashboard JSON in `helm-charts`, reused per service: request rate, error rate, latency.
4. Propagate the trace header on calls from a module to platform and auth.
5. Three journeys, alert on burn rate: login, read a content, one module action. Sloth or Pyrra generates the rules.
6. Gatus probes those journeys from outside the cluster. An in-cluster probe stays green while users cannot reach the ingress.

Finish line: a preproduction request shows one trace across the services it touched, and an outside probe goes red when the ingress is down.

### Phase 9 — Supply chain

After images and promotion are stable:

- Renovate across the organization, grouping minor bumps into one pull request per repo per week.
- `syft` writes an SBOM next to the image. `cosign` signs the digest in `image.yml`. Trivy scans that image for OS packages pip-audit cannot see.
- Kyverno in production rejects tags that are not a digest, then rejects unsigned images.
- Pin third-party Actions to a commit SHA inside the shared workflows (one place).
- Runtime secrets stay in SOPS or External Secrets. Example values in git stay inert.
- GHCR retention: keep sha tags that are referenced by Helm, delete untagged builds on a schedule.

Finish line: production Kyverno admits only a signed digest that Helmfile named.

### Phase 10 — SonarQube, optional

Stand up SonarQube Community Build only if the team wants one quality UI. Point the scanner at `main` after tests, and import the coverage report from phase 2. The merge gate stays the GitHub checks from phases 1, 2, and 5.

Finish line: `main` has a Sonar project per repo. A red Sonar gate does not replace a red CI check.

### Phase 11 — Agent loop

PR automation already comments on rules, `docs/module.yaml`, and review, then posts to Talkspirit. Keep it as a commenter.

The development loop:

1. The spec is in the pull request body (the `new-module` recap, or a short change spec).
2. An implementation agent opens the pull request.
3. The loop stops when the required checks are green, or after three pushes.
4. A human merges.
5. Production stays the reviewer on the GitHub Environment from phase 6.

Agents do not receive `production` environment access and do not push to `main`.

Finish line: an agent can reach a green pull request and cannot deploy production.

## 7. Order

| Order | Phase | Why it is here |
|---|---|---|
| 1 | 0 Shared workflows on `main`, tag `ci-v1.0.0` | Callers have nothing to `uses:` before this |
| 2 | 1 `auth-service` caller, `push: false`, no `web` job | Proves CI without publishing and without deesplay |
| 3 | 2 Other repos, branch protection, coverage ratchet | One definition of green |
| 4 | 3 Publish contracts | Removes the clone from every build |
| 5 | 4 Publish deesplay, restore the `web` job | Frontend CI becomes possible |
| 6 | 5 Contract validator, Semgrep, import rules | Gates that match this architecture |
| 7 | 6 `helm-charts`, digest promotion, then `push: true` | First time an image is deployed |
| 8 | 7 Previews | Needs the Helm path |
| 9 | 8 Telemetry | Needs digests so a spike has a version |
| 10 | 9 Signing, Kyverno, Renovate SHA pins | Needs a registry people actually pull |
| 11 | 10 SonarQube | Optional dashboard |
| 12 | 11 Agent loop | Exit condition is the gates above |

## 8. Secrets

| Secret | Where | Purpose |
|---|---|---|
| `SCHEMAS_READ_TOKEN` | each service repo, until org Actions can read `deepidoo-contracts` | clone contracts |
| `GITHUB_TOKEN` | implicit | push the image to this org’s GHCR, after `packages: write` |
| kubeconfig | `helm-charts` environment `preproduction` and `production` only | Helmfile apply, until Argo CD replaces it |
| `NODE_AUTH_TOKEN` | repos that npm-install GitHub Packages | deesplay, phase 4 |
| Package read token for the cluster | Kubernetes `imagePullSecret` | pull `ghcr.io/deepidoo-s-new-age/*` |

`TALKSPIRIT_WEBHOOK_URL` stays a Cursor secret. GitHub Actions does not post that recap.

## 9. Out of scope until a repository moves

Repositories in the `Deepidoo` organization, including `play_music_ai`, `play`, `deesplay` (until phase 4 moves it), and `helm_charts`, keep their current pipelines. When a repository moves into `Deepidoo-s-new-age`, it deletes its own deploy workflow, adds the thin caller, and publishes to `ghcr.io/deepidoo-s-new-age/<service>:<git-sha>`. The digest is then added to `deepidoo-s-new-age/helm-charts`.

Do not point a New Age workflow at `Deepidoo/helm_charts`. Do not publish a New Age image to `ghcr.io/deepidoo`.

## 10. Definition of done for the program

- Every non-empty repository in `Deepidoo-s-new-age` calls the shared workflows at a pinned `ci-v*` tag.
- `main` cannot be updated when those checks are red.
- Images are `ghcr.io/deepidoo-s-new-age/<service>:<git-sha>` and are private.
- `helm-charts` is the only repository that can change what the cluster runs.
- Preproduction and production document the digest. Production apply requires a reviewer.
- Preview namespaces expire.
- Login, a content read, and one module action have a trace, an SLO, and an outside probe.
- `deepidoo-contracts` and deesplay are consumed as versions.
- Agents stop at a green pull request.
