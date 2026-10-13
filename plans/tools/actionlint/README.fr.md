# actionlint

La version anglaise est [README.md](README.md).

## Objet

Contrôler les fichiers de workflow GitHub Actions : syntaxe, expressions incorrectes, erreurs de shell, avant qu’un workflow ne s’exécute.

## Problème résolu

Un workflow réutilisable avec un `if` cassé ou un input manquant ne tombe qu’au moment où un service l’appelle. L’échec ressemble alors à un bug du service.

## Comment on l’utilise

Phase 0. Job dans `Deepidoo-s-new-age/ci-workflows`, fichier `.github/workflows/ci.yml`, sur chaque pull request de ce dépôt. Version 1.7.12. Il lint `.github/workflows/*.yml` et `examples/*.yml`. ShellCheck tourne aussi quand il est installé sur le runner.

## Installation

Le workflow partagé dans `Deepidoo-s-new-age/ci-workflows` télécharge la release 1.7.12 sur le runner, via une Action GitHub épinglée ou l’archive de la release. ShellCheck, quand le job s’en sert, vient de l’image du runner.

## Contraintes

Il contrôle le graphe du workflow, pas le succès de `uv sync` ou de Docker. Il n’exécute pas les workflows appelés.

## Avantages

Rapide, sans serveur, et il attrape la classe d’erreur qui bloque tous les appelants.

## Inconvénients

La couverture ShellCheck dépend de l’image du runner. Il ne connaît pas le sens métier de nos inputs.

## Alternatives

`action-validator`, ou pousser un workflow brouillon et lire l’erreur Actions. actionlint est celui qu’on lance.
