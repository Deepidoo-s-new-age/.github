# actionlint

The French version is [README.fr.md](README.fr.md).

## Purpose

Check GitHub Actions workflow files for syntax errors, bad expressions, and shell mistakes before a workflow runs.

## Problem it resolves

A reusable workflow with a broken `if` or a missing input fails only when a service calls it. That failure looks like a service bug.

## How we use it

Phase 0. Job in `Deepidoo-s-new-age/ci-workflows` `.github/workflows/ci.yml`, on every pull request to that repo. Version 1.7.12. It lints `.github/workflows/*.yml` and `examples/*.yml`. ShellCheck runs too when it is installed on the runner.

## Installation

The shared workflow in `Deepidoo-s-new-age/ci-workflows` downloads release 1.7.12 onto the runner, as a pinned GitHub Action or the release archive. ShellCheck, when the job uses it, comes from the runner image.

## Constraints

It checks the workflow graph, not whether `uv sync` or Docker will succeed. It does not execute the called workflows.

## Pros

Fast, no server, catches the class of mistake that blocks every caller.

## Cons

ShellCheck coverage depends on the runner image. It does not know our custom inputs’ business meaning.

## Alternatives

`action-validator`, or pushing a draft workflow and reading the Actions error. actionlint is the one we run.
