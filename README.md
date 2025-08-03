# 🚀 GFX Tool - Version GitHub

**GFX Tool by Hyrax** - Outil de traitement automatisé de fichiers via GitHub Actions et GitHub Pages.

## ✨ Fonctionnalités

- 🎯 **Interface web moderne** hébergée sur GitHub Pages
- ⚡ **Traitement automatisé** via GitHub Actions
- 📦 **Génération d'installateurs** automatique
- 🔄 **Workflow complet** : Upload → Traitement → Release → Téléchargement
- 🔐 **Authentification GitHub** sécurisée
- 📱 **Interface responsive** et accessible

## 🛠️ Configuration GitHub

### 1. Prérequis

- Compte GitHub
- Repository GitHub (public ou privé)
- GitHub Actions activé
- GitHub Pages activé

### 2. Structure du Repository

```
graphicx-gfxtool/
├── gfxtool/                    # Interface web
│   ├── index.html
│   ├── script.js
│   ├── config.js
│   └── ressources/
│       └── rules.json
├── scripts/
│   └── process_files.py        # Script de traitement
├── .github/
│   └── workflows/
│       ├── deploy.yml          # Déploiement Pages
│       └── process-files.yml   # Traitement fichiers
└── README.md
```

### 3. Configuration GitHub Pages

1. **Aller dans Settings > Pages**
2. **Source** : Deploy from a branch
3. **Branch** : `gh-pages` / `/(root)`
4. **Save**

### 4. Configuration GitHub Actions

Les workflows sont automatiquement activés :
- `deploy.yml` : Déploie l'interface sur Pages
- `process-files.yml` : Traite les fichiers et crée des releases

### 5. Configuration OAuth App (Optionnel)

Pour l'authentification automatique :

1. **Settings > Developer settings > OAuth Apps**
2. **New OAuth App**
3. **Application name** : `GFX Tool`
4. **Homepage URL** : `https://yourusername.github.io/graphicx-gfxtool`
5. **Authorization callback URL** : `https://yourusername.github.io/graphicx-gfxtool`
6. **Scopes** : `repo`, `workflow`

## 🚀 Utilisation

### Interface Web

1. **Accéder à l'interface** : `https://yourusername.github.io/graphicx-gfxtool`
2. **Glisser-déposer** vos fichiers ou cliquer pour sélectionner
3. **Authentifier GitHub** (première utilisation)
4. **Cliquer sur PATCH** pour lancer le traitement
5. **Attendre** la completion du workflow GitHub Actions
6. **Télécharger** les installateurs générés

### Workflow Automatique

1. **Upload** des fichiers via l'interface
2. **Déclenchement** du workflow GitHub Actions
3. **Traitement** des fichiers selon les règles
4. **Création** d'installateurs
5. **Release** automatique sur GitHub
6. **Téléchargement** direct depuis les releases

## 🔧 Personnalisation

### Règles de Traitement

Modifier `gfxtool/ressources/rules.json` :

```json
{
  "multi_conditions": [
    {
      "patterns": ["*010Editor*.exe"],
      "action": "010 Editor"
    }
  ]
}
```

### Script de Traitement

Modifier `scripts/process_files.py` pour :
- Changer la logique de traitement
- Ajouter de nouveaux outils
- Modifier la génération d'installateurs

### Interface

Modifier `gfxtool/index.html` et `gfxtool/script.js` pour :
- Changer le design
- Ajouter des fonctionnalités
- Modifier les messages

## 🔐 Sécurité

- **Authentification GitHub** requise pour le traitement
- **Tokens temporaires** pour les opérations
- **Permissions minimales** (repo, workflow)
- **Validation** des fichiers uploadés

## 📊 Monitoring

### GitHub Actions

- **Workflow runs** : Voir l'historique des traitements
- **Logs détaillés** : Suivre chaque étape
- **Notifications** : Email/webhook en cas d'échec

### Releases

- **Historique** : Tous les installateurs générés
- **Métadonnées** : Date, fichiers traités, version
- **Téléchargements** : Statistiques d'utilisation

## 🐛 Dépannage

### Problèmes Courants

1. **Workflow ne se déclenche pas**
   - Vérifier les permissions GitHub
   - Contrôler les secrets et variables

2. **Authentification échoue**
   - Vérifier l'OAuth App
   - Contrôler les scopes

3. **Fichiers non traités**
   - Vérifier les règles dans `rules.json`
   - Contrôler les patterns

4. **Installateurs non créés**
   - Vérifier les logs GitHub Actions
   - Contrôler le script Python

### Logs et Debug

- **Console navigateur** : Erreurs JavaScript
- **GitHub Actions** : Logs du workflow
- **Network tab** : Requêtes API

## 🤝 Contribution

1. **Fork** le repository
2. **Créer** une branche feature
3. **Modifier** le code
4. **Tester** localement
5. **Pull Request**

## 📄 Licence

Ce projet est sous licence MIT. Voir `LICENSE` pour plus de détails.

## 👨‍💻 Auteur

**Hyrax** - [GitHub](https://github.com/hyrax)

---

⭐ **N'oubliez pas de star le repository si ce projet vous aide !** 