# Plan CI/CD — Deepidoo-s-new-age

Plan de mise en œuvre du pipeline discuté pour cette organisation.
La version anglaise est [CICD-PLAN.md](CICD-PLAN.md).

Date d’inventaire : 9 octobre 2026. Revérifier le contenu d’un dépôt avant une phase qui le touche s’il n’est pas ouvert dans ce workspace.

## 1. Objet

Un seul pipeline pour chaque dépôt de `Deepidoo-s-new-age` :

- une pull request exécute les mêmes contrôles partout ;
- `main` publie une image immuable ;
- la préproduction et la production exécutent ce même digest ;
- un environnement de courte durée peut être créé pour une pull request et supprimé à sa fermeture ;
- la promotion en production est un changement relu dans `helm-charts`.

Les dépôts de services testent et publient. Ils ne déploient pas.

## 2. Décisions figées

1. **Registre.** Une image construite depuis un dépôt de cette organisation est `ghcr.io/deepidoo-s-new-age/<service>:<git-sha>`. Le workflow utilise le `GITHUB_TOKEN` de ce dépôt. Un dépôt qui arrivera plus tard depuis `Deepidoo` suit la même règle après le transfert.
2. **Workflows.** Les workflows partagés vivent dans `Deepidoo-s-new-age/ci-workflows`, un dépôt qui ne contient que ces workflows. GitHub exige les fichiers sous `.github/workflows/` à l’intérieur de ce dépôt. Un appelant utilise `Deepidoo-s-new-age/ci-workflows/.github/workflows/<fichier>.yml@<tag>`. Ils visent la disposition de cette organisation (`backend/`, `frontend/` ou `frontend-web/`, `deepidoo-contracts`, FastAPI, Vue, uv). Les appelants sont des dépôts de `Deepidoo-s-new-age`. Les workflows refusent tout autre `github.repository_owner`. `Deepidoo-s-new-age/.github` garde le profil de l’organisation, les règles et ce plan.
3. **Environnements.** `deepidoo-s-new-age/helm-charts` est la seule source pour la préproduction, la production et les environnements de courte durée. Ce dépôt n’existe pas encore. Les dépôts de services ne stockent pas de kubeconfig et n’exécutent pas `kubectl`.
4. **Le même appelant pour chaque service.** `auth-service` n’est pas un pilote de déploiement à part. Il reçoit le même appelant mince que `platform-api` et les futurs modules.
5. **Un digest avance.** La préproduction et la production exécutent le digest qui a été testé. La promotion ne reconstruit pas l’image.
6. **Les gates de merge sont déterministes.** Ruff, les types, les tests, les audits et le validateur d’architecture décident si une pull request est verte. Un agent de revue commente. Un humain merge. Un humain approuve la production.

`Deepidoo-s-new-age/ci-workflows` est le dépôt que ces appelants lisent. Chaque workflow réutilisable écrit en phase 0 doit refuser tout autre `github.repository_owner`. Si ce dépôt est privé, GitHub refuse aussi un appelant qui ne peut pas le lire. Le laisser lisible par chaque dépôt de `Deepidoo-s-new-age`. Ces fichiers ne doivent pas contenir de secrets.

## 3. État actuel

Les workflows partagés sont sur `main` dans `Deepidoo-s-new-age/ci-workflows`, `ci.yml` est vert, et le tag est `ci-v1.0.0`. Les dépôts de services ne les appellent pas encore.

### Sur GitHub au 8 octobre 2026

| Dépôt | Pipeline |
|---|---|
| `auth-service` | `.github/workflows/docker.yml` tague `ghcr.io/deepidoo/auth-service` et `ghcr.io/deepidoo/auth-service:<sha>`. Les push échouent avec `denied: permission_denied: read_package` parce que le dépôt est dans `Deepidoo-s-new-age` et le nom d’image est dans l’autre organisation |
| `platform-api` | `.github/workflows/docker.yml` tague `ghcr.io/deepidoo/platform-api`. Même refus inter-organisations |
| `deepidoo-contracts` | Pas de workflow. Version `0.1.0`. Consommé comme chemin ou checkout git, pas comme package publié |
| `menuboards`, `deep_desk`, `scheduler`, `tickets`, `roadmap`, `epaper` | Pas de `.github/workflows` |
| `messaging`, `call_me_maybe`, `converter` | Dépôts vides |
| `Deepidoo/deesplay` | Workspace Yarn. Package `@deepidoo/deesplay` dans `packages/deesplay`. Champ version `1.0.0`. Pas de tags git, pas de releases GitHub, absent de npm |
| `Deepidoo/helm_charts` | Helmfile de l’organisation legacy. Hors de ce plan tant que ces workloads n’ont pas bougé |

Le frontend d’`auth-service` est une UI d’administration ACL (rôles, matrice de permissions, bindings). On le lance en local avec `npm run dev`. Aucune image ne le contient. Il dépend de `file:../../deesplay/packages/deesplay`, et Vite alias `@deepidoo/deesplay` vers ce répertoire. L’image API ne contient pas cette UI.

