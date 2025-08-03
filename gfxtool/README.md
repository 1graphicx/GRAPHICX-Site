# GFX Tool - Version Web

## 🌐 Version Web de GFX Tool

Cette version web permet d'utiliser GFX Tool directement dans votre navigateur sans avoir à télécharger l'application.

## 🚀 Comment utiliser

### Option 1: Version complète avec serveur backend (Recommandé)
1. **Démarrez le serveur backend** : Double-cliquez sur `start_server.bat`
2. **Ouvrez l'interface web** : Double-cliquez sur `index.html`
3. **Utilisez l'application** : Glissez vos fichiers et traitez-les

### Option 2: Version simulation (sans serveur)
1. Ouvrez le fichier `index.html` dans votre navigateur
2. Utilisez l'interface pour sélectionner vos fichiers
3. Le traitement sera simulé (pas de vrai traitement)

### Option 3: Héberger sur un serveur web
1. Uploadez le dossier `web/` sur votre serveur web
2. Démarrez le serveur backend sur votre serveur
3. Accédez à l'URL de votre serveur

## 📁 Structure des fichiers

```
web/
├── index.html              # Page principale
├── styles.css              # Styles CSS
├── script.js               # Logique JavaScript
├── config.js               # Configuration et chargement des règles
├── server.py               # Serveur backend Flask
├── start_server.bat        # Script de démarrage du serveur
├── requirements_server.txt  # Dépendances du serveur
└── README.md               # Ce fichier
```

## ✨ Fonctionnalités

### ✅ Fonctionnalités disponibles
- **Drag & Drop** : Glissez vos fichiers directement dans l'interface
- **Sélection de fichiers** : Bouton pour sélectionner des fichiers
- **Interface identique** : Même design que l'application originale
- **Règles de traitement** : Utilise les mêmes règles que l'application desktop
- **Console en temps réel** : Affichage des logs et du statut
- **Barre de progression** : Suivi du traitement des fichiers
- **Responsive** : Fonctionne sur mobile et desktop

### ⚠️ Limitations de la version web
- **Pas de sélection de dossiers** : Les navigateurs ne permettent pas de sélectionner des dossiers
- **Traitement simulé** : Le traitement réel des fichiers nécessite un serveur backend
- **Sécurité** : Les fichiers ne sont pas envoyés au serveur (traitement côté client uniquement)

## 🎨 Interface

L'interface reproduit fidèlement le design de l'application originale :
- **Thème sombre** : Mêmes couleurs que l'application desktop
- **Animations** : Effets visuels pour une meilleure expérience utilisateur
- **Responsive** : S'adapte aux différentes tailles d'écran

## 🔧 Configuration

### Chargement des règles
L'application tente de charger les règles depuis `../ressources/rules.json`. Si le fichier n'est pas disponible, elle utilise des règles par défaut.

### Personnalisation
Vous pouvez modifier :
- `styles.css` : Pour changer l'apparence
- `script.js` : Pour modifier la logique
- `config.js` : Pour changer la configuration

## 🌐 Déploiement

### Serveur local
```bash
# Avec Python
python -m http.server 8000

# Avec Node.js
npx serve .

# Avec PHP
php -S localhost:8000
```

### Serveur de production
Uploadez simplement les fichiers sur votre serveur web (Apache, Nginx, etc.)

## 🔒 Sécurité

⚠️ **Important** : Cette version web traite les fichiers uniquement côté client. Pour un traitement réel des fichiers, vous devrez :

1. Créer un serveur backend (Node.js, Python, PHP, etc.)
2. Implémenter les actions de traitement côté serveur
3. Modifier le JavaScript pour envoyer les fichiers au serveur

## 🚀 Développement futur

Pour une version complète avec traitement réel :

1. **Backend API** : Créer un serveur qui traite les fichiers
2. **Upload de fichiers** : Envoyer les fichiers au serveur
3. **Téléchargement** : Permettre de télécharger les fichiers traités
4. **Authentification** : Ajouter un système de connexion si nécessaire

## 📞 Support

Pour toute question ou problème :
- Vérifiez que tous les fichiers sont présents
- Ouvrez la console du navigateur (F12) pour voir les erreurs
- Assurez-vous que JavaScript est activé

## 🎯 Compatibilité

- **Navigateurs** : Chrome, Firefox, Safari, Edge (versions récentes)
- **Mobile** : Compatible avec les navigateurs mobiles
- **Systèmes** : Windows, macOS, Linux, Android, iOS 