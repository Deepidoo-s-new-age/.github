# Helm

The French version is [README.fr.md](README.fr.md).

## Purpose

Render a Kubernetes Deployment, Service, and migration Job from one chart and a values file.

## Problem it resolves

Copying YAML per service drifts. A chart is the shape. The values file is the one thing that changes per service and per environment: the image digest, env, resources.

## How we use it

Phase 6, inside `deepidoo-s-new-age/helm-charts`. `charts/app` for a long-running service. `charts/job` for Alembic. Values pin:

```yaml
image:
  repository: ghcr.io/deepidoo-s-new-age/auth-service
  digest: sha256:…
```

Production and preproduction use the same chart. They differ by values. `kubeconform` checks the rendered YAML.

## Installation

The `helm-charts` runner installs a pinned Helm CLI, through a setup action or the official binary. The charts are files in `deepidoo-s-new-age/helm-charts` under `charts/`.

## Constraints

Helm does not apply itself in this plan. Helmfile is the command that applies. A chart change is a pull request. A digest change is a pull request. Nobody edits the cluster to change an image.

## Pros

The team already uses Helm charts in `Deepidoo/helm_charts`. The new repo can reuse that shape without taking that repo as a dependency.

## Cons

Charts hide a lot of YAML. A bad default (running as root, no resources) reaches every service. Kyverno rejects those defaults in production later.

## Alternatives

Raw manifests, Kustomize. Helm is the packaging. Helmfile is the environment list. We use both, for those two jobs.
