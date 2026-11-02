---
name: setup-local
description: >-
  Bootstrap the New Age local workspace after cloning (.github siblings, Docker
  Compose profiles, Traefik hosts, ACL grant, DEV overlays). Reports outdated
  local checkouts (auth-service, platform-api, …) without auto git pull. Use when
  setting up New Age locally, onboarding, /setup-local, make setup, or when a
  colleague asks why DEV stack differs from main.
disable-model-invocation: true
---

# Setup local (New Age)

Orchestrer le **premier setup** (ou un diagnostic) du workspace multi-repos
autour de `.github/`. Les commandes canoniques sont dans le **Makefile** —
ne pas inventer d’autres scripts.

Doc humaine : `local/README.md`.

## Règles dures

1. **Ne jamais** `git pull` / `git merge` / `git reset` sur un sibling sans demande
   **explicite** de l’utilisateur (mot pour mot : pull, sync, mettre à jour).
2. **Toujours** signaler clairement si `auth-service` ou `platform-api` (et les
   autres repos de `repos.tsv`) sont **en retard** sur leur remote — via
   `make repos-check`.
3. `make clone` ne clone que les dossiers **absents** ; un checkout existant
   périmé reste périmé jusqu’à action manuelle de l’utilisateur.
4. Travailler depuis le dossier `.github/` (`cd …/new-age/.github`).

## Workflow

```
- [ ] 0 — Prérequis
- [ ] 1 — Clone missing + rapport outdated
- [ ] 2 — Hosts Traefik
- [ ] 3 — Stack Docker (profiles + DEV)
- [ ] 4 — User de test ACL (optionnel)
- [ ] 5 — Synthèse (URLs + alertes repos)
```

---

## Phase 0 — Prérequis

Vérifier rapidement (et arrêter avec un message clair si KO) :

- Docker Desktop (ou engine) joignable : `docker info`
- SSH GitHub OK pour les URLs `git@github.com:…` de `local/repos.tsv`
- Workspace = parent de `.github/` (`make print-root`)

Si l’utilisateur n’a cloné que `.github`, c’est normal : `make clone` tire les siblings.

---

## Phase 1 — Clone + outdated (obligatoire)

```bash
cd .github
make clone
make repos-check
```

Interpréter `repos-check` et **afficher à l’utilisateur** (pas seulement en log) :

| État | Message |
|---|---|
| `missing` | Repo absent — relancer `make clone` ou vérifier le nom dans `repos.tsv` |
| `WRONG-REMOTE` | `origin` ≠ URL `repos.tsv` (ex. `deesplay` encore sur `Deepidoo/deesplay`) — `mv ../<dir> ../<dir>-legacy && make clone` |
| `ok` | À jour avec l’upstream suivi |
| `BEHIND n` | **Alerte** : checkout local en retard de *n* commits — code `DEV=…` ≠ remote |
| `AHEAD n` | Commits locaux non poussés |
| `DIRTY` | Fichiers non commités — ne pas proposer de pull |
| `no-upstream` | Branche sans tracking — indiquer de fixer `git branch -u` |

Insister pour **`auth-service`** et **`platform-api`** quand `BEHIND` ou `DIRTY` :

> Avec `DEV=auth` / `DEV=platform`, Compose monte **ce** checkout. Un retard
> local explique des bugs déjà corrigés sur `main`.

Ne pas pull. Si l’utilisateur veut mettre à jour : lui donner la commande
repo par repo, ex. `git -C ../auth-service pull`, **après** son OK.

---

## Phase 2 — Hosts Traefik

```bash
make hosts-print
# ou, avec confirmation interactive « oui »/« yes » :
make hosts-install
```

Rappeler : `setup` / `up` **n’écrivent jamais** `/etc/hosts` tout seuls.
URLs utiles : `http://auth-service.new-age.me`, `http://auth-admin.new-age.me`,
`http://platform-api.new-age.me`, `http://pgadmin.new-age.me`,
`http://grafana.new-age.me` (profile `otel`).

---

## Phase 3 — Stack Docker

Demander (ou inférer) profiles + mode DEV :

| Besoin | Exemple |
|---|---|
| Infra seule | `make up PROFILES=infra` |
| Observabilité | `make up PROFILES="infra otel"` |
| Apps images GHCR | `make up PROFILES="infra auth platform"` |
| Auth hot-reload local | `make up PROFILES="infra auth" DEV=auth` |
| Platform hot-reload | `make up PROFILES="infra platform" DEV=platform` |
| Full local + OTel | `make up PROFILES="infra otel auth platform" DEV="auth platform"` |

Prérequis profile `auth` : clones `auth-service`, **`deesplay`**
(`Deepidoo-s-new-age/deesplay` — fallback `file:` auth-admin si pas de
`NODE_AUTH_TOKEN`), et **`deepilot`** (lib OTel montée `/deepilot` avec
`DEV=auth|platform` — pas un service Compose ; checkout **≥ v0.1.3**).

Après `up` : `make status` (repos + containers + DEV vs GHCR) ;
`make stack` / `make service SERVICE=…` pour le détail.

Si `DEV=auth` et `auth-service` était `BEHIND` en phase 1 → **répéter l’alerte**.

---

## Phase 4 — User de test ACL (optionnel)

Uniquement si l’utilisateur veut un JWT avec rôles admin/curator :

```bash
cd ../auth-service/backend
./scripts/grant-acl-roles.sh --email toi@example.com
# ou --user-id N
docker restart na-auth-api
```

Le script lit `.github/local/.env` (ACL `localhost:5435`). Puis **re-login**.

Migration platform si besoin : `docker exec -it na-platform-api uv run alembic upgrade head`
(voir `local/README.md` — Premier jour).

---

## Phase 5 — Synthèse

Réponse courte à l’utilisateur :

1. `NEW_AGE_ROOT` + profiles / DEV utilisés  
2. URLs Traefik (+ rappel hosts si pas faits)  
3. **Bloc « Repos »** : coller le résumé `repos-check`, en gras mental sur
   auth-service / platform-api `BEHIND` ou `DIRTY`  
4. Prochaine action concrète (pull manuel, grant ACL, ou ouvrir auth-admin)

---

## Anti-patterns

- Ne pas « sync prudent » silencieux (`pull --ff-only` auto, stash, reset).
- Ne pas confondre image **GHCR** (fixe) et checkout **DEV** (local) :
  `make stack` / `make service SERVICE=…`.
- Ne pas documenter l’ancien Postgres auth `:5433` comme défaut New Age :
  stack `.github` → ACL `:5435` / db `new_age`.
