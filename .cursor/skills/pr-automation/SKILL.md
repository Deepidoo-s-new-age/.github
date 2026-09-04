---
name: pr-automation
description: >-
  New Age PR automation workflow: validate architecture rules, update
  docs/module.yaml on the same PR branch when needed, post a code review, then
  notify Talkspirit (Dédé). Use on pull_request opened/pushed or /pr-automation.
disable-model-invocation: true
---

# PR Automation (New Age)

Triggered by Cursor Automation on **PR opened** and **PR pushed** across New Age repos.

Follow this order. Do not skip Talkspirit when the run completes successfully
(unless throttled — see below).

## Step 0 — Identify

1. Repo name and type: `contracts` | `auth-service` | `platform-api` | `module` | `play` | `deesplay` | `helm-charts` | `persistence`.
2. Read `.cursor/BUGBOT.md` in the repo.
3. Read applicable `.cursor/rules/*.mdc` if present (IDE rules — still useful for this agent).
4. Module? → also read `docs/module.yaml` when it exists.

## Step 1 — Validate rules

Check the PR diff against New Age architecture:

- No cross-service SQL / app-code imports.
- Auth: no duplicate JWT validation; no JWT issuance outside auth-service.
- No secrets in the diff.
- Naming: `deepidoo-contracts`, not `deepidoo-schemas`.
- Repo-specific boundaries from `BUGBOT.md`.

Post findings as PR comments (blocking vs suggestion).

## Step 2 — Module YAML (same PR branch)

**Only** if this is a business module (has or must have `docs/module.yaml`):

1. Compare routes/scopes/deps in the diff with `docs/module.yaml`.
2. If drift: **edit `docs/module.yaml`**, commit, **push to the PR branch** (same PR — never open a follow-up PR).
3. Every touched API/UI entry must keep `purpose`, `actors`, `access`|`api_groups`, `source`. Be honest about `currently_unprotected` / `mixed_by_endpoint`.
4. If not a module repo: comment briefly « N/A — no module.yaml » and continue.

Follow the spirit of `/update-module-contract` and `/review-module`.

## Step 3 — Code review

- Inline + summary comments.
- Do not invent stricter auth than the code.
- Call out missing tests for auth/behavior changes.

## Step 4 — Talkspirit recap

Run from the org `.github` clone when available:

```bash
python3 tools/talkspirit_pr_notify.py \
  --title "PR #N — {repo}: {short title}" \
  --url "{pr_html_url}" \
  --content "{recap}"
```

Requires env `TALKSPIRIT_WEBHOOK_URL` (Cloud Agent secret). Optional `TALKSPIRIT_ICON_URL`.

**Recap content** (French, concise):

- Lien PR + auteur + branche
- Verdict règles : OK / warnings / blocking
- YAML : updated / OK / N/A
- Review : 2–5 bullets max

**Author** : Dédé. Never mention CTO OS, vault paths, or internal assistant tooling.

### Throttle

On **PR pushed**: post to Talkspirit only if

- this is the first automation run for the PR, **or**
- the overall verdict changed (e.g. was blocking → now OK, or new blocking findings).

Otherwise skip Talkspirit and note « Talkspirit skipped (unchanged verdict) » in the PR summary comment.

## Anti-patterns

- Opening a second PR for YAML fixes
- Spamming Talkspirit on every push
- Hardening YAML access beyond what the code enforces
- Storing webhook URLs in the repo
