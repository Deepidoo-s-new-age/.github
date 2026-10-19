# CI/CD progress — Deepidoo-s-new-age

Status of [CICD-PLAN.md](CICD-PLAN.md) as of 19 October 2026.

A phase is concluded for a repository when that phase’s finish line is true for it. A later phase that is not started leaves the repository stopped at the last concluded phase.

## Program

| Phase | Status |
|---|---|
| 0 — Shared workflows | Concluded |
| 1 — Prove the caller | Concluded for `auth-service` and `platform-api` |
| 2 — Callers, protection, coverage | Rulesets for `main` are saved in the UI on the cloned callers and on `ci-workflows`. GitHub does not enforce them while the org stays on the Free plan. Uncloned repositories were left untouched |
| 3 — Publish `deepidoo-contracts` | Concluded for the cloned consumers. The release is git tag `v0.1.0`. Renovate is configured and waits for the GitHub App |
| 4 — deesplay | Concluded for the new `Deepidoo-s-new-age/deesplay` and for the `auth-service` web job |
| 5 — Architecture and security gates | Finish line met on the cloned repositories. Cross-service import-linter, base-commit oasdiff (`ci-v1.0.7`), and dependency-cruiser are on `main`. The nightly smoke waits for a preproduction deploy. Comparing the generated spec with `docs/openapi.json` in the same commit is [ci-workflows #9](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/9), still open |
| 6 — `helm-charts` and promotion | Started. Charts and deploy workflows are on `helm-charts` `main` (`f55ad5d`). No digest is recorded, no cluster secret is set, and image push from `main` is still an open pull request |
| 7 — Preview environments | Not started |
| 8 — Telemetry and uptime | Not started |
| 9 — Supply chain | Not started |
| 10 — SonarQube | Not started |
| 11 — Agent loop | Not started |

The live shared-workflow tag is `ci-v1.0.6` (`669ec5a`). `auth-service` and `platform-api` test jobs pin it. Their image jobs stay on `ci-v1.0.3` (`1771088`). The Vue caller stays on `ci-v1.0.5` (`aeb5c98`). `deepidoo-contracts` tests stay on `ci-v1.0.2`. `ci-v1.0.0` through `ci-v1.0.5` stay where they were tagged. `ci-v1.0.4` writes the npm auth file but leaves `GITHUB_TOKEN` unset under `set -u`. `deepidoo-contracts` `v0.1.0` is `cab3c24`. `@deepidoo-s-new-age/deesplay` `1.0.1` is tag `v1.0.1` (`dc39440`).

## Per repository

| Repository | Last concluded phase | Stopped at |
|---|---|---|
| `ci-workflows` | 0 | Phase 5 workflows are on `main` and tagged `ci-v1.0.6` ([#7](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/7)). Vue callers stay on `ci-v1.0.5`. Image callers stay on `ci-v1.0.3`. Phase 2 branch protection is still blocked by the Free plan |
| `auth-service` | 5 | Architecture, Semgrep, and the SQL import contract are on `main` ([#11](https://github.com/Deepidoo-s-new-age/auth-service/pull/11), `2ffecdb`). Web job stays green with `run_build` off. Phase 2 branch protection remains blocked by the Free plan |
| `platform-api` | 5 | Architecture, Semgrep, and the SQL import contract are on `main` ([#54](https://github.com/Deepidoo-s-new-age/platform-api/pull/54), `876c889`). Image build does not clone the repository. Phase 2 branch protection remains blocked by the Free plan |
| `deepidoo-contracts` | 5 | Semgrep is on `main` ([#130](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/130), `7b1394c`). There is no HTTP API, so the architecture job is not called. Tag `v0.1.0` is unchanged. Phase 2 branch protection remains blocked by the Free plan |
| `menuboards`, `deep_desk`, `scheduler`, `tickets`, `roadmap`, `epaper` | — | Stopped before phase 2. No shared caller. Left uncloned on purpose |
| `messaging`, `call_me_maybe`, `converter` | — | Stopped before phase 2. The plan waits until these hold code, then copies a caller from `ci-workflows/examples/` |
| `helm-charts` | — | Phase 6 started (`f55ad5d`). `charts/app`, `charts/job`, and preproduction and production values exist. Digests are empty, so apply does not run. `KUBECONFIG` is not set. Argo CD is not installed |
| `deesplay` | 5 | Package `1.0.1` is unchanged (`v1.0.1`, `dc39440`). Semgrep is on `main` ([#1](https://github.com/Deepidoo-s-new-age/deesplay/pull/1), `1100f3e`). `Deepidoo/deesplay` was left in place for the legacy repositories |
| `Deepidoo/deesplay` | — | Left untouched. Legacy repositories still depend on `@deepidoo/deesplay` |
| `.github` | — | Holds this plan. `tools/validate_architecture.py` is on `main` ([#1](https://github.com/Deepidoo-s-new-age/.github/pull/1), `9cb93f8`). The architecture job clones it |

## What is already on `main`

### Phase 0 — `ci-workflows`

Concluded. Workflows are on `main`, `ci.yml` is green, and `ci-v1.0.0` exists ([#1](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/1)).

Two later tags are also on `main`:

- `ci-v1.0.1` ([#2](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/2)) authenticates the `deepidoo-contracts` clone with Basic auth. Found while proving the `auth-service` caller.
- `ci-v1.0.2` adds the phase 2 coverage ratchet to `python-service.yml` and `python-package.yml`.

### Phase 1 — callers, images unpublished

Concluded for both repositories named in that phase.

| Repository | Merged | `main` |
|---|---|---|
| `auth-service` | [#6](https://github.com/Deepidoo-s-new-age/auth-service/pull/6) | `626bca2`. Push run [38410328373](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38410328373) green. `docker.yml` removed. Image job `push: false`. No `web` job |
| `platform-api` | [#51](https://github.com/Deepidoo-s-new-age/platform-api/pull/51) | `20dae16`. Push run [38700625143](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38700625143) green. `docker.yml` removed. Caller uses `working_directory: .` and `context: .`. Image job `push: false` |

No `ghcr.io/deepidoo-s-new-age/auth-service` or `platform-api` package was published.

## Phase 2, where it stopped

The finish line is: every non-empty New Age repository runs the shared CI on pull requests, and images are still not deployed. That line is not true yet.

Done on `main` inside this phase:

- `deepidoo-contracts` calls `python-package.yml` ([#127](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/127)).
- The coverage ratchet is in the shared workflows at `ci-v1.0.2`.
- The three callers pin that tag, store a coverage floor, and their `main` push is green.

| Repository | Merge | `main` push |
|---|---|---|
| `auth-service` | [#8](https://github.com/Deepidoo-s-new-age/auth-service/pull/8) `6dd8c18`. Floor `64.8`. `CODEOWNERS` for `@Deepidoo-s-new-age/devs` | [38706977417](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38706977417) |
| `platform-api` | [#52](https://github.com/Deepidoo-s-new-age/platform-api/pull/52) `4aa99bc`. Floor `87.1` | [38706979751](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38706979751) |
| `deepidoo-contracts` | [#128](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/128) `8c6372c`. Floor `98.6`. `CODEOWNERS` for `@Deepidoo-s-new-age/devs` | [38706985686](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/actions/runs/38706985686) |

Images stay unpublished (`push: false`).

Not done, and blocking the finish line:

- Enforcement of the `main` rulesets. They are saved on `auth-service`, `platform-api`, `deepidoo-contracts`, and `ci-workflows`. The ruleset API still returns the Free-plan refusal, and GitHub will not apply the rules until an organization owner moves `Deepidoo-s-new-age` to GitHub Team. The saved rules are: required pull request, required check `test / test` (strict; `lint` on `ci-workflows`), no force-push, no deletion, and a code-owner review on `auth-service` and `deepidoo-contracts`.
- Shared CI on the other non-empty repositories. They were left uncloned.

`CODEOWNERS` for `helm-charts` production values is still not added. The values files exist and their digests are empty.

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

The architecture job fails when a route is missing from `docs/module.yaml` and is not already listed in `docs/architecture-baseline.txt`. `auth-service` has 17 baselined gaps and `platform-api` has 92. Neither foundation has a module contract yet, so every current route is a known gap. A new prefix fails. `deepidoo-contracts` has no API package, so the script skips it.

The same job regenerates OpenAPI and runs oasdiff 1.33.0 against `docs/openapi.json` committed in that same tree. A pull request that changes the API and updates the snapshot together passes. A pull request that leaves the snapshot behind a breaking change fails.

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

Landed after the table above:

- Cross-service import-linter is on `main` ([auth-service #12](https://github.com/Deepidoo-s-new-age/auth-service/pull/12), [platform-api #55](https://github.com/Deepidoo-s-new-age/platform-api/pull/55)). Each forbidden module is an empty dev stub. The production image does not install it.
- Architecture callers pin `ci-v1.0.7`. oasdiff compares the generated spec with the base commit.
- dependency-cruiser runs in the `auth-service` web job.
- The nightly preproduction smoke is still not started. It waits for a preproduction deploy.
- A second oasdiff, against `docs/openapi.json` in the same commit, is [ci-workflows #9](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/9) and is not tagged.

## Phase 6 — charts and promotion

`helm-charts` `main` holds `charts/app`, `charts/job`, and preproduction and production values for `auth-service` and `platform-api`. The migration job is off: neither service has an Alembic command. `auth-service` creates its schema when the process starts.

Digests are empty, so the deploy workflows skip apply. The `preproduction` and `production` environments have no `KUBECONFIG`, and the cluster pull secret is not created here. Argo CD is not installed. The Free plan still cannot require a production reviewer.

Image push from `main` is proposed in [auth-service #14](https://github.com/Deepidoo-s-new-age/auth-service/pull/14) and [platform-api #57](https://github.com/Deepidoo-s-new-age/platform-api/pull/57). Until those merge, image jobs stay at `push: false`. The promote job needs a `HELM_CHARTS_TOKEN` secret on each service repository.

## Phases not started

| Phase | Where the plan stops |
|---|---|
| 7–11 | Depend on a real preproduction deploy, or are optional (phase 10) |
