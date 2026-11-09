# New Age — local workspace helpers
#
#   make setup
#   make up PROFILES="infra"
#   make up PROFILES="infra platform"                 # GHCR image
#   make up PROFILES="infra platform" DEV=platform    # local Dockerfile.dev + reload
#   make up PROFILES="infra auth platform" DEV=auth
#
# NEW_AGE_ROOT = parent of .github/ (any folder name). Override:
#   make clone NEW_AGE_ROOT=/path/to/ws

.DEFAULT_GOAL := help

MAKEFILE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
NEW_AGE_ROOT ?= $(abspath $(MAKEFILE_DIR)/..)
LOCAL_DIR := $(MAKEFILE_DIR)/local
REPOS_TSV := $(LOCAL_DIR)/repos.tsv
COMPOSE_FILE := $(LOCAL_DIR)/docker-compose.yml
COMPOSE_ENV := $(LOCAL_DIR)/.env
COMPOSE_ENV_EXAMPLE := $(LOCAL_DIR)/.env.example
OVERLAYS_DIR := $(LOCAL_DIR)/overlays

# Space-separated Compose profiles
PROFILES ?= infra
# Space-separated apps to run from local Dockerfile.dev (auth, platform, monitor)
DEV ?=

DOCKER_COMPOSE := docker compose
PROFILE_FLAGS := $(foreach p,$(PROFILES),--profile $(p))
DEV_FLAGS := $(foreach d,$(DEV),-f $(OVERLAYS_DIR)/dev-$(d).yml)

.PHONY: help setup ensure-env clone clone-status repos-check status stack service \
	migrations \
	up down build infra-up infra-down infra-ps infra-logs infra-reset \
	hosts-print hosts-install print-root

# make service SERVICE=auth-service  (aliases: auth, platform, auth-admin, postgres, …)
# make migrations SERVICE=auth       (aliases: auth, platform, monitor | all)
SERVICE ?=

help: ensure-env ## Show targets
	@echo "New Age — NEW_AGE_ROOT=$(NEW_AGE_ROOT)"
	@echo "PROFILES=$(PROFILES)  DEV=$(DEV)"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make up PROFILES=\"infra\""
	@echo "  make up PROFILES=\"infra otel\"                  # + Grafana/Loki/Tempo/Prometheus"
	@echo "  make up PROFILES=\"infra platform\"              # platform from GHCR"
	@echo "  make up PROFILES=\"infra platform\" DEV=platform # hot-reload build"
	@echo "  make up PROFILES=\"infra auth platform\" DEV=auth"
	@echo "  make up PROFILES=\"infra monitor\" DEV=monitor  # deepi_monitor hot-reload"
	@echo "  make up PROFILES=\"infra messaging scheduler deepipush deepivoice deepiads deepikiosk\""
	@echo "  make stack                                      # containers + profiles + Traefik URLs"
	@echo "  make service SERVICE=deepi-monitor              # détail 1 service (aliases: monitor)"
	@echo "  make migrations                                 # Alembic info (5 derniers appliqués)"
	@echo "  make migrations SERVICE=auth                    # filtrer auth|platform|monitor"
	@echo "  make migrations DETAIL=1                        # toutes révisions + icône ✓/○"
	@echo "  make migrations APPLY=1                         # alembic upgrade head + rapport"
	@echo "  make repos-check                                # behind/ahead/dirty (fetch, no pull)"
	@echo "  make hosts-print / make hosts-install           # print ou install (confirm oui/yes)"
	@echo ""
	@echo "URLs: http://pgadmin.new-age.me  http://auth-admin.new-age.me  http://monitor.new-age.me  http://grafana.new-age.me …"
	@echo "Overlays: $(OVERLAYS_DIR)/dev-<name>.yml"
	@echo "Skill Cursor : .cursor/skills/setup-local  (/setup-local)"

print-root: ## Print resolved workspace root
	@echo $(NEW_AGE_ROOT)

ensure-env: ## Create local/.env from .env.example if missing
	@if [ ! -f "$(COMPOSE_ENV)" ]; then \
		if [ ! -f "$(COMPOSE_ENV_EXAMPLE)" ]; then \
			echo "Missing $(COMPOSE_ENV_EXAMPLE)"; exit 1; \
		fi; \
		cp "$(COMPOSE_ENV_EXAMPLE)" "$(COMPOSE_ENV)"; \
		echo "Created $(COMPOSE_ENV) from .env.example"; \
	fi

