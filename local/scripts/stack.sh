#!/usr/bin/env sh
# Liste les containers du projet Compose new-age : profiles, mode DEV/GHCR,
# mount contracts, URLs Traefik.
set -eu

DOMAIN="${NEW_AGE_DOMAIN:-new-age.me}"
if [ -f "${COMPOSE_ENV:-}" ]; then
  d=$(grep -E '^NEW_AGE_DOMAIN=' "$COMPOSE_ENV" 2>/dev/null | cut -d= -f2- || true)
  [ -n "${d:-}" ] && DOMAIN="$d"
fi

# Couleurs ON par défaut (make n'a souvent pas de TTY).
# NO_COLOR=1 les coupe ; FORCE_COLOR=1 les force même sous NO_COLOR.
USE_COLOR=1
if [ -n "${NO_COLOR:-}" ]; then
  USE_COLOR=0
fi
if [ "${FORCE_COLOR:-}" = "1" ]; then
  USE_COLOR=1
fi

# Largeurs visibles (hors codes ANSI)
W_NAME=18
W_SVC=16
W_KIND=10
W_MODE=8
W_CONTRACTS=12
W_PROFILES=34

pad() {
  # pad CURRENT_VISIBLE TARGET
  cur=$1
  want=$2
  n=$((want - cur))
  if [ "$n" -gt 0 ]; then
    printf "%*s" "$n" ""
  fi
}

# Affiche un tag coloré ; echo la largeur visible sur fd 3 si demandé via retour
# Usage: tag COLOR TEXT  → imprime ; met VIS dans variable via tag_vis
tag() {
  code=$1
  shift
  text=$*
  if [ "$USE_COLOR" = 1 ]; then
    printf '\033[%sm %s \033[0m' "$code" "$text"
    # " text " → len+2
    TAG_VIS=$((${#text} + 2))
  else
    printf '[%s]' "$text"
    TAG_VIS=$((${#text} + 2))
  fi
}

profile_tag() {
  case "$1" in
    infra)    tag '1;37;46' infra ;;
    otel)     tag '1;30;103' otel ;;
    auth)     tag '1;37;45' auth ;;
    platform) tag '1;30;43' platform ;;
    monitor)  tag '1;37;42' monitor ;;
    messaging|scheduler|deepipush|deepivoice|deepiads|deepikiosk) tag '1;37;42' "$1" ;;
    apps)     tag '1;37;42' apps ;;
    full)     tag '1;37;44' full ;;
    *)        tag '1;37;100' "$1" ;;
  esac
}

profiles_for_service() {
  case "$1" in
    traefik|postgres|redis|pgadmin) printf '%s' 'infra full' ;;
    tempo|loki|prometheus|grafana)  printf '%s' 'otel full' ;;
    auth-service|auth-admin)        printf '%s' 'auth apps full' ;;
    platform-api)                   printf '%s' 'platform apps full' ;;
    deepi-monitor)                  printf '%s' 'monitor apps full' ;;
    messaging|messaging-api|mailcatcher) printf '%s' 'messaging apps full' ;;
    scheduler)                      printf '%s' 'scheduler apps full' ;;
    deepipush|deepipush-db|deepipush-web) printf '%s' 'deepipush apps full' ;;
    deepivoice|deepivoice-api)      printf '%s' 'deepivoice apps full' ;;
    deepiads|deepiads-api|deepiads-postgres|deepiads-redis) printf '%s' 'deepiads apps full' ;;
    deepikiosk)                     printf '%s' 'deepikiosk apps full' ;;
    *)                              printf '%s' '?' ;;
  esac
}

kind_for_service() {
  case "$1" in
    traefik|postgres|redis|pgadmin) printf '%s' 'infra' ;;
    tempo|loki|prometheus|grafana)  printf '%s' 'otel' ;;
    auth-admin)                     printf '%s' 'web' ;;
    auth-service|platform-api|deepi-monitor|messaging-api|scheduler|deepipush|deepivoice-api|deepiads-api) printf '%s' 'api' ;;
    messaging|deepivoice|deepiads|deepikiosk|deepipush-web) printf '%s' 'web' ;;
    *)                              printf '%s' 'svc' ;;
  esac
}

traefik_urls() {
  docker inspect -f '{{range $k,$v := .Config.Labels}}{{println $k $v}}{{end}}' "$1" 2>/dev/null \
    | grep 'traefik.http.routers.' \
    | grep '\.rule ' \
    | sed -n 's/.*Host(`\([^`]*\)`).*/\1/p' \
    | while read -r host; do
        [ -n "$host" ] && printf 'http://%s\n' "$host"
      done | awk 'NR>1{printf ", "}{printf "%s", $0} END{print ""}'
}

