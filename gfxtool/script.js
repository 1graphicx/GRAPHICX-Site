// Variables globales
let filesAdded = [];
let currentFontSize = 14;
let rules = null;
let isProcessing = false; // Nouvelle variable pour éviter les clics multiples

// Initialisation
document.addEventListener('DOMContentLoaded', async function() {
    // Charger les règles
    rules = await window.gfxConfig.loadRules();
    
    initializeDragAndDrop();
    initializeFileInput();
    initializeButtons();
    updateStatus();
    
    logToConsole('🚀 GFX Tool Web Version initialisée', 'success');
    logToConsole('☁️ Mode cloud activé - Connexion à graphicx.store', 'info');
    logToConsole('📁 Prêt à traiter vos fichiers !', 'info');
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

// Initialisation des boutons avec gestion d'état
function initializeButtons() {
    const buttons = document.querySelectorAll('.btn');
    
    buttons.forEach(button => {
        // Ajouter un délai de protection contre les clics multiples
        button.addEventListener('click', function(e) {
            if (isProcessing && this.classList.contains('primary')) {
                e.preventDefault();
                return;
            }
            
            // Ajouter un effet de ripple
            createRippleEffect(e, this);
        });
        
        // Améliorer l'accessibilité
        button.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                this.click();
            }
        });
    });
}

// Effet de ripple pour les boutons
function createRippleEffect(event, button) {
    const ripple = document.createElement('span');
    const rect = button.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    const x = event.clientX - rect.left - size / 2;
    const y = event.clientY - rect.top - size / 2;
    
    ripple.style.width = ripple.style.height = size + 'px';
    ripple.style.left = x + 'px';
    ripple.style.top = y + 'px';
    ripple.classList.add('ripple');
    
    button.appendChild(ripple);
    
    setTimeout(() => {
        ripple.remove();
    }, 600);
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
    if (isProcessing) return;
    document.getElementById('fileInput').click();
}

// Sélectionner des dossiers (simulation - les navigateurs ne permettent pas de sélectionner des dossiers directement)
function selectFolders() {
    if (isProcessing) return;
    logToConsole('⚠️ Sélection de dossiers non supportée dans cette version web', 'warning');
    logToConsole('💡 Utilisez la sélection de fichiers ou le drag & drop', 'info');
}

// Effacer tous les fichiers
function clearFiles() {
    if (isProcessing) return;
    filesAdded = [];
    refreshFileList();
    updateProgress(0);
    updateStatus();
    logToConsole('🗑️ Tous les fichiers ont été effacés', 'info');
}

// Patcher les fichiers
async function patchFiles() {
    if (isProcessing) {
        logToConsole('⚠️ Traitement déjà en cours...', 'warning');
        return;
    }
    
    if (filesAdded.length === 0) {
        logToConsole('❌ Aucun fichier à traiter', 'error');
        return;
    }
    
    // Désactiver les boutons pendant le traitement
    setButtonsState(true);
    isProcessing = true;
    
    logToConsole('🚀 Début du traitement des fichiers...', 'info');
    updateProgress(10);
    
    try {
        // Utiliser uniquement le serveur graphicx.store
        const serverUrl = 'https://graphicx.store/gfxtool/api/process-files';
        
        const formData = new FormData();
        filesAdded.forEach(file => {
            formData.append('files', file);
        });

        logToConsole('📡 Connexion au serveur graphicx.store...', 'info');
        updateProgress(25);

        const response = await fetch(serverUrl, {
            method: 'POST',
            body: formData
        });

        if (response.ok) {
            const result = await response.json();
            updateProgress(100);
            
            if (result.success) {
                logToConsole('🎉 Traitement terminé avec succès !', 'success');
                
                // Afficher les résultats
                result.results.forEach(r => {
                    if (r.status === 'success') {
                        logToConsole(`✅ ${r.action || r.filename}: ${r.output}`, 'success');
                        
                        // Si un installateur a été créé, afficher le bouton de téléchargement
                        if (r.installer) {
                            logToConsole(`📦 Installateur créé: ${r.installer}`, 'info');
                            showDownloadButton(r.installer);
                        }
                    } else {
                        logToConsole(`❌ ${r.action || r.filename}: ${r.message}`, 'error');
                    }
                });
                
                // Afficher tous les installateurs créés
                if (result.installers_created && result.installers_created.length > 0) {
                    logToConsole(`🎁 ${result.installers_created.length} installateur(s) créé(s) !`, 'success');
                    result.installers_created.forEach(installer => {
                        showDownloadButton(installer);
                    });
                }
            } else {
                logToConsole('❌ Erreur lors du traitement', 'error');
            }
        } else {
            throw new Error(`Erreur serveur: ${response.status} - ${response.statusText}`);
        }
    } catch (error) {
        console.error('Erreur de connexion au serveur:', error);
        logToConsole('❌ Impossible de se connecter au serveur graphicx.store', 'error');
        logToConsole('💡 Vérifiez votre connexion internet ou réessayez plus tard', 'info');
        
        // Réactiver les boutons en cas d'erreur
        setButtonsState(false);
        isProcessing = false;
        updateProgress(0);
        return;
    } finally {
        // Réactiver les boutons après le traitement
        setButtonsState(false);
        isProcessing = false;
    }
}

