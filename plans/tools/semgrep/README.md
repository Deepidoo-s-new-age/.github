# Semgrep Community Edition

The French version is [README.fr.md](README.fr.md).

## Purpose

Scan Python and Vue source for insecure patterns mapped to the OWASP Top 10.

## Problem it resolves

Tests prove the cases we wrote. They do not notice a new `subprocess` call built from a request, a hardcoded password, or a log line that prints a JWT. Semgrep is the code scanner for those patterns. The list we map it to is [OWASP Top 10:2025](https://owasp.org/Top10/2025/).

## How we use it

Phase 5, reusable workflow `security.yml`:

```bash
semgrep scan --error --config p/owasp-top-ten --config p/python --config p/javascript
```

Pin the CLI version. The engine is LGPL 2.1. The registry rules are free for internal use. If the first run is noisy, fail only on findings that are not in a committed baseline.

This job is aimed at A04 cryptographic failures, A05 injection, part of A01 (path traversal, open redirect, obvious SSRF), and part of A10 (fail-open, empty handlers). Access control tests and the architecture validator still own A01 and A07. pip-audit, Renovate, and Trivy own A03.

## Installation

The `security.yml` job installs a pinned Community Edition CLI on the runner: the official Semgrep Action, a pinned pip install, or a pinned container. Rules `p/owasp-top-ten`, `p/python`, and `p/javascript` are downloaded from the Semgrep registry when the job runs.

## Constraints

Community Edition looks inside one function. A bug that passes through several helpers needs the paid Pro engine, which we do not use. CodeQL is stronger on that data flow and is free only for public repositories. These service repos are private, so CodeQL is GitHub Code Security and is paid. Do not run bandit beside Semgrep. Do not treat SonarQube as this scanner.

## Pros

One job, no server, both languages, custom rules later if a team pattern should fail the build.

## Cons

False positives on the first run. Single-function analysis misses some real injection bugs. The rules license is for internal use, not for reselling a scanning service.

## Alternatives

CodeQL (paid here), SonarQube security rules (shallower), bandit (Python only, overlaps Semgrep). Semgrep CE is the free scanner that fits this pipeline.
