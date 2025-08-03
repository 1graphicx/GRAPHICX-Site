// Variables globales
let filesAdded = [];
let currentFontSize = 14;
let rules = null;
let isProcessing = false;
let githubToken = null; // Token GitHub pour l'authentification

// Initialisation
document.addEventListener('DOMContentLoaded', async function() {
    // Charger les règles
    rules = await window.gfxConfig.loadRules();
    
    initializeDragAndDrop();
    initializeFileInput();
    initializeButtons();
    updateStatus();
    
    logToConsole('🚀 GFX Tool GitHub Version initialisée', 'success');
    logToConsole('☁️ Mode GitHub activé - Connexion via GitHub Actions', 'info');
    logToConsole('📁 Prêt à traiter vos fichiers !', 'info');
    logToConsole('🔑 Authentification GitHub requise pour le traitement', 'warning');
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

// Patcher les fichiers via GitHub Actions
async function patchFiles() {
    if (isProcessing) {
        logToConsole('⚠️ Traitement déjà en cours...', 'warning');
        return;
    }
    
    if (filesAdded.length === 0) {
        logToConsole('❌ Aucun fichier à traiter', 'error');
        return;
    }
    
    // Vérifier l'authentification GitHub
    if (!githubToken) {
        logToConsole('🔑 Authentification GitHub requise', 'warning');
        logToConsole('💡 Cliquez sur "Authentifier GitHub" pour continuer', 'info');
        showGitHubAuthButton();
        return;
    }
    
    // Désactiver les boutons pendant le traitement
    setButtonsState(true);
    isProcessing = true;
    
    logToConsole('🚀 Début du traitement via GitHub Actions...', 'info');
    updateProgress(10);
    
    try {
        // Créer un workflow dispatch via GitHub API
        const workflowUrl = `https://api.github.com/repos/${getGitHubRepo()}/actions/workflows/process-files.yml/dispatches`;
        
        // Préparer les fichiers pour l'upload
        const formData = new FormData();
        filesAdded.forEach(file => {
            formData.append('files', file);
        });

        logToConsole('📡 Déclenchement du workflow GitHub Actions...', 'info');
        updateProgress(25);

        // Déclencher le workflow GitHub Actions
        const response = await fetch(workflowUrl, {
            method: 'POST',
            headers: {
                'Authorization': `token ${githubToken}`,
                'Accept': 'application/vnd.github.v3+json',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                ref: 'main',
                inputs: {
                    files: JSON.stringify(filesAdded.map(f => ({ name: f.name, size: f.size })))
                }
            })
        });

        if (response.ok) {
            logToConsole('✅ Workflow GitHub Actions déclenché avec succès !', 'success');
            updateProgress(50);
            
            // Attendre la completion du workflow
            await waitForWorkflowCompletion();
            
            updateProgress(100);
            logToConsole('🎉 Traitement terminé avec succès !', 'success');
            
            // Récupérer les releases créées
            await fetchGitHubReleases();
            
        } else {
            throw new Error(`Erreur GitHub API: ${response.status} - ${response.statusText}`);
        }
    } catch (error) {
        console.error('Erreur lors du traitement GitHub:', error);
        logToConsole('❌ Erreur lors du traitement GitHub', 'error');
        logToConsole(`💡 Détails: ${error.message}`, 'info');
        
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

function showDownloadButton(installerName, downloadUrl = null) {
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
        setTimeout(() => downloadInstaller(installerName, downloadUrl), 150);
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

async function downloadInstaller(installerName, downloadUrl = null) {
    try {
        // Désactiver temporairement le bouton
        const downloadBtn = document.querySelector(`[data-installer="${installerName}"]`);
        if (downloadBtn) {
            downloadBtn.disabled = true;
            downloadBtn.innerHTML = `⏳ Téléchargement...`;
        }
        
        // Utiliser l'URL GitHub si fournie, sinon construire
        const finalDownloadUrl = downloadUrl || 
            `https://github.com/${getGitHubRepo()}/releases/latest/download/${installerName}`;
        
        logToConsole(`📥 Début du téléchargement: ${installerName}`, 'info');
        
        // Créer un lien temporaire pour le téléchargement
        const link = document.createElement('a');
        link.href = finalDownloadUrl;
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

// Obtenir le nom du repository GitHub
function getGitHubRepo() {
    // Détecter automatiquement le repo depuis l'URL
    const hostname = window.location.hostname;
    if (hostname.includes('github.io')) {
        const pathParts = window.location.pathname.split('/');
        if (pathParts.length >= 3) {
            return `${pathParts[1]}/${pathParts[2]}`;
        }
    }
    // Fallback - à configurer manuellement
    return 'hyrax/graphicx-gfxtool';
}

// Attendre la completion du workflow
async function waitForWorkflowCompletion() {
    logToConsole('⏳ Attente de la completion du workflow...', 'info');
    updateProgress(75);
    
    // Polling du statut du workflow
    let attempts = 0;
    const maxAttempts = 30; // 5 minutes max
    
    while (attempts < maxAttempts) {
        try {
            const runsUrl = `https://api.github.com/repos/${getGitHubRepo()}/actions/runs`;
            const response = await fetch(runsUrl, {
                headers: {
                    'Authorization': `token ${githubToken}`,
                    'Accept': 'application/vnd.github.v3+json'
                }
            });
            
            if (response.ok) {
                const runs = await response.json();
                const latestRun = runs.workflow_runs[0];
                
                if (latestRun.status === 'completed') {
                    if (latestRun.conclusion === 'success') {
                        logToConsole('✅ Workflow terminé avec succès !', 'success');
                        return;
                    } else {
                        throw new Error(`Workflow échoué: ${latestRun.conclusion}`);
                    }
                }
            }
            
            await new Promise(resolve => setTimeout(resolve, 10000)); // 10 secondes
            attempts++;
            updateProgress(75 + (attempts / maxAttempts) * 20);
            
        } catch (error) {
            logToConsole('⚠️ Erreur lors du polling du workflow', 'warning');
            break;
        }
    }
    
    throw new Error('Timeout: Le workflow a pris trop de temps');
}

// Récupérer les releases GitHub
async function fetchGitHubReleases() {
    try {
        const releasesUrl = `https://api.github.com/repos/${getGitHubRepo()}/releases`;
        const response = await fetch(releasesUrl, {
            headers: {
                'Authorization': `token ${githubToken}`,
                'Accept': 'application/vnd.github.v3+json'
            }
        });
        
        if (response.ok) {
            const releases = await response.json();
            const latestRelease = releases[0];
            
            if (latestRelease && latestRelease.assets) {
                logToConsole(`📦 ${latestRelease.assets.length} installateur(s) trouvé(s) !`, 'success');
                
                latestRelease.assets.forEach(asset => {
                    if (asset.name.endsWith('.exe') || asset.name.endsWith('.msi')) {
                        showDownloadButton(asset.name, asset.browser_download_url);
                    }
                });
            }
        }
    } catch (error) {
        logToConsole('⚠️ Erreur lors de la récupération des releases', 'warning');
    }
}

// Afficher le bouton d'authentification GitHub
function showGitHubAuthButton() {
    const authBtn = document.createElement('button');
    authBtn.className = 'btn primary';
    authBtn.innerHTML = '🔑 Authentifier GitHub';
    authBtn.onclick = authenticateGitHub;
    
    const buttonsContainer = document.querySelector('.buttons');
    buttonsContainer.appendChild(authBtn);
}

// Authentification GitHub
async function authenticateGitHub() {
    logToConsole('🔑 Début de l\'authentification GitHub...', 'info');
    
    // Ouvrir la popup d'authentification GitHub
    const clientId = 'your-github-app-client-id'; // À configurer
    const redirectUri = encodeURIComponent(window.location.origin);
    const scope = 'repo workflow';
    
    const authUrl = `https://github.com/login/oauth/authorize?client_id=${clientId}&redirect_uri=${redirectUri}&scope=${scope}`;
    
    const popup = window.open(authUrl, 'github-auth', 'width=600,height=600');
    
    // Écouter le message de retour
    window.addEventListener('message', async function(event) {
        if (event.origin !== window.location.origin) return;
        
        if (event.data.type === 'github-auth-success') {
            githubToken = event.data.token;
            logToConsole('✅ Authentification GitHub réussie !', 'success');
            popup.close();
            
            // Relancer le traitement
            patchFiles();
        }
    });
} 