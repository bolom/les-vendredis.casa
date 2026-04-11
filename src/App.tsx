/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, ChevronLeft, ChevronRight, Maximize2 } from 'lucide-react';
import { IMAGES } from './constants';
import { ImageItem } from './types';

export default function App() {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [currentIndex, setCurrentIndex] = useState<number>(0);

  const selectedImage = IMAGES.find(img => img.id === selectedId);

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

  // Keyboard navigation
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

  return (
    <div className="min-h-screen bg-[#f5f5f0] text-[#2c2c24] selection:bg-[#5a5a40] selection:text-white">
      {/* Header */}
      <header className="fixed top-0 left-0 w-full z-40 px-6 py-10 flex justify-between items-start pointer-events-none">
        <div className="bg-white/40 backdrop-blur-md p-6 rounded-3xl border border-white/20">
          <h1 className="text-2xl font-serif italic tracking-tight">A-Frame</h1>
          <p className="text-[10px] uppercase tracking-[0.3em] opacity-60 mt-1 font-sans">Martinique, West Indies</p>
        </div>
        <div className="bg-[#5a5a40] text-white px-4 py-2 rounded-full text-[10px] uppercase tracking-[0.2em] font-sans">
          {IMAGES.length} Views
        </div>
      </header>

      {/* Main Grid */}
      <main className="pt-48 pb-24 px-4 md:px-8 max-w-7xl mx-auto">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8 md:gap-12">
          {IMAGES.map((image, index) => (
            <motion.div
              key={image.id}
              layoutId={`container-${image.id}`}
              onClick={() => handleOpen(image.id, index)}
              className="group relative aspect-[3/4] overflow-hidden bg-[#e8e8e0] cursor-pointer rounded-[40px] shadow-sm hover:shadow-xl transition-shadow duration-500"
              whileHover={{ y: -10 }}
              transition={{ type: 'spring', stiffness: 200, damping: 25 }}
            >
              <motion.img
                layoutId={`image-${image.id}`}
                src={image.url}
                alt={image.title}
                referrerPolicy="no-referrer"
                className="w-full h-full object-cover transition-transform duration-1000 ease-out scale-110 group-hover:scale-100"
              />
              
              {/* Overlay */}
              <div className="absolute inset-0 bg-gradient-to-t from-[#2c2c24]/40 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
              
              {/* Info on Hover */}
              <div className="absolute bottom-0 left-0 w-full p-10 translate-y-4 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-500 ease-out">
                <h3 className="text-white text-xl font-serif italic">{image.title}</h3>
                <p className="text-white/80 text-[10px] uppercase tracking-widest mt-2 font-sans">Perspective {index + 1}</p>
              </div>
            </motion.div>
          ))}
        </div>
      </main>

      {/* Footer */}
      <footer className="px-10 py-20 border-t border-[#5a5a40]/10 flex flex-col md:flex-row justify-between items-center gap-12">
        <div className="text-[11px] uppercase tracking-[0.3em] opacity-40 font-sans">
          © 2026 A-Frame Martinique
        </div>
        <div className="flex gap-12">
          {['The Cabin', 'Location', 'Booking'].map(item => (
            <a key={item} href="#" className="text-[11px] uppercase tracking-[0.3em] opacity-40 hover:opacity-100 transition-opacity font-sans border-b border-transparent hover:border-[#5a5a40]/40 pb-1">
              {item}
            </a>
          ))}
        </div>
      </footer>

      {/* Lightbox */}
      <AnimatePresence>
        {selectedId && selectedImage && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center bg-[#f5f5f0]/98 backdrop-blur-xl"
          >
            {/* Close Button */}
            <button
              onClick={handleClose}
              className="absolute top-10 right-10 z-[60] p-4 text-[#5a5a40] hover:scale-110 transition-transform"
            >
              <X className="w-8 h-8 stroke-[1px]" />
            </button>

            {/* Navigation Buttons (Desktop) */}
            <div className="hidden md:contents">
              <button
                onClick={handlePrev}
                className="absolute left-10 top-1/2 -translate-y-1/2 z-[60] p-6 text-[#5a5a40]/30 hover:text-[#5a5a40] transition-colors"
              >
                <ChevronLeft className="w-12 h-12 stroke-[1px]" />
              </button>
              <button
                onClick={handleNext}
                className="absolute right-10 top-1/2 -translate-y-1/2 z-[60] p-6 text-[#5a5a40]/30 hover:text-[#5a5a40] transition-colors"
              >
                <ChevronRight className="w-12 h-12 stroke-[1px]" />
              </button>
            </div>

            {/* Image Container */}
            <motion.div
              layoutId={`container-${selectedId}`}
              className="relative w-full h-full flex flex-col items-center justify-center p-6 md:p-24"
              drag
              dragConstraints={{ top: 0, bottom: 0, left: 0, right: 0 }}
              dragElastic={0.7}
              onDragEnd={(_, info) => {
                const swipeThreshold = 100;
                if (Math.abs(info.offset.y) > 150) {
                  handleClose();
                } else if (info.offset.x > swipeThreshold) {
                  handlePrev();
                } else if (info.offset.x < -swipeThreshold) {
                  handleNext();
                }
              }}
            >
              <motion.img
                layoutId={`image-${selectedId}`}
                src={selectedImage.url}
                alt={selectedImage.title}
                referrerPolicy="no-referrer"
                className="max-w-full max-h-[65vh] md:max-h-[75vh] object-contain rounded-[40px] shadow-2xl pointer-events-none"
                initial={{ scale: 0.95, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                transition={{ delay: 0.1 }}
              />

              {/* Info (Lightbox) */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                className="mt-12 text-center max-w-2xl px-8"
              >
                <h2 className="text-[#2c2c24] text-3xl font-serif italic">
                  {selectedImage.title}
                </h2>
                <p className="text-[#2c2c24]/60 text-base font-serif italic mt-6 leading-relaxed">
                  {selectedImage.description}
                </p>
                <div className="mt-10 h-[1px] w-16 bg-[#5a5a40]/20 mx-auto" />
                <p className="mt-8 text-[#5a5a40]/40 text-[11px] uppercase tracking-[0.4em] font-sans">
                  {currentIndex + 1} — {IMAGES.length}
                </p>
              </motion.div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

