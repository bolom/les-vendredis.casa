const GALLERY = [
  // 01 — Le domaine (index 0–2)
  { src: "public/images/jpk-cabane-vegetation-palmiers.webp", title: "The Domain", titleFr: "Le domaine", desc: "The A-frame seen through dense palms — the cabin set into the green of the hillside.", descFr: "L'A-frame vue à travers les palmiers — la cabane fondue dans le vert de la colline." },
  { src: "public/images/jpk-detente-balancoire-collines.webp", title: "The Hills", titleFr: "Les hauteurs", desc: "The wooden swing suspended in the garden, hills of Sainte-Luce out of focus behind.", descFr: "La balançoire en bois suspendue dans le jardin, les collines de Sainte-Luce floutées derrière." },
  { src: "public/images/jpk-cabane-cypers-angle.webp", title: "Under the Gable", titleFr: "Sous le pignon", desc: "The tip of the A-frame in low angle, seen through a papyrus plant.", descFr: "La pointe de l'A-frame en contre-plongée, vue à travers un papyrus." },
  // 02 — L'A-frame (index 3–6)
  { src: "public/images/jpk-cabane-facade-plein-air.webp", title: "The A-Frame", titleFr: "L'A-frame", desc: "The A-frame seen from the garden: Wapa shingles, palms, and an open sky.", descFr: "L'A-frame vue depuis le jardin : bardeaux de Wapa, palmiers et ciel ouvert." },
  { src: "public/images/jpk-cabane-interieur-vue-paysage.webp", title: "Inside", titleFr: "Le dedans", desc: "Wood floor, cushions on the ground, a ladder to the mezzanine, and the mornes framed in the opening.", descFr: "Plancher bois, coussins au sol, échelle vers la mezzanine, et les mornes cadrés dans l'ouverture." },
  { src: "public/images/jpk-cabane-vue-interieure-foret.webp", title: "Tucked in the Green", titleFr: "Nichée dans le vert", desc: "The A-frame nested in the forest, the inside just visible through the foliage.", descFr: "L'A-frame nichée dans la forêt, l'intérieur tout juste visible à travers le feuillage." },
  { src: "public/images/jpk-detail-corde-noeud-cabane.webp", title: "Made by Hand.", titleFr: "Fait à la main.", desc: "A braided rope knot, the tip of the A-frame in the background.", descFr: "Un nœud de corde tressée, la pointe de l'A-frame en arrière-plan." },
  // 03 — Jardin tropical (index 7–11)
  { src: "public/images/jpk-flore-passiflore-ouverte.webp", title: "Passion Flower", titleFr: "Fleur de la passion", desc: "A passion flower fully open, violet filaments and curling tendrils.", descFr: "Une fleur de la passion pleinement ouverte, filaments violets et vrilles enroulées." },
  { src: "public/images/jpk-flore-gingembre-rouge.webp", title: "Red Ginger", titleFr: "Gingembre rouge", desc: "Red ginger flower up close, lush garden behind.", descFr: "Fleur de gingembre rouge en gros plan, jardin verdoyant derrière." },
  { src: "public/images/jpk-flore-orchidee-coco-orange.webp", title: "Orchid on Coconut.", titleFr: "Orchidée sur coco.", desc: "An orange orchid growing from a coconut shell fixed to a tree trunk.", descFr: "Une orchidée orange poussant depuis une coque de coco accrochée à un tronc." },
  { src: "public/images/jpk-flore-allamanda-jaune.webp", title: "Yellow Allamanda", titleFr: "Allamanda jaune", desc: "A yellow allamanda against a soft bokeh of orange flowers.", descFr: "Une allamanda jaune sur un bokeh de fleurs orange." },
  { src: "public/images/jpk-detail-panneau-vendredi.webp", title: "Vendredi.", titleFr: "Vendredi.", desc: "Hand-engraved wooden sign in the foliage.", descFr: "Panneau de bois gravé dans le feuillage." },
  // 04 — La vie dehors (index 12–20)
  { src: "public/images/jpk-detente-hamac-bleu-gingembre.webp", title: "Hammock", titleFr: "Hamac", desc: "Blue hammock in the tropical garden, red ginger flowers in the foreground.", descFr: "Hamac bleu dans le jardin tropical, fleurs de gingembre rouge au premier plan." },
  { src: "public/images/jpk-vie-fruits-tropicaux-dessus.webp", title: "Fruit from the Garden.", titleFr: "Les fruits du jardin.", desc: "Overhead view of tropical fruit baskets — bananas, mangoes, prunes de Cythère — and an awalé board at the centre.", descFr: "Vue de dessus sur les corbeilles de fruits tropicaux — bananes, mangues, prunes de Cythère — et un jeu d'awalé au centre." },
  { src: "public/images/jpk-vie-bbq-feu.webp", title: "The BBQ.", titleFr: "Le BBQ.", desc: "Grilled meat and sausages on the grill, smoke rising, a second brazier in the foreground.", descFr: "Viandes grillées et saucisses sur la grille, fumée qui monte, second brasero au premier plan." },
  { src: "public/images/jpk-vie-samsam-portrait.webp", title: "Samsam", titleFr: "Samsam", desc: "Samsam, the Creole dog, lying on the terrace, mouth open, garden chairs out of focus behind.", descFr: "Samsam, la chienne créole, couchée sur la terrasse gueule ouverte, transats flous derrière." },
  { src: "public/images/jpk-vie-dimdim-sous-manguier.webp", title: "Dimdim", titleFr: "Dimdim", desc: "Dimdim the rooster under the mango tree, seen through the foliage.", descFr: "Dimdim le coq sous le manguier, vu à travers le feuillage." },
  { src: "public/images/jpk-vie-anolis-tronc.webp", title: "Anolis", titleFr: "Anolis", desc: "A green anolis lizard on a tree trunk, wrapped in fine vines.", descFr: "Un anolis vert sur un tronc, entouré de vrilles fines." },
  { src: "public/images/jpk-vie-dames-marbre.webp", title: "Checkers", titleFr: "Le jeu de dames", desc: "The green marble checkers board on the terrace, wooden pieces, soft bokeh.", descFr: "Le jeu de dames en marbre vert sur la terrasse, pions de bois, bokeh doux." },
  { src: "public/images/douche-exterieure-les-vendredis.webp", title: "Solar Shower.", titleFr: "Douche solaire.", desc: "A solar shower surrounded by tropical plants and garden views.", descFr: "Une douche solaire entourée de plantes tropicales et de vues sur le jardin." },
  { src: "public/images/toilette-seche-cabine-bardage-jardin-les-vendredis.webp", title: "The Dry Toilet Cabin.", titleFr: "La cabine des toilettes sèches.", desc: "The dry toilet cabin, wood cladding, shade, same handmade logic as the rest.", descFr: "La cabine des toilettes sèches, bardage bois, ombre, même logique artisanale que le reste." },
  // 05 — La nuit (index 21–24)
  { src: "public/images/jardin-preau-nuit-les-vendredis.webp", title: "The garden after dark.", titleFr: "Le jardin après la tombée du jour.", desc: "The covered terrace, hammock, stone wall, and planted garden after the lights come on.", descFr: "Le préau, le hamac, le mur de pierres et le jardin planté quand les lumières s'allument." },
  { src: "public/images/aframe-nuit-jardin-les-vendredis.webp", title: "The A-frame stays open to the night.", titleFr: "L'A-frame ouverte sur la nuit.", desc: "Warm light inside the A-frame, with the tropical garden and night sky around it.", descFr: "La lumière chaude dans l'A-frame, avec le jardin tropical et le ciel du soir autour." },
  { src: "public/images/manguier-guirlandes-nuit-les-vendredis.webp", title: "Lights in the mango tree.", titleFr: "Les lumières dans le manguier.", desc: "String lights through the branches, the garden path, and the outdoor kitchen beyond.", descFr: "Les guirlandes dans les branches, le chemin du jardin et la cuisine dehors au fond." },
  { src: "public/images/douche-exterieure-nuit-les-vendredis.webp", title: "The outdoor shower at night.", titleFr: "La douche dehors, la nuit.", desc: "The outdoor shower tucked behind planting and warm garden lights.", descFr: "La douche extérieure, cachée dans les plantes et les lumières chaudes du jardin." },
  // 06 — La fabrication (index 25–30)
  { src: "public/images/construction-bardage-bois-cabane-aframe-martinique.webp", title: "The Cladding", titleFr: "Le bardage", desc: "Wapa shingles covering the frame, when the A-frame started looking finished.", descFr: "Le bardage en wapa couvre l'ossature, le moment où l'A-frame devient vraiment elle-même." },
  { src: "public/images/pose-bardage-facade-cabane-aframe-sainte-luce.webp", title: "Facade Work", titleFr: "Façade", desc: "The front face of the A-frame taking on its final character through hand-cut shingles.", descFr: "La façade de l'A-frame prend son caractère final, bardeau après bardeau." },
  { src: "public/images/construction-cabane-aframe-pose-bardage-martinique.webp", title: "Building by Hand", titleFr: "À la main", desc: "Laying the wooden cladding, plank by plank, in the Martinique sun.", descFr: "Poser le bardage en bois, planche après planche, sous le soleil de Martinique." },
  { src: "public/images/construction-charpente-aframe-enfant-martinique.webp", title: "Family Build", titleFr: "Chantier famille", desc: "Léon on the frame; built together, from the ground up.", descFr: "Léon sur la charpente ; construit ensemble, depuis le sol." },
  { src: "public/images/ossature-bois-aframe-construction-martinique.webp", title: "The Structure", titleFr: "La structure", desc: "The wooden skeleton of the A-frame taking shape on site.", descFr: "L'ossature bois de l'A-frame prend forme sur le terrain." },
  { src: "public/images/terrain-debut-chantier-les-vendredis-martinique.webp", title: "Day One", titleFr: "Le premier jour", desc: "The land before anything existed; the beginning of the build in Sainte-Luce.", descFr: "Le terrain avant tout ; le début du chantier dans les hauteurs de Sainte-Luce." },
  // 07 — Détails (index 31–36)
  { src: "public/images/jpk-detail-casseroles-suspendues.webp", title: "Hanging Pots", titleFr: "Casseroles suspendues", desc: "Old pots and pans hanging in the open-air kitchen, foliage all around.", descFr: "Vieilles casseroles suspendues dans la cuisine ouverte, feuillage tout autour." },
  { src: "public/images/jpk-detail-douche-gel.webp", title: "The Shower", titleFr: "La douche", desc: "Shower gel, brushes, and a coconut half on the wooden shelf of the outdoor shower.", descFr: "Gel douche, brosses et une demi-noix de coco sur l'étagère bois de la douche extérieure." },
  { src: "public/images/jpk-detail-nichoir-gros-plan.webp", title: "The Birdhouse", titleFr: "Le nichoir", desc: "The bird-shaped opening of the birdhouse, weathered wood and lichen.", descFr: "L'ouverture en forme d'oiseau du nichoir, bois patiné et lichen." },
  { src: "public/images/jpk-detail-domino-awale.webp", title: "Domino & Awalé", titleFr: "Domino et awalé", desc: "A single domino on the awalé board, bananas out of focus behind.", descFr: "Un domino posé sur le plateau d'awalé, bananes floutées derrière." },
  { src: "public/images/jpk-detail-carreau-creole.webp", title: "Creole Tile", titleFr: "Carreau créole", desc: "An old painted tile of fishing boats, resting against the volcanic stone.", descFr: "Un vieux carreau peint de barques de pêche, posé contre la pierre volcanique." },
  { src: "public/images/jpk-detail-banc-rouge.webp", title: "The Red Bench", titleFr: "Le banc rouge", desc: "A red metal bench against the grey Wapa cladding.", descFr: "Un banc en métal rouge contre le bardage gris en Wapa." },
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
  const src = item.src.startsWith('/') ? item.src : `/${item.src}`;

  document.getElementById('lb-img').src = src;
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
