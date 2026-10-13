# Helmfile

The French version is [README.fr.md](README.fr.md).

## Purpose

List which Helm releases exist in an environment and apply one of them.

## Problem it resolves

Preproduction and production are sets of services, not one chart. Someone has to say “auth-service in preproduction uses this values file” and apply only that release.

## How we use it

Phase 6. `deepidoo-s-new-age/helm-charts` is the only repo whose workflows talk to the cluster.

```text
environments/preproduction/helmfile.yaml
environments/preproduction/<service>.values.yaml
environments/production/helmfile.yaml
environments/production/<service>.values.yaml
```

Merging a digest into preproduction runs:

```bash
helmfile -f environments/preproduction/helmfile.yaml --selector name=auth-service apply
```

from a GitHub Environment named `preproduction`. Production is a second pull request that copies the same digest, and the `production` environment requires a reviewer. Rollback is `helm rollback` or a pull request that restores the previous digest.

Preview namespaces in phase 7 are a Helmfile release with a generated name, destroyed when the pull request closes.

## Installation

The same `helm-charts` runner installs a pinned Helmfile CLI next to Helm. The release list is `environments/<env>/helmfile.yaml` in that repository.

## Constraints

Until Argo CD exists, the kubeconfig secret lives only on this repo’s GitHub Environments. Service repos never get it. The legacy repo `Deepidoo/helm_charts` is not the target of these workflows.

## Pros

One command applies one service. The desired digest is a line in git.

## Cons

Apply-from-Actions holds cluster credentials. That is why Argo CD comes after two services deploy this way.

## Alternatives

Argo CD from day one. Helmfile first matches the tool the team already runs, then Argo watches the same files.
