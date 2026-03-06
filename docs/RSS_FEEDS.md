# Système de Flux RSS - Documentation

## Vue d'ensemble

Inkavi intègre un système de flux RSS configurable permettant aux utilisateurs de consulter les actualités manga, anime, BD et comics directement depuis l'application.

## Flux disponibles par langue

### 🇫🇷 Français (9 flux)

| Flux | Catégorie | URL |
|------|-----------|-----|
| BDGest | Bande dessinée | https://www.bdgest.com/rss |
| Manga News | Manga | https://www.manga-news.com/index.php/feed/news |
| Adala News | Anime | https://adala-news.fr/feed |
| AnimeLand | Anime | https://animeland.fr/feed |
| Planète BD | Bande dessinée | https://www.planetebd.com/planete-bd |
| Planète BD - Manga | Manga | https://www.planetebd.com/planete-bd/manga |
| Actualitté | Livres | https://actualitte.com/rss-main.rss |
| Journaux.fr | Livres | https://api.journaux.fr/rss?filename=tout |
| Jeuxvideo.com | Jeux vidéo | https://www.jeuxvideo.com/rss/rss-news.xml |

### 🇬🇧 English (10 feeds)

| Feed | Category | URL |
|------|----------|-----|
| Anime News Network | Anime | https://www.animenewsnetwork.com/all/rss.xml |
| MyAnimeList | Manga | https://myanimelist.net/rss/news.xml |
| Tokyo Otaku Mode | Anime | https://otakumode.com/news/feed |
| Honey's Anime | Anime | https://honeysanime.com/feed |
| Comic Book Resources | Comics | https://www.cbr.com/feed/ |
| Kotaku Anime | Anime | https://kotaku.com/tag/anime/rss |
| The Guardian Books | Books | https://www.theguardian.com/books/rss |
| Book Riot | Books | https://bookriot.com/feed/ |
| Tor Books | Books | https://www.tor.com/feed/ |
| Standard Ebooks | Books | https://standardebooks.org/feeds/rss/new-releases |

### 🇪🇸 Español (6 fuentes)

| Fuente | Categoría | URL |
|--------|-----------|-----|
| Ramen Para Dos | Manga | https://ramenparados.com/feed |
| Zona Negativa | Cómics | https://www.zonanegativa.com/feed |
| Tomos y Grapas | Cómics | https://www.tomosygrapas.com/feed |
| Lecturalia | Libros | https://feeds.feedburner.com/lecturalia |
| El País Cultura | Libros | https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/section/cultura/portada |
| Locus Magazine | Libros | https://locusmag.com/feed/ |

## Comment activer les flux RSS

### 🇫🇷 Français

1. Ouvrir l'application Inkavi
2. Aller dans **Paramètres** (icône ⚙️ en bas à droite)
3. Section **"Flux d'actualités"**
4. Cliquer sur **"Sélectionner les flux"**
5. Choisir les flux souhaités par langue :
   - 🇫🇷 Français : BDGest, Manga News, Adala News...
   - 🇬🇧 Anglais : Anime News Network, MyAnimeList...
   - 🇪🇸 Espagnol : Ramen Para Dos, Zona Negativa...
6. Les actualités apparaissent sur la page d'accueil dans la section **"Actualités"**

### 🇬🇧 English

1. Open the Inkavi app
2. Go to **Settings** (⚙️ icon at bottom right)
3. **"News Feed"** section
4. Tap **"Select Feeds"**
5. Choose desired feeds by language:
   - 🇫🇷 French: BDGest, Manga News, Adala News...
   - 🇬🇧 English: Anime News Network, MyAnimeList...
   - 🇪🇸 Spanish: Ramen Para Dos, Zona Negativa...
6. News will appear on the home page in the **"News"** section

### 🇪🇸 Español

1. Abrir la aplicación Inkavi
2. Ir a **Ajustes** (icono ⚙️ abajo a la derecha)
3. Sección **"Fuente de noticias"**
4. Tocar **"Seleccionar fuentes"**
5. Elegir las fuentes deseadas por idioma:
   - 🇫🇷 Francés: BDGest, Manga News, Adala News...
   - 🇬🇧 Inglés: Anime News Network, MyAnimeList...
   - 🇪🇸 Español: Ramen Para Dos, Zona Negativa...
6. Las noticias aparecerán en la página de inicio en la sección **"Noticias"**

## Fonctionnalités

- **Sélection multiple** : Activer plusieurs flux simultanément
- **Filtrage par langue** : Organisation claire par drapeau (🇫🇷 🇬🇧 🇪🇸)
- **Catégories visuelles** : Chaque flux a une couleur et icône distincte
- **Mise à jour automatique** : Les articles se rafraîchissent à l'ouverture
- **Lecture externe** : Ouvrir les articles dans le navigateur

## Fichiers techniques

- `lib/core/constants/rss_feeds.dart` - Configuration des flux
- `lib/features/settings/screens/rss_feed_selection_screen.dart` - Écran de sélection
- `lib/providers/rss_feed_provider.dart` - Gestion d'état Riverpod
- `lib/services/rss_service.dart` - Parsing et récupération RSS
