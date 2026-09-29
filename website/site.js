// palnacare.com: theme and language switching, menus, scroll animations,
// gallery arrows and counters. No libraries; works without it too (the
// page is readable, just English, light/dark by device and not animated).
(function () {
  var root = document.documentElement;
  root.classList.add('js');

  function store(key, value) {
    try {
      if (value == null) localStorage.removeItem(key);
      else localStorage.setItem(key, value);
    } catch (e) {}
  }

  // ── Theme ──────────────────────────────────────────────────────────
  var themeColors = { light: '#fbf7f0', dark: '#121722', baby: '#fff5f7' };
  var themeIcons = {
    light: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
    dark: '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>',
    baby: '<path d="M12 21s-7-4.4-9.3-9A5.4 5.4 0 0 1 12 6.3 5.4 5.4 0 0 1 21.3 12C19 16.6 12 21 12 21z"/>',
    system: '<rect x="3" y="4" width="18" height="12" rx="2"/><path d="M8 20h8M12 16v4"/>'
  };

  function currentTheme() {
    return root.dataset.theme || 'system';
  }
  function effectiveTheme() {
    var t = root.dataset.theme;
    if (t) return t;
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
  function setTheme(theme) {
    if (theme === 'system') delete root.dataset.theme;
    else root.dataset.theme = theme;
    store('palna-theme', theme === 'system' ? null : theme);
    paintTheme();
  }
  function paintTheme() {
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute('content', themeColors[effectiveTheme()]);
    document.querySelectorAll('[data-theme-icon]').forEach(function (svg) {
      svg.innerHTML = themeIcons[currentTheme()];
    });
    document.querySelectorAll('[data-set-theme]').forEach(function (b) {
      b.setAttribute('aria-checked', String(b.dataset.setTheme === currentTheme()));
    });
  }
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', paintTheme);

  // ── Language ───────────────────────────────────────────────────────
  var LANGS = { en: 'EN', ur: 'اردو', roman: 'Roman' };
  var dict = window.PALNA_I18N || {};

  function t(lang, key, fallback) {
    return (dict[lang] && dict[lang][key]) || fallback;
  }

  function setLang(lang, save) {
    if (!LANGS[lang]) lang = 'en';
    root.dataset.lang = lang;
    root.lang = lang === 'ur' ? 'ur' : lang === 'roman' ? 'ur-Latn' : 'en';
    root.dir = lang === 'ur' ? 'rtl' : 'ltr';
    if (save) store('palna-lang', lang);

    // English is the text already in the page; remember it the first time.
    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      if (el.dataset.en == null) el.dataset.en = el.textContent;
      el.textContent = lang === 'en' ? el.dataset.en : t(lang, el.dataset.i18n, el.dataset.en);
    });
    document.querySelectorAll('[data-i18n-html]').forEach(function (el) {
      if (el.dataset.enHtml == null) el.dataset.enHtml = el.innerHTML;
      el.innerHTML = lang === 'en' ? el.dataset.enHtml : t(lang, el.dataset.i18nHtml, el.dataset.enHtml);
    });
    document.querySelectorAll('[data-i18n-attr]').forEach(function (el) {
      // "attr:key" pairs, separated by ";"
      el.dataset.i18nAttr.split(';').forEach(function (pair) {
        var p = pair.split(':'), attr = p[0], key = p[1];
        var saved = 'en' + attr.replace(/[^a-z]/gi, '');
        if (el.dataset[saved] == null) el.dataset[saved] = el.getAttribute(attr) || '';
        el.setAttribute(attr, lang === 'en' ? el.dataset[saved] : t(lang, key, el.dataset[saved]));
      });
    });
    var title = document.querySelector('title[data-i18n-title]');
    if (title) {
      if (title.dataset.en == null) title.dataset.en = title.textContent;
      document.title = lang === 'en' ? title.dataset.en : t(lang, title.dataset.i18nTitle, title.dataset.en);
    }

    // Screenshots in the same language (the hero's back phone shows the other script).
    var shotLang = lang;
    document.querySelectorAll('img[data-shot]').forEach(function (img) {
      var l = img.dataset.alt === 'other' ? (lang === 'ur' ? 'en' : 'ur') : shotLang;
      var src = 'img/' + img.dataset.shot + '_' + l + '.webp';
      if (img.getAttribute('src') === src) return;
      img.classList.add('swapping');
      var next = new Image();
      next.onload = next.onerror = function () {
        img.src = src;
        img.classList.remove('swapping');
      };
      next.src = src;
    });

    document.querySelectorAll('[data-lang-label]').forEach(function (el) {
      el.textContent = LANGS[lang];
    });
    document.querySelectorAll('[data-set-lang]').forEach(function (b) {
      b.setAttribute('aria-checked', String(b.dataset.setLang === lang));
    });
    root.classList.remove('i18n-pending');
  }

  // ── Menus (language, theme, mobile nav) ────────────────────────────
  function closeMenus(except) {
    document.querySelectorAll('.menu.open').forEach(function (m) {
      if (m === except) return;
      m.classList.remove('open');
      m.querySelector('button').setAttribute('aria-expanded', 'false');
    });
  }
  document.querySelectorAll('.menu').forEach(function (menu) {
    var trigger = menu.querySelector('button');
    trigger.addEventListener('click', function (e) {
      e.stopPropagation();
      var open = !menu.classList.contains('open');
      closeMenus(menu);
      menu.classList.toggle('open', open);
      trigger.setAttribute('aria-expanded', String(open));
      if (open) {
        var first = menu.querySelector('[aria-checked="true"]') || menu.querySelector('li button');
        if (first) first.focus();
      }
    });
  });
  document.addEventListener('click', function () { closeMenus(); });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      closeMenus();
      header && header.classList.remove('nav-open');
    }
  });
  document.querySelectorAll('[data-set-theme]').forEach(function (b) {
    b.addEventListener('click', function () { setTheme(b.dataset.setTheme); closeMenus(); });
  });
  document.querySelectorAll('[data-set-lang]').forEach(function (b) {
    b.addEventListener('click', function () { setLang(b.dataset.setLang, true); closeMenus(); });
  });

  var header = document.querySelector('.top');
  var burger = document.querySelector('.burger');
  if (burger && header) {
    burger.addEventListener('click', function (e) {
      e.stopPropagation();
      var open = header.classList.toggle('nav-open');
      burger.setAttribute('aria-expanded', String(open));
    });
    document.querySelectorAll('.nav a').forEach(function (a) {
      a.addEventListener('click', function () { header.classList.remove('nav-open'); });
    });
  }
  if (header) {
    var onScroll = function () { header.classList.toggle('scrolled', window.scrollY > 8); };
    addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  // ── Scroll reveal and counters ─────────────────────────────────────
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  function countUp(el) {
    var target = +el.dataset.count;
    if (reduce) { el.textContent = target; return; }
    var start = performance.now(), dur = 1200;
    (function step(now) {
      var p = Math.min(1, (now - start) / dur);
      el.textContent = Math.round(target * (1 - Math.pow(1 - p, 3)));
      if (p < 1) requestAnimationFrame(step);
    })(start);
  }
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (!e.isIntersecting) return;
        e.target.classList.add('in');
        e.target.querySelectorAll('[data-count]').forEach(countUp);
        io.unobserve(e.target);
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
    document.querySelectorAll('.reveal').forEach(function (el) { io.observe(el); });
  } else {
    document.querySelectorAll('.reveal').forEach(function (el) { el.classList.add('in'); });
  }

  // ── Gallery arrows ─────────────────────────────────────────────────
  var gallery = document.querySelector('.gallery');
  document.querySelectorAll('[data-scroll]').forEach(function (b) {
    b.addEventListener('click', function () {
      if (!gallery) return;
      var card = gallery.querySelector('.shot');
      var step = card ? card.getBoundingClientRect().width + 22 : 320;
      var dir = root.dir === 'rtl' ? -1 : 1;
      gallery.scrollBy({ left: step * dir * +b.dataset.scroll, behavior: 'smooth' });
    });
  });

  // ── Start ──────────────────────────────────────────────────────────
  paintTheme();
  setLang(root.dataset.lang || 'en', false);
})();
