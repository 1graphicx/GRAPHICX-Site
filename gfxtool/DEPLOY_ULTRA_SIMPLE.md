# 🚀 Déploiement Ultra-Simple GFX Tool

## 📋 **Problème**
Le serveur backend ne fonctionne que localement. Il faut le déployer sur votre hébergeur.

## 🔧 **Solution en 3 étapes**

### **Étape 1: Modifier l'URL**
Dans `script.js`, ligne 15, l'URL est déjà configurée :
```javascript
const serverUrl = isLocalhost 
    ? 'http://localhost:5000/api/process-files'
    : 'https://graphicx.store/gfxtool/api/process-files'; // ✅ Déjà configuré
```

### **Étape 2: Déployer le serveur**

#### **Option A: Votre hébergeur actuel**
```bash
# 1. Uploader ces fichiers sur votre serveur dans /gfxtool/
- deploy_simple.py
- requirements_server.txt
- ressources/ (tout le dossier)

# 2. Installer Python et les dépendances
pip install flask flask-cors werkzeug

# 3. Démarrer le serveur
python deploy_simple.py
```

#### **Option B: Railway (Gratuit et simple)**
1. Aller sur [railway.app](https://railway.app)
2. Créer un compte
3. Cliquer "New Project" → "Deploy from GitHub"
4. Uploader ces fichiers :
   - `deploy_simple.py`
   - `requirements_server.txt`
   - `ressources/` (dossier complet)
5. Railway déploiera automatiquement
6. Copier l'URL générée (ex: `https://gfx-tool-backend.railway.app`)

### **Étape 3: Configurer le proxy**
Ajouter dans votre `.htaccess` dans le dossier `/gfxtool/` :
```apache
RewriteEngine On
RewriteRule ^api/(.*)$ http://localhost:5000/api/$1 [P,L]
```

## 🎯 **Test rapide**

1. **Vérifier que le serveur répond :**
```bash
curl https://graphicx.store/gfxtool/api/health
```

2. **Tester le traitement :**
```bash
curl -X POST -F "files=@test.exe" https://graphicx.store/gfxtool/api/process-files
```

## 📞 **Si ça ne marche pas**

1. **Vérifiez les logs** du serveur
2. **Testez l'API** avec Postman
3. **Vérifiez les permissions** des fichiers
4. **Assurez-vous** que Python est installé

## 🚀 **Résultat**
Après déploiement, votre GFX Tool fonctionnera pour tous les utilisateurs ! 🎉 