#!/usr/bin/env python3
"""
Script de traitement des fichiers pour GFX Tool
Exécuté par GitHub Actions
"""

import json
import os
import sys
import subprocess
import shutil
from pathlib import Path

def load_rules():
    """Charger les règles de traitement"""
    try:
        with open('ressources/rules.json', 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        # Règles par défaut
        return {
            "multi_conditions": [
                {
                    "patterns": ["*RedGiant*.exe", "*Maxon_App*.exe"],
                    "action": "Maxon Red Giant"
                },
                {
                    "patterns": ["*Universe*.exe", "*Maxon_App*.exe"],
                    "action": "Maxon Universe"
                },
                {
                    "patterns": ["*Cinema4D*.exe", "*Maxon_App*.exe"],
                    "action": "Maxon Cinema 4D"
                },
                {
                    "patterns": ["*010Editor*.exe"],
                    "action": "010 Editor"
                },
                {
                    "patterns": ["*Continuum*.exe"],
                    "action": "Boris FX Continuum"
                },
                {
                    "patterns": ["*sapphire*.exe"],
                    "action": "Boris FX Sapphire"
                },
                {
                    "patterns": ["*MochaPro*.msi"],
                    "action": "Boris FX Mocha Pro"
                },
                {
                    "patterns": ["*TopazGigapixelAI*.msi"],
                    "action": "Topaz Gigapixel"
                },
                {
                    "patterns": ["*TopazPhotoAI*.msi"],
                    "action": "Topaz Photo"
                },
                {
                    "patterns": ["*TopazVideoAI*.msi"],
                    "action": "Topaz Video"
                },
                {
                    "patterns": ["*TopazVideoEnhanceAI*.exe"],
                    "action": "Topaz Video Enhance"
                }
            ]
        }

def filename_match(filename, pattern):
    """Vérifier si un nom de fichier correspond à un pattern"""
    import re
    
    # Convertir le pattern en regex
    regex_pattern = pattern
    regex_pattern = regex_pattern.replace('.', '\\.')
    regex_pattern = regex_pattern.replace('*', '.*')
    regex_pattern = regex_pattern.replace('?', '.')
    regex_pattern = regex_pattern.replace('[', '\\[')
    regex_pattern = regex_pattern.replace(']', '\\]')
    
    regex = re.compile(regex_pattern, re.IGNORECASE)
    return regex.match(filename) is not None

def match_rule_for_file(filename, rules):
    """Trouver la règle correspondante pour un fichier"""
    if not rules or 'multi_conditions' not in rules:
        return None
    
    for rule in rules['multi_conditions']:
        if 'patterns' in rule and isinstance(rule['patterns'], list):
            for pattern in rule['patterns']:
                if filename_match(filename, pattern):
                    return rule
    return None

def create_installer(filename, action, output_dir):
    """Créer un installateur pour le fichier"""
    try:
        # Créer le nom de l'installateur
        base_name = Path(filename).stem
        installer_name = f"{base_name}_Patched.exe"
        installer_path = os.path.join(output_dir, installer_name)
        
        # Simuler la création d'un installateur
        # Dans une vraie implémentation, vous utiliseriez PyInstaller ou Inno Setup
        
        # Créer un fichier exécutable factice pour la démo
        with open(installer_path, 'w') as f:
            f.write(f"# Installateur généré pour {action}\n")
            f.write(f"# Fichier original: {filename}\n")
            f.write(f"# Généré par GFX Tool\n")
        
        # Rendre le fichier exécutable (Linux/Mac)
        os.chmod(installer_path, 0o755)
        
        print(f"✅ Installateur créé: {installer_name}")
        return installer_name
        
    except Exception as e:
        print(f"❌ Erreur lors de la création de l'installateur: {e}")
        return None

def main():
    """Fonction principale"""
    if len(sys.argv) < 2:
        print("❌ Usage: python process_files.py <files_json>")
        sys.exit(1)
    
    try:
        # Parser la liste des fichiers
        files_json = sys.argv[1]
        files_data = json.loads(files_json)
        
        print(f"🚀 Début du traitement de {len(files_data)} fichier(s)")
        
        # Charger les règles
        rules = load_rules()
        print("📋 Règles chargées")
        
        # Créer le répertoire de sortie
        output_dir = "output"
        os.makedirs(output_dir, exist_ok=True)
        
        installers_created = []
        
        # Traiter chaque fichier
        for file_info in files_data:
            filename = file_info['name']
            print(f"\n📁 Traitement de: {filename}")
            
            # Trouver la règle correspondante
            rule = match_rule_for_file(filename, rules)
            
            if rule:
                action = rule['action']
                print(f"✅ Règle trouvée: {action}")
                
                # Créer l'installateur
                installer_name = create_installer(filename, action, output_dir)
                if installer_name:
                    installers_created.append(installer_name)
            else:
                print(f"⚠️ Aucune règle trouvée pour: {filename}")
        
        # Résumé
        print(f"\n🎉 Traitement terminé!")
        print(f"📦 {len(installers_created)} installateur(s) créé(s):")
        for installer in installers_created:
            print(f"  - {installer}")
        
        # Définir l'output pour GitHub Actions
        if installers_created:
            print(f"::set-output name=installers_created::true")
            print(f"::set-output name=installers_list::{','.join(installers_created)}")
        else:
            print(f"::set-output name=installers_created::false")
            
    except json.JSONDecodeError as e:
        print(f"❌ Erreur JSON: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Erreur générale: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 