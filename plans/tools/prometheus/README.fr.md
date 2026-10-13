# Prometheus

La version anglaise est [README.md](README.md).

## Objet

Stocker et interroger les métriques de service : débit de requêtes, taux d’erreur, latence.

## Problème résolu

Les logs disent qu’une requête a échoué. Ils ne disent pas si cinq pour cent des logins échouent depuis vingt minutes. Grafana lit Prometheus pour les tableaux RED et pour les alertes de consommation de budget SLO.

## Comment on l’utilise

Phase 8. Le collecteur OpenTelemetry fait du remote-write, ou les services exposent un endpoint de scrape. Un JSON de tableau de bord dans `helm-charts` est réutilisé par service. Alerter sur le taux de consommation pour trois parcours, pas sur chaque 500.

## Installation

Une release Helm dans le cluster, Prometheus ou la pile kube-prometheus. Les applications exposent des métriques, ou le collecteur fait du remote-write. Le JSON des tableaux vit dans `helm-charts` et est provisionné depuis là.

## Contraintes

Un seul Prometheus garde les données sur une rétention courte. Ce n’est pas une archive longue. Quand cela gêne, on déplace le stockage vers Mimir. On ne fait pas tourner les deux comme deux sources de vérité.

## Avantages

Le langage de requête (PromQL) est celui que Sloth, Pyrra et Grafana parlent déjà. Simple à faire tourner pour ce nombre de services.

## Inconvénients

Le disque local se remplit. La cardinalité d’un label comme `user_id` le fait tomber. On ne met pas d’identifiants utilisateur sur les métriques.

## Alternatives

Mimir, VictoriaMetrics, un produit de métriques en SaaS. Prometheus d’abord.
