# Deepidoo-s-new-age

Organisation GitHub **New Age**.

La page d’accueil visible sur l’org est [`profile/README.md`](profile/README.md).

## Documentation transverse

| Document | Contenu |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Contexte global : fondations, flux d’authentification, arborescences, diagrammes |
| [docs/TEAM-RULES.md](docs/TEAM-RULES.md) | Règles d’équipe — une seule ref : [`docs/rules/*.mdc`](docs/rules/) |
| [docs/RULES-CATALOG.md](docs/RULES-CATALOG.md) | Catalogue : contenu, mode d’application et portée de chaque règle |
| [docs/rules/](docs/rules) | Règles globales Cursor (`.mdc`) — coller le corps dans Team Rules si besoin |
| [docs/CI-CONTRACT-VALIDATION.md](docs/CI-CONTRACT-VALIDATION.md) | Validation CI envisagée (contrats, routes, scopes) |

## Skills d’équipe

Workflows agents (Cursor). Détail : [`.cursor/skills/README.md`](.cursor/skills/README.md).

| Skill | Déclencheur | Quand l’utiliser |
|---|---|---|
| [new-module](.cursor/skills/new-module/SKILL.md) | `/new-module` | Nouveau **module métier New Age** → `docs/module.yaml` + README + boundary |
| [new-project](.cursor/skills/new-project/SKILL.md) | `/new-project` | Projet **autonome** hors New Age (redirige vers `new-module` si New Age) |
| [update-module-contract](.cursor/skills/update-module-contract/SKILL.md) | `/update-module-contract` | MAJ `docs/module.yaml` après changement de surface |
| [review-module](.cursor/skills/review-module/SKILL.md) | `/review-module` | Review drift contrat ↔ code |

```
Besoin New Age (module)  →  /new-module
Projet hors écosystème   →  /new-project
Surface déjà existante   →  /update-module-contract
Avant merge / audit      →  /review-module
```

Les **règles** (`docs/rules/`) disent *comment* travailler au quotidien.
Les **skills** orchestrent un *workflow* de bout en bout — elles ne remplacent pas les règles.
