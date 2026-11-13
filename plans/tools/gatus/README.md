# Gatus — out of scope (for now)

The French version is [README.fr.md](README.fr.md).

**Not in the New Age pipeline today.** Uptime is **in-cluster**: Prometheus blackbox exporter probes public Ingress URLs for `/health`; Grafana dashboard **Uptime** shows `probe_success`. Journey checks (login, platform read, module token) are manual or scripted curls plus Tempo traces — not probes deployed outside the cluster.

If we add external journey probing later, revisit this sheet and [CICD-PLAN.md](../../CICD-PLAN.md) phase 8.