# Validate DEV overlays exist before compose (known = local/overlays/dev-*.yml)
ensure-dev-overlays:
	@for d in $(DEV); do \
		f="$(OVERLAYS_DIR)/dev-$${d}.yml"; \
		if [ ! -f "$$f" ]; then \
			echo "Unknown DEV=$${d} (missing $$f)."; \
			echo "Known DEV overlays:"; \
			ls "$(OVERLAYS_DIR)"/dev-*.yml 2>/dev/null | xargs -n1 basename | sed 's/^dev-//;s/\.yml$$//' | sed 's/^/  /' \
				|| echo "  (none)"; \
			exit 1; \
		fi; \
	done

COMPOSE = $(DOCKER_COMPOSE) --env-file $(COMPOSE_ENV) -f $(COMPOSE_FILE) $(DEV_FLAGS) $(PROFILE_FLAGS)

setup: clone up ## Clone missing repos then start PROFILES (default infra)
	@echo ""
	@echo "Setup done. PROFILES=$(PROFILES) DEV=$(DEV)"
	@echo "  postgres → :5435  redis → :6380  traefik → :80  pgadmin → http://pgadmin.new-age.me"
	@echo ""
	@echo "Hostnames Traefik (pas écrits automatiquement dans /etc/hosts) :"
	@$(MAKE) --no-print-directory hosts-print
	@echo ""
	@echo "  → copier/coller les lignes ci-dessus dans /etc/hosts"
	@echo "  → ou : make hosts-install   (demande confirmation explicite + sudo)"
	@echo ""
	@$(MAKE) --no-print-directory repos-check

hosts-print: ## Print /etc/hosts lines for *.new-age.me
	@domain=$$(grep -E '^NEW_AGE_DOMAIN=' "$(COMPOSE_ENV)" 2>/dev/null | cut -d= -f2-); \
	domain=$${domain:-new-age.me}; \
	sed '/^[[:space:]]*#/d;/^[[:space:]]*$$/d' "$(LOCAL_DIR)/hosts.example" | \
		sed "s/new-age\\.me/$${domain}/g"

hosts-install: ensure-env ## Append missing hosts (asks oui/yes; never silent)
	@domain=$$(grep -E '^NEW_AGE_DOMAIN=' "$(COMPOSE_ENV)" 2>/dev/null | cut -d= -f2-); \
	domain=$${domain:-new-age.me}; \
	tmp=$$(mktemp); miss=$${tmp}.missing; rm -f "$$miss"; \
	sed '/^[[:space:]]*#/d;/^[[:space:]]*$$/d' "$(LOCAL_DIR)/hosts.example" | \
		sed "s/new-age\\.me/$${domain}/g" > "$$tmp"; \
	while read -r line; do \
		host=$$(echo "$$line" | awk '{print $$2}'); \
		if ! grep -Eq "(^|[[:space:]])$${host}([[:space:]]|$$)" /etc/hosts 2>/dev/null; then \
			echo "$$line" >> "$$miss"; \
		fi; \
	done < "$$tmp"; \
	if [ ! -s "$$miss" ]; then \
		echo "All hosts already present in /etc/hosts"; \
		rm -f "$$tmp" "$$miss"; \
		exit 0; \
	fi; \
	echo "Lignes absentes de /etc/hosts :"; \
	cat "$$miss"; \
	echo ""; \
	printf "Écrire ces lignes dans /etc/hosts via sudo ? Tape « oui » ou « yes » pour confirmer : "; \
	read ans; \
	case "$$ans" in \
		oui|Oui|OUI|yes|Yes|YES) \
			sudo sh -c "cat '$$miss' >> /etc/hosts"; \
			echo "Done." ;; \
		*) \
			echo "Annulé — rien n’a été modifié."; \
			echo "Copie/colle manuellement les lignes ci-dessus, ou relance : make hosts-install" ;; \
	esac; \
	rm -f "$$tmp" "$$miss"

