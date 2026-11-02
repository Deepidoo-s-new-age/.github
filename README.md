# Deepidoo-s-new-age

Organisation GitHub **New Age**.

La page d’accueil visible sur l’org est [`profile/README.md`](profile/README.md).

## Setup local (workspace)

Depuis ce dépôt (`.github/`) :

```bash
make help                                                 # catalogue Make
make setup                                                # clone + infra
make hosts-print                                          # ou make hosts-install
make up PROFILES="infra otel auth platform" DEV="auth platform"
make stack                                                # containers + URLs Traefik
```

Détail : [local/README.md](local/README.md) — [commandes Make](local/README.md#commandes-make),
profiles (`infra` / `otel` / `auth` / `platform`), overlays GHCR / `Dockerfile.dev`,
[premier jour](local/README.md#premier-jour-user-de-test--migration-platform) (ACL user + Alembic),
[BDD platform (transition)](local/README.md#bdd-platform-api-transition).

Skill agent : `/setup-local`. Ajouter une app au compose : `/add-compose-service`.

## Documentation transverse

| Document | Contenu |
|---|---|
| [local/README.md](local/README.md) | Clone workspace + Postgres/Redis New Age (Make) |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Contexte global : fondations, flux d’authentification, arborescences, diagrammes |
| [docs/TEAM-RULES.md](docs/TEAM-RULES.md) | Règles d’équipe — une seule ref : [`docs/rules/*.mdc`](docs/rules/) |
| [docs/RULES-CATALOG.md](docs/RULES-CATALOG.md) | Catalogue : contenu, mode d’application et portée de chaque règle |
| [docs/rules/](docs/rules) | Règles globales Cursor (`.mdc`) — coller le corps dans Team Rules si besoin |
| [docs/CI-CONTRACT-VALIDATION.md](docs/CI-CONTRACT-VALIDATION.md) | Validation CI envisagée (contrats, routes, scopes) |
| [docs/PR-AUTOMATION.md](docs/PR-AUTOMATION.md) | Cursor Automation sur les PR (règles, YAML, review, Talkspirit) |

## Skills d’équipe

Workflows agents (Cursor). Détail : [`.cursor/skills/README.md`](.cursor/skills/README.md).

| Skill | Déclencheur | Quand l’utiliser |
|---|---|---|
| [setup-local](.cursor/skills/setup-local/SKILL.md) | `/setup-local` | Bootstrap workspace local (clone, hosts, Compose, ACL) |
| [add-compose-service](.cursor/skills/add-compose-service/SKILL.md) | `/add-compose-service` | Ajouter un service au stack `local/` |
| [new-module](.cursor/skills/new-module/SKILL.md) | `/new-module` | Nouveau **module métier New Age** → `docs/module.yaml` + README + boundary |
| [new-project](.cursor/skills/new-project/SKILL.md) | `/new-project` | Projet **autonome** hors New Age (redirige vers `new-module` si New Age) |
| [update-module-contract](.cursor/skills/update-module-contract/SKILL.md) | `/update-module-contract` | MAJ `docs/module.yaml` après changement de surface |
| [review-module](.cursor/skills/review-module/SKILL.md) | `/review-module` | Review drift contrat ↔ code |
| [pr-automation](.cursor/skills/pr-automation/SKILL.md) | `/pr-automation` | Workflow PR auto (règles → YAML → review → Talkspirit) |

```
Onboarding / stack local     →  /setup-local
Nouveau service Compose      →  /add-compose-service
Besoin New Age (module)      →  /new-module
Projet hors écosystème       →  /new-project
Surface déjà existante       →  /update-module-contract
Avant merge / audit          →  /review-module
PR Automation (Cursor)       →  voir docs/PR-AUTOMATION.md
```

Les **règles** (`docs/rules/`) disent *comment* travailler au quotidien.
Les **skills** orchestrent un *workflow* de bout en bout — elles ne remplacent pas les règles.

## PR Automation

Sur chaque pull request New Age (dashboard Cursor) :

1. Valider les règles
2. Compléter `docs/module.yaml` sur la **même branche** si besoin
3. Review de code
4. Récap Talkspirit (Dédé)

Runbook : [docs/PR-AUTOMATION.md](docs/PR-AUTOMATION.md) · Prompt : [prompts/pr-automation.md](prompts/pr-automation.md)
