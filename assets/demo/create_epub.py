#!/usr/bin/env python3
"""Génère un EPUB minimal de démo pour Inkavi (revue Apple)."""
import zipfile, os

OUT = os.path.join(os.path.dirname(__file__), "demo.epub")

MIMETYPE = "application/epub+zip"

CONTAINER_XML = """<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>"""

CONTENT_OPF = """<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="uid">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>Inkavi — Démo Lecteur</dc:title>
    <dc:creator>Inkavi App</dc:creator>
    <dc:language>fr</dc:language>
    <dc:identifier id="uid">inkavi-demo-2024</dc:identifier>
  </metadata>
  <manifest>
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="ch1" href="ch1.xhtml" media-type="application/xhtml+xml"/>
    <item id="ch2" href="ch2.xhtml" media-type="application/xhtml+xml"/>
    <item id="ch3" href="ch3.xhtml" media-type="application/xhtml+xml"/>
    <item id="css" href="style.css" media-type="text/css"/>
  </manifest>
  <spine>
    <itemref idref="ch1"/>
    <itemref idref="ch2"/>
    <itemref idref="ch3"/>
  </spine>
</package>"""

NAV_XHTML = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
<head><title>Table des matières</title></head>
<body>
  <nav epub:type="toc">
    <ol>
      <li><a href="ch1.xhtml">Bienvenue dans Inkavi</a></li>
      <li><a href="ch2.xhtml">Votre bibliothèque</a></li>
      <li><a href="ch3.xhtml">Explorer & Découvrir</a></li>
    </ol>
  </nav>
</body>
</html>"""

STYLE_CSS = """
body { font-family: Georgia, serif; margin: 2em; line-height: 1.8; color: #1a1a2e; background: #fff; }
h1 { font-size: 2em; color: #FF1B8D; border-bottom: 3px solid #A855F7; padding-bottom: 0.3em; }
h2 { font-size: 1.4em; color: #A855F7; }
p { text-align: justify; margin: 1em 0; }
.highlight { background: linear-gradient(135deg, #FF1B8D20, #06B6D420); padding: 1em; border-radius: 8px; border-left: 4px solid #FF1B8D; }
.feature { margin: 1em 0; padding: 0.8em 1em; background: #f8f4ff; border-radius: 6px; }
"""

CH1 = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>Bienvenue</title><link rel="stylesheet" href="style.css"/></head>
<body>
  <h1>Bienvenue dans Inkavi 📚</h1>
  <p>Inkavi est votre client natif pour <strong>Kavita</strong>, le serveur de lecture de mangas, comics et livres. Cette démo vous permet de découvrir l'expérience de lecture intégrée à l'application.</p>
  <div class="highlight">
    <p>✨ <strong>Lecteur natif</strong> — intégré directement dans l'app, sans navigateur web. Thème sombre, filtres de couleur, navigation fluide.</p>
  </div>
  <p>Le lecteur EPUB d'Inkavi prend en charge :</p>
  <div class="feature">📖 Navigation par chapitres avec pagination fluide</div>
  <div class="feature">🌙 Mode sombre complet, intégré au thème système</div>
  <div class="feature">🔍 Zoom et navigation tactile intuitive</div>
  <div class="feature">💾 Cache intelligent — le contenu se charge instantanément après la première lecture</div>
  <p>Connectez Inkavi à votre serveur Kavita pour accéder à toute votre bibliothèque personnelle.</p>
</body>
</html>"""

CH2 = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>Votre bibliothèque</title><link rel="stylesheet" href="style.css"/></head>
<body>
  <h1>Votre bibliothèque 🗂️</h1>
  <p>Inkavi se connecte à votre instance <strong>Kavita</strong> auto-hébergée pour vous donner accès à toute votre collection de mangas et comics, où que vous soyez.</p>
  <h2>Fonctionnalités disponibles</h2>
  <div class="feature">🔖 <strong>Favoris</strong> — Marquez vos séries préférées pour y accéder rapidement</div>
  <div class="feature">📌 <strong>À lire</strong> — Créez une liste de lecture personnalisée</div>
  <div class="feature">📊 <strong>Progression</strong> — Suivez votre avancement chapitre par chapitre</div>
  <div class="feature">🏷️ <strong>Collections</strong> — Organisez vos séries par genre ou thème</div>
  <p>L'interface s'adapte automatiquement au thème clair ou sombre de votre appareil, pour un confort visuel optimal en toutes circonstances.</p>
  <div class="highlight">
    <p>💡 La bibliothèque se synchronise en temps réel avec votre serveur Kavita, vous assurant d'avoir toujours le contenu le plus récent.</p>
  </div>
</body>
</html>"""

CH3 = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>Explorer</title><link rel="stylesheet" href="style.css"/></head>
<body>
  <h1>Explorer &amp; Découvrir 🔭</h1>
  <p>Naviguez dans vos bibliothèques, découvrez de nouvelles séries et reprenez votre lecture là où vous l'avez laissée grâce à la section <em>En cours</em> sur la page d'accueil.</p>
  <h2>Interface intuitive</h2>
  <p>La page d'accueil d'Inkavi vous présente :</p>
  <div class="feature">🔄 <strong>En cours</strong> — Vos séries en cours de lecture, pour reprendre instantanément</div>
  <div class="feature">🆕 <strong>Récemment ajoutés</strong> — Les dernières séries disponibles sur votre serveur</div>
  <div class="feature">📚 <strong>Raccourcis bibliothèque</strong> — Accédez directement à chaque collection</div>
  <h2>Fiche série détaillée</h2>
  <p>Chaque série dispose d'une fiche complète avec synopsis, progression de lecture, volumes et chapitres disponibles, ainsi que les boutons d'action rapide.</p>
  <div class="highlight">
    <p>🚀 <strong>Inkavi</strong> — Le meilleur compagnon de lecture pour Kavita sur iPhone et Android.</p>
  </div>
  <p>Merci d'utiliser Inkavi. Bonne lecture ! 📖</p>
</body>
</html>"""

with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("mimetype", MIMETYPE, compress_type=zipfile.ZIP_STORED)
    z.writestr("META-INF/container.xml", CONTAINER_XML)
    z.writestr("OEBPS/content.opf", CONTENT_OPF)
    z.writestr("OEBPS/nav.xhtml", NAV_XHTML)
    z.writestr("OEBPS/style.css", STYLE_CSS)
    z.writestr("OEBPS/ch1.xhtml", CH1)
    z.writestr("OEBPS/ch2.xhtml", CH2)
    z.writestr("OEBPS/ch3.xhtml", CH3)

print(f"✅ EPUB créé : {OUT} ({os.path.getsize(OUT)} bytes)")
