# Pyrra

The French version is [README.fr.md](README.fr.md).

## Purpose

Define SLOs and show their error budgets, generating Prometheus rules like Sloth and adding a UI.

## Problem it resolves

The same problem as Sloth: page on budget burn, not on a single error. Pyrra is the alternative when the team wants a page that shows the budget without building that view in Grafana by hand.

## How we use it

Phase 8, instead of Sloth, not beside it. The three journeys are the same: login, read a content, one module action. Pyrra writes the Prometheus rules and serves the UI. Grafana can still graph the same recording rules.

## Installation

A Helm release in the cluster, the Pyrra chart and its CRDs, in place of Sloth. It reads Prometheus and serves its own page.

## Constraints

Another service to run and authenticate. It needs Prometheus. It does not replace Gatus. An SLO inside the cluster does not prove the ingress is reachable.

## Pros

The budget is visible without a custom dashboard. The rules are still Prometheus-native.

## Cons

Two places to look if Grafana is already the standard UI. More to operate than a Sloth-generated file.

## Alternatives

Sloth. Choose Sloth unless someone will actually open the Pyrra UI. Do not run both generators on the same SLO.
