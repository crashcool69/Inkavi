# Intégration AniList pour les bibliothèques Manga

## Vue d'ensemble

L'application Inkavi intègre l'API AniList pour enrichir les métadonnées des séries dans les bibliothèques de type **Manga** (libraryType = 0).

## Processus d'intégration

### 1. Détection du type de bibliothèque

Quand un utilisateur ouvre la fiche détail d'une série :
- L'application vérifie le `libraryType` de la série
- Si `libraryType == 0` (Manga/manga/Mangas/mangas) → Activation de l'intégration AniList
- Si autre type (Comic, Book, etc.) → Pas d'appel AniList

**Important** : Pour bénéficier de l'intégration AniList, vous devez créer une bibliothèque de type **Manga**, **manga**, **Mangas** ou **mangas** sur votre serveur Kavita et y ajouter vos séries.

### 2. Recherche sur AniList

L'application envoie une requête GraphQL à l'API AniList avec :
- Le titre de la série (name)
- Le type filtré sur MANGA uniquement

**Requête GraphQL utilisée :**
```graphql
query SearchManga($search: String) {
  Media(search: $search, type: MANGA) {
    id
    title { romaji english native }
    status
    volumes
    chapters
    startDate { year month day }
    endDate { year month day }
  }
}
```

### 3. Récupération des métadonnées

AniList retourne les informations suivantes :

| Champ | Description | Utilisation dans Inkavi |
|-------|-------------|------------------------|
| `status` | État de la série (RELEASING, FINISHED, etc.) | Badge "En cours" / "Terminé" |
| `volumes` | Nombre total de volumes | Calcul des volumes manquants |
| `chapters` | Nombre total de chapitres | Information complémentaire |
| `startDate` / `endDate` | Dates de publication | Potentiellement pour futures fonctionnalités |

### 4. Affichage des informations

#### Badge de statut
- Positionné dans le header de la fiche série
- "En cours" (dégradé cyan/bleu) si `status == RELEASING`
- "Terminé" (dégradé rose/violet) si `status == FINISHED`

#### Volumes manquants
- Comparaison entre volumes existants dans Kavita et `volumes` total AniList
- Affichage de tuiles "fantômes" pour les volumes manquants
- Badge "Manquant" sur ces tuiles

### 5. Conditions d'activation

L'intégration AniList s'active uniquement si :
1. La bibliothèque est de type Manga (`libraryType == 0`)
2. Une correspondance est trouvée sur AniList (titre similaire)
3. L'API AniList est accessible (connexion Internet)

## Limitations connues

- **Pas de dates de sortie** : AniList ne fournit pas de dates précises pour les volumes futurs
- **Correspondance par titre** : La recherche dépend de la similarité des titres entre Kavita et AniList
- **Uniquement Manga** : Pas d'intégration pour les Comics, Books, ou autres types

## Confidentialité

- Aucune donnée utilisateur n'est envoyée à AniList
- Seul le titre de la série est utilisé pour la recherche
- Pas de stockage des données AniList en local
