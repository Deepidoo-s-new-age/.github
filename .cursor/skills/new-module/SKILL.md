---
name: new-module
description: >-
  Discovery and contract workflow for a New Age business module (capability,
  boundaries, API/UI surfaces, scopes, frontend choice). Generates docs/module.yaml,
  README and module-boundary Cursor rule. Use when creating a new New Age module
  or invoking /new-module. Not for generic greenfield — use /new-project instead.
disable-model-invocation: true
---

# New Module (New Age)

Créer un **module métier New Age** : capacité autonome, contrat YAML, frontières
avec `contracts` / `auth-service` / `platform-api`.

Cette skill **n'est pas** un greenfield générique. Pour un projet hors écosystème →
**`new-project`**.

Les conventions de stack (FastAPI, Vue, etc.) relèvent des règles du repo cible —
ne pas les re-rédiger ici. Suivre `docs/rules/` (règle module contract) et le
template `contracts/docs/module-contract.TEMPLATE.yaml`.

## Livrables (après validation)

| Fichier | Rôle |
|---|---|
| `{module-repo}/docs/module.yaml` | Contrat machine (copie remplie du template contracts) |
| `{module-repo}/README.md` | Présentation humaine |
| `{module-repo}/.cursor/rules/module-boundary.mdc` | Règle Cursor du module |

**Ne génère pas** au premier passage : code FastAPI/Vue, Helm, scopes dans
auth-service, intégration playdoo. Proposer une **checklist Phase 8** optionnelle
après génération des docs.

## Workflow

```
- [ ] Phase 0 — Prérequis New Age
- [ ] Phase 1 — Capability (métier)
- [ ] Phase 2 — Boundaries (données & dépendances)
- [ ] Phase 3 — Surface (API groups + UI routes + purpose)
- [ ] Phase 4 — Authz (scopes, rôles, M2M)
- [ ] Phase 5 — Frontend (frontend-web / play later / API only)
- [ ] Phase 6 — Synthèse + validation explicite
- [ ] Phase 7 — Génération docs
- [ ] Phase 8 — Checklist post-docs (optionnelle, pas de code auto)
```

Ne jamais écrire de fichiers avant validation Phase 6.

---

## Phase 0 — Prérequis

Confirmer :

1. Nouveau **module métier** New Age (pas une fondation `auth`/`platform`, pas un package UI).
2. Nom repo / `module_id` (snake_case).
3. Chemin local du futur (ou déjà créé) dépôt cible.
4. Accès au template : `deepidoo-contracts` → `docs/module-contract.TEMPLATE.yaml`.

Si le besoin est « outil autonome hors New Age » → basculer sur **`new-project`**.

---

## Phase 1 — Capability (langage métier)

1. **Objectif** — une phrase (outcome métier).
2. **Acteurs** — curator, client, admin, support…
3. **IN** — ce qui doit être vrai pour dire « c'est livré ».
4. **OUT** — hors capacité (player hardware, billing, autre module…).
5. **Pourquoi maintenant** — contrainte / opportunité.

---

## Phase 2 — Boundaries

1. **Données possédées** par le module (aggregates).
2. **Données seulement référencées** (UUID vers core / auth) — jamais de FK SQL croisée.
3. **Appels sortants** prévus : `auth-service`, `platform-api` (quels domaines), autres ?
4. **Interdits** : SQL autre service, import code applicatif d'un autre service, secrets en repo.

---

## Phase 3 — Surface (contrat)

Pour **chaque** groupe API et **chaque** route UI prévus (même MVP) :

| Champ | Obligatoire |
|---|---|
| `purpose` | 1–2 phrases — le job, pas les verbes HTTP |
| `actors` | qui l'utilise |
| `access` ou `api_groups` | scopes / mixte / currently_unprotected si honnête |
| `source` | chemin fichier cible (peut être provisoire) |
| `downstream` | si appel à un autre service |

Ne pas lister chaque méthode HTTP (OpenAPI plus tard).
Ne pas inventer une politique plus stricte que ce qui sera vraiment codé.

---

## Phase 4 — Authz

1. Scopes module proposés (forme actuelle `resource:read|write`, ex. `foo:read`).
2. Mapping rôles → scopes.
3. Scopes platform nécessaires (`content:read`, …) si forward Bearer / M2M.
4. Identité module M2M : oui / non / plus tard.
5. Rappeler : enregistrement des scopes dans **auth-service** = étape humaine après docs ;
   frontend scope enforcement = documenté, pas exigé.

---

## Phase 5 — Frontend

Choisir **une** option principale :

| Option | Quand |
|---|---|
| `frontend-web/` production | Client du module pour les utilisateurs finaux |
| Intégration `play` / playdoo **plus tard** | Capacité d'abord API + éventuellement front module |
| API seule | Consommateurs externes uniquement |

`playdoo` n'est **pas** le shell obligatoire. Si `frontend-web/` : qualité production
(auth réelle, erreurs, i18n, a11y, tests) — pas un proto jetable.

---

## Phase 6 — Synthèse

```markdown
## Récap module — [module_id]

**Objectif :** …
**Acteurs :** …
**IN / OUT :** …
**Données owns / references / forbidden :** …
**Outbound :** auth-service · platform-api · …
**Scopes :** …
**Front :** frontend-web | play later | API only

### Surfaces (extrait)
| Type | Path/prefix | Purpose | Actors | Access |
|---|---|---|---|---|
| API | /… | … | … | … |
| UI | /… | … | … | … |

### Fichiers à générer
- docs/module.yaml
- README.md
- .cursor/rules/module-boundary.mdc

### Hypothèses / risques
- …
```

_« Valides-tu ce récap ? Je génère uniquement les docs. »_

---

## Phase 7 — Génération

1. Copier le template contracts → `{module}/docs/module.yaml` et remplir.
2. Écrire `README.md` (métier + liens fondations + pointeur vers `docs/module.yaml`).
3. Écrire `.cursor/rules/module-boundary.mdc` (`alwaysApply: true`) — objectif, owns,
   scopes, front role, alignement YAML.

Ne pas stocker le contrat rempli dans `contracts`.

---

## Phase 8 — Checklist post-docs (proposer, ne pas exécuter sans demande)

- [ ] Créer le repo Git + clone workspace
- [ ] Enregistrer scopes / module identity dans `auth-service`
- [ ] Scaffold `backend/` (et `frontend-web/` si retenu) selon règles du repo
- [ ] Dépendance `deepidoo-contracts[auth,fastapi]`
- [ ] Entrée Helm si déploiement New Age
- [ ] Décision playdoo documentée dans `play_integration` du YAML

## Anti-patterns

- ❌ Feature folder dans playdoo « par défaut »
- ❌ Contrat rempli dans `contracts`
- ❌ Scopes inventés sans passage auth-service
- ❌ Générer tout le boilerplate avant validation du YAML
- ❌ Présenter une cible (`capability:action`, enforcement front) comme déjà faite
