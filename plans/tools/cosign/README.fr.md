# cosign

La version anglaise est [README.md](README.md).

## Objet

Signer le digest d’image pour que la production puisse refuser une image que nous n’avons pas construite.

## Problème résolu

Quiconque peut pousser sur GHCR, ou retaguer un nom, peut mettre des octets dans un nom que Helm pourrait tirer. Un digest plus une signature signifie que les octets et le constructeur sont ceux que la CI a produits. L’OWASP A08 est ce contrôle.

## Comment on l’utilise

Phase 9, dans `image.yml`, après le push. Signer le digest, pas le tag `:sha` seul. La signature sans clé avec le jeton OIDC de GitHub évite une clé de signature de longue durée dans le dépôt. Kyverno en production n’admet qu’un digest signé que Helmfile a nommé. Les images non signées continuent de fonctionner tant que cette politique n’est pas active : on ne l’active qu’après que la signature est verte depuis un moment.

## Installation

Le runner d’`image.yml` installe une release cosign épinglée. La signature utilise l’OIDC GitHub, donc l’identité de signature est le workflow. La signature est rangée dans GHCR à côté du digest. Kyverno dans le cluster la vérifie ensuite.

## Contraintes

Un `:latest` signé bougerait encore. On ne pousse pas `:latest`. La politique doit exiger un digest. L’identité de signature (le workflow de cette organisation) doit être celle que Kyverno attend, sinon chaque déploiement échoue fermé.

## Avantages

Pas de clé de signature à stocker si on utilise la signature OIDC sans clé. La signature voyage avec le registre.

## Inconvénients

Une politique mal configurée bloque la production. La passer d’abord en mode avertissement. La vérification sans clé a besoin que le cluster atteigne le journal de transparence, sauf si on épingle exprès un autre mode de vérification.

## Alternatives

Notary, Docker Content Trust. cosign est le signataire qui correspond aux exemples habituels de Kyverno. On utilise cosign.
