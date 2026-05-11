const GALLERY = [
  { src: "public/images/mangues-jardin-cabane-aframe-les-vendredis.jpg",            title: "Mango Season",         desc: "Green mangoes hanging heavy, with the cabin visible through the garden behind." },
  { src: "public/images/goyavier-jardin-les-vendredis-sainte-luce.jpg",             title: "The Guava Tree",       desc: "Ripe guavas on the tree — the garden produces all year round." },
  { src: "public/images/flamboyant-palmiers-collines-jardin-les-vendredis.jpg",     title: "The Flamboyant",       desc: "The flamboyant tree in full red bloom, with the hills of Sainte-Luce behind." },
  { src: "public/images/panorama-domaine-cabane-aframe-les-vendredis-martinique.jpg", title: "The Domain",         desc: "A wide view of the full estate — cabin, covered terrace, palms, and the Martinique hills." },
  { src: "public/images/vue-interieure-cabane-aframe-jardin-rochers-martinique.jpg", title: "From Inside",         desc: "The open front of the cabin framing the garden, the stone wall, and the red chair beyond." },
  { src: "public/images/interieur-cabane-aframe-vue-jardin-les-vendredis.jpg",      title: "Inside Looking Out",   desc: "Lying in the loft, looking through the triangular window into the palms and hills." },
  { src: "public/images/fenetre-triangulaire-cabane-aframe-les-vendredis.jpg",     title: "The Window",           desc: "The triangular gable window — built by hand, in pieces, fitted on a Sunday." },
  { src: "public/images/cabane-aframe-rochers-fleurs-jardin-les-vendredis.jpg",     title: "Cabin & Rocks",        desc: "The A-frame beside the volcanic rock wall — a signature feature of the garden." },
  { src: "public/images/cabane-aframe-jardin-fleurs-rouges-les-vendredis.jpg",      title: "The A-Frame",          desc: "The cabin seen through tropical foliage — red flowers, Waba shingles, blue sky." },
  { src: "public/images/cabane-aframe-ouverte-jardin-tropical-sainte-luce.jpg",     title: "Open to the Garden",   desc: "The finished A-frame, front open, framed by trees and the Martinique hillside." },
  { src: "public/images/coucher-soleil-palmiers-construction-les-vendredis.jpg",    title: "Sunset on Site",       desc: "End of a long day — the palms and the half-built structure against a Caribbean sky." },
  { src: "public/images/construction-bardage-bois-cabane-aframe-martinique.jpg",    title: "The Cladding",         desc: "Waba shingles covering the frame — the moment the cabin started looking like a cabin." },
  { src: "public/images/pose-bardage-facade-cabane-aframe-sainte-luce.jpg",         title: "Facade Work",          desc: "The front face of the A-frame taking on its final character through hand-cut shingles." },
  { src: "public/images/construction-cabane-aframe-pose-bardage-martinique.jpg",    title: "Building by Hand",     desc: "Laying the wooden cladding, plank by plank, in the Martinique sun." },
  { src: "public/images/construction-charpente-aframe-enfant-martinique.jpg",       title: "Family Build",         desc: "Léon on the frame — built together, from the ground up." },
  { src: "public/images/ossature-bois-aframe-construction-martinique.jpg",          title: "The Structure",        desc: "The wooden skeleton of the A-frame taking shape, assembled by hand on site." },
  { src: "public/images/terrain-defriche-avant-construction-les-vendredis.jpg",     title: "Clearing the Ground",  desc: "First clearing — making way for what would become the A-frame and its garden." },
  { src: "public/images/terrain-avant-construction-les-vendredis-sainte-luce.jpg",  title: "The Land",             desc: "The raw terrain of Les Vendredis, before a single post was driven into the ground." },
  { src: "public/images/terrain-debut-chantier-les-vendredis-martinique.jpg",       title: "Day One",              desc: "The land before anything existed — the start of a two-year build in the hills of Sainte-Luce." },
];

let current = 0;

function openLightbox(index) {
  current = index;
  render();
  document.getElementById('lightbox').classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeLightbox() {
  document.getElementById('lightbox').classList.remove('open');
  document.body.style.overflow = '';
}

function moveLightbox(dir) {
  current = (current + dir + GALLERY.length) % GALLERY.length;
  render();
}

function render() {
  const item = GALLERY[current];
  document.getElementById('lb-img').src = item.src;
  document.getElementById('lb-img').alt = item.title;
  document.getElementById('lb-title').textContent = item.title;
  document.getElementById('lb-desc').textContent = item.desc;
  document.getElementById('lb-counter').textContent = (current + 1) + ' — ' + GALLERY.length;
}

document.addEventListener('keydown', e => {
  const lb = document.getElementById('lightbox');
  if (!lb.classList.contains('open')) return;
  if (e.key === 'Escape') closeLightbox();
  if (e.key === 'ArrowRight') moveLightbox(1);
  if (e.key === 'ArrowLeft') moveLightbox(-1);
});

document.getElementById('lightbox').addEventListener('click', e => {
  if (e.target === e.currentTarget) closeLightbox();
});
