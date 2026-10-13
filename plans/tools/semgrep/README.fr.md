# Semgrep Community Edition

La version anglaise est [README.md](README.md).

## Objet

Scanner le source Python et Vue à la recherche de motifs dangereux, mappés sur l’OWASP Top 10.

## Problème résolu

Les tests prouvent les cas qu’on a écrits. Ils ne remarquent pas un nouvel appel `subprocess` construit depuis une requête, un mot de passe en dur, ou une ligne de log qui imprime un JWT. Semgrep est le scanner de code pour ces motifs. La liste à laquelle on le rattache est [OWASP Top 10:2025](https://owasp.org/Top10/2025/).

## Comment on l’utilise

Phase 5, workflow réutilisable `security.yml` :

```bash
semgrep scan --error --config p/owasp-top-ten --config p/python --config p/javascript
```

Épingler la version du CLI. Le moteur est en LGPL 2.1. Les règles du registre sont gratuites pour un usage interne. Si le premier passage est bruyant, on ne fait échouer que les findings absents d’une baseline commitée.

Ce job vise A04 (défaillances cryptographiques), A05 (injection), une partie de A01 (traversée de chemin, redirection ouverte, SSRF évidente) et une partie de A10 (fail-open, handlers vides). Les tests de contrôle d’accès et le validateur d’architecture gardent A01 et A07. pip-audit, Renovate et Trivy gardent A03.

## Installation

Le job `security.yml` installe un CLI Community Edition épinglé sur le runner : l’Action officielle Semgrep, un `pip install` épinglé, ou un conteneur épinglé. Les règles `p/owasp-top-ten`, `p/python` et `p/javascript` sont téléchargées depuis le registre Semgrep quand le job tourne.

## Contraintes

Community Edition regarde à l’intérieur d’une fonction. Un bug qui traverse plusieurs helpers demande le moteur Pro, payant, qu’on n’utilise pas. CodeQL est plus fort sur ce flux de données et n’est gratuit que pour les dépôts publics. Ces dépôts de services sont privés, donc CodeQL y est GitHub Code Security, payant. On ne lance pas bandit à côté de Semgrep. SonarQube n’est pas ce scanner.

## Avantages

Un job, pas de serveur, les deux langages, et des règles custom plus tard si un motif d’équipe doit faire échouer le build.

## Inconvénients

Des faux positifs au premier passage. L’analyse à une fonction rate certains vrais bugs d’injection. La licence des règles vaut pour l’usage interne, pas pour revendre un service de scan.

## Alternatives

CodeQL (payant ici), les règles de sécurité SonarQube (moins profondes), bandit (Python seulement, recouvre Semgrep). Semgrep CE est le scanner gratuit qui tient dans ce pipeline.
