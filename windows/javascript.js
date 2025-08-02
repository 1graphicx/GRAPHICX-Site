const searchInput = document.getElementById('searchInput');
const tagsFilterInput = document.getElementById('tagsFilterInput');
const tagsDropdown = document.getElementById('tagsDropdown');
const selectedTagsContainer = document.querySelector('.selected-tags');
const postsGrid = document.getElementById('postsGrid');

// Ajout des styles d'animation
const animationStyles = `
  <style>
    /* Animations pour les cartes de posts - optimisées pour la vitesse */
    .post-card {
      opacity: 0;
      transform: translateY(20px) scale(0.98);
      transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
      animation: fadeInUp 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
    }

    /* Délais réduits pour un affichage plus rapide */
    .post-card:nth-child(1) { animation-delay: 0.02s; }
    .post-card:nth-child(2) { animation-delay: 0.04s; }
    .post-card:nth-child(3) { animation-delay: 0.06s; }
    .post-card:nth-child(4) { animation-delay: 0.08s; }
    .post-card:nth-child(5) { animation-delay: 0.10s; }
    .post-card:nth-child(6) { animation-delay: 0.12s; }
    .post-card:nth-child(7) { animation-delay: 0.14s; }
    .post-card:nth-child(8) { animation-delay: 0.16s; }
    .post-card:nth-child(9) { animation-delay: 0.18s; }
    .post-card:nth-child(10) { animation-delay: 0.20s; }

    @keyframes fadeInUp {
      to {
        opacity: 1;
        transform: translateY(0) scale(1);
      }
    }

    /* Animation hover pour les cartes */
    .post-card:hover {
      transform: translateY(-8px) scale(1.02);
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
      transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
    }

    /* Animation pour les images */
    .post-image img {
      transition: transform 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94);
    }

    .post-card:hover .post-image img {
      transform: scale(1.1);
    }

    /* Animation pour les tags - optimisée pour la vitesse */
    .post-tag {
      opacity: 0;
      transform: translateX(-10px);
      animation: slideInTag 0.2s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
    }

    .post-tag:nth-child(1) { animation-delay: 0.1s; }
    .post-tag:nth-child(2) { animation-delay: 0.15s; }
    .post-tag:nth-child(3) { animation-delay: 0.2s; }
    .post-tag:nth-child(4) { animation-delay: 0.25s; }

    @keyframes slideInTag {
      to {
        opacity: 1;
        transform: translateX(0);
      }
    }

    /* Animation pour les tags sélectionnés */
    .selected-tag {
      opacity: 0;
      transform: scale(0.8) rotate(-5deg);
      animation: popInTag 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55) forwards;
    }

    @keyframes popInTag {
      to {
        opacity: 1;
        transform: scale(1) rotate(0deg);
      }
    }

    /* Animation pour le dropdown */
    .tags-dropdown {
      opacity: 0;
      transform: translateY(-10px) scale(0.95);
      transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
    }

    .tags-dropdown.show {
      opacity: 1;
      transform: translateY(0) scale(1);
    }

    /* Animation pour les boutons */
    .post-link, .info-btn {
      transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
      position: relative;
      overflow: hidden;
    }

    .post-link::before, .info-btn::before {
      content: '';
      position: absolute;
      top: 0;
      left: -100%;
      width: 100%;
      height: 100%;
      background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
      transition: left 0.5s;
    }

    .post-link:hover::before, .info-btn:hover::before {
      left: 100%;
    }

    .post-link:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
    }

    .info-btn:hover {
      transform: scale(1.1) rotate(5deg);
    }

    /* Animation pour les bulles d'info */
    .info-bubble {
      opacity: 0;
      transform: scale(0.8) translateY(10px);
      transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
    }

    .info-bubble.show {
      opacity: 1;
      transform: scale(1) translateY(0);
    }

    /* Animation pour l'état vide */
    .empty-state {
      opacity: 0;
      transform: translateY(20px);
      animation: fadeInEmpty 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
    }

    @keyframes fadeInEmpty {
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    /* Animation de pulsation pour les éléments en cours de chargement */
    .loading {
      animation: pulse 1.5s ease-in-out infinite;
    }

    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.5; }
    }

    /* Animation de rebond pour les suppressions */
    .removing {
      animation: bounceOut 0.5s cubic-bezier(0.68, -0.55, 0.265, 1.55) forwards;
    }

    @keyframes bounceOut {
      0% { transform: scale(1); }
      50% { transform: scale(1.1); }
      100% { transform: scale(0); }
    }

    /* Animation pour les transitions de filtres */
    .filter-transition {
      transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
    }

    /* Effet de particules au hover */
    .post-card::after {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: radial-gradient(circle at var(--mouse-x, 50%) var(--mouse-y, 50%), 
                                 rgba(255, 255, 255, 0.1) 0%, 
                                 transparent 50%);
      opacity: 0;
      transition: opacity 0.3s;
      pointer-events: none;
    }

    .post-card:hover::after {
      opacity: 1;
    }
  </style>
`;

