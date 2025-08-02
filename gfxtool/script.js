// Variables globales
let filesAdded = [];
let currentFontSize = 14;
let rules = null;

// Initialisation
document.addEventListener('DOMContentLoaded', async function() {
    // Charger les règles
    rules = await window.gfxConfig.loadRules();
    
    initializeDragAndDrop();
    initializeFileInput();
    updateStatus();
    
    logToConsole('🚀 GFX Tool Web Version initialisée', 'success');
});

// Initialisation du drag & drop
function initializeDragAndDrop() {
    const dropZone = document.getElementById('dropZone');
    
    dropZone.addEventListener('dragover', function(e) {
        e.preventDefault();
        dropZone.classList.add('dragover');
    });
    
    dropZone.addEventListener('dragleave', function(e) {
        e.preventDefault();
        dropZone.classList.remove('dragover');
    });
    
    dropZone.addEventListener('drop', function(e) {
        e.preventDefault();
        dropZone.classList.remove('dragover');
        
        const files = Array.from(e.dataTransfer.files);
        addFiles(files);
    });
    
    dropZone.addEventListener('click', function() {
        document.getElementById('fileInput').click();
    });
}

// Initialisation de l'input file
function initializeFileInput() {
    const fileInput = document.getElementById('fileInput');
    
    fileInput.addEventListener('change', function(e) {
        const files = Array.from(e.target.files);
        addFiles(files);
    });
}

// Ajout de fichiers
function addFiles(files) {
    files.forEach(file => {
        if (!filesAdded.some(f => f.name === file.name && f.size === file.size)) {
            filesAdded.push(file);
            console.log(`Ajouté fichier : ${file.name}`);
        }
    });
    
    refreshFileList();
    updateStatus();
}

// Rafraîchir la liste des fichiers
function refreshFileList() {
    const fileList = document.getElementById('fileList');
    fileList.innerHTML = '';
    
    if (filesAdded.length === 0) {
        const emptyMessage = document.createElement('div');
        emptyMessage.className = 'file-item unknown';
        emptyMessage.textContent = 'Aucun fichier sélectionné';
        fileList.appendChild(emptyMessage);
        return;
    }
    
    // Grouper les fichiers par type
    const fileGroups = {};
    
    filesAdded.forEach(file => {
        const extension = getFileExtension(file.name);
        if (!fileGroups[extension]) {
            fileGroups[extension] = [];
        }
        fileGroups[extension].push(file);
    });
    
    // Afficher les fichiers groupés
    Object.keys(fileGroups).forEach(extension => {
        const files = fileGroups[extension];
        
        // En-tête du groupe
        const groupHeader = document.createElement('div');
        groupHeader.className = 'file-item folder';
        groupHeader.textContent = `[+] ${extension.toUpperCase()} Files (${files.length})`;
        fileList.appendChild(groupHeader);
        
        // Fichiers du groupe
        files.forEach(file => {
            const fileItem = document.createElement('div');
            const rule = matchRuleForFile(file.name);
            fileItem.className = `file-item ${rule ? 'recognized' : 'unknown'}`;
            
            let displayText = ` ⤷ [${rule ? '+' : 'x'}] ${file.name}`;
            if (rule) {
                displayText += ` → ${rule.action}`;
            }
            
            fileItem.textContent = displayText;
            fileList.appendChild(fileItem);
        });
    });
}

// Obtenir l'extension d'un fichier
function getFileExtension(filename) {
    return filename.split('.').pop().toLowerCase();
}

// Vérifier si un fichier correspond à une règle
function matchRuleForFile(filename) {
    return window.gfxConfig.matchRuleForFile(filename);
}

// Vérifier si un nom de fichier correspond à un pattern
function filenameMatch(filename, pattern) {
    return window.gfxConfig.filenameMatch(filename, pattern);
}

// Sélectionner des fichiers
function selectFiles() {
    document.getElementById('fileInput').click();
}

// Sélectionner des dossiers (simulation - les navigateurs ne permettent pas de sélectionner des dossiers directement)
function selectFolders() {
    logToConsole('⚠️ Sélection de dossiers non supportée dans cette version web', 'warning');
    logToConsole('💡 Utilisez la sélection de fichiers ou le drag & drop', 'info');
}

// Effacer tous les fichiers
function clearFiles() {
    filesAdded = [];
    refreshFileList();
    updateProgress(0);
    updateStatus();
    logToConsole('🗑️ Tous les fichiers ont été effacés', 'info');
}

