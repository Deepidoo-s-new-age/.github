#!/usr/bin/env sh
# Détail d'un service New Age : runtime Docker + catalogue compose (env, volumes,
# Traefik, comment relancer en DEV ou GHCR).
#
# Usage: SERVICE=auth-service COMPOSE_ENV=... NEW_AGE_ROOT=... sh stack-service.sh
# Alias acceptés : auth, auth-api, na-auth-api, platform, pg, redis, …
set -eu

DOMAIN="${NEW_AGE_DOMAIN:-new-age.me}"
ROOT="${NEW_AGE_ROOT:-}"
ENV_FILE="${COMPOSE_ENV:-}"
LOCAL_DIR="${LOCAL_DIR:-}"
QUERY="${SERVICE:-${1:-}}"

if [ -f "$ENV_FILE" ]; then
  d=$(grep -E '^NEW_AGE_DOMAIN=' "$ENV_FILE" 2>/dev/null | cut -d= -f2- || true)
  [ -n "${d:-}" ] && DOMAIN="$d"
fi

if [ -z "$QUERY" ]; then
  echo "Usage: make service SERVICE=<nom>"
  echo ""
  echo "Services connus :"
  echo "  infra     traefik | postgres | redis | pgadmin"
  echo "  otel      tempo | loki | prometheus | grafana"
  echo "  apps      auth-service (auth) | auth-admin | platform-api (platform)"
  echo "            deepi-monitor (monitor)"
  exit 1
fi

# Normalise alias → compose service name
resolve_service() {
  q=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  case "$q" in
    traefik|na-traefik)                 echo traefik ;;
    postgres|pg|na-postgres|db)         echo postgres ;;
    redis|na-redis)                     echo redis ;;
    pgadmin|na-pgadmin)                 echo pgadmin ;;
    tempo|na-tempo)                     echo tempo ;;
    loki|na-loki)                       echo loki ;;
    prometheus|prom|na-prometheus)      echo prometheus ;;
    grafana|na-grafana)                 echo grafana ;;
    auth-service|auth|auth-api|na-auth-api|api-auth)
                                        echo auth-service ;;
    auth-admin|admin|na-auth-admin|acl) echo auth-admin ;;
    platform-api|platform|na-platform-api|api-platform)
                                        echo platform-api ;;
    deepi-monitor|monitor|na-monitor-api|deepimonitor)
                                        echo deepi-monitor ;;
    *)                                  echo "$1" ;;
  esac
}

SVC=$(resolve_service "$QUERY")

# --- Catalogue (source de vérité doc locale) ---------------------------------

container_name_for() {
  case "$1" in
    traefik)       echo na-traefik ;;
    postgres)      echo na-postgres ;;
    redis)         echo na-redis ;;
    pgadmin)       echo na-pgadmin ;;
    tempo)         echo na-tempo ;;
    loki)          echo na-loki ;;
    prometheus)    echo na-prometheus ;;
    grafana)       echo na-grafana ;;
    auth-service)  echo na-auth-api ;;
    auth-admin)    echo na-auth-admin ;;
    platform-api)  echo na-platform-api ;;
    deepi-monitor) echo na-monitor-api ;;
    *)             echo "" ;;
  esac
}

profiles_for() {
  case "$1" in
    traefik|postgres|redis|pgadmin) echo "infra full" ;;
    tempo|loki|prometheus|grafana)  echo "otel full" ;;
    auth-service|auth-admin)        echo "auth apps full" ;;
    platform-api)                   echo "platform apps full" ;;
    deepi-monitor)                  echo "monitor apps full" ;;
    *)                              echo "?" ;;
  esac
}

kind_for() {
  case "$1" in
    traefik|postgres|redis|pgadmin) echo infra ;;
    tempo|loki|prometheus|grafana)  echo otel ;;
    auth-admin)                     echo web ;;
    auth-service|platform-api|deepi-monitor) echo api ;;
    *)                              echo svc ;;
  esac
}

