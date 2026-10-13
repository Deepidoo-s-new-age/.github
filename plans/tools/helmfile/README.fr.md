# Helmfile

La version anglaise est [README.md](README.md).

## Objet

Lister les releases Helm d’un environnement et en appliquer une.

## Problème résolu

La préproduction et la production sont des ensembles de services, pas un seul chart. Quelqu’un doit dire « auth-service en préproduction utilise ce fichier de values » et n’appliquer que cette release.

## Comment on l’utilise

Phase 6. `deepidoo-s-new-age/helm-charts` est le seul dépôt dont les workflows parlent au cluster.

```text
environments/preproduction/helmfile.yaml
environments/preproduction/<service>.values.yaml
environments/production/helmfile.yaml
environments/production/<service>.values.yaml
```

Merger un digest en préproduction lance :

```bash
helmfile -f environments/preproduction/helmfile.yaml --selector name=auth-service apply
```

depuis un GitHub Environment nommé `preproduction`. La production est une seconde pull request qui copie le même digest, et l’environnement `production` exige un relecteur. Le rollback est `helm rollback` ou une pull request qui restaure le digest précédent.

Les namespaces de preview en phase 7 sont une release Helmfile au nom généré, détruite à la fermeture de la pull request.

## Installation

Le même runner `helm-charts` installe un CLI Helmfile épinglé à côté de Helm. La liste des releases est `environments/<env>/helmfile.yaml` dans ce dépôt.

## Contraintes

Tant qu’Argo CD n’existe pas, le secret kubeconfig ne vit que sur les GitHub Environments de ce dépôt. Les dépôts de services ne l’ont jamais. Le dépôt legacy `Deepidoo/helm_charts` n’est pas la cible de ces workflows.

## Avantages

Une commande applique un service. Le digest voulu est une ligne dans git.

## Inconvénients

L’apply depuis Actions détient les identifiants du cluster. C’est pour cela qu’Argo CD arrive après que deux services se déploient ainsi.

## Alternatives

Argo CD dès le premier jour. Helmfile d’abord correspond à l’outil que l’équipe lance déjà, puis Argo surveille les mêmes fichiers.
