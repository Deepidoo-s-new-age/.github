# kubeconform

La version anglaise est [README.md](README.md).

## Objet

Contrôler le YAML Kubernetes rendu contre le schéma d’API avant toute application.

## Problème résolu

Un template Helm peut émettre un champ inconnu ou un mauvais type. L’apply Helmfile échoue alors dans le cluster, ou pire, laisse tomber le champ en silence sur une API plus ancienne. C’est la moitié peu chère de l’OWASP A02 (mauvaise configuration).

## Comment on l’utilise

Phase 6, dans la CI de `helm-charts`. Rendre avec `helmfile template` ou `helm template`, puis `kubeconform` sur la sortie. Épingler une version de Kubernetes qui correspond au cluster. Faire échouer la pull request sur les erreurs de schéma. Kyverno, plus tard, applique la politique sur le cluster vivant. kubeconform ne le fait pas.

## Installation

Le runner de CI de `helm-charts` télécharge un binaire kubeconform épinglé et le lance sur le YAML rendu de la pull request.

## Contraintes

Un schéma valide n’est pas une politique de sécurité. Un manifeste valide peut encore tourner en root avec le tag `latest`. Kyverno rejette cela en production.

## Avantages

Quelques secondes, pas de cluster, et il attrape les coquilles dans les templates.

## Inconvénients

Les CRD ont besoin qu’on leur passe leurs schémas, sinon ces ressources sont sautées. Oublier le schéma de CRD rend le contrôle aveugle sur ce type.

## Alternatives

kubeval (plus maintenu), `kubectl apply --dry-run=server` (a besoin du cluster). kubeconform est le contrôle de schéma hors ligne.