Le package `playdoo` de Play épingle déjà deesplay par commit git et workspace Yarn (`Deepidoo/deesplay#commit=…&workspace=@deepidoo/deesplay`). Cette syntaxe est réservée à Yarn. `auth-service` utilise npm.

Rien dans la CI ne lance le lint, les tests, le scan de secrets, la couverture, le diff OpenAPI, la validation du contrat de module, la signature d’image, un SBOM, Renovate, Helm, les namespaces de preview ou la télémétrie. SonarQube n’est pas un gate de merge.

## 4. Cible

```text
pull request
  → CI partagée (lint, types, tests, audit, scan de secrets, contrôle de contrat)
  → merge sur main
  → image ghcr.io/deepidoo-s-new-age/<service>:<git-sha>
  → pull request dans helm-charts qui pose ce digest en préproduction
  → helmfile apply (environnement preproduction)
  → pull request qui copie le même digest en production
  → approbation humaine, puis helmfile apply
```

Un namespace de preview installe seulement le service qui a changé et le pointe vers les `auth-service` et `platform-api` de préproduction. Une pull request qui modifie ces deux dépôts, ou `deepidoo-contracts`, est le cas qui déploie plus d’une release.

## 5. Outils

Utiliser ceux-ci. Ne pas ajouter un second programme qui fait le même travail. Une fiche par programme tiers est dans [tools/README.fr.md](tools/README.fr.md). Le validateur d’architecture et l’automatisation de revue Cursor sont les nôtres ; ce plan les décrit.

| Rôle | Outil | Où il tourne |
|---|---|---|
| Syntaxe des workflows | actionlint | `ci.yml` de `ci-workflows`, créé en phase 0 |
| Format et lint Python | ruff | `python-service.yml`, `python-package.yml`, phase 0 |
| Tests Python | pytest, uv | idem, phase 0 |
| Dépendances Python | lockfile uv, pip-audit | idem, phase 0 |
| Types Python | mypy | à ajouter quand un dépôt a une config propre. Input optionnel, éteint par défaut |
| Frontières d’import Python | import-linter | `python-service.yml`, après un fichier de baseline |
| Secrets dans l’arbre | gitleaks 8.30.1 | chaque workflow partagé, phase 0 |
| Installation et audit Vue | npm, Yarn ou pnpm selon le lockfile | `vue-app.yml`, phase 0 |
| Types Vue | vue-tsc | `vue-app.yml` quand le binaire est installé, phase 0 |
| Frontières d’import Vue | dependency-cruiser | `vue-app.yml` quand un fichier de config existe, phase 0 |
| Tests frontend | le script `test`, Vitest quand le dépôt l’ajoute | `vue-app.yml` |
| Scan de code OWASP | Semgrep Community Edition : `semgrep scan --config p/owasp-top-ten --config p/python --config p/javascript` | `security.yml`, phase 5. Moteur en LGPL 2.1. Les règles du registre sont gratuites pour un usage interne |
| Dépendances vulnérables | pip-audit, `npm audit --audit-level=high`, Renovate | CI et une PR hebdomadaire |
| Dérive du contrat de module | `tools/validate_architecture.py` comme décrit dans [CI-CONTRACT-VALIDATION.md](../docs/CI-CONTRACT-VALIDATION.md) | job de pull request, d’abord en avertissement puis bloquant |
| Dérive de forme d’API | oasdiff | le même job, contre l’OpenAPI de la branche de base |
| Publication de packages | GitHub Packages (Python et npm) | workflows de release sur un tag |
| Images | GHCR, tag = git sha, digest enregistré dans Helm | `image.yml` |
| Contenu d’image | SBOM syft, signature cosign, Trivy sur l’image construite | `image.yml`, phase 9. pip-audit ne voit pas les paquets Debian de l’image |
| Description du déploiement | Helmfile dans `helm-charts` | le seul écrivain du cluster |
| Apply et dérive | Helmfile depuis un GitHub Environment, puis Argo CD une fois que deux services se déploient ainsi | `helm-charts` |
| Politique cluster | Kyverno | cluster de production, après que les digests sont les seuls tags |
| Secrets à l’exécution | SOPS ou External Secrets, exemples inertes dans git | `helm-charts` |
| Traces, logs, métriques | OpenTelemetry vers Prometheus ou Mimir, Loki, Tempo, Grafana | cluster plus chaque app FastAPI |
| Disponibilité | Gatus, sondé depuis l’extérieur du cluster | le même Grafana |
| SLO | Sloth ou Pyrra | trois parcours utilisateur |
| Tableau de qualité | SonarQube Community Build | `main` seulement, optionnel, pas un gate de merge |
| Montées de version | Renovate, Release Please (ou un équivalent qui ouvre une PR de release) | toute l’organisation |
| Commentaires de revue | l’automation PR Cursor et Bugbot déjà en place | déjà décrits dans [PR-AUTOMATION.md](../docs/PR-AUTOMATION.md) |

