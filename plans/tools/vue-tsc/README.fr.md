# vue-tsc

La version anglaise est [README.md](README.md).

## Objet

Vérifier les types des composants Vue à fichier unique et du TypeScript d’un frontend.

## Problème résolu

Un template peut passer la mauvaise prop et Vite construira quand même si personne ne lance le vérificateur. Le frontend d’`auth-service` dépend déjà de `vue-tsc` et son script de build est `vue-tsc -b && vite build`.

## Comment on l’utilise

Phase 0, dans `vue-app.yml`, seulement quand le job est activé.

- Si `package.json` a un script `typecheck`, lancer celui-là.
- Sinon, si `vue-tsc` est installé, lancer `vue-tsc --noEmit`.

`run_build` reste à false tant que `npm run build` n’est pas vert contre le package deesplay publié. Le script de build utilise `vue-tsc -b`, le mode références de projet. `--noEmit` et `-b` ne sont pas la même commande. Quand le dépôt a un `tsconfig` qui a besoin de `-b`, le script `typecheck` doit être cette commande, et le workflow suivra le script.

## Installation

devDependency npm du frontend qui la déclare déjà. Le frontend d’`auth-service` le fait. `npm ci` l’installe avec le reste du lockfile.

## Contraintes

Le vérificateur d’`auth-service` ne peut pas passer tant que Vite alias `@deepidoo/deesplay` vers un dossier que la CI n’a pas. La phase 4 retire cet alias.

## Avantages

Il utilise le binaire que le dépôt a déjà installé. Pas de second vérificateur TypeScript.

## Inconvénients

Lent sur les grosses applications. Toujours moins cher qu’un build de production à chaque pull request.

## Alternatives

`tsc --noEmit` seul ignore les fichiers `.vue`. Le vérificateur de Volar est le même moteur que vue-tsc. On utilise vue-tsc.
