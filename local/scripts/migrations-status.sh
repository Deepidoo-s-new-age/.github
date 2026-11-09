#!/usr/bin/env sh
# Rapport Alembic local. Par défaut : info only. APPLY=1 lance upgrade head.
#
# Usage (depuis .github/ via Make):
#   make migrations                          # 5 derniers schémas appliqués (sha → name)
#   make migrations SERVICE=auth
#   make migrations DETAIL=1                 # toutes les révisions + icône ✓ / ○
#   make migrations APPLY=1                  # alembic upgrade head puis rapport
#   make migrations SERVICE=auth APPLY=1
#   make migrations SERVICE=desk APPLY=1     # deep_desk (app/alembic.ini)
#
# Env: SERVICE, DETAIL (0|1), APPLY (0|1), NO_COLOR=1

set -eu

QUERY=$(printf '%s' "${SERVICE:-}" | tr '[:upper:]' '[:lower:]')
DETAIL=${DETAIL:-0}
APPLY=${APPLY:-0}

is_truthy() {
  case "$1" in
    1|true|yes|YES|True|TRUE) return 0 ;;
    *) return 1 ;;
  esac
}

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RESET='\033[0m'
  C_DIM='\033[2m'
  C_BOLD='\033[1m'
  C_CYAN='\033[36m'
  C_GREEN='\033[32m'
  C_YELLOW='\033[33m'
  C_RED='\033[31m'
  C_MAGENTA='\033[35m'
  C_BLUE='\033[34m'
else
  C_RESET='' C_DIM='' C_BOLD='' C_CYAN='' C_GREEN='' C_YELLOW='' C_RED='' C_MAGENTA='' C_BLUE=''
fi

ICON_OK='✓'
ICON_PENDING='○'
ICON_NA='—'

resolve_filter() {
  q=$1
  case "$q" in
    ""|all) echo all ;;
    auth|auth-service|na-auth-api) echo auth ;;
    platform|platform-api|na-platform-api) echo platform ;;
    monitor|deepi-monitor|na-monitor-api) echo monitor ;;
    desk|deep-desk|deep_desk|deep-desk-api|na-desk-api) echo desk ;;
    *)
      echo "Unknown SERVICE='$q' (try: auth | platform | monitor | desk | all)" >&2
      exit 1
      ;;
  esac
}

FILTER=$(resolve_filter "$QUERY")

# short|container|label|alembic.ini (relative to container WORKDIR)
APPS="auth|na-auth-api|auth-service|alembic.ini
platform|na-platform-api|platform-api|alembic.ini
monitor|na-monitor-api|deepi-monitor|alembic.ini
desk|na-desk-api|deep-desk|app/alembic.ini"

hr() {
  printf '%b\n' "${C_DIM}────────────────────────────────────────────────────────────────${C_RESET}"
}

section() {
  echo ""
  printf '%b\n' "${C_BOLD}${C_CYAN}▸ $1${C_RESET}"
  hr
}

# Build rev→slug map inside container (stdout: REVMAP|rev|slug)
# Files use `revision: str = "…"` or `revision = "…"`.
# $1 = container, $2 = alembic versions dir
load_revmap() {
  docker exec "$1" sh -c '
    for f in "$1"/*.py; do
      [ -f "$f" ] || continue
      base=$(basename "$f" .py)
      case "$base" in
        __*) continue ;;
      esac
      rev=$(grep -E "^revision" "$f" | head -1 | sed -E "s/.*[\"'\'']([^\"'\'']+)[\"'\''].*/\1/")
      if [ -z "$rev" ] || [ "$rev" = "$(grep -E "^revision" "$f" | head -1)" ]; then
        continue
      fi
      prefix="${rev}_"
      case "$base" in
        ${prefix}*) slug=${base#"$prefix"} ;;
        *) slug=${base#*_} ;;
      esac
      printf "REVMAP|%s|%s\n" "$rev" "$slug"
    done
  ' sh "$2"
}

