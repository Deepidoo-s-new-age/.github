# Release Please

La version anglaise est [README.md](README.md).

## Objet

Ouvrir une pull request de release qui monte la version, met à jour le changelog, et pose le tag `vX.Y.Z` au merge.

## Problème résolu

`deepidoo-contracts` et deesplay ont besoin d’une version que l’on peut épingler. Des tags coupés à la main s’écartent du changelog et de ce que les consommateurs installent. Le tag d’image d’un service peut suivre le même numéro, pour qu’une PR de promotion Helm se lise « 1.4.2, digest sha256:… ».

## Comment on l’utilise

Quand les phases 3 et 4 commencent à publier. Les commits conventionnels sur `main` alimentent la PR de release. La merger crée le tag. Le tag déclenche la publication GitHub Packages. Un changement cassant est une majeure, ce que le document d’architecture exige déjà pour contracts.

## Installation

L’Action GitHub Release Please, épinglée, dans les dépôts qui publient : `deepidoo-contracts`, puis `deesplay`. Merger sa pull request crée le tag git. Ce tag démarre le workflow de publication GitHub Packages.

## Contraintes

Cela dépend de messages de commit qui disent feat, fix, ou le marqueur de rupture. Un dépôt qui ne les écrit pas n’a pas de release tant que quelqu’un n’édite pas la PR de release. Cela ne déploie pas. Helm reçoit toujours une PR de digest à part.

## Avantages

La version, le changelog et le tag sont un seul merge.

## Inconvénients

De mauvais types de commit produisent une mauvaise version. La PR de release est l’endroit pour corriger cela avant que le tag existe.

## Alternatives

semantic-release, qui tague depuis la CI sans PR. Release Please garde un humain sur la version. Cela correspond à « un humain merge ».
