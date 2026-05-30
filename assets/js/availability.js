(() => {
  const DEFAULT_API_URL = 'https://api.lesvendredis.casa/availability';

  const MONTHS_EN = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  const MONTHS_FR = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
  const DAYS_EN = ['M','T','W','T','F','S','S'];
  const DAYS_FR = ['L','M','M','J','V','S','D'];

  function toIso(date) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  function buildAvailabilityMap(days) {
    const map = new Map();
    (days || []).forEach(day => {
      if (day && typeof day.date === 'string') map.set(day.date, day.available === true);
    });
    return map;
  }

  function renderMonth(year, month, availMap, lang, offset, maxOffset) {
    const months = lang === 'fr' ? MONTHS_FR : MONTHS_EN;
    const days   = lang === 'fr' ? DAYS_FR   : DAYS_EN;

    const first    = new Date(year, month, 1);
    const last     = new Date(year, month + 1, 0);
    const startDay = (first.getDay() + 6) % 7; // Mon=0
    const today    = new Date(); today.setHours(0,0,0,0);

    const prevDisabled = offset === 0 ? 'disabled' : '';
    const nextDisabled = offset === maxOffset ? 'disabled' : '';

    const arrowPrev = lang === 'fr' ? 'Mois précédent' : 'Previous month';
    const arrowNext = lang === 'fr' ? 'Mois suivant'   : 'Next month';

    let grid = '';
    days.forEach(d => { grid += `<span class="cal-dow" aria-hidden="true">${d}</span>`; });
    for (let i = 0; i < startDay; i++) grid += '<span class="cal-empty" aria-hidden="true"></span>';

    for (let d = 1; d <= last.getDate(); d++) {
      const date = new Date(year, month, d);
      const iso  = toIso(date);
      const isPast = date < today;
      const avail  = availMap.get(iso);

      let cls = 'cal-day';
      let dot = '';
      if (isPast) {
        cls += ' cal-past';
      } else if (avail === false) {
        cls += ' cal-booked';
      } else if (avail === true) {
        cls += ' cal-avail';
        dot = '<span class="cal-dot" aria-hidden="true"></span>';
      }
      grid += `<span class="${cls}">${d}${dot}</span>`;
    }

    return `
      <div class="cal-header">
        <button class="cal-arrow" data-dir="-1" aria-label="${arrowPrev}" ${prevDisabled}>‹</button>
        <div class="cal-title">
          <span class="cal-month-name">${months[month]}</span>
          <span class="cal-year">${year}</span>
        </div>
        <button class="cal-arrow" data-dir="1" aria-label="${arrowNext}" ${nextDisabled}>›</button>
      </div>
      <div class="cal-grid" role="grid">${grid}</div>`;
  }

  function init() {
    const container = document.getElementById('availability-cal');
    if (!container) return;

    const lang   = document.documentElement.lang || 'en';
    const apiUrl = container.dataset.availabilityUrl || DEFAULT_API_URL;
    const now    = new Date();

    const fromDate = new Date(now.getFullYear(), now.getMonth(), 1);
    const toDate   = new Date(now.getFullYear(), now.getMonth() + 3, 0);

    let availMap  = new Map();
    let offset    = 0;
    const maxOffset = 2;

    function render() {
      const d     = new Date(now.getFullYear(), now.getMonth() + offset, 1);
      const year  = d.getFullYear();
      const month = d.getMonth();

      const legend = lang === 'fr' ? '• jours libres' : '• available days';

      container.innerHTML = `
        ${renderMonth(year, month, availMap, lang, offset, maxOffset)}
        <p class="cal-legend">${legend}</p>`;

      container.querySelectorAll('.cal-arrow').forEach(btn => {
        btn.addEventListener('click', () => {
          const dir = parseInt(btn.dataset.dir, 10);
          const next = offset + dir;
          if (next < 0 || next > maxOffset) return;
          offset = next;
          render();
        });
      });
    }

    container.innerHTML = `<p class="cal-loading">${lang === 'fr' ? 'Chargement…' : 'Loading…'}</p>`;

    fetch(`${apiUrl}?from=${toIso(fromDate)}&to=${toIso(toDate)}`)
      .then(r => r.ok ? r.json() : Promise.reject())
      .then(data => { availMap = buildAvailabilityMap(data.days); render(); })
      .catch(() => { container.innerHTML = ''; });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
