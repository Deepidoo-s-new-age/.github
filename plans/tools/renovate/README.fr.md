# Renovate

La version anglaise est [README.md](README.md).

## Objet

Ouvrir des pull requests qui montent les dépendances, une PR groupée par dépôt et par semaine pour les mineures.

## Problème résolu

pip-audit et npm audit disent qu’une version est vulnérable. Ils ne changent pas le lockfile. Un humain qui chasse les versions ne passe pas à l’échelle de cette organisation. L’OWASP A03, c’est surtout « on a gardé l’ancienne version ».

## Comment on l’utilise

D’abord quand `deepidoo-contracts` est publié (phase 3) : une nouvelle version ouvre une PR chez chaque consommateur. Puis à l’échelle de l’organisation : Python, npm, GitHub Actions et images de base Docker. Grouper les montées mineures et les correctifs. Les montées majeures restent séparées. La PR lance quand même la CI partagée. Le merge est humain.

## Installation

Une GitHub App installée une fois sur l’organisation `Deepidoo-s-new-age`. Le calendrier et les règles de paquets vivent dans une config Renovate partagée.

## Contraintes

Il lui faut une GitHub App ou un jeton capable d’ouvrir des PR. Il ne pousse pas sur `main`. Il n’a pas l’environnement `production`. Épingler la config Renovate dans un dépôt partagé par l’organisation, pour que chaque dépôt New Age n’invente pas un calendrier.

## Avantages

La montée est une pull request normale, avec les mêmes contrôles qu’une fonctionnalité.

## Inconvénients

Une config bruyante crée une file que personne ne lit. Le groupement est le correctif. Une montée majeure cassée peut rester ouverte. C’est préférable à un silence.

## Alternatives

Dependabot. Renovate groupe plus clairement à travers les écosystèmes. On utilise Renovate, pas les deux.
