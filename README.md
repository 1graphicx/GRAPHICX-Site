# GRAPHICX by HYRAX

Hub de Création Numérique - Votre ressource pour les plugins, logiciels et outils de création numérique.

## 🌐 Site Web

**URL principale :** https://graphicx.store

## 🚀 Installation et Déploiement

### Prérequis
- Node.js (version 18 ou supérieure)
- npm ou yarn
- Git

### Installation locale

1. **Cloner le repository**
   ```bash
   git clone https://github.com/your-username/GRAPHICX-Site-main.git
   cd GRAPHICX-Site-main
   ```

2. **Installer les dépendances**
   ```bash
   npm install
   ```

3. **Lancer en mode développement**
   ```bash
   npm run dev
   ```

### Optimisation et Build

1. **Optimiser le code**
   ```bash
   npm run build
   ```

2. **Minifier les fichiers**
   ```bash
   npm run minify
   ```

## 📁 Structure du Projet

```
GRAPHICX-Site-main/
├── index.html              # Page principale
├── CNAME                   # Configuration du domaine
├── _headers               # Headers de sécurité
├── robots.txt             # Configuration SEO
├── sitemap.xml            # Sitemap pour les moteurs de recherche
├── cloudflare.toml        # Configuration Cloudflare
├── package.json           # Dépendances et scripts
├── .github/
│   └── workflows/
│       └── deploy.yml     # Workflow de déploiement GitHub Actions
├── assets/
│   ├── css/
│   │   ├── style.css      # Styles principaux
│   │   └── style.min.css  # Styles minifiés
│   ├── js/
│   │   ├── script.js      # JavaScript principal
│   │   └── script.min.js  # JavaScript minifié
│   └── images/            # Images du site
├── android/               # Contenu Android
├── macos/                 # Contenu macOS
├── windows/               # Contenu Windows
├── licenses/              # Licences
└── gfxtool/               # Outils GFX
```

## 🔒 Configuration SSL/HTTPS

### GitHub Pages
1. Allez dans les **Settings** de votre repository
2. Dans **Pages**, activez **GitHub Pages**
3. Sélectionnez la branche **main** ou **master**
4. Cochez **"Enforce HTTPS"**
5. Configurez votre domaine personnalisé

### DNS Configuration
```
Type: CNAME
Name: @
Value: votre-username.github.io
```

### Vérification SSL
- Attendez 24-48h pour la génération du certificat
- Testez avec `https://graphicx.store`

## 🛠️ Optimisations Implémentées

### Performance
- ✅ CSS et JavaScript séparés
- ✅ Minification automatique
- ✅ Compression des assets
- ✅ Cache headers configurés
- ✅ Images optimisées

### SEO
- ✅ Meta tags complets
- ✅ Sitemap XML
- ✅ Robots.txt
- ✅ Open Graph tags
- ✅ Twitter Cards

### Sécurité
- ✅ Headers de sécurité
- ✅ Content Security Policy
- ✅ HTTPS forcé
- ✅ Protection contre le clickjacking

### Accessibilité
- ✅ Langue définie
- ✅ Contrastes appropriés
- ✅ Navigation au clavier
- ✅ Responsive design

## 📊 Métriques de Performance

- **Taille du fichier HTML :** ~54KB (optimisé)
- **Temps de chargement :** < 2 secondes
- **Score Lighthouse :** 95+ (après optimisation)
- **Mobile-friendly :** ✅

## 🔧 Scripts Disponibles

```bash
npm run dev        # Lancer le serveur de développement
npm run build      # Optimiser et construire le projet
npm run optimize   # Optimiser le HTML
npm run minify     # Minifier CSS et JS
npm test           # Lancer les tests
```

## 🌍 Support Multilingue

Le site détecte automatiquement la langue du navigateur et affiche le contenu en :
- 🇫🇷 **Français** (par défaut pour les navigateurs français)
- 🇬🇧 **Anglais** (pour tous les autres navigateurs)

## 📝 Mise à Jour du Contenu

### Ajouter de nouveaux liens
1. Modifiez le fichier `index.html`
2. Ajoutez les traductions dans `assets/js/script.js`
3. Testez avec `npm run dev`
4. Déployez avec `npm run build`

### Modifier les styles
1. Éditez `assets/css/style.css`
2. Testez les changements
3. Minifiez avec `npm run minify`

## 🐛 Dépannage

### Problèmes SSL
- Vérifiez la configuration DNS
- Attendez 24-48h pour la propagation
- Contactez votre registrar si nécessaire

### Problèmes de performance
- Vérifiez la taille des images
- Optimisez avec `npm run build`
- Testez avec Lighthouse

## 📞 Support

- **Discord :** [Rejoindre le serveur](https://discord.com/invite/CNudm6aJ2n)
- **YouTube :** [Chaîne HYRAX](https://www.youtube.com/channel/UCJB2IQP3pfiYF5NxMa5-jPQ)
- **Site :** https://graphicx.store

## 📄 Licence

© 2025 GRAPHICX by HYRAX. Tous droits réservés.

---

**Développé avec ❤️ par HYRAX** 