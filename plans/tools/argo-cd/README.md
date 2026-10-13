# Argo CD

The French version is [README.fr.md](README.fr.md).

## Purpose

Watch `helm-charts` and apply the cluster so git stays the source of truth without a kubeconfig in GitHub Actions.

## Problem it resolves

Helmfile-from-Actions works, and it stores a cluster credential in GitHub. A compromise of that environment can change production. Argo runs inside the cluster and pulls git.

## How we use it

After two services deploy through Helmfile (phase 6). Argo watches `deepidoo-s-new-age/helm-charts`. Preproduction syncs on merge. Production syncs only when the `production` GitHub Environment, or an Argo sync window with the same reviewer rule, allows it. The kubeconfig secret leaves GitHub Actions once Argo is the applier. Drift shows up in Argo instead of in a surprise `kubectl diff`.

## Installation

One Helm release of the upstream Argo CD chart in the cluster, after two services already deploy with Helmfile. From then on, Argo applies what git says, and the kubeconfig leaves the GitHub Environment.

## Constraints

Do not install it before the values files and the digest flow exist. Two deploy systems at once, with different values, will fight.

## Pros

The cluster reconciles to git. Rollbacks are git reverts. Actions no longer holds long-lived cluster admin.

## Cons

Another component to upgrade. A bad sync policy can auto-apply a production values change we meant to review.

## Alternatives

Stay on Helmfile-from-Actions. That is the first step. Argo replaces the apply, not the chart.
