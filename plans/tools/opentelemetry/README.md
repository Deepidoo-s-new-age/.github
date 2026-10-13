# OpenTelemetry

The French version is [README.fr.md](README.fr.md).

## Purpose

One instrumentation path that emits traces, metrics, and logs from each FastAPI service.

## Problem it resolves

A module calls `platform-api`, which calls auth. Three log formats and no shared request id make a latency spike unreadable. Phase 8 waits until deploys have digests, so a trace can be tied to a version.

## How we use it

Instrument `auth-service`, `platform-api`, then modules. Export to one collector in the cluster. The collector fans out to Prometheus or Mimir, Loki, and Tempo. Propagate the trace header on outbound HTTP. Do not log `Authorization`, JWTs, or passwords. A Semgrep rule backs that up.

Start with rate, errors, and latency per service. Do not invent a custom metric per route on day one.

## Installation

Two pieces. The Python SDK is a dependency of each FastAPI app, in `pyproject.toml` and `uv.lock`, and ships inside that service image. The collector is its own deployment in the cluster, the OpenTelemetry Collector chart, and it forwards to Prometheus or Mimir, Loki, and Tempo.

## Constraints

The SDK version has to match the collector protocol. A service that forgets the header splits the trace. Instrumentation that records request bodies will store personal data. Do not do that.

## Pros

One library for three signals. Vendors can change later without rewriting the apps.

## Cons

A collector to run and upgrade. Bad sampling hides the one slow request you needed.

## Alternatives

A vendor agent per signal (Prometheus client plus a log shipper plus a tracer). OpenTelemetry replaces that split.
