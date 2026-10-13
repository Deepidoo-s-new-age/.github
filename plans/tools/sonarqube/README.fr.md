# SonarQube Community Build

La version anglaise est [README.md](README.md).

## Objet

Un tableau de bord auto-hébergé de qualité de code sur `main` : issues, duplication, couverture importée depuis la CI.

## Problème résolu

Certains veulent un écran pour « comment va ce dépôt ? » à travers les services. La pull request a déjà ruff, pytest et Semgrep. Sonar ne les remplace pas. C’est optionnel, phase 10.

## Comment on l’utilise

Seulement si l’équipe veut encore cet écran. Community Build est gratuit à auto-héberger. Pointer le scanner sur `main` après les tests et importer `coverage.xml`. Un projet par dépôt. Un gate Sonar rouge ne bloque pas le merge. Les checks GitHub le font.

## Installation

Optionnel. Community Build est un serveur auto-hébergé, son chart Helm ou son conteneur, avec son propre Postgres. Le scanner est une étape de CI sur `main`, le CLI du scanner ou l’Action officielle, et il importe `coverage.xml` du job de tests.

## Contraintes

Community Build analyse la branche main. L’analyse et la décoration de pull request sont une édition payante. Il lance une analyse à la fois, donc beaucoup de dépôts qui finissent ensemble feront la queue. Il lui faut son propre Postgres et des mises à jour. Ses règles de sécurité sont moins profondes que Semgrep, et il ne fait pas l’analyse de taint inter-fichiers qu’on attend d’un outil SAST payant. On n’en fait pas le scanner OWASP.

## Avantages

Une interface. La couverture vient du job de CI qu’on produit déjà. Pas de prix par siège pour le community build.

## Inconvénients

Un serveur à opérer pour une vue qui n’est pas un gate. La file gêne si chaque dépôt scanne en même temps.

## Alternatives

Rien. Les checks de CI sont l’alternative, et ils sont le gate. On ajoute Sonar seulement pour le tableau de bord.
