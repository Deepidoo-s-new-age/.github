# Questionnaire métier — new-project

Questions Phases 1 et 2. Langage accessible, orienté compréhension du projet.
**Ne pas** utiliser de jargon technique ni nommer de type de client (player, web, mobile).

---

## Projet — creuser si nécessaire

- Quelle est la situation **aujourd'hui** sans cet outil ?
- Qu'est-ce qui **ne fonctionne pas** ou coûte du temps / de l'argent ?
- À quoi ressemble le **succès** dans 6 mois ?
- Qui a **demandé** ce projet ? Qui valide qu'il est terminé ?

## Utilisateurs

Pour chaque profil identifié :

- Qui est cette personne ? (métier, pas titre IT)
- Où l'utilise-t-elle ? (poste de travail, ligne de production, déplacement, open space…)
- À quelle fréquence ?
- Quel est son niveau de confort avec l'informatique ?
- Quelle est sa **priorité** : rapidité, fiabilité, simplicité ?

## Usages — affichage / consultation

*(Si des usages de type « voir des informations » ressortent)*

- Que doit **voir** l'utilisateur ?
- L'information change-t-elle **en continu** ou une fois par jour / par shift ?
- Taille ou type d'écran connu ? (petit widget, grand écran mural, téléphone…)
- Que doit-il se passer si les données ne sont plus disponibles ?
- Faut-il une **charte visuelle** imposée (couleurs, logo) ?
- L'accès est-il **ouvert** ou réservé à certains profils ?

## Usages — gestion / configuration

*(Si des usages de type « paramétrer, administrer » ressortent)*

- Qui **configure** le système au quotidien ?
- Quelles informations peut-on **modifier** vs **consulter seulement** ?
- Faut-il un **historique** (« qui a changé quoi, quand ») ?
- Faut-il **exporter** des données (Excel, PDF, rapport) ?
- Combien de personnes concernées au maximum ?

## Usages — mobilité / terrain

*(Si des usages en déplacement ou hors bureau ressortent)*

- Dans quel **contexte physique** (déplacement, entrepôt, extérieur…) ?
- La connexion réseau est-elle **fiable** ou intermittente ?
- Faut-il des **notifications** ou alertes push ?
- Des actions doivent-elles être possibles **sans connexion** ?

## Matrice fonctionnalité × profil

| Fonctionnalité | Profil A | Profil B | Profil C | Contexte |
|---|---|---|---|---|
| Voir les indicateurs | | | | |
| Modifier la configuration | | | | |
| Saisir des valeurs | | | | |
| Exporter / rapporter | | | | |

Règle : une action = **un contexte d'usage principal**, sauf justification métier.
Le mapping vers un front précis se fera en Phase 3.

## Données sans interface directe

- Quel **autre système** consomme les données ?
- À quelle **fréquence** en a-t-il besoin ?
- Que se passe-t-il si les données ne sont **pas disponibles** ?
- Quel niveau de **fiabilité** est exigé ?

## Droits d'accès (langage métier)

| Action | Tout le monde | Profil A | Profil B | Direction |
|---|---|---|---|---|
| Voir les indicateurs | | | | |
| Modifier les paramètres | | | | |
| Valider / verrouiller | | | | |

Questions associées :

- Faut-il une **connexion** (identifiant / mot de passe) ?
- Ou certains usages sont-ils **ouverts** sans connexion ?
- Qui **crée les comptes** ?

## Systèmes existants

Pour chaque système mentionné :

- Comment s'appelle-t-il ? (ERP, MES, Excel, autre)
- Le nouveau projet doit-il **recevoir** des données de ce système, **en envoyer**, ou les deux ?
- Que faire si ce système est **indisponible** ? (attendre, saisie manuelle, alerte…)
- Y a-t-il une **personne référente** côté métier pour ce système ?

## Fréquence et fraîcheur des données

- Les utilisateurs ont-ils besoin de voir les changements **immédiatement** ?
- Ou une mise à jour **toutes les X minutes / heures** suffit ?
- Y a-t-il des **moments critiques** (début de shift, fin de journée) ?

*(Ne pas nommer WebSocket, polling, etc.)*

## Contraintes d'usage

- Langue(s) de l'interface
- Environnement physique (bruit, luminosité, port de gants, froid…)
- Connexion réseau fiable ou parfois coupée ?
- Horaires d'utilisation (24/7, jours ouvrés seulement)

## Contraintes organisationnelles

- Date limite ou jalons imposés ?
- Un ou plusieurs sites / usines / entités ?
- Contraintes imposées par l'IT ou la direction ? *(noter le besoin, pas la solution)*
- Obligations légales ou qualité (traçabilité, archivage…) ?

## Hors périmètre métier

Demander explicitement :

> *« Y a-t-il des choses que ce projet ne doit clairement PAS faire ? »*

Exemples : pas de facturation, pas de multi-langue, pas d'inscription libre,
pas de remplacement d'un système existant.

Documenter dans `project-context.mdc` → section **Hors périmètre**.

*(Ne pas exclure ici un type de front — ce choix relève de la Phase 3.)*
