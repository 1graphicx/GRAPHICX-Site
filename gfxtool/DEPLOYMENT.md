# 🚀 Guide de Déploiement GFX Tool Web

## 📋 **Problème**
Le GFX Tool Web Version fonctionne localement mais pas sur votre site hébergé car le serveur backend Flask n'est pas déployé.

## 🔧 **Solutions**

### **Option 1: Déployer le serveur backend (Recommandé)**

#### **Étape 1: Préparer les fichiers**
```bash
# Sur votre serveur web, créer un dossier pour le backend
mkdir gfx-tool-backend
cd gfx-tool-backend

# Copier les fichiers nécessaires
- deploy_server.py
- requirements_server.txt
- ressources/ (dossier complet)
```

#### **Étape 2: Installer les dépendances**
```bash
pip install -r requirements_server.txt
```

#### **Étape 3: Démarrer le serveur**
```bash
python deploy_server.py
```

#### **Étape 4: Configurer le proxy**
Si vous utilisez Apache/Nginx, ajoutez un proxy vers le port 5000 :

**Apache (.htaccess):**
```apache
RewriteEngine On
RewriteRule ^api/(.*)$ http://localhost:5000/api/$1 [P,L]
```

**Nginx:**
```nginx
location /api/ {
    proxy_pass http://localhost:5000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

### **Option 2: Utiliser un service cloud**

#### **Heroku:**
```bash
# Créer Procfile
echo "web: python deploy_server.py" > Procfile

# Déployer
git init
git add .
git commit -m "Initial commit"
heroku create gfx-tool-backend
git push heroku main
```

#### **Railway:**
```bash
# Connecter votre repo GitHub
# Railway détectera automatiquement Python
```

### **Option 3: VPS/Dédié**

#### **Avec PM2 (Recommandé):**
```bash
# Installer PM2
npm install -g pm2

# Démarrer le serveur
pm2 start deploy_server.py --name gfx-tool-backend

# Configurer le démarrage automatique
pm2 startup
pm2 save
```

## 🔗 **Modifier l'URL du serveur**

Dans `script.js`, changez l'URL du serveur :

```javascript
// Pour un serveur local
const serverUrl = 'http://localhost:5000/api/process-files';

// Pour votre domaine
const serverUrl = 'https://votre-domaine.com/api/process-files';

// Ou détecter automatiquement
const serverUrl = window.location.hostname === 'localhost' 
    ? 'http://localhost:5000/api/process-files'
    : 'https://votre-domaine.com/api/process-files';
```

## 📁 **Structure des fichiers sur le serveur**

```
votre-site.com/
├── index.html (GFX Tool frontend)
├── script.js
├── config.js
└── backend/
    ├── deploy_server.py
    ├── requirements_server.txt
    └── ressources/
        ├── rules.json
        └── rules/
            ├── Maxon Cinema 4D.py
            ├── Boris FX Continuum.py
            └── ...
```

## 🔒 **Sécurité**

### **Limiter l'accès:**
```python
# Dans deploy_server.py
from flask import request

@app.before_request
def check_origin():
    allowed_origins = ['https://votre-domaine.com', 'http://localhost:3000']
    if request.headers.get('Origin') not in allowed_origins:
        return jsonify({'error': 'Origin non autorisée'}), 403
```

### **Limiter la taille des fichiers:**
```python
app.config['MAX_CONTENT_LENGTH'] = 100 * 1024 * 1024  # 100MB max
```

## 🚀 **Test du déploiement**

1. **Vérifier que le serveur répond:**
```bash
curl https://votre-domaine.com/api/health
```

2. **Tester le traitement de fichiers:**
```bash
curl -X POST -F "files=@test.exe" https://votre-domaine.com/api/process-files
```

## 📞 **Support**

Si vous avez des problèmes :
1. Vérifiez les logs du serveur
2. Testez l'API avec curl/Postman
3. Vérifiez les permissions des fichiers
4. Assurez-vous que Python et les dépendances sont installés

## 🎯 **Résultat attendu**

Après déploiement, votre GFX Tool Web Version fonctionnera pour tous les utilisateurs de votre site hébergé ! 🚀 