# Tool cheatsheets

One page per third-party program the pipeline runs. The French pages are [README.fr.md](README.fr.md).

When two programs do the same job, the plan picks one. The sheets say which.

Scripts we write ourselves stay in the plan: the architecture validator (`tools/validate_architecture.py`) and the Cursor review automation.

Each sheet has an Installation section: where the tool is installed, and how it is packaged.

| Tool | Phase | Job |
|---|---|---|
| [actionlint](actionlint/README.md) | 0 | Workflow syntax |
| [uv](uv/README.md) | 0 | Python install and lockfile |
| [ruff](ruff/README.md) | 0 | Python format and lint |
| [pytest](pytest/README.md) | 0 | Python tests |
| [pip-audit](pip-audit/README.md) | 0 | Python dependency CVEs |
| [gitleaks](gitleaks/README.md) | 0 | Secrets in the tree |
| [npm](npm/README.md) | 0 | JavaScript install and audit |
| [vue-tsc](vue-tsc/README.md) | 0 | Vue typecheck |
| [vitest](vitest/README.md) | 0, when a frontend adds tests | Frontend unit tests |
| [mypy](mypy/README.md) | later, optional | Python types |
| [dependency-cruiser](dependency-cruiser/README.md) | 5, after a frontend config exists | Frontend import boundaries |
| [import-linter](import-linter/README.md) | 5 | Python import boundaries |
| [Semgrep](semgrep/README.md) | 5 | OWASP code scan |
| [oasdiff](oasdiff/README.md) | 5 | API shape drift |
| [GitHub Packages](github-packages/README.md) | 3 and 4 | Publish contracts and deesplay |
| [GHCR](ghcr/README.md) | 6 | Container registry |
| [Helm](helm/README.md) | 6 | Kubernetes manifests |
| [Helmfile](helmfile/README.md) | 6 | Environment values and apply |
| [Alembic](alembic/README.md) | 6 | Database migrations |
| [Argo CD](argo-cd/README.md) | 6, after two services | GitOps apply |
| [kubeconform](kubeconform/README.md) | 6 | Manifest schema check |
| [Renovate](renovate/README.md) | 3, then org-wide | Dependency bump PRs |
| [Release Please](release-please/README.md) | with publishing | Version and changelog PRs |
| [SOPS](sops/README.md) | 6 | Secrets encrypted in git |
| [External Secrets](external-secrets/README.md) | 6, alternative to SOPS | Secrets injected into the cluster |
| [OpenTelemetry](opentelemetry/README.md) | 8 | Traces, metrics, logs |
| [Prometheus](prometheus/README.md) | 8 | Metrics |
| [Mimir](mimir/README.md) | 8, if Prometheus is outgrown | Long-term metrics |
| [Loki](loki/README.md) | 8 | Logs |
| [Tempo](tempo/README.md) | 8 | Traces |
| [Grafana](grafana/README.md) | 8 | Dashboards |
| [Gatus](gatus/README.md) | 8 | Uptime from outside the cluster |
| [Sloth](sloth/README.md) | 8 | SLO rules |
| [Pyrra](pyrra/README.md) | 8, alternative to Sloth | SLO rules and UI |
| [Trivy](trivy/README.md) | 9 | OS packages in the image |
| [syft](syft/README.md) | 9 | SBOM |
| [cosign](cosign/README.md) | 9 | Image signature |
| [Kyverno](kyverno/README.md) | 9 | Cluster policy |
| [SonarQube](sonarqube/README.md) | 10, optional | Quality dashboard |
