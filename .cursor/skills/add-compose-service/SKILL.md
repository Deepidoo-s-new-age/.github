---
name: add-compose-service
description: >-
  Add a New Age app to the shared local Docker Compose stack: service + profiles,
  Traefik host, DEV overlay, .env.example, hosts.example, repos.tsv, Makefile
  hints, and local/README. Use when integrating a new module/API/UI into
  .github/local, /add-compose-service, or when a colleague asks to run their
  new New Age app via make up.
disable-model-invocation: true
---

# Add Compose service (New Age local)

Intégrer un **nouveau service** (API et/ou front) dans le stack
`.github/local/docker-compose.yml` pour que l’équipe le lance avec
`make up PROFILES=…` / `DEV=…`.

Ce skill **n’écrit pas** le code métier du module. Pour le contrat
`docs/module.yaml` → **`/new-module`** d’abord. Pour booter un workspace
existant → **`/setup-local`**.

Références vivantes à copier / adapter :

- API GHCR + overlay : `auth-service` / `platform-api` + `overlays/dev-*.yml`
- Front Vite always-dev : `auth-admin`
- Templates : `.cursor/skills/add-compose-service/templates/`

## Règles dures

1. Travailler sous **`.github/`** ; chemins volumes relatifs à `local/`
   (`../../{repo}/…`).
2. **Profile** dédié court (`foo`) + inclusion dans `apps` et `full`.
3. **`DEV=`** = short name = fichier `overlays/dev-{short}.yml`
   (`DEV=foo` → `dev-foo.yml`), pas le nom du repo complet.
4. Container : `na-{short}-api` (API) ou `na-{short}-web` (UI).
5. Traefik : `Host(\`{hostname}.${NEW_AGE_DOMAIN:-new-age.me}\`)` +
   `loadbalancer.server.port` = port **interne** du container.
6. Pas de secrets réels dans `.env.example` (valeurs inertes seulement).
7. Ne pas monter `pyproject.toml` / `uv.lock` si un entrypoint les réécrit
   (pattern platform-api).
8. Valider la synthèse **avec l’utilisateur** avant d’écrire les fichiers
   (sauf s’il a déjà donné tous les paramètres explicitement).

## Workflow

```
- [ ] 0 — Prérequis / type de service
- [ ] 1 — Discovery (noms, ports, deps)
- [ ] 2 — Synthèse + validation utilisateur
- [ ] 3 — Édition fichiers
- [ ] 4 — Smoke compose config
- [ ] 5 — Récap commandes
```

---

## Phase 0 — Prérequis

Confirmer :

| Question | Notes |
|---|---|
| Repo sibling | Ex. `scheduler`, `play_music_ai` — path `NEW_AGE_ROOT/{dir}` |
| Type | `api` (FastAPI/Python) · `web` (Vite) · `api+web` |
| Contrat module | Si module métier sans `docs/module.yaml` → proposer `/new-module` |
| Images | GHCR org `ghcr.io/deepidoo-s-new-age/…` et/ou `Dockerfile.dev` local |

Si le dossier repo est absent : l’ajouter à `local/repos.tsv` et `make clone`
(ne pas `git pull` d’autres repos).

---

## Phase 1 — Discovery

Collecter (demander ce qui manque) :

| Champ | Exemple | Règle |
|---|---|---|
| `repo_dir` | `scheduler` | nom dossier = clé `repos.tsv` |
| `short` | `scheduler` | profile + `DEV=` + `dev-{short}.yml` |
| `compose_service` | `scheduler-api` | clé YAML `services:` |
| `container_name` | `na-scheduler-api` | préfixe `na-` |
| `hostname` | `scheduler-api` | → `http://scheduler-api.new-age.me` |
| `host_port` | `8002` | port publié hôte (libre vs 8000/8001/5174) |
| `container_port` | `8000` | port écouté dans l’image |
| `ghcr_image` | `ghcr.io/…/scheduler:main` | défaut `.env` |
| `build_context` | `../../scheduler` | relatif à `local/` |
| `dockerfile_dev` | `Dockerfile.dev` | requis pour overlay DEV |
| `needs_postgres` / `needs_redis` | oui/non | sinon retirer `<<: *app-common` ou overrider `depends_on` |
| `needs_auth` | oui → `AUTH_SERVICE_URL`, JWT_* | |
| `env_vars` | liste | noms + defaults inertes |
| `web` (si UI) | port 517x, proxy API, deps `deesplay` ? | pattern `auth-admin` |

---

## Phase 2 — Synthèse (validation)

Avant d’écrire, afficher un tableau :

