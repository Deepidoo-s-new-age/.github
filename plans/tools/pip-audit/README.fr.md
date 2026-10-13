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
uvx pip-audit -r /tmp/requirements.pypi.txt
```

Les dépendances par chemin, comme `../../contracts`, sont retirées. C’est notre code, pas un avis PyPI. Une liste d’exceptions est un fichier commité pour une CVE qu’on accepte exprès, avec une raison et une date de retrait.

## Installation

Le workflow lance `uvx pip-audit`, qui télécharge l’outil dans un environnement jetable pour cette étape. La base d’avis est récupérée quand le job tourne. Le fichier de requirements qu’il lit est exporté depuis `uv.lock`.

## Contraintes

Il ne scanne pas les paquets Debian dans l’image d’exécution. Trivy le fait en phase 9. Il n’ouvre pas la pull request de montée. Renovate le fait.

## Avantages

Il utilise le lockfile qu’on commit déjà. Pas de compte supplémentaire.

## Inconvénients

Un nouvel avis peut rendre `main` rouge sans changement de code. La liste d’exceptions est la sortie de secours, pas un silence.

## Alternatives

`uv audit` si une future version d’uv couvre la même base, Safety, OSV-Scanner. Un seul outil d’avis Python suffit. pip-audit est cet outil.
