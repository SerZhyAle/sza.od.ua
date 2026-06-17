# SZA Web Style Guide

**One technical style for every SZA web property — present and future.**
Version 1.0 · Palette: **Pine + Gold** (dark-green primary, gold secondary).

This document + [`sza-kit.css`](./sza-kit.css) are the single source of truth. Any new site
(or any agent building one) follows this. When in doubt: **compact, minimal, professional,
forward. No water. No over-promotion. We are professionals.**

---

## 0. How to use this kit (for an agent in a repo)

1. Copy [`sza-kit.css`](./sza-kit.css) into the target repo (e.g. `assets/sza-kit.css`) **or** paste its
   contents into the page's `<style>`. All visual tokens live there — change the look in one place.
2. Add the font link in `<head>`:
   ```html
   <link rel="preconnect" href="https://fonts.googleapis.com">
   <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
   <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
   ```
3. Add the pre-paint script (Section 7) **before** the stylesheet so theme/language never flash.
4. Build the page from the components in Section 4 in the order of Section 3.
5. Run the acceptance checklist (Section 11) before declaring done.

---

## 1. Principles

- **Compact & minimal.** Say it once. Tight spacing, few colors, no decorative filler.
- **Forward.** Lead with what the thing *is* and how to *get it*. The visitor's next action is always visible.
- **No water.** Every sentence carries information. No "revolutionary", no "seamless synergy", no padding.
- **No over-promotion.** State facts and honest caveats. One author credit, not a billboard.
- **Humor ≈ 3/5.** Dry, intelligent, occasional. A good line in a section intro is welcome; a joke in every heading is not. Reference voice: *"a brilliant intern with amnesia."*
- **Wide screens and mobile equally.** Fluid layout, real mobile behavior, 44px touch targets.
- **Fast & accessible.** System-font fallback, no heavy libraries unless earned, full keyboard + reduced-motion support.

---

## 2. Site taxonomy (roles)

| Role | Sites | Gets |
|---|---|---|
| **Hub** | sza.od.ua | Header, hero, project grid, 1C/ELTR highlight, contact (copy boxes), footer. No distribution block. |
| **Informational / Docs** | universal-agent-kit | Header, hero, numbered `<details>` TOC, copy boxes, callouts, footer, back-to-top. |
| **App — big** | FastMediaSorter_mob_v2 | Everything + interactive explorer (marked.js) + dynamic release buttons + AdSense + full SEO. |
| **App — medium** | doc-html-translate, FastMediaSorter_Lite, FileDO | Header, hero, **distribution block**, feature sections, copy boxes, footer. |
| **App — small** | CyrFlip | Header, hero, **distribution block**, demo strip, short feature list, footer. |
| **Future** | OneClickRunner, … | Start from this guide. Until built: footer link to GitHub only. |

> ELTR (1C) is the flagship business product, different audience. It lives on the **Hub** content only;
> it is **not** part of the dev-tools footer grid and is out of scope for restyling.

---

## 3. Page order (the contract)

**App sites — above the fold, in this exact order:**

1. **Sticky header** — brand · language (RU EN UA) · theme · primary Download.
2. **H1** — app name. One-line **tagline**.
3. **"What it is & who it's for"** — 1–2 sentences. Plain. (`.get .whatfor`)
4. **Get it block** (`.get`) — *immediately after #3, still above the fold:*
   - **Official channels** that actually exist for this app: Microsoft Store / winget / Google Play / etc.
   - **GitHub Releases** download (always present; dynamic latest where possible — Section 4.10).
   - **Quickstart** — 2–3 numbered steps: install → run → first useful action.
5. Then: features, details, screenshots, FAQ, links.
6. **Footer** — "More tools by SZA" grid + contact.

**Hub & Docs sites:** header → hero → content (grid / numbered sections) → footer. No distribution block on the Hub.

---

## 4. Components

All class names match [`sza-kit.css`](./sza-kit.css). Markup patterns below are the canonical form.

### 4.1 Sticky glass header
```html
<header class="site-header">
  <span class="brand">CyrFlip<span class="dot">.</span></span>
  <div class="seg" role="group" aria-label="Language">
    <button data-lang="ru">RU</button><button data-lang="en" aria-pressed="true">EN</button><button data-lang="ua">UA</button>
  </div>
  <button class="theme-btn" id="themeBtn" aria-label="Switch theme">◐</button>
  <a class="btn btn-primary btn-sm" href="#get">Download</a>
</header>
```

### 4.2 Language switcher — RU · EN · UA, **no flags**
- Visible labels exactly: `RU` `EN` `UA` (note **UA**, not "UK"). Button order: **RU, EN, UA**.
- Mechanism: pure-CSS `data-lang` (Section 6). Persist to `localStorage`. Pre-paint resolver (Section 7).
- No flag emoji, no flag images. Text only.

