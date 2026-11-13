# Gatus — hors périmètre (pour l’instant)

La version anglaise est [README.md](README.md).

**Pas dans le pipeline New Age aujourd’hui.** La dispo est **dans le cluster** : blackbox Prometheus sur les URL Ingress `/health` ; Grafana **Uptime** affiche `probe_success`. Les parcours (login, lecture platform, token module) passent par des curls manuels ou scriptés et les traces Tempo — pas de sonde hors cluster.

Si on ajoute des sondes de parcours extérieures plus tard, mettre à jour cette fiche et la phase 8 de [CICD-PLAN.fr.md](../../CICD-PLAN.fr.md).
