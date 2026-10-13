# Gatus

The French version is [README.fr.md](README.fr.md).

## Purpose

Probe the product from outside the cluster and record whether users can reach it.

## Problem it resolves

A health check inside the cluster stays green while DNS, the ingress, or the certificate is broken. OWASP A09 is logging and alerting. An outside probe is the alert that the login journey is down.

## How we use it

Phase 8. Gatus runs outside the cluster and hits the three journeys: login, read a content, one module action. Results land on the same Grafana board as the SLOs. The probe uses a fixture account, not a production user’s password in the config repo.

## Installation

Its own small deployment, outside the cluster it probes, from a pinned container image and a YAML config in git. The config holds the three journeys and a fixture account.

## Constraints

The probe must not depend on the same ingress it is testing for its own metrics path. A probe that only checks TCP open is not a journey. Check the HTTP status and a body field that means the app answered.

## Pros

Simple YAML. Status page included. No SaaS account.

## Cons

It does not explain why the check failed. Tempo and Loki do that. Gatus only says it failed.

## Alternatives

Prometheus blackbox exporter, Uptime Kuma. Blackbox is enough if every check is a Prometheus metric and nobody wants a status page. Gatus is the choice when the status page and the YAML live together. Uptime Kuma is a UI-first alternative with less SLO math.
