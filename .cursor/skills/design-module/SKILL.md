---
name: design-module
description: >-
  Product and UI/UX discovery for a New Age module, then frontend-only scaffold.
  Sets design_mode: frontend_only in docs/module.yaml. Use when design creates
  mockups or journeys for a new module, or when invoking /design-module. Not for
  full-stack modules — use /new-module instead.
disable-model-invocation: true
---

# Design Module (New Age — frontend only)

Créer un **module New Age en mode design** : comprendre le besoin et l’UX, puis
générer **uniquement le frontend** (`frontend-web/`).

Le backend, les scopes, Helm et les fondations New Age sont **hors périmètre**.
Le flag `design_mode: frontend_only` dans `docs/module.yaml` active la règle
globale **RULE-GLOBAL-DESIGN-MODE** pour toutes les conversations suivantes.

Pour un module full-stack dès le départ → **`/new-module`**.

## Principes

- Langage métier + design d’abord. Pas de tables, routes HTTP, scopes ou SQL.
- Poser seulement les questions utiles (usage + intention visuelle).
- Inspecter **`deesplay`** (primitives `Deepi*`) et, si utile, un
  `frontend-web/` de module existant **explicitement cité**.
- Ne pas inspecter en profondeur `contracts` / `auth-service` / `platform-api`
  (réservé à `/new-module`).
- Ne jamais écrire de fichiers avant validation de la synthèse.
- **Ne pas** créer `.cursor/rules/design-mode.mdc` — l’enforcement est la règle
  org `RULE-GLOBAL-DESIGN-MODE` + le flag YAML.

## Livrables après validation

| Livrable | Rôle |
|---|---|
| `frontend-web/` | Structure UI minimale (vues / routes), sans logique métier réelle |
| `docs/module.yaml` | Contrat avec **`design_mode: frontend_only`** + routes UI |
| `docs/ux-design.md` | Parcours, écrans, états, composants, décisions design |
| `README.md` | Objectif, acteurs, comment itérer en design mode |
| `.cursor/rules/module-boundary.mdc` | Objectif produit + rappel du flag (pas un second design-mode) |

Pas de `backend/`, pas de Helm, pas de scopes dans `auth-service`.

## Workflow

```
- [ ] Phase 0 — Prérequis
- [ ] Phase 1 — Compréhension métier / usage
- [ ] Phase 2 — Questions design UI/UX
- [ ] Phase 3 — Inspection design system (légère)
- [ ] Phase 4 — Proposition UX + structure front
- [ ] Phase 5 — Synthèse + validation
- [ ] Phase 6 — Génération
- [ ] Phase 7 — Contrôles
```

---

## Phase 0 — Prérequis

Confirmer :

1. Objectif = **maquettes / parcours UI** pour un module New Age (pas full-stack).
2. Nom métier ; proposer `module_id` snake_case.
3. Chemin du dépôt cible (ne pas créer de repo distant sans demande explicite).
4. Si le besoin est clairement backend + front dès J1 → rediriger vers **`/new-module`**.

---

## Phase 1 — Compréhension métier / usage

Sans jargon technique :

- problème et résultat attendu ;
- acteurs et jobs-to-be-done ;
- parcours principaux (happy path + erreurs visibles) ;
- informations affichées / saisies (vocabulaire métier) ;
- périmètre IN / OUT ;
- contraintes : mobile, offline, accessibilité, multilingue, délais.

Réutiliser le prompt ; ne pas questionner en masse.

---

## Phase 2 — Questions design UI/UX

Uniquement les ambiguïtés design / produit :

- densité d’information (dashboard vs flux guidé) ;
- navigation (sidebar, steps, modales) ;
- hiérarchie visuelle et priorités d’écran ;
- états vides / chargement / erreur / succès ;
- ton (pro, retail, support…) et contraintes marque ;
- références (module existant, maquette Figma, capture) ;
- ce qui doit être **cliquable** en prototype vs purement illustratif.

Ne pas demander : stack backend, scopes, schéma BDD, endpoints.

---

## Phase 3 — Inspection design system (légère)

