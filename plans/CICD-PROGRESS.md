# CI/CD progress — Deepidoo-s-new-age

Status of [CICD-PLAN.md](CICD-PLAN.md) as of 26 October 2026, 13:40 UTC. Git, GitHub, and the cluster were read for this status.

A phase is concluded for a repository when that phase’s finish line is true for it. A later phase that is not started leaves the repository stopped at the last concluded phase.

**Branch rulesets are not enforced, and the plan goes on without them.** The organization is on the GitHub Free plan. The ruleset and branch-protection APIs return `403 Upgrade to GitHub Pro` on every private repository. Phase 2 asks for a required check, no direct pushes to `main`, and code-owner review. Those rules cannot be enforced today. They are counted as an accepted exception, not as a blocker: a phase whose only open item is ruleset enforcement counts as concluded. The repositories that need a ruleset once the plan allows it are listed in [Rulesets waiting on the GitHub plan](#rulesets-waiting-on-the-github-plan).

How a change reaches preproduction and production is [helm-charts/docs/deploying.md](https://github.com/Deepidoo-s-new-age/helm-charts/blob/main/docs/deploying.md). Rebuilding the cluster is [helm-charts/docs/cluster.md](https://github.com/Deepidoo-s-new-age/helm-charts/blob/main/docs/cluster.md). A pull-request preview is [helm-charts/docs/previews.md](https://github.com/Deepidoo-s-new-age/helm-charts/blob/main/docs/previews.md).

## Program

| Phase | Status |
|---|---|
| 0 — Shared workflows | Concluded |
| 1 — Prove the caller | Concluded for `auth-service` and `platform-api` |
| 2 — Callers, protection, coverage | Concluded for the cloned repositories, with the ruleset exception. The six uncloned repositories with code still have no shared caller |
| 3 — Publish `deepidoo-contracts` | Concluded for the cloned consumers. The release is git tag `v0.1.0`. Renovate is configured and waits for the GitHub App |
| 4 — deesplay | Concluded for `Deepidoo-s-new-age/deesplay` and the `auth-service` web job |
| 5 — Architecture and security gates | Finish line met on the cloned repositories. The nightly preproduction smoke is still absent |
| 6 — `helm-charts` and promotion | Concluded. Argo CD `v3.5.6` applies `main`. Production values carry the digests promoted on 26 October. Preproduction values are newer; production moves only when **Promote to production** runs |
| 7 — Preview environments | Open. A labeled pull request served a URL, and removing the label deleted the namespace. The fixture user is in open pull requests, and the real preview domain is still absent |
| 8 — Telemetry and uptime | Not started |
| 9 — Supply chain | Not started |
| 10 — SonarQube | Not started |
| 11 — Agent loop | Not started |

`ci-workflows` tags: `ci-v1.0.9` (`22a4d53`, [#10](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/10)) fetches the architecture validator at `.github` commit `ce47fb1` instead of the default branch. The architecture jobs of `auth-service` and `platform-api` pin it since [auth-service #21](https://github.com/Deepidoo-s-new-age/auth-service/pull/21) and [platform-api #62](https://github.com/Deepidoo-s-new-age/platform-api/pull/62). `ci-v1.0.8` (`8a915cc`, [#9](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/9)) adds the same-commit OpenAPI compare. It was tagged on 26 October, after the examples on `main` already named it. `ci-v1.0.7` (`7e9c789`) compares OpenAPI with the base commit. `ci-v1.0.6` (`669ec5a`) is the test and security jobs. `ci-v1.0.5` (`aeb5c98`) is the Vue caller. `ci-v1.0.3` (`1771088`) is the image job. `deepidoo-contracts` tests stay on `ci-v1.0.2`. `ci-v1.0.4` writes the npm auth file but leaves `GITHUB_TOKEN` unset under `set -u`. `deepidoo-contracts` `v0.1.0` is `cab3c24`. `@deepidoo-s-new-age/deesplay` `1.0.1` is tag `v1.0.1` (`dc39440`).

## Per repository

| Repository | Last concluded phase | Stopped at |
|---|---|---|
| `ci-workflows` | 5 | `main` is `22a4d53` = `ci-v1.0.9` ([#10](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/10), pin the validator, refresh the FastAPI example) |
| `auth-service` | 6 | `main` is `40b71ff` ([#21](https://github.com/Deepidoo-s-new-age/auth-service/pull/21)), green. Its image is proposed for preproduction in [helm-charts #19](https://github.com/Deepidoo-s-new-age/helm-charts/pull/19). Preproduction values carry `91e9e8c` ([#20](https://github.com/Deepidoo-s-new-age/auth-service/pull/20)); production values carry `b85aa3e` ([#18](https://github.com/Deepidoo-s-new-age/auth-service/pull/18)). [#22](https://github.com/Deepidoo-s-new-age/auth-service/pull/22) seeds the preview fixture user and is open |
| `platform-api` | 6 | `main` is `84b790a` ([#62](https://github.com/Deepidoo-s-new-age/platform-api/pull/62)), green. Its image is proposed for preproduction in [helm-charts #20](https://github.com/Deepidoo-s-new-age/helm-charts/pull/20). Preproduction values carry `0042463` ([#61](https://github.com/Deepidoo-s-new-age/platform-api/pull/61)); production values carry `5e0f50c` ([#60](https://github.com/Deepidoo-s-new-age/platform-api/pull/60)) |
| `deepidoo-contracts` | 5 | Semgrep is on `main` ([#130](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/130), `7b1394c`). No HTTP API, so no architecture job. Tag `v0.1.0` unchanged. [#131](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/131) (drop `test-lib`) is still open |
| `helm-charts` | 6 | `main` is `ead14c6` ([#18](https://github.com/Deepidoo-s-new-age/helm-charts/pull/18)). Argo CD applies it. Preproduction digest pull requests [#19](https://github.com/Deepidoo-s-new-age/helm-charts/pull/19) and [#20](https://github.com/Deepidoo-s-new-age/helm-charts/pull/20) are open. [#21](https://github.com/Deepidoo-s-new-age/helm-charts/pull/21) turns the fixture flag on for the auth-service preview and is open. Head branches are deleted after merge |
| `deesplay` | 5 | Package `1.0.1` unchanged. Semgrep is on `main` ([#1](https://github.com/Deepidoo-s-new-age/deesplay/pull/1), `1100f3e`) |
| `.github` | 5 | Holds this plan and `tools/validate_architecture.py` (`ce47fb1`). CI for the validator tests is on `main` ([#7](https://github.com/Deepidoo-s-new-age/.github/pull/7)). [#8](https://github.com/Deepidoo-s-new-age/.github/pull/8) records the first preview |
| `menuboards`, `deep_desk`, `scheduler`, `tickets`, `roadmap`, `epaper` | — | Stopped before phase 2. No shared caller. Left uncloned on purpose |
| `messaging`, `call_me_maybe`, `converter` | — | Stopped before phase 2. A caller is copied from `ci-workflows/examples/` when they hold code |
| `Deepidoo/deesplay` | — | Left untouched. Legacy repositories still depend on `@deepidoo/deesplay` |

## Rulesets waiting on the GitHub plan

Saved, not enforced, on `auth-service`, `platform-api`, `deepidoo-contracts`, and `ci-workflows`: required pull request, required check `test / test` (strict; `lint` on `ci-workflows`), no force-push, no deletion, and code-owner review on `auth-service` and `deepidoo-contracts`.

Still to add when the plan allows it:

- `helm-charts`: required pull request, required check `lint`, and code-owner review. `CODEOWNERS` for `environments/production/` is on `main` ([#18](https://github.com/Deepidoo-s-new-age/helm-charts/pull/18)). Without this ruleset, whoever merges a production pull request is its only reviewer.
- `.github`: required check `test` once its CI is on `main`.
- `deesplay`: required pull request and the Semgrep check.
- A required reviewer on the `production` environment of `helm-charts` gates nothing under Argo CD, because no workflow deploys from it. The production gate is the `helm-charts` ruleset above.

What the missing enforcement already allowed: eight commits went to `auth-service` `main` without a pull request on 16 and 19 October (`06a44df`, `f03523d`, `f117dba`, `0347196`, `21056c5`, `4e51fcb`, `45bf292`, `7b701bc`). Six of those `main` runs were red. The current `main` run (`40b71ff`) is green.

## Fixes before the first preview

Found while checking phases 0 to 6 on 26 October. Each fix stays inside the plan. All are merged.

| Pull request | Fixes |
|---|---|
| [auth-service #21](https://github.com/Deepidoo-s-new-age/auth-service/pull/21), [platform-api #62](https://github.com/Deepidoo-s-new-age/platform-api/pull/62) | The promote job fetched `promote/<service>` without the auth header, so a push to an existing branch was rejected. That failed the `main` run of [auth-service #19](https://github.com/Deepidoo-s-new-age/auth-service/pull/19): image `sha256:577a31…` never reached preproduction. After both merges, the promote jobs opened [helm-charts #19](https://github.com/Deepidoo-s-new-age/helm-charts/pull/19) and [#20](https://github.com/Deepidoo-s-new-age/helm-charts/pull/20). Those branches were new, so the update of an existing promote branch is first exercised by the next `main` push while #19 or #20 is open. **Run workflow** on Preview now publishes the image; before, it only added a label GitHub ignores. Images move from floating `python:3.14-slim` to `python:3.12.15-slim-trixie` with `uv==0.12.23`, the versions CI tests. The architecture job moves to `ci-v1.0.9` |
| [helm-charts #18](https://github.com/Deepidoo-s-new-age/helm-charts/pull/18) | `charts/preview-namespace` gives each preview a managed Namespace (deleted with the Application on close), the quota, and an egress NetworkPolicy that keeps previews out of `production`. Production reads the optional hand-made Secret `runtime-env`, so its `JWT_SECRET` can leave git. `CODEOWNERS` for production values. Rollback documented as a digest pull request, not `helm rollback`. Sweeper image pinned |
| [ci-workflows #10](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/10) | `architecture.yml` fetched the validator from the `.github` default branch, so a `.github` merge changed every caller's gate without a tag. It now fetches commit `ce47fb1`. The FastAPI example pins current tags and grants `packages: write` only to the image job. Tagged `ci-v1.0.9` (`22a4d53`) |
| This `.github` pull request | CI for `tools/test_validate_architecture.py` (17 tests), which ran nowhere, with actions pinned by commit. This status |

Done outside a pull request on 26 October: tags `ci-v1.0.8` on `ci-workflows` `8a915cc` and `ci-v1.0.9` on `22a4d53`, and **Automatically delete head branches** on `helm-charts`.

Manual steps from [helm-charts #18](https://github.com/Deepidoo-s-new-age/helm-charts/pull/18), done on 26 October from the cluster kubeconfig:

1. Secret `runtime-env` exists in `production`. Both deployments were restarted and came back ready. The value is not in git ([cluster.md](https://github.com/Deepidoo-s-new-age/helm-charts/blob/main/docs/cluster.md) section 2b).
2. The `sh.helm.release.v1.*` Secrets were deleted from `preproduction` and `production` (section 7). None remain.
3. From a pod in `pr-auth-service-22`, TCP to `postgres:5432` in that namespace opened. TCP to `postgres.production.svc.cluster.local:5432` and to `postgres.preproduction.svc.cluster.local:5432` timed out. The cluster runs Canal, so NetworkPolicy is enforced.

## Debt and deviations from the plan

Recorded here so the plan text stays the target:

- **Contracts release.** The plan publishes `deepidoo-contracts` to GitHub Packages. GitHub Packages does not host Python, so the release is a git tag (phase 3).
- **Apply path.** Phase 6 steps 4 and 9 are done in the order the plan allows: Argo CD replaced the Helmfile apply. The helmfiles remain only as a CI render check. Phase 7's "`helmfile destroy` on close" is implemented as an Argo CD pull-request generator whose Application finalizer deletes the namespace.
- **Preview address.** Previews use `http://pr-<service>-<number>.preview.51.178.114.227.sslip.io`. The first preview answered `GET /health` with 200 on that name. The plan's `*.preview.<domain>` record, the wildcard certificate, and cert-manager are not in place: there is no domain and no DNS-01 credential to issue them with. This still belongs to phase 7.
- **Fixture user.** [auth-service #22](https://github.com/Deepidoo-s-new-age/auth-service/pull/22) and [helm-charts #21](https://github.com/Deepidoo-s-new-age/helm-charts/pull/21) add the seed hook for both services. A preview runs it. Preproduction has the source and leaves it off until the digest contains `python -m app.seeds`. The hook clears every ordinary table and leaves `alembic_version` in place. `auth-service` then inserts `admin@auth-demo.local`. `platform-api` has no seed rows yet. Production does not run it. The pull requests are open.
- **Shared preview workflow.** The preview image build is a copy in each service, not a reusable workflow in `ci-workflows`. Move it there before a third service gets a preview.
- **Secrets in git.** The Postgres password and `JWT_SECRET` are inert placeholder values in git for every namespace. `runtime-env` ([#18](https://github.com/Deepidoo-s-new-age/helm-charts/pull/18)) is the interim for production. SOPS or External Secrets is phase 9. Changing the Postgres password also needs `ALTER USER` on the existing volume.
- **Cluster.** Preproduction and production run on the cluster whose kubeconfig is `configs/stress-test.yml`, next to the `tsm-*` and `new-age-load` namespaces.
- **No migrations yet.** No migration runs: neither service has an Alembic command, and `charts/job` has no Argo CD Application.
- **Baselines act as a waiver list.** Foundations have no `docs/module.yaml`, so their architecture baseline is used as a waiver list. `auth-service` added three `/v1/acl/modules` routes to it in `f117dba`.
- **Renovate.** The GitHub App is not installed, so `renovate.json` opens nothing.

## What is already on `main`

### Phase 0 — `ci-workflows`

Concluded. Workflows are on `main`, `ci.yml` is green, and `ci-v1.0.0` exists ([#1](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/1)). `ci-v1.0.1` ([#2](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/2)) authenticates the contracts clone with Basic auth. `ci-v1.0.2` ([#3](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/3)) adds the coverage ratchet.

### Phase 1 — callers

Concluded for both repositories named in that phase. At the end of this phase the image job was `push: false`. Phase 6 later publishes both images from `main`.

| Repository | Merged | `main` at the time |
|---|---|---|
| `auth-service` | [#6](https://github.com/Deepidoo-s-new-age/auth-service/pull/6) | `626bca2`. Push run [38410328373](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38410328373) green. `docker.yml` removed. No `web` job |
| `platform-api` | [#51](https://github.com/Deepidoo-s-new-age/platform-api/pull/51) | `20dae16`. Push run [38700625143](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38700625143) green. `docker.yml` removed. Caller uses `working_directory: .` and `context: .` |

### Phase 2 — callers and coverage

Concluded for the cloned repositories, with the ruleset exception above. Still open for the six uncloned repositories with code.

| Repository | Merge | `main` push |
|---|---|---|
| `auth-service` | [#8](https://github.com/Deepidoo-s-new-age/auth-service/pull/8) `6dd8c18`. Floor `64.8` at merge, `64.9` on `main` now. `CODEOWNERS` for `@Deepidoo-s-new-age/devs` | [38706977417](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38706977417) |
| `platform-api` | [#52](https://github.com/Deepidoo-s-new-age/platform-api/pull/52) `4aa99bc`. Floor `87.1` | [38706979751](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38706979751) |
| `deepidoo-contracts` | [#127](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/127) caller, [#128](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/128) `8c6372c`. Floor `98.6`. `CODEOWNERS` for `@Deepidoo-s-new-age/devs` | [38706985686](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/actions/runs/38706985686) |

### Phase 3 — git tag, cloned repositories

GitHub Packages does not host Python, so the release is the git tag. Both service lockfiles pin `deepidoo-contracts` `v0.1.0` (`cab3c24`). Their image jobs skip the contracts clone.

| Repository | What landed |
|---|---|
| `ci-workflows` | [#4](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/4), tag `ci-v1.0.3`. `checkout_contracts: false` authenticates git for `uv sync` and passes BuildKit secret `github_token` |
| `deepidoo-contracts` | [#129](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/129), tag `v0.1.0`. Release run [38708105137](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/actions/runs/38708105137) green |
| `auth-service` | [#9](https://github.com/Deepidoo-s-new-age/auth-service/pull/9) `8e411da`. Main run [38708608432](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38708608432) green |
| `platform-api` | [#53](https://github.com/Deepidoo-s-new-age/platform-api/pull/53) `9bc07ad`. Main run [38708615186](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38708615186) green |

### Phase 4 — deesplay on GitHub Packages

`Deepidoo-s-new-age/deesplay` is a copy of branches `main` and `dev` of `Deepidoo/deesplay`. The package is `@deepidoo-s-new-age/deesplay`.

| What | Where |
|---|---|
| Rename and release workflow | `a36efe4`. Tag `v1.0.0` published `1.0.0` |
| Source typechecks in a consuming app | `dc39440`. Tag `v1.0.1` published `1.0.1`. Release run [38712991821](https://github.com/Deepidoo-s-new-age/deesplay/actions/runs/38712991821) green |
| Vue install auth | [#5](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/5) `ci-v1.0.4`, then [#6](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/6) `ci-v1.0.5` |
| `auth-service` web job | [#10](https://github.com/Deepidoo-s-new-age/auth-service/pull/10) `1a83a47`. `run_build` is false. No frontend image |

The admin UI depends on `@deepidoo-s-new-age/deesplay` `1.0.1`, with no sibling alias in `vite.config.ts`. The web job passes `SCHEMAS_READ_TOKEN` as `packages_read_token`, because the caller `GITHUB_TOKEN` is denied `read_package`. `frontend/.npmrc` sets the scope registry, `legacy-peer-deps` (for the `pdfjs-dist` 6.x pin), and `min-release-age=7`.

### Phase 5 — routes, OpenAPI, Semgrep, imports

The architecture job fails when a route is missing from `docs/module.yaml` and is not listed in `docs/architecture-baseline.txt`. `auth-service` has 20 baselined gaps (19 routes and `missing-module-yaml`), and `platform-api` has 92. Neither foundation has a module contract. Both committed `docs/openapi.json` files matched the generated spec on 26 October, so the same-commit compare (`ci-v1.0.8` and later) does not turn the callers red; [auth-service #21](https://github.com/Deepidoo-s-new-age/auth-service/pull/21) and [platform-api #62](https://github.com/Deepidoo-s-new-age/platform-api/pull/62) merged green on `ci-v1.0.9`.

`python-service.yml` at `ci-v1.0.6` runs `lint-imports` when `[tool.importlinter]` is present. Route handlers may not import SQLAlchemy. `auth-service` also forbids `app.models` in handlers, and `platform-api` forbids `app.repositories`. Each service forbids importing the other through an empty dev stub, which the production image does not contain ([auth-service #12](https://github.com/Deepidoo-s-new-age/auth-service/pull/12), [platform-api #55](https://github.com/Deepidoo-s-new-age/platform-api/pull/55)). dependency-cruiser runs in the `auth-service` web job.

Semgrep 1.181.0 runs `p/owasp-top-ten`, `p/python`, and `p/javascript` against the base commit, or `HEAD^` on `main`.

| Repository | Merge | `main` push |
|---|---|---|
| `.github` | [#1](https://github.com/Deepidoo-s-new-age/.github/pull/1) `9cb93f8`, parser follow-up [#3](https://github.com/Deepidoo-s-new-age/.github/pull/3) `ce47fb1` | No workflow until this pull request |
| `ci-workflows` | [#7](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/7) `ci-v1.0.6`, [#8](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/8) `ci-v1.0.7`, [#9](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/9) `ci-v1.0.8`, [#10](https://github.com/Deepidoo-s-new-age/ci-workflows/pull/10) `ci-v1.0.9` | `ci.yml` green on `22a4d53` |
| `auth-service` | [#11](https://github.com/Deepidoo-s-new-age/auth-service/pull/11) `2ffecdb` | [38740934316](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/38740934316) green |
| `platform-api` | [#54](https://github.com/Deepidoo-s-new-age/platform-api/pull/54) `876c889` | [38740943465](https://github.com/Deepidoo-s-new-age/platform-api/actions/runs/38740943465) green |
| `deepidoo-contracts` | [#130](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/pull/130) `7b1394c` | Test [38740953222](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/actions/runs/38740953222) and Semgrep [38740953570](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/actions/runs/38740953570) green |
| `deesplay` | [#1](https://github.com/Deepidoo-s-new-age/deesplay/pull/1) `1100f3e` | Semgrep [38740962330](https://github.com/Deepidoo-s-new-age/deesplay/actions/runs/38740962330) green |

Not done: the nightly preproduction smoke (login, call a module, the module calls `platform-api`).

### Phase 6 — charts and promotion

Concluded. Preproduction and production are two namespaces on one cluster. Each runs Postgres `18.6`, Redis `7.4.2`, `auth-service`, and `platform-api`. On the morning of 26 October, Argo CD reported all nine Applications `Synced` and `Healthy`, with both namespaces on the production digests below. [helm-charts #16](https://github.com/Deepidoo-s-new-age/helm-charts/pull/16) and [#17](https://github.com/Deepidoo-s-new-age/helm-charts/pull/17) then moved preproduction one image ahead. The values files on `main` (`ead14c6`) now hold:

| Namespace | Service | Digest | Built from |
|---|---|---|---|
| `preproduction` | `auth-service` | `sha256:420183f31d34ba5f091d35d0b8afafe754c62c1794ea84910cf77bbfb68d7046` | `91e9e8c` ([#20](https://github.com/Deepidoo-s-new-age/auth-service/pull/20)) |
| `preproduction` | `platform-api` | `sha256:9b5b970a56d34ed11cb37dcdaa11c0162f0069b04d04aee4d21e2b73ccda61d4` | `0042463` ([#61](https://github.com/Deepidoo-s-new-age/platform-api/pull/61)) |
| `production` | `auth-service` | `sha256:93ebaa5d643073b26f6725958c94cbbcec9503b8558085c8a113724948331496` | `b85aa3e` ([#18](https://github.com/Deepidoo-s-new-age/auth-service/pull/18)) |
| `production` | `platform-api` | `sha256:000a61d007ef0ce4c32aa4fe310963a493bdd56bceea713c41ff9640bcb9d9d8` | `5e0f50c` ([#60](https://github.com/Deepidoo-s-new-age/platform-api/pull/60)) |

Waiting for preproduction: `auth-service` `sha256:d80e64a307a1640da0db4733c6cfa8594e3fa106c55e31032956e730a446165d` from `40b71ff` ([helm-charts #19](https://github.com/Deepidoo-s-new-age/helm-charts/pull/19)) and `platform-api` `sha256:66ac2af9948f5788e0938e235e9781a756b524fca2a85af95508befc20347989` from `84b790a` ([helm-charts #20](https://github.com/Deepidoo-s-new-age/helm-charts/pull/20)). These are the first images on Python 3.12.

A push to `main` in a service publishes `ghcr.io/deepidoo-s-new-age/<service>:<git-sha>` (`push: true` only on `main`, `packages: write` on the image job) and opens or updates `Set the <service> preproduction digest` in `helm-charts`, using the repository secret `HELM_CHARTS_TOKEN`. Merging it makes Argo CD apply namespace `preproduction`. **Promote to production** ([#9](https://github.com/Deepidoo-s-new-age/helm-charts/pull/9)) copies the selected preproduction digests into one production pull request. [#10](https://github.com/Deepidoo-s-new-age/helm-charts/pull/10) and [#11](https://github.com/Deepidoo-s-new-age/helm-charts/pull/11) put production on the production digests above.

Argo CD `v3.5.6` in namespace `argocd` applies `main` ([#12](https://github.com/Deepidoo-s-new-age/helm-charts/pull/12)). `helm-charts` lists no repository secrets; the secrets of its `preproduction` and `production` environments were not listed. No service repository contains `kubectl`. The clone credential is the read-only deploy key `argocd-helm-charts`. The kubeconfig stays in gitignored `configs/`. Repeating the install is [docs/cluster.md](https://github.com/Deepidoo-s-new-age/helm-charts/blob/main/docs/cluster.md) ([#13](https://github.com/Deepidoo-s-new-age/helm-charts/pull/13)).

The migration job is off: neither service has an Alembic command. `auth-service` creates schema `auth` on startup.

## Phase 7 — preview namespaces

Open. On `main`:

- `helm-charts` ([#14](https://github.com/Deepidoo-s-new-age/helm-charts/pull/14), docs corrected in [#15](https://github.com/Deepidoo-s-new-age/helm-charts/pull/15)): AppProject `preview`, ApplicationSets `preview-auth-service` and `preview-platform-api`, and CronJob `preview-sweeper`. Secret `preview-github` is present in namespace `argocd`. Its value was not read.
- [helm-charts #18](https://github.com/Deepidoo-s-new-age/helm-charts/pull/18): each preview Application first syncs `charts/preview-namespace` (Namespace, quota, egress NetworkPolicy).
- [auth-service #20](https://github.com/Deepidoo-s-new-age/auth-service/pull/20) and [platform-api #61](https://github.com/Deepidoo-s-new-age/platform-api/pull/61), corrected by [#21](https://github.com/Deepidoo-s-new-age/auth-service/pull/21) and [#62](https://github.com/Deepidoo-s-new-age/platform-api/pull/62): adding the label `preview` on the pull request page, or **Run workflow** on Preview with the pull request number, publishes `ghcr.io/deepidoo-s-new-age/<service>:<head sha>`. Fork pull requests are refused.

A preview namespace is `pr-<service>-<number>`, with its own Postgres and Redis. `platform-api` calls `auth-service` in preproduction. The URL is `http://pr-<service>-<number>.preview.51.178.114.227.sslip.io`. The sweeper copies Secret `ghcr` from preproduction into each preview namespace and expires previews at 96 hours.

Checked on the cluster on 26 October. [auth-service #22](https://github.com/Deepidoo-s-new-age/auth-service/pull/22) was labeled `preview`. The image job [40331430430](https://github.com/Deepidoo-s-new-age/auth-service/actions/runs/40331430430) published `ghcr.io/deepidoo-s-new-age/auth-service:edf7cc739c12f4dae46cfd58db015cf57c6181fa`. Argo CD created Application `pr-auth-service-22`, Synced and Healthy, with Ingress host `pr-auth-service-22.preview.51.178.114.227.sslip.io`. `GET /health` returned 200 and `{"status":"ok"}`. Removing the label deleted the Application and the namespace. No preview namespace remains. The pull request stayed open, so this checked label removal, which uses the same generator as closing the pull request.

Still open: merge [#22](https://github.com/Deepidoo-s-new-age/auth-service/pull/22) and [helm-charts #21](https://github.com/Deepidoo-s-new-age/helm-charts/pull/21), then label again and log in as the fixture user. A real `*.preview.<domain>` name and its wildcard certificate wait on a domain.

## Phases not started

| Phase | Where the plan stops |
|---|---|
| 8–11 | Depend on a stable preproduction, or are optional (phase 10). |
