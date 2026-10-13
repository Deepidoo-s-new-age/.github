# External Secrets

The French version is [README.fr.md](README.fr.md).

## Purpose

Create Kubernetes Secrets from a store outside git (cloud secret manager, Vault).

## Problem it resolves

SOPS still stores ciphertext in the repo. A store outside git rotates a password without a Helm commit, and the cluster picks it up. The plan allows SOPS or External Secrets. Run one of them, not both for the same key.

## How we use it

Phase 6, only if SOPS is not the choice. The operator runs in the cluster. Helm values name the remote secret. They do not contain it. The operator’s credentials are the one cluster secret installed by hand or by the platform, not by a service repo.

## Installation

One Helm release of the External Secrets operator in the cluster, if SOPS is not the store we keep. The operator’s credential for the secret store is installed with the platform. Helm values name the remote secret.

## Constraints

The cluster must be allowed to read the store. A store outage blocks new pods that need the secret. Preview namespaces need their own path or a fixture secret, not production credentials.

## Pros

Rotation does not require a git commit. Git never holds the secret, encrypted or not.

## Cons

Another live dependency. “What value is in production?” means opening the store, not reading the pull request.

## Alternatives

SOPS, Sealed Secrets. SOPS matches the existing Helm repo. External Secrets matches a team that already has a secret manager. Decide before the first production values file.
