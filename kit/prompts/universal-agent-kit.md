# Unify: Universal Agent Kit (SerZhyAle/universal-agent-kit)

You are working in the **universal-agent-kit** repo (single self-contained `index.html`). It has excellent docs UX
(numbered `<details>` TOC, hash-open, theme toggle, pure-CSS i18n, copy buttons, ASCII diagrams) - **keep all of it**.
Job: **recolor to Pine + Gold**, **add the brand fonts**, align languages, and add cross-linking. Follow the SZA Web
Style Guide; use `sza-kit.css` (pasted above).

## Do
1. Replace the `:root` (dark) + `html[data-theme="light"]` token blocks with the kit's **Pine + Gold** tokens.
   Map: `--acc` → green, `--acc2` → gold; `--ok` stays green; `--warn` → gold. Then fix hardcoded colors that
   bypass variables: `pre{color:#cdd6f4}` / `pre.diagram{color:#aeb9d6}` → `var(--code-ink)`; white-on-accent text →
   `var(--acc-ink)`; the static `<meta name="theme-color">` + the hardcoded `#0f1115`/`#f7f8fa` inside `applyThemeLabel()`.
   The `color-mix(...var(--acc)...)` tints will green-shift for free.
2. **Add fonts** (currently system-only): add the Outfit + Plus Jakarta Sans `<link>` and set `--font-heading` /
   `--font-body` from the kit. Keep the mono stack for `code/kbd/pre`.
3. **Language:** switcher is EN/RU/UK → **RU EN UA** (order + labels, Ukrainian shown as **UA**), no flags. Keep the
   pure-CSS `data-lang` engine; you may align localStorage keys to `sza-theme` / `sza-lang`.
4. **Header / Get-it:** this is a methodology kit, not a store app. Frame the top as: what it is & for whom →
   **Download kit (.zip)** + the existing "For a new project" / "For an existing project" quickstart anchors. Keep the
   adopt-prompt copy boxes.
5. **Footer:** add the kit **tools-grid** (currently only the hub is linked) + **back-to-top** (long page).
6. Keep the dry-witty voice (it's the reference for humor 3/5). Emoji already minimal - keep it that way.

## Done when
Style-Guide Section 11 passes. Green+gold (incl. diagrams/meta), Outfit+Plus Jakarta Sans loaded, RU/EN/UA, tools-grid footer, all existing docs UX intact.
