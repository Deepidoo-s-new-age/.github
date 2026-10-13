# Grafana Mimir

The French version is [README.fr.md](README.fr.md).

## Purpose

Store Prometheus metrics for longer, across more than one Prometheus, with the same PromQL.

## Problem it resolves

Prometheus on one disk is the phase 8 start. A retention of a few weeks is not enough for an SLO that looks at 30 days, and a second cluster should not mean a second query language.

## How we use it

Only after Prometheus is in place and retention or high availability is the actual problem. Grafana points at Mimir instead of at Prometheus. Recording rules and Sloth rules stay PromQL. Do not introduce Mimir in the same change as the first dashboard.

## Installation

A Helm chart in the cluster, added when Prometheus retention or high availability is the limit. It stores data in an object-storage bucket. Grafana then reads Mimir.

## Constraints

It expects object storage. That is another bucket and another credential. A small cluster does not need it yet.

## Pros

Same dashboards and alerts. Horizontal storage.

## Cons

More moving parts than one Prometheus. Operating it is a project.

## Alternatives

Stay on Prometheus with short retention. Thanos. Mimir is the Grafana-native step when Prometheus is the limit, not before.
