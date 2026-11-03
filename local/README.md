# New Age — local workspace

Clone les dépôts siblings + stack Docker (infra / apps) avec **profiles**,
**overlays DEV** (GHCR vs Dockerfile local + hot-reload), **Traefik** et **pgAdmin**.

## Table des matières

- [Quick start](#quick-start)
- [Commandes Make](#commandes-make)
- [Hostnames HTTP (Traefik)](#hostnames-http-traefik)
  - [HTTPS (optionnel)](#https-optionnel)
  - [pgAdmin](#pgadmin)
- [Layout / `NEW_AGE_ROOT`](#layout--new_age_root)
- [Profiles](#profiles)
- [GHCR vs hot-reload](#ghcr-vs-hot-reload-pas-de-commentaire)
- [Que lancer ?](#que-lancer-)
- [Premier jour (user de test + migration platform)](#premier-jour-user-de-test--migration-platform)
- [BDD platform-api (transition)](#bdd-platform-api-transition)
- [Ports / URLs](#ports--urls)
- [Fichiers](#fichiers)

## Quick start

```bash
cd .github
make help                           # catalogue des targets + exemples
make setup                          # clone + infra (affiche les hosts, ne les écrit pas)
make repos-check                    # BEHIND/AHEAD/DIRTY — fetch only, jamais de pull
make hosts-print                    # lignes à copier dans /etc/hosts
# ou : make hosts-install           # demande « oui »/« yes » puis sudo
make up PROFILES="infra platform" DEV=platform   # example hot-reload
```

Skill Cursor (agent) : `/setup-local` — même parcours + alerte si `auth-service` /
`platform-api` locaux ne sont pas à jour (`make repos-check`).

## Commandes Make

Depuis `.github/` (`make help` pour la même liste) :

| Target | Rôle |
|---|---|
| `help` | Catalogue + exemples (`PROFILES` / `DEV`) |
| `print-root` | Affiche `NEW_AGE_ROOT` |
| `ensure-env` | Crée `local/.env` depuis `.env.example` si absent |
| `setup` | `clone` + `up` (défaut `PROFILES=infra`) |
| `clone` / `clone-status` | Clone les absents / liste présents |
| `repos-check` | Fetch + BEHIND/AHEAD/DIRTY/WRONG-REMOTE (**jamais** de pull) |
| `hosts-print` / `hosts-install` | Lignes `/etc/hosts` (install = confirm `oui`/`yes` + sudo) |
| `up` / `down` / `build` | Start / stop (volumes gardés) / build images |
| `status` | Repos + outdated + compose + DEV/GHCR |
| `stack` | Tous les containers `new-age` + profiles + URLs Traefik |
| `service` | Détail 1 service (`SERVICE=auth-service\|grafana\|…`) |
| `infra-up` / `infra-down` / `infra-ps` / `infra-logs` | Raccourcis infra |
| `infra-reset` | `down -v` (**destructif** — efface Postgres local) |

Variables courantes : `PROFILES="infra otel auth platform"`, `DEV="auth platform"`,
`NEW_AGE_ROOT=…`, `SERVICE=…`.

## Hostnames HTTP (Traefik)

Traefik écoute sur le **port 80** et route selon le `Host` :

| URL | Service |
|---|---|
| http://pgadmin.new-age.me | pgAdmin |
| http://auth-service.new-age.me | auth-service (API) |
| http://auth-admin.new-age.me | auth-service admin ACL (Vite `:5174`) |
| http://platform-api.new-age.me | platform-api |
| http://grafana.new-age.me | Grafana (profile `otel`) |
| http://traefik.new-age.me | dashboard Traefik (aussi `:8080`) |

1. Lancer l’infra : `make up PROFILES=infra` (ou `full` / apps selon besoin).
2. Résoudre les noms vers localhost :

```bash
make hosts-print      # afficher les lignes (copie/colle)
make hosts-install    # confirmation « oui »/« yes » puis sudo → append
```

`setup` / `up` **n’écrivent jamais** `/etc/hosts` tout seuls.

3. Ouvrir les URLs ci-dessus dans le navigateur (HTTP, pas HTTPS).

Les ports directs restent disponibles (`:8000`, `:8001`, `:5435`, …) en parallèle.

### HTTPS (optionnel)

Pour du local en HTTPS (`https://….new-age.me`) :

1. Installer [mkcert](https://github.com/FiloSottile/mkcert) et générer un cert pour `*.new-age.me`.
2. Monter le cert dans Traefik + activer un entrypoint `:443` (TLS).
3. Ajouter les origines `https://…` dans `CORS_ORIGINS`.

Sans ça, restez en **HTTP sur le port 80** — suffisant pour le dev local.

### pgAdmin

- Login : `PGADMIN_EMAIL` / `PGADMIN_PASSWORD` (défaut `admin@new-age.me` / `admin`).
- Serveur préconfiguré « New Age (local) » → host Docker `postgres`, DB `new_age`, user `newage` (mot de passe = `NEW_AGE_POSTGRES_PASSWORD`).

## Layout / `NEW_AGE_ROOT`

Parent du clone `.github/` (nom de dossier libre). Surcharge :

```bash
make clone NEW_AGE_ROOT=~/dev/mon-ws
```

## Profiles

| Profile | Services |
|---|---|
| `infra` | postgres, redis, traefik, pgadmin |
| `otel` | Tempo, Loki, Prometheus, Grafana (deepilot) |
| `auth` | auth-service API + **auth-admin** (UI ACL Vite) |
| `platform` | platform-api |
| `apps` | auth (+ admin) + platform |
| `full` | tout (infra + otel + apps) |

Observabilité locale (alignée helm-charts / deepilot) :

```bash
make up PROFILES="infra otel auth platform" DEV="auth platform"
# UI : http://grafana.new-age.me  (admin / admin)
# Dossier Deepidoo : dashboards Service / Errors / Uptime / Workloads (copie de helm-charts/charts/grafana/dashboards/)
# Service/Errors : traffic HTTP sur auth + platform (otel-synthetic-traffic en profile apps/full) ; métriques OTLP ~60s
# Uptime : blackbox → /health (compose). Workloads : vide en local (metrics K8s seulement)
# Apps exportent via DEEPILOT_*_ENDPOINT → tempo:4318, loki:3100/otlp, prometheus:9090/api/v1/otlp
```

Le front ACL démarre avec le profile `auth` (plus besoin de `npm run dev` à la main).
Prérequis clone profile `auth` : `auth-service`, **`deesplay`**
(`Deepidoo-s-new-age/deesplay` via `repos.tsv` / `make clone`), et **`deepilot`**
(lib télémétrie OpenTelemetry — sibling monté en `/deepilot` si `DEV=auth|platform`,
pas un container Compose). En DEV, le checkout `deepilot/` doit être **≥ v0.1.3**
(`instrument_redis` / `instrument_sqlalchemy_engines`) — sinon auth/platform
ne démarrent pas.

**auth-admin / deesplay** :

| `NODE_AUTH_TOKEN` dans `local/.env` | Source |
|---|---|
| absent | `file:` → sibling `deesplay/packages/deesplay` (clone New Age) |
| PAT `read:packages` | GitHub Packages `@deepidoo-s-new-age/deesplay` |

Si `make repos-check` affiche `WRONG-REMOTE` sur `deesplay` (souvent un ancien
`Deepidoo/deesplay`) : `mv ../deesplay ../deesplay-legacy && make clone`.

```bash
make up PROFILES="infra"
make up PROFILES="infra otel"                     # + Grafana/Loki/Tempo/Prometheus
make up PROFILES="infra platform"                 # image GHCR (.env)
make up PROFILES="infra platform" DEV=platform    # build local + reload
make up PROFILES="infra auth platform" DEV=auth   # platform GHCR, auth local
make up PROFILES="infra otel auth platform" DEV="auth platform"
```

## GHCR vs hot-reload (pas de commentaire)

| Mode | Mécanisme |
|---|---|
| Défaut | `image:` GHCR dans `docker-compose.yml` (`AUTH_IMAGE` / `PLATFORM_IMAGE`) |
| Dev | overlay `overlays/dev-<app>.yml` via `DEV=auth` ou `DEV=platform` |

L’overlay force `build:` + volumes (`app/`, `contracts/`) + `Dockerfile.dev`
(uvicorn `--reload`).

Quand l’image GHCR n’existe pas encore : utilise `DEV=…` (build local).

Voir ce qui tourne vraiment (tous les containers `new-age`, tags de profiles,
mode DEV/GHCR, URLs Traefik, mount `contracts`) :

```bash
make stack
# aussi inclus dans: make status
# sans couleurs : NO_COLOR=1 make stack

# détail d’un service (env, volumes, Traefik, relancer DEV vs GHCR) :
make service SERVICE=auth-service
make service SERVICE=auth-admin
make service SERVICE=platform   # alias de platform-api
```

**CONTRACTS=yes** = le sibling `contracts/` (deepidoo-contracts) est monté en
`/contracts` dans l’API (overlays `DEV=auth|platform`) — code contracts éditable
à chaud. `-` = non applicable (infra / auth-admin) ou image GHCR sans ce mount.

## Que lancer ?

**Recommandé** : n’active en Compose que ce dont tu as besoin ; l’app que tu édites
en `DEV=` (container reload) **ou** uniquement sur l’hôte (uvicorn) + `PROFILES=infra`
(+ les autres apps en GHCR).

Si auth tourne sur l’hôte et platform en Compose :

```bash
# .env
AUTH_SERVICE_URL=http://host.docker.internal:8000
make up PROFILES="infra platform"
```

## Premier jour (user de test + migration platform)

### 1. Lier un user webapp aux rôles ACL (auth-service)

Les comptes vivent dans la **Postgres webapp** ; les rôles / permissions New Age
sont dans le schéma `auth` (Postgres du stack ou auth local). Pour un user
existant, le script est documenté côté auth-service :

→ [`auth-service/README.md` — Scripts utiles](../../auth-service/README.md#scripts-utiles)

En pratique (depuis `auth-service/backend`, auth déjà up) :

```bash
./scripts/grant-acl-roles.sh --email toi@deepidoo.com
# (le script lit `.github/local/.env` → ACL sur localhost:5435)
docker restart na-auth-api   # Casbin du container
# puis re-login pour un JWT à jour
```

### 2. Migration Alembic platform-api (`organisation_closures`)

Requis pour le header `X-ORGANIZATION-ID` (arbre d’orgs). Détail + suivi
`alembic_version` :

→ [`platform-api/README.md` — Migrations Alembic](../../platform-api/README.md#migrations-alembic)

Avec le stack `.github` et `DEV=platform` :

```bash
docker exec -it na-platform-api uv run alembic upgrade head
docker exec -it na-platform-api uv run alembic current
```

## BDD platform-api (transition)

`platform-api` remplacera à terme le backend Rails de la webapp. **Aujourd’hui**
il lit encore la base **webapp** (`webapp_development`, schéma legacy
`givemenext_production`) — d’où `PLATFORM_DATABASE_URL` / `DATABASE_URL` pointés
vers cette instance (souvent `host.docker.internal:5432`), pas vers le Postgres
New Age du compose (`:5435` / DB `new_age`).

Le Postgres du stack local (schémas `auth`, `core` via `initdb/`) est la cible
**future** : platform migrera dessus avec son propre schéma (ex. `core`) quand le
découpage legacy sera prêt. Jusque-là, ne pas s’étonner que catalogue / closures
vivent hors du volume `na_pgdata`.

## Ports / URLs

| Service | Port hôte | Hostname Traefik |
|---|---|---|
| Traefik | 80 (+ dashboard 8080) | traefik.new-age.me |
| Postgres | 5435 | — |
| Redis | 6380 | — |
| pgAdmin | 5051 | pgadmin.new-age.me |
| auth-service | 8000 | auth-service.new-age.me |
| auth-admin (ACL UI) | 5174 | auth-admin.new-age.me |
| platform-api | 8001 | platform-api.new-age.me |
| Grafana (profile `otel`) | 3001 | grafana.new-age.me |
| Tempo OTLP / HTTP | 4318 / 3200 | — |
| Loki | 3100 | — |
| Prometheus | 9090 | — |

```text
postgresql+asyncpg://newage:newage@localhost:5435/new_age
redis://localhost:6380/14
```

`.env` créé auto depuis `.env.example` (`make help` / `make up`). Domaine
configurable via `NEW_AGE_DOMAIN` (défaut `new-age.me`).

## Ajouter un service (module / API / UI)

Skill Cursor : **`/add-compose-service`** — profiles, overlay `DEV=`, Traefik,
`.env.example`, `hosts.example`, `repos.tsv`, doc.

Templates : `.cursor/skills/add-compose-service/templates/`.

## Fichiers

| Fichier | Rôle |
|---|---|
| `docker-compose.yml` | Infra + apps (images GHCR) + Traefik labels |
| `overlays/dev-auth.yml` | Build/reload auth |
| `overlays/dev-platform.yml` | Build/reload platform |
| `overlays/dev-*.yml` | Autres hot-reload (`DEV=` = suffixe du fichier) |
| `hosts.example` | Lignes `/etc/hosts` |
| `pgadmin/servers.json` | Connexion Postgres préremplie |
| `repos.tsv` | Liste des clones (`deesplay`, `deepilot` — libs, pas des services Compose) |
| `otel/` | Configs Tempo / Loki / Prometheus + datasources Grafana |
| `initdb/01-schemas.sql` | Schémas `auth`, `core` |
