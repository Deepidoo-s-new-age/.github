# dependency-cruiser

La version anglaise est [README.md](README.md).

## Objet

Échouer quand un import frontend traverse une frontière, y compris un import circulaire.

## Problème résolu

Une UI de module qui importe un autre service, ou un cycle entre vues, est un bug de structure. Le typecheck ne le voit pas comme une violation.

## Comment on l’utilise

Le workflow le lance seulement quand un fichier de config est déjà dans le frontend (`.dependency-cruiser.*` ou `dependency-cruiser.config.*`), sur `src`. La phase 5 ajoute cette config une fois le job frontend vert : une UI de module n’importe pas un autre service.

## Installation

devDependency npm du frontend. `npm ci` l’installe une fois que ce dépôt commit le paquet et un fichier de config.

## Contraintes

Pas de config, pas de contrôle. Ajouter une config alors que le graphe actuel est rouge bloque le frontend jusqu’à ce que le graphe soit corrigé ou mis en baseline.

## Avantages

Les arêtes interdites sont un fichier relu. Il comprend TypeScript et Vue si la config le dit.

## Inconvénients

Une devDependency de plus à tenir à jour. Cela vaut le coup seulement quand la règle est réelle.

## Alternatives

eslint-plugin-import, madge pour les cycles seuls. dependency-cruiser couvre les cycles et les dossiers interdits dans une seule config. On utilise celui-là, pas les deux.