1. **`deesplay`** — primitives `Deepi*` réutilisables (ne pas inventer une lib parallèle).
2. Un **`frontend-web/`** d’un module **nommé dans le prompt** — patterns de routes / layout.
3. **RULE-GLOBAL-MODULE-LAYOUT** — référence `deepivoice/frontend-web` (AppShell + `HomeView` `.stage`).
4. Ne pas scanner tous les modules « au cas où ».

---

## Phase 4 — Proposition

Produire une recommandation :

1. **Carte des écrans** — paths, but, acteurs.
2. **Parcours** — enchaînements et états visibles.
3. **Composants** — `Deepi*` vs vues métier locales.
4. **Données UI** — mocks locaux ; `api_groups` marqués mock / à venir.
5. **Hors design mode** — ce que le backend devra porter plus tard (liste courte, non implémentée).

---

## Phase 5 — Synthèse et validation

```markdown
## Récap design module — [module_id]

**Objectif :** …
**Acteurs / parcours :** …
**Écrans :** …
**Dans / hors périmètre design :** …

### design_mode
- `frontend_only` (RULE-GLOBAL-DESIGN-MODE)

### Génération proposée
- frontend-web/ (structure minimale)
- docs/module.yaml (design_mode: frontend_only)
- docs/ux-design.md
- README.md
- .cursor/rules/module-boundary.mdc

### Plus tard (hors scope)
- backend, auth scopes, Helm, intégration play…
```

Demander :

_« Valides-tu ce récap UX ? Je génère le front et le contrat en design_mode. »_

---

## Phase 6 — Génération

Après validation seulement.

### 6.1 Structure

```text
{module-repo}/
├── .cursor/rules/module-boundary.mdc
├── docs/
│   ├── module.yaml
│   └── ux-design.md
├── frontend-web/
│   └── … (structure minimale Vue/TS alignée stack New Age)
└── README.md
```

**Ne pas** créer `backend/`.

Fichiers structurants OK ; pas de logique métier fictive lourde. Mocks UI
explicites (fixtures / stubs) autorisés pour rendre les écrans navigables.

### 6.2 `docs/module.yaml`

1. Partir de `contracts/docs/module-contract.TEMPLATE.yaml`.
2. **Obligatoire** en tête (après `schema_version` / identité) :

```yaml
design_mode: frontend_only
```

3. Remplir `capability`, routes `frontend` avec `path`, `purpose`, `actors`,
   `api_groups`, `source`.
4. `current_state.backend` : absent, vide, ou clairement « not started » —
   ne pas inventer de `route_groups` implémentés.
5. Distinguer `current_state` (prototype UI) et `target_state` (module complet).

### 6.3 `docs/ux-design.md`

Inclure : objectifs, acteurs, parcours, inventaire d’écrans, états UI,
composants Deepi*, décisions ouvertes, critères de « design done ».

### 6.4 README + boundary

- README : comment ouvrir le front, rappel `design_mode: frontend_only`, lien
  vers `ux-design.md` et sortie de mode (null + `/new-module`).
- `module-boundary.mdc` (`alwaysApply: true`) : objectif produit, chemin
  `frontend-web/`, **rappel** que `design_mode` dans `docs/module.yaml` gouverne
  le focus front (ne pas dupliquer toute la règle org).

---

## Phase 7 — Contrôles

- [ ] `design_mode: frontend_only` présent dans `docs/module.yaml`.
- [ ] Aucun `backend/` généré.
- [ ] Aucun `.cursor/rules/design-mode.mdc`.
- [ ] Routes UI documentées ; api_groups mock / à venir si besoin.
- [ ] `ux-design.md` rédigé.
- [ ] Pas de scopes auth-service / Helm / secrets.

## Sortie du design mode (plus tard)

Quand le produit valide le design et que la tech démarre :

1. Passer `design_mode` à `null` (ou supprimer le champ) dans `docs/module.yaml`.
2. Lancer **`/new-module`** (ou implémentation guidée) pour le backend et le reste.
3. Mettre à jour `current_state` / `target_state` honnêtement.

## Anti-patterns

- ❌ Générer un backend « pour plus tard » pendant design mode
- ❌ Créer une règle locale `design-mode.mdc` à la place du flag YAML
- ❌ Scanner auth/platform en profondeur
- ❌ Inventer une lib UI hors Deesplay
- ❌ Feature folder playdoo par défaut
- ❌ Présenter le prototype comme module livré
