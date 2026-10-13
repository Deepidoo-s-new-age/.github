# SonarQube Community Build

The French version is [README.fr.md](README.fr.md).

## Purpose

A self-hosted dashboard of code quality on `main`: issues, duplication, coverage imported from CI.

## Problem it resolves

Some people want one screen for “how is this repo?” across services. The pull request already has ruff, pytest, and Semgrep. Sonar does not replace those. It is optional, phase 10.

## How we use it

Only if the team still wants that screen. Community Build is free to self-host. Point the scanner at `main` after tests and import `coverage.xml`. One project per repo. A red Sonar gate does not block merge. GitHub checks do.

## Installation

Optional. Community Build is a self-hosted server, its Helm chart or container, with its own Postgres. The scanner is a CI step on `main`, the scanner CLI or the official Action, and it imports `coverage.xml` from the test job.

## Constraints

Community Build analyzes the main branch. Pull-request analysis and decoration are a paid edition. It runs one analysis at a time, so many repos finishing together will queue. It needs its own Postgres and upgrades. Its security rules are shallower than Semgrep, and it does not do the cross-file taint analysis people expect from a paid SAST tool. Do not make it the OWASP scanner.

## Pros

One UI. Coverage from the CI job we already produce. No per-seat fee for the community build.

## Cons

A server to operate for a view that is not a gate. The queue hurts if every repo scans at once.

## Alternatives

Nothing. The CI checks are the alternative, and they are the gate. Add Sonar only for the dashboard.