SonarQube Community Build est gratuit en auto-hébergement. Il analyse la branche principale. L’analyse de pull request et la décoration de pull request exigent une édition payante. Community Build traite une analyse à la fois. Ses règles de sécurité sont moins profondes que celles de Semgrep : il reste un tableau de qualité et n’est pas le scanner OWASP.

La liste en vigueur est l’[OWASP Top 10:2025](https://owasp.org/Top10/2025/). Semgrep Community Edition est le scanner de code de ce pipeline : un job, pas de serveur, et il tourne sur des dépôts privés. CodeQL n’est gratuit que pour les dépôts publics. `auth-service` et `platform-api` sont privés, donc CodeQL y relève de GitHub Code Security, qui est payant. Community Edition analyse une fonction à la fois. Le suivi de taint entre fichiers est le moteur Pro, payant : un bug qui traverse plusieurs helpers peut passer.

| Risque 2025 | Contrôle |
|---|---|
| A01 Contrôle d’accès cassé, SSRF compris | Tests autorisés et interdits, plus le validateur de contrat de module. Semgrep attrape le path traversal, les redirections ouvertes et le SSRF évident |
| A02 Mauvaise configuration | kubeconform, puis Kyverno (pas de tags flottants, non-root, limites de ressources) |
| A03 Défaillances de la chaîne d’approvisionnement | pip-audit, npm audit, Renovate, et Trivy sur l’image construite |
| A04 Défaillances cryptographiques | Semgrep, plus gitleaks. Pas de secrets JWT dans les logs |
| A05 Injection | Semgrep. Le SQL reste dans les repositories, via SQLAlchemy |
| A06 Conception peu sûre | Validateur d’architecture. Pas de SQL inter-services |
| A07 Défaillances d’authentification | Tests d’auth-service et le contrôle de scopes du validateur de contrat |
| A08 Défaillances d’intégrité logicielle ou des données | cosign, digest épinglé dans Helm |
| A09 Défaillances de journalisation et d’alerte | Alertes OpenTelemetry, plus une règle Semgrep contre le log de `Authorization`, de JWT ou de mots de passe |
| A10 Mauvaise gestion des conditions exceptionnelles | Semgrep pour le fail-open et les gestionnaires d’erreur vides. Le reste est la revue et les tests |

## 6. Phases

Chaque phase a une ligne d’arrivée. On commence la phase suivante quand cette ligne est vraie. On n’implémente pas la phase 8 dans le même changement que la phase 1.

### Phase 0 — Écrire les workflows partagés et les mettre sur `main`

Créer le dépôt `Deepidoo-s-new-age/ci-workflows` et y ajouter ces fichiers, plus un `README.md` qui explique comment les appeler. Le dépôt contient les workflows partagés, les appelants d’exemple ci-dessous, et ce README. Les chemins sont relatifs à ce dépôt. GitHub charge les fichiers de workflow depuis `.github/workflows/` à l’intérieur d’un dépôt, donc les workflows réutilisables utilisent ce répertoire. Ce sont des workflows réutilisables (`workflow_call`). Chacun commence par échouer quand `github.repository_owner` n’est pas `deepidoo-s-new-age`.

| Fichier | Comportement |
|---|---|
| `.github/workflows/python-service.yml` | Pour un service FastAPI. `working_directory` par défaut : `backend`. Scan de secrets avec gitleaks 8.30.1 (`--no-git`). Cloner `Deepidoo-s-new-age/deepidoo-contracts` au chemin enregistré dans `uv.lock` (aujourd’hui `../../contracts` depuis `backend/`), avec `secrets.contracts_read_token` ou le `GITHUB_TOKEN` de l’appelant. `astral-sh/setup-uv@v10.2.0` avec uv `0.12.23` et Python 3.12. `uv sync --frozen --all-groups`, `ruff check`, `ruff format --check`, `pytest`. Exporter un fichier de requirements, retirer les lignes de chemin, lancer `pip-audit`. Pytest reçoit un env inerte : `JWT_SECRET=ci-test-secret`, `JWT_ISSUER=deepidoo-auth`, `AUTH_DATABASE_URL`, `WEBAPP_DATABASE_URL`, `REDIS_URL` sur localhost. Des inputs permettent de surcharger ces valeurs et de couper le checkout de contracts |
| `.github/workflows/python-package.yml` | Les mêmes contrôles pour un package uv à la racine du dépôt. Pas de checkout de contracts. Utilisé par `deepidoo-contracts` |
| `.github/workflows/vue-app.yml` | `working_directory` par défaut : `frontend-web`. Détecter npm, Yarn ou pnpm depuis le lockfile et installer en figé. Lancer `lint`, `typecheck` et `test` seulement quand `package.json` les définit. S’il n’y a pas de script `typecheck` et que `vue-tsc` est installé, lancer `vue-tsc --noEmit`. Lancer `dependency-cruiser` seulement quand un fichier de config existe. `npm audit --audit-level=high` (ou l’équivalent Yarn/pnpm). `run_build` vaut false par défaut |
| `.github/workflows/js-package.yml` | Publier un package npm sur GitHub Packages à un tag `vX.Y.Z`. Le nom dans `package.json` est `@deepidoo-s-new-age/<nom>` et la version correspond au tag. `working_directory` par défaut : `.` ; deesplay utilise `packages/deesplay`. `install_directory` est le répertoire du lockfile, la racine du dépôt pour un workspace. Yarn Berry, Yarn classic, npm ou pnpm. `packages: write`. Sorties `name` et `version` |
| `.github/workflows/image.yml` | Construire `ghcr.io/deepidoo-s-new-age/<image_name>:<git-sha>`. Refuser toute autre forme de nom d’image. Ne pas taguer `:latest`. Ne pas déployer. Contexte par défaut `backend/Dockerfile`, plateforme `linux/amd64`. Checkout de `deepidoo-contracts` dans `contracts/` et le passer comme contexte BuildKit nommé `contracts`, parce que les Dockerfiles actuels réécrivent la dépendance de chemin ainsi. L’input `push` vaut true par défaut. Sorties `image` et `digest`. `packages: write` sur ce workflow |
| `.github/workflows/ci.yml` | Tourne sur `ci-workflows` : gitleaks, puis actionlint 1.7.12 |
| `examples/python-service.yml` | Appelant de départ : test, puis image sur `main`, nom d’image laissé à `your-service` |
| `examples/python-package.yml` | Appelant de départ pour un package uv |
| `examples/vue-app.yml` | Appelant de départ avec `working_directory: frontend-web` |
| `examples/js-package.yml` | Appelant de release pour deesplay : tag `vX.Y.Z`, `working_directory: packages/deesplay` |

GitHub ne liste les templates de workflow d’organisation que depuis `Deepidoo-s-new-age/.github`. Ce plan garde les appelants de départ dans `ci-workflows/examples/`. Un nouveau service copie l’exemple qui lui correspond dans son propre répertoire `.github/workflows/`.

Épingler les Actions tierces à un tag majeur ou exact connu dans cette première version (`actions/checkout@v4`, `docker/build-push-action@v6`, `docker/login-action@v3`, `docker/setup-buildx-action@v3`, `actions/setup-node@v4`). Les SHA de commit arrivent en phase 9.

Les lockfiles de services disent encore `editable = "../../contracts"`. Le clone de contracts doit atterrir à ce chemin. `actions/checkout` ne peut pas écrire hors de `GITHUB_WORKSPACE`, donc le workflow de test résout le chemin et clone avec git. Le workflow d’image clone dans `./contracts` pour le contexte BuildKit. Retirer le token du remote git après le fetch.

Étapes :

1. Ajouter les fichiers ci-dessus dans une pull request sur `ci-workflows`. Ce plan reste dans `.github`.
2. Confirmer que `ci.yml` est vert (gitleaks, actionlint).
3. Merger.
4. Tagger ce commit `ci-v1.0.0`.
5. Pointer les appelants de départ vers `@ci-v1.0.0`, pas `@main`. Les dépôts de services épinglent ce tag. Ne déplacer le tag que lorsque le workflow partagé change exprès.

Réglages d’organisation avant le premier push d’image (phase 6, pas cette phase) :

- Visibilité par défaut des nouveaux packages : privée.
- Actions peut lire les autres dépôts de `Deepidoo-s-new-age`, ou chaque service garde `SCHEMAS_READ_TOKEN` et le passe comme `contracts_read_token`.
- `auth-service` utilise déjà le nom de secret `SCHEMAS_READ_TOKEN`.

Ligne d’arrivée : ces workflows sont sur `main`, `ci.yml` est vert, et `ci-v1.0.0` existe. Aucun dépôt de service ne les appelle encore.

### Phase 1 — Prouver l’appelant sur `auth-service` sans publier

Ajouter `auth-service/.github/workflows/ci.yml`. Il remplace `docker.yml`. Il ne publie pas d’image. Un `push: true` ici publierait `ghcr.io/deepidoo-s-new-age/auth-service:<sha>` dès que `main` bouge, et rien ne déploierait ce digest.

Ne pas ajouter de job `web` pour l’instant. `npm ci` a besoin de `deesplay` sur le disque, et `frontend/vite.config.ts` alias `@deepidoo/deesplay` vers `../../deesplay/packages/deesplay`. Ce job revient en phase 4. Le laisser de côté permet à la protection de branche d’exiger `test` seul.

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]
permissions:
  contents: read
