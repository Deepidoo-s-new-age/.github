# pip-audit

The French version is [README.fr.md](README.fr.md).

## Purpose

Fail the build when a locked Python dependency has a known vulnerability.

## Problem it resolves

A lockfile keeps builds reproducible. It also keeps a vulnerable version until someone bumps it. This job is that bump’s alarm. It maps to OWASP 2025 A03 (supply chain).

## How we use it

Phase 0, at the end of the Python workflows.

```bash
uv export --frozen --no-dev --no-hashes -o /tmp/requirements.txt
grep -v -E '^-e |^file:' /tmp/requirements.txt > /tmp/requirements.pypi.txt
uvx pip-audit -r /tmp/requirements.pypi.txt
```

Path dependencies such as `../../contracts` are stripped. They are our code, not a PyPI advisory. An allowlist is a committed file for a CVE we accept on purpose, with a reason and a removal date.

## Installation

The workflow runs `uvx pip-audit`, which downloads the tool into a throwaway environment for that step. The advisory database is fetched when the job runs. The requirements file it reads is exported from `uv.lock`.

## Constraints

It does not scan Debian packages inside the runtime image. Trivy does that in phase 9. It does not open the upgrade pull request. Renovate does that.

## Pros

Uses the lockfile we already commit. No extra account.

## Cons

A new advisory can turn `main` red without a code change. The allowlist is the escape hatch, not a silent skip.

## Alternatives

`uv audit` if a future uv release covers the same database, Safety, OSV-Scanner. One Python advisory tool is enough. pip-audit is that tool.
