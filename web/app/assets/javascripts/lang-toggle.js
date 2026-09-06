(function() {
  const savedLang = localStorage.getItem('les-vendredis-lang') || 'en';
  
  function setLanguage(lang) {
    localStorage.setItem('les-vendredis-lang', lang);
    document.querySelectorAll('.lang-en, .lang-fr').forEach(el => {
      if (!el.classList.contains(`lang-${lang}`)) {
        el.style.display = 'none';
        return;
      }

      el.style.display = el.tagName === 'SPAN' ? 'inline' : 'block';
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
