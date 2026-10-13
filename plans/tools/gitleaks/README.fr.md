# gitleaks

La version anglaise est [README.md](README.md).

## Objet

Trouver les secrets commités dans l’arbre : jetons, clés privées, mots de passe.

## Problème résolu

Un secret JWT ou un kubeconfig dans une pull request devient un identifiant dès qu’il arrive sur GitHub. C’est le contrôle OWASP 2025 A04 qui ne demande pas de lire la logique du code.

## Comment on l’utilise

Phase 0, première étape de chaque workflow partagé, version 8.30.1.

```bash
gitleaks detect --source "$GITHUB_WORKSPACE" --no-git --redact --exit-code 1
```

`--no-git` scanne les fichiers du checkout. Les pull requests sont peu profondes : un scan d’historique raterait l’essentiel et coûterait du temps. `--redact` garde le secret hors du journal.

## Installation

Chaque workflow partagé télécharge le binaire de la release 8.30.1 sur le runner. C’est un exécutable autonome, à part des lockfiles Python et npm.

## Contraintes

Il rate un secret qui ne correspond à aucun motif, et il peut signaler une fixture de test. Les valeurs inertes du workflow (`ci-test-secret`) ont été vérifiées avec 8.30.1 et ne correspondaient pas. Une nouvelle fixture qui ressemble à une vraie clé a besoin d’une entrée d’allowlist avec une raison.

## Avantages

Pas de serveur. Il tourne avant l’installation : un secret fait échouer le job même si les tests échouent ensuite.

## Inconvénients

Le scan de fichiers ne voit pas les secrets commités puis supprimés. Un scan d’historique ponctuel du dépôt est une tâche à part quand on soupçonne une fuite.

## Alternatives

trufflehog, le secret scanning de GitHub. gitleaks est le contrôle qu’on possède dans la CI. Le produit GitHub est en plus, et sur les dépôts privés il fait partie d’un plan payant.
