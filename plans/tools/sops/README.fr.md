# SOPS

La version anglaise est [README.md](README.md).

## Objet

Garder un secret dans git, chiffré, et ne le déchiffrer qu’au moment d’un déploiement.

## Problème résolu

Les URL de base et les clés d’API ne peuvent pas rester en clair dans les fichiers de values. Il faut aussi pouvoir relire « cette clé a changé » sans révéler la valeur. `Deepidoo/helm_charts` utilise déjà un `.sops.yaml`. Le nouveau `helm-charts` peut commencer de la même façon.

## Comment on l’utilise

Phase 6, si on choisit SOPS plutôt qu’External Secrets. On en choisit un. Les fichiers de values chiffrés vivent à côté des values en clair. Le GitHub Environment qui lance Helmfile détient la clé age ou cloud qui déchiffre. Les valeurs d’exemple commitées pour la documentation restent inertes et ne sont pas des copies chiffrées de la production.

## Installation

Le job de déploiement de `helm-charts` installe le CLI `sops`, et le plugin helm-secrets si le chart s’en sert. La clé privée age ou cloud est un secret du GitHub Environment. `.sops.yaml` dans `helm-charts` nomme la clé publique. Les fichiers de values chiffrés sont à côté des values en clair.

## Contraintes

Qui a la clé privée peut lire chaque secret du fichier. La clé n’est pas dans le dépôt. Une pull request montre un diff de texte chiffré, difficile à relire. On ne chiffre pas le digest d’image. Cette ligne doit rester lisible.

## Avantages

Le changement de secret est une pull request. Le déchiffrement hors ligne sert de break-glass. L’équipe a déjà utilisé ce schéma.

## Inconvénients

L’historique git garde d’anciens textes chiffrés. Tourner la clé de données est une corvée. Le cluster ne rafraîchit un secret qu’au prochain apply.

## Alternatives

External Secrets Operator, qui lit un magasin de secrets et ne met jamais de texte chiffré dans git. On l’utilise si le magasin existe déjà. On utilise SOPS si la source de vérité du secret doit être la pull request Helm.
