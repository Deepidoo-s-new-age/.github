---
name: review-module
description: >-
  Review a New Age module for drift between docs/module.yaml and the codebase
  (routes, purposes, access honesty, forbidden cross-service access). Use before
  merge, during architecture review, or when invoking /review-module.
disable-model-invocation: true
---

# Review Module

Contrôle de cohérence **contrat ↔ code** pour un module New Age.

## Entrées

- Chemin du module (ex. `play_music_ai/`)
- `docs/module.yaml` (obligatoire — sinon stopper et demander `/new-module` ou création du YAML)

## Checks

1. **YAML présent et rempli** — `module_id`, capability, authorization, data, dependencies.
2. **Chaque groupe API du code** a une entrée YAML (prefix) avec `purpose`, `actors`, `access`, `source`.
3. **Chaque route UI production** a une entrée avec `purpose`, `actors`, `api_groups`, `source`.
4. **Honnêteté accès** — pas de scope inventé ; flagger `currently_unprotected` / `mixed_by_endpoint` manquants.
5. **Downstream** — appels HTTP vers platform-api / auth déclarés.
6. **Forbidden** — pas de SQL croisé ni d'import applicatif d'un autre service (spot-check).
7. **Front** — `frontend-web` vs `play_integration` cohérent avec le repo.
8. **Écarts connus** — lister sans les « corriger » silencieusement.

## Sortie

```markdown
## Review module — [module_id]

**Verdict :** OK | Drift | Bloquant

### Drift
| Sévérité | Sujet | Constat | Action suggérée |
|---|---|---|---|
| … | … | … | update YAML / fix code / enregistrer scope |

### OK
- …
```

Ne pas modifier le code ni le YAML sans demande explicite après le rapport.
