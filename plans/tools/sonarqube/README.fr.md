# SonarQube Community Build

La version anglaise est [README.md](README.md).

## Objet

Un tableau de bord auto-hébergé de qualité de code sur `main` : issues, duplication, couverture importée depuis la CI.

## Problème résolu

Certains veulent un écran pour « comment va ce dépôt ? » à travers les services. La pull request a déjà ruff, pytest et Semgrep. Sonar ne les remplace pas. C’est optionnel, phase 10.

## Comment on l’utilise

Community Build est gratuit à auto-héberger. Un serveur dans le namespace `sonarqube`, son propre Postgres, chart `helm-charts/charts/sonarqube`. Le scanner est `sonarqube.yml` dans `ci-workflows`, appelé sur `main` après les tests. `auth-service` et `platform-api` l’appellent. Chaque dépôt a `sonar-project.properties` et un projet Sonar. Le job importe `coverage.xml`. `sonar.qualitygate.wait` est faux : un gate Sonar rouge ne fait pas échouer le job et ne bloque pas le merge. Les checks GitHub le font. Le job n’est pas dans les `needs` de l’image ni de la promotion.

## Installation

Le serveur est `sonarqube:26.11.0.134175-community` plus la release `sonarqube-postgres` du chart `charts/postgres` (base `sonar`), tous deux dans le namespace `sonarqube`. Applications Argo CD `sonarqube-postgres` et `sonarqube`. L’URL de debug est `http://sonarqube.51.178.114.227.sslip.io`.

Le scanner est `SonarSource/sonarqube-scan-action` `v8.5.0` dans `sonarqube.yml`, pin `ci-v1.0.23` après **Actions → Tag ci release** sur `main` de `ci-workflows`.

Organisation GitHub `Deepidoo-s-new-age` :

| Nom | Sorte | Valeur |
|---|---|---|
| `SONAR_TOKEN` | secret Actions | Jeton Global Analysis Token dans l’UI SonarQube (My Account → Security), créé après la première connexion |
| `SONAR_HOST_URL` | variable Actions | `http://sonarqube.51.178.114.227.sslip.io` |

Première connexion : `admin` / `admin`. SonarQube exige ensuite un nouveau mot de passe. Ce mot de passe n’est pas dans git. Le mot de passe de base dans le chart est le placeholder inerte `sonar`.

## Contraintes

Community Build analyse la branche main. L’analyse et la décoration de pull request sont une édition payante. Il lance une analyse à la fois, donc beaucoup de dépôts qui finissent ensemble feront la queue. Il lui faut son propre Postgres et des mises à jour. Ses règles de sécurité sont moins profondes que Semgrep, et il ne fait pas l’analyse de taint inter-fichiers qu’on attend d’un outil SAST payant. On n’en fait pas le scanner OWASP.

## Avantages

Une interface. La couverture vient du job de CI qu’on produit déjà. Pas de prix par siège pour le community build.

## Inconvénients

Un serveur à opérer pour une vue qui n’est pas un gate. La file gêne si chaque dépôt scanne en même temps.

## Alternatives

Rien. Les checks de CI sont l’alternative, et ils sont le gate. On ajoute Sonar seulement pour le tableau de bord.
