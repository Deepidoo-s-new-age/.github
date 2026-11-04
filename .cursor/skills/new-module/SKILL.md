---
name: new-module
description: >-
  Product-first discovery and technical-design workflow for a New Age business
  module. Understands the requested capability, inspects the New Age foundations,
  proposes architecture and generates a minimal repository skeleton, README,
  docs/module.yaml and docs/technical-design.md. Use when creating a New Age
  module or invoking /new-module. Not for generic greenfield.
disable-model-invocation: true
---

# New Module (New Age)

Créer un **module métier New Age** à partir d'une description fonctionnelle.

La personne décrit le besoin, les utilisateurs et les parcours. **La skill porte
l'analyse technique** : dépendances, propriété des données, réutilisation de la
plateforme, API, frontend, autorisation et architecture.

Cette skill n'est pas un greenfield générique. Pour un projet hors New Age,
basculer sur **`new-project`**.

## Principes

- Commencer en langage métier. Ne pas demander à l'utilisateur de concevoir la
  base de données, les routes, les scopes ou les appels inter-services.
- Poser uniquement les questions nécessaires pour comprendre le produit ou
  départager un choix métier réel.
- Inspecter obligatoirement les fondations dans cet ordre :
  `contracts` → `auth-service` → `platform-api`.
- Inspecter un autre module uniquement s'il est explicitement cité dans le
  prompt initial. Sinon, ne pas parcourir tous les modules ; signaler seulement
  les dépendances candidates dans la synthèse.
- Par défaut, l'identité utilisateur vient de `auth-service`.
- Toute donnée possédée par `platform-api` doit être consommée via son API. Ne
  jamais la recopier comme donnée maîtresse du module ni accéder à sa base.
- Les décisions techniques et leurs justifications vont dans
  `docs/technical-design.md`.
- `docs/module.yaml` reste le contrat machine synthétique et doit suivre
  `contracts/docs/module-contract.TEMPLATE.yaml`.

## Livrables après validation

| Livrable | Rôle |
|---|---|
| Structure minimale du dépôt | Dossiers et fichiers structurants, sans logique métier |
| `README.md` | Présentation humaine, démarrage et liens |
| `docs/module.yaml` | Contrat machine rempli depuis le template de `contracts` |
| `docs/technical-design.md` | Analyse technique et plan d'implémentation |
| `.cursor/rules/module-boundary.mdc` | Frontières persistantes du module |

Ne pas générer de logique métier, de déploiement Helm, de migration réelle, de
scopes dans `auth-service` ou d'intégration dans un autre dépôt sans demande
explicite.

## Workflow

```
- [ ] Phase 0 — Prérequis New Age
- [ ] Phase 1 — Compréhension métier
- [ ] Phase 2 — Questions d'approfondissement
- [ ] Phase 3 — Inspection obligatoire de l'écosystème
- [ ] Phase 4 — Conception technique par la skill
- [ ] Phase 5 — Synthèse + validation explicite
- [ ] Phase 6 — Génération du dépôt minimal et des documents
- [ ] Phase 7 — Contrôles
```

Ne jamais écrire de fichiers avant validation de la Phase 5.

---

## Phase 0 — Prérequis

Confirmer :

1. Il s'agit d'un **module métier New Age**, pas d'une fondation ou d'un package UI.
2. Si l'objectif est **uniquement maquettes / parcours UI** (pas de backend pour
   l'instant) → arrêter et exécuter **`design-module`** à la place.
3. Le nom métier du module. Proposer le `module_id` snake_case ; ne pas exiger que
   l'utilisateur le fournisse.
4. Le chemin du dépôt cible, ou proposer un nom sans créer de nouveau dépôt avant
   approbation explicite.
5. Les dépôts `contracts`, `auth-service` et `platform-api` sont accessibles.

Avant de modifier un module existant, lire son `docs/module.yaml`.

---

## Phase 1 — Compréhension métier

Faire décrire, sans jargon technique :

- le problème actuel et le résultat attendu ;
- les personnes concernées et ce qu'elles cherchent à accomplir ;
- les principaux parcours ;
- les informations manipulées dans le vocabulaire métier ;
- l'origine connue de ces informations ;
- le périmètre attendu et ce qui en est exclu ;
- les contraintes importantes : volume, délai, confidentialité, usage hors ligne,
  import/export ou systèmes existants.

Réutiliser toute information déjà donnée. Ne pas dérouler un questionnaire
exhaustif si le prompt est suffisant.

---

## Phase 2 — Questions d'approfondissement

Poser des questions adaptatives uniquement sur les ambiguïtés fonctionnelles :

