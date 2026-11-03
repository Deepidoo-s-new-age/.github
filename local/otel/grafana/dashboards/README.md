Provisioned Grafana dashboards for the local stack.

Source of truth: `helm-charts/charts/grafana/dashboards/` (Service, Errors, Uptime, Workloads + `provider.yaml`).

When dashboards change in Helm, refresh this folder from that path (at least `errors.json` when alert/stat windows change) and recreate `na-grafana`.

### Local behaviour

| Dashboard | Local stack |
|-----------|-------------|
| **Service** / **Errors** | Need OTLP HTTP metrics from auth/platform (`DEEPILOT_*`). The **service** variable lists `service_name` values Prometheus received. Use profile **apps** or **full** so `otel-synthetic-traffic` hits the APIs; metrics export about every **60s** after traffic. |
| **Uptime** | Needs **blackbox** probes — configured in `otel/prometheus.yml` (internal `/health` on auth + platform). |
| **Workloads** | **Kubernetes only** (`kube_pod_info`, cAdvisor). Empty locally — use preprod Grafana for pod CPU/memory. |
