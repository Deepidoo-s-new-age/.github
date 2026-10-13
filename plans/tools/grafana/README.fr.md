# Grafana

La version anglaise est [README.md](README.md).

## Objet

Une interface pour les métriques, les logs, les traces et les sondes de disponibilité.

## Problème résolu

Quatre outils et quatre interfaces, et personne ne regarde. La phase 8 met Prometheus ou Mimir, Loki, Tempo et Gatus derrière Grafana. Un JSON de tableau de bord réutilisé dans `helm-charts` montre le débit, les erreurs et la latence de chaque service, pour que le module numéro cinq ne construise pas ses panneaux à la main.

## Comment on l’utilise

Les tableaux de bord et les règles d’alerte sont des fichiers dans git, provisionnés dans Grafana. Éditer un panneau dans l’interface sans l’exporter ne compte pas. Les alertes vont vers le canal que l’équipe lit déjà. Elles partent sur la consommation de SLO, pas sur chaque ligne d’erreur.

## Installation

Un chart Helm dans le cluster, devant Prometheus ou Mimir, Loki, Tempo et les résultats Gatus. Les tableaux et les règles d’alerte sont des fichiers dans `helm-charts`, provisionnés dans Grafana.

## Contraintes

Grafana n’est pas le magasin de données. Perdre Grafana perd la vue, pas l’historique, si Prometheus et Loki gardent les données. On ne met pas d’identifiants de production dans une variable de tableau de bord qui se partage.

## Avantages

Un login. La trace, la ligne de log et le graphe sont liés.

## Inconvénients

Un dossier de tableaux sans propriétaire pourrit. Le mixin dans git est le tableau qui existe.

## Alternatives

Les interfaces de Prometheus, Loki et Tempo séparément. Grafana est celle qu’on ouvre.