clone: ## Clone repos from local/repos.tsv if missing under NEW_AGE_ROOT
	@test -f "$(REPOS_TSV)" || (echo "Missing $(REPOS_TSV)"; exit 1)
	@echo "Workspace: $(NEW_AGE_ROOT)"
	@mkdir -p "$(NEW_AGE_ROOT)"
	@awk '!/^[[:space:]]*#/ && NF >= 2 { print $$1, $$2 }' "$(REPOS_TSV)" | \
	while read -r dir url; do \
		dest="$(NEW_AGE_ROOT)/$${dir}"; \
		if [ -d "$${dest}/.git" ]; then \
			echo "OK      $${dir}"; \
		elif [ -e "$${dest}" ]; then \
			echo "SKIP    $${dir} (exists but not a git repo)"; \
		else \
			echo "CLONE   $${dir} <- $${url}"; \
			git clone "$${url}" "$${dest}"; \
		fi; \
	done

clone-status: ## Show which listed repos are present
	@test -f "$(REPOS_TSV)" || (echo "Missing $(REPOS_TSV)"; exit 1)
	@echo "NEW_AGE_ROOT=$(NEW_AGE_ROOT)"
	@awk '!/^[[:space:]]*#/ && NF >= 2 { print $$1, $$2 }' "$(REPOS_TSV)" | \
	while read -r dir url; do \
		dest="$(NEW_AGE_ROOT)/$${dir}"; \
		if [ -d "$${dest}/.git" ]; then \
			branch=$$(git -C "$${dest}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?"); \
			echo "present  $${dir}  ($${branch})"; \
		else \
			echo "missing  $${dir}"; \
		fi; \
	done

repos-check: ## Fetch remotes; report behind/ahead/dirty/wrong-remote (never pulls)
	@test -f "$(REPOS_TSV)" || (echo "Missing $(REPOS_TSV)"; exit 1)
	@echo "Repos check (fetch only — no pull)  NEW_AGE_ROOT=$(NEW_AGE_ROOT)"
	@echo "-------------------------------------------------------------------------"
	@printf "%-18s %-12s %-12s %s\n" "REPO" "BRANCH" "STATE" "DETAIL"
	@echo "-------------------------------------------------------------------------"
	@awk '!/^[[:space:]]*#/ && NF >= 2 { print $$1, $$2 }' "$(REPOS_TSV)" | \
	while read -r dir expected_url; do \
		dest="$(NEW_AGE_ROOT)/$${dir}"; \
		if [ ! -d "$${dest}/.git" ]; then \
			printf "%-18s %-12s %-12s %s\n" "$${dir}" "-" "missing" "make clone ← $${expected_url}"; \
			continue; \
		fi; \
		branch=$$(git -C "$${dest}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?"); \
		origin=$$(git -C "$${dest}" remote get-url origin 2>/dev/null || echo ""); \
		norm_origin=$$(echo "$$origin" | sed -E 's#^https://github.com/#git@github.com:#; s#\.git$$##'); \
		norm_expected=$$(echo "$${expected_url}" | sed -E 's#^https://github.com/#git@github.com:#; s#\.git$$##'); \
		dirty=""; \
		if [ -n "$$(git -C "$${dest}" status --porcelain 2>/dev/null)" ]; then dirty="DIRTY"; fi; \
		detail=""; state="ok"; \
		if [ -n "$$origin" ] && [ "$$norm_origin" != "$$norm_expected" ]; then \
			state="WRONG-REMOTE"; detail="origin=$${origin} (attendu $${expected_url})"; \
			printf "%-18s %-12s %-12s %s\n" "$${dir}" "$${branch}" "$${state}" "$${detail}"; \
			continue; \
		fi; \
		git -C "$${dest}" fetch --quiet origin 2>/dev/null || true; \
		up=$$(git -C "$${dest}" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true); \
		if [ -z "$$up" ]; then \
			if git -C "$${dest}" rev-parse --verify origin/main >/dev/null 2>&1; then up=origin/main; \
			elif git -C "$${dest}" rev-parse --verify origin/master >/dev/null 2>&1; then up=origin/master; \
			fi; \
		fi; \
		if [ -z "$$up" ]; then \
			state="no-up"; detail="no upstream / origin/main"; \
		else \
			behind=$$(git -C "$${dest}" rev-list --count "HEAD..$${up}" 2>/dev/null || echo 0); \
			ahead=$$(git -C "$${dest}" rev-list --count "$${up}..HEAD" 2>/dev/null || echo 0); \
			if [ "$$behind" != 0 ]; then state="BEHIND"; detail="$${behind} behind $${up}"; fi; \
			if [ "$$ahead" != 0 ]; then \
				if [ "$$state" = "BEHIND" ]; then detail="$${detail}, $${ahead} ahead"; \
				else state="AHEAD"; detail="$${ahead} ahead of $${up}"; fi; \
			fi; \
		fi; \
		if [ -n "$$dirty" ]; then \
			if [ "$$state" = "ok" ]; then state="DIRTY"; detail="uncommitted changes"; \
			else detail="$${detail} + DIRTY"; fi; \
		fi; \
		warn=""; \
		case "$${dir}" in auth-service|platform-api) \
			case "$$state" in BEHIND|DIRTY|missing) warn="  ← impacte DEV=$${dir%%-*}"; esac ;; \
		esac; \
		case "$${dir}" in deesplay) \
			case "$$state" in WRONG-REMOTE|missing) warn="  ← auth-admin file: sans NODE_AUTH_TOKEN"; esac ;; \
		esac; \
		printf "%-18s %-12s %-12s %s%s\n" "$${dir}" "$${branch}" "$${state}" "$${detail}" "$${warn}"; \
	done
	@echo "-------------------------------------------------------------------------"
	@echo "Si BEHIND sur auth-service / platform-api + DEV=… : ton hot-reload ≠ remote."
	@echo "WRONG-REMOTE (ex. deesplay legacy Deepidoo/) : mv <dir> <dir>-legacy && make clone"
	@echo "Mise à jour = git pull manuel dans le repo (jamais fait par cette cible)."

