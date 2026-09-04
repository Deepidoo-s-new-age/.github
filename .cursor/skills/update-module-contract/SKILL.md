---
name: update-module-contract
description: >-
  Update an existing New Age module docs/module.yaml when routes, purposes,
  actors, access, scopes, dependencies or owned data change. Use when adding or
  changing API/UI surfaces, or invoking /update-module-contract.
disable-model-invocation: true
---

# Update Module Contract

Mettre à jour `{module-repo}/docs/module.yaml` **dans le même changement** qu'une
évolution de surface (route, droit, dépendance, donnée).

## Quand l'utiliser

- Nouvelle route UI ou groupe API
- Changement de `purpose`, acteurs, accès / scopes
- Nouvel appel `platform-api` / `auth-service`
- Changement d'aggregates possédés

## Workflow

1. Lire le `docs/module.yaml` du module concerné.
2. Lire le code touché (handlers, router Vue) — ne pas inventer l'accès.
3. Proposer le **diff YAML** (entrées ajoutées / modifiées / retirées).
4. Vérifier chaque entrée API/UI a : `purpose`, `actors`, `access`|`api_groups`, `source`.
5. Si un groupe est mixte ou non protégé : le dire (`mixed_by_endpoint`, `currently_unprotected`).
6. Attendre OK, puis éditer le YAML (+ `module-boundary.mdc` si objectif/scopes changent).
7. Rappeler : nouveau scope → enregistrer dans `auth-service` ; OpenAPI pour les verbes HTTP.

## Ne pas faire

- Recréer le module ou le README entier
- Durcir l'auth dans le YAML au-delà du code
- Modifier `contracts` pour un contrat rempli
