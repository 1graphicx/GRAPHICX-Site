// Improved language detection
function detectLanguage() {
  const userLang = navigator.language || navigator.userLanguage;
  const browserLang = userLang.toLowerCase();
  
  // Check for French variants
  if (browserLang.startsWith('fr') || browserLang.includes('french')) {
    return 'fr';
  }
  
  // Check for other languages that might prefer English
  if (browserLang.startsWith('en') || browserLang.includes('english')) {
    return 'en';
  }
  
  // Default to English for other languages
  return 'en';
}

const lang = detectLanguage();
const translations = {
  fr: {
    splash: "Bienvenue sur GRAPHICX",
    discordTitle: "Rejoins la communauté GRAPHICX",
    discordText: "Échange, collabore et reste à jour sur les dernières créations. Notre serveur Discord est ouvert à tous.",
    discordLink: "Accéder au serveur",
    youtubeTitle: "Découvre ma chaîne YouTube",
    youtubeText: "Tutoriels, astuces, logiciels... Je partage mes outils et ma vision de la création numérique chaque semaine.",
    youtubeLink: "Visiter la chaîne",
    megathreadTitle: "📚 Megathread - Base d'informations",
    megathreadText: "Le Megathread est une base d'informations regroupant différentes sources d'internet sécurisées.",
    megathreadLink1: "Megathread Piracy",
    megathreadDesc1: "La référence Reddit pour les ressources de piratage",
    megathreadLink2: "Awesome Piracy",
    megathreadDesc2: "Collection curated de ressources de piratage",
    megathreadLink3: "Champagne Piracy",
    megathreadDesc3: "Guide moderne et élégant du piratage",
    megathreadLink4: "FMHY FreeMediaHeckYeah",
    megathreadDesc4: "Média gratuit et ressources de streaming",
    megathreadLink5: "Ripped",
    megathreadDesc5: "Guide complet pour le piratage moderne",
    megathreadLink6: "Wikitipiak",
    megathreadDesc6: "Wiki français du piratage et des alternatives",
    pluginsTitle: "💻 Plugins & Logiciels Windows / MacOS",
    pluginsText: "Si vous ne trouvez pas le plugin ou le logiciel que vous cherchez, voici quelques sites que je vous recommande.",
    pluginsLink1: "VFX Download",
    pluginsDesc1: "(Lent) Plugins Win / Mac",
    pluginsLink2: "Intro HD",
    pluginsDesc2: "(Lent) Plugins Win / Mac",
    pluginsLink3: "Download Pirate",
    pluginsDesc3: "(Rapide) Plugins & Software Win / Mac",
    pluginsLink4: "Team V.R",
    pluginsDesc4: "(Lent) Plugins Win / Mac",
    pluginsLink5: "VFX Med",
    pluginsDesc5: "(Lent) Plugins & Software Win / Mac",
    pluginsLink6: "Taiwebs",
    pluginsDesc6: "(Rapide) Plugins & Software Win / Mac - Mot de passe : taiweb.com",
    pluginsLink7: "MatesFX",
    pluginsDesc7: "(Rapide) Plugins Win / Mac",
    pluginsLink8: "Motka",
    pluginsDesc8: "(Rapide) Plugins Win / Mac",
    pluginsLink9: "VFX Loot",
    pluginsDesc9: "(Rapide) Plugins Win / Mac",
    pluginsLink10: "LookAE",
    pluginsDesc10: "(Moyen) Plugins Win / Mac",
    pluginsLink11: "DownloadHA",
    pluginsDesc11: "(Moyen) Software Win / Mac",
    pluginsLink12: "AppStorrent",
    pluginsDesc12: "(Rapide) Plugins & Software Mac",
    mobileTitle: "📱 Applications Android / iOS",
    mobileText: "Si vous ne trouvez pas l'application que vous cherchez, voici quelques sites que je vous recommande.",
    mobileLink1: "APK Mos",
    mobileDesc1: "Android",
    mobileLink2: "REXDL",
    mobileDesc2: "Android",
    mobileLink3: "DL Android",
    mobileDesc3: "Android",
    mobileLink4: "APK Mody",
    mobileDesc4: "Android",
    mobileLink5: "MODYOLO",
    mobileDesc5: "Android",
    mobileLink6: "Rock Mods",
    mobileDesc6: "Android",
    mobileLink7: "Andreed",
    mobileDesc7: "Android",
    mobileLink8: "AN1",
    mobileDesc8: "Android",
    mobileLink9: "APK Done",
    mobileDesc9: "Android",
    mobileLink10: "APK Kit",
    mobileDesc10: "Android",
    mobileLink11: "APK MB",
    mobileDesc11: "Android",
    mobileLink12: "PlatinMods",
    mobileDesc12: "Android / iOS",
    mobileLink13: "App DB Market",
    mobileDesc13: "iOS",
    mobileLink14: "CyPwn",
    mobileDesc14: "iOS",
    utilitiesTitle: "🛠️ Utilitaires",
    utilitiesText: "Outils pratiques pour télécharger du contenu et traiter l'audio.",
    utilitiesLink1: "Video DownloadHelper",
    utilitiesDesc1: "Télécharger des animés et films facilement",
    utilitiesLink2: "HiAnime",
    utilitiesDesc2: "Site d'animés",
    utilitiesLink3: "AnimeKai",
    utilitiesDesc3: "Site d'animés",
    utilitiesLink4: "AniCrush",
    utilitiesDesc4: "Site d'animés",
    utilitiesLink5: "4Anime",
    utilitiesDesc5: "Site d'animés",
    utilitiesLink6: "CineBy",
    utilitiesDesc6: "Site de films",
    utilitiesLink7: "Hexa Watch",
    utilitiesDesc7: "Site de films",
    utilitiesLink8: "CinemaOS",
    utilitiesDesc8: "Site de films",
    utilitiesLink9: "Flixer",
    utilitiesDesc9: "Site de films",
    utilitiesLink10: "Beech Watch",
    utilitiesDesc10: "Site de films",
    utilitiesLink11: "Ultimate Vocal Remover",
    utilitiesDesc11: "Software - Supprimer musique de fond",
    utilitiesLink12: "Vocal Remover",
    utilitiesDesc12: "Web - Supprimer musique de fond",
    footer: "© 2025 GRAPHICX by HYRAX. Tous droits réservés."
  },
  en: {
    splash: "Welcome to GRAPHICX",
    discordTitle: "Join the GRAPHICX community",
    discordText: "Chat, collaborate and stay updated on the latest creations. Our Discord server is open to everyone.",
    discordLink: "Join the server",
    youtubeTitle: "Discover my YouTube channel",
    youtubeText: "Tutorials, tips, software... I share my tools and digital creation vision every week.",
    youtubeLink: "Visit the channel",
    megathreadTitle: "📚 Megathread - Information Database",
    megathreadText: "The Megathread is an information database gathering various secure sources from the internet.",
    megathreadLink1: "Megathread Piracy",
    megathreadDesc1: "Reddit reference for piracy resources",
    megathreadLink2: "Awesome Piracy",
    megathreadDesc2: "Curated collection of piracy resources",
    megathreadLink3: "Champagne Piracy",
    megathreadDesc3: "Modern and elegant piracy guide",
    megathreadLink4: "FMHY FreeMediaHeckYeah",
    megathreadDesc4: "Free media and streaming resources",
    megathreadLink5: "Ripped",
    megathreadDesc5: "Complete guide for modern piracy",
    megathreadLink6: "Wikitipiak",
    megathreadDesc6: "French wiki of piracy and alternatives",
    pluginsTitle: "💻 Plugins & Software Windows / MacOS",
    pluginsText: "If you can't find the plugin or software you're looking for, here are some sites I recommend.",
    pluginsLink1: "VFX Download",
    pluginsDesc1: "(Slow) Plugins Win / Mac",
    pluginsLink2: "Intro HD",
    pluginsDesc2: "(Slow) Plugins Win / Mac",
    pluginsLink3: "Download Pirate",
    pluginsDesc3: "(Fast) Plugins & Software Win / Mac",
    pluginsLink4: "Team V.R",
    pluginsDesc4: "(Slow) Plugins Win / Mac",
    pluginsLink5: "VFX Med",
    pluginsDesc5: "(Slow) Plugins & Software Win / Mac",
    pluginsLink6: "Taiwebs",
    pluginsDesc6: "(Fast) Plugins & Software Win / Mac - Password: taiweb.com",
    pluginsLink7: "MatesFX",
    pluginsDesc7: "(Fast) Plugins Win / Mac",
    pluginsLink8: "Motka",
    pluginsDesc8: "(Fast) Plugins Win / Mac",
    pluginsLink9: "VFX Loot",
    pluginsDesc9: "(Fast) Plugins Win / Mac",
    pluginsLink10: "LookAE",
    pluginsDesc10: "(Medium) Plugins Win / Mac",
    pluginsLink11: "DownloadHA",
    pluginsDesc11: "(Medium) Software Win / Mac",
    pluginsLink12: "AppStorrent",
    pluginsDesc12: "(Fast) Plugins & Software Mac",
    mobileTitle: "📱 Android / iOS Applications",
    mobileText: "If you can't find the application you're looking for, here are some sites I recommend.",
    mobileLink1: "APK Mos",
    mobileDesc1: "Android",
    mobileLink2: "REXDL",
    mobileDesc2: "Android",
    mobileLink3: "DL Android",
    mobileDesc3: "Android",
    mobileLink4: "APK Mody",
    mobileDesc4: "Android",
    mobileLink5: "MODYOLO",
    mobileDesc5: "Android",
    mobileLink6: "Rock Mods",
    mobileDesc6: "Android",
    mobileLink7: "Andreed",
    mobileDesc7: "Android",
    mobileLink8: "AN1",
    mobileDesc8: "Android",
    mobileLink9: "APK Done",
    mobileDesc9: "Android",
    mobileLink10: "APK Kit",
    mobileDesc10: "Android",
    mobileLink11: "APK MB",
    mobileDesc11: "Android",
    mobileLink12: "PlatinMods",
    mobileDesc12: "Android / iOS",
    mobileLink13: "App DB Market",
    mobileDesc13: "iOS",
    mobileLink14: "CyPwn",
    mobileDesc14: "iOS",
    utilitiesTitle: "🛠️ Utilities",
    utilitiesText: "Practical tools for downloading content and processing audio.",
    utilitiesLink1: "Video DownloadHelper",
    utilitiesDesc1: "Download anime and movies easily",
    utilitiesLink2: "HiAnime",
    utilitiesDesc2: "Anime site",
    utilitiesLink3: "AnimeKai",
    utilitiesDesc3: "Anime site",
    utilitiesLink4: "AniCrush",
    utilitiesDesc4: "Anime site",
    utilitiesLink5: "4Anime",
    utilitiesDesc5: "Anime site",
    utilitiesLink6: "CineBy",
    utilitiesDesc6: "Movie site",
    utilitiesLink7: "Hexa Watch",
    utilitiesDesc7: "Movie site",
    utilitiesLink8: "CinemaOS",
    utilitiesDesc8: "Movie site",
    utilitiesLink9: "Flixer",
    utilitiesDesc9: "Movie site",
    utilitiesLink10: "Beech Watch",
    utilitiesDesc10: "Movie site",
    utilitiesLink11: "Ultimate Vocal Remover",
    utilitiesDesc11: "Software - Remove background music",
    utilitiesLink12: "Vocal Remover",
    utilitiesDesc12: "Web - Remove background music",
    footer: "© 2025 GRAPHICX by HYRAX. All rights reserved."
  }
};

