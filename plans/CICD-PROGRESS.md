# CI/CD progress — Deepidoo-s-new-age

Status of [CICD-PLAN.md](CICD-PLAN.md) as of 26 October 2026.

A phase is concluded for a repository when that phase’s finish line is true for it. A later phase that is not started leaves the repository stopped at the last concluded phase.

How to ship `auth-service` and `platform-api` is [helm-charts/docs/deploying.md](https://github.com/Deepidoo-s-new-age/helm-charts/blob/argocd-watch/docs/deploying.md). That file is on [helm-charts #12](https://github.com/Deepidoo-s-new-age/helm-charts/pull/12) until the pull request merges.

## Program

| Phase | Status |
|---|---|
| 0 — Shared workflows | Concluded |
| 1 — Prove the caller | Concluded for `auth-service` and `platform-api` |
| 2 — Callers, protection, coverage | Rulesets for `main` are saved in the UI on the cloned callers and on `ci-workflows`. GitHub does not enforce them while the org stays on the Free plan. Uncloned repositories were left untouched |
| 3 — Publish `deepidoo-contracts` | Concluded for the cloned consumers. The release is git tag `v0.1.0`. Renovate is configured and waits for the GitHub App |
| 4 — deesplay | Concluded for the new `Deepidoo-s-new-age/deesplay` and for the `auth-service` web job |
| 5 — Architecture and security gates | Finish line met on the cloned repositories. Cross-service import-linter, base-commit oasdiff (`ci-v1.0.7`), and dependency-cruiser are on `main`. The nightly smoke workflow has not been added. [ci-workflows #9](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/9) is merged and is not tagged, so callers still run the `ci-v1.0.7` check |
| 6 — `helm-charts` and promotion | Open. Both namespaces run the digests recorded on `helm-charts` `main`. Argo CD `v3.5.6` is installed and its applications cannot clone the repository, so GitHub Actions still applies and the phase stays open |
| 7 — Preview environments | Not started |
| 8 — Telemetry and uptime | Not started |
| 9 — Supply chain | Not started |
| 10 — SonarQube | Not started |
| 11 — Agent loop | Not started |

Callers pin several tags. `ci-v1.0.7` (`7e9c789`) is the architecture job. `ci-v1.0.6` (`669ec5a`) is the test and security jobs. `ci-v1.0.5` (`aeb5c98`) is the Vue caller. `ci-v1.0.3` (`1771088`) is the image job. `deepidoo-contracts` tests stay on `ci-v1.0.2`. `ci-v1.0.0` through `ci-v1.0.7` stay where they were tagged. `ci-workflows` `main` is `8a915cc` ([#9](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/9)), which is not a tag. `ci-v1.0.4` writes the npm auth file but leaves `GITHUB_TOKEN` unset under `set -u`. `deepidoo-contracts` `v0.1.0` is `cab3c24`. `@deepidoo-s-new-age/deesplay` `1.0.1` is tag `v1.0.1` (`dc39440`).

## Per repository

| Repository | Last concluded phase | Stopped at |
|---|---|---|
| `ci-workflows` | 0 | Phase 5 workflows are tagged through `ci-v1.0.7` ([#8](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/8)). [#9](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/9) is on `main` and has no tag. Vue callers stay on `ci-v1.0.5`. Image callers stay on `ci-v1.0.3`. Phase 2 branch protection is still blocked by the Free plan |
| `auth-service` | 5 | Architecture, Semgrep, and the SQL import contract are on `main` ([#11](https://github.com/Deepidoo-s-new-age/auth-service/pull/11), `2ffecdb`). Image publish from `main` is on ([#14](https://github.com/Deepidoo-s-new-age/auth-service/pull/14)). The running image starts with `.venv/bin/uvicorn` ([#18](https://github.com/Deepidoo-s-new-age/auth-service/pull/18)). Web job stays green with `run_build` off. Phase 2 branch protection remains blocked by the Free plan |
| `platform-api` | 5 | Architecture, Semgrep, and the SQL import contract are on `main` ([#54](https://github.com/Deepidoo-s-new-age/platform-api/pull/54), `876c889`). Image publish from `main` is on ([#57](https://github.com/Deepidoo-s-new-age/platform-api/pull/57)). The running image starts with `.venv/bin/uvicorn` ([#59](https://github.com/Deepidoo-s-new-age/platform-api/pull/59)). Image build does not clone the repository. Phase 2 branch protection remains blocked by the Free plan |
| `deepidoo-contracts` | 5 | Semgrep is on `main` ([#130](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/130), `7b1394c`). There is no HTTP API, so the architecture job is not called. Tag `v0.1.0` is unchanged. [#131](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/131) (drop `test-lib`) is still open. Phase 2 branch protection remains blocked by the Free plan |
| `menuboards`, `deep_desk`, `scheduler`, `tickets`, `roadmap`, `epaper` | — | Stopped before phase 2. No shared caller. Left uncloned on purpose |
| `messaging`, `call_me_maybe`, `converter` | — | Stopped before phase 2. The plan waits until these hold code, then copies a caller from `ci-workflows/examples/` |
| `helm-charts` | — | Phase 6 is open on `main` `c051934`. Both namespaces run the recorded digests. Argo CD is installed and is not syncing. [Deploy workflows stay](https://github.com/Deepidoo-s-new-age/helm-charts/blob/main/.github/workflows/deploy-preproduction.yml) until [#12](https://github.com/Deepidoo-s-new-age/helm-charts/pull/12) merges after the applications are Synced |
| `deesplay` | 5 | Package `1.0.1` is unchanged (`v1.0.1`, `dc39440`). Semgrep is on `main` ([#1](https://github.com/Deepidoo-s-new-age/deesplay/pull/1), `1100f3e`). `Deepidoo/deesplay` was left in place for the legacy repositories |
| `Deepidoo/deesplay` | — | Left untouched. Legacy repositories still depend on `@deepidoo/deesplay` |
| `.github` | — | Holds this plan. `tools/validate_architecture.py` is on `main` ([#1](https://github.com/Deepidoo-s-new-age/.github/pull/1), `9cb93f8`, parser follow-up [#3](https://github.com/Deepidoo-s-new-age/.github/pull/3) `ce47fb1`). The architecture job clones it |

## What is already on `main`

### Phase 0 — `ci-workflows`

Concluded. Workflows are on `main`, `ci.yml` is green, and `ci-v1.0.0` exists ([#1](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/1)).

Two later tags are also on `main`:

- `ci-v1.0.1` ([#2](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/2)) authenticates the `deepidoo-contracts` clone with Basic auth. Found while proving the `auth-service` caller.
- `ci-v1.0.2` adds the phase 2 coverage ratchet to `python-service.yml` and `python-package.yml`.

### Phase 1 — callers

Concluded for both repositories named in that phase. At the end of this phase the image job was `push: false` and no package existed. Phase 6 later publishes both images from `main`.

| Repository | Merged | `main` at the time |
|---|---|---|
| `auth-service` | [#6](https://github.com/Deepidoo-s-new-age/auth-service/pull/6) | `626bca2`. Push run [38410328373](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38410328373) green. `docker.yml` removed. No `web` job |
| `platform-api` | [#51](https://github.com/Deepidoo-s-new-age/platform-api/pull/51) | `20dae16`. Push run [38700625143](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38700625143) green. `docker.yml` removed. Caller uses `working_directory: .` and `context: .` |

## Phase 2, where it stopped

The finish line is every non-empty New Age repository running the shared CI on pull requests. The line is still open: the uncloned repositories have no shared caller, and the saved `main` rulesets are not enforced. Image publish landed later, in phase 6, and that publish leaves this phase open.

Done on `main` inside this phase:

- `deepidoo-contracts` calls `python-package.yml` ([#127](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/127)).
- The coverage ratchet is in the shared workflows at `ci-v1.0.2`.
- The three callers pin that tag, store a coverage floor, and their `main` push is green.

| Repository | Merge | `main` push |
|---|---|---|
| `auth-service` | [#8](https://github.com/Deepidoo-s-new-age/auth-service/pull/8) `6dd8c18`. Floor `64.8`. `CODEOWNERS` for `@Deepidoo-s-new-age/devs` | [38706977417](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38706977417) |
| `platform-api` | [#52](https://github.com/Deepidoo-s-new-age/platform-api/pull/52) `4aa99bc`. Floor `87.1` | [38706979751](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38706979751) |
| `deepidoo-contracts` | [#128](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/128) `8c6372c`. Floor `98.6`. `CODEOWNERS` for `@Deepidoo-s-new-age/devs` | [38706985686](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/actions/runs/38706985686) |

Not done, and blocking the finish line:

- Enforcement of the `main` rulesets. They are saved on `auth-service`, `platform-api`, `deepidoo-contracts`, and `ci-workflows`. The ruleset API still returns the Free-plan refusal, and GitHub will not apply the rules until an organization owner moves `Deepidoo-s-new-age` to GitHub Team. The saved rules are: required pull request, required check `test / test` (strict; `lint` on `ci-workflows`), no force-push, no deletion, and a code-owner review on `auth-service` and `deepidoo-contracts`.
- Shared CI on the other non-empty repositories. They were left uncloned.

`CODEOWNERS` for `helm-charts` production values is still absent. The values files now contain digests.

## Phase 3 — git tag, cloned repositories

GitHub Packages does not host Python, so the release is the git tag. A contracts change reaches `auth-service` and `platform-api` only when their lockfiles move to a new tag. Their image jobs skip the contracts clone.

| Repository | What landed |
|---|---|
| `ci-workflows` | [#4](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/4), tag `ci-v1.0.3` (`1771088`). `checkout_contracts: false` authenticates git for `uv sync` and passes BuildKit secret `github_token` |
| `deepidoo-contracts` | [#129](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/129), tag `v0.1.0` (`cab3c24`). Release run [38708105137](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/actions/runs/38708105137) green |
| `auth-service` | [#9](https://github.com/Deepidoo-s-new-age/auth-service/pull/9) `8e411da`. Main run [38708608432](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38708608432) green |
| `platform-api` | [#53](https://github.com/Deepidoo-s-new-age/platform-api/pull/53) `9bc07ad`. Main run [38708615186](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38708615186) green |

`renovate.json` in the two services proposes only `deepidoo-contracts` bumps. The Renovate GitHub App is not installed on the organization, so those files do not open pull requests yet.

## Phase 4 — deesplay on GitHub Packages

`Deepidoo/deesplay` stays where it is. `Deepidoo-s-new-age/deesplay` is a copy of branches `main` and `dev` only. The package name is `@deepidoo-s-new-age/deesplay`.

| What | Where |
|---|---|
| Rename and release workflow | `a36efe4` on `main`, also on `dev`. Tag `v1.0.0` published `1.0.0` |
| Source typechecks in a consuming app | `dc39440`. Tag `v1.0.1` published `1.0.1`. Release run [38712991821](https://github.com/Deepidoo-s-new-age/deesplay/actions/runs/38712991821) green |
| Vue install auth | [#5](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/5) `ci-v1.0.4`, then [#6](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/6) `ci-v1.0.5` (`aeb5c98`) |
| `auth-service` web job | [#10](https://github.com/Deepidoo-s-new-age/auth-service/pull/10) `1a83a47`. Main run [38715031428](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38715031428): `web / web`, `test / test`, and `image / image` green. `run_build` is false. No frontend image |

The caller `GITHUB_TOKEN` is denied `read_package` on `@deepidoo-s-new-age/deesplay`. The web job passes the existing `SCHEMAS_READ_TOKEN` as `packages_read_token`. The admin UI peers match the published ranges for Vue, Vue Router, Pinia, vue-i18n, and Vuetify. `frontend/.npmrc` sets the scope registry and `legacy-peer-deps` for the peers the UI does not install. `auth-service` `renovate.json` also allows deesplay bumps. The Renovate GitHub App is still not installed.

## Phase 5 — routes, OpenAPI, Semgrep

The architecture job fails when a route is missing from `docs/module.yaml` and is not already listed in `docs/architecture-baseline.txt`. `auth-service` has 17 baselined gaps and `platform-api` has 92. Neither foundation has a module contract yet, so every current route is a known gap. A new prefix fails. `deepidoo-contracts` has no API package, so the script skips it. Foundations with no module contract keep their current routes in the baseline. Later phases do not clear those lines.

Callers pin `architecture.yml` at `ci-v1.0.7`. That tag regenerates OpenAPI and runs oasdiff 1.33.0 against `docs/openapi.json` from the pull request’s base commit, or from `HEAD^` on a push to `main`. [ci-workflows #9](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/9) (`8a915cc`) also compares the generated spec with `docs/openapi.json` in the same commit. It is merged and not tagged, so the callers do not run that second compare.

`python-service.yml` at `ci-v1.0.6` runs `lint-imports` when `[tool.importlinter]` is present. Route handlers in both services may not import SQLAlchemy directly. `auth-service` also forbids `app.models`. `platform-api` also forbids `app.repositories`. Indirect imports through a service stay allowed.

Semgrep 1.181.0 runs with `p/owasp-top-ten`, `p/python`, and `p/javascript`. The baseline is the pull request’s base commit, or `HEAD^` on a push to `main`. A finding that already exists there does not fail the job.

| Repository | Merge | `main` push |
|---|---|---|
| `.github` | [#1](https://github.com/Deepidoo-s-new-age/.github/pull/1) `9cb93f8` | No workflow in this repository |
| `ci-workflows` | [#7](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/7) `669ec5a`. Tag `ci-v1.0.6` | Lint was green on the pull request ([38739626366](https://github.com/Deepidoo-s-new-age/ci-workflows/actions/runs/38739626366)) |
| `auth-service` | [#11](https://github.com/Deepidoo-s-new-age/auth-service/pull/11) `2ffecdb` | [38740934316](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38740934316) green |
| `platform-api` | [#54](https://github.com/Deepidoo-s-new-age/platform-api/pull/54) `876c889` | [38740943465](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38740943465) green |
| `deepidoo-contracts` | [#130](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/130) `7b1394c` | Test [38740953222](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/actions/runs/38740953222) and Semgrep [38740953570](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/actions/runs/38740953570) green |
| `deesplay` | [#1](https://github.com/Deepidoo-s-new-age/deesplay/pull/1) `1100f3e` | Semgrep [38740962330](https://github.com/Deepidoo-s-new-age/deesplay/actions/runs/38740962330) green. No new package tag |

Landed after that table:

- Cross-service import-linter is on `main` ([auth-service #12](https://github.com/Deepidoo-s-new-age/auth-service/pull/12), [platform-api #55](https://github.com/Deepidoo-s-new-age/platform-api/pull/55)). Each forbidden module is an empty dev stub. The production image does not install it.
- Architecture callers pin `ci-v1.0.7` ([ci-workflows #8](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/8)).
- dependency-cruiser runs in the `auth-service` web job.
- The nightly preproduction smoke is still absent. Preproduction itself now exists; the workflow was not added.
- [deepidoo-contracts #131](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/131) is open. `test-lib` is still a dependency.

## Phase 6 — charts and promotion

`helm-charts` `main` is `c051934`. Preproduction and production are two namespaces on the same cluster. Each namespace runs Postgres `18.6`, Redis `7.4.2`, `auth-service`, and `platform-api`. Pods in both namespaces were `Running` on 26 October 2026 with the digests below, which are also the digests in the merged values files.

| Service | Digest |
|---|---|
| `auth-service` | `sha256:93ebaa5d643073b26f6725958c94cbbcec9503b8558085c8a113724948331496` |
| `platform-api` | `sha256:000a61d007ef0ce4c32aa4fe310963a493bdd56bceea713c41ff9640bcb9d9d8` |

The migration job is off: neither service has an Alembic command. `auth-service` creates schema `auth` when the process starts. `platform-api` does not migrate on startup. One database, `deepidoo`, per namespace. Extra isolation is a schema.

A push to `main` in a service repository publishes `ghcr.io/deepidoo-s-new-age/<service>:<git-sha>` and opens a pull request that sets `environments/preproduction/<service>.values.yaml`. That job uses the repository secret `HELM_CHARTS_TOKEN` on `auth-service` and on `platform-api`. Merging the pull request runs **Deploy preproduction**, which applies with Helmfile from the `preproduction` environment. The environment secret is named `KUBECONFIG`.

**Promote to production** ([#9](https://github.com/Deepidoo-s-new-age/helm-charts/pull/9)) is a manual workflow on `helm-charts`. Run it from `main` and tick the services to copy. One run reads those preproduction digests and opens one pull request. The organization allows Actions to create that pull request. [#10](https://github.com/Deepidoo-s-new-age/helm-charts/pull/10) and [#11](https://github.com/Deepidoo-s-new-age/helm-charts/pull/11) are the promotions that put production on the digests above. Merging a promotion pull request runs **Deploy production** with the `production` environment’s `KUBECONFIG`. The Free plan still cannot require a reviewer on that environment.

The plan’s finish line is true for the two services: both namespaces run a digest that appears in a merged values file, and no service repository contains `kubectl`. The phase stays open on step 9.

Argo CD `v3.5.6` is installed in namespace `argocd` (non-HA upstream manifest). AppProject `deepidoo` and eight Applications are in the cluster. Their sync status is Unknown because deploy keys are disabled on `helm-charts`, so Argo CD cannot clone it. `argocd/root.yaml` has not been applied. [#12](https://github.com/Deepidoo-s-new-age/helm-charts/pull/12) adds the manifests and removes the two deploy workflows. Leave both `KUBECONFIG` secrets in place until the Applications are Synced and that pull request is on `main`. The order is in the deploy guide linked at the top.

`CODEOWNERS` for the production values is still absent. The nightly smoke workflow is still absent.

## Phases not started

| Phase | Where the plan stops |
|---|---|
| 7 | Preview namespaces. Waits until Argo CD is the applier. |
| 8–11 | Depend on a stable preproduction, or are optional (phase 10). |