// Patcher les fichiers
async function patchFiles() {
    if (filesAdded.length === 0) {
        logToConsole('❌ Aucun fichier à traiter', 'error');
        return;
    }
    
    const filesToProcess = filesAdded.filter(file => {
        const rule = matchRuleForFile(file.name);
        return rule !== null;
    });
    
    if (filesToProcess.length === 0) {
        logToConsole('❌ Aucun fichier reconnu pour le traitement', 'error');
        return;
    }
    
    logToConsole('🚀 Début du traitement des fichiers...', 'info');
    updateProgress(0);
    
    try {
        // Créer FormData pour envoyer les fichiers
        const formData = new FormData();
        filesToProcess.forEach(file => {
            formData.append('files', file);
        });
        
        // Envoyer les fichiers au serveur
        const response = await fetch('http://localhost:5000/api/process-files', {
            method: 'POST',
            body: formData
        });
        
        if (!response.ok) {
            throw new Error(`Erreur serveur: ${response.status}`);
        }
        
        const result = await response.json();
        
        if (result.success) {
            result.results.forEach((fileResult, index) => {
                const progress = ((index + 1) / result.results.length) * 100;
                
                if (fileResult.status === 'success') {
                    logToConsole(`✅ ${fileResult.filename} → ${fileResult.action}`, 'success');
                    if (fileResult.output) {
                        logToConsole(`📝 Sortie: ${fileResult.output}`, 'info');
                    }
                } else if (fileResult.status === 'no_rule') {
                    logToConsole(`⚠️ ${fileResult.filename}: ${fileResult.message}`, 'warning');
                } else {
                    logToConsole(`❌ ${fileResult.filename}: ${fileResult.message}`, 'error');
                }
                
                updateProgress(progress);
            });
            
            logToConsole('🎉 Traitement terminé avec succès !', 'success');
        } else {
            logToConsole(`❌ Erreur: ${result.error}`, 'error');
        }
        
    } catch (error) {
        logToConsole(`❌ Erreur de connexion: ${error.message}`, 'error');
        logToConsole('💡 Assurez-vous que le serveur backend est démarré', 'info');
        
        // Fallback vers la simulation si le serveur n'est pas disponible
        logToConsole('🔄 Utilisation du mode simulation...', 'warning');
        simulateProcessing(filesToProcess);
    }
    
    setTimeout(() => updateProgress(0), 1000);
}

// Simulation du traitement (fallback)
function simulateProcessing(filesToProcess) {
    filesToProcess.forEach((file, index) => {
        setTimeout(() => {
            const rule = matchRuleForFile(file.name);
            const progress = ((index + 1) / filesToProcess.length) * 100;
            
            logToConsole(`✅ Simulation: ${file.name} avec l'action: ${rule.action}`, 'success');
            updateProgress(progress);
            
            if (index === filesToProcess.length - 1) {
                logToConsole('🎉 Simulation terminée !', 'success');
            }
        }, index * 500);
    });
}

// Ouvrir le site Graphicx
function openGraphicx() {
    window.open('https://graphicx.store/', '_blank');
}

// Mettre à jour la barre de progression
function updateProgress(percentage) {
    const progressFill = document.getElementById('progressFill');
    progressFill.style.width = percentage + '%';
}

// Mettre à jour le statut
function updateStatus() {
    const status = document.getElementById('status');
    status.textContent = `${filesAdded.length} fichier(s) chargé(s)`;
}

// Logger dans la console
function logToConsole(message, type = 'info') {
    const console = document.getElementById('console');
    const timestamp = new Date().toLocaleTimeString();
    const logEntry = document.createElement('div');
    logEntry.className = type;
    logEntry.textContent = `[${timestamp}] ${message}`;
    console.appendChild(logEntry);
    console.scrollTop = console.scrollHeight;
}

// Gestion du zoom de la console (simulation)
document.addEventListener('wheel', function(e) {
    if (e.ctrlKey) {
        e.preventDefault();
        const console = document.getElementById('console');
        const currentSize = parseInt(getComputedStyle(console).fontSize);
        const newSize = Math.max(8, Math.min(20, currentSize + (e.deltaY > 0 ? -1 : 1)));
        console.style.fontSize = newSize + 'px';
    }
});

// Fonction utilitaire pour simuler le traitement de fichiers
function simulateFileProcessing(file, action) {
    return new Promise((resolve) => {
        setTimeout(() => {
            logToConsole(`📝 Traitement de ${file.name} avec l'action ${action}`, 'info');
            resolve();
        }, Math.random() * 1000 + 500);
    });
}

// Export des fonctions pour l'utilisation globale
window.selectFiles = selectFiles;
window.selectFolders = selectFolders;
window.clearFiles = clearFiles;
window.patchFiles = patchFiles;
window.openGraphicx = openGraphicx; 