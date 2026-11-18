# PAGE-STYLE

- **Id:** `PAGE-STYLE`
- **Version:** 3.13
- **Home:** the shared contracts catalog, `product-web-pages/PAGE-STYLE.md` - see [CLAUDE.md](../../CLAUDE.md) for where the catalog is
- **Role:** producer and consumer. This repo owns the contract and its page is built from it.

## What this repo must do to stay conformant

- `kit/sza-kit.css` is the deployment copy of the catalog's `product-web-pages/reference/sza-kit.css`,
  which is canonical (31950 bytes, SHA-256 `8d49a8f0a36369da62faf56a4dd9f026097f5aeba43b6d8f4f8c0edc56417e42`,
  the 2026-11-17 revision 3.13: Manrope + Golos Text with full Cyrillic; 3.12's header box, forced-colour glyphs and pressed controls).
  They must be byte-identical; `index.html` serves this repo's copy.
- The kit is never edited in a repo; `.gitattributes` marks `kit/sza-kit.css -text`. The page layer carries no
  button, group or checkbox adapter and no `max-width` on the page, a container or running text.
- `index.html` passes `PAGE-STYLE` section 11, in the hub role: no distribution block, no tools grid.
- Pre-paint theme, language and input-profile resolver, RU / EN / UA switcher and copy boxes stay as section 7 and
  the 3.3 amendment define them (`ua` key against `uk` `lang`/`hreflang` code). `embed.html` is byte-identical to
  `index.html`.
- Buttons and glyph controls follow the kit's BUTTONS markup (3.3 amendment); the one primary command is the
  hero's. Profile, scale and the permanent variants are in [../UI_PROFILE.md](../UI_PROFILE.md).
- Amendments are written in the catalog first, then here.
- 3.5: the page may read locale queries; the hub reads `lang`, then `l`, maps `uk` to stored `ua`, and saves a valid query.
- 3.6: the kit aligns brand text with the shared content edge; consumers re-vendor and verify their headers.
- 3.7: the hub publishes one page per locale (`/`, `/uk/`, `/ru/`) rendered by `tools/build-locales.ps1`; the segmented control navigates and the root forwards only on an explicit choice.
- 3.8: the kit draws `.pill` text in `--acc-strong` (light theme 5.31:1 or better, was 4.07:1); consumers re-vendor.
- 3.9 and 3.10 bind product landings and release facts; the hub has neither. 3.11: the hub's root never forwards on
  `navigator.language` (the comment in `tools/hub/template.html` says so and the page does it).
- 3.12: the header box reaches past the content edge by its border and padding, so the brand text keeps both edges
  (`header-brand-inset`, `header-brand-inside-box`); under forced colours each glyph takes its control's system colour
  and a pressed control keeps `Highlight` / `HighlightText` after a theme switch (`forced-glyph-system-colour`,
  `forced-pressed-highlight`); section 9 points to `EXCHANGE-MARK` 0.4 rule 10. Consumers re-vendor.
- 3.13: the kit's font pair is Manrope (headings, 400-800 loaded, 700-800 drawn) + Golos Text (body, 400-700) - the old
  Outfit + Plus Jakarta Sans carry no basic Cyrillic subset, so ru and uk text was set in the system font (S0004 W4, this
  ticket S0017); each page's own font link names the pair (no dead `Outfit:wght@300`), and a ru or uk page is checked that
  the loaded families draw its Cyrillic. Consumers re-vendor.
- 3.4 (section 9): the mark of the exchange server is the second full-colour picture a page may carry, unaltered,
  as a head image or inline beside the name, never an action glyph; the kit has no component for it and gains none
  (owner decision K1). The hub page draws no mark, so nothing on it changes.

## Current adoption

- Read at 3.3 on 2026-10-21 (ticket `docs/PLAN-2026-10-17-unified-ui-contracts.md`): the revised kit is vendored,
  the controls are migrated and measured in a headless browser (89 checks, 0 failed). The rest of section 11 was not
  re-run; physical-device, real-font and screen-reader proof are owed (UI_PROFILE section 6).

- S0004, 2026-11-10: the revised kit and locale resolver passed 140 headless checks. Other consumers must re-vendor; physical and assistive proof remains owed.
- S0004 W4, 2026-11-17: real web fonts in Chromium 148, Firefox 150 and WebKit 26.4 (177 checks, 0 failed), Chrome 157 on an
  Android 15 emulator, Windows High Contrast Black and White measured; the pass found the 3.12 defects, and the kit at 3.12
  passes `tools/ui-check.ps1` (173 checks, 0 failed). Evidence `docs/ui-evidence/2026-11-17/`. Still owed: Safari on Apple
  hardware, a physical phone, a by-ear screen-reader pass. Outfit and Plus Jakarta Sans draw no basic Cyrillic (ticket S0017).
- S0017, 2026-11-17: the 3.13 pair amendment written in the catalog and adopted here in the same pass - the font link of
  `tools/hub/template.html` re-rendered for en / ru / uk, `kit/sza-kit.css` byte-identical to the revised reference
  (SHA-256 `8d49a8f0..`). `CSS.getPlatformFontsForNode` on the rebuilt pages reports Manrope / Golos Text for `h1`,
  `.lead` and `.btn` (see the ticket's `## Last Audit`). `tools/ui-check.ps1` is release tier and reruns at the
  pre-publish pre-flight.
