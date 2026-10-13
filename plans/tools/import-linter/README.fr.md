# import-linter

La version anglaise est [README.md](README.md).

## Objet

Échouer quand un import Python traverse une frontière que l’architecture interdit.

## Problème résolu

Un module qui importe le code applicatif de `platform-api`, ou un handler de route qui importe la session SQLAlchemy et écrit du SQL, casse la règle : les services se parlent en HTTP, et les repositories possèdent le SQL. La revue peut le manquer. Un contrôle de contrat, non.

## Comment on l’utilise

Phase 5, dans `python-service.yml`, une fois qu’une config existe dans le service. Contrats à encoder :

- ce service n’importe pas le package applicatif d’un autre service ;
- les modules de route n’importent pas la session DB ; les repositories le font.

Les violations existantes vont dans une baseline pour que le premier jour ne soit pas une réécriture. Les nouvelles violations échouent.

## Installation

Dépendance de dev Python du service, dans `pyproject.toml` et `uv.lock`. `uv sync` l’installe une fois que le service commit un fichier de contrat.

## Contraintes

Il voit les imports, pas les appels HTTP. Un appel `httpx` interdit vers un autre service reste du ressort du validateur d’architecture et de la revue.

## Avantages

La règle est un fichier du dépôt, relu comme du code. Rapide.

## Inconvénients

Quelqu’un peut cacher un import derrière une chaîne. C’est rare à côté d’un import normal.

## Alternatives

Des règles Semgrep pour les mêmes imports. import-linter est l’outil de couches. Semgrep reste le scanner de sécurité. On ne duplique pas les règles de couches là-bas.