summary_for() {
  case "$1" in
    traefik)
      echo "Reverse-proxy HTTP :80 — route Host(*.${DOMAIN}) vers les apps via labels Docker." ;;
    postgres)
      echo "Postgres New Age (schémas auth, core, monitor). Port hôte NEW_AGE_POSTGRES_PORT (défaut 5435)." ;;
    redis)
      echo "Redis (allowlist/blocklist JWT jti). Port hôte NEW_AGE_REDIS_PORT (défaut 6380)." ;;
    pgadmin)
      echo "UI Postgres. Serveur « New Age (local) » branché sur le Postgres du Compose (mot de passe inclus)." ;;
    tempo)
      echo "Tempo — traces OTLP HTTP :4318 (deepilot DEEPILOT_TEMPO_ENDPOINT)." ;;
    loki)
      echo "Loki — logs OTLP http://loki:3100/otlp (deepilot DEEPILOT_LOKI_ENDPOINT)." ;;
    prometheus)
      echo "Prometheus — metrics OTLP /api/v1/otlp (deepilot DEEPILOT_PROMETHEUS_ENDPOINT)." ;;
    grafana)
      echo "Grafana UI — datasources Tempo/Loki/Prometheus. http://grafana.${DOMAIN}" ;;
    auth-service)
      echo "API auth (JWT, ACL Casbin, registre modules). Login users = WEBAPP_DATABASE_URL." ;;
    auth-admin)
      echo "UI ACL Vite (auth-service/frontend). Toujours build local ; proxy /v1 → auth-service." ;;
    platform-api)
      echo "API platform/core. Transition : lit encore souvent la webapp (PLATFORM_DATABASE_URL)." ;;
    deepi-monitor)
      echo "API Deepi Monitor (contrôle parc). Scaffold /health ; schéma Postgres monitor." ;;
    *)
      echo "Service inconnu du catalogue local — infos runtime seulement si le container tourne." ;;
  esac
}

# Env keys attendues par le service + courte signification
env_docs_for() {
  case "$1" in
    traefik)
      cat <<EOF
NEW_AGE_DOMAIN          Domaine Traefik (Host rules + /etc/hosts)
TRAEFIK_HTTP_PORT       Port hôte entrypoint web (défaut 80)
TRAEFIK_DASHBOARD_PORT  Port dashboard Traefik (défaut 8080)
EOF
      ;;
    postgres)
      cat <<EOF
NEW_AGE_POSTGRES_PORT     Port hôte → 5432 container
NEW_AGE_POSTGRES_USER     User Postgres
NEW_AGE_POSTGRES_PASSWORD Mot de passe
NEW_AGE_POSTGRES_DB       Database (new_age)
EOF
      ;;
    redis)
      cat <<EOF
NEW_AGE_REDIS_PORT  Port hôte → 6379 container
REDIS_URL           URL utilisée par les apps (redis://redis:6379/14)
EOF
      ;;
    pgadmin)
      cat <<EOF
PGADMIN_EMAIL             Login UI
PGADMIN_PASSWORD          Mot de passe UI
PGADMIN_HOST_PORT         Port hôte → 80 container
NEW_AGE_DOMAIN            Host Traefik pgadmin.\${DOMAIN}
NEW_AGE_POSTGRES_USER     User du serveur prérempli
NEW_AGE_POSTGRES_PASSWORD Mot de passe du serveur prérempli
NEW_AGE_POSTGRES_DB       Database du serveur prérempli
EOF
      ;;
    auth-service)
      cat <<EOF
AUTH_IMAGE            Image GHCR (défaut ghcr.io/.../auth-service:main)
AUTH_PULL_POLICY      Politique pull Compose (souvent missing)
AUTH_HOST_PORT        Port hôte API (8000)
AUTH_DATABASE_URL     Postgres schéma auth (stack : postgres:5432/new_age)
WEBAPP_DATABASE_URL   Users / login (souvent webapp hôte :5432)
REDIS_URL             Redis jti allow/blocklist
JWT_SECRET            Secret de signature JWT (aligner avec platform)
JWT_ISSUER            Claim iss des JWT (aligner avec platform)
CORS_ORIGINS          Origines autorisées (fronts locaux + Traefik)
EOF
      ;;
    auth-admin)
      cat <<EOF
AUTH_ADMIN_HOST_PORT  Port Vite hôte (5174)
AUTH_API_PROXY        Cible proxy /v1 (http://auth-service:8000 en Compose)
NODE_AUTH_TOKEN       Optionnel — PAT read:packages ; sinon file: sibling deesplay
NEW_AGE_DOMAIN        Host Traefik auth-admin.\${DOMAIN}
EOF
      ;;
    platform-api)
      cat <<EOF
