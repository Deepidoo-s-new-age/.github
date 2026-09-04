# New Age — Catalogue des règles

Publié à titre indicatif. Les règles globales sont chargées comme team rules Cursor ;
les règles par dépôt vivent dans le dépôt concerné.

## Règles globales

| Nom | Fichier | Contenu | Application | Fichiers |
|---|---|---|---|---|
| New Age ecosystem architecture | [`rules/RULE-GLOBAL-ECOSYSTEM-ARCHITECTURE.md`](rules/RULE-GLOBAL-ECOSYSTEM-ARCHITECTURE.md) | Rôles des dépôts, sens des dépendances, frontières service/données | Always | Tous |
| Business module contract | [`rules/RULE-GLOBAL-MODULE-CONTRACT.md`](rules/RULE-GLOBAL-MODULE-CONTRACT.md) | YAML module : purpose, actors, access, source ; propriété des routes et données | Always | Tous |
| Identity and authorization ownership | [`rules/RULE-GLOBAL-IDENTITY-AUTHORIZATION.md`](rules/RULE-GLOBAL-IDENTITY-AUTHORIZATION.md) | Émission/validation JWT, scopes actuels, licences vs flags, moindre privilège | Intelligent/file-scoped | `**/*.{py,ts,tsx,vue,js,mjs,mts,csv,yaml,yml}` |
| API contracts and data boundaries | [`rules/RULE-GLOBAL-API-DATA-BOUNDARIES.md`](rules/RULE-GLOBAL-API-DATA-BOUNDARIES.md) | `/v1`, couches, propriété des DTO, pagination, invalidation de cache, clients HTTP | Intelligent/file-scoped | `**/*.{py,ts,tsx,vue,js,mjs,mts}` |
| Production frontend integration | [`rules/RULE-GLOBAL-FRONTEND-INTEGRATION.md`](rules/RULE-GLOBAL-FRONTEND-INTEGRATION.md) | `play → playdoo → deesplay` (dans `play`), fronts de modules, migration API | Intelligent/file-scoped | `**/*.{ts,tsx,vue,js,scss,css}` |
| Security and delivery baseline | [`rules/RULE-GLOBAL-SECURITY-QUALITY.md`](rules/RULE-GLOBAL-SECURITY-QUALITY.md) | Secrets, isolation tenant, tests, qualité, statut honnête | Always | Tous |

## Règles par dépôt

| Dépôt | Nom | Fichier | Contenu | Application | Globs |
|---|---|---|---|---|---|
| `contracts` | deepidoo-contracts team contract | `.cursor/rules/10-team-contract.mdc` | Contrats partagés uniquement, nommage, semver, impact consommateurs | Always | Tout le dépôt |
| `auth-service` | auth-service routes and permissions | `.cursor/rules/10-routes-permissions.mdc` | Routes possédées, source ACL, enregistrement des scopes, identité module | Conditionnelle | `backend/app/**/*.{py,csv}` |
| `platform-api` | platform-api route and scope contract | `.cursor/rules/10-route-scope-contract.mdc` | Alignement route/scope CRUD, routes core custom, comportement auth | Conditionnelle | `app/api/**/*.py` |
| `play` | New Age module integration in Play | `.cursor/rules/frontend/module-integration.mdc` | UI module production, routes, clients, migration `/api/v4` → `/v1` | Conditionnelle | `packages/playdoo/**/*.{ts,vue}` |
| `play_music_ai` | Play Music AI module boundary | `.cursor/rules/module-boundary.mdc` | Objectif, front production, YAML purpose/actors/access/source, scopes | Always | Tout le dépôt |
| `deesplay` | Deesplay repository boundary | `.cursor/rules/team-boundary.mdc` | Source de vérité standalone, isolation du design system | Always | Tout le dépôt |
| `helm-charts` | New Age deployment rules | `.cursor/rules/new-age-deployments.mdc` | Isolation des environnements, images, secrets, migrations, blast radius | Conditionnelle | `environments/**/*` |
| `persistence` | Persistence repository boundary | `.cursor/rules/new-age-data-boundary.mdc` | Dumps sensibles, propriété des bases, isolation Redis, opérations destructives | Always | Tout le dépôt |

## Contrats module (lisibles par machine)

| Fichier | Rôle |
|---|---|
| `contracts/docs/module-contract.TEMPLATE.yaml` | Forme vide partagée (versionnée dans `contracts`) |
| `{module-repo}/docs/module.yaml` | Contrat rempli canonique (versionné dans le module) |
| `play_music_ai/docs/module.yaml` | Play Music AI — objectifs, routes, droits, fichiers, dépendances |

## Écarts connus, assumés par les règles

- `play` n’applique pas encore les scopes JWT dans les métadonnées de route : c’est
  documenté, pas présenté comme fait.
- `play` utilise encore des contrats API historiques alors que les services New Age
  exposent `/v1`.
- Certains scopes de ressources générés par `platform-api` ne sont pas représentés dans
  le catalogue de permissions initial.
- Les copies standalone et embarquée de Deesplay peuvent diverger.
- L’autorisation orientée capacités est une cible ; les scopes actuels restent inchangés.

La validation automatisée envisagée est décrite dans
[CI-CONTRACT-VALIDATION.md](CI-CONTRACT-VALIDATION.md) ; aucun contrôle CI n’est actif.
