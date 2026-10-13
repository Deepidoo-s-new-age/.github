# GitHub Packages

La version anglaise est [README.md](README.md).

## Objet

Publier des packages Python et npm versionnés depuis cette organisation, pour que les autres dépôts les installent au lieu de cloner un checkout voisin.

## Problème résolu

`deepidoo-contracts` est un chemin dans `uv.lock` (`../../contracts`). deesplay est un lien `file:` vers le checkout d’une autre organisation. La CI ne peut pas compter sur le disque d’un développeur. Une version fait de la montée une pull request.

## Comment on l’utilise

Phase 3 : un tag `vX.Y.Z` sur `deepidoo-contracts` lance les tests du package, puis publie `deepidoo-contracts` sur GitHub Packages. Les consommateurs épinglent la version. `checkout_contracts: false` ensuite. Un changement cassant est une version majeure.

Phase 4 : publier deesplay depuis `packages/deesplay`. GitHub Packages exige que le scope npm corresponde à l’organisation propriétaire, donc le nom est `@deepidoo-s-new-age/deesplay`. Les imports, le lockfile et l’alias Vite changent avec ce nom. Les consommateurs ont besoin de :

```text
@deepidoo-s-new-age:registry=https://npm.pkg.github.com
```

et de `NODE_AUTH_TOKEN` dans `vue-app.yml`.

## Installation

Un registre GitHub. Le workflow de release de `deepidoo-contracts` publie avec l’outillage uv déjà dans ce dépôt et `GITHUB_TOKEN`. deesplay publie avec `npm publish` depuis `packages/deesplay`. Les consommateurs pointent pip vers l’index Python de l’organisation, ou npm vers `https://npm.pkg.github.com`, avec un jeton de lecture.

## Contraintes

Le package est privé. La CI et le cluster ont besoin d’un jeton qui peut le lire. Le scope ne peut pas rester `@deepidoo` si le package est publié depuis `Deepidoo-s-new-age`.

## Avantages

Le même hôte que les dépôts git. Le `GITHUB_TOKEN` du workflow peut publier depuis le dépôt qui possède le package.

## Inconvénients

Les consommateurs hors de l’organisation ont besoin d’un jeton. La configuration npm et pip est facile à rater d’un détail, et cela ne casse qu’à l’installation.

## Alternatives

Une publication publique sur PyPI ou npm. Ces packages sont privés. GitHub Packages est le registre.
