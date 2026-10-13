# syft

The French version is [README.fr.md](README.fr.md).

## Purpose

Write an SBOM: the list of packages inside the image.

## Problem it resolves

When a CVE is announced, “are we running that library?” should be a query, not a rebuild. The SBOM is that list, attached to the digest we deployed.

## How we use it

Phase 9, in `image.yml`, on the image that was just built. Store the SBOM next to the image (an OCI artifact or a workflow artifact). It does not decide pass or fail. Trivy decides vulnerabilities. syft records contents.

## Installation

The same `image.yml` runner installs a pinned syft release. It writes an SBOM for that digest and stores it as an OCI artifact or a workflow artifact.

## Constraints

An SBOM of the build that was not the digest in Helm is useless. Generate it from the same digest Helm will pin. It will not include a package installed later by an entrypoint script.

## Pros

Standard formats (SPDX or CycloneDX). No account. Useful the day a transitive library is in the news.

## Cons

Nobody reads it until that day. That is fine. The value is having it.

## Alternatives

Trivy’s SBOM output, `docker sbom`. syft is the writer. Trivy is the scanner. Keeping those jobs separate makes the failure mode obvious.
