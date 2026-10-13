# External Secrets

La version anglaise est [README.md](README.md).

## Objet

Créer des Secrets Kubernetes depuis un magasin hors de git (gestionnaire de secrets cloud, Vault).

## Problème résolu

SOPS stocke encore du texte chiffré dans le dépôt. Un magasin hors de git tourne un mot de passe sans commit Helm, et le cluster le reprend. Le plan permet SOPS ou External Secrets. On en fait tourner un, pas les deux pour la même clé.

## Comment on l’utilise

Phase 6, seulement si SOPS n’est pas le choix. L’opérateur tourne dans le cluster. Les values Helm nomment le secret distant. Elles ne le contiennent pas. Les identifiants de l’opérateur sont le seul secret de cluster installé à la main ou par la plateforme, pas par un dépôt de service.

## Installation

Une release Helm de l’opérateur External Secrets dans le cluster, si SOPS n’est pas le magasin qu’on garde. L’identifiant de l’opérateur vers le magasin de secrets est installé avec la plateforme. Les values Helm nomment le secret distant.

## Contraintes

Le cluster doit être autorisé à lire le magasin. Une panne du magasin bloque les nouveaux pods qui ont besoin du secret. Les namespaces de preview ont leur propre chemin ou un secret de fixture, pas les identifiants de production.

## Avantages

La rotation ne demande pas de commit git. Git ne détient jamais le secret, chiffré ou non.

## Inconvénients

Une dépendance vivante de plus. « Quelle valeur est en production ? » veut dire ouvrir le magasin, pas lire la pull request.

## Alternatives

SOPS, Sealed Secrets. SOPS correspond au dépôt Helm existant. External Secrets correspond à une équipe qui a déjà un gestionnaire de secrets. On décide avant le premier fichier de values de production.
