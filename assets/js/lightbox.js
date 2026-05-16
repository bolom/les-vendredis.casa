const GALLERY = [
  { src: "public/images/panorama-domaine-cabane-aframe-les-vendredis-martinique.jpg", title: "The Domain", titleFr: "Le domaine", desc: "A wide view of the full estate: A-frame, covered terrace, palms, and the Martinique hills.", descFr: "Une vue large du domaine : l'A-frame, le préau, les palmiers et les collines de Martinique." },
  { src: "public/images/vue-jardin-collines-les-vendredis-sainte-luce.jpg", title: "The Hills", titleFr: "Les hauteurs", desc: "The garden opens toward the quiet hills above Sainte-Luce.", descFr: "Le jardin s'ouvre vers les hauteurs calmes de Sainte-Luce." },
  { src: "public/images/coucher-soleil-palmiers-construction-les-vendredis.jpg", title: "Evening Light", titleFr: "Fin de journée", desc: "Palms and warm light at the end of a day on the land.", descFr: "Les palmiers et la lumière chaude de fin de journée sur le terrain." },
  { src: "public/images/cabane-aframe-ouverte-jardin-tropical-sainte-luce.jpg", title: "Open to the Garden", titleFr: "Ouverte au jardin", desc: "The finished A-frame, front open, framed by trees and the Martinique hillside.", descFr: "L'A-frame terminée, ouverte sur le jardin, encadrée par les arbres et les hauteurs." },
  { src: "public/images/cabane-aframe-jardin-fleurs-rouges-les-vendredis.jpg", title: "The A-Frame", titleFr: "L'A-frame", desc: "The A-frame seen through tropical foliage, red flowers, Wapa shingles, and blue sky.", descFr: "L'A-frame vue à travers le jardin tropical, les fleurs rouges, le bardage en wapa et le ciel bleu." },
  { src: "public/images/vue-interieure-cabane-aframe-jardin-rochers-martinique.jpg", title: "From Inside", titleFr: "Depuis l'intérieur", desc: "The open front of the A-frame frames the garden, stone wall, and red chair beyond.", descFr: "L'ouverture de l'A-frame cadre le jardin, le mur de pierre et le fauteuil rouge." },
  { src: "public/images/fenetre-triangulaire-cabane-aframe-les-vendredis.jpg", title: "Garden Juice", titleFr: "Jus au jardin", desc: "A fresh juice in hand, looking out over the tropical garden.", descFr: "Un jus frais à la main, face au jardin tropical." },
  { src: "public/images/jardin-tropical-anthurium-les-vendredis-martinique.jpg", title: "Tropical Garden", titleFr: "Jardin tropical", desc: "Anthurium and tropical planting set the tone for the private garden.", descFr: "Anthurium et plantations tropicales donnent le ton du jardin privatif." },
  { src: "public/images/mangues-jardin-cabane-aframe-les-vendredis.jpg", title: "Mango Season", titleFr: "Saison des mangues", desc: "Green mangoes hanging heavy, with the A-frame visible through the garden behind.", descFr: "Les mangues vertes pendent lourdement, avec l'A-frame visible derrière le jardin." },
  { src: "public/images/goyavier-jardin-les-vendredis-sainte-luce.jpg", title: "The Guava Tree", titleFr: "Le goyavier", desc: "Ripe guavas on the tree; the garden produces all year round.", descFr: "Des goyaves mûres sur l'arbre ; le jardin produit toute l'année." },
  { src: "public/images/flamboyant-palmiers-collines-jardin-les-vendredis.jpg", title: "The Flamboyant", titleFr: "Le flamboyant", desc: "The flamboyant tree in red bloom, with the hills of Sainte-Luce behind.", descFr: "Le flamboyant en fleurs rouges, avec les collines de Sainte-Luce derrière." },
  { src: "public/images/cabane-aframe-rochers-fleurs-jardin-les-vendredis.jpg", title: "Rocks & Flowers", titleFr: "Rochers et fleurs", desc: "The A-frame beside the volcanic rock wall, a signature feature of the garden.", descFr: "L'A-frame près du mur de roches volcaniques, une signature du jardin." },
  { src: "public/images/hamac-jardin-tropical-les-vendredis-martinique.jpg", title: "The Hammock", titleFr: "Le hamac", desc: "A quiet place to read, nap, and let the garden take over.", descFr: "Un endroit calme pour lire, dormir et laisser le jardin prendre toute la place." },
  { src: "public/images/anais-leon-petit-dejeuner-fruits-les-vendredis.jpg", title: "Breakfast Outside", titleFr: "Petit déjeuner", desc: "Fruit from the garden, breakfast outside, and time moving slowly.", descFr: "Les fruits du jardin, le petit déjeuner dehors et le temps qui ralentit." },
  { src: "public/images/jardin-plantes-tropicales-les-vendredis-sainte-luce.jpg", title: "Planted Paths", titleFr: "Allées plantées", desc: "Tropical planting shapes the paths between the A-frame and the garden.", descFr: "Les plantations tropicales dessinent les passages entre l'A-frame et le jardin." },
  { src: "public/images/samsam-dimdim-cohabitation-jardin-les-vendredis.jpg", title: "Pets Welcome", titleFr: "Animaux bienvenus", desc: "The garden is part of the stay for guests and their animals.", descFr: "Le jardin fait partie du séjour pour les voyageurs et leurs animaux." },
  { src: "public/images/cuisine-ouverte-jardin-les-vendredis.webp", title: "Outdoor Shower", titleFr: "Douche extérieure", desc: "The outdoor shower in wood, open to the tropical garden.", descFr: "La douche extérieure en bois, ouverte sur le jardin tropical." },
  { src: "public/images/detail-cuisine-preparation-les-vendredis.webp", title: "Outdoor Shower", titleFr: "Douche extérieure", desc: "The outdoor shower area, tucked into the garden.", descFr: "L'espace de douche extérieure, installé dans le jardin." },
  { src: "public/images/douche-exterieure-les-vendredis.webp", title: "Solar Shower", titleFr: "Douche solaire", desc: "A solar shower surrounded by tropical plants and garden views.", descFr: "Une douche solaire entourée de plantes tropicales et de vues sur le jardin." },
  { src: "public/images/toilette-seche-chemin-cabine-jardin-les-vendredis.webp", title: "The Path to the Cabin", titleFr: "Le chemin vers la cabine", desc: "A small planted path leads to the dry toilet cabin, set slightly apart in the garden.", descFr: "Un petit chemin planté mène à la cabine des toilettes sèches, légèrement à l'écart dans le jardin." },
  { src: "public/images/toilette-seche-cabine-bardage-jardin-les-vendredis.webp", title: "The Cabin in the Garden", titleFr: "La cabine dans le jardin", desc: "The dry toilet cabin sits in the planting, with wood cladding, shade, and the same handmade logic as the rest of the place.", descFr: "La cabine des toilettes sèches se glisse dans les plantations, avec son bardage bois, son ombre et la même logique artisanale que le reste du lieu." },
  { src: "public/images/jardin-preau-nuit-les-vendredis.jpg", title: "The garden after dark.", titleFr: "Le jardin après la tombée du jour.", desc: "The covered terrace, hammock, stone wall, and planted garden after the lights come on.", descFr: "Le préau, le hamac, le mur de pierres et le jardin planté quand les lumières s'allument." },
  { src: "public/images/aframe-nuit-jardin-les-vendredis.jpg", title: "The A-frame stays open to the night.", titleFr: "L'A-frame ouverte sur la nuit.", desc: "Warm light inside the A-frame, with the tropical garden and night sky around it.", descFr: "La lumière chaude dans l'A-frame, avec le jardin tropical et le ciel du soir autour." },
  { src: "public/images/manguier-guirlandes-nuit-les-vendredis.jpg", title: "Lights in the mango tree.", titleFr: "Les lumières dans le manguier.", desc: "String lights through the branches, the garden path, and the outdoor kitchen beyond.", descFr: "Les guirlandes dans les branches, le chemin du jardin et la cuisine dehors au fond." },
  { src: "public/images/douche-exterieure-nuit-les-vendredis.jpg", title: "The outdoor shower at night.", titleFr: "La douche dehors, la nuit.", desc: "The outdoor shower tucked behind planting and warm garden lights.", descFr: "La douche extérieure, cachée dans les plantes et les lumières chaudes du jardin." },
  { src: "public/images/construction-bardage-bois-cabane-aframe-martinique.jpg", title: "The Cladding", titleFr: "Le bardage", desc: "Wapa shingles covering the frame, when the A-frame started looking finished.", descFr: "Le bardage en wapa couvre l'ossature, le moment où l'A-frame devient vraiment elle-même." },
  { src: "public/images/pose-bardage-facade-cabane-aframe-sainte-luce.jpg", title: "Facade Work", titleFr: "Façade", desc: "The front face of the A-frame taking on its final character through hand-cut shingles.", descFr: "La façade de l'A-frame prend son caractère final, bardeau après bardeau." },
  { src: "public/images/construction-cabane-aframe-pose-bardage-martinique.jpg", title: "Building by Hand", titleFr: "À la main", desc: "Laying the wooden cladding, plank by plank, in the Martinique sun.", descFr: "Poser le bardage en bois, planche après planche, sous le soleil de Martinique." },
  { src: "public/images/construction-charpente-aframe-enfant-martinique.jpg", title: "Family Build", titleFr: "Chantier famille", desc: "Léon on the frame; built together, from the ground up.", descFr: "Léon sur la charpente ; construit ensemble, depuis le sol." },
  { src: "public/images/ossature-bois-aframe-construction-martinique.jpg", title: "The Structure", titleFr: "La structure", desc: "The wooden skeleton of the A-frame taking shape on site.", descFr: "L'ossature bois de l'A-frame prend forme sur le terrain." },
  { src: "public/images/terrain-debut-chantier-les-vendredis-martinique.jpg", title: "Day One", titleFr: "Le premier jour", desc: "The land before anything existed; the beginning of the build in Sainte-Luce.", descFr: "Le terrain avant tout ; le début du chantier dans les hauteurs de Sainte-Luce." },
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
  const isFrench = document.documentElement.lang.toLowerCase().startsWith('fr');
  const title = isFrench ? item.titleFr : item.title;
  const desc = isFrench ? item.descFr : item.desc;

  document.getElementById('lb-img').src = item.src;
  document.getElementById('lb-img').alt = title;
  document.getElementById('lb-title').textContent = title;
  document.getElementById('lb-desc').textContent = desc;
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
