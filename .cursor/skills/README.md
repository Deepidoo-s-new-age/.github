# New Age — Skills d’équipe

Workflows agents à invoquer (ex. `/new-module`). Source : ce dépôt
[`Deepidoo-s-new-age/.github`](https://github.com/Deepidoo-s-new-age/.github).

Les **règles** restent dans [`docs/rules/`](../../docs/rules/) — une seule référence.
Les skills **orchestrent** un workflow ; elles ne remplacent pas les règles.

## Catalogue

| Skill | Déclencheur | Rôle |
|---|---|---|
| [new-module](new-module/SKILL.md) | `/new-module` | Nouveau **module métier New Age** → `docs/module.yaml` + README + boundary rule |
| [new-project](new-project/SKILL.md) | `/new-project` | Projet **autonome** hors New Age → `project-context` + README (redirige vers new-module si New Age) |
| [update-module-contract](update-module-contract/SKILL.md) | `/update-module-contract` | MAJ `docs/module.yaml` après changement de surface |
| [review-module](review-module/SKILL.md) | `/review-module` | Review drift contrat ↔ code |
| [pr-automation](pr-automation/SKILL.md) | `/pr-automation` | PR auto : règles → YAML → review → Talkspirit |

## Installation locale

Options :

1. Ouvrir ce repo dans le workspace (skills sous `.cursor/skills/`).
2. Copier / symlinker un skill vers `{repo}/.cursor/skills/{name}/` d’un dépôt consommateur.
3. Skills Team Cursor (dashboard) : coller ou importer le contenu de chaque `SKILL.md` si votre plan le permet — **pas de sync auto** depuis GitHub.

## Règle de choix

```
Besoin New Age (module)  →  new-module
Projet hors écosystème   →  new-project
Surface déjà existante   →  update-module-contract
Avant merge / audit      →  review-module
Automation PR (dashboard)→  pr-automation + docs/PR-AUTOMATION.md
```
