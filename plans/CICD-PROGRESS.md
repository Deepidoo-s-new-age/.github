# CI/CD progress — Deepidoo-s-new-age

Status of [CICD-PLAN.md](CICD-PLAN.md) as of 15 October 2026.

A phase is concluded for a repository when that phase’s finish line is true for it. A later phase that is not started leaves the repository stopped at the last concluded phase.

## Program

| Phase | Status |
|---|---|
| 0 — Shared workflows | Concluded |
| 1 — Prove the caller | Concluded for `auth-service` and `platform-api` |
| 2 — Callers, protection, coverage | In progress on the cloned callers: coverage and `CODEOWNERS` are on `main`. Branch protection is blocked because the org is on the Free plan. Uncloned repositories were left untouched |
| 3 — Publish `deepidoo-contracts` | Not started |
| 4 — deesplay | Not started |
| 5 — Architecture and security gates | Not started |
| 6 — `helm-charts` and promotion | Not started |
| 7 — Preview environments | Not started |
| 8 — Telemetry and uptime | Not started |
| 9 — Supply chain | Not started |
| 10 — SonarQube | Not started |
| 11 — Agent loop | Not started |

The live shared-workflow tag is `ci-v1.0.2` (`3439217`). `ci-v1.0.0` and `ci-v1.0.1` stay where they were tagged.

## Per repository

| Repository | Last concluded phase | Stopped at |
|---|---|---|
| `ci-workflows` | 0 | Phase 2 coverage ratchet is on `main` and tagged `ci-v1.0.2` ([#3](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/3)). Phases 3–11 have no workflow here yet |
| `auth-service` | 1 | Phase 2 coverage and `CODEOWNERS` are on `main` ([#8](https://github.com/Deepidoo-s-new-age/auth-service/pull/8), `6dd8c18`). Stopped on branch protection: the org plan is Free, and GitHub refuses protection on a private repository |
| `platform-api` | 1 | Phase 2 coverage is on `main` ([#52](https://github.com/Deepidoo-s-new-age/platform-api/pull/52), `4aa99bc`). Stopped on the same branch-protection limit |
| `deepidoo-contracts` | — | Phase 2 caller, coverage, and `CODEOWNERS` are on `main` ([#127](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/127), [#128](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/128), `8c6372c`). The phase is not concluded: `main` cannot be protected on the Free plan. Phase 3 has not started |
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

- Branch protection on `auth-service`, `platform-api`, and `deepidoo-contracts`. The account is admin on those repositories. GitHub still refuses the protection API with “Upgrade to GitHub Pro or make this repository public”, because `Deepidoo-s-new-age` is on the Free plan and the repositories are private. Protection of a private repository needs GitHub Team. Once that plan is on, protect `main` with a required pull request, required check `test / test` (strict), and no force-push. `auth-service` and `deepidoo-contracts` also require a review from code owners. `CODEOWNERS` is already on `main` and is not enforced until that setting exists.
- Shared CI on the other non-empty repositories. They were left uncloned.

`CODEOWNERS` for `helm-charts` production values waits until that repository has values.

## Phases not started

| Phase | Where the plan stops |
|---|---|
| 3 | `deepidoo-contracts` is still a path checkout. No tag publish, no service lockfile points at a version, `checkout_contracts` is still on |
| 4 | `deesplay` is still `@deepidoo/deesplay` in `Deepidoo`. `auth-service` has no `web` job |
| 5 | `tools/validate_architecture.py` is not a CI job. No `security.yml`, no import-linter |
| 6 | `helm-charts` has no charts and no values. Image jobs stay at `push: false` |
| 7–11 | Depend on phase 6, or are optional (phase 10) |
