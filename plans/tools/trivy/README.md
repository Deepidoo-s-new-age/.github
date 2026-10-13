# Trivy

The French version is [README.fr.md](README.fr.md).

## Purpose

Scan the built container image for known vulnerabilities in OS packages.

## Problem it resolves

pip-audit sees Python packages. The image is `python:3.14-slim` plus apt packages such as git. A CVE in those packages never appears in `uv.lock`. That gap is OWASP A03 for the artifact we actually run.

## How we use it

Phase 9, in `image.yml`, after the image is built. Scan the image digest. Fail on critical and high, with a committed ignore file for a CVE we accept, including a reason and a date. Do not fail the pull-request job on a Debian CVE before images are the thing we deploy. Phase 9 is after promotion works.

## Installation

The `image.yml` runner installs a pinned Trivy CLI, the Trivy Action or a pinned container, and scans the image that was just built. The scanner stays on the runner.

## Constraints

It reports what the advisory database knew that day. A new CVE turns a previously green digest red. Decide whether production Kyverno cares about the scan result or only about the signature. The plan uses Kyverno for signature and digest, and Trivy as the CI gate on the build.

## Pros

One binary for images. No account. Also understands Kubernetes manifests if we ever want a second opinion beside kubeconform. We do not need that second opinion on day one.

## Cons

Noise from low-severity issues in the base image. Gate on high and critical only. Fix the base image on a schedule rather than blocking every feature PR.

## Alternatives

Grype, Docker Scout. Trivy is the image scanner. pip-audit stays the Python scanner. They do not replace each other.
