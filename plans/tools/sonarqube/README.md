# SonarQube Community Build

The French version is [README.fr.md](README.fr.md).

## Purpose

A self-hosted dashboard of code quality on `main`: issues, duplication, coverage imported from CI.

## Problem it resolves

Some people want one screen for “how is this repo?” across services. The pull request already has ruff, pytest, and Semgrep. Sonar does not replace those. It is optional, phase 10.

## How we use it

Community Build is free to self-host. One server in preproduction, its own Postgres, chart `helm-charts/charts/sonarqube`. The scanner is `ci-workflows` `sonarqube.yml`, called on `main` after tests. `auth-service` and `platform-api` call it. Each repo has `sonar-project.properties` and one Sonar project. The job imports `coverage.xml`. `sonar.qualitygate.wait` is false, so a red Sonar gate does not fail the job and does not block merge. GitHub checks do. The job is not in the image or promote `needs` list.

## Installation

The server is `sonarqube:26.11.0.134175-community` plus `charts/postgres` release `sonarqube-postgres` (database `sonar`). Argo CD applications `preproduction-sonarqube-postgres` and `preproduction-sonarqube`. The debug URL is `http://sonarqube.preproduction.51.178.114.227.sslip.io`.

The scanner is `SonarSource/sonarqube-scan-action` `v8.5.0` in `sonarqube.yml`, pin `ci-v1.0.23` after **Actions → Tag ci release** on `ci-workflows` `main`.

GitHub organization `Deepidoo-s-new-age`:

| Name | Kind | Value |
|---|---|---|
| `SONAR_TOKEN` | Actions secret | Global Analysis Token from the SonarQube UI (My Account → Security), created after the first login |
| `SONAR_HOST_URL` | Actions variable | `http://sonarqube.preproduction.51.178.114.227.sslip.io` |

First UI login is `admin` / `admin`. SonarQube then requires a new password. That password is not stored in git. The chart database password is the inert placeholder `sonar`.

## Constraints

Community Build analyzes the main branch. Pull-request analysis and decoration are a paid edition. It runs one analysis at a time, so many repos finishing together will queue. It needs its own Postgres and upgrades. Its security rules are shallower than Semgrep, and it does not do the cross-file taint analysis people expect from a paid SAST tool. Do not make it the OWASP scanner.

## Pros

One UI. Coverage from the CI job we already produce. No per-seat fee for the community build.

## Cons

A server to operate for a view that is not a gate. The queue hurts if every repo scans at once.

## Alternatives

Nothing. The CI checks are the alternative, and they are the gate. Add Sonar only for the dashboard.
