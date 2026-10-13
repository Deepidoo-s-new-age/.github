# npm, Yarn et pnpm

La version anglaise est [README.md](README.md).

## Objet

Installer les dépendances JavaScript depuis le lockfile que le dépôt commit déjà, puis les auditer.

## Problème résolu

`npm install` sans lock peut changer les versions entre deux exécutions de CI. Un lock non audité conserve un paquet vulnérable connu jusqu’à ce que quelqu’un le remarque.

## Comment on l’utilise

Phase 0, `vue-app.yml`. Le workflow regarde le lockfile dans `working_directory` :

| Lockfile | Installation |
|---|---|
| `package-lock.json` | `npm ci` |
| `yarn.lock` | `yarn install --frozen-lockfile` |
| `pnpm-lock.yaml` | `pnpm install --frozen-lockfile` |

L’absence de lockfile fait échouer le job. L’audit échoue sur high et critical : `npm audit --audit-level=high`, ou l’équivalent Yarn ou pnpm.

Le frontend d’`auth-service` utilise npm et `package-lock.json`. Le job reste éteint jusqu’à la phase 4, parce que ce lockfile lie `file:../../deesplay`. Une fois deesplay publié sur GitHub Packages, le workflow a besoin d’un `.npmrc` et de `NODE_AUTH_TOKEN`.

## Installation

Le runner reçoit Node via `actions/setup-node@v4`. npm est livré avec ce Node. Yarn ou pnpm est activé quand le lockfile le demande, par Corepack ou par l’installeur de ce gestionnaire. `npm ci`, ou l’installation figée Yarn ou pnpm, remplit `node_modules` sur le runner. L’image API laisse cet arbre derrière elle. Une image frontend, si on en ajoute une plus tard, emporterait son propre résultat de build.

## Contraintes

`npm audit` interroge la base d’avis npm, pas les paquets OS ni Python. Les codes de sortie de l’audit Yarn v1 sont un masque de bits et peuvent échouer pour des sévérités plus basses. Les nouveaux frontends préfèrent npm, pour que la commande d’audit reste celle de ce tableau.

## Avantages

Le lockfile est le contrat. `npm ci` supprime `node_modules` et s’y aligne.

## Inconvénients

Du bruit d’audit sur les paquets transitifs. Renovate est le moyen de monter la version. L’audit n’est que le gate.

## Alternatives

Faire tourner les trois gestionnaires dans un même dépôt. Un lockfile par frontend. Le workflow accepte celui que le dépôt a déjà choisi.