jobs:
  test:
    uses: Deepidoo-s-new-age/ci-workflows/.github/workflows/python-service.yml@ci-v1.0.0
    secrets:
      contracts_read_token: ${{ secrets.SCHEMAS_READ_TOKEN }}
  image:
    needs: test
    uses: Deepidoo-s-new-age/ci-workflows/.github/workflows/image.yml@ci-v1.0.0
    with:
      image_name: auth-service
      push: false
    secrets:
      contracts_read_token: ${{ secrets.SCHEMAS_READ_TOKEN }}
```

Étapes :

1. Ajouter cet appelant et supprimer `.github/workflows/docker.yml` dans la même pull request. Cela retire le push vers `ghcr.io/deepidoo/auth-service`.
2. Ouvrir une pull request qui touche un fichier backend et confirmer que ruff, pytest et pip-audit tournent.
3. Confirmer que le job image construit et ne pousse pas.

Ligne d’arrivée : une pull request `auth-service` est rouge quand les tests échouent, et aucune image n’est publiée. Ajouter `packages: write` et `push: true` seulement en phase 6, et seulement sur les push vers `main`.

`platform-api` est le deuxième appelant, même forme, nom d’image `platform-api`, `push: false`. Supprimer son `docker.yml` dans ce changement. Le faire après qu’`auth-service` est vert, pas dans la même pull request.

### Phase 2 — Appelants pour les autres dépôts qui contiennent du code

Pour chaque dépôt qui a un `backend/pyproject.toml` et un `uv.lock` :

```yaml
jobs:
  test:
    uses: Deepidoo-s-new-age/ci-workflows/.github/workflows/python-service.yml@ci-v1.0.0
    secrets:
      contracts_read_token: ${{ secrets.SCHEMAS_READ_TOKEN }}
