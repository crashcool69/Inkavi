# 🗺️ Roadmap Inkavi

## ✅ Fonctionnalités actuellement en place

### 🔐 Authentification & Connexion
- ✅ **Configuration OPDS simplifiée** — URL OPDS unique extrait automatiquement serveur + API Key
- ✅ **Liste des serveurs enregistrés** — tuiles interactives avec badge "Par défaut" animé
- ✅ **Modal d'aide intégré** — guide étape par étape pour obtenir l'URL OPDS depuis Kavita
- ✅ **Thème sombre par défaut** — démarrage en dark mode, toggle utilisateur disponible
- ✅ Login via API Key
- ✅ Login via compte utilisateur (identifiant/mot de passe)
- ✅ JWT Token automatique
- ✅ Stockage sécurisé des credentials (Keychain/Keystore)
- ✅ Validation de connexion serveur

### 📚 Gestion des bibliothèques
- ✅ Affichage de toutes les bibliothèques
- ✅ Scroll horizontal des bibliothèques (carrousel)
- ✅ Icônes par type (Manga, Comic, Book)
- ✅ Filtrage par bibliothèque

### 📖 Lecture de séries
- ✅ Liste des séries par bibliothèque
- ✅ Détails d'une série (cover, description, métadonnées)
- ✅ Affichage des volumes et chapitres
- ✅ Lecteur d'images page par page (CBZ/CBR/PDF/Images)
- ✅ **Lecteur EPUB natif** — streaming direct depuis le serveur Kavita via WebView (`EpubReaderScreen`)
- ✅ **Routage automatique format** — détection format 3 = EPUB → `EpubReaderScreen`, sinon → `ReaderScreen`
- ✅ **URL EPUB dynamique** — construction `library-agnostic` (JWT, seriesId, volumeId, chapterId, startPage)
- ✅ **Zoom sur les pages** (pinch & double-tap)
- ✅ Mode plein écran avec tap pour sortir
- ✅ Navigation par tap (gauche/centre/droite)
- ✅ Modes de lecture : LTR, RTL, Vertical
- ✅ Filtres de couleur (Sepia, Night mode)
- ✅ Réglage luminosité

### 📊 Progression & Statistiques
- ✅ Sauvegarde automatique de la progression
- ✅ "Continuer la lecture" sur la page d'accueil
- ✅ Marquer comme lu/non lu (chapitre & série)
- ✅ Statistiques utilisateur (pages lues, temps de lecture)
- ✅ Historique de lecture
- ✅ **Pagination intelligente** (chargement par lots de 50)
- ✅ **Scroll infini** avec chargement automatique

### ⭐ Collections & Favoris
- ✅ Liste "À lire plus tard" (Want to Read)
- ✅ Notation des séries (1-5 étoiles)
- ✅ Affichage des séries en cours

### 🎨 Interface & Design
- ✅ Design Material Design 3
- ✅ Mode clair/sombre adaptatif
- ✅ Navigation fluide entre écrans
- ✅ **Hero animations** sur les covers de séries
- ✅ **Animations stagger** (apparition progressive des listes)
- ✅ Animations de scale sur les interactions
- ✅ Préchargement des images
- ✅ Cache des images pour performances
- ✅ Gestion des erreurs réseau

### 🌐 Multilingue
- ✅ Support français
- ✅ Support anglais
- ✅ Détection automatique de la langue système

---

## 📊 Endpoints Kavita API actuellement utilisés

### 🔐 Authentification
- ✅ `POST /api/Plugin/authenticate` - Obtenir JWT token
- ✅ `GET /api/Plugin/authkey-expires` - Valider connexion
- ✅ `POST /api/Account/login` - Login utilisateur

### 📚 Bibliothèques & Séries
- ✅ `GET /api/Library/libraries` - Liste bibliothèques
- ✅ `POST /api/series/v2` - Liste séries (avec filtres)
- ✅ `GET /api/Series/{id}` - Détails série
- ✅ `GET /api/Series/volumes?seriesId={id}` - Volumes/chapitres

### 📖 Lecture
- ✅ `GET /api/Reader/image?chapterId={id}&page={page}` - Images pages
- ✅ `POST /api/Reader/progress` - Sauvegarder progression
- ✅ `POST /api/Reader/mark-unread` - Marquer non lu

### ⭐ Collections & Favoris
- ✅ `POST /api/want-to-read/add-series/{id}` - Ajouter "À lire"
- ✅ `DELETE /api/want-to-read/{id}` - Retirer "À lire"
- ✅ `GET /api/want-to-read` - Liste "À lire"
- ✅ `POST /api/Series/{id}/rating` - Noter série

### 📊 Statistiques
- ✅ `GET /api/Stats/user` - Stats utilisateur

### 🖼️ Images
- ✅ `/api/image/series-cover?seriesId={id}` - Cover série
- ✅ `/api/image/chapter-cover?chapterId={id}` - Cover chapitre

---

## 🚀 Évolutions à venir

### 1. 📋 Collections personnalisées
**API** : `/api/Collection/*`

**Fonctionnalités** :
- Créer/éditer/supprimer des collections personnalisées
- Ajouter/retirer des séries d'une collection
- Afficher les collections sur la page d'accueil
- Icônes et couleurs personnalisables

**Priorité** : Moyenne

---

### 2. 🔍 Recherche avancée
**API** : `/api/Search/*`

**Fonctionnalités** :
- Recherche globale (séries, auteurs, genres, tags)
- Filtres avancés (type, statut, année, langue)
- Suggestions de recherche en temps réel
- Historique de recherche

