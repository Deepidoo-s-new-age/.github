# Vitest

La version anglaise est [README.md](README.md).

## Objet

Lancer les tests unitaires frontend.

## Problème résolu

`vue-tsc` vérifie les types. Il ne vérifie pas qu’un bouton envoie le formulaire. Les frontends de cette organisation n’ont pas tous un script de test. Le frontend d’`auth-service` n’a pas de script `test`.

## Comment on l’utilise

`vue-app.yml` lance `npm test` (ou Yarn ou pnpm) seulement quand `package.json` définit un script `test`. Quand un frontend ajoute des tests, ce script doit être Vitest. Le workflow partagé n’installe pas Vitest lui-même.

## Installation

devDependency npm que le frontend ajoute quand il ajoute un script `test`. La même installation figée qui remplit `node_modules` l’installe. Le workflow partagé attend que le dépôt la déclare.

## Contraintes

Un script de test qui lance un navigateur ou une vraie API n’a pas sa place sur le job de pull request par défaut. Vitest reste sur jsdom ou happy-dom. Les tests navigateur attendent l’environnement de preview.

## Avantages

Le même pipeline Vite que l’application : les alias et les composants Vue se chargent comme dans l’application.

## Inconvénients

Un script absent ou vide ne fait pas échouer. Un frontend peut rester sans tests jusqu’à ce que quelqu’un ajoute le script. C’est voulu jusqu’à la phase 4.

## Alternatives

Jest. Les nouveaux tests vont vers Vitest pour que le runner corresponde à Vite. On n’ajoute pas Jest à côté.
