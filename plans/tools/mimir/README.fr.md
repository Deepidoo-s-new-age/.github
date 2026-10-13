# Grafana Mimir

La version anglaise est [README.md](README.md).

## Objet

Stocker les métriques Prometheus plus longtemps, à travers plus d’un Prometheus, avec le même PromQL.

## Problème résolu

Prometheus sur un disque est le départ de la phase 8. Une rétention de quelques semaines ne suffit pas à un SLO qui regarde 30 jours, et un second cluster ne doit pas vouloir dire un second langage de requête.

## Comment on l’utilise

Seulement une fois Prometheus en place, et quand la rétention ou la haute disponibilité est le vrai problème. Grafana pointe vers Mimir à la place de Prometheus. Les recording rules et les règles Sloth restent du PromQL. On n’introduit pas Mimir dans le même changement que le premier tableau de bord.

## Installation

Un chart Helm dans le cluster, ajouté quand la rétention ou la haute disponibilité de Prometheus est la limite. Il stocke les données dans un bucket de stockage objet. Grafana lit alors Mimir.

## Contraintes

Il attend du stockage objet. C’est un bucket de plus et un identifiant de plus. Un petit cluster n’en a pas encore besoin.

## Avantages

Les mêmes tableaux et les mêmes alertes. Stockage horizontal.

## Inconvénients

Plus de pièces mobiles qu’un Prometheus. L’opérer est un projet.

## Alternatives

Rester sur Prometheus avec une rétention courte. Thanos. Mimir est l’étape native Grafana quand Prometheus est la limite, pas avant.
