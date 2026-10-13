# mypy

La version anglaise est [README.md](README.md).

## Objet

Vérifier les annotations de type Python et attraper les appels qui passent la mauvaise forme.

## Problème résolu

Ruff ne sait pas qu’une fonction attend un UUID et a reçu une chaîne. Les services typés font échouer cette classe de bug avant la revue.

## Comment on l’utilise

Pas en phase 0. `auth-service` et `deepidoo-contracts` n’ont pas de config mypy aujourd’hui. Ajouter un input `run_mypy` sur `python-service.yml`, faux par défaut. Un dépôt l’active quand `mypy` est propre sur `main` et que la config vit dans le `pyproject.toml` de ce dépôt.

## Installation

Dépendance de dev optionnelle du groupe uv du dépôt, verrouillée dans `uv.lock`. `uv sync` l’installe dans les dépôts qui activent `run_mypy`. Le workflow partagé laisse l’input éteint tant que cette config n’existe pas.

## Contraintes

L’activer sur un dépôt qui n’a jamais été typé rend la pull request rouge pour de l’ancien code. On ne l’active pas par surprise.

## Avantages

Il attrape les décalages d’API entre nos propres modules. Il tourne dans l’environnement uv déjà en place.

## Inconvénients

Le mode strict est un projet à part. Une config lâche qui ignore presque tout ajoute du temps sans signal.

## Alternatives

Pyright. On choisit mypy une fois et on l’utilise depuis uv. On ne lance pas les deux.
