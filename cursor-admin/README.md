# Cursor Admin — Team Rules (à coller)

Ces fichiers sont prêts pour **Cursor → Dashboard → Team Rules** (règles générales d’équipe).

Le contenu métier est le même que [`docs/rules/*.mdc`](../docs/rules/) (utilisé en local via symlinks).
Ici : format **Markdown sans frontmatter YAML**, avec le mode d’application indiqué en tête.

## Comment appliquer

1. Ouvrir [Cursor Dashboard → Rules](https://cursor.com/dashboard?tab=rules) (Team Rules).
2. Pour chaque fichier ci-dessous : **New rule** → coller le contenu (ou au minimum la section Rule).
3. Régler **Application** et **File patterns** comme indiqué dans le tableau / l’en-tête du fichier.
4. Enregistrer. Optionnel : **Enforce** pour les 3 règles Always (écosystème, module contract, sécurité).

Pas de synchronisation auto GitHub → Admin : après une MAJ de `docs/rules/*.mdc`, régénérer ce dossier ou recopier.

## Fichiers

| Fichier | Nom suggéré dans Admin | Application | File patterns |
|---|---|---|---|
| [`RULE-GLOBAL-ECOSYSTEM-ARCHITECTURE.md`](RULE-GLOBAL-ECOSYSTEM-ARCHITECTURE.md) | New Age ecosystem architecture | Always Apply | `All files` |
| [`RULE-GLOBAL-MODULE-CONTRACT.md`](RULE-GLOBAL-MODULE-CONTRACT.md) | Business module contract | Always Apply | `All files` |
| [`RULE-GLOBAL-IDENTITY-AUTHORIZATION.md`](RULE-GLOBAL-IDENTITY-AUTHORIZATION.md) | Identity and authorization ownership | Apply Intelligently / file-scoped | `**/*.{py,ts,tsx,vue,js,mjs,mts,csv,yaml,yml}` |
| [`RULE-GLOBAL-API-DATA-BOUNDARIES.md`](RULE-GLOBAL-API-DATA-BOUNDARIES.md) | API contracts and data boundaries | Apply Intelligently / file-scoped | `**/*.{py,ts,tsx,vue,js,mjs,mts}` |
| [`RULE-GLOBAL-FRONTEND-INTEGRATION.md`](RULE-GLOBAL-FRONTEND-INTEGRATION.md) | Production frontend integration | Apply Intelligently / file-scoped | `**/*.{ts,tsx,vue,js,scss,css}` |
| [`RULE-GLOBAL-SECURITY-QUALITY.md`](RULE-GLOBAL-SECURITY-QUALITY.md) | Security and delivery baseline | Always Apply | `All files` |

## Ordre recommandé

1. `RULE-GLOBAL-ECOSYSTEM-ARCHITECTURE.md` — New Age ecosystem architecture
2. `RULE-GLOBAL-MODULE-CONTRACT.md` — Business module contract
3. `RULE-GLOBAL-IDENTITY-AUTHORIZATION.md` — Identity and authorization ownership
4. `RULE-GLOBAL-API-DATA-BOUNDARIES.md` — API contracts and data boundaries
5. `RULE-GLOBAL-FRONTEND-INTEGRATION.md` — Production frontend integration
6. `RULE-GLOBAL-SECURITY-QUALITY.md` — Security and delivery baseline