print_kind() {
  case "$1" in
    infra) tag '1;37;46' infra ;;
    otel)  tag '1;30;103' otel ;;
    api)   tag '1;37;44' api ;;
    web)   tag '1;37;45' web ;;
    *)     printf '%s' "$1"; TAG_VIS=${#1} ;;
  esac
  pad "$TAG_VIS" "$W_KIND"
}

print_mode() {
  case "$1" in
    DEV)  tag '1;30;102' DEV ;;
    GHCR) tag '1;37;104' GHCR ;;
    -)    printf '-'; TAG_VIS=1 ;;
    *)    tag '1;37;100' "$1" ;;
  esac
  pad "$TAG_VIS" "$W_MODE"
}

print_profiles() {
  vis=0
  first=1
  for p in $(profiles_for_service "$1"); do
    if [ "$first" = 1 ]; then
      first=0
    else
      printf ' '
      vis=$((vis + 1))
    fi
    profile_tag "$p"
    vis=$((vis + TAG_VIS))
  done
  pad "$vis" "$W_PROFILES"
}

HR="--------------------------------------------------------------------------------------------------------------"

echo "New Age stack (project=new-age)  domain=${DOMAIN}"
echo "$HR"

ids=$(docker ps -q --filter 'label=com.docker.compose.project=new-age' 2>/dev/null || true)
if [ -z "$ids" ]; then
  echo "(aucun container new-age en cours)"
  exit 0
fi

printf "%-${W_NAME}s %-${W_SVC}s %-${W_KIND}s %-${W_MODE}s %-${W_CONTRACTS}s %-${W_PROFILES}s %s\n" \
  'CONTAINER' 'SERVICE' 'KIND' 'MODE' 'CONTRACTS' 'PROFILES' 'TRAEFIK'
echo "$HR"

echo "$ids" | while read -r id; do
  [ -z "$id" ] && continue
  name=$(docker inspect -f '{{.Name}}' "$id" | sed 's#^/##')
  svc=$(docker inspect -f '{{index .Config.Labels "com.docker.compose.service"}}' "$id")
  img=$(docker inspect -f '{{.Config.Image}}' "$id")
  cfg=$(docker inspect -f '{{index .Config.Labels "com.docker.compose.project.config_files"}}' "$id")
  kind=$(kind_for_service "$svc")

  mode='-'
  case "$kind" in
    api|web)
      case "$img" in
        *:dev|na-*:dev) mode=DEV ;;
        ghcr.io/*)      mode=GHCR ;;
        *)
          case "$cfg" in
            *overlays/dev-*) mode=DEV ;;
            *) mode='?' ;;
          esac
          ;;
      esac
      if [ "$svc" = 'auth-admin' ]; then mode=DEV; fi
      ;;
  esac

  contracts=$(docker inspect -f '{{range .Mounts}}{{if eq .Destination "/contracts"}}yes{{end}}{{end}}' "$id")
  [ -z "$contracts" ] && contracts='-'
  if [ "$kind" = 'infra' ] || [ "$kind" = 'web' ]; then
    contracts='-'
  fi

  urls=$(traefik_urls "$id" || true)
  [ -z "${urls:-}" ] && urls='-'

  printf "%-${W_NAME}s %-${W_SVC}s " "$name" "$svc"
  print_kind "$kind"
  printf ' '
  print_mode "$mode"
  printf ' '
  printf "%-${W_CONTRACTS}s " "$contracts"
  print_profiles "$svc"
  printf ' %s\n' "$urls"
done

echo "$HR"
echo "KIND       infra | otel (Tempo/Loki/Prometheus/Grafana) | api | web"
echo "MODE       DEV = Dockerfile.dev + bind-mounts | GHCR = image fixe (.env *_IMAGE)"
echo "CONTRACTS  yes = deepidoo-contracts monte en /contracts (editable, overlays DEV)"
echo "PROFILES   infra|otel|auth|platform|apps|full via make up PROFILES=..."
echo "TRAEFIK    Host rules -> http://*.${DOMAIN} (port ${TRAEFIK_HTTP_PORT:-80}, /etc/hosts)"
echo "Couleurs   FORCE_COLOR=1 make stack   |   NO_COLOR=1 pour les couper"
echo "Détail 1 service:  make service SERVICE=auth-service   (aliases: auth, platform, monitor, grafana, …)"