```
short:           …
profiles:        [short, apps, full]
DEV overlay:     local/overlays/dev-{short}.yml
make up:         make up PROFILES="infra {short}" DEV={short}
URL Traefik:     http://{hostname}.new-age.me
Port direct:     localhost:{host_port}
```

Attendre un OK explicite si un paramètre était ambigu.

---

## Phase 3 — Édition fichiers

Checklist (cocher mentalement ; tout faire dans le même changement) :

### 3.1 `local/docker-compose.yml`

- Commentaire d’en-tête : ajouter l’URL Traefik.
- Profiles doc : ajouter `{short}`.
- Nouveau service :
  - API : `<<: *app-common`, `profiles: ["{short}", "apps", "full"]`,
    `image: ${FOO_IMAGE:-…}`, `pull_policy: ${FOO_PULL_POLICY:-missing}`,
    `ports`, `environment`, labels Traefik.
  - Web only-dev : `pull_policy: never`, `build`, volumes, volume nommé
    `node_modules` si besoin (voir `auth-admin`).
- S’inspirer du template
  `templates/compose-api.fragment.yml` ou `compose-web.fragment.yml`.

### 3.2 `local/overlays/dev-{short}.yml`

- Copier / adapter `templates/dev-api.overlay.yml`.
- `image: na-{short}-api:dev`, `pull_policy: never`, `build.context`,
  volumes code + `/contracts` (et `/deepilot` si le service dépend de
  deepilot comme auth — lib OTel, pas un container).
- **Ne pas** bind-mount `pyproject.toml` / `uv.lock` si entrypoint les patch.

### 3.3 `local/.env.example`

- `{SHORT}_IMAGE`, `{SHORT}_PULL_POLICY=missing`, `{SHORT}_HOST_PORT=…`
- Vars d’env spécifiques (DB URL, etc.)
- Si front ou CORS : ajouter `http://{hostname}.new-age.me` (et localhost
  du port Vite) à `CORS_ORIGINS` **côté service qui sert l’API** (souvent
  auth ou la nouvelle API).

Ne pas modifier le `.env` local de l’utilisateur sans le dire ; proposer
de recopier les clés manquantes depuis l’example.

### 3.4 `local/hosts.example`

- `127.0.0.1 {hostname}.new-age.me`

### 3.5 `local/repos.tsv` (si nouveau repo)

- Ligne `dir_name<TAB>git_clone_url`

### 3.6 `Makefile`

- Exemples `help` : une ligne `PROFILES="infra {short}" DEV={short}`
- `local/scripts/stack.sh` + `stack-service.sh` : ajouter le service dans les
  catalogues (profiles, container_name, env docs, how_to_run)
- `ensure-dev-overlays` liste déjà les `dev-*.yml` présents (pas de liste
  en dur à maintenir)

### 3.7 `local/README.md`

- Tableau Profiles : ligne `{short}`
- Tableau Ports / URLs
- Exemple `make up` dans « Que lancer ? »
- Si front : noter le prérequis clone (ex. `deesplay`)

### 3.8 Headers compose / skill setup-local

- Si le service impacte le DEV hot-reload : rien d’obligatoire dans
  `setup-local` sauf si tu veux citer le nouveau short dans les exemples.

---

## Phase 4 — Smoke

Depuis `.github/` :

```bash
make ensure-env
docker compose --env-file local/.env -f local/docker-compose.yml \
  -f local/overlays/dev-{short}.yml --profile {short} config --services
```

Doit lister le nouveau service **sans** erreur. Ne pas `up` sans demande
utilisateur (peut tirer des images / builder).

Optionnel : `make repos-check` si le repo vient d’être cloné.

---

## Phase 5 — Récap

Donner à l’utilisateur :

```bash
make hosts-install   # si nouveau hostname
make up PROFILES="infra {short}" DEV={short}
# URL : http://{hostname}.new-age.me  ou  http://localhost:{host_port}
```

Lister les fichiers touchés. Rappeler : image GHCR sans `DEV=` =
`make up PROFILES="infra {short}"` (pas d’overlay).

---

## Anti-patterns

- Inventer un second réseau Docker (rester sur `na` / `na-network`).
- Profile uniquement `full` sans profile dédié (impossible de lancer le
  service seul).
- `DEV=scheduler-api` si le fichier est `dev-scheduler.yml` — mismatch.
- Oublier `apps` / `full` → le service n’apparaît pas dans les profils
  « tout ».
- Traefik `server.port` = port **hôte** (non : port container).
- Créer le service Compose sans `Dockerfile.dev` puis documenter `DEV=`
  comme prêt.
