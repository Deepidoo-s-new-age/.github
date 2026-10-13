# GHCR

La version anglaise est [README.md](README.md).

## Objet

Stocker les images de conteneur que cette organisation construit.

## Problème résolu

`auth-service` et `platform-api` taguent `ghcr.io/deepidoo/...` depuis des dépôts de `Deepidoo-s-new-age`. Le `GITHUB_TOKEN` ne peut pas pousser là. Les exécutions échouent avec `denied: permission_denied: read_package`.

## Comment on l’utilise

`image.yml` pousse `ghcr.io/deepidoo-s-new-age/<service>:<git-sha>` avec le `GITHUB_TOKEN` de l’appelant et `packages: write`. Le tag est le commit. Il n’y a pas de tag `:latest`. Le workflow sort le digest. Les values Helm stockent ce digest. La phase 1 construit avec `push: false`. La phase 6 est le premier push, et seulement sur `main`.

Avant le premier push, régler la visibilité par défaut des packages de l’organisation sur privé. Le cluster reçoit un `imagePullSecret` qui peut lire les packages de cette organisation.

## Installation

Le registre de conteneurs de GitHub. `image.yml` s’authentifie avec `docker/login-action` et pousse avec `docker/build-push-action`. Le cluster tire les images avec un `imagePullSecret` qui peut lire `ghcr.io/deepidoo-s-new-age/*`.

## Contraintes

Le nom d’image doit être en minuscules et correspondre au motif du workflow. Le package appartient à `Deepidoo-s-new-age`. Un dépôt encore dans `Deepidoo` ne pousse pas ici tant qu’il n’a pas bougé.

## Avantages

Pas de compte de registre supplémentaire. Le jeton est celui du workflow. Le digest est immuable.

## Inconvénients

La rétention doit être configurée, sinon les anciens tags sha s’accumulent. Les pulls privés demandent un secret de pull sur le cluster.

## Alternatives

Docker Hub, un registre dans le cluster. GHCR reste à côté de l’hôte git. Un registre pour les images New Age.
