# cosign

The French version is [README.fr.md](README.fr.md).

## Purpose

Sign the image digest so production can refuse an image we did not build.

## Problem it resolves

Anyone who can push to GHCR, or retag a name, can put bytes in a name Helm might pull. A digest plus a signature means the bytes and the builder are the ones CI produced. OWASP A08 is this check.

## How we use it

Phase 9, in `image.yml`, after the push. Sign the digest, not the `:sha` tag alone. Keyless signing with GitHub’s OIDC token avoids a long-lived signing key in the repo. Kyverno in production admits only a signed digest that Helmfile named. Unsigned images keep working until that policy is on, so turn the policy on only after signing has been green for a while.

## Installation

The `image.yml` runner installs a pinned cosign release. Signing uses GitHub OIDC, so the signing identity is the workflow. The signature is stored in GHCR beside the digest. Kyverno in the cluster verifies it later.

## Constraints

A signed `:latest` would still move. We do not push `:latest`. The policy has to require a digest. The signing identity (this org’s workflow) has to be what Kyverno expects, or every deploy fails closed.

## Pros

No signing key to store if OIDC keyless signing is used. The signature travels with the registry.

## Cons

A misconfigured policy blocks production. Stage it in warning mode. Keyless verification needs the cluster to reach the transparency log, unless we pin a different verification mode on purpose.

## Alternatives

Notary, Docker Content Trust. cosign is the signer that matches Kyverno’s usual examples. Use cosign.
