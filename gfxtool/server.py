#!/usr/bin/env python3
"""
Serveur backend pour GFX Tool Web Version
Permet d'exécuter les scripts de traitement côté serveur
"""

import os
import json
import subprocess
import sys
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import tempfile
import shutil
from werkzeug.utils import secure_filename

app = Flask(__name__)
CORS(app)  # Permet les requêtes cross-origin

# Configuration
BASE_DIR = os.path.dirname(os.path.dirname(__file__))  # Remonte au dossier gfx_tool
RULES_PATH = os.path.join(BASE_DIR, "ressources", "rules.json")
RULES_SCRIPTS_DIR = os.path.join(BASE_DIR, "ressources", "rules")

# Charger les règles
try:
    with open(RULES_PATH, encoding="utf-8") as f:
        rules = json.load(f)
except Exception as e:
    print(f"Erreur lors du chargement des règles: {e}")
    rules = {}

def match_rule_for_file(filename):
    """Vérifier si un fichier correspond à une règle"""
    for rule in rules.get("multi_conditions", []):
        for pattern in rule.get("patterns", []):
            if filename_match(filename, pattern):
                return rule
    return None

def filename_match(filename, pattern):
    """Vérifier si un nom de fichier correspond à un pattern"""
    import fnmatch
    return fnmatch.fnmatch(filename, pattern)

def execute_action(action, file_paths):
    """Exécuter l'action correspondante"""
    # Chercher le script avec le bon nom (gérer les espaces)
    script_name = f"{action}.py"
    script_path = os.path.join(RULES_SCRIPTS_DIR, script_name)
    
    if not os.path.exists(script_path):
        # Essayer de trouver le script avec des variations
        available_scripts = os.listdir(RULES_SCRIPTS_DIR)
        matching_scripts = [s for s in available_scripts if s.lower().startswith(action.lower().replace(' ', ''))]
        
        if matching_scripts:
            script_path = os.path.join(RULES_SCRIPTS_DIR, matching_scripts[0])
            print(f"Script trouvé: {matching_scripts[0]} pour l'action: {action}")
        else:
            raise FileNotFoundError(f"Script non trouvé pour l'action '{action}'. Scripts disponibles: {available_scripts}")
    
    print(f"Exécution du script: {script_path}")
    print(f"Fichiers à traiter: {file_paths}")
    
    # Préparer la commande avec tous les fichiers
    cmd = [sys.executable, script_path] + file_paths
    
    # Exécuter le script Python
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        cwd=RULES_SCRIPTS_DIR
    )
    
    print(f"Code de retour: {result.returncode}")
    print(f"Sortie stdout: {result.stdout}")
    print(f"Sortie stderr: {result.stderr}")
    
    if result.returncode != 0:
        raise RuntimeError(f"Erreur d'exécution: {result.stderr}")
    
    return result.stdout

@app.route('/api/process-files', methods=['POST'])
def process_files():
    """Traiter les fichiers uploadés"""
    try:
        if 'files' not in request.files:
            return jsonify({'error': 'Aucun fichier fourni'}), 400
        
        files = request.files.getlist('files')
        results = []
        
        # Sauvegarder tous les fichiers temporairement
        temp_files = {}
        for file in files:
            if file.filename:
                filename = secure_filename(file.filename)
                temp_dir = tempfile.mkdtemp()
                temp_path = os.path.join(temp_dir, filename)
                file.save(temp_path)
                temp_files[filename] = temp_path
        
        try:
            # Traiter les règles multi-conditions d'abord
            processed_files = set()
            
            for multi_rule in rules.get("multi_conditions", []):
                patterns = multi_rule.get("patterns", [])
                action = multi_rule.get("action")
                
                # Vérifier si tous les patterns sont présents
                matching_files = {}
                for pattern in patterns:
                    for filename, temp_path in temp_files.items():
                        if filename_match(filename, pattern):
                            matching_files[pattern] = temp_path
                            break
                
                # Si tous les patterns sont trouvés, exécuter l'action
                if len(matching_files) == len(patterns):
                    try:
                        output = execute_action(action, list(matching_files.values()))
                        results.append({
                            'action': action,
                            'files': list(matching_files.keys()),
                            'status': 'success',
                            'output': output
                        })
                        # Marquer les fichiers comme traités
                        for filename in matching_files.keys():
                            processed_files.add(filename)
                    except Exception as e:
                        results.append({
                            'action': action,
                            'files': list(matching_files.keys()),
                            'status': 'error',
                            'message': str(e)
                        })
            
            # Traiter les fichiers restants individuellement
            for filename, temp_path in temp_files.items():
                if filename not in processed_files:
                    rule = match_rule_for_file(filename)
                    if rule:
                        try:
                            output = execute_action(rule['action'], [temp_path])
                            results.append({
                                'filename': filename,
                                'action': rule['action'],
                                'status': 'success',
                                'output': output
                            })
                        except Exception as e:
                            results.append({
                                'filename': filename,
                                'status': 'error',
                                'message': str(e)
                            })
                    else:
                        results.append({
                            'filename': filename,
                            'status': 'no_rule',
                            'message': 'Aucune règle trouvée'
                        })
        
        finally:
            # Nettoyer tous les fichiers temporaires
            for temp_path in temp_files.values():
                temp_dir = os.path.dirname(temp_path)
                shutil.rmtree(temp_dir)
        
        return jsonify({
            'success': True,
            'results': results
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/rules', methods=['GET'])
def get_rules():
    """Récupérer les règles"""
    return jsonify(rules)

@app.route('/api/health', methods=['GET'])
def health_check():
    """Vérification de l'état du serveur"""
    return jsonify({
        'status': 'ok',
        'rules_loaded': len(rules.get('multi_conditions', [])),
        'scripts_dir': RULES_SCRIPTS_DIR
    })

if __name__ == '__main__':
    print("🚀 Démarrage du serveur GFX Tool...")
    print(f"📁 Répertoire de base: {BASE_DIR}")
    print(f"📄 Règles chargées: {len(rules.get('multi_conditions', []))}")
    print(f"🔧 Scripts disponibles: {os.listdir(RULES_SCRIPTS_DIR) if os.path.exists(RULES_SCRIPTS_DIR) else 'Non trouvé'}")
    print("🌐 Serveur accessible sur: http://localhost:5000")
    
    app.run(debug=True, host='0.0.0.0', port=5000) 