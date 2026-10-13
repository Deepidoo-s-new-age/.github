# Pyrra

La version anglaise est [README.md](README.md).

## Objet

Définir des SLO et montrer leurs budgets d’erreur, en générant des règles Prometheus comme Sloth et en ajoutant une interface.

## Problème résolu

Le même problème que Sloth : pager sur la consommation du budget, pas sur une erreur isolée. Pyrra est l’alternative quand l’équipe veut une page qui montre le budget sans construire cette vue à la main dans Grafana.

## Comment on l’utilise

Phase 8, à la place de Sloth, pas à côté. Les trois parcours sont les mêmes : login, lire un contenu, une action de module. Pyrra écrit les règles Prometheus et sert l’interface. Grafana peut toujours grapher les mêmes recording rules.

## Installation

Une release Helm dans le cluster, le chart Pyrra et ses CRD, à la place de Sloth. Il lit Prometheus et sert sa propre page.

## Contraintes

Un service de plus à faire tourner et à authentifier. Il a besoin de Prometheus. Il ne remplace pas Gatus. Un SLO dans le cluster ne prouve pas que l’ingress est joignable.

## Avantages

Le budget est visible sans tableau de bord custom. Les règles restent natives Prometheus.

## Inconvénients

Deux endroits où regarder si Grafana est déjà l’interface standard. Plus à opérer qu’un fichier généré par Sloth.

## Alternatives

Sloth. Choisir Sloth sauf si quelqu’un ouvrira vraiment l’interface Pyrra. On ne fait pas tourner les deux générateurs sur le même SLO.
