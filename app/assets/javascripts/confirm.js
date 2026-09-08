(() => {
  document.addEventListener("click", function (event) {
    const target = event.target.closest("[data-lv-confirm]");
    if (!target) return;
    if (!window.confirm(target.dataset.lvConfirm)) {
      event.preventDefault();
    }
  });
})();