**Priorité** : Haute

---

### 3. 👤 Gestion du profil
**API** : `/api/Users/*`, `/api/Account/*`

**Fonctionnalités** :
- Modifier les préférences utilisateur
- Changer le mot de passe
- Gérer l'avatar
- Paramètres de confidentialité

**Priorité** : Basse

---

### 4. 📚 Listes de lecture
**API** : `/api/ReadingList/*`

**Fonctionnalités** :
- Créer des listes de lecture personnalisées
- Partager des listes avec d'autres utilisateurs
- Suivre la progression d'une liste
- Réorganiser l'ordre des séries

**Priorité** : Haute

---

### 5. 🏷️ Tags & Métadonnées enrichies
**API** : `/api/Metadata/*`, `/api/Series/metadata`

**Fonctionnalités** :
- Afficher les genres, auteurs, tags détaillés
- Filtrer par métadonnées
- Éditer les métadonnées (admin)
- Vue par genre/auteur

**Priorité** : Moyenne

---

### 6. 📊 Statistiques avancées
**API** : `/api/Stats/*`

**Fonctionnalités** :
- Graphiques de lecture par jour/mois/année
- Top séries les plus lues
- Temps de lecture par genre
- Objectifs de lecture
- Streaks (jours consécutifs de lecture)

**Priorité** : Moyenne

---

### 7. 🔔 Notifications & Annonces
**API** : `/api/Server/announcements`

**Fonctionnalités** :
- Notifications de nouvelles séries ajoutées
- Alertes de nouveaux chapitres pour les séries favorites
- Annonces du serveur
- Notifications push (optionnel)

**Priorité** : Basse

---

### 8. 📥 Téléchargement hors ligne
**API** : `/api/Download/*`

**Fonctionnalités** :
- Télécharger des chapitres pour lecture hors ligne
- Gestion du stockage (limite, suppression auto)
- Synchronisation automatique
- Indicateur de chapitres téléchargés

**Priorité** : Haute

---

### 9. 🌐 Multi-serveurs
**API** : Gestion locale

**Fonctionnalités** :
- Gérer plusieurs serveurs Kavita
- Basculer facilement entre serveurs
- Synchronisation multi-serveurs
- Comptes séparés par serveur

**Priorité** : Basse

---

### 10. 🎨 Thèmes personnalisables
**API** : Gestion locale

**Fonctionnalités** :
- Thèmes clair/sombre/auto
- Couleurs d'accentuation personnalisables
- Fonds d'écran personnalisés
- Mode AMOLED (noir pur)

**Priorité** : Moyenne

---

## 🐛 Bugs connus & Améliorations

### Corrections en cours
- 🐛 **Lecteur EPUB** — problèmes de lecture des fichiers EPUB (format 3), investigations en cours
- ✅ Zoom lecteur fonctionnel (PhotoViewGallery)
- ✅ Noms de bibliothèques affichés en entier (scroll horizontal)
- ✅ Retour du mode plein écran (tap pour sortir)

### ✅ Optimisations récemment complétées
- ✅ Performance sur les grandes bibliothèques (pagination par 50 séries)
- ✅ Mise en cache des images améliorée (limite 500 MB, nettoyage LRU)
- ✅ Gestion erreurs réseau robuste (retry automatique x3 avec backoff)
- ✅ **Mode immersif complet** (barres système cachées automatiquement)
- ✅ **Contraste SnackBar amélioré** (notifications visibles en mode clair et sombre)
- ✅ **Affichage dynamique de la version** (lecture automatique depuis pubspec.yaml)
- ✅ **Thème clair Inkavi** — fond blanc pur, couleurs d'accent rose/violet/cyan issues du logo
- ✅ **Tuiles séries redesignées** — gradient arc-en-ciel doux, ombres colorées, coins arrondis uniformes
- ✅ **Hero tags uniques** — correctif crash duplication d'animations Hero (`heroSuffix` par contexte)
- ✅ **Fiche série — boutons Favoris & À lire** — glassmorphism avec gloss et dégradé actif/inactif
- ✅ **Fiche série — tuile Progression** — carte blanche avec ligne d'accent gradient 3 px
- ✅ **Fiche série — tuile Temps de lecture** — même style que Progression avec palette cyan/bleu
- ✅ **Refactoring series_detail_screen** — fichier 2 456 lignes découpé en 5 sous-widgets modulaires (`SeriesProgressTile`, `SeriesReadingTimeTile`, `SeriesActionButtons`, `SeriesSynopsis`, `SeriesVolumesSection`)

---

## 📅 Planning prévisionnel

**Q1 2026** (Janvier - Mars)
- Recherche avancée
- Listes de lecture
- Téléchargement hors ligne

**Q2 2026** (Avril - Juin)
- Collections personnalisées
- Tags & Métadonnées enrichies
- Statistiques avancées

**Q3 2026** (Juillet - Septembre)
- Thèmes personnalisables
- Notifications
- Optimisations performances

**Q4 2026** (Octobre - Décembre)
- Multi-serveurs
- Gestion profil avancée
- Fonctionnalités communautaires

---

## 🤝 Contributions

Les suggestions et contributions sont les bienvenues ! Ouvrez une issue sur GitHub pour proposer de nouvelles fonctionnalités ou signaler des bugs.

**Ressources** :
- [Kavita API Documentation](https://www.kavitareader.com/docs/api/)
- [Kavita OpenAPI Spec](https://raw.githubusercontent.com/Kareadita/Kavita/develop/openapi.json)
- [Kavita Wiki](https://wiki.kavitareader.com/)
