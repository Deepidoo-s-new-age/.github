# Helm

La version anglaise est [README.md](README.md).

## Objet

Rendre un Deployment, un Service et un Job de migration Kubernetes à partir d’un chart et d’un fichier de values.

## Problème résolu

Copier du YAML par service fait dériver. Un chart est la forme. Le fichier de values est la seule chose qui change par service et par environnement : le digest d’image, l’env, les ressources.

## Comment on l’utilise

Phase 6, dans `deepidoo-s-new-age/helm-charts`. `charts/app` pour un service de longue durée. `charts/job` pour Alembic. Les values épinglent :

```yaml
image:
  repository: ghcr.io/deepidoo-s-new-age/auth-service
  digest: sha256:…
```

La production et la préproduction utilisent le même chart. Elles diffèrent par les values. `kubeconform` contrôle le YAML rendu.

## Installation

Le runner de `helm-charts` installe un CLI Helm épinglé, via une Action d’installation ou le binaire officiel. Les charts sont des fichiers dans `deepidoo-s-new-age/helm-charts`, sous `charts/`.

## Contraintes

Helm ne s’applique pas lui-même dans ce plan. Helmfile est la commande qui applique. Un changement de chart est une pull request. Un changement de digest est une pull request. Personne n’édite le cluster pour changer une image.

## Avantages

L’équipe utilise déjà des charts Helm dans `Deepidoo/helm_charts`. Le nouveau dépôt peut reprendre cette forme sans prendre ce dépôt comme dépendance.

## Inconvénients

Les charts cachent beaucoup de YAML. Un mauvais défaut (root, pas de ressources) atteint tous les services. Kyverno rejette ces défauts en production plus tard.

## Alternatives

Des manifestes bruts, Kustomize. Helm est le packaging. Helmfile est la liste des environnements. On utilise les deux, pour ces deux rôles.