PLATFORM_IMAGE          Image GHCR (défaut ghcr.io/.../platform-api:main)
PLATFORM_PULL_POLICY    Politique pull Compose
PLATFORM_HOST_PORT      Port hôte (8001→8000)
PLATFORM_DATABASE_URL   Injecté comme DATABASE_URL (souvent webapp en transition)
REDIS_URL               Cache / utilitaires
AUTH_SERVICE_URL        Validation JWT / appels auth
JWT_SECRET              Doit matcher auth-service
JWT_ISSUER              Doit matcher auth-service
AUTH_SKIP_JTI_CHECK     true = skip allowlist Redis (dev)
EOF
      ;;
    deepi-monitor)
      cat <<EOF
MONITOR_IMAGE           Image GHCR (défaut ghcr.io/.../deepi-monitor:latest)
MONITOR_PULL_POLICY     Politique pull Compose
MONITOR_HOST_PORT       Port hôte (8010→8000)
MONITOR_DATABASE_URL    Injecté comme DATABASE_URL (Postgres New Age / schéma monitor)
PLATFORM_API_URL        Appels M2M / lecture parc (http://platform-api:8000)
AUTH_SERVICE_URL        Validation JWT / appels auth
JWT_SECRET / JWT_ISSUER Doivent matcher auth-service
MONITOR_CORS_ORIGINS    CORS dédié Monitor (sinon défaut compose)
EOF
      ;;
  esac
}

compose_paths_for() {
  case "$1" in
    traefik|postgres|redis|pgadmin)
      echo "Compose:  local/docker-compose.yml  (service $1)"
      echo "Overlay:  (aucun — infra image upstream)"
      ;;
    auth-service)
      echo "Compose:  local/docker-compose.yml  (service auth-service)"
      echo "Overlay:  local/overlays/dev-auth.yml  (DEV=auth)"
      echo "Backend:  ${ROOT}/auth-service/backend"
      echo "Dockerfile.dev:  auth-service/backend/Dockerfile.dev"
      echo "Alembic:    ${ROOT}/auth-service/backend/alembic  → /app/alembic"
      echo "Contracts:  ${ROOT}/contracts  → /contracts"
      echo "Deepilot:   ${ROOT}/deepilot   → /deepilot"
      echo "Migrate:    docker exec na-auth-api uv run alembic upgrade head"
      ;;
    auth-admin)
      echo "Compose:  local/docker-compose.yml  (service auth-admin)"
      echo "Overlay:  (aucun — toujours image locale na-auth-admin:dev)"
      echo "Frontend: ${ROOT}/auth-service/frontend"
      echo "Entrypoint: auth-service/frontend/scripts/docker-dev.sh"
      echo "Deesplay:   ${ROOT}/deesplay  → /workspace/deesplay (file: si pas de NODE_AUTH_TOKEN)"
      ;;
    platform-api)
      echo "Compose:  local/docker-compose.yml  (service platform-api)"
      echo "Overlay:  local/overlays/dev-platform.yml  (DEV=platform)"
      echo "Repo:     ${ROOT}/platform-api"
      echo "Dockerfile.dev:  platform-api/Dockerfile.dev"
      echo "Alembic:    ${ROOT}/platform-api/alembic  → /app/alembic"
      echo "Contracts:  ${ROOT}/contracts  → /contracts"
      echo "Deepilot:   ${ROOT}/deepilot   → /deepilot"
      ;;
    deepi-monitor)
      echo "Compose:  local/docker-compose.yml  (service deepi-monitor)"
      echo "Overlay:  local/overlays/dev-monitor.yml  (DEV=monitor)"
      echo "Backend:  ${ROOT}/deepi_monitor/backend"
      echo "Dockerfile.dev:  deepi_monitor/backend/Dockerfile.dev"
      echo "Contracts:  ${ROOT}/contracts  → /contracts"
      ;;
  esac
}

how_to_run() {
  case "$1" in
    traefik|postgres|redis|pgadmin)
      cat <<EOF
Relancer (infra) :
  cd .github && make up PROFILES="infra"

Logs :
  docker logs -f $(container_name_for "$1")
EOF
      ;;
    tempo|loki|prometheus|grafana)
      cat <<EOF
Relancer (observability) :
  cd .github && make up PROFILES="infra otel"

Avec apps (export deepilot) :
  make up PROFILES="infra otel auth platform" DEV="auth platform"