```

Ajouter le job image avec `push: false` seulement quand le dépôt a un Dockerfile compatible avec `image.yml` (contexte `backend/`, contexte BuildKit `contracts`).

Pour `deepidoo-contracts`, utiliser `python-package.yml` avec `working_directory: .`. Pas d’image.

Les dépôts vides (`messaging`, `call_me_maybe`, `converter`) reçoivent un appelant quand ils reçoivent du code, copié depuis `examples/` dans `ci-workflows`, pas avant.

Protection de branche sur chaque dépôt qui a un appelant vert :

- check requis : le job CI ;
- pas de push direct sur `main` ;
- `CODEOWNERS` sur `deepidoo-contracts` et sur `auth-service` pour tout le dépôt, puis plus tard sur les valeurs de production de `helm-charts`.

Cliquet de couverture, dans la même phase une fois pytest stable :

- publier `coverage.xml` ;
- stocker le pourcentage actuel dans le dépôt ;
- échouer quand le nombre baisse ;
- ne pas choisir un 80 pour cent global.

Ligne d’arrivée : chaque dépôt New Age non vide lance la CI partagée sur les pull requests. Les images ne sont toujours pas déployées.

### Phase 3 — Publier `deepidoo-contracts`

Aujourd’hui chaque build d’image et chaque test de service clone le dépôt contracts, et `uv.lock` enregistre `../../contracts`.

Étapes :

1. Ajouter `release.yml` dans `deepidoo-contracts`, déclenché sur les tags `vX.Y.Z`. Il réutilise `python-package.yml` pour les contrôles, puis publie le package sur GitHub Packages.
2. Le nom du package reste `deepidoo-contracts`. Le dépôt GitHub Packages est l’organisation qui possède le repo.
3. Un changement cassant est une version majeure, comme [ARCHITECTURE.md](../docs/ARCHITECTURE.md) l’exige déjà.
4. Dans un service (`auth-service` d’abord), remplacer la source par chemin par la version publiée, régénérer `uv.lock`, et mettre `checkout_contracts: false` sur le workflow de test et sur le workflow d’image.
5. Mettre à jour le Dockerfile de ce service pour qu’il installe le package depuis le lockfile. Supprimer le contexte BuildKit `contracts` et le `sed` qui réécrit `../../contracts`.
6. Répéter pour `platform-api` et les autres services.
7. Ajouter Renovate pour qu’une nouvelle version de contracts ouvre une pull request par consommateur.

Ligne d’arrivée : un changement de contracts n’atteint un service que par une montée de version mergée, et le build d’image ne clone pas `deepidoo-contracts`.

### Phase 4 — Deesplay comme package versionné

Déplacer le dépôt dans `Deepidoo-s-new-age` ne suffit pas à rendre les installations correctes.

GitHub Packages exige que le scope npm corresponde à l’organisation propriétaire. Publié depuis cette organisation, le nom du package est `@deepidoo-s-new-age/deesplay`. Les imports dans `auth-service` sont `@deepidoo/deesplay/...`. Ces imports, `package.json` et le lockfile changent avec le nouveau nom. Garder le nom `@deepidoo/deesplay` suppose de publier vers un registre qui autorise ce scope.

Le package livre des sources TypeScript et Vue (les `exports` pointent vers des `.ts` et des `.vue`). Vite peut les compiler depuis `node_modules`. Une étape de build séparée n’est pas nécessaire pour la première publication.

`frontend/vite.config.ts` alias `@deepidoo/deesplay` vers `../../deesplay/packages/deesplay`. Retirer cet alias et l’entrée `server.fs.allow` de ce chemin, sinon Vite continue de lire le checkout voisin.

Les peers de deesplay sont en avance sur l’UI d’admin : Vue Router 5, vue-i18n 11, Pinia 3, Vuetify 3.11, contre Vue Router 4, vue-i18n 10, Pinia 2, Vuetify 3.7 dans `auth-service`. Le lien `file:` n’applique pas les peers. Un `npm ci` du package publié peut échouer tant que l’UI d’admin ne rejoint pas ces peers, ou tant que le package publié ne déclare pas des peers que l’UI satisfait déjà.

Travail de workflow :

1. Ajouter `deesplay/.github/workflows/release.yml` depuis `examples/js-package.yml`. Il tourne sur les tags `vX.Y.Z` et appelle `js-package.yml` avec `working_directory: packages/deesplay`. `packages/deesplay/package.json` s’appelle `@deepidoo-s-new-age/deesplay` avant le premier tag.
2. `.npmrc` dans l’application consommatrice : `@deepidoo-s-new-age:registry=https://npm.pkg.github.com`.
3. Étendre `vue-app.yml` avec un secret `packages_read_token` et `NODE_AUTH_TOKEN` pour que `npm ci` puisse lire GitHub Packages.
4. Remettre le job `web` sur `auth-service` avec `working_directory: frontend`. Laisser `run_build` à false tant que `npm run build` (`vue-tsc -b && vite build`) n’est pas vert en local contre le package publié.
5. Dependabot ou Renovate monte la version de deesplay.