// Injecter les styles d'animation
document.head.insertAdjacentHTML('beforeend', animationStyles);

let selectedTags = new Set();

// Fonction pour ajouter l'effet de particules au hover
function addParticleEffect() {
  const cards = document.querySelectorAll('.post-card');
  cards.forEach(card => {
    card.addEventListener('mousemove', (e) => {
      const rect = card.getBoundingClientRect();
      const x = ((e.clientX - rect.left) / rect.width) * 100;
      const y = ((e.clientY - rect.top) / rect.height) * 100;
      card.style.setProperty('--mouse-x', `${x}%`);
      card.style.setProperty('--mouse-y', `${y}%`);
    });
  });
}

function init() {
  // Animation de chargement initial
  postsGrid.innerHTML = `
    <div class="loading-state" style="
      display: flex;
      justify-content: center;
      align-items: center;
      height: 200px;
      font-size: 18px;
      color: #666;
    ">
      <div style="
        width: 40px;
        height: 40px;
        border: 3px solid #f3f3f3;
        border-top: 3px solid #007bff;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin-right: 15px;
      "></div>
      Chargement des posts...
    </div>
  `;
  
  // Ajouter l'animation de rotation
  const spinStyle = document.createElement('style');
  spinStyle.textContent = `
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  `;
  document.head.appendChild(spinStyle);
  
  // Charger les éléments avec un délai réduit pour l'animation
  setTimeout(() => {
    renderTagsDropdown();
    renderPosts(posts);
  }, 400); // Réduit de 800ms à 400ms

  // Gestion unifiée de l'input de filtrage des tags
  tagsFilterInput.addEventListener('input', (e) => {
    const search = e.target.value.toLowerCase();
    const labels = tagsDropdown.querySelectorAll('label');
    let visibleCount = 0;
    
    labels.forEach(label => {
      const tagText = label.textContent.toLowerCase();
      if (tagText.includes(search)) {
        label.style.display = 'flex';
        visibleCount++;
      } else {
        label.style.display = 'none';
      }
    });

    // Affiche le dropdown si ce n'est pas visible
    if (!tagsDropdown.classList.contains('show')) {
      tagsDropdown.classList.add('show');
      tagsFilterInput.setAttribute('aria-expanded', 'true');
    }

    // Gestion du message "Aucun tag trouvé"
    let noTagsMsg = tagsDropdown.querySelector('.no-tags-msg');
    if (visibleCount === 0 && search.length > 0) {
      if (!noTagsMsg) {
        noTagsMsg = document.createElement('div');
        noTagsMsg.className = 'no-tags-msg';
        noTagsMsg.style.padding = '10px 15px';
        noTagsMsg.style.color = '#999';
        noTagsMsg.style.fontStyle = 'italic';
        noTagsMsg.textContent = 'Aucun tag trouvé.';
        tagsDropdown.appendChild(noTagsMsg);
      }
    } else {
      if (noTagsMsg) {
        noTagsMsg.remove();
      }
    }
  });

  // Clic sur la barre tags : toggle dropdown
  tagsFilterInput.addEventListener('click', (e) => {
    e.stopPropagation(); // Empêche la fermeture immédiate par document click
    const isVisible = tagsDropdown.classList.toggle('show');
    tagsFilterInput.setAttribute('aria-expanded', isVisible ? 'true' : 'false');
  });

  // Clic sur document ferme dropdown sauf si on clique dans dropdown ou input
  document.addEventListener('click', (e) => {
    if (!tagsFilterInput.contains(e.target) && !tagsDropdown.contains(e.target)) {
      tagsDropdown.classList.remove('show');
      tagsFilterInput.setAttribute('aria-expanded', 'false');
    }
  });

  // Empêche la fermeture quand on clique dans dropdown lui-même
  tagsDropdown.addEventListener('click', (e) => {
    e.stopPropagation();
  });

  // Recherche texte live avec animation - optimisée
  searchInput.addEventListener('input', (e) => {
    // Animation de pulsation pendant la recherche
    searchInput.classList.add('loading');
    clearTimeout(searchInput.searchTimeout);
    searchInput.searchTimeout = setTimeout(() => {
      searchInput.classList.remove('loading');
      updateFilter();
    }, 150); // Réduit de 300ms à 150ms
  });
  
  // Animation au focus des inputs
  [searchInput, tagsFilterInput].forEach(input => {
    input.addEventListener('focus', () => {
      input.style.transform = 'scale(1.02)';
      input.style.boxShadow = '0 0 0 3px rgba(0, 123, 255, 0.25)';
    });
    
    input.addEventListener('blur', () => {
      input.style.transform = 'scale(1)';
      input.style.boxShadow = '';
    });
  });

  // Gestion des checkbox tags dans dropdown
  tagsDropdown.addEventListener('change', (e) => {
    if (e.target.matches('input[type="checkbox"]')) {
      const tag = e.target.value;
      if (e.target.checked) selectedTags.add(tag);
      else selectedTags.delete(tag);
      updateSelectedTagsUI();
      updateFilter();
    }
  });

  // Scroll horizontal dans les tags des posts au wheel vertical
  postsGrid.addEventListener('wheel', (e) => {
    const tagsDiv = e.target.closest('.post-tags');
    if (tagsDiv && Math.abs(e.deltaX) < Math.abs(e.deltaY)) {
      e.preventDefault();
      tagsDiv.scrollLeft += e.deltaY;
    }
  }, { passive: false });
}

