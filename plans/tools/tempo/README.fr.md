# Tempo

La version anglaise est [README.md](README.md).

## Objet

Stocker les traces : le chemin d’une requête à travers auth, platform et un module.

## Problème résolu

La latence d’un module peut être le module, ou l’appel à `platform-api`. Les logs de trois services ne le montrent pas s’ils ne partagent pas une trace. Tempo est la moitié traces de la pile de phase 8. Les métriques ont toujours besoin de Prometheus. Les logs ont toujours besoin de Loki.

## Comment on l’utilise

Le collecteur OpenTelemetry exporte les traces vers Tempo. Grafana relie un pic RED aux traces, et une trace aux logs. Les services propagent l’en-tête de trace entrant sur le HTTP sortant. L’échantillonnage peut commencer à un taux modeste et passer à toujours pour les erreurs.

## Installation

Un chart Helm dans le cluster. Le collecteur OpenTelemetry y exporte les traces. L’image du service porte le SDK, et le magasin reste dans le cluster.

## Contraintes

Un service qui démarre une nouvelle trace au lieu de continuer l’en-tête coupe l’histoire. Tempo n’alerte pas tout seul. Les alertes de consommation restent sur les métriques.

## Avantages

La trace est l’image de cette architecture, parce que l’architecture est du HTTP entre services.

## Inconvénients

Des taux d’échantillon élevés coûtent cher. Les erreurs non échantillonnées sont celles qu’on voudra. Échantillonner les erreurs à 100 %.

## Alternatives

Jaeger. Tempo est le défaut Grafana à côté de Loki et Mimir. On utilise Tempo.