function applyTranslations() {
  const t = translations[lang] || translations.en;
  
  // Splash screen
  const splashText = document.getElementById('splash-text');
  if (splashText) splashText.textContent = t.splash;
  
  // Discord section
  const discordTitle = document.getElementById('discord-title');
  const discordText = document.getElementById('discord-text');
  const discordLink = document.getElementById('discord-link');
  if (discordTitle) discordTitle.textContent = t.discordTitle;
  if (discordText) discordText.textContent = t.discordText;
  if (discordLink) discordLink.textContent = t.discordLink;
  
  // YouTube section
  const youtubeTitle = document.getElementById('youtube-title');
  const youtubeText = document.getElementById('youtube-text');
  const youtubeLink = document.getElementById('youtube-link');
  if (youtubeTitle) youtubeTitle.textContent = t.youtubeTitle;
  if (youtubeText) youtubeText.textContent = t.youtubeText;
  if (youtubeLink) youtubeLink.textContent = t.youtubeLink;
  
  // Update all sections
  updateSectionContent('megathread', t);
  updateSectionContent('plugins', t);
  updateSectionContent('mobile', t);
  updateSectionContent('utilities', t);
  
  // Footer
  const footer = document.querySelector('footer');
  if (footer) footer.textContent = t.footer;
}