### 4.3 Theme toggle — light/dark on **every** site
- `◐` button flips `data-theme` on `<html>` between `dark`/`light`. Persist to `localStorage`.
- First visit: `prefers-color-scheme` (default **dark**). Resolve before paint (Section 7).
- Update `<meta name="theme-color">` and `aria-label` on toggle.

### 4.4 Buttons
`btn btn-primary` (green, the main CTA) · `btn btn-gold` (gold, secondary highlight — use sparingly) · `btn btn-ghost` (outline). Add `btn-sm` in headers/cards.

### 4.5 Glass cards / grid
`.grid` (1→2→3 columns) of `.card`. Hover lift + green border. Used for project lists, feature cards.

### 4.6 Numbered collapsible sections (TOC-as-content)
```html
<details class="sec" id="install">
  <summary><span class="secnum">02</span> Install &amp; start</summary>
  <p>…</p>
</details>
```
Number sections `00, 01, 02…`. Deep links auto-open + scroll (Section 7). Provide **Expand all / Collapse all** when there are 4+.

### 4.7 Copy-to-clipboard box
For commands, **and on the Hub for phone & email.**
```html
<div class="copybox"><span class="tok">winget</span> install SerZhyAle.CyrFlip
  <button class="copy" data-copy="winget install SerZhyAle.CyrFlip">Copy</button></div>
```
Clipboard API + `execCommand` fallback; show "✓ Copied" for ~1.6s (`.copy.done`). Script in Section 7.

### 4.8 Callout / note + kbd + pills
- `.note` with uppercase `.tag` (gold border) for "The point" / caveats.
- `kbd` for keys: `<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>F12</kbd>`.
- `.pill` (green) / `.pill.gold` for formats & tags (EPUB, SMB, etc.).

### 4.9 Inline demo strip
One-line "what it does" proof: `input → action → result`.
```html
<div class="demo"><code>ghbdtn</code><span class="arrow">→ Ctrl+Shift+F12 →</span><code class="out">привет</code></div>
```

### 4.10 Distribution channels + dynamic GitHub release
- Render a `btn` per existing official channel (Store / winget / Play). winget/CLI commands go in a `.copybox`.
- **GitHub release:** fetch `https://api.github.com/repos/SerZhyAle/<repo>/releases/latest`, label the button with the
  tag/asset, link to the asset. **Static fallback** to `/releases` if the fetch fails. Never hardcode a version string.

### 4.11 Footer — "More tools by SZA" + contact
```html
<footer class="site-footer"><div class="container">
  <div class="tools-grid"><!-- all sibling tools except the current one (Section 10) --></div>
  <div class="footer-bottom">
    <span>© 2026 Serhii Zhyhunenko</span>
    <span><a href="https://sza.od.ua">sza.od.ua</a> · <a href="https://github.com/SerZhyAle">GitHub</a> · <a href="mailto:sza@ukr.net">sza@ukr.net</a></span>
  </div>
</div></footer>
```

### 4.12 Back-to-top
`.to-top` button, shown after ~600px scroll (Section 7). Long pages only.

---

## 5. Visual language

- **Color:** see tokens in [`sza-kit.css`](./sza-kit.css). Green `--acc` is the primary/CTA color; gold `--gold` is the
  *secondary* accent — use it for one thing at a time (a callout border, a highlight tag), never as a second CTA color.
  Code blocks stay dark in both themes.
- **Typography:** Outfit (headings, 700–800), Plus Jakarta Sans (body, 300–600), system mono for code. Tight letter-spacing on headings (`-0.02em`).
- **Spacing & shape:** radius 16px cards / 10px small / pill buttons. Generous but not airy. `--wide: 1100px` container.
- **Background:** subtle blurred blobs (`.bg-blobs`), opacity ~0.14. Decoration only; never competes with text.
- **Motion:** short (≤0.3s), purposeful (hover lift, fade-in). All disabled under `prefers-reduced-motion`.

---

## 6. Internationalization (RU / EN / UA)

- Three languages: **RU, EN, UA**. Labels text-only (no flags). Visible label for Ukrainian is **UA** (lang attribute may stay `uk`).
- **Default mechanism (Hub, Docs, small/medium apps): pure-CSS toggle.** All languages in the DOM; show the active one:
  ```css
  html[data-lang="ru"] [data-l]:not([data-l="ru"]){display:none}
  html[data-lang="en"] [data-l]:not([data-l="en"]){display:none}
  html[data-lang="ua"] [data-l]:not([data-l="ua"]){display:none}
  ```
  `setLang()` sets `data-lang` + `lang` on `<html>`, persists, and swaps `<title>`/description/OG from a JS map.
- **Big SEO app (FastMediaSorter_mob_v2): keep separate per-language pages** (`index.html`, `index-ru.html`, `index-uk.html`)
  with `hreflang` — but relabel the switcher to RU/EN/UA, no flags, and restyle to the kit.
