# Loki

The French version is [README.fr.md](README.fr.md).

## Purpose

Store logs and query them by label, next to the metrics in Grafana.

## Problem it resolves

`kubectl logs` disappears when the pod is gone. A login failure at 02:00 needs the line, with the trace id, after the pod restarted.

## How we use it

Phase 8. Apps log JSON to stdout. The collector ships to Loki. Labels are service, environment, and level. The trace id is a field in the line so a Grafana link can jump to Tempo. Do not label by user id or request path with unbounded values.

## Installation

A Helm chart in the cluster. The collector, or the chart’s shipper, reads JSON on stdout and writes it to Loki.

## Constraints

Loki is not a full-text search engine for every field at search time. High-cardinality labels make it expensive and slow. Secrets in a log line are now in the log store. The Semgrep rule and the team rule exist so that line is not written.

## Pros

Lives beside Grafana and Tempo. Cheap compared with indexing every word.

## Cons

A query that filters on an unindexed field scans a lot of chunks. Structure the JSON fields you actually search.

## Alternatives

Elasticsearch, CloudWatch. Loki matches the Grafana stack in the plan. One log store.
