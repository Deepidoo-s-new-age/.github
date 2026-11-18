# pip-audit

La version anglaise est [README.md](README.md).

## Objet

Faire échouer le build quand une dépendance Python verrouillée a une vulnérabilité connue.

## Problème résolu

Un lockfile rend les builds reproductibles. Il conserve aussi une version vulnérable jusqu’à ce que quelqu’un la monte. Ce job est l’alarme de cette montée. Il correspond à l’OWASP 2025 A03 (chaîne d’approvisionnement).

## Comment on l’utilise

Phase 0, à la fin des workflows Python.

```bash
uv export --frozen --no-dev --no-hashes -o /tmp/requirements.txt
grep -v -E '^-e |^file:' /tmp/requirements.txt > /tmp/requirements.pypi.txt
uvx pip-audit -r /tmp/requirements.pypi.txt --format json
```

Les dépendances par chemin, comme `../../contracts`, sont retirées. C’est notre code, pas un avis PyPI. Un avis fait échouer le job quand pip-audit indique une version corrigée. Un avis sans version corrigée est un avertissement. Il n’y a pas de liste d’exceptions.

## Installation

Le workflow lance `uvx pip-audit`, qui télécharge l’outil dans un environnement jetable pour cette étape. La base d’avis est récupérée quand le job tourne. Le fichier de requirements qu’il lit est exporté depuis `uv.lock`.

## Contraintes

Il ne scanne pas les paquets Debian dans l’image d’exécution. Trivy le fait en phase 9. Il n’ouvre pas la pull request de montée. Renovate le fait.

## Avantages

Il utilise le lockfile qu’on commit déjà. Pas de compte supplémentaire.

## Inconvénients

Un nouvel avis qui a une version corrigée peut rendre `main` rouge sans changement de code. Un avis qui n’a toujours pas de version corrigée avertit et laisse le job vert.

## Alternatives

`uv audit` si une future version d’uv couvre la même base, Safety, OSV-Scanner. Un seul outil d’avis Python suffit. pip-audit est cet outil.
