# uv

La version anglaise est [README.md](README.md).

## Objet

Installer Python, résoudre les dépendances, et installer exactement ce que `uv.lock` enregistre.

## Problème résolu

Les services utilisent déjà uv et un lockfile (`auth-service`, `deepidoo-contracts`). Un job de CI qui fait `pip install` depuis `pyproject.toml` peut installer d’autres versions que la machine d’un développeur.

## Comment on l’utilise

Phase 0, dans `python-service.yml` et `python-package.yml`. Épingler l’action `astral-sh/setup-uv@v10.2.0` et uv `0.12.23`. Python 3.12. Commande : `uv sync --frozen --all-groups`, puis `uv run` pour ruff, pytest et pip-audit. `--frozen` échoue si le lockfile est en retard.

Jusqu’à la phase 3, les lockfiles des services pointent vers `../../contracts`. Le workflow clone `deepidoo-contracts` à ce chemin avant `uv sync`.

## Installation

Le runner l’installe avec l’Action GitHub `astral-sh/setup-uv@v10.2.0`, épinglée à uv `0.12.23` et Python 3.12. Les portables utilisent le même uv. L’image du service contient les paquets que `uv sync` a résolus, et le binaire uv reste sur le runner.

## Contraintes

Le format du lockfile doit correspondre à l’uv épinglé. Un lock plus récent, commité depuis l’uv d’un développeur, peut faire échouer `--frozen` sur 0.12.23. On monte alors l’épingle dans le workflow partagé, à un seul endroit.

## Avantages

Le même installeur en local et en CI. Un lockfile pour l’application et le groupe de dev.

## Inconvénients

Les dépendances par chemin (`editable = "../../contracts"`) demandent un checkout que `actions/checkout` ne peut pas faire seul. Cela disparaît quand contracts est une version publiée.

## Alternatives

pip avec un fichier requirements, Poetry, PDM. Les dépôts sont déjà sur uv. On n’ajoute pas un second installeur Python.
