#!/usr/bin/env python3
"""
Script de déploiement simple pour GFX Tool
À utiliser sur votre hébergeur web
"""

import os
import sys
import subprocess
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import tempfile
import shutil
import json
from werkzeug.utils import secure_filename

app = Flask(__name__)
CORS(app)

# Configuration simple
BASE_DIR = os.path.dirname(os.path.dirname(__file__))
RULES_PATH = os.path.join(BASE_DIR, "ressources", "rules.json")
RULES_SCRIPTS_DIR = os.path.join(BASE_DIR, "ressources", "rules")

# Charger les règles
try:
    with open(RULES_PATH, encoding="utf-8") as f:
        rules = json.load(f)
    print(f"✅ Règles chargées: {len(rules.get('multi_conditions', []))}")
except Exception as e:
    print(f"❌ Erreur lors du chargement des règles: {e}")
    rules = {}

def filename_match(filename, pattern):
    """Vérifier si un nom de fichier correspond à un pattern"""
    import fnmatch
    return fnmatch.fnmatch(filename, pattern)

def match_rule_for_file(filename):
    """Vérifier si un fichier correspond à une règle"""
    for rule in rules.get("multi_conditions", []):
        for pattern in rule.get("patterns", []):
            if filename_match(filename, pattern):
                return rule
    return None

def execute_action(action, file_paths):
    """Exécuter l'action correspondante"""
    script_name = f"{action}.py"
    script_path = os.path.join(RULES_SCRIPTS_DIR, script_name)
    
    if not os.path.exists(script_path):
        available_scripts = os.listdir(RULES_SCRIPTS_DIR)
        matching_scripts = [s for s in available_scripts if s.lower().startswith(action.lower().replace(' ', ''))]
        
        if matching_scripts:
            script_path = os.path.join(RULES_SCRIPTS_DIR, matching_scripts[0])
            print(f"Script trouvé: {matching_scripts[0]} pour l'action: {action}")
        else:
            raise FileNotFoundError(f"Script non trouvé pour l'action '{action}'")
    
    print(f"Exécution du script: {script_path}")
    print(f"Fichiers à traiter: {file_paths}")
    
    cmd = [sys.executable, script_path] + file_paths
    
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        cwd=RULES_SCRIPTS_DIR
    )
    
    print(f"Code de retour: {result.returncode}")
    print(f"Sortie stdout: {result.stdout}")
    
    if result.returncode != 0:
        raise RuntimeError(f"Erreur d'exécution: {result.stderr}")
    
    return result.stdout

@app.route('/api/download/<filename>', methods=['GET'])
def download_installer(filename):
    """Télécharger un installateur créé"""
    try:
        # Chercher le fichier dans le dossier installers
        installers_dir = os.path.join(BASE_DIR, "installers")
        file_path = os.path.join(installers_dir, filename)
        
        if os.path.exists(file_path):
            return send_file(
                file_path,
                as_attachment=True,
                download_name=filename,
                mimetype='application/octet-stream'
            )
        else:
            return jsonify({'error': 'Fichier non trouvé'}), 404
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/list-installers', methods=['GET'])
def list_installers():
    """Lister les installateurs disponibles"""
    try:
        installers_dir = os.path.join(BASE_DIR, "installers")
        if os.path.exists(installers_dir):
            files = [f for f in os.listdir(installers_dir) if f.endswith('.exe')]
            return jsonify({
                'success': True,
                'installers': files
            })
        else:
            return jsonify({
                'success': True,
                'installers': []
            })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/process-files', methods=['POST'])
def process_files():
    """Traiter les fichiers uploadés"""
    try:
        if 'files' not in request.files:
            return jsonify({'error': 'Aucun fichier fourni'}), 400
        
        files = request.files.getlist('files')
        results = []
        created_installers = []
        
        temp_files = {}
        for file in files:
            if file.filename:
                filename = secure_filename(file.filename)
                temp_dir = tempfile.mkdtemp()
                temp_path = os.path.join(temp_dir, filename)
                file.save(temp_path)
                temp_files[filename] = temp_path
        
        try:
            processed_files = set()
            
            # Traiter les règles multi-conditions d'abord
            for multi_rule in rules.get("multi_conditions", []):
                patterns = multi_rule.get("patterns", [])
                action = multi_rule.get("action")
                
                matching_files = {}
                for pattern in patterns:
                    for filename, temp_path in temp_files.items():
                        if filename_match(filename, pattern):
                            matching_files[pattern] = temp_path
                            break
                
                if len(matching_files) == len(patterns):
                    try:
                        output = execute_action(action, list(matching_files.values()))
                        
                        # Extraire le nom de l'installateur créé depuis la sortie
                        installer_name = extract_installer_name(output)
                        if installer_name:
                            created_installers.append(installer_name)
                        
                        results.append({
                            'action': action,
                            'files': list(matching_files.keys()),
                            'status': 'success',
                            'output': output,
                            'installer': installer_name
                        })
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
                            
                            # Extraire le nom de l'installateur créé depuis la sortie
                            installer_name = extract_installer_name(output)
                            if installer_name:
                                created_installers.append(installer_name)
                            
                            results.append({
                                'filename': filename,
                                'action': rule['action'],
                                'status': 'success',
                                'output': output,
                                'installer': installer_name
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
            # Nettoyer les fichiers temporaires
            for temp_path in temp_files.values():
                temp_dir = os.path.dirname(temp_path)
                shutil.rmtree(temp_dir)
        
        return jsonify({
            'success': True,
            'results': results,
            'installers_created': created_installers
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def extract_installer_name(output):
    """Extraire le nom de l'installateur depuis la sortie du script"""
    try:
        # Chercher des patterns comme "Compilation réussie : C:\...\NomInstaller.exe"
        import re
        pattern = r'Compilation réussie : .*[\\/]([^\\/]+\.exe)'
        match = re.search(pattern, output)
        if match:
            return match.group(1)
        
        # Chercher des patterns comme "installers\NomInstaller.exe"
        pattern2 = r'installers[\\/]([^\\/]+\.exe)'
        match2 = re.search(pattern2, output)
        if match2:
            return match2.group(1)
            
        return None
    except:
        return None

@app.route('/api/health', methods=['GET'])
def health_check():
    """Vérification de l'état du serveur"""
    return jsonify({
        'status': 'ok',
        'rules_loaded': len(rules.get('multi_conditions', [])),
        'message': 'GFX Tool Backend opérationnel'
    })

@app.route('/api/rules', methods=['GET'])
def get_rules():
    """Récupérer les règles"""
    return jsonify(rules)

if __name__ == '__main__':
    print("🚀 Démarrage du serveur GFX Tool (Simple)...")
    print(f"📁 Répertoire de base: {BASE_DIR}")
    print(f"📄 Règles chargées: {len(rules.get('multi_conditions', []))}")
    print("🌐 Serveur accessible sur: http://localhost:5000")
    
    # Configuration pour la production
    app.run(host='0.0.0.0', port=5000, debug=False) 