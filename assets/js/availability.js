(() => {
  const DEFAULT_API_URL = 'https://api.lesvendredis.casa/availability';

  function toDate(s) {
    return new Date(+s.slice(0,4), +s.slice(4,6)-1, +s.slice(6,8));
  }

  function toIso(date) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  function renderMonth(year, month, availability, lang) {
    const MONTHS_EN = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    const MONTHS_FR = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
    const months = lang === 'fr' ? MONTHS_FR : MONTHS_EN;

    const first = new Date(year, month, 1);
    const last  = new Date(year, month + 1, 0);
    const startDay = (first.getDay() + 6) % 7; // Mon=0

    let html = `<div class="cal-month">
      <div class="cal-month-name">${months[month]} ${year}</div>
      <div class="cal-grid">
        <span class="cal-dow">M</span><span class="cal-dow">T</span><span class="cal-dow">W</span><span class="cal-dow">T</span><span class="cal-dow">F</span><span class="cal-dow">S</span><span class="cal-dow">S</span>`;

    for (let i = 0; i < startDay; i++) html += '<span class="cal-day cal-empty"></span>';

    const today = new Date(); today.setHours(0,0,0,0);
    for (let d = 1; d <= last.getDate(); d++) {
      const date = new Date(year, month, d);
      const iso = toIso(date);
      const past   = date < today ? ' cal-past' : '';
      const available = availability.get(iso);
      const state = available === false ? ' cal-booked' : available === true ? ' cal-available' : '';
      html += `<span class="cal-day${past}${state}">${d}</span>`;
    }

    html += '</div></div>';
    return html;
  }

  function render(availability, lang) {
    const container = document.getElementById('availability-cal');
    if (!container) return;

    const now = new Date();
    let html = '';
    for (let i = 0; i < 3; i++) {
      const d = new Date(now.getFullYear(), now.getMonth() + i, 1);
      html += renderMonth(d.getFullYear(), d.getMonth(), availability, lang);
    }

    const availLabel = lang === 'fr' ? 'Disponible' : 'Available';
    const bookedLabel = lang === 'fr' ? 'Réservé' : 'Booked';
    const note = lang === 'fr' ? 'Calendrier synchronisé avec les réservations directes, Airbnb et Booking.' : 'Calendar synced with direct bookings, Airbnb, and Booking.';

    container.innerHTML = `
      <p class="cal-note">${note}</p>
      <div class="cal-wrap">${html}</div>
      <div class="cal-legend">
        <span class="cal-legend-item"><span class="cal-swatch cal-swatch-avail"></span>${availLabel}</span>
        <span class="cal-legend-item"><span class="cal-swatch cal-swatch-booked"></span>${bookedLabel}</span>
      </div>`;
  }

  function buildAvailabilityMap(days) {
    const map = new Map();
    days.forEach((day) => {
      if (day && typeof day.date === 'string') {
        map.set(day.date, day.available === true);
      }
    });
    return map;
  }

  function init() {
    const container = document.getElementById('availability-cal');
    if (!container) return;
    const lang = document.documentElement.lang || 'en';
    const apiUrl = container.dataset.availabilityUrl || DEFAULT_API_URL;
    const now = new Date();
    const from = new Date(now.getFullYear(), now.getMonth(), 1);
    const to = new Date(now.getFullYear(), now.getMonth() + 3, 0);

    fetch(`${apiUrl}?from=${toIso(from)}&to=${toIso(to)}`)
      .then(r => r.ok ? r.json() : Promise.reject(new Error('availability fetch failed')))
      .then(data => render(buildAvailabilityMap(data.days || []), lang))
      .catch(() => {
        container.innerHTML = '';
      });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