// Récupère tous les tags uniques dans les posts
function getAllTags() {
  const allTags = new Set();
  posts.forEach(post => post.tags.forEach(tag => allTags.add(tag)));
  return Array.from(allTags).sort();
}

// Affiche la dropdown avec les tags et cases à cocher
function renderTagsDropdown() {
  const tags = getAllTags();
  tagsDropdown.innerHTML = '';
  tags.forEach((tag, index) => {
    const id = 'tag-checkbox-' + tag.toLowerCase().replace(/\s+/g, '-');
    const label = document.createElement('label');
    label.setAttribute('for', id);
    label.textContent = tag;
    label.style.animationDelay = `${index * 0.05}s`;
    label.style.opacity = '0';
    label.style.transform = 'translateX(-20px)';
    
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.id = id;
    checkbox.value = tag;
    
    // Animation au changement de checkbox
    checkbox.addEventListener('change', (e) => {
      // Pas d'animation sur les checkboxes pour éviter les conflits
      // L'animation se fait via updateSelectedTagsUI
    });
    
    label.prepend(checkbox);
    tagsDropdown.appendChild(label);
    
    // Animation d'apparition séquentielle - optimisée
    setTimeout(() => {
      label.style.animation = 'slideInTag 0.2s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards';
    }, index * 20);
  });
}

// Met à jour la barre des tags sélectionnés sous la barre tags
function updateSelectedTagsUI() {
  const currentTags = Array.from(selectedTags);
  const existingTags = Array.from(selectedTagsContainer.querySelectorAll('.selected-tag'))
    .map(el => el.textContent.replace('×', '').trim());
  
  // Supprimer les tags qui ne sont plus sélectionnés avec animation
  selectedTagsContainer.querySelectorAll('.selected-tag').forEach(tagEl => {
    const tagText = tagEl.textContent.replace('×', '').trim();
    if (!currentTags.includes(tagText)) {
      tagEl.classList.add('removing');
      setTimeout(() => {
        if (tagEl.parentNode) {
          tagEl.remove();
        }
      }, 500);
    }
  });
  
  // Ajouter les nouveaux tags avec animation
  currentTags.forEach(tag => {
    if (!existingTags.includes(tag)) {
      const tagPill = document.createElement('div');
      tagPill.classList.add('selected-tag');
      tagPill.textContent = tag;
      
      const removeBtn = document.createElement('button');
      removeBtn.classList.add('remove-tag');
      removeBtn.setAttribute('aria-label', `Supprimer le filtre ${tag}`);
      removeBtn.setAttribute('data-tag', tag);
      removeBtn.textContent = '×';
      
      // Animation au clic de suppression
      removeBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        const tagToRemove = e.target.getAttribute('data-tag');
        selectedTags.delete(tagToRemove);
        updateSelectedTagsUI();
        updateFilter();
        // Décoche checkbox correspondante
        const checkbox = tagsDropdown.querySelector(`input[value="${tagToRemove}"]`);
        if (checkbox) checkbox.checked = false;
      });
      
      tagPill.appendChild(removeBtn);
      selectedTagsContainer.appendChild(tagPill);
    }
  });
}

