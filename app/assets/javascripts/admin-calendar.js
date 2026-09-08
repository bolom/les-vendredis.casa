(() => {
  // Month-calendar day detail: clicking a day fetches the server-rendered
  // detail for that date (occupants, origins, cancel action for manual
  // closures) and shows it in the panel. Vanilla JS, no dependency.
  document.addEventListener("click", function (event) {
    const day = event.target.closest("[data-lv-action='show-day-detail']");
    if (!day) return;

    const panel = document.querySelector("[data-day-detail]");
    if (!panel) return;
    const detailUrl = panel.dataset.dayDetailUrl;
    if (!detailUrl) return;

    fetch(detailUrl + "?date=" + encodeURIComponent(day.dataset.date), {
      headers: { Accept: "application/json" },
      credentials: "same-origin"
    })
      .then(function (response) { return response.json(); })
      .then(function (data) { renderDetail(panel, day.dataset.date, data); })
      .catch(function () { panel.hidden = true; });
  });

  function renderDetail(panel, date, data) {
    const title = panel.querySelector("[data-detail-title]");
    const list = panel.querySelector("[data-detail-entries]");
    const blockLink = panel.querySelector("[data-detail-block-link]");

    title.textContent = frenchDate(date);
    list.innerHTML = "";
    if (data.entries.length === 0) {
      const item = document.createElement("li");
      item.textContent = "Journée libre — aucune réservation ni blocage.";
      list.appendChild(item);
    } else {
      data.entries.forEach(function (entry) {
        const item = document.createElement("li");
        const label = document.createElement("span");
        label.textContent = entry.occupant + " · " + entry.origin_label + " · " + entry.range_label;
        item.appendChild(label);
        if (entry.cancel_url) {
          item.appendChild(cancelForm(entry.cancel_url, entry.occupant));
        }
        if (entry.inquiry_url) {
          const link = document.createElement("a");
          link.href = entry.inquiry_url;
          link.textContent = "Voir la demande";
          item.appendChild(document.createTextNode(" "));
          item.appendChild(link);
        }
        list.appendChild(item);
      });
    }

    if (blockLink) {
      const url = new URL(blockLink.getAttribute("href"), window.location.origin);
      url.searchParams.set("starts_on", date);
      const next = new Date(date + "T12:00:00");
      next.setDate(next.getDate() + 1);
      url.searchParams.set("ends_on", next.toISOString().slice(0, 10));
      blockLink.setAttribute("href", url.pathname + "?" + url.searchParams.toString());
    }

    panel.hidden = false;
    panel.scrollIntoView({ behavior: "smooth", block: "nearest" });
  }

  function frenchDate(date) {
    return new Date(date + "T12:00:00").toLocaleDateString("fr-FR", { day: "numeric", month: "long" });
  }

  function cancelForm(cancelUrl, occupant) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content;
    const form = document.createElement("form");
    form.method = "post";
    form.action = cancelUrl;
    if (token) {
      const csrf = document.createElement("input");
      csrf.type = "hidden";
      csrf.name = "authenticity_token";
      csrf.value = token;
      form.appendChild(csrf);
    }
    const button = document.createElement("button");
    button.type = "submit";
    button.className = "admin-button--danger";
    button.textContent = "Annuler ce blocage";
    button.dataset.lvConfirm = "Annuler le blocage de " + occupant + " ? Les dates redeviendront disponibles.";
    form.appendChild(button);
    return form;
  }
})();
