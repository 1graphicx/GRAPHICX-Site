const searchInput = document.getElementById('searchInput');
const tagsFilterInput = document.getElementById('tagsFilterInput');
const tagsDropdown = document.getElementById('tagsDropdown');
const selectedTagsContainer = document.querySelector('.selected-tags');
const postsGrid = document.getElementById('postsGrid');


let selectedTags = new Set();

function init() {
  renderTagsDropdown();
  renderPosts(posts);

  tagsFilterInput.addEventListener('input', () => {
  filterTagsDropdown();
  });

  // Clic sur la barre tags : toggle dropdown
  tagsFilterInput.addEventListener('click', (e) => {
    e.stopPropagation(); // Empêche la fermeture immédiate par document click
    const isVisible = tagsDropdown.classList.toggle('show');
    tagsFilterInput.setAttribute('aria-expanded', isVisible ? 'true' : 'false');
  });

  // Clic sur document ferme dropdown sauf si on clique dans dropdown ou input
  document.addEventListener('click', () => {
    tagsDropdown.classList.remove('show');
    tagsFilterInput.setAttribute('aria-expanded', 'false');
  });

  tagsFilterInput.addEventListener('input', (e) => {
  const search = e.target.value.toLowerCase();
  const labels = tagsDropdown.querySelectorAll('label');
  labels.forEach(label => {
    const tagText = label.textContent.toLowerCase();
    label.style.display = tagText.includes(search) ? 'flex' : 'none';
  });

  // Affiche le dropdown si ce n’est pas visible
  if (!tagsDropdown.classList.contains('show')) {
    tagsDropdown.classList.add('show');
    tagsFilterInput.setAttribute('aria-expanded', 'true');
  }
  });


  // Empêche la fermeture quand on clique dans dropdown lui-même
  tagsDropdown.addEventListener('click', (e) => {
    e.stopPropagation();
  });

  // Recherche texte live
  searchInput.addEventListener('input', updateFilter);

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

  // Gestion des boutons de suppression de tags sélectionnés
  selectedTagsContainer.addEventListener('click', (e) => {
    if (e.target.matches('button.remove-tag')) {
      const tag = e.target.getAttribute('data-tag');
      selectedTags.delete(tag);
      updateSelectedTagsUI();
      updateFilter();
      // Décoche checkbox correspondante
      const checkbox = tagsDropdown.querySelector(`input[value="${tag}"]`);
      if (checkbox) checkbox.checked = false;
    }
  });

    // Filtre la liste des tags dans la dropdown selon l'entrée texte
function filterTagsDropdown() {
  const filterText = tagsFilterInput.value.trim().toLowerCase();
  const labels = tagsDropdown.querySelectorAll('label');
  let visibleCount = 0;
  labels.forEach(label => {
    const tagText = label.textContent.toLowerCase();
    if (tagText.includes(filterText)) {
      label.style.display = 'flex';
      visibleCount++;
    } else {
      label.style.display = 'none';
    }
  });

  // Si aucun tag visible, afficher message "Aucun tag trouvé"
  let noTagsMsg = tagsDropdown.querySelector('.no-tags-msg');
  if (visibleCount === 0) {
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
}


  // Scroll horizontal dans les tags des posts au wheel vertical
  postsGrid.addEventListener('wheel', (e) => {
    const tagsDiv = e.target.closest('.tags');
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
  tags.forEach(tag => {
    const id = 'tag-checkbox-' + tag.toLowerCase().replace(/\s+/g, '-');
    const label = document.createElement('label');
    label.setAttribute('for', id);
    label.textContent = tag;
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.id = id;
    checkbox.value = tag;
    label.prepend(checkbox);
    tagsDropdown.appendChild(label);
  });
}

// Met à jour la barre des tags sélectionnés sous la barre tags
function updateSelectedTagsUI() {
  selectedTagsContainer.innerHTML = '';
  if (selectedTags.size > 0) {
    selectedTags.forEach(tag => {
      const tagPill = document.createElement('div');
      tagPill.classList.add('selected-tag');
      tagPill.textContent = tag;
      const removeBtn = document.createElement('button');
      removeBtn.classList.add('remove-tag');
      removeBtn.setAttribute('aria-label', `Supprimer le filtre ${tag}`);
      removeBtn.setAttribute('data-tag', tag);
      removeBtn.textContent = '×';
      tagPill.appendChild(removeBtn);
      selectedTagsContainer.appendChild(tagPill);
    });
  }
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
  postsGrid.innerHTML = '';

  if (postsToRender.length === 0) {
    postsGrid.innerHTML = '<p>Aucun post trouvé.</p>';
    return;
  }

  postsToRender.forEach(post => {
    const postDiv = document.createElement('div');
    postDiv.className = 'post';
    postDiv.tabIndex = 0;
    postDiv.setAttribute('aria-label', `Post ${post.title}`);

    // Image
    const postImgDiv = document.createElement('div');
    postImgDiv.className = 'post-img';
    const img = document.createElement('img');
    img.src = post.thumbnail;
    img.alt = `Thumbnail de ${post.title}`;
    postImgDiv.appendChild(img);

    // Content
    const contentDiv = document.createElement('div');
    contentDiv.className = 'post-content';

    const title = document.createElement('h2');
    title.className = 'post-title';
    title.textContent = post.title;

    const desc = document.createElement('p');
    desc.className = 'post-desc';
    desc.textContent = post.description;

    // Tags
    const tagsDiv = document.createElement('div');
    tagsDiv.className = 'tags';
    post.tags.forEach(tag => {
      const tagSpan = document.createElement('span');
      tagSpan.className = 'tag';
      tagSpan.textContent = tag;
      tagsDiv.appendChild(tagSpan);
    });

    // Version + Size
    const version = document.createElement('div');
    version.className = 'post-version';
    if (post.version) {
      version.textContent = `v${post.version} • Taille : ${post.size}`;
    } else {
      version.textContent = `Taille : ${post.size}`;
    }

    // Download section
    const downloadSection = document.createElement('div');
    downloadSection.className = 'download-section';

    const downloadLink = document.createElement('a');
    downloadLink.className = 'download-btn';
    downloadLink.href = post.file;
    downloadLink.target = '_blank';
    downloadLink.textContent = 'Télécharger';
    downloadLink.setAttribute('aria-label', `Télécharger ${post.title}`);

    downloadSection.appendChild(downloadLink);

    // Bouton info + bulle
    if (post.information !== undefined && post.information !== null) {
      const infoBtn = document.createElement('button');
      infoBtn.className = 'info-btn';
      infoBtn.type = 'button';
      infoBtn.setAttribute('aria-expanded', 'false');
      infoBtn.setAttribute('aria-label', `Afficher les informations supplémentaires pour ${post.title}`);
      infoBtn.textContent = 'i';

      const infoBubble = document.createElement('div');
      infoBubble.className = 'info-bubble';
      infoBubble.textContent = post.information || "Pas d'information supplémentaire.";
      infoBubble.setAttribute('role', 'tooltip');
      infoBubble.id = `info-bubble-${post.title.toLowerCase().replace(/\s+/g, '-')}`;

      infoBtn.setAttribute('aria-describedby', infoBubble.id);

      downloadSection.appendChild(infoBtn);
      downloadSection.appendChild(infoBubble);

      // Afficher bulle au focus (clavier)
      infoBtn.addEventListener('focus', () => {
        closeAllInfoBubbles();
        infoBubble.classList.add('show');
        infoBtn.setAttribute('aria-expanded', 'true');
      });

      // Cacher bulle au blur (clavier)
      infoBtn.addEventListener('blur', () => {
        infoBubble.classList.remove('show');
        infoBtn.setAttribute('aria-expanded', 'false');
      });
    }

    contentDiv.appendChild(title);
    contentDiv.appendChild(desc);
    contentDiv.appendChild(tagsDiv);
    contentDiv.appendChild(version);
    contentDiv.appendChild(downloadSection);

    postDiv.appendChild(postImgDiv);
    postDiv.appendChild(contentDiv);
    postsGrid.appendChild(postDiv);
  });
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
  
