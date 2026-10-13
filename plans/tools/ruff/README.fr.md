# ruff

La version anglaise est [README.md](README.md).

## Objet

Formater le Python et attraper les erreurs de lint (imports inutilisés, bugs probables, ordre des imports).

## Problème résolu

`auth-service` et `deepidoo-contracts` sélectionnent déjà les règles ruff `E`, `F`, `I`, `UP`, `B`, `SIM` et une longueur de ligne de 100. La CI doit appliquer les mêmes règles que le hook pre-commit, sinon `main` s’écarte de ce que les portables acceptent.

## Comment on l’utilise

Phase 0. Après `uv sync` :

```bash
uv run ruff check .
uv run ruff format --check .
```

La config reste dans le `pyproject.toml` de chaque dépôt. Le workflow partagé ne passe pas une seconde config.

## Installation

Dépendance de dev de chaque dépôt Python, déclarée dans le `pyproject.toml` de ce dépôt et verrouillée dans `uv.lock`. `uv sync --frozen --all-groups` l’installe dans le virtualenv de CI. Le workflow partagé ne va pas chercher une seconde copie.

## Contraintes

`ruff format --check` échoue tant que le dépôt n’est pas formaté. On l’active avec le premier appelant, et on formate ce dépôt dans la même pull request.

## Avantages

Un outil pour le lint et le format. Assez rapide pour chaque pull request. Déjà le hook local.

## Inconvénients

Ce n’est ni un vérificateur de types ni un scanner de sécurité. mypy et Semgrep couvrent ces deux rôles.

## Alternatives

Black plus flake8 plus isort. Ruff remplace cet ensemble. On ne les ajoute pas à côté.
