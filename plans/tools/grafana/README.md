# Grafana

The French version is [README.fr.md](README.fr.md).

## Purpose

One UI for metrics, logs, traces, and the uptime probes.

## Problem it resolves

Four tools with four UIs means nobody looks. Phase 8 puts Prometheus or Mimir, Loki, Tempo, and Gatus behind Grafana. A reused dashboard JSON in `helm-charts` shows rate, errors, and latency for each service so module number five does not hand-build panels.

## How we use it

Dashboards and alert rules are files in git, provisioned into Grafana. Editing a panel in the UI and not exporting it does not count. Alerts go to the channel the team already reads. They fire on SLO burn, not on every error log.

## Installation

A Helm chart in the cluster, in front of Prometheus or Mimir, Loki, Tempo, and the Gatus results. Dashboards and alert rules are files in `helm-charts`, provisioned into Grafana.

## Constraints

Grafana is not the data store. Losing Grafana loses the view, not the history, if Prometheus and Loki keep the data. Do not put production credentials in a dashboard variable that gets shared.

## Pros

One login. The trace, the log line, and the graph are linked.

## Cons

A folder of unowned dashboards rots. The mixin in git is the dashboard that exists.

## Alternatives

The UIs of Prometheus, Loki, and Tempo separately. Grafana is the one we open.
