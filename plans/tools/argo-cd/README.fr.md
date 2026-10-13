# Argo CD

La version anglaise est [README.md](README.md).

## Objet

Surveiller `helm-charts` et appliquer le cluster pour que git reste la source de vérité, sans kubeconfig dans GitHub Actions.

## Problème résolu

Helmfile depuis Actions fonctionne, et il stocke un identifiant de cluster dans GitHub. Une compromission de cet environnement peut changer la production. Argo tourne dans le cluster et tire git.

## Comment on l’utilise

Après que deux services se déploient par Helmfile (phase 6). Argo surveille `deepidoo-s-new-age/helm-charts`. La préproduction se synchronise au merge. La production ne se synchronise que lorsque l’environnement GitHub `production`, ou une fenêtre de sync Argo avec la même règle de relecteur, l’autorise. Le secret kubeconfig quitte GitHub Actions une fois qu’Argo est celui qui applique. La dérive apparaît dans Argo, pas dans un `kubectl diff` surprise.

## Installation

Une release Helm du chart Argo CD upstream dans le cluster, après que deux services se déploient déjà avec Helmfile. À partir de là, Argo applique ce que git dit, et le kubeconfig quitte le GitHub Environment.

## Contraintes

On ne l’installe pas avant que les fichiers de values et le flux de digest existent. Deux systèmes de déploiement en même temps, avec des values différentes, se battent.

## Avantages

Le cluster se réconcilie vers git. Les rollbacks sont des reverts git. Actions ne détient plus un admin de cluster de longue durée.

## Inconvénients

Un composant de plus à mettre à jour. Une mauvaise politique de sync peut appliquer toute seule un changement de values de production qu’on voulait relire.

## Alternatives

Rester sur Helmfile depuis Actions. C’est la première étape. Argo remplace l’apply, pas le chart.