- qui crée, consulte, modifie, valide ou supprime quoi ;
- règles et exceptions métier ;
- déroulement des parcours et états visibles ;
- fréquence, fraîcheur et volume attendus ;
- résultat minimal permettant de considérer le module utile.

Ne pas demander :

- « quelles données le module possède-t-il ? » ;
- les tables, DTO, routes, méthodes HTTP ou préfixes ;
- les scopes, JWT, M2M ou choix de framework ;
- quel service technique doit fournir une donnée.

Ces réponses relèvent des Phases 3 et 4.

---

## Phase 3 — Inspection obligatoire de l'écosystème

Inspecter le code et la documentation dans l'ordre suivant.

### 3.1 `contracts`

- contrats core/auth réutilisables ;
- types d'identifiants, pagination et erreurs ;
- validation JWT utilisateur et dépendances FastAPI disponibles ;
- template `docs/module-contract.TEMPLATE.yaml`.

### 3.2 `auth-service`

- flux d'identité utilisateur existants ;
- scopes actuels et rôles pertinents ;
- support d'identité module/M2M si le besoin l'exige ;
- contraintes d'intégration réellement implémentées.

Supposer que les utilisateurs viennent de `auth-service`, sauf exigence contraire
explicitement donnée. Ne proposer aucun second système d'identité.

### 3.3 `platform-api`

- domaines, routes `/v1`, schémas et opérations déjà disponibles ;
- données core utiles au module ;
- scopes et modes d'appel requis ;
- manques éventuels entre le besoin métier et l'API existante.

Toute donnée core existante doit rester propriété de `platform-api` et être
consommée via HTTP avec un identifiant stable. Si `platform-api` ne fournit pas
encore l'opération nécessaire, documenter une évolution proposée de
`platform-api` ; ne pas contourner par SQL ni dupliquer la donnée maîtresse.

### 3.4 Autre module explicitement cité

Uniquement si le prompt initial nomme un autre module :

1. lire son `docs/module.yaml` ;
2. vérifier ses APIs et données possédées ;
3. documenter l'appel HTTP et les identifiants stables nécessaires.

Si aucun autre module n'est cité, ne pas explorer les modules existants. Une
dépendance potentielle peut être proposée, clairement marquée « à confirmer ».

---

## Phase 4 — Conception technique par la skill

À partir du besoin métier et de l'inspection, produire une recommandation. La
skill décide et explique :

1. **Frontières**
   - données possédées par le module ;
   - références UUID vers auth/core/autres modules ;
   - données lues depuis `platform-api` et contrats réutilisés ;
   - accès interdits et absence de FK SQL inter-services.
2. **Architecture**
   - backend, frontend de production éventuel, stockage et clients HTTP ;
   - structure `api → services → repositories`, appels sortants dans `clients` ;
   - choix entre `frontend-web/`, API seule ou intégration `play` ultérieure.
3. **Surface**
   - groupes API avec `prefix`, `purpose`, `actors`, `access`, `source` et
     `downstream` si nécessaire ;
   - routes UI avec `path`, `purpose`, `actors`, `api_groups` et `source` ;
   - pagination des listes et comportements d'erreur importants.
4. **Identité et autorisation**
   - JWT utilisateur via `auth-service` et validation via `deepidoo-contracts` ;
   - scopes actuels proposés, rôles et besoins M2M ;
   - cas autorisés et interdits à tester.
5. **Plan**
   - étapes d'implémentation ordonnées ;
   - évolutions requises dans un dépôt fondation, avec blast radius explicite ;
   - risques, hypothèses et questions restantes ;
   - stratégie de tests et critères d'acceptation.

Ne demander une décision technique à l'utilisateur que si plusieurs options ont
un impact produit réel ou si une hypothèse ne peut pas être vérifiée dans les
dépôts. Sinon, recommander et justifier.

---

## Phase 5 — Synthèse et validation

```markdown
## Récap module — [module_id]

**Objectif :** …
**Utilisateurs et parcours :** …
**Dans / hors périmètre :** …

### Réutilisation New Age
- contracts : …
- auth-service : …
- platform-api : …
- autre module explicitement cité : …

### Recommandation technique
- données module / références plateforme : …
- API / frontend : …
- identité / autorisation : …
- évolutions externes requises : …

### Génération proposée
- arborescence minimale : …
- README.md
- docs/module.yaml
- docs/technical-design.md
- .cursor/rules/module-boundary.mdc

### Hypothèses / risques
- …
```

Demander explicitement :

_« Valides-tu ce récap et cette architecture ? Je génère le squelette minimal et
les documents. »_