// Gérer l'état des boutons
function setButtonsState(disabled) {
    const buttons = document.querySelectorAll('.btn');
    buttons.forEach(button => {
        if (disabled) {
            button.disabled = true;
            button.style.opacity = '0.6';
            button.style.cursor = 'not-allowed';
        } else {
            button.disabled = false;
            button.style.opacity = '1';
            button.style.cursor = 'pointer';
        }
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

// Export des fonctions pour l'utilisation globale
window.selectFiles = selectFiles;
window.selectFolders = selectFolders;
window.clearFiles = clearFiles;
window.patchFiles = patchFiles;
window.openGraphicx = openGraphicx; 

function showDownloadButton(installerName) {
    // Vérifier si le bouton existe déjà
    const existingBtn = document.querySelector(`[data-installer="${installerName}"]`);
    if (existingBtn) {
        logToConsole(`📥 Bouton de téléchargement déjà présent pour: ${installerName}`, 'info');
        return;
    }
    
    // Créer un bouton de téléchargement amélioré
    const downloadBtn = document.createElement('button');
    downloadBtn.className = 'btn primary download-btn';
    downloadBtn.setAttribute('data-installer', installerName);
    downloadBtn.innerHTML = `📥 Télécharger ${installerName}`;
    downloadBtn.onclick = (e) => {
        // Ajouter l'effet de ripple
        createRippleEffect(e, downloadBtn);
        // Lancer le téléchargement après un court délai pour l'effet visuel
        setTimeout(() => downloadInstaller(installerName), 150);
    };
    
    // Ajouter la gestion du clavier
    downloadBtn.addEventListener('keydown', function(e) {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            this.click();
        }
    });
    
    // Ajouter le bouton à l'interface avec animation
    const buttonsContainer = document.querySelector('.buttons');
    downloadBtn.style.opacity = '0';
    downloadBtn.style.transform = 'translateY(20px)';
    buttonsContainer.appendChild(downloadBtn);
    
    // Animation d'apparition
    setTimeout(() => {
        downloadBtn.style.transition = 'all 0.3s ease';
        downloadBtn.style.opacity = '1';
        downloadBtn.style.transform = 'translateY(0)';
    }, 100);
    
    // Afficher un message dans la console
    logToConsole(`📥 Bouton de téléchargement ajouté pour: ${installerName}`, 'info');
}

async function downloadInstaller(installerName) {
    try {
        // Désactiver temporairement le bouton
        const downloadBtn = document.querySelector(`[data-installer="${installerName}"]`);
        if (downloadBtn) {
            downloadBtn.disabled = true;
            downloadBtn.innerHTML = `⏳ Téléchargement...`;
        }
        
        // Utiliser uniquement le serveur graphicx.store
        const downloadUrl = `https://graphicx.store/gfxtool/api/download/${installerName}`;
        
        logToConsole(`📥 Début du téléchargement: ${installerName}`, 'info');
        
        // Créer un lien temporaire pour le téléchargement
        const link = document.createElement('a');
        link.href = downloadUrl;
        link.download = installerName;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        logToConsole(`✅ Téléchargement lancé: ${installerName}`, 'success');
        
        // Réactiver le bouton après un délai
        setTimeout(() => {
            if (downloadBtn) {
                downloadBtn.disabled = false;
                downloadBtn.innerHTML = `📥 Télécharger ${installerName}`;
            }
        }, 2000);
        
    } catch (error) {
        logToConsole(`❌ Erreur lors du téléchargement: ${error.message}`, 'error');
        
        // Réactiver le bouton en cas d'erreur
        const downloadBtn = document.querySelector(`[data-installer="${installerName}"]`);
        if (downloadBtn) {
            downloadBtn.disabled = false;
            downloadBtn.innerHTML = `📥 Télécharger ${installerName}`;
        }
    }
} 