L’UI d’admin reste non déployée tant que personne n’ajoute une image frontend et une release Helm. La phase 4 permet à la CI de l’installer et de la typechecker. Elle ne la met pas sur le cluster.

Ligne d’arrivée : `npm ci` en CI installe `@deepidoo-s-new-age/deesplay` à un tag, sans checkout voisin, et le job `web` est vert.

### Phase 5 — Gates d’architecture et de sécurité

Implémenter [CI-CONTRACT-VALIDATION.md](../docs/CI-CONTRACT-VALIDATION.md). Le script vit dans `.github` sous `tools/validate_architecture.py`.

Déroulement, dans l’ordre que ce document donne déjà :

1. Rapport local plus une baseline commitée des écarts connus.
2. Job de pull request en mode avertissement.
3. Une dérive nouvelle fait échouer le check. Les entrées de baseline restent autorisées jusqu’à ce qu’on les retire exprès.
4. `oasdiff` contre l’artefact OpenAPI de la branche de base.

Ajouter `security.yml` dans `ci-workflows`, à côté des autres workflows réutilisables. Lancer Semgrep Community Edition, pas bandit, pas CodeQL, et pas SonarQube :

```bash
semgrep scan --error --config p/owasp-top-ten --config p/python --config p/javascript
```

Épingler la version du CLI dans le workflow. Si le premier run est bruyant, échouer seulement sur les trouvailles absentes d’une baseline commitée. Le job couvre A04, A05, une partie de A01 et une partie de A10. Il ne remplace pas les tests de contrôle d’accès ni les contrôles de chaîne d’approvisionnement du tableau ci-dessus.

Ajouter des contrats import-linter :

- un service n’importe pas le code applicatif d’un autre service ;
- les handlers de routes ne possèdent pas le SQL.

Ajouter dependency-cruiser pour les frontends une fois la phase 4 verte : l’UI d’un module n’importe pas un autre service.

La nuit, pas sur chaque pull request : un smoke de préproduction. Login, appel d’un module, le module appelle `platform-api`.

Ligne d’arrivée : une route nouvelle absente de `docs/module.yaml` fait échouer la CI. Les anciens écarts restent listés dans la baseline.

### Phase 6 — `helm-charts` et promotion

Créer `deepidoo-s-new-age/helm-charts`. C’est le dépôt de déploiement. Il porte les charts, les valeurs d’environnement, et les seuls workflows qui parlent au cluster.

Disposition :

```text
helm-charts/
  charts/app/          # un chart pour un service long
  charts/job/          # migrations
  environments/preproduction/<service>.values.yaml
  environments/production/<service>.values.yaml
  environments/preproduction/helmfile.yaml
  environments/production/helmfile.yaml
```

Les valeurs épinglent un digest :

```yaml
image:
  repository: ghcr.io/deepidoo-s-new-age/auth-service
  digest: sha256:…
```

Étapes :

