# Sloth

La version anglaise est [README.md](README.md).

## Objet

Générer les recording rules et les règles d’alerte Prometheus d’un SLO à partir d’une spec courte.

## Problème résolu

« Alerter quand le login est tombé » pagine sur un à-coup. Un budget d’erreur se consume quand les utilisateurs passent vraiment une mauvaise heure. Sloth transforme « 99,9 % des logins réussissent sur 30 jours » en alertes de taux de consommation que Grafana déclenche.

## Comment on l’utilise

Phase 8, une fois les métriques en place. Trois SLO : login, lire un contenu, une action de module. Les specs vivent dans git à côté des tableaux de bord. Sloth génère les règles. Prometheus les charge. On choisit Sloth ou Pyrra, pas les deux.

## Installation

Un CLI, ou un conteneur lancé une fois, depuis la CI ou un hook de chart. Les specs sont du YAML dans git, à côté des tableaux. Il écrit des manifestes PrometheusRule que Prometheus charge. Le plan fait tourner Sloth ou Pyrra.

## Contraintes

Le SLO ne vaut que ce que vaut la métrique. Une métrique qui compte les health checks comme des succès ne se consumera jamais. Exclure les sondes. Sloth ne collecte pas les métriques. Prometheus le fait.

## Avantages

La spec tient en quelques lignes. Les alertes de consommation à plusieurs fenêtres sont la partie facile à rater à la main.

## Inconvénients

Les règles générées sont bruyantes à relire dans un diff. On relit la spec, pas chaque ligne générée.

## Alternatives

Pyrra, qui ajoute une interface. Du PromQL écrit à la main. Sloth est le défaut si on veut des fichiers et pas de serveur supplémentaire.
