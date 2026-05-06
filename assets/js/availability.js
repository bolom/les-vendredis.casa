(() => {
  const ICAL_URL = 'https://www.airbnb.fr/calendar/ical/1651467419646453001.ics?t=574acc9c6a3a4a53af597a0ed3002fdb';
  const PROXY = 'https://api.allorigins.win/raw?url=';

  function parseIcal(text) {
    const booked = [];
    const events = text.split('BEGIN:VEVENT');
    for (let i = 1; i < events.length; i++) {
      const dtstart = events[i].match(/DTSTART[^:]*:(\d{8})/);
      const dtend   = events[i].match(/DTEND[^:]*:(\d{8})/);
      if (dtstart && dtend) {
        booked.push({ start: toDate(dtstart[1]), end: toDate(dtend[1]) });
      }
    }
    return booked;
  }

  function toDate(s) {
    return new Date(+s.slice(0,4), +s.slice(4,6)-1, +s.slice(6,8));
  }

  function isBooked(date, booked) {
    const d = date.getTime();
    return booked.some(r => d >= r.start.getTime() && d < r.end.getTime());
  }

  function renderMonth(year, month, booked, lang) {
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
      const past   = date < today ? ' cal-past' : '';
      const booked_ = isBooked(date, booked) ? ' cal-booked' : '';
      html += `<span class="cal-day${past}${booked_}">${d}</span>`;
    }

    html += '</div></div>';
    return html;
  }

  function render(booked, lang) {
    const container = document.getElementById('availability-cal');
    if (!container) return;

    const now = new Date();
    let html = '';
    for (let i = 0; i < 3; i++) {
      const d = new Date(now.getFullYear(), now.getMonth() + i, 1);
      html += renderMonth(d.getFullYear(), d.getMonth(), booked, lang);
    }

    const availLabel = lang === 'fr' ? 'Disponible' : 'Available';
    const bookedLabel = lang === 'fr' ? 'Réservé' : 'Booked';

    container.innerHTML = `
      <div class="cal-wrap">${html}</div>
      <div class="cal-legend">
        <span class="cal-legend-item"><span class="cal-swatch cal-swatch-avail"></span>${availLabel}</span>
        <span class="cal-legend-item"><span class="cal-swatch cal-swatch-booked"></span>${bookedLabel}</span>
      </div>`;
  }

  function init() {
    const container = document.getElementById('availability-cal');
    if (!container) return;
    const lang = document.documentElement.lang || 'en';

    fetch(PROXY + encodeURIComponent(ICAL_URL))
      .then(r => r.text())
      .then(text => render(parseIcal(text), lang))
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