1. `imagePullSecret` du cluster capable de lire les packages de `Deepidoo-s-new-age`.
2. Première release : API `auth-service` seulement. Passer `push: true` sur les push vers `main`, avec `packages: write`, restreint par `if: github.ref == 'refs/heads/main'`.
3. Un workflow ouvre une pull request dans `helm-charts` qui pose le nouveau digest dans `environments/preproduction/auth-service.values.yaml`. Le workflow lit la sortie `digest` de `image.yml`.
4. Merger cette pull request lance `helmfile -f environments/preproduction/helmfile.yaml --selector name=auth-service apply` depuis un GitHub Environment nommé `preproduction`.
5. Alembic tourne comme hook Helm ou Job dans la même release, avec le même digest, avant que les nouveaux pods prennent le trafic. La migration doit tolérer la version précédente encore en cours d’exécution.
6. La production est une seconde pull request qui copie le même digest dans `environments/production/`. Le GitHub Environment `production` exige un relecteur.
7. Le rollback est `helm rollback <release>` ou une pull request qui restaure le digest précédent.
8. Répéter pour `platform-api`.
9. Après que deux services se déploient ainsi, installer Argo CD pour surveiller `helm-charts` et appliquer. Le GitHub Environment cesse alors de détenir un kubeconfig de longue durée. Jusqu’à Argo, le secret kubeconfig vit seulement sur `helm-charts`.

Ligne d’arrivée : la préproduction et la production exécutent un digest qui figure dans un fichier de valeurs mergé, et les deux exécutent le même digest après promotion. Aucun dépôt de service ne contient `kubectl`.

### Phase 7 — Environnements de preview

Une preview est un namespace `pr-<repo>-<number>` dans le même cluster.

- Déclencheur : label `preview` sur la pull request, ou un `workflow_dispatch`.
- Installer le service qui a changé, plus son frontend quand ce frontend a une image.
- Pointer le service vers les `auth-service` et `platform-api` de préproduction.
- Déployer une copie d’auth ou de platform seulement quand la pull request modifie ces dépôts ou `deepidoo-contracts`.
- Hôte d’ingress `pr-<repo>-<number>.preview.<domain>`. Remplacer `_` dans le nom du dépôt par `-`, parce qu’un label DNS ne peut pas contenir `_`. La pull request 12 de `deep_desk` est `pr-deep-desk-12.preview.<domain>`.
- Quota de ressources sur le namespace.
- Utilisateur de fixture, pas un dump de production.
- À la fermeture de la pull request, `helmfile destroy` de cette release.
- Un job quotidien supprime les namespaces de plus de 96 heures.

Enregistrements DNS, tous dirigés vers l’ingress du cluster. Ouvrir une pull request ne crée pas d’enregistrement.

| Nom | Usage |
|---|---|
| `<service>.<domain>` | Production. Un enregistrement par service déployé |
| `<service>.preproduction.<domain>` | Préproduction. Un enregistrement par service déployé |
| `*.preview.<domain>` | Toutes les previews. Un wildcard couvre `pr-menuboards-12.preview.<domain>` et `pr-deep-desk-12.preview.<domain>` |

Les certificats TLS portent les mêmes noms. Un certificat, ou une liste SAN, couvre les noms de production. Un second couvre les noms de préproduction. Un certificat wildcard couvre `*.preview.<domain>`. cert-manager peut émettre ce wildcard avec un défi DNS-01.

Ligne d’arrivée : une pull request labelisée donne une URL, et la fermer retire le namespace.

### Phase 8 — Télémétrie et disponibilité

Le faire après la phase 6. Un tableau de bord est plus fiable quand chaque pod a un digest.

1. OpenTelemetry dans `auth-service`, `platform-api`, puis les modules. Exporter traces, métriques et logs vers un collecteur.
2. Grafana lit Prometheus ou Mimir, Loki et Tempo.
3. Un JSON de dashboard dans `helm-charts`, réutilisé par service : débit, taux d’erreur, latence.
4. Propager l’en-tête de trace sur les appels d’un module vers platform et auth.
5. Trois parcours, alerte sur le burn rate : login, lecture d’un contenu, une action de module. Sloth ou Pyrra génère les règles.
6. Gatus sonde ces parcours depuis l’extérieur du cluster. Une sonde dans le cluster reste verte alors que les utilisateurs n’atteignent pas l’ingress.

Ligne d’arrivée : une requête de préproduction montre une trace à travers les services qu’elle a touchés, et une sonde extérieure passe au rouge quand l’ingress est down.

### Phase 9 — Chaîne d’approvisionnement

Une fois les images et la promotion stables :

- Renovate sur l’organisation, en groupant les montées mineures dans une pull request par dépôt et par semaine.
- `syft` écrit un SBOM à côté de l’image. `cosign` signe le digest dans `image.yml`. Trivy scanne cette image pour les paquets OS que pip-audit ne voit pas.
- Kyverno en production refuse les tags qui ne sont pas un digest, puis refuse les images non signées.
- Épingler les Actions tierces à un SHA de commit dans les workflows partagés (un seul endroit).
- Les secrets d’exécution restent dans SOPS ou External Secrets. Les exemples dans git restent inertes.
- Rétention GHCR : garder les tags sha référencés par Helm, supprimer les builds non tagués sur un calendrier.

Ligne d’arrivée : Kyverno en production n’admet qu’un digest signé nommé par Helmfile.

### Phase 10 — SonarQube, optionnel

