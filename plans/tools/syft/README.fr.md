# syft

La version anglaise est [README.md](README.md).

## Objet

Écrire un SBOM : la liste des paquets dans l’image.

## Problème résolu

Quand une CVE est annoncée, « est-ce qu’on exécute cette bibliothèque ? » doit être une requête, pas un rebuild. Le SBOM est cette liste, attachée au digest qu’on a déployé.

## Comment on l’utilise

Phase 9, dans `image.yml`, sur l’image qui vient d’être construite. Stocker le SBOM à côté de l’image (un artefact OCI ou un artefact de workflow). Il ne décide pas du succès ou de l’échec. Trivy décide des vulnérabilités. syft enregistre le contenu.

## Installation

Le même runner d’`image.yml` installe une release syft épinglée. Il écrit un SBOM pour ce digest et le range comme artefact OCI ou artefact de workflow.

## Contraintes

Un SBOM du build qui n’est pas le digest dans Helm ne sert à rien. Le générer depuis le même digest que Helm épinglera. Il n’inclura pas un paquet installé plus tard par un script d’entrypoint.

## Avantages

Des formats standards (SPDX ou CycloneDX). Pas de compte. Utile le jour où une bibliothèque transitive est dans l’actualité.

## Inconvénients

Personne ne le lit avant ce jour. C’est normal. La valeur est de l’avoir.

## Alternatives

La sortie SBOM de Trivy, `docker sbom`. syft est celui qui écrit. Trivy est celui qui scanne. Garder ces jobs séparés rend le mode d’échec évident.
