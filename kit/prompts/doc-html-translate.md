# Unify: doc-html-translate (SerZhyAle/doc-html-translate)

You are working in the **doc-html-translate** repo. This site is the **closest to the kit already** (shares tokens,
has a working theme toggle, pure-CSS i18n, copy boxes, numbered sections, hash-open). Job: **recolor to Pine + Gold**,
relabel languages, and lift install into the header. Follow the SZA Web Style Guide; use `sza-kit.css` (pasted above).
Single self-contained `index.html` (inline `<style>`/`<script>`).

## Do
1. Replace the `:root` (dark) and `html[data-theme="light"]` token blocks with the kit's **Pine + Gold** tokens.
   Then hunt and replace **hardcoded** indigo/purple/cyan that bypass variables:
   - gradient stops `#6366f1` / `#a855f7` / `#06b6d4`
   - `.pill` `rgba(99,102,241,.1/.2)`, `.seg` pressed shadow `rgba(99,102,241,.3)`, glow vars
   - `--blob-1/2/3` colors
   - the **hero inline SVG** `<linearGradient>` stops `#c4b5fd` / `#818cf8` / `#22d3ee`
   - `<meta name="theme-color">` values and the duplicated colors in `applyThemeLabel()`
   Map: primary → green (`--acc`), single highlights → gold (`--gold`); keep code blocks dark.
2. **Language:** switcher is EN/RU/UK → make it **RU EN UA** (order + labels; show Ukrainian as **UA**), no flags.
   Keep the pure-CSS `data-lang` engine; you may align localStorage keys to `sza-theme` / `sza-lang`.
3. **Get-it block in the header zone:** it already has an install section (winget `SerZhyAle.DocHtmlTranslate`) lower down —
   lift a Get-it block to right after the "what & for whom" lead: winget `.copybox` + GitHub Releases (dynamic) + a
   3-step quickstart (install → convert a file → optional translate). Keep the existing deep-linkable sections.
4. **Footer:** standardize to the kit **tools-grid** (it already cross-links hub, FMS-Lite, UAK — expand to the full grid).
5. Keep: theme toggle, copy boxes, numbered `<details>` + hash-open, expand/collapse-all, `prefers-reduced-motion`.

## Done when
Style-Guide Section 11 passes. No indigo/purple anywhere (incl. SVG + meta), green+gold, RU/EN/UA, Get-it in header, tools-grid footer.
