---
name: new-project
description: >-
  Discovery workflow for a standalone project (problem, users, workflows, scope),
  then technical perimeter (API + fronts: player, web, mobile). Generates
  project-context and README. If the target is a New Age business module, redirect
  to /new-module. Use when starting a greenfield project or invoking /new-project.
disable-model-invocation: true
---

# New Project

Skill **autonome et agnostique** : comprendre un projet (métier) puis définir son
périmètre technique (API + fronts).

Ne présuppose ni le domaine ni le contenu du repository cible. Les conventions de
stack relèvent des règles du repo (`.cursor/rules/`) — la skill ne les duplique pas.

## Branche New Age (obligatoire en ouverture)

Avant Phase 1, demander :

> Ce travail est-il un **module métier New Age** (écosystème `contracts` /
> `auth-service` / `platform-api`) ?

| Réponse | Action |
|---|---|
| Oui | Arrêter cette skill et exécuter **`new-module`** |
| Non / projet autonome hors New Age | Continuer ici |

Ne pas inventer un `docs/module.yaml` New Age depuis cette skill.

## Principe directeur

**Phases 1–2 — langage métier uniquement :**

- ✅ « Les opérateurs doivent-ils voir les changements immédiatement ? »
- ✅ « Qui peut modifier les paramètres ? Qui peut seulement consulter ? »
- ❌ Stack, protocoles, frameworks, hébergement, auth technique

**Phase 3 — choix de périmètre technique :**

- ✅ API backend seule ou API + un ou plusieurs fronts
- ✅ Player, backoffice web, app mobile — seuls ou combinés
- ❌ Détail d'implémentation (librairies, patterns, déploiement)

## Livrables

| Fichier | Rôle |
|---|---|
| `.cursor/rules/project-context.mdc` | Contexte IA — métier, périmètre |
| `README.md` | Présentation humaine du projet |

Ne génère **rien d'autre** (pas de code, pas de `.env.example`, pas de règles stack).

## Workflow

```
- [ ] Branche New Age ? → sinon continuer
- [ ] Phase 1 — Compréhension métier
- [ ] Phase 2 — Approfondissement métier (conditionnel)
- [ ] Phase 3 — Périmètre technique (API + fronts)
- [ ] Phase 4 — Synthèse + validation
- [ ] Phase 5 — Génération
```

Ne jamais générer de fichiers avant validation Phase 4.

---

## Phase 1 — Compréhension métier

Détail : [questionnaire-metier.md](questionnaire-metier.md).

### Projet

1. **Nom du projet**
2. **Quel problème résout-il ?** — situation actuelle vs souhaitée
3. **Pour qui ?** — profils, contexte d'usage
4. **Pourquoi maintenant ?** — urgence, opportunité, contrainte

### Usage (sans choix technique)

5. **Comment les gens interagissent-ils avec le système ?** — sans nommer de techno ni de type de client
6. **Qui fait quoi ?** — rôles métier

### Domaine

7. **Quelles « choses » sont manipulées ?** — vocabulaire métier
8. **Parcours principaux** — 3–5 étapes chacun
9. **D'où viennent les données ?**

### Contraintes et périmètre

10. **Contraintes d'usage**
11. **Contraintes organisationnelles**
12. **Hors périmètre métier**

Si réponses floues, reformuler avant Phase 2.

---

## Phase 2 — Approfondissement métier

Conditionnel — [questionnaire-metier.md](questionnaire-metier.md).

Creuser selon Phase 1 : affichage, gestion, mobilité, matrice fonctionnalité × profil,
données sans UI, droits, systèmes existants, fraîcheur des données.

---

## Phase 3 — Périmètre technique (API + fronts)

Détail : [questionnaire-architecture.md](questionnaire-architecture.md).

| Composant | Dossier | Rôle |
|---|---|---|
| API backend | `backend/` | Logique métier, persistance, HTTP |
| Player | `frontend/` | Affichage embarqué, iframe, écrans |
| Backoffice web | `frontend-web/` | Administration, gestion |
| App mobile | `mobile-app/` | iOS / Android |

Proposer une recommandation argumentée, puis valider.

---

## Phase 4 — Synthèse

Récap métier + périmètre. Attendre validation explicite.

_« Valides-tu ce récap ? Je génère les fichiers. »_

---

## Phase 5 — Génération

Répertoire cible indiqué par l'utilisateur.

- `project-context.mdc` ← [templates/project-context.mdc.template](templates/project-context.mdc.template)
- `README.md` ← [templates/README.template.md](templates/README.template.md)

## Contrôles finaux

- [ ] Branche New Age traitée (redirigé ou confirmé hors New Age)
- [ ] Phases 1–2 sans jargon technique
- [ ] Phase 3 validée
- [ ] `project-context.mdc` avec `alwaysApply: true`
- [ ] Hors périmètre documenté
- [ ] Cohérence README ↔ project-context
