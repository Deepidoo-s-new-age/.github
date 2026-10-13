# SOPS

The French version is [README.fr.md](README.fr.md).

## Purpose

Keep a secret in git, encrypted, and decrypt it only when a deploy runs.

## Problem it resolves

Database URLs and API keys cannot sit in values files in clear text. They also have to be reviewable as “this key changed” without revealing the value. `Deepidoo/helm_charts` already uses a `.sops.yaml`. The new `helm-charts` can start the same way.

## How we use it

Phase 6, if we pick SOPS rather than External Secrets. Pick one. Encrypted values files live next to the clear values. The GitHub Environment that runs Helmfile holds the age or cloud key that decrypts. Example values committed for documentation stay inert and are not encrypted copies of production.

## Installation

The `helm-charts` deploy job installs the `sops` CLI, and the helm-secrets plugin if the chart uses it. The age or cloud private key is a secret of the GitHub Environment. `.sops.yaml` in `helm-charts` names the public key. Encrypted values files sit next to the plain values.

## Constraints

Whoever has the private key can read every secret in the file. The key is not in the repo. A pull request shows a ciphertext diff, which is hard to review. Do not encrypt the image digest. That line must stay readable.

## Pros

The secret change is a pull request. Offline decrypt works for a break-glass. The team has used this pattern.

## Cons

Git history keeps old ciphertexts. Rotating the data key is a chore. The cluster does not refresh a secret until the next apply.

## Alternatives

External Secrets Operator, which reads a secret store and never puts ciphertext in git. Use that if the secret store already exists. Use SOPS if the secret’s source of truth should be the Helm pull request.
