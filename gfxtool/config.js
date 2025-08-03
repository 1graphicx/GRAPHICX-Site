// Configuration pour charger les règles depuis le fichier JSON original
class GFXToolConfig {
    constructor() {
        this.rules = null;
        this.loaded = false;
    }

    // Charger les règles depuis le fichier JSON
    async loadRules() {
        try {
            const response = await fetch('../ressources/rules.json');
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            this.rules = await response.json();
            this.loaded = true;
            console.log('✅ Règles chargées avec succès:', this.rules);
            return this.rules;
        } catch (error) {
            console.error('❌ Erreur lors du chargement des règles:', error);
            // Utiliser des règles par défaut
            this.rules = this.getDefaultRules();
            this.loaded = true;
            return this.rules;
        }
    }

    // Règles par défaut si le fichier JSON n'est pas disponible
    getDefaultRules() {
        return {
            multi_conditions: [
                {
                    patterns: ["*RedGiant*.exe", "*Maxon_App*.exe"],
                    action: "Maxon Red Giant"
                },
                {
                    patterns: ["*Universe*.exe", "*Maxon_App*.exe"],
                    action: "Maxon Universe"
                },
                {
                    patterns: ["*Cinema4D*.exe", "*Maxon_App*.exe"],
                    action: "Maxon Cinema 4D"
                },
                {
                    patterns: ["*010Editor*.exe"],
                    action: "010 Editor"
                },
                {
                    patterns: ["*Continuum*.exe"],
                    action: "Boris FX Continuum"
                },
                {
                    patterns: ["*sapphire*.exe"],
                    action: "Boris FX Sapphire"
                },
                {
                    patterns: ["*MochaPro*.msi"],
                    action: "Boris FX Mocha Pro"
                },
                {
                    patterns: ["*TopazGigapixelAI*.msi"],
                    action: "Topaz Gigapixel"
                },
                {
                    patterns: ["*TopazPhotoAI*.msi"],
                    action: "Topaz Photo"
                },
                {
                    patterns: ["*TopazVideoAI*.msi"],
                    action: "Topaz Video"
                },
                {
                    patterns: ["*TopazVideoEnhanceAI*.exe"],
                    action: "Topaz Video Enhance"
                }
            ]
        };
    }

    // Obtenir les règles
    getRules() {
        return this.rules;
    }

    // Vérifier si les règles sont chargées
    isLoaded() {
        return this.loaded;
    }

    // Fonction améliorée pour vérifier si un nom de fichier correspond à un pattern
    filenameMatch(filename, pattern) {
        // Convertir le pattern en regex
        let regexPattern = pattern
            .replace(/\./g, '\\.')  // Échapper les points
            .replace(/\*/g, '.*')   // Remplacer * par .*
            .replace(/\?/g, '.')    // Remplacer ? par .
            .replace(/\[/g, '\\[')  // Échapper les crochets
            .replace(/\]/g, '\\]'); // Échapper les crochets
        
        const regex = new RegExp(regexPattern, 'i'); // Insensible à la casse
        return regex.test(filename);
    }

    // Vérifier si un fichier correspond à une règle
    matchRuleForFile(filename) {
        if (!this.rules || !this.rules.multi_conditions) {
            return null;
        }

        for (let rule of this.rules.multi_conditions) {
            if (rule.patterns && Array.isArray(rule.patterns)) {
                for (let pattern of rule.patterns) {
                    if (this.filenameMatch(filename, pattern)) {
                        return rule;
                    }
                }
            }
        }
        return null;
    }
}

// Instance globale de configuration
window.gfxConfig = new GFXToolConfig(); 