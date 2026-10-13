# Loki

La version anglaise est [README.md](README.md).

## Objet

Stocker les logs et les interroger par label, à côté des métriques dans Grafana.

## Problème résolu

`kubectl logs` disparaît quand le pod n’est plus là. Un échec de login à 02:00 a besoin de la ligne, avec l’identifiant de trace, après le redémarrage du pod.

## Comment on l’utilise

Phase 8. Les applications loguent du JSON sur stdout. Le collecteur envoie vers Loki. Les labels sont le service, l’environnement et le niveau. L’identifiant de trace est un champ de la ligne, pour qu’un lien Grafana saute vers Tempo. On ne labelle pas par identifiant utilisateur ni par chemin de requête aux valeurs non bornées.

## Installation

Un chart Helm dans le cluster. Le collecteur, ou le shipper du chart, lit le JSON sur stdout et l’écrit dans Loki.

## Contraintes

Loki n’est pas un moteur de recherche plein texte pour chaque champ au moment de la recherche. Des labels à forte cardinalité le rendent cher et lent. Un secret dans une ligne de log est désormais dans le magasin de logs. La règle Semgrep et la règle d’équipe existent pour que cette ligne ne soit pas écrite.

## Avantages

Il vit à côté de Grafana et de Tempo. Moins cher qu’indexer chaque mot.

## Inconvénients

Une requête qui filtre sur un champ non indexé parcourt beaucoup de chunks. Structurer les champs JSON que l’on cherche vraiment.

## Alternatives

Elasticsearch, CloudWatch. Loki correspond à la pile Grafana du plan. Un magasin de logs.
