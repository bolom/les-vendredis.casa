const GALLERY = [
  { src: "public/images/IMG_0387.jpg",  title: "The A-Frame Exterior",  desc: "Sustainable wooden architecture nestled in the lush tropical forest of Martinique." },
  { src: "public/images/IMG_0390.jpg",  title: "Verdant Canopy",        desc: "The view from the loft, looking out into the heart of the garden." },
  { src: "public/images/IMG_0391.jpg",  title: "Artisanal Details",     desc: "Hand-crafted local timber used throughout the interior structure." },
  { src: "public/images/IMG_0392.jpg",  title: "Coastal Proximity",     desc: "Just a short walk from the cabin to the pristine Caribbean shores." },
  { src: "public/images/IMG_0396.jpg",  title: "Golden Hour",           desc: "Warm light filtering through the palm leaves at dusk." },
  { src: "public/images/IMG_0896.jpg",  title: "Botanical Sanctuary",   desc: "The private garden surrounding the A-Frame, filled with native flora." },
  { src: "public/images/IMG_0940.jpg",  title: "Morning Mist",          desc: "The cabin emerging from the mist on a humid tropical morning." },
  { src: "public/images/IMG_1251.jpg",  title: "Natural Light",         desc: "Sunlight streaming through the architectural lines of the cabin." },
  { src: "public/images/IMG_1348.jpg",  title: "Forest Serenity",       desc: "Surrounded by the tranquility of untouched tropical nature." },
  { src: "public/images/IMG_1355.jpg",  title: "Architectural Detail",  desc: "The geometric precision of the A-Frame design against natural elements." },
  { src: "public/images/IMG_3290.jpg",  title: "Tropical Flora",        desc: "The lush vegetation surrounding and embracing the structure." },
  { src: "public/images/IMG_3343.jpg",  title: "Sunset View",           desc: "The cabin silhouetted against the Caribbean sunset." },
  { src: "public/images/IMG_3936.jpg",  title: "Wooden Frame",          desc: "The structural beauty of locally sourced timber." },
  { src: "public/images/IMG_4621.JPG",  title: "Aerial View",           desc: "A panoramic view from above the cabin and surrounding forest." },
  { src: "public/images/IMG_4688.JPG",  title: "Mountain Backdrop",     desc: "The A-Frame framed against the dramatic Martinique landscape." },
  { src: "public/images/IMG_6303.jpg",  title: "Garden Path",           desc: "The winding path leading through the botanical sanctuary." },
  { src: "public/images/IMG_7953.jpg",  title: "The Domain",            desc: "The full domain — cabin, garden, and sky." },
  { src: "public/images/AA4940C0-AE7D-4C3A-8304-688BF02A1955.jpg", title: "Garden Path", desc: "Morning light on the garden path." },
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
