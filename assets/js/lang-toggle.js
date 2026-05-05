(function() {
  const savedLang = localStorage.getItem('les-vendredis-lang') || 'fr';
  
  function setLanguage(lang) {
    localStorage.setItem('les-vendredis-lang', lang);
    document.querySelectorAll('[class^="lang-"]').forEach(el => {
      el.style.display = el.classList.contains(`lang-${lang}`) ? 'block' : 'none';
    });
    document.querySelectorAll('.lang-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.lang === lang);
    });
  }
  
  document.addEventListener('DOMContentLoaded', () => {
    setLanguage(savedLang);
    document.querySelectorAll('.lang-btn').forEach(btn => {
      btn.addEventListener('click', () => setLanguage(btn.dataset.lang));
    });
  });
})();
