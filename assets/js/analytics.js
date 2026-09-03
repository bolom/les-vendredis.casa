(() => {
  const SAFE_PARAM_KEYS = new Set(['method', 'target', 'locale', 'status', 'source']);
  const EVENTS = new Set([
    'view_availability',
    'select_dates',
    'start_inquiry',
    'submit_inquiry',
    'inquiry_success',
    'click_airbnb',
    'click_booking',
    'click_email',
    'click_whatsapp'
  ]);

  function safeParams(params) {
    return Object.fromEntries(
      Object.entries(params || {}).filter(([key, value]) => (
        SAFE_PARAM_KEYS.has(key) && typeof value === 'string' && value.length <= 80
      ))
    );
  }

  function track(eventName, params = {}) {
    if (!EVENTS.has(eventName) || typeof window.gtag !== 'function') return;

    window.gtag('event', eventName, safeParams(params));
  }

  function linkEvent(link) {
    const href = link.getAttribute('href') || '';
    const url = href.toLowerCase();

    if (url.startsWith('mailto:')) return ['click_email', { method: 'mailto' }];
    if (url.includes('wa.me') || url.includes('whatsapp')) return ['click_whatsapp', { method: 'whatsapp' }];
    if (url.includes('airbnb.')) return ['click_airbnb', { target: 'airbnb' }];
    if (url.includes('booking.com')) return ['click_booking', { target: 'booking' }];
    return null;
  }

  document.addEventListener('click', event => {
    const tracked = event.target.closest('[data-analytics-event]');
    if (tracked) {
      track(tracked.dataset.analyticsEvent, {
        locale: document.documentElement.lang || 'en',
        source: tracked.dataset.analyticsSource || 'site'
      });
      return;
    }

    const link = event.target.closest('a[href]');
    const linkTracking = link && linkEvent(link);
    if (linkTracking) track(linkTracking[0], linkTracking[1]);
  });

  document.addEventListener('submit', event => {
    const form = event.target.closest('form[data-analytics-event]');
    if (!form) return;

    track(form.dataset.analyticsEvent, {
      locale: document.documentElement.lang || 'en',
      source: form.dataset.analyticsSource || 'booking_form'
    });
  });

  window.LesVendredisAnalytics = { track };
})();
