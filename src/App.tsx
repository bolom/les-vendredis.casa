import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, ChevronLeft, ChevronRight } from 'lucide-react';
import { IMAGES } from './constants';

const BOOKING = {
  airbnb: 'https://www.airbnb.fr/hosting/listings/editor/1651467419646453001/details/photo-tour',
  booking:
    'https://www.booking.com/hotel/mq/an-atypical-cabin.fr.html?label=gen173bo-10CAsomQFCEWFuLWF0eXBpY2FsLWNhYmluSDNYA2iZAYgBAZgBM7gBB8gBDdgBA-gBAfgBAYgCAZgCBqgCAbgC4fTTzwbAAgHSAiRkNDRmY2NlYi02M2ZiLTQ3NGYtYjk5OC0zYmY2ZTNlNjZkYmXYAgHgAgE&sid=c7e1c5589f91f2a47df92f453ef0ca6a&aid=304142',
};

const ENTRIES = [
  {
    date: 'Sunday, May 3rd 2026',
    tag: 'N°02 · Build log',
    title: 'Digging the trenches for hot water.',
    titleAccent: 'water',
    body: [
      'This Sunday we started cutting the trenches to bring hot water into the kitchen and the A-frame.',
      'Slow, hot work — but every line in the dirt is one more thing finished by hand. Léon helped carry the pipe.',
    ],
    image: '/images/IMG_3038.jpg',
  },
  {
    date: 'Saturday, April 12th 2026',
    tag: 'N°01 · Garden',
    title: 'The mango trees are heavy again.',
    titleAccent: 'heavy',
    body: [
      'First mangoes of the season fell this week. The garden is lush after two weeks of rain — the bougainvillea by the path is opening.',
      'We left a crate at the gate for the neighbours. Some came back with bananas.',
    ],
    image: '/images/IMG_0390.jpg',
  },
];

