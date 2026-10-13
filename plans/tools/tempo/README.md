# Tempo

The French version is [README.fr.md](README.fr.md).

## Purpose

Store traces: one request’s path across auth, platform, and a module.

## Problem it resolves

Latency in a module might be the module, or it might be the call to `platform-api`. Logs from three services do not show that unless they share a trace. Tempo is the trace half of the phase 8 stack. Metrics still need Prometheus. Logs still need Loki.

## How we use it

The OpenTelemetry collector exports traces to Tempo. Grafana links a RED spike to traces and a trace to logs. Services propagate the incoming trace header on outbound HTTP. Sampling can start at a modest rate and go to always-on for errors.

## Installation

A Helm chart in the cluster. The OpenTelemetry collector exports traces to it. The service image carries the SDK and leaves the store in the cluster.

## Constraints

A service that starts a new trace instead of continuing the header splits the story. Tempo does not alert by itself. Burn alerts stay on metrics.

## Pros

The trace is the picture of this architecture, because the architecture is HTTP between services.

## Cons

High sample rates get expensive. Unsampled errors are the ones you will want. Sample errors at 100 percent.

## Alternatives

Jaeger. Tempo is the Grafana default next to Loki and Mimir. Use Tempo.
