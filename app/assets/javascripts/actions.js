(() => {
  window.toggleMenu = function () {
    const bar = document.getElementById('top-bar');
    const isOpen = bar.classList.toggle('menu-open');
    document.body.classList.toggle('nav-open', isOpen);
    document.querySelector('.menu-toggle')?.setAttribute('aria-expanded', isOpen);
    document.getElementById('mobile-nav')?.setAttribute('aria-hidden', !isOpen);
  };

  document.addEventListener('click', function (event) {
    const target = event.target.closest('[data-lv-action]');
    if (!target) return;
    if (target.dataset.lvAction === 'toggle-menu') {
      toggleMenu();
    }
    if (target.dataset.lvAction === 'open-lightbox') {
      const index = Number.parseInt(target.dataset.lvIndex, 10);
      if (typeof window.openLightbox === 'function' && !Number.isNaN(index)) {
        window.openLightbox(index);
      }
    }
    if (target.dataset.lvAction === 'toggle-admin-technical') {
      const bar = document.querySelector('.admin-topbar');
      if (!bar) return;
      const isOpen = bar.classList.toggle('technical-open');
      target.setAttribute('aria-expanded', String(isOpen));
    }
  });
})();
