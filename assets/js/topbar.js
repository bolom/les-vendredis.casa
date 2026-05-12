(() => {
  const bar = document.getElementById('top-bar');
  if (!bar) return;
  const threshold = 24;
  let ticking = false;
  function update() {
    bar.classList.toggle('scrolled', window.scrollY > threshold);
    ticking = false;
  }
  window.addEventListener('scroll', () => {
    if (!ticking) {
      window.requestAnimationFrame(update);
      ticking = true;
    }
  }, { passive: true });
  update();

  // Switch top-bar to dark variant when a dark section sits behind it.
  const darkSections = document.querySelectorAll('.booking');
  if (darkSections.length && 'IntersectionObserver' in window) {
    const barHeight = () => bar.getBoundingClientRect().height || 64;
    const io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        bar.classList.toggle('on-dark', entry.isIntersecting);
      });
    }, { rootMargin: `0px 0px -${window.innerHeight - 80}px 0px`, threshold: 0 });
    darkSections.forEach((el) => io.observe(el));
  }
})();
