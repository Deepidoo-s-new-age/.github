# Prometheus

The French version is [README.fr.md](README.fr.md).

## Purpose

Store and query service metrics: request rate, error rate, latency.

## Problem it resolves

Logs say a request failed. They do not say whether five percent of login requests have been failing for twenty minutes. Grafana reads Prometheus for the RED dashboards and for the SLO burn alerts.

## How we use it

Phase 8. The OpenTelemetry collector remote-writes, or the services expose a scrape endpoint. One dashboard JSON in `helm-charts` is reused per service. Alert on burn rate for three journeys, not on every 500.

## Installation

One Helm release in the cluster, Prometheus or the kube-prometheus stack. Applications expose metrics, or the collector remote-writes. Dashboard JSON lives in `helm-charts` and is provisioned from there.

## Constraints

A single Prometheus keeps data for a short retention. It is not a long-term archive. When that hurts, move storage to Mimir. Do not run both as two sources of truth.

## Pros

The query language (PromQL) is what Sloth, Pyrra, and Grafana already speak. Simple to run for this number of services.

## Cons

Local disk fills up. Cardinality from a label like `user_id` will take it down. Do not put user ids on metrics.

## Alternatives

Mimir, VictoriaMetrics, a SaaS metrics product. Prometheus first.
