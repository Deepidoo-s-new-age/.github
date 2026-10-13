# OpenTelemetry

La version anglaise est [README.md](README.md).

## Objet

Un seul chemin d’instrumentation qui émet traces, métriques et logs depuis chaque service FastAPI.

## Problème résolu

Un module appelle `platform-api`, qui appelle auth. Trois formats de log et aucun identifiant de requête partagé rendent un pic de latence illisible. La phase 8 attend que les déploiements aient des digests, pour qu’une trace puisse être rattachée à une version.

## Comment on l’utilise

Instrumenter `auth-service`, `platform-api`, puis les modules. Exporter vers un collecteur dans le cluster. Le collecteur répartit vers Prometheus ou Mimir, Loki et Tempo. Propager l’en-tête de trace sur le HTTP sortant. Ne pas logger `Authorization`, les JWT ni les mots de passe. Une règle Semgrep le rappelle.

Commencer par le débit, les erreurs et la latence par service. On n’invente pas une métrique custom par route le premier jour.

## Installation

Deux pièces. Le SDK Python est une dépendance de chaque app FastAPI, dans `pyproject.toml` et `uv.lock`, et part dans l’image de ce service. Le collecteur est son propre déploiement dans le cluster, le chart OpenTelemetry Collector, et il transmet vers Prometheus ou Mimir, Loki et Tempo.

## Contraintes

La version du SDK doit correspondre au protocole du collecteur. Un service qui oublie l’en-tête coupe la trace. Une instrumentation qui enregistre les corps de requête stockera des données personnelles. On ne le fait pas.

## Avantages

Une bibliothèque pour trois signaux. Les fournisseurs peuvent changer plus tard sans réécrire les applications.

## Inconvénients

Un collecteur à faire tourner et à mettre à jour. Un mauvais échantillonnage cache la requête lente dont on avait besoin.

## Alternatives

Un agent fournisseur par signal (client Prometheus, plus un expéditeur de logs, plus un traceur). OpenTelemetry remplace cette séparation.
