# Fiches outils

Une page par programme tiers que le pipeline exécute. La version anglaise de cet index est [README.md](README.md).

Quand deux programmes font le même travail, le plan en retient un. Les fiches le disent.

Les scripts que l’on écrit restent dans le plan : le validateur d’architecture (`tools/validate_architecture.py`) et l’automatisation de revue Cursor.

Chaque fiche a une section Installation : où l’outil est installé, et comment il est empaqueté.

| Outil | Phase | Rôle |
|---|---|---|
| [actionlint](actionlint/README.fr.md) | 0 | Syntaxe des workflows |
| [uv](uv/README.fr.md) | 0 | Installation Python et lockfile |
| [ruff](ruff/README.fr.md) | 0 | Format et lint Python |
| [pytest](pytest/README.fr.md) | 0 | Tests Python |
| [pip-audit](pip-audit/README.fr.md) | 0 | CVE des dépendances Python |
| [gitleaks](gitleaks/README.fr.md) | 0 | Secrets dans l’arbre |
| [npm](npm/README.fr.md) | 0 | Installation et audit JavaScript |
| [vue-tsc](vue-tsc/README.fr.md) | 0 | Vérification de types Vue |
| [vitest](vitest/README.fr.md) | 0, quand un frontend ajoute des tests | Tests unitaires frontend |
| [mypy](mypy/README.fr.md) | plus tard, optionnel | Types Python |
| [dependency-cruiser](dependency-cruiser/README.fr.md) | 5, après une config frontend | Frontières d’import frontend |
| [import-linter](import-linter/README.fr.md) | 5 | Frontières d’import Python |
| [Semgrep](semgrep/README.fr.md) | 5 | Scan de code OWASP |
| [oasdiff](oasdiff/README.fr.md) | 5 | Dérive de la forme d’API |
| [GitHub Packages](github-packages/README.fr.md) | 3 et 4 | Publication de contracts et deesplay |
| [GHCR](ghcr/README.fr.md) | 6 | Registre d’images |
| [Helm](helm/README.fr.md) | 6 | Manifestes Kubernetes |
| [Helmfile](helmfile/README.fr.md) | 6 | Valeurs d’environnement et apply |
| [Alembic](alembic/README.fr.md) | 6 | Migrations de base de données |
| [Argo CD](argo-cd/README.fr.md) | 6, après deux services | Apply GitOps |
| [kubeconform](kubeconform/README.fr.md) | 6 | Contrôle de schéma des manifestes |
| [Renovate](renovate/README.fr.md) | 3, puis toute l’organisation | Pull requests de montée de dépendances |
| [Release Please](release-please/README.fr.md) | avec la publication | Pull requests de version et de changelog |
| [SOPS](sops/README.fr.md) | 6 | Secrets chiffrés dans git |
| [External Secrets](external-secrets/README.fr.md) | 6, alternative à SOPS | Secrets injectés dans le cluster |
| [OpenTelemetry](opentelemetry/README.fr.md) | 8 | Traces, métriques, logs |
| [Prometheus](prometheus/README.fr.md) | 8 | Métriques |
| [Mimir](mimir/README.fr.md) | 8, si Prometheus ne suffit plus | Métriques sur la durée |
| [Loki](loki/README.fr.md) | 8 | Logs |
| [Tempo](tempo/README.fr.md) | 8 | Traces |
| [Grafana](grafana/README.fr.md) | 8 | Tableaux de bord |
| [Gatus](gatus/README.fr.md) | 8 | Disponibilité depuis l’extérieur du cluster |
| [Sloth](sloth/README.fr.md) | 8 | Règles de SLO |
| [Pyrra](pyrra/README.fr.md) | 8, alternative à Sloth | Règles de SLO et interface |
| [Trivy](trivy/README.fr.md) | 9 | Paquets OS dans l’image |
| [syft](syft/README.fr.md) | 9 | SBOM |
| [cosign](cosign/README.fr.md) | 9 | Signature d’image |
| [Kyverno](kyverno/README.fr.md) | 9 | Politique du cluster |
| [SonarQube](sonarqube/README.fr.md) | 10, optionnel | Tableau de qualité |
