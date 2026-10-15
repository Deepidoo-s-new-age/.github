# CI/CD progress — Deepidoo-s-new-age

Status of [CICD-PLAN.md](CICD-PLAN.md) as of 15 October 2026.

A phase is concluded for a repository when that phase’s finish line is true for it. A later phase that is not started leaves the repository stopped at the last concluded phase.

## Program

| Phase | Status |
|---|---|
| 0 — Shared workflows | Concluded |
| 1 — Prove the caller | Concluded for `auth-service` and `platform-api` |
| 2 — Callers, protection, coverage | Rulesets for `main` are saved in the UI on the cloned callers and on `ci-workflows`. GitHub does not enforce them while the org stays on the Free plan. Uncloned repositories were left untouched |
| 3 — Publish `deepidoo-contracts` | Concluded for the cloned consumers. The release is git tag `v0.1.0`. Renovate is configured and waits for the GitHub App |
| 4 — deesplay | Not started |
| 5 — Architecture and security gates | Not started |
| 6 — `helm-charts` and promotion | Not started |
| 7 — Preview environments | Not started |
| 8 — Telemetry and uptime | Not started |
| 9 — Supply chain | Not started |
| 10 — SonarQube | Not started |
| 11 — Agent loop | Not started |

The live shared-workflow tag is `ci-v1.0.3` (`1771088`). `ci-v1.0.0`, `ci-v1.0.1`, and `ci-v1.0.2` stay where they were tagged. `deepidoo-contracts` `v0.1.0` is `cab3c24`.

## Per repository

| Repository | Last concluded phase | Stopped at |
|---|---|---|
| `ci-workflows` | 0 | Phase 3 git-tag auth is on `main` and tagged `ci-v1.0.3` ([#4](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/4)). Phase 2 branch protection is still blocked by the Free plan |
| `auth-service` | 3 | Pins `deepidoo-contracts` `v0.1.0` ([#9](https://github.com/Deepidoo-s-new-age/auth-service/pull/9), `8e411da`). Image build does not clone the repository. Phase 2 branch protection remains blocked by the Free plan |
| `platform-api` | 3 | Pins `deepidoo-contracts` `v0.1.0` ([#53](https://github.com/Deepidoo-s-new-age/platform-api/pull/53), `9bc07ad`). Image build does not clone the repository. Phase 2 branch protection remains blocked by the Free plan |
| `deepidoo-contracts` | 3 | Release workflow is on `main` ([#129](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/129), `cab3c24`) and tag `v0.1.0` is green. Phase 2 branch protection remains blocked by the Free plan |
| `menuboards`, `deep_desk`, `scheduler`, `tickets`, `roadmap`, `epaper` | — | Stopped before phase 2. No shared caller. Left uncloned on purpose |
| `messaging`, `call_me_maybe`, `converter` | — | Stopped before phase 2. The plan waits until these hold code, then copies a caller from `ci-workflows/examples/` |
| `helm-charts` | — | Stopped before phase 2 and phase 6. The clone has no commits, so there are no production values to put under `CODEOWNERS` |
| `Deepidoo/deesplay` | — | Stopped before phase 4. Still in `Deepidoo`, still named `@deepidoo/deesplay` |
| `.github` | — | Holds this plan. No service caller. The phase 5 validator is not wired into CI |

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

`CODEOWNERS` for `helm-charts` production values waits until that repository has values.

## Phase 3 — git tag, cloned repositories

GitHub Packages does not host Python, so the release is the git tag. A contracts change reaches `auth-service` and `platform-api` only when their lockfiles move to a new tag. Their image jobs skip the contracts clone.

| Repository | What landed |
|---|---|
| `ci-workflows` | [#4](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/4), tag `ci-v1.0.3` (`1771088`). `checkout_contracts: false` authenticates git for `uv sync` and passes BuildKit secret `github_token` |
| `deepidoo-contracts` | [#129](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/129), tag `v0.1.0` (`cab3c24`). Release run [38708105137](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/actions/runs/38708105137) green |
| `auth-service` | [#9](https://github.com/Deepidoo-s-new-age/auth-service/pull/9) `8e411da`. Main run [38708608432](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38708608432) green |
| `platform-api` | [#53](https://github.com/Deepidoo-s-new-age/platform-api/pull/53) `9bc07ad`. Main run [38708615186](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38708615186) green |

`renovate.json` in the two services proposes only `deepidoo-contracts` bumps. The Renovate GitHub App is not installed on the organization, so those files do not open pull requests yet.

## Phases not started

| Phase | Where the plan stops |
|---|---|
| 4 | `deesplay` is still `@deepidoo/deesplay` in `Deepidoo`. `auth-service` has no `web` job |
| 5 | `tools/validate_architecture.py` is not a CI job. No `security.yml`, no import-linter |
| 6 | `helm-charts` has no charts and no values. Image jobs stay at `push: false` |
| 7–11 | Depend on phase 6, or are optional (phase 10) |
