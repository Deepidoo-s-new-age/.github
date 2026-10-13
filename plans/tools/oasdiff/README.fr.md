# oasdiff

La version anglaise est [README.md](README.md).

## Objet

Montrer si une pull request a changé l’API HTTP d’une façon qui casse les appelants.

## Problème résolu

Un champ renommé ou un code de statut retiré peut passer des tests qui mockent le client. Le module qui appelle `platform-api` le découvre en préproduction.

## Comment on l’utilise

Phase 5, le même job que le validateur d’architecture. Le job de test génère l’OpenAPI sans dépendances de production. oasdiff compare ce document à l’artefact OpenAPI de la branche de base. Un changement cassant échoue, ou au minimum s’affiche dans la pull request avant qu’on rende le contrôle bloquant.

## Installation

Le job d’architecture dans `ci-workflows` télécharge une release épinglée du binaire Go sur le runner. Les documents OpenAPI qu’il compare sont des artefacts de CI du job de test.

## Contraintes

Il lui faut une façon stable de générer l’OpenAPI en CI. Un générateur qui exige Postgres ne tournera pas sur le job par défaut. Cassant ou compatible, c’est la classification d’oasdiff. Lire le rapport avant de traiter chaque diff comme un échec.

## Avantages

Le diff est l’API, pas une supposition à partir de la liste des routes. Pas de serveur.

## Inconvénients

Il ne sait pas quel consommateur épingle un ancien client. La montée de version de contracts reste le moyen de faire bouger les schémas partagés.

## Alternatives

`openapi-diff`, optic. oasdiff est celui qu’on lance. Un seul outil de diff d’API.