// Applique le filtre combiné recherche + tags sélectionnés
function updateFilter() {
  const searchTerm = searchInput.value.trim().toLowerCase();

  let filteredPosts = posts.filter(post => {
    // Filtre par tags sélectionnés : tous doivent être présents
    if (selectedTags.size > 0) {
      const hasAllTags = [...selectedTags].every(t => post.tags.includes(t));
      if (!hasAllTags) return false;
    }

    // Filtre recherche texte sur title, description, tags, version
    if (searchTerm.length > 0) {
      const haystack = [
        post.title.toLowerCase(),
        post.information ? post.information.toLowerCase() : '',
        post.description.toLowerCase(),
        post.tags.join(' ').toLowerCase(),
      ].join(' ');

      if (!haystack.includes(searchTerm)) return false;
    }

    return true;
  });

  renderPosts(filteredPosts);
}

function renderPosts(postsToRender) {
  // Optimisation : pas d'animation de sortie pour les filtres rapides
  const isFiltering = postsGrid.children.length > 0 && postsToRender.length > 0;
  
  if (isFiltering) {
    // Pour les filtres, affichage immédiat sans animation de sortie
    postsGrid.innerHTML = '';
  } else {
    // Animation de sortie seulement pour le chargement initial
    postsGrid.classList.add('filter-transition');
    const existingCards = postsGrid.querySelectorAll('.post-card');
    existingCards.forEach((card, index) => {
      card.style.animation = `bounceOut 0.2s cubic-bezier(0.68, -0.55, 0.265, 1.55) ${index * 0.02}s forwards`;
    });

    // Vider la grille après l'animation de sortie
    setTimeout(() => {
      postsGrid.innerHTML = '';
      renderPostsContent(postsToRender);
    }, existingCards.length * 20 + 200);
    return;
  }

  renderPostsContent(postsToRender);
}

