# Kyverno

The French version is [README.fr.md](README.fr.md).

## Purpose

Reject Kubernetes resources that break production policy, at admission time.

## Problem it resolves

A values file can still say `latest`, run as root, or omit CPU limits. CI might miss a manifest someone applied by hand. Kyverno is the cluster saying no. It is the live half of OWASP A02, after kubeconform has checked schema.

## How we use it

Phase 9, after digests are the only tags we deploy. Policies, in order:

1. Images in production use a digest, not a tag.
2. Then images are signed (cosign).
3. Non-root, resource limits, no privilege escalation.

Start in audit mode. Switch a policy to enforce when the audit log is clean. Policies live in git with `helm-charts`.

## Installation

One Helm release of the admission controller in the production cluster. Policies are YAML in `helm-charts` and start in audit mode.

## Constraints

Enforce mode on a policy the current workloads violate will block the next deploy, including a rollback if the old manifest also violates it. Audit first. Do not enforce on preview namespaces the same day as production if previews are allowed to be looser. Say so in the policy.

## Pros

The rule is YAML the team can read. It covers applies that did not come from the happy-path workflow.

## Cons

A bad policy is an outage. Audit mode exists for that reason.

## Alternatives

OPA Gatekeeper. Kyverno policies look like Kubernetes resources. Use Kyverno.