Mettre en place SonarQube Community Build seulement si l’équipe veut une UI de qualité unique. Pointer le scanner sur `main` après les tests, et importer le rapport de couverture de la phase 2. Le gate de merge reste les checks GitHub des phases 1, 2 et 5.

Ligne d’arrivée : `main` a un projet Sonar par dépôt. Un gate Sonar rouge ne remplace pas un check CI rouge.

### Phase 11 — Boucle d’agents

L’automation de PR commente déjà les règles, `docs/module.yaml` et la revue, puis poste sur Talkspirit. La garder comme commentateur.

La boucle de développement :

1. La spec est dans le corps de la pull request (le récap `new-module`, ou une spec de changement courte).
2. Un agent d’implémentation ouvre la pull request.
3. La boucle s’arrête quand les checks requis sont verts, ou après trois pushes.
4. Un humain merge.
5. La production reste le relecteur du GitHub Environment de la phase 6.

Les agents ne reçoivent pas l’accès à l’environnement `production` et ne poussent pas sur `main`.

Ligne d’arrivée : un agent peut atteindre une pull request verte et ne peut pas déployer la production.

## 7. Ordre

| Ordre | Phase | Pourquoi elle est ici |
|---|---|---|
| 1 | 0 Workflows partagés sur `main`, tag `ci-v1.0.0` | Les appelants n’ont rien à `uses:` avant cela |
| 2 | 1 Appelant `auth-service`, `push: false`, pas de job `web` | Prouve la CI sans publier et sans deesplay |
| 3 | 2 Autres dépôts, protection de branche, cliquet de couverture | Une seule définition de vert |
| 4 | 3 Publier contracts | Retire le clone de chaque build |
| 5 | 4 Publier deesplay, restaurer le job `web` | La CI frontend devient possible |
| 6 | 5 Validateur de contrat, Semgrep, règles d’import | Des gates qui collent à cette architecture |
| 7 | 6 `helm-charts`, promotion de digest, puis `push: true` | Première fois qu’une image est déployée |
| 8 | 7 Previews | A besoin du chemin Helm |
| 9 | 8 Télémétrie | A besoin des digests pour qu’un pic ait une version |
| 10 | 9 Signature, Kyverno, pins SHA Renovate | A besoin d’un registre que l’on tire vraiment |
| 11 | 10 SonarQube | Tableau de bord optionnel |
| 12 | 11 Boucle d’agents | La condition de sortie est les gates ci-dessus |

## 8. Secrets

| Secret | Où | Rôle |
|---|---|---|
| `SCHEMAS_READ_TOKEN` | chaque dépôt de service, jusqu’à ce qu’Actions de l’org puisse lire `deepidoo-contracts` | cloner contracts |
| `GITHUB_TOKEN` | implicite | pousser l’image vers le GHCR de cette org, après `packages: write` |
| kubeconfig | environnements `preproduction` et `production` de `helm-charts` seulement | Helmfile apply, jusqu’à ce qu’Argo CD le remplace |
| `NODE_AUTH_TOKEN` | dépôts qui font un npm install de GitHub Packages | deesplay, phase 4 |
| Token de lecture de packages pour le cluster | `imagePullSecret` Kubernetes | tirer `ghcr.io/deepidoo-s-new-age/*` |

`TALKSPIRIT_WEBHOOK_URL` reste un secret Cursor. GitHub Actions ne poste pas ce récap.

## 9. Hors périmètre tant qu’un dépôt n’a pas bougé

Les dépôts de l’organisation `Deepidoo`, y compris `play_music_ai`, `play`, `deesplay` (jusqu’à ce que la phase 4 le déplace) et `helm_charts`, gardent leurs pipelines actuels. Quand un dépôt entre dans `Deepidoo-s-new-age`, il supprime son propre workflow de déploiement, ajoute l’appelant mince, et publie vers `ghcr.io/deepidoo-s-new-age/<service>:<git-sha>`. Le digest est ensuite ajouté à `deepidoo-s-new-age/helm-charts`.

Ne pas pointer un workflow New Age vers `Deepidoo/helm_charts`. Ne pas publier une image New Age vers `ghcr.io/deepidoo`.

## 10. Définition de fini pour le programme

- Chaque dépôt non vide de `Deepidoo-s-new-age` appelle les workflows partagés à un tag `ci-v*` épinglé.
- `main` ne peut pas être mis à jour quand ces checks sont rouges.
- Les images sont `ghcr.io/deepidoo-s-new-age/<service>:<git-sha>` et sont privées.
- `helm-charts` est le seul dépôt qui peut changer ce que le cluster exécute.
- La préproduction et la production documentent le digest. L’apply de production exige un relecteur.
- Les namespaces de preview expirent.
- Le login, une lecture de contenu et une action de module ont une trace, un SLO et une sonde extérieure.
- `deepidoo-contracts` et deesplay sont consommés comme des versions.
- Les agents s’arrêtent à une pull request verte.