function updateSectionContent(sectionName, translations) {
  const titleElement = document.getElementById(`${sectionName}-title`);
  const textElement = document.getElementById(`${sectionName}-text`);
  
  if (titleElement) titleElement.textContent = translations[`${sectionName}Title`];
  if (textElement) textElement.textContent = translations[`${sectionName}Text`];
  
  // Remove bilingual paragraphs
  const section = titleElement?.closest('.section');
  if (section) {
    const paragraphs = section.querySelectorAll('p');
    if (paragraphs.length >= 2) {
      const secondP = paragraphs[1];
      if (secondP && (secondP.textContent.includes('If you can\'t find') || 
                      secondP.textContent.includes('Si vous ne trouvez pas') || 
                      secondP.textContent.includes('Practical tools') || 
                      secondP.textContent.includes('Outils pratiques'))) {
        secondP.remove();
      }
    }
  }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  applyTranslations();

  const splash = document.querySelector('.splash');
  let splashHidden = false;

  function hideSplash() {
    if (splashHidden) return;
    splashHidden = true;
    splash.style.animationPlayState = 'paused';
    splash.style.transition = 'opacity 0.5s ease';
    splash.style.opacity = '0';
    setTimeout(() => {
      splash.style.display = 'none';
    }, 500);
  }

  setTimeout(hideSplash, 2500);
  splash.addEventListener('click', hideSplash);
}); 