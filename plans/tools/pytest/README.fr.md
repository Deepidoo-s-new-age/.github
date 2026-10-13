# pytest

La version anglaise est [README.md](README.md).

## Objet

Lancer les tests Python qui décident si un changement de comportement peut être mergé.

## Problème résolu

Un job de lint vert peut encore livrer un login cassé ou un test de scope interdit manquant. La règle d’équipe : un changement de comportement a des tests, et un changement d’autorisation a un cas autorisé et un cas interdit.

## Comment on l’utilise

Phase 0. `uv run pytest -q --tb=short` depuis le répertoire du service. `python-service.yml` pose des variables d’environnement inertes avant l’import, parce qu’`auth-service` construit `Settings()` à l’import : `JWT_SECRET`, `JWT_ISSUER`, `AUTH_DATABASE_URL`, `WEBAPP_DATABASE_URL`, `REDIS_URL`. Ces valeurs ne pointent jamais vers une vraie base. Les tests qui ont besoin de Postgres mockent la session.

Aucun test collecté est un échec (code de sortie pytest 5). Le cliquet de couverture est la phase 2 : publier `coverage.xml` et échouer quand le pourcentage baisse. Il n’y a pas d’objectif global de 80 %.

La suite lente reste hors de la pull request. Un job de nuit peut lancer les tests d’intégration.

## Installation

Empaqueté comme ruff : une dépendance de dev du groupe uv du dépôt, installée par `uv sync`. Les plugins comme pytest-asyncio restent dans ce même lockfile.

## Contraintes

Des tests qui ouvrent une vraie base feront échouer ce job. Ils appartiennent à un job ultérieur avec des conteneurs de service, pas au chemin par défaut.

## Avantages

La même commande que le hook pre-commit local (`uv run pytest`). Retour rapide.

## Inconvénients

Des tests unitaires avec des mocks ne prouvent ni le SQL ni l’appel HTTP vers `platform-api`. Le smoke de préproduction en phase 5 couvre ce chemin.

## Alternatives

unittest seul. Les dépôts utilisent déjà pytest et pytest-asyncio.