function renderPostsContent(postsToRender) {
  if (postsToRender.length === 0) {
    postsGrid.innerHTML = `
      <div class="empty-state">
        <h3>Aucun résultat trouvé</h3>
        <p>Essayez de modifier vos critères de recherche ou vos filtres.</p>
      </div>
    `;
    return;
  }

  // Créer tous les éléments en une fois pour de meilleures performances
  const fragment = document.createDocumentFragment();
  
  postsToRender.forEach((post, index) => {
    const postCard = document.createElement('div');
    postCard.className = 'post-card';
    postCard.tabIndex = 0;
    postCard.setAttribute('aria-label', `Post ${post.title}`);
    
    // Délai d'animation réduit et optimisé
    const animationDelay = Math.min(index * 0.03, 0.3); // Max 0.3s de délai
    postCard.style.animationDelay = `${animationDelay}s`;

      // Image du post avec animation de chargement
      const imageDiv = document.createElement('div');
      imageDiv.className = 'post-image';
      const img = document.createElement('img');
      img.src = post.thumbnail;
      img.alt = post.title;
      
      // Animation de chargement de l'image
      img.classList.add('loading');
      img.addEventListener('load', () => {
        img.classList.remove('loading');
        img.style.animation = 'fadeInUp 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards';
      });
      
      imageDiv.appendChild(img);

      // Titre avec animation
      const title = document.createElement('h3');
      title.className = 'post-title';
      title.textContent = post.title;
      title.style.animationDelay = `${index * 0.1 + 0.2}s`;

      // Description avec animation
      const description = document.createElement('p');
      description.className = 'post-description';
      description.textContent = post.description;
      description.style.animationDelay = `${index * 0.1 + 0.3}s`;

      // Tags avec animation séquentielle
      const tagsDiv = document.createElement('div');
      tagsDiv.className = 'post-tags';
      post.tags.forEach((tag, tagIndex) => {
        const tagSpan = document.createElement('span');
        tagSpan.className = 'post-tag';
        tagSpan.textContent = tag;
        tagSpan.style.animationDelay = `${index * 0.1 + 0.8 + tagIndex * 0.1}s`;
        tagsDiv.appendChild(tagSpan);
      });

      // Version et taille
      const versionInfo = document.createElement('div');
      versionInfo.className = 'post-version';
      if (post.version) {
        versionInfo.textContent = `v${post.version} • ${post.size}`;
      } else {
        versionInfo.textContent = post.size;
      }
      versionInfo.style.animationDelay = `${index * 0.1 + 0.4}s`;

      // Lien de téléchargement avec effet de brillance
      const downloadLink = document.createElement('a');
      downloadLink.className = 'post-link';
      downloadLink.href = post.file;
      downloadLink.target = '_blank';
      downloadLink.textContent = 'Télécharger';
      downloadLink.setAttribute('aria-label', `Télécharger ${post.title}`);
      
      // Animation au clic
      downloadLink.addEventListener('click', (e) => {
        e.preventDefault();
        downloadLink.style.transform = 'scale(0.95)';
        setTimeout(() => {
          downloadLink.style.transform = '';
          window.open(post.file, '_blank');
        }, 150);
      });

      // Information supplémentaire si disponible
      if (post.information) {
        const infoBtn = document.createElement('button');
        infoBtn.className = 'info-btn';
        infoBtn.type = 'button';
        infoBtn.setAttribute('aria-expanded', 'false');
        infoBtn.setAttribute('aria-label', `Afficher les informations supplémentaires pour ${post.title}`);
        infoBtn.textContent = 'i';

        const infoBubble = document.createElement('div');
        infoBubble.className = 'info-bubble';
        infoBubble.textContent = post.information;
        infoBubble.setAttribute('role', 'tooltip');
        infoBubble.id = `info-bubble-${post.title.toLowerCase().replace(/\s+/g, '-')}`;

        infoBtn.setAttribute('aria-describedby', infoBubble.id);

        // Afficher bulle au hover (souris) avec animation
        infoBtn.addEventListener('mouseenter', () => {
          closeAllInfoBubbles();
          infoBubble.classList.add('show');
          infoBtn.setAttribute('aria-expanded', 'true');
        });

        infoBtn.addEventListener('mouseleave', () => {
          setTimeout(() => {
            if (!infoBubble.matches(':hover')) {
              infoBubble.classList.remove('show');
              infoBtn.setAttribute('aria-expanded', 'false');
            }
          }, 100);
        });

        // Afficher bulle au focus (clavier)
        infoBtn.addEventListener('focus', () => {
          closeAllInfoBubbles();
          infoBubble.classList.add('show');
          infoBtn.setAttribute('aria-expanded', 'true');
        });

        // Cacher bulle au blur (clavier)
        infoBtn.addEventListener('blur', () => {
          setTimeout(() => {
            infoBubble.classList.remove('show');
            infoBtn.setAttribute('aria-expanded', 'false');
          }, 100);
        });

        // Permettre de survoler la bulle elle-même
        infoBubble.addEventListener('mouseenter', () => {
          infoBubble.classList.add('show');
          infoBtn.setAttribute('aria-expanded', 'true');
        });

        infoBubble.addEventListener('mouseleave', () => {
          infoBubble.classList.remove('show');
          infoBtn.setAttribute('aria-expanded', 'false');
        });

        // Ajouter les éléments à la carte
        postCard.appendChild(imageDiv);
        postCard.appendChild(title);
        postCard.appendChild(description);
        postCard.appendChild(tagsDiv);
        postCard.appendChild(versionInfo);
        
        const actionDiv = document.createElement('div');
        actionDiv.className = 'post-actions';
        actionDiv.appendChild(downloadLink);
        actionDiv.appendChild(infoBtn);
        actionDiv.appendChild(infoBubble);
        postCard.appendChild(actionDiv);
      } else {
        // Pas d'information supplémentaire
        postCard.appendChild(imageDiv);
        postCard.appendChild(title);
        postCard.appendChild(description);
        postCard.appendChild(tagsDiv);
        postCard.appendChild(versionInfo);
        
        const actionDiv = document.createElement('div');
        actionDiv.className = 'post-actions';
        actionDiv.appendChild(downloadLink);
        postCard.appendChild(actionDiv);
      }

      fragment.appendChild(postCard);
    });

    // Ajouter tous les éléments en une fois
    postsGrid.appendChild(fragment);

    // Ajouter l'effet de particules après le rendu
    setTimeout(() => {
      addParticleEffect();
    }, 50);
  }

// Fermer toutes les info-bulles ouvertes
function closeAllInfoBubbles() {
  document.querySelectorAll('.info-bubble.show').forEach(bubble => bubble.classList.remove('show'));
  document.querySelectorAll('.info-btn[aria-expanded="true"]').forEach(btn => btn.setAttribute('aria-expanded', 'false'));
}

document.addEventListener('click', (e) => {
  if (!tagsFilterInput.contains(e.target) && !tagsDropdown.contains(e.target)) {
    tagsDropdown.classList.remove('show');
    tagsFilterInput.setAttribute('aria-expanded', 'false');
  }
});

init();
  
