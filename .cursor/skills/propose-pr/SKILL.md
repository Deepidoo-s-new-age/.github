---
name: propose-pr
description: >-
  Opens a GitHub pull request from the current front-end work without merging.
  Use when the user says Propose PR, Ouvre une PR, Create PR, PR please, or
  asks to ship UI changes for review. For designers and product on Gedeon.
disable-model-invocation: false
---

# Propose PR (front / design)

Crée une **pull request de review**. Ne merge jamais. Ne pousse jamais sur `main`.

## Triggers

`Propose PR` · `Ouvre une PR` · `Create PR` · `PR please`

## Préconditions

1. Repo Git avec remote GitHub.
2. `gh` authentifié (sinon : expliquer en 1 phrase comment se connecter, stop).
3. Changements front uniquement (voir garde-fous). Si backend / infra touchés → **stop**, lister les fichiers hors périmètre, demander confirmation explicite avant de continuer.

## Garde-fous front

**Autorisé à committer** (selon le repo ouvert) :

- `frontend-web/**`
- `play/packages/playdoo/**`, `play/packages/play/**` (UI host)
- `deesplay/**` (composants UI seulement)
- docs UX (`docs/ux-design.md`, i18n UI, assets front)

**Interdit** (refuser le commit / la PR) :

- `backend/**`, migrations, Docker, Helm, `auth-service`, `platform-api`, `contracts` runtime
- secrets, `.env`, credentials

Si le module a `design_mode: frontend_only` dans `docs/module.yaml`, appliquer aussi **RULE-GLOBAL-DESIGN-MODE**.

## Workflow

```
- [ ] 1. Diff
- [ ] 2. Branche
- [ ] 3. Commit
- [ ] 4. Push
- [ ] 5. PR
- [ ] 6. Lien
```

### 1. Diff

```bash
git status
git diff
git diff --cached
git log -5 --oneline
git branch -vv
```

Rien à committer → le dire et stop.

### 2. Branche

Si déjà sur une branche feature ≠ default (`main`/`master`) → la garder.

Sinon :

```text
design/{prenom}/{slug-court}
```

- `{prenom}` = user git / context (camelia, luca, alexandre…)
- `{slug}` = 2–4 mots kebab-case depuis le sujet

```bash
git checkout -b design/{prenom}/{slug}
```

Base = branche default du remote.

### 3. Commit

- Stage **uniquement** les fichiers front autorisés.
- Message court, focus *why* (1–2 phrases). Style du repo (`git log`).
- HEREDOC :

```bash
git commit -m "$(cat <<'EOF'
Summary of why.

EOF
)"
```

Pas de `--no-verify` sauf demande explicite.

### 4. Push

```bash
git push -u origin HEAD
```

### 5. PR

```bash
gh pr create --title "…" --body "$(cat <<'EOF'
## Summary
- …

## Preview (Gedeon)
- Play / Music / webapp URL used (ex. http://camelia.play.me/…)

## Test plan
- [ ] Parcours UI vérifié dans le navigateur
- [ ] Pas de changement backend / infra dans le diff

EOF
)"
```

- **Ne pas** assigner de reviewer sauf si l’utilisateur le demande.
- **Ne pas** merge / squash / close.

### 6. Lien

Répondre avec **l’URL de la PR** uniquement (+ 1 ligne si CI déjà rouge).

## Hors scope

- Review code approfondie → skill `review-pr` (play) ou `pr-automation` (org)
- Création de module → `design-module` / `new-module`
- Fix CI → `fix-ci` (play)