# Parse `alembic history --indicate-current` → REV|rev|applied(1|0) newest first
# Applied = revision on the (current) line and everything older below it.
parse_history() {
  cname=$1
  ini=$2
  hist=$(docker exec "$cname" uv run alembic -c "$ini" history --indicate-current 2>/dev/null \
    | grep -v '^INFO  \[alembic' || true)

  # Emit raw lines with markers for awk
  printf '%s\n' "$hist" | awk '
    # Formats:
    #   <parent> -> <rev> (head) (current), msg
    #   <base> -> <rev>, msg
    {
      line = $0
      if (line !~ /->/) next
      # extract dest revision (token after ->)
      n = split(line, parts, "->")
      if (n < 2) next
      right = parts[2]
      sub(/^[[:space:]]+/, "", right)
      split(right, tok, /[[:space:],]+/)
      rev = tok[1]
      if (rev == "" || rev == "<base>") next
      applied_mark = (index(line, "(current)") > 0) ? 1 : 0
      head_mark = (index(line, "(head)") > 0) ? 1 : 0
      print rev "|" applied_mark "|" head_mark
    }
  '
}

run_for() {
  short=$1
  cname=$2
  label=$3
  ini=$4
  alembic_dir="$(dirname "$ini")/alembic"

  if [ "$FILTER" != "all" ] && [ "$FILTER" != "$short" ]; then
    return 0
  fi

  section "$label  ${C_DIM}($cname)${C_RESET}"

  if ! docker inspect "$cname" >/dev/null 2>&1; then
    printf '%b\n' "${C_YELLOW}Container absent${C_RESET} — ex.:"
    case "$short" in
      auth)     echo "  make up PROFILES=\"infra auth\" DEV=auth" ;;
      platform) echo "  make up PROFILES=\"infra platform\" DEV=platform" ;;
      monitor)  echo "  make up PROFILES=\"infra monitor\" DEV=monitor" ;;
      desk)     echo "  make up PROFILES=\"infra auth platform desk\" DEV=desk" ;;
    esac
    return 0
  fi

  state=$(docker inspect -f '{{.State.Status}}' "$cname")
  if [ "$state" != "running" ]; then
    printf '%b\n' "${C_YELLOW}Container présent mais arrêté${C_RESET} (state=$state)."
    return 0
  fi

  if ! docker exec "$cname" test -f "$ini" -a -d "$alembic_dir" >/dev/null 2>&1; then
    printf '%b\n' "${C_DIM}${ICON_NA} Pas d’Alembic (pas de ${ini} / ${alembic_dir}/) — N/A.${C_RESET}"
    return 0
  fi

  if is_truthy "$APPLY"; then
    printf '%b\n' "${C_BOLD}Apply${C_RESET}  ${C_DIM}uv run alembic -c ${ini} upgrade head${C_RESET}"
    if docker exec "$cname" uv run alembic -c "$ini" upgrade head; then
      printf '%b\n' "        ${C_GREEN}${ICON_OK} upgrade head OK${C_RESET}"
    else
      printf '%b\n' "        ${C_RED}upgrade head a échoué${C_RESET}"
      return 0
    fi
    echo ""
  fi

  head_out=$(docker exec "$cname" uv run alembic -c "$ini" heads 2>/dev/null | grep -v '^INFO  \[alembic' | head -1 || true)
  current_out=$(docker exec "$cname" uv run alembic -c "$ini" current 2>/dev/null | grep -v '^INFO  \[alembic' | head -1 || true)
  head_rev=$(printf '%s' "$head_out" | awk '{print $1}')
  current_rev=$(printf '%s' "$current_out" | awk '{print $1}')

  parsed=$(parse_history "$cname" "$ini")
  # Mark applied: once we see (current), that rev and all following (older) are applied
  # History is newest-first, so before current = pending, from current on = applied
  rev_lines=$(
    printf '%s\n' "$parsed" | awk -F'|' '
      BEGIN { seen_current = 0 }
      {
        rev = $1; is_cur = $2; is_head = $3
        if (is_cur == 1) seen_current = 1
        applied = (seen_current == 1) ? 1 : 0
        # if never current (empty DB), nothing applied
        print rev "|" applied "|" is_head "|" is_cur
      }
    '
  )

  has_current=$(printf '%s\n' "$parsed" | awk -F'|' '$2==1 {found=1} END{print found+0}')
  has_pending=$(printf '%s\n' "$rev_lines" | awk -F'|' '$2==0 {found=1} END{print found+0}')

  if [ "$has_current" = "0" ] || [ -z "$current_rev" ] || [ "$current_rev" = "(empty)" ]; then
    # alembic current may print nothing useful
    if [ -z "$current_out" ] || printf '%s' "$current_out" | grep -qi 'empty\|none\|^$'; then
      printf '%b\n' "Status  ${C_YELLOW}${ICON_PENDING} DB vide (aucune révision)${C_RESET}"
      printf '%b\n' "        ${C_DIM}Appliquer : docker exec -it $cname uv run alembic -c $ini upgrade head${C_RESET}"
      status=empty
    else
      printf '%b\n' "Status  ${C_MAGENTA}? inconnu${C_RESET}"
      status=unknown
    fi
  elif [ "$has_pending" = "1" ]; then
    printf '%b\n' "Status  ${C_YELLOW}${ICON_PENDING} migrations en attente${C_RESET}"
    printf '%b\n' "        ${C_DIM}Appliquer : docker exec -it $cname uv run alembic -c $ini upgrade head${C_RESET}"
    status=pending
  else
    printf '%b\n' "Status  ${C_GREEN}${ICON_OK} à jour${C_RESET}  ${C_DIM}(current = head)${C_RESET}"
    status=ok
  fi

  printf '%b\n' "Head    ${C_BLUE}${head_rev:-—}${C_RESET}"
  printf '%b\n' "Current ${C_BLUE}${current_rev:-—}${C_RESET}"
  echo ""

  revmap=$(load_revmap "$cname" "$alembic_dir/versions" 2>/dev/null || true)

  slug_for() {
    rev=$1
    hit=$(printf '%s\n' "$revmap" | awk -F'|' -v r="$rev" '$2==r {print $3; exit}')
    if [ -n "$hit" ]; then
      printf '%s\n' "$hit"
    else
      printf '%s\n' "$rev"
    fi
  }

  if [ "$DETAIL" = "1" ] || [ "$DETAIL" = "true" ] || [ "$DETAIL" = "yes" ]; then
    printf '%b\n' "${C_BOLD}Révisions${C_RESET}  ${C_DIM}(✓ appliquée · ○ non appliquée)${C_RESET}"
    if [ -z "$rev_lines" ]; then
      printf '%b\n' "  ${C_DIM}(aucune révision dans alembic/versions)${C_RESET}"
    else
      printf '%s\n' "$rev_lines" | while IFS='|' read -r rev applied _is_head _is_cur; do
        [ -n "$rev" ] || continue
        slug=$(slug_for "$rev")
        if [ "$applied" = "1" ]; then
          printf '%b\n' "  ${C_GREEN}${ICON_OK}${C_RESET}  ${C_CYAN}${rev}${C_RESET}  ${C_DIM}→${C_RESET}  ${slug}"
        else
          printf '%b\n' "  ${C_YELLOW}${ICON_PENDING}${C_RESET}  ${C_CYAN}${rev}${C_RESET}  ${C_DIM}→${C_RESET}  ${slug}"
        fi
      done
    fi
  else
    printf '%b\n' "${C_BOLD}5 derniers schémas appliqués${C_RESET}  ${C_DIM}(sha → name)${C_RESET}"
    shown=0
    # shellcheck disable=SC2034
    printf '%s\n' "$rev_lines" | while IFS='|' read -r rev applied _is_head _is_cur; do
      [ -n "$rev" ] || continue
      [ "$applied" = "1" ] || continue
      shown=$((shown + 1))
      [ "$shown" -le 5 ] || break
      slug=$(slug_for "$rev")
      printf '%b\n' "  ${C_GREEN}${ICON_OK}${C_RESET}  ${C_CYAN}${rev}${C_RESET}  ${C_DIM}→${C_RESET}  ${slug}"
    done
    applied_n=$(printf '%s\n' "$rev_lines" | awk -F'|' '$2==1 {n++} END{print n+0}')
    if [ "$applied_n" = "0" ]; then
      printf '%b\n' "  ${C_DIM}(aucune migration appliquée)${C_RESET}"
    fi
  fi
}

mode_tag="info only"
is_truthy "$APPLY" && mode_tag="APPLY"
detail_tag=""
is_truthy "$DETAIL" && detail_tag=" · DETAIL"

printf '%b\n' "${C_BOLD}New Age — Alembic${C_RESET}  ${C_DIM}(${mode_tag} · filter=${FILTER}${detail_tag})${C_RESET}"

printf '%s\n' "$APPS" | while IFS='|' read -r short cname label ini; do
  [ -n "$short" ] || continue
  run_for "$short" "$cname" "$label" "$ini"
done

echo ""
hr
printf '%b\n' "${C_DIM}make migrations SERVICE=auth | DETAIL=1 | APPLY=1 (upgrade head + rapport)${C_RESET}"