---

## Phase 6 — Génération

Après validation seulement :

### 6.1 Structure minimale

Créer uniquement les dossiers retenus et leurs fichiers structurants minimaux.
Par défaut :

```text
{module-repo}/
├── .cursor/rules/module-boundary.mdc
├── docs/
│   ├── module.yaml
│   └── technical-design.md
├── backend/
│   ├── app/
│   │   ├── api/
│   │   ├── clients/
│   │   ├── repositories/
│   │   └── services/
│   └── tests/
└── README.md
```

Ajouter `frontend-web/` uniquement si la recommandation validée retient un
frontend propre au module. Adapter l'arborescence au besoin réel.

Les fichiers doivent rendre la structure versionnable et explicite, mais ne
doivent contenir aucune logique métier fictive. Ne pas produire un scaffold
exécutable FastAPI/Vue à cette étape.

### 6.2 `docs/module.yaml`

1. Copier le template contracts → `{module}/docs/module.yaml` et remplir.
2. Chaque groupe API doit déclarer `prefix`, `purpose`, `actors`, `access`,
   `source` et `downstream` si nécessaire.
3. Chaque route frontend doit déclarer `path`, `purpose`, `actors`,
   `api_groups` et `source`.
4. Distinguer honnêtement `current_state` et `target_state` lorsque
   l'implémentation n'existe pas encore. Un nouveau squelette n'est pas une
   fonctionnalité livrée.

Ne pas stocker le contrat rempli dans `contracts`.

### 6.3 `docs/technical-design.md`

Inclure :

1. contexte, objectifs, non-objectifs et parcours ;
2. constat de l'inspection `contracts` → `auth-service` → `platform-api` ;
3. matrice des données :
   - donnée/agrégat ;
   - propriétaire ;
   - source/API ;
   - stockage local éventuel ;
   - identifiant de référence ;
   - règles de synchronisation ou de cache ;
4. architecture et responsabilités des dossiers ;
5. groupes API et routes UI proposés ;
6. flux d'identité, scopes, rôles et M2M ;
7. dépendances sortantes, timeouts et erreurs typées ;
8. étapes d'implémentation ;
9. tests, critères d'acceptation, risques et décisions ouvertes.

La propriété des données est décidée ici par analyse :

- identité et données utilisateur → `auth-service`, sauf preuve contraire ;
- données core existantes → `platform-api` via HTTP ;
- données spécifiques à la capacité → module ;
- contrat transversal stable → candidat `contracts`, avec changement versionné.

### 6.4 README et règle

- `README.md` : objectif, utilisateurs, architecture résumée, structure,
  dépendances New Age et liens vers les deux documents.
- `module-boundary.mdc` (`alwaysApply: true`) : objectif, données possédées,
  données référencées, dépendances autorisées, interdits, scopes et rôle du
  frontend.

---

## Phase 7 — Contrôles

- [ ] Questions initiales formulées en langage métier.
- [ ] Inspection effectuée dans l'ordre `contracts` → `auth-service` → `platform-api`.
- [ ] Aucun autre module inspecté sans mention explicite dans le prompt initial.
- [ ] Données auth attribuées à `auth-service` par défaut.
- [ ] Données core consommées via `platform-api`, sans duplication maîtresse.
- [ ] `module.yaml` conforme au template et honnête sur l'état courant.
- [ ] `technical-design.md` contient propriété, réutilisation, architecture et plan.
- [ ] Structure minimale cohérente avec la recommandation validée.
- [ ] Aucun secret, code métier fictif, Helm ou permission externe généré.

## Suite optionnelle

- [ ] Créer le repo Git + clone workspace
- [ ] Enregistrer scopes / module identity dans `auth-service`
- [ ] Implémenter le backend selon `docs/technical-design.md`
- [ ] Implémenter `frontend-web/` si retenu
- [ ] Dépendance `deepidoo-contracts[auth,fastapi]`
- [ ] Entrée Helm si déploiement New Age
- [ ] Intégration `play` si elle a été validée

## Anti-patterns

- ❌ Demander à l'utilisateur de définir tables, routes ou ownership
- ❌ Sauter l'inspection des trois fondations New Age
- ❌ Scanner tous les modules « au cas où »
- ❌ Copier localement une donnée maîtresse de `platform-api`
- ❌ Créer un second système d'identité utilisateur
- ❌ Feature folder dans playdoo par défaut
- ❌ Contrat rempli dans `contracts`
- ❌ Scopes inventés sans passage auth-service
- ❌ Générer du code métier avant validation
- ❌ Présenter la cible comme déjà implémentée
