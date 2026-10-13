# Sloth

The French version is [README.fr.md](README.fr.md).

## Purpose

Generate Prometheus recording and alert rules for an SLO from a short spec.

## Problem it resolves

“Alert when login is down” pages on one blip. An error budget burns when users are actually having a bad hour. Sloth turns “99.9 percent of logins succeed over 30 days” into the burn-rate alerts Grafana fires.

## How we use it

Phase 8, after metrics exist. Three SLOs: login, read a content, one module action. Specs live in git next to the dashboards. Sloth generates the rules. Prometheus loads them. Pick Sloth or Pyrra, not both.

## Installation

A CLI, or a one-shot container, run from CI or from a chart hook. Specs are YAML in git next to the dashboards. It writes PrometheusRule manifests that Prometheus loads. The plan runs Sloth or Pyrra.

## Constraints

The SLO is only as good as the metric. A metric that counts health checks as success will never burn. Exclude probes. Sloth does not collect metrics. Prometheus does.

## Pros

The spec is a few lines. The multi-window burn alerts are the part that is easy to get wrong by hand.

## Cons

Generated rules are noisy to review in a diff. Review the spec, not every generated line.

## Alternatives

Pyrra, which adds a UI. Hand-written PromQL. Sloth is the default if we want files and no extra server.
