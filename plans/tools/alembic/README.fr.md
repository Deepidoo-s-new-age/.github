# Alembic

La version anglaise est [README.md](README.md).

## Objet

Appliquer les migrations de base du service dans la release, avec le même digest d’image que les nouveaux pods.

## Problème résolu

Un nouveau pod qui attend une colonne absente de la base plante. Une migration lancée à la main depuis un portable n’est pas le digest qui a été testé. Chaque service possède son schéma. Il n’y a pas de clé étrangère inter-services pour ordonner les migrations à notre place.

## Comment on l’utilise

Phase 6. La release Helm lance Alembic en Job ou en hook Helm avant que les nouveaux pods prennent le trafic : `alembic upgrade head`, image réglée sur le digest promu. La migration doit tolérer que la version précédente de l’application tourne encore pendant le rollout.

## Installation

Dépendance Python de chaque service qui possède une base, déjà dans le `pyproject.toml` et le `uv.lock` de ce service, donc elle part dans l’image du service. Le Job de migration lance cette même image et ce même digest.

## Contraintes

Une migration qui verrouille une grosse table, ou qui supprime une colonne que les anciens pods lisent encore, coupe le service. Étendre, puis contracter, sur deux releases. Le Job utilise l’env et les secrets du service. Il ne reçoit pas une seconde URL de base.

## Avantages

La migration et le code sont le même build. Une migration en échec arrête le rollout.

## Inconvénients

Un Job en échec demande un humain pour lire les logs et décider s’il faut revenir au digest précédent. Le pipeline n’invente pas une migration down tout seul.

## Alternatives

Lancer la migration dans l’entrypoint de chaque réplica. Cela crée une course. Un Job par release est le schéma.