export default function App() {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [currentIndex, setCurrentIndex] = useState<number>(0);

  const selectedImage = IMAGES.find((img) => img.id === selectedId);

  const handleOpen = (id: string, index: number) => {
    setSelectedId(id);
    setCurrentIndex(index);
    document.body.style.overflow = 'hidden';
  };

  const handleClose = useCallback(() => {
    setSelectedId(null);
    document.body.style.overflow = 'auto';
  }, []);

  const handleNext = useCallback(() => {
    const nextIndex = (currentIndex + 1) % IMAGES.length;
    setCurrentIndex(nextIndex);
    setSelectedId(IMAGES[nextIndex].id);
  }, [currentIndex]);

  const handlePrev = useCallback(() => {
    const prevIndex = (currentIndex - 1 + IMAGES.length) % IMAGES.length;
    setCurrentIndex(prevIndex);
    setSelectedId(IMAGES[prevIndex].id);
  }, [currentIndex]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (!selectedId) return;
      if (e.key === 'Escape') handleClose();
      if (e.key === 'ArrowRight') handleNext();
      if (e.key === 'ArrowLeft') handlePrev();
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [selectedId, handleClose, handleNext, handlePrev]);

  function renderEntryTitle(title: string, accent: string) {
    const parts = title.split(accent);
    if (parts.length < 2) return <>{title}</>;
    return (
      <>
        {parts[0]}
        <em className="italic text-accent">{accent}</em>
        {parts[1]}
      </>
    );
  }

  return (
    <div className="min-h-screen bg-cream text-ink selection:bg-accent selection:text-cream">
      {/* Top bar */}
      <div className="wrap">
        <header className="top-bar">
          <a href="/" className="mark">Les Vendredis</a>
          <nav className="top-nav">
            <a href="#journal">Journal</a>
            <a href="#gallery">Gallery</a>
            <a href="#stay">Stay</a>
          </nav>
          <span className="location-tag">Sainte-Luce · Martinique</span>
        </header>
      </div>

      {/* Hero */}
      <div className="wrap">
        <section className="hero">
          <div className="image-frame">
            <img
              src="/images/IMG_0387.jpg"
              alt="The A-frame cabin at Les Vendredis, Sainte-Luce, Martinique"
              className="w-full h-full object-cover"
            />
            <span className="image-cap">A-frame · Sainte-Luce, Martinique</span>
          </div>

          <div className="copy">
            <div className="eyebrow">A-frame · Sainte-Luce</div>
            <h1>
              A Friday<br />that <em className="italic text-accent">lasts.</em>
            </h1>
            <p className="lead">
              An A-frame cabin and a garden in the south of Martinique. Built by hand by Anaïs, Bolo, Léon and Same — from the foundation to the last plank.
            </p>
            <p className="lead muted">
              A small house, a wide garden, and the sea three minutes away. A place to disconnect.
            </p>
            <div className="ctas">
              <a className="btn primary" href={BOOKING.airbnb} target="_blank" rel="noopener noreferrer">
                Book on Airbnb <span className="arrow">→</span>
              </a>
              <a className="btn" href={BOOKING.booking} target="_blank" rel="noopener noreferrer">
                Book on Booking <span className="arrow">→</span>
              </a>
            </div>
          </div>
        </section>
      </div>

      {/* Journal */}
      <div className="wrap">
        <section className="journal" id="journal">
          <div className="journal-head">
            <h2>The <em className="italic text-accent">journal.</em></h2>
            <p className="journal-sub">Notes from the build, the garden, and the slow life of Sainte-Luce.</p>
          </div>

          {ENTRIES.map((entry, i) => (
            <article className="entry" key={i}>
              <div className="entry-meta">
                <span className="entry-date">{entry.date}</span>
                <span className="entry-tag">{entry.tag}</span>
              </div>
              <div className="entry-body">
                <h3>{renderEntryTitle(entry.title, entry.titleAccent)}</h3>
                {entry.body.map((p, j) => <p key={j}>{p}</p>)}
              </div>
              <div className="entry-img">
                <img src={entry.image} alt={entry.title} className="w-full h-full object-cover" />
              </div>
            </article>
          ))}

          <div className="journal-foot">— more entries to come —</div>
        </section>
      </div>

      {/* Gallery */}
      <div className="wrap" id="gallery">
        <div className="gallery-head">
          <h2>The <em className="italic text-accent">place.</em></h2>
          <p className="journal-sub">Views of the cabin, the garden, and the land we built from scratch.</p>
        </div>
      </div>

      <div className="gallery-grid-wrap">
        <div className="gallery-grid">
          {IMAGES.map((image, index) => (
            <motion.div
              key={image.id}
              layoutId={`container-${image.id}`}
              onClick={() => handleOpen(image.id, index)}
              className="gallery-item"
              whileHover={{ y: -6 }}
              transition={{ type: 'spring', stiffness: 200, damping: 25 }}
            >
              <motion.img
                layoutId={`image-${image.id}`}
                src={image.url}
                alt={image.title}
                className="w-full h-full object-cover transition-transform duration-700 ease-out scale-105 group-hover:scale-100"
              />
              <div className="gallery-overlay" />
              <div className="gallery-info">
                <h3>{image.title}</h3>
              </div>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Booking */}
      <section className="booking" id="stay">
        <div className="wrap booking-inner">
          <div>
            <h2>Come stay in <em className="italic text-accent-light">our Friday.</em></h2>
            <p className="booking-sub">
              Book through whichever platform you already trust — the cabin and the welcome are the same.
            </p>
          </div>
          <div className="b-ctas">
            <a className="b-btn" href={BOOKING.airbnb} target="_blank" rel="noopener noreferrer">
              <span className="b-label">Airbnb</span>
              <span className="b-open">Open ↗</span>
            </a>
            <a className="b-btn" href={BOOKING.booking} target="_blank" rel="noopener noreferrer">
              <span className="b-label">Booking.com</span>
              <span className="b-open">Open ↗</span>
            </a>
          </div>
        </div>
      </section>

      {/* Footer */}
      <div className="wrap">
        <footer className="foot">
          <span>© 2026 · Built by hand</span>
          <span>Anaïs &amp; Bolo · hello@lesvendredis.casa</span>
        </footer>
      </div>

      {/* Lightbox */}
      <AnimatePresence>
        {selectedId && selectedImage && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="lightbox-overlay"
          >
            <button onClick={handleClose} className="lightbox-close">
              <X className="w-7 h-7 stroke-[1px]" />
            </button>

            <div className="hidden md:contents">
              <button onClick={handlePrev} className="lightbox-nav left">
                <ChevronLeft className="w-10 h-10 stroke-[1px]" />
              </button>
              <button onClick={handleNext} className="lightbox-nav right">
                <ChevronRight className="w-10 h-10 stroke-[1px]" />
              </button>
            </div>

            <motion.div
              layoutId={`container-${selectedId}`}
              className="lightbox-content"
              drag
              dragConstraints={{ top: 0, bottom: 0, left: 0, right: 0 }}
              dragElastic={0.7}
              onDragEnd={(_, info) => {
                if (Math.abs(info.offset.y) > 150) handleClose();
                else if (info.offset.x > 100) handlePrev();
                else if (info.offset.x < -100) handleNext();
              }}
            >
              <motion.img
                layoutId={`image-${selectedId}`}
                src={selectedImage.url}
                alt={selectedImage.title}
                className="lightbox-img"
                initial={{ scale: 0.95, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                transition={{ delay: 0.1 }}
              />
              <motion.div
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.25 }}
                className="lightbox-caption"
              >
                <h2>{selectedImage.title}</h2>
                <p>{selectedImage.description}</p>
                <span className="lightbox-counter">{currentIndex + 1} — {IMAGES.length}</span>
              </motion.div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