- First visit: `navigator.language` → `ru*`→RU, `uk*`→UA, else EN. Persisted choice wins.

---

## 7. Required scripts (vanilla, no libraries)

Place a **pre-paint** snippet in `<head>` *before* the stylesheet (prevents theme/lang flash), and the rest before `</body>`.

```html
<!-- in <head>, before CSS -->
<script>
(function(){try{
  var t=localStorage.getItem('sza-theme')||(matchMedia('(prefers-color-scheme: light)').matches?'light':'dark');
  document.documentElement.setAttribute('data-theme',t);
  var l=localStorage.getItem('sza-lang');
  if(!l){var n=(navigator.language||'en').toLowerCase();l=n.indexOf('ru')==0?'ru':n.indexOf('uk')==0?'ua':'en';}
  document.documentElement.setAttribute('data-lang',l);
}catch(e){}})();
</script>
```

Body scripts: `setLang()`, `toggleTheme()`, copy buttons (`data-copy` → clipboard + "✓ Copied"),
`openFromHash()` (auto-open the `<details>` a `#hash` targets + scroll, on load and `hashchange`),
expand/collapse-all, and back-to-top show/hide. Keep it dependency-free
(exception: `marked.js` is allowed only on the big app for markdown-as-data-source).

---

## 8. Content & voice

- **Open with the problem or the "what & for whom"**, not with the brand. ("You bought a book that isn't in your language…")
- **Short answer first**, detail on demand (inside `<details>`).
- **Honest caveats** belong on the page ("DRM not supported", "VR build is separate"). They build trust and kill "water".
- **Self-promotion budget:** one author line in the footer + the cross-link grid. Related tools are mentioned only where genuinely relevant ("for cases this doesn't cover").
- **Humor 3/5:** at most one dry line per section intro. Never in buttons, labels, or error text.

---

## 9. Emoji & icon policy

- **Minimum emoji in prose.** No emoji in headings, paragraphs, buttons, or quickstart steps.
- Emoji are allowed **only as small decorative markers on badges/pills** when there are many and they need quick visual
  differentiation — and even then, prefer a restrained set.
- For UI affordances (theme, copy, download, arrows) prefer **inline SVG icons** or the few neutral glyphs already in the
  kit (`◐ ⤓ → ▸`). Functional, not festive.

---

## 10. Cross-linking map

Canonical URLs for the footer "More tools by SZA" grid. Each site lists **all the others** (omit itself; mark current if shown).

| Tool | Type | URL |
|---|---|---|
| FastMediaSorter v2 | Android media sorter | https://serzhyale.github.io/FastMediaSorter_mob_v2/ |
| FastMediaSorter LITE | Windows media sorter | https://serzhyale.github.io/FastMediaSorter_Lite/ |
| CyrFlip | Windows layout fixer | https://serzhyale.github.io/CyrFlip/ |
| doc-html-translate | Windows ebook converter | https://serzhyale.github.io/doc-html-translate/ |
| FileDO | Windows storage CLI | https://serzhyale.github.io/FileDO/ |
| Universal Agent Kit | AI-dev methodology | https://serzhyale.github.io/universal-agent-kit/ |
| OneClickRunner *(future)* | Windows tray launcher | https://github.com/SerZhyAle/OneClickRunner |
| SZA (hub) | Portfolio | https://sza.od.ua |

Contextual links (in content, where relevant): FMS-Lite ⇄ FMS-mob (desktop/mobile pair); FMS-Lite & doc-html-translate (companions); FileDO is mentioned by FMS for fake-capacity/duplicate checks.

**Contact (standardized):** email **sza@ukr.net** · GitHub **SerZhyAle** · LinkedIn (hub only) · phone **+356 9957 6364** (hub only, copy box).

---

## 11. Acceptance checklist (per site)

- [ ] `sza-kit.css` tokens in use; **no** leftover indigo/purple/cyan; green primary, gold secondary only.
- [ ] Outfit + Plus Jakarta Sans loaded; no Inter / no theme-default fonts.
- [ ] Light + dark both work; toggle persists; **no flash** on reload.
- [ ] Language switcher shows **RU EN UA**, no flags; switching works and persists; metadata localizes.
- [ ] (App sites) Above-the-fold order: name → tagline → "what & for whom" → Get-it (channels + GitHub release + quickstart).
- [ ] GitHub release link is dynamic or, if static, points to `/releases/latest`.
- [ ] Copy buttons work (incl. fallback) and show "✓ Copied".
- [ ] Footer "More tools by SZA" grid present and correct; contact = sza@ukr.net.
- [ ] No emoji in prose; emoji only on badges if needed.
- [ ] Responsive at 360 / 768 / 1280+; 44px touch targets; `prefers-reduced-motion` respected; visible focus.
- [ ] Existing functionality preserved (no broken downloads, anchors, or scripts).
