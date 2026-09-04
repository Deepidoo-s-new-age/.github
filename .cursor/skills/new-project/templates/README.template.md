# {{PROJECT_NAME}}

{{ONE_LINE_DESCRIPTION}}

## Le problème

{{PROBLEM_STATEMENT}}

## Pour qui

{{TARGET_USERS_AND_ROLES}}

## Périmètre technique

| Composant | Retenu | Rôle |
|---|---|---|
| API backend | {{HAS_BACKEND}} | {{BACKEND_DESC}} |
| Player (écrans / widgets) | {{HAS_PLAYER}} | {{PLAYER_DESC}} |
| Backoffice web | {{HAS_ADMIN}} | {{ADMIN_DESC}} |
| App mobile | {{HAS_MOBILE}} | {{MOBILE_DESC}} |

## Comment c'est utilisé

{{USAGE_SUMMARY}}

**Éléments manipulés :** {{ENTITY_LIST}}

## Parcours principaux

{{WORKFLOWS_SUMMARY}}

## Contraintes

{{CONSTRAINTS_SUMMARY}}

## Hors périmètre

{{OUT_OF_SCOPE}}

## Contexte Cursor

Le fichier `.cursor/rules/project-context.mdc` contient le contexte métier détaillé
(vocabulaire, parcours, droits, intégrations, périmètre technique) pour l'assistant IA.

Les conventions d'implémentation (stack, architecture, sécurité) sont dans les autres
fichiers `.cursor/rules/` du repository.
