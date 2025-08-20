function setupHamburger() {
  const btn = document.getElementById("menu-btn");
  const closeBtn = document.getElementById("menu-close");
  const menu = document.getElementById("mobile-menu");
  const overlay = document.getElementById("menu-overlay");
  if (!btn || !menu || !overlay) return;

  const open = () => {
    menu.classList.remove("-translate-x-full");
    overlay.classList.remove("pointer-events-none");
    overlay.classList.add("opacity-100");
    btn.setAttribute("aria-expanded", "true");
    // フォーカスをメニューに
    menu.querySelector("a,button")?.focus();
    document.body.classList.add("overflow-hidden"); // 背景スクロール止め
  };

  const close = () => {
    menu.classList.add("-translate-x-full");
    overlay.classList.add("pointer-events-none");
    overlay.classList.remove("opacity-100");
    btn.setAttribute("aria-expanded", "false");
    document.body.classList.remove("overflow-hidden");
  };

  btn.addEventListener("click", open);
  closeBtn?.addEventListener("click", close);
  overlay.addEventListener("click", close);
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") close();
  });
}

document.addEventListener("turbo:load", setupHamburger);