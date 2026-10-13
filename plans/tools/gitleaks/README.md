# gitleaks

The French version is [README.fr.md](README.fr.md).

## Purpose

Find secrets committed in the tree: tokens, private keys, passwords.

## Problem it resolves

A JWT secret or a kubeconfig in a pull request becomes a credential the moment it reaches GitHub. This is the OWASP 2025 A04 check that does not require reading the code’s logic.

## How we use it

Phase 0, first step of every shared workflow, version 8.30.1.

```bash
gitleaks detect --source "$GITHUB_WORKSPACE" --no-git --redact --exit-code 1
```

`--no-git` scans the files in the checkout. Pull requests are shallow, so a history scan would miss the point and cost time. `--redact` keeps the secret out of the log.

## Installation

Every shared workflow downloads the 8.30.1 release binary onto the runner. It is a standalone executable, separate from the Python and npm lockfiles.

## Constraints

It misses a secret that does not match a pattern, and it can flag a test fixture. Inert values in the workflow (`ci-test-secret`) were checked against 8.30.1 and did not match. A new fixture that looks like a real key needs an allowlist entry with a reason.

## Pros

No server. Runs before install, so a secret fails the job even when tests fail later.

## Cons

File scan does not see secrets that were committed and then deleted. A one-off history scan on the repo is a separate task when a leak is suspected.

## Alternatives

trufflehog, GitHub secret scanning. gitleaks is the check we own in CI. GitHub’s product is extra, and on private repos it is part of a paid plan.
