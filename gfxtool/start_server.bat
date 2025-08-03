@echo off
echo ========================================
echo    GFX Tool - Serveur Backend
echo ========================================
echo.

echo [1/3] Installation des dépendances...
pip install -r requirements_server.txt
if %errorlevel% neq 0 (
    echo ❌ Erreur lors de l'installation des dépendances
    pause
    exit /b 1
)
echo ✅ Dépendances installées
echo.

echo [2/3] Vérification des fichiers...
if not exist "..\ressources\rules.json" (
    echo ❌ Erreur: rules.json non trouvé
    pause
    exit /b 1
)

if not exist "..\ressources\rules" (
    echo ❌ Erreur: dossier rules non trouvé
    pause
    exit /b 1
)
echo ✅ Fichiers vérifiés
echo.

echo [3/3] Démarrage du serveur...
echo 🌐 Le serveur sera accessible sur: http://localhost:5000
echo 📱 Vous pouvez maintenant utiliser la version web
echo.
echo Appuyez sur Ctrl+C pour arrêter le serveur
echo.

python server.py

pause 