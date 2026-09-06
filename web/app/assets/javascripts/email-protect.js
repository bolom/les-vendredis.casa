(function() {
  function reverse(value) {
    return (value || '').split('').reverse().join('');
  }

  function addressFrom(el) {
    return `${reverse(el.dataset.epU)}@${reverse(el.dataset.epD)}`;
  }

  document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('[data-email-link]').forEach(function(link) {
      const address = addressFrom(link);
      link.href = `mailto:${address}`;
    });

    document.querySelectorAll('[data-email-text]').forEach(function(el) {
      el.textContent = addressFrom(el);
    });
  });
})();