Grafana : http://grafana.new-age.me  (GRAFANA_ADMIN_USER / GRAFANA_ADMIN_PASSWORD)

Logs :
  docker logs -f $(container_name_for "$1")
EOF
      ;;
    auth-service)
      cat <<EOF
Relancer en DEV (hot-reload + mounts contracts/deepilot) :
  cd .github && make up PROFILES="infra auth" DEV=auth

Relancer en image GHCR (pas d'overlay DEV) :
  cd .github && make up PROFILES="infra auth" DEV=

  # image / tag : AUTH_IMAGE et AUTH_PULL_POLICY dans local/.env

Recreate uniquement ce service (Compose courant) :
  docker compose --env-file local/.env -f local/docker-compose.yml \\
    -f local/overlays/dev-auth.yml --profile auth up -d --force-recreate --build auth-service

Logs :
  docker logs -f na-auth-api
EOF
      ;;
    auth-admin)
      cat <<EOF
Toujours build local (pas de mode GHCR pour l'admin ACL).

Relancer avec le stack auth :
  cd .github && make up PROFILES="infra auth" DEV=auth

Recreate uniquement auth-admin :
  docker compose --env-file local/.env -f local/docker-compose.yml \\
    --profile auth up -d --force-recreate --build auth-admin

deesplay : sans NODE_AUTH_TOKEN → file: sibling ; avec PAT → GitHub Packages
  (voir auth-service/frontend/scripts/docker-dev.sh)

Logs :
  docker logs -f na-auth-admin
EOF
      ;;
    platform-api)
      cat <<EOF
Relancer en DEV (hot-reload + mount contracts) :
  cd .github && make up PROFILES="infra platform" DEV=platform

Relancer en image GHCR :
  cd .github && make up PROFILES="infra platform" DEV=

  # image / tag : PLATFORM_IMAGE et PLATFORM_PULL_POLICY dans local/.env

Recreate uniquement platform-api (DEV) :
  docker compose --env-file local/.env -f local/docker-compose.yml \\
    -f local/overlays/dev-platform.yml --profile platform \\
    up -d --force-recreate --build platform-api

Logs :
  docker logs -f na-platform-api
EOF
      ;;
    deepi-monitor)
      cat <<EOF
Relancer en DEV (hot-reload + mount contracts) :
  cd .github && make up PROFILES="infra monitor" DEV=monitor

Relancer en image GHCR (quand publiée) :
  cd .github && make up PROFILES="infra monitor" DEV=

  # image / tag : MONITOR_IMAGE et MONITOR_PULL_POLICY dans local/.env

Recreate uniquement deepi-monitor (DEV) :
  docker compose --env-file local/.env -f local/docker-compose.yml \\
    -f local/overlays/dev-monitor.yml --profile monitor \\
    up -d --force-recreate --build deepi-monitor

URL : http://monitor.new-age.me/health  ou  http://localhost:8010/health

Logs :
  docker logs -f na-monitor-api
EOF
      ;;
  esac
}

# --- Helpers runtime ---------------------------------------------------------

mask_value() {
  key=$1
  val=$2
  case "$key" in
    *PASSWORD*|*SECRET*|*TOKEN*|*_KEY*|NODE_AUTH_TOKEN|JWT_SECRET|WEBAPP_DATABASE_URL|PLATFORM_DATABASE_URL|AUTH_DATABASE_URL|DATABASE_URL|REDIS_URL)
      # garde schéma/host visible pour les URLs ; masque userinfo
      case "$val" in
        *://*)
          printf '%s' "$val" | sed -E 's#://[^@/]+@#://***:***@#'
          ;;
        "")
          printf '%s' '(vide)'
          ;;
        *)
          printf '%s' '***'
          ;;
      esac
      ;;
    *)
      printf '%s' "$val"
      ;;
  esac
}

section() {
  echo ""
  echo "## $1"
  echo "--------------------------------------------------------------------------------"
}

CNAME=$(container_name_for "$SVC")
if [ -z "$CNAME" ]; then
  echo "Service inconnu: '$QUERY' (résolu: '$SVC')"
  echo "Essayez: make service SERVICE=auth-service | auth-admin | platform-api | deepi-monitor | postgres | …"
  exit 1
fi

RUNNING=0
if docker inspect "$CNAME" >/dev/null 2>&1; then
  STATE=$(docker inspect -f '{{.State.Status}}' "$CNAME")
  if [ "$STATE" = "running" ]; then
    RUNNING=1
  fi
