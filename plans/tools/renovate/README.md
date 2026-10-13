# Renovate

The French version is [README.fr.md](README.fr.md).

## Purpose

Open pull requests that bump dependencies, one grouped PR per repo per week for minors.

## Problem it resolves

pip-audit and npm audit say a version is vulnerable. They do not change the lockfile. A human hunting versions does not scale across this organization. OWASP A03 is mostly “we kept the old version”.

## How we use it

First when `deepidoo-contracts` is published (phase 3): a new version opens a PR in each consumer. Then org-wide: Python, npm, GitHub Actions, and Docker base images. Group minor and patch bumps. Major bumps stay separate. The PR still runs the shared CI. Merge is human.

## Installation

A GitHub App installed once on the `Deepidoo-s-new-age` organization. The schedule and package rules live in one shared Renovate config.

## Constraints

It needs a GitHub App or token that can open PRs. It must not push to `main`. It must not have the `production` environment. Pin the Renovate config in a repo the org shares, so every New Age repo does not invent a schedule.

## Pros

The bump is a normal pull request with the same checks as a feature.

## Cons

A noisy config creates a queue nobody reads. Grouping is the fix. A broken major bump can sit open. That is better than a silent skip.

## Alternatives

Dependabot. Renovate groups across ecosystems more clearly. Use Renovate, not both.
