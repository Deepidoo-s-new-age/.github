# Bienvenue chez New Age

New Age n’est **pas un monorepo**. C’est un ensemble de dépôts Git autonomes : chacun a son cycle de version, ses tests et son déploiement.

Ce README est la page d’accueil de l’organisation [Deepidoo-s-new-age](https://github.com/Deepidoo-s-new-age).

## Comment ça marche

```text
deepidoo-contracts     types + validation JWT utilisateur
        ↓
auth-service           seul émetteur JWT + ACL
        ↓
platform-api           cœur produit (orgs, spots, contents, …)
        ↓
modules métier         une capacité = un dépôt (API + front éventuel)
```

| Dépôt | Rôle |
|---|---|
| [deepidoo-contracts](https://github.com/Deepidoo-s-new-age/deepidoo-contracts) | Package Python partagé. Pas un service. Template YAML des modules : `docs/module-contract.TEMPLATE.yaml`. |
| [auth-service](https://github.com/Deepidoo-s-new-age/auth-service) | Login, refresh, révocation, JWT user et module, Casbin. |
| [platform-api](https://github.com/Deepidoo-s-new-age/platform-api) | API `/v1` du cœur. N’émet pas de JWT. |
| [play_music_ai](https://github.com/Deepidoo/play_music_ai) | Premier module métier (musique IA). Contrat : `docs/module.yaml`. |
| [play](https://github.com/Deepidoo/play) | Client web Play (monorepo Yarn : `play` → `playdoo` → `deesplay`). |

Les modules appellent le cœur **par HTTP**, jamais par SQL. Pas de clé étrangère entre bases de services.

## Contrat d’un module

Chaque module versionne **dans son repo** un fichier `docs/module.yaml` (copié depuis le template `contracts`).

Il décrit : objectif, acteurs, routes UI et API, droits, fichiers source, données possédées, dépendances interdites.

Une nouvelle route sans mise à jour de ce YAML n’est pas complète.

## Identité

- **Émission** des JWT : `auth-service` uniquement.
- **Validation** JWT utilisateur : `deepidoo-contracts` (même secret, issuer, Redis jti).
- JWT **module** (M2M) : introspection `POST /v1/auth/validate-module-token`.
- Scopes actuels : `resource:read|write|delete` sur le CRUD plateforme ; `music_ai:read|write` sur Play Music AI.

## Frontends

- Un module peut avoir `frontend-web/` : c’est **son** client (qualité production).
- `play` / `playdoo` n’est pas le shell obligatoire de tous les modules.

## Développer

1. Lire le `docs/module.yaml` du module concerné (ou les fondations ci-dessus).
2. Changer uniquement ce dépôt, sauf si le contrat partagé (`contracts`) bouge.
3. Si `contracts` change : versionner, puis adapter les consommateurs.
4. Secrets uniquement en variables d’environnement.

Clones locaux habituels : siblings sous un même dossier workspace, **sans** en faire un seul dépôt Git.

## Pour aller plus loin

| Document | Contenu |
|---|---|
| [Architecture détaillée](https://github.com/Deepidoo-s-new-age/.github/blob/main/docs/ARCHITECTURE.md) | Fondations, flux d’authentification user et M2M, arborescences, diagrammes |
| [Team rules](https://github.com/Deepidoo-s-new-age/.github/blob/main/docs/TEAM-RULES.md) | Cadre appliqué aux devs et aux agents — règles dans `docs/rules/` |
| [Skills](https://github.com/Deepidoo-s-new-age/.github/blob/main/README.md#skills-déquipe) | `/new-module`, `/new-project`, `/update-module-contract`, `/review-module` |
| [Catalogue des règles](https://github.com/Deepidoo-s-new-age/.github/blob/main/docs/RULES-CATALOG.md) | Chaque règle : contenu, portée, écarts assumés |
| [Validation CI future](https://github.com/Deepidoo-s-new-age/.github/blob/main/docs/CI-CONTRACT-VALIDATION.md) | Contrôles envisagés sur contrats, routes et scopes |