else
  STATE="absent"
fi

# --- Affichage ---------------------------------------------------------------

echo "New Age service detail"
echo "================================================================================"
echo "Query:       $QUERY"
echo "Compose:     $SVC"
echo "Container:   $CNAME"
echo "Kind:        $(kind_for "$SVC")"
echo "Profiles:    $(profiles_for "$SVC")"
echo "Status:      $STATE"
echo "Summary:     $(summary_for "$SVC")"

section "Fichiers / chemins"
compose_paths_for "$SVC"

section "Comment relancer"
how_to_run "$SVC"

section "Variables d'environnement (catalogue + .env)"
echo "(valeurs masquées pour secrets / URLs avec credentials)"
echo ""
env_docs_for "$SVC" | while IFS= read -r line; do
  [ -z "$line" ] && continue
  key=$(printf '%s' "$line" | awk '{print $1}')
  desc=$(printf '%s' "$line" | sed -E 's/^[^ ]+[ ]+//')
  printf "  %-28s %s\n" "$key" "$desc"
  if [ -f "$ENV_FILE" ] && grep -Eq "^${key}=" "$ENV_FILE" 2>/dev/null; then
    raw=$(grep -E "^${key}=" "$ENV_FILE" | head -1 | cut -d= -f2-)
    printf "      .env %s=%s\n" "$key" "$(mask_value "$key" "$raw")"
  elif [ -f "$ENV_FILE" ] && grep -Eq "^#[[:space:]]*${key}=" "$ENV_FILE" 2>/dev/null; then
    printf "      .env %s=(commenté)\n" "$key"
  fi
done

if [ "$RUNNING" = 1 ]; then
  section "Runtime — image"
  docker inspect -f 'Image:     {{.Config.Image}}
ImageID:   {{.Image}}
Created:   {{.Created}}
Started:   {{.State.StartedAt}}' "$CNAME"

  section "Runtime — ports (hôte → container)"
  docker inspect -f '{{range $p, $conf := .NetworkSettings.Ports}}{{printf "%s -> " $p}}{{range $conf}}{{.HostIp}}:{{.HostPort}} {{end}}{{println}}{{else}}(aucun publish){{end}}' "$CNAME"

  section "Runtime — Traefik / liens HTTP"
  docker inspect -f '{{range $k,$v := .Config.Labels}}{{println $k "=" $v}}{{end}}' "$CNAME" \
    | grep -E '^traefik\.' | sort || echo "(pas de labels Traefik)"
  echo ""
  docker inspect -f '{{range $k,$v := .Config.Labels}}{{println $k $v}}{{end}}' "$CNAME" \
    | grep 'traefik.http.routers.' | grep '\.rule ' \
    | sed -n 's/.*Host(`\([^`]*\)`).*/\1/p' \
    | while read -r host; do
        [ -n "$host" ] && echo "  http://${host}"
      done
  # ports hôte directs
  echo "  (ports publish : voir section ports ; Traefik = http://*.${DOMAIN})"

  section "Runtime — volumes / binds"
  docker inspect -f '{{range .Mounts}}{{printf "%-10s %s\n         -> %s\n" .Type .Source .Destination}}{{else}}(aucun){{end}}' "$CNAME"

  section "Runtime — env du container (masqué)"
  docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$CNAME" | sort | while IFS= read -r line; do
    key=${line%%=*}
    val=${line#*=}
    printf "  %s=%s\n" "$key" "$(mask_value "$key" "$val")"
  done

  section "Runtime — réseaux"
  docker inspect -f '{{range $k,$v := .NetworkSettings.Networks}}{{printf "%s  ip=%s\n" $k $v.IPAddress}}{{end}}' "$CNAME"

  section "Runtime — depends_on (label compose)"
  docker inspect -f '{{index .Config.Labels "com.docker.compose.depends_on"}}' "$CNAME"
  echo ""
  echo "Config files:"
  docker inspect -f '{{index .Config.Labels "com.docker.compose.project.config_files"}}' "$CNAME" | tr ',' '\n' | sed 's/^/  /'
else
  section "Runtime"
  echo "Container '$CNAME' non running ($STATE)."
  echo "Démarre-le puis relance: make service SERVICE=$SVC"
fi

echo ""
echo "================================================================================"
echo "Liste courte de tous les containers:  make stack"
