# PR Automation — New Age (Cursor)

Runbook pour l’Automation Cursor qui tourne à chaque PR sur les dépôts New Age.

## Objectif

Sur **PR opened** et **PR pushed** :

1. Valider les règles d’architecture New Age
2. Compléter `docs/module.yaml` sur **la même branche PR** si nécessaire (modules)
3. Poster une review de code sur la PR
4. Poster un récap Talkspirit (Dédé) via webhook — **depuis Cursor**, pas via GitHub Actions

```text
PR opened/pushed
  → Cursor Automation
  → validate rules
  → update module.yaml (same branch, if module)
  → PR review comments
  → Talkspirit (Dédé)
```

## Artefacts versionnés

| Fichier | Rôle |
|---|---|
| [prompts/pr-automation.md](../prompts/pr-automation.md) | Prompt à coller dans le dashboard |
| [.cursor/skills/pr-automation/SKILL.md](../.cursor/skills/pr-automation/SKILL.md) | Workflow détaillé |
| [.cursor/BUGBOT.md](../.cursor/BUGBOT.md) | Règles de review (Bugbot + agent) |
| [tools/talkspirit_pr_notify.py](../tools/talkspirit_pr_notify.py) | Notif Talkspirit (env secret) |
| `docs/rules/*.mdc` | Règles globales (SoT) |

Chaque dépôt New Age doit contenir un `.cursor/BUGBOT.md` (copie adaptée).

## Repos couverts

| Repo GitHub | Type |
|---|---|
| `Deepidoo-s-new-age/deepidoo-contracts` | fondation contracts |
| `Deepidoo-s-new-age/auth-service` | fondation auth |
| `Deepidoo-s-new-age/platform-api` | fondation platform |
| `Deepidoo/play_music_ai` | module métier |
| `Deepidoo/play` | client Play |
| `Deepidoo/deesplay` | design system |
| `Deepidoo/helm_charts` | déploiements |
| `Deepidoo/persistence` | données / dumps |

## Setup dashboard Cursor (checklist)

### 1. Secret Talkspirit

1. Talkspirit → Intégrations → **Webhook entrant** → groupe Tech (ou équivalent).
2. Copier l’URL `https://webhook.talkspirit.com/v1/incoming/…`
3. [cursor.com/agents](https://cursor.com/agents) (Cloud Agents) → secrets :
   - `TALKSPIRIT_WEBHOOK_URL` = l’URL
   - optionnel `TALKSPIRIT_ICON_URL` = `https://cdn.jsdelivr.net/gh/Alexandre-Cornu/dede-avatar@main/dede-256.png`

Ne jamais committer ces valeurs.

### 2. Créer l’Automation

1. Ouvrir [cursor.com/automations](https://cursor.com/automations) → New.
2. **Triggers** : Pull request opened + Pull request pushed.
3. **Environment** : multi-repo — ajouter les 8 dépôts ci-dessus (et le repo org `.github` si l’agent doit exécuter `tools/talkspirit_pr_notify.py` depuis ce clone).
4. **Tools** : Comment on PR (top-level + inline) ; write / push sur la branche PR ; shell / network pour le webhook.
5. **Prompt** : coller le contenu de [prompts/pr-automation.md](../prompts/pr-automation.md).
6. **Permission** : Team Owned (recommandé).
7. Activer l’Automation.

### 3. Bugbot (recommandé en complément)

Activer Bugbot sur les mêmes repos. Il lira `.cursor/BUGBOT.md` dans chaque dépôt.
Les `.cursor/rules/*.mdc` **ne s’appliquent pas** à Bugbot.

### 4. Test

1. Ouvrir une PR draft sur `play_music_ai` (petit changement de route ou de YAML).
2. Vérifier : commentaires PR, éventuel commit YAML sur la branche, message Talkspirit.
3. Pousser un commit sans changer le verdict → Talkspirit doit être **skipped** (throttle).

## Comportement YAML

- Uniquement sur les **modules** (présence / obligation de `docs/module.yaml`).
- Drift détecté → edit + commit + **push sur la branche de la PR**.
- Jamais de PR de suivi pour le YAML.
- Fondations / play / helm / persistence : commenter `N/A — no module.yaml`.

## Throttle Talkspirit

Poster si :

- premier run pour cette PR, **ou**
- le verdict global a changé (blocking ↔ OK, nouveaux bloquants).

Sinon : pas de post ; noter le skip dans le résumé PR.

## Limites connues

- Pas de sync auto dashboard ↔ GitHub : le prompt vit aussi dans `prompts/pr-automation.md`.
- PRs depuis un **fork** : non supportées par les triggers Cursor.
- Ce n’est **pas** un gate CI déterministe (voir [CI-CONTRACT-VALIDATION.md](CI-CONTRACT-VALIDATION.md) pour plus tard).
- Facturation = usage Cloud Agent.

## Dépannage

| Symptôme | Action |
|---|---|
| Pas de notif Talkspirit | Vérifier secret `TALKSPIRIT_WEBHOOK_URL` ; logs agent ; throttle |
| YAML non mis à jour | Confirmer que le repo est un module et que le diff touche routes/scopes |
| Pas de commentaires PR | Droits GitHub de l’Automation / Team Owned |
| Script introuvable | Inclure le repo `.github` dans l’environment multi-repo |
