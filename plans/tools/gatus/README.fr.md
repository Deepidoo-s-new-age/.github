# Gatus

La version anglaise est [README.md](README.md).

## Objet

Sonder le produit depuis l’extérieur du cluster et enregistrer si les utilisateurs peuvent l’atteindre.

## Problème résolu

Un health check dans le cluster reste vert pendant que le DNS, l’ingress ou le certificat est cassé. L’OWASP A09, c’est la journalisation et l’alerte. Une sonde extérieure est l’alerte que le parcours de login est tombé.

## Comment on l’utilise

Phase 8. Gatus tourne hors du cluster et frappe les trois parcours : login, lire un contenu, une action de module. Les résultats arrivent sur le même tableau Grafana que les SLO. La sonde utilise un compte fixture, pas le mot de passe d’un utilisateur de production dans le dépôt de config.

## Installation

Son propre petit déploiement, hors du cluster qu’il sonde, à partir d’une image de conteneur épinglée et d’une config YAML dans git. La config porte les trois parcours et un compte fixture.

## Contraintes

La sonde ne doit pas dépendre du même ingress qu’elle teste pour son propre chemin de métriques. Une sonde qui ne vérifie que l’ouverture TCP n’est pas un parcours. Vérifier le statut HTTP et un champ du corps qui signifie que l’application a répondu.

## Avantages

Du YAML simple. Page de statut incluse. Pas de compte SaaS.

## Inconvénients

Il n’explique pas pourquoi le contrôle a échoué. Tempo et Loki le font. Gatus dit seulement qu’il a échoué.

## Alternatives

L’exporteur blackbox de Prometheus, Uptime Kuma. Blackbox suffit si chaque contrôle est une métrique Prometheus et que personne ne veut de page de statut. Gatus est le choix quand la page de statut et le YAML vivent ensemble. Uptime Kuma est une alternative d’abord interface, avec moins de calcul de SLO.
