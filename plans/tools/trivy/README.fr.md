# Trivy

La version anglaise est [README.md](README.md).

## Objet

Scanner l’image de conteneur construite à la recherche de vulnérabilités connues dans les paquets du système.

## Problème résolu

pip-audit voit les paquets Python. L’image est `python:3.14-slim` plus des paquets apt comme git. Une CVE dans ces paquets n’apparaît jamais dans `uv.lock`. Cet écart est l’OWASP A03 pour l’artefact qu’on exécute vraiment.

## Comment on l’utilise

Phase 9, dans `image.yml`, après la construction de l’image. Scanner le digest de l’image. Échouer sur critical et high, avec un fichier d’ignore commité pour une CVE qu’on accepte, raison et date comprises. On ne fait pas échouer le job de pull request sur une CVE Debian avant que les images soient ce qu’on déploie. La phase 9 vient après que la promotion fonctionne.

## Installation

Le runner d’`image.yml` installe un CLI Trivy épinglé, l’Action Trivy ou un conteneur épinglé, et scanne l’image qui vient d’être construite. Le scanner reste sur le runner.

## Contraintes

Il rapporte ce que la base d’avis savait ce jour-là. Une nouvelle CVE rend rouge un digest qui était vert. Décider si le Kyverno de production se soucie du résultat de scan ou seulement de la signature. Le plan utilise Kyverno pour la signature et le digest, et Trivy comme gate de CI sur le build.

## Avantages

Un binaire pour les images. Pas de compte. Il comprend aussi les manifestes Kubernetes si on veut un second avis à côté de kubeconform. On n’a pas besoin de ce second avis le premier jour.

## Inconvénients

Du bruit venant des issues de basse sévérité dans l’image de base. Le gate ne porte que sur high et critical. On corrige l’image de base sur un calendrier, plutôt que de bloquer chaque PR de fonctionnalité.

## Alternatives

Grype, Docker Scout. Trivy est le scanner d’image. pip-audit reste le scanner Python. Ils ne se remplacent pas.
