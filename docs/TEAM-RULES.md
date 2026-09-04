# New Age — Team rules

Ces règles sont publiées **à titre indicatif** : elles décrivent le cadre appliqué aux
agents (Cursor) et aux développeurs sur les dépôts New Age.

New Age est un ensemble de dépôts indépendants, pas une configuration de monorepo.

## Source de vérité

| Emplacement | Rôle |
|---|---|
| [`docs/rules/*.mdc`](rules/) | Texte des règles globales (unique) |
| Workspace local `.cursor/rules/` | Symlinks vers ces `.mdc` (pas de copie) |
| Cursor Team Admin | Optionnel — coller / synchroniser depuis ce dépôt ; pas de sync auto depuis GitHub |

Ne pas recréer `RULE-GLOBAL-*.md` à la racine du workspace local.

## Documents liés

| Document | Rôle |
|---|---|
| [Architecture](ARCHITECTURE.md) | Ordre des services, fondations, flux d’authentification |
| [Catalogue des règles](RULES-CATALOG.md) | Nom, contenu, mode d’application et globs de chaque règle |
| [Validation CI future](CI-CONTRACT-VALIDATION.md) | Contrôles envisagés sur contrats, routes et scopes |
| [Template de contrat module](https://github.com/Deepidoo-s-new-age/deepidoo-contracts/blob/main/docs/module-contract.TEMPLATE.yaml) | Forme YAML partagée (dans `contracts`) |
| [Contrat Play Music AI](https://github.com/Deepidoo/play_music_ai/blob/main/docs/module.yaml) | Contrat rempli, dans le dépôt du module |

Dépôts : [deepidoo-contracts](https://github.com/Deepidoo-s-new-age/deepidoo-contracts) ·
[auth-service](https://github.com/Deepidoo-s-new-age/auth-service) ·
[platform-api](https://github.com/Deepidoo-s-new-age/platform-api) ·
[play_music_ai](https://github.com/Deepidoo/play_music_ai) ·
[play](https://github.com/Deepidoo/play)

## Modèle d’application

| Règle | Application Cursor | Fichiers concernés |
|---|---|---|
| [Ecosystem architecture](rules/RULE-GLOBAL-ECOSYSTEM-ARCHITECTURE.mdc) | Always | Tous les dépôts |
| [Business module contract](rules/RULE-GLOBAL-MODULE-CONTRACT.mdc) | Always | Tous les dépôts |
| [Identity and authorization](rules/RULE-GLOBAL-IDENTITY-AUTHORIZATION.mdc) | Intelligent/file-scoped | `**/*.{py,ts,tsx,vue,js,mjs,mts,csv,yaml,yml}` |
| [API contracts and data boundaries](rules/RULE-GLOBAL-API-DATA-BOUNDARIES.mdc) | Intelligent/file-scoped | `**/*.{py,ts,tsx,vue,js,mjs,mts}` |
| [Production frontend integration](rules/RULE-GLOBAL-FRONTEND-INTEGRATION.mdc) | Intelligent/file-scoped | `**/*.{ts,tsx,vue,js,scss,css}` |
| [Security and delivery baseline](rules/RULE-GLOBAL-SECURITY-QUALITY.mdc) | Always | Tous les dépôts |

## Précédence

1. La sécurité et l’isolation des données ne sont jamais contournées.
2. Une règle `.cursor/rules/*.mdc` d’un dépôt précise la règle globale pour ce dépôt.
3. Une règle de package précise la règle de son dépôt.
4. En cas de conflit : s’arrêter et signaler les fichiers en conflit — ne pas deviner.

## Workflow attendu d’un agent

1. Identifier le dépôt et, pour `play`, le package modifié.
2. Lire les règles du dépôt concerné.
3. Identifier le module métier via `{module-repo}/docs/module.yaml` quand c’est pertinent.
4. Énoncer les routes UI/API, scopes, propriétaire de données et services aval impactés
   avant tout changement d’architecture.
5. Rester dans le module nommé, sauf changement explicite d’un contrat partagé.

L’inventaire détaillé est dans [RULES-CATALOG.md](RULES-CATALOG.md).
