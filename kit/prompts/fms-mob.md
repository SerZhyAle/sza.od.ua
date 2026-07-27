# Unify: FastMediaSorter v2 (SerZhyAle/FastMediaSorter_mob_v2)

You are working in the **FastMediaSorter_mob_v2** repo - the **biggest, most productized** site. Files: `index.html`,
`index-ru.html`, `index-uk.html`, `styles.css`. **Keep its strengths** (marked.js Feature Explorer, dynamic APK
buttons from the GitHub Releases API, JSON-LD/OG/hreflang SEO, AdSense, perf-aware canvas hero). Job: **recolor to
Pine + Gold**, swap fonts, add light mode + a sticky header, align languages, surface a Get-it block, and add
cross-linking. Follow the SZA Web Style Guide; use `sza-kit.css` (pasted above). This is the highest-effort site -
budget time for hardcoded colors.

## Do
1. **Tokens:** replace `styles.css` `:root` with the kit's **Pine + Gold** dark tokens, and **add the
   `html[data-theme="light"]` block** (this site is currently dark-only). Then hunt hardcoded colors that bypass vars:
   - hero gradient `#150f38`; `h1` gradient stop `#a5b4fc`
   - the many `rgba(102,126,234,*)` literals (badges, card-hover shadow, `.filter-pill-active`)
   - button gradients `rgba(124,58,237,*)` on `.tab-btn.active`, `.v1-cat-btn.active`, `.toggle-v3-btn.active`, `.scenario-pill-btn.active`
   - badge text `#818cf8` / `#22d3ee` / `#f472b6`; scenario-badge `#a5b4fc` / `#f0abfc` / `#67e8f9`
   - `<meta name="theme-color">` `#070512`; the GitHub-corner SVG fill
   Map: standard/primary → green (`--acc`); the second/“VR/common” accents → gold (`--gold`) and green tints. Keep edition
   badges visually distinct using green / gold / a neutral (and you may keep **one** extra hue like cyan if three
   distinct edition colors are truly needed - but lead with green+gold).
2. **Canvas hero JS:** the wave/particle colors are hardcoded HSL blues (`hsla(210±…,75%,60%)`). Re-hue to green
   (~140) and gold (~45). Keep the `visibilitychange` pause and resize re-init.
3. **Fonts:** replace **Inter** with **Plus Jakarta Sans** (body); keep **Outfit** (headings). Update the CSS `@import`/links.
4. **Sticky header:** add the kit `.site-header` (brand `FastMediaSorter v2.` · lang · theme toggle · Download). Add the
   theme toggle + pre-paint script (new for this site).
5. **Language:** keep the **separate pages** (`index.html` / `index-ru.html` / `index-uk.html`) + `hreflang` for SEO, but
   relabel the switcher to **RU EN UA** (no flags) and restyle it to `.seg`. Update `og:locale` labels accordingly.
6. **Get-it block above the fold:** today downloads live far down. Add a concise Get-it near the top after the
   "what & for whom" lead: **Google Play** button *if* the app is published there (verify; otherwise omit) +
   **GitHub Releases APK** (reuse the existing dynamic release fetch) + a 3-step quickstart (install APK → allow the
   source → add a folder / network / cloud). Keep the full Explorer below.
7. **Footer:** add the kit **tools-grid** (currently only UAK is linked). Keep AdSense.
8. **Emoji:** reduce in prose; keep emoji only as edition/badge differentiators.

## Done when
Style-Guide Section 11 passes. Green+gold (CSS **and** canvas JS **and** meta), Plus Jakarta Sans replaces Inter,
light/dark toggle works, RU/EN/UA switcher, Get-it near top, tools-grid footer, Explorer + dynamic APK + SEO intact.
