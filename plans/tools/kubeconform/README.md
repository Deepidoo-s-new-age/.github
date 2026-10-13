# kubeconform

The French version is [README.fr.md](README.fr.md).

## Purpose

Check rendered Kubernetes YAML against the API schema before anything is applied.

## Problem it resolves

A Helm template can emit an unknown field or a wrong type. Helmfile apply then fails in the cluster, or worse, silently drops the field on an older API. This is the cheap half of OWASP A02 (misconfiguration).

## How we use it

Phase 6, in `helm-charts` CI. Render with `helmfile template` or `helm template`, then `kubeconform` on the output. Pin a Kubernetes version that matches the cluster. Fail the pull request on schema errors. Kyverno, later, enforces policy on the live cluster. kubeconform does not.

## Installation

The `helm-charts` CI runner downloads a pinned kubeconform binary and runs it on the rendered YAML of the pull request.

## Constraints

Schema validity is not security policy. A valid manifest can still run as root with tag `latest`. Kyverno rejects that in production.

## Pros

Seconds, no cluster, catches typos in templates.

## Cons

CRDs need their schemas passed in, or those resources are skipped. Forget the CRD schema and the check is blind to that kind.

## Alternatives

kubeval (unmaintained), `kubectl apply --dry-run=server` (needs the cluster). kubeconform is the offline schema check.