status: clone-status repos-check infra-ps stack ## Repos + outdated + compose + DEV/GHCR

stack: ensure-env ## All new-age containers: profiles, DEV/GHCR, Traefik URLs
	@COMPOSE_ENV="$(COMPOSE_ENV)" NEW_AGE_DOMAIN="$(shell grep -E '^NEW_AGE_DOMAIN=' $(COMPOSE_ENV) 2>/dev/null | cut -d= -f2-)" \
		sh "$(LOCAL_DIR)/scripts/stack.sh"

service: ensure-env ## Detail one service (SERVICE=auth-service|auth-admin|platform|…)
	@COMPOSE_ENV="$(COMPOSE_ENV)" LOCAL_DIR="$(LOCAL_DIR)" NEW_AGE_ROOT="$(NEW_AGE_ROOT)" \
		NEW_AGE_DOMAIN="$(shell grep -E '^NEW_AGE_DOMAIN=' $(COMPOSE_ENV) 2>/dev/null | cut -d= -f2-)" \
		SERVICE="$(SERVICE)" \
		sh "$(LOCAL_DIR)/scripts/stack-service.sh"

migrations: ensure-env ## Alembic info (APPLY=1 pour upgrade head ; DETAIL=1 pour ✓/○)
	@SERVICE="$(SERVICE)" DETAIL="$(DETAIL)" APPLY="$(APPLY)" sh "$(LOCAL_DIR)/scripts/migrations-status.sh"

up: ensure-env ensure-dev-overlays ## Start PROFILES (+ optional DEV overlays)
	@if [ -n "$(DEV)" ]; then echo "DEV overlays: $(DEV)"; fi
	$(COMPOSE) up -d --build
	@$(COMPOSE) ps

build: ensure-env ensure-dev-overlays ## Build images for current PROFILES/DEV
	$(COMPOSE) build

down: ensure-env ## Stop stack (keep volumes)
	$(COMPOSE) down

infra-up: ## up with PROFILES=infra
	@$(MAKE) up PROFILES=infra DEV=

infra-down: ## down with PROFILES=infra
	@$(MAKE) down PROFILES=infra DEV=

infra-ps: ensure-env ## Show containers
	@$(COMPOSE) ps || true

infra-logs: ensure-env ## Tail logs
	$(COMPOSE) logs -f --tail=100

infra-reset: ensure-env ## Stop and DELETE Postgres volume (destructive)
	@echo "This removes local Postgres data (volume na_pgdata)."
	@printf "Type 'yes' to confirm: " && read ans && [ "$$ans" = "yes" ]
	$(COMPOSE) down -v
