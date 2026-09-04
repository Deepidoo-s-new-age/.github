# Questionnaire architecture — new-project

Phase 3 uniquement. À mener **après** la compréhension métier (Phases 1–2).

Objectif : traduire les usages identifiés en **périmètre technique** —
API backend et un ou plusieurs fronts — sans entrer dans l'implémentation.

---

## Principe

1. **Reformuler** les usages métier en langage utilisateur
2. **Proposer** une combinaison API + fronts cohérente
3. **Valider** avec l'utilisateur avant la synthèse

Les choix disponibles dépendent des règles du repository cible. Périmètre
standard :

| Composant | Dossier | Quand le retenir |
|---|---|---|
| API backend | `backend/` | Toujours sauf extension sans API |
| Player | `frontend/` | Affichage embarqué, écrans dédiés, widgets iframe |
| Backoffice web | `frontend-web/` | Administration, gestion, configuration |
| App mobile | `mobile-app/` | Usage mobile terrain, iOS / Android |

---

## Questions obligatoires

### 1. API backend

- Une **API backend** est-elle nécessaire dans ce repository ?
- Un **client externe** consommera-t-il l'API sans front dans ce repo ?
- Y a-t-il des **données ou règles métier** à centraliser côté serveur ?

### 2. Fronts à inclure

Pour chaque option, **Oui / Non** puis justification métier :

| Front | Retenu ? | Rôle métier | Profils concernés |
|---|---|---|---|
| Player (`frontend/`) | | | |
| Backoffice web (`frontend-web/`) | | | |
| App mobile (`mobile-app/`) | | | |

Cas fréquents :

- **Player seul** — affichage atelier, écrans muraux, widgets embarqués
- **Web seul** — outil de gestion interne, backoffice
- **Mobile seul** — agents terrain, opérateurs en déplacement
- **Player + web** — affichage + administration
- **Web + mobile** — gestion bureau + actions terrain
- **Les trois** — affichage, admin et mobilité
- **API seule** — pas de front dans ce repo, consommation externe

### 3. Matrice fonctionnalité × front

Compléter pour chaque front **retenu** :

| Fonctionnalité | Player | Web | Mobile | API externe |
|---|---|---|---|---|
| {{FEATURE_1}} | | | | |
| {{FEATURE_2}} | | | | |

Règle : une fonctionnalité = **un front principal**, sauf justification métier
(ex. consultation sur plusieurs surfaces).

### 4. Cohérence

- Chaque front retenu a-t-il un **rôle distinct** ou se chevauche-t-il avec un autre ?
- Un front peut-il être **reporté** (phase 2 du projet) sans bloquer le reste ?
- Le hors périmètre métier exclut-il explicitement un type de front ?

---

## Recommandation agent

Avant validation, présenter :

```markdown
### Recommandation périmètre technique

**API backend :** Oui/Non — [justification]

**Fronts retenus :**
- Player : Oui/Non — [rôle métier]
- Backoffice web : Oui/Non — [rôle métier]
- App mobile : Oui/Non — [rôle métier]

**Combinaison :** [ex. API + player + web]

**Arborescence cible :**
- backend/
- frontend/        (si player)
- frontend-web/    (si web)
- mobile-app/      (si mobile)
```

Demander : _« Ce périmètre te convient-il ? »_

---

## Anti-patterns

- ❌ Choisir un front « par défaut » sans lien avec les usages métier
- ❌ Retenir les trois fronts sans justification distincte pour chacun
- ❌ Mélanger Phase 3 avec des questions d'implémentation (auth technique, librairies…)
- ❌ Générer des dossiers ou du code — la skill ne produit que le contexte documentaire
