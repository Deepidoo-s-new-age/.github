# Kyverno

La version anglaise est [README.md](README.md).

## Objet

Rejeter, à l’admission, les ressources Kubernetes qui cassent la politique de production.

## Problème résolu

Un fichier de values peut encore dire `latest`, tourner en root, ou omettre les limites CPU. La CI peut manquer un manifeste que quelqu’un a appliqué à la main. Kyverno est le cluster qui dit non. C’est la moitié vivante de l’OWASP A02, après que kubeconform a contrôlé le schéma.

## Comment on l’utilise

Phase 9, une fois que les digests sont les seuls tags qu’on déploie. Politiques, dans l’ordre :

1. Les images en production utilisent un digest, pas un tag.
2. Puis les images sont signées (cosign).
3. Non-root, limites de ressources, pas d’escalade de privilèges.

Commencer en mode audit. Passer une politique en enforce quand le journal d’audit est propre. Les politiques vivent dans git avec `helm-charts`.

## Installation

Une release Helm du contrôleur d’admission dans le cluster de production. Les politiques sont du YAML dans `helm-charts` et commencent en mode audit.

## Contraintes

Le mode enforce sur une politique que les workloads actuels violent bloquera le prochain déploiement, y compris un rollback si l’ancien manifeste viole aussi. Auditer d’abord. On n’enforce pas les namespaces de preview le même jour que la production si les previews ont le droit d’être plus lâches. Le dire dans la politique.

## Avantages

La règle est du YAML que l’équipe peut lire. Elle couvre les apply qui ne viennent pas du workflow du chemin heureux.

## Inconvénients

Une mauvaise politique est une panne. Le mode audit existe pour cette raison.

## Alternatives

OPA Gatekeeper. Les politiques Kyverno ressemblent à des ressources Kubernetes. On utilise Kyverno.
