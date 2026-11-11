# PAGE-STYLE

- **Id:** `PAGE-STYLE`
- **Version:** 3.8
- **Home:** the shared contracts catalog, `product-web-pages/PAGE-STYLE.md` - see [CLAUDE.md](../../CLAUDE.md) for where the catalog is
- **Role:** producer and consumer. This repo owns the contract and its page is built from it.

## What this repo must do to stay conformant

- `kit/sza-kit.css` is the deployment copy of the catalog's `product-web-pages/reference/sza-kit.css`,
  which is canonical (30698 bytes, SHA-256 `d490abf3bf55455f2cffb92b9ba6305f58c2f1160f3f1ddf70c2d125dd22fa5d`,
  the 2026-11-10 revision 3.8 that draws the pill text in `--acc-strong`).
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
- 3.4 (section 9): the mark of the exchange server is the second full-colour picture a page may carry, unaltered,
  as a head image or inline beside the name, never an action glyph; the kit has no component for it and gains none
  (owner decision K1). The hub page draws no mark, so nothing on it changes.

## Current adoption

- Read at 3.3 on 2026-10-21 (ticket `docs/PLAN-2026-10-17-unified-ui-contracts.md`): the revised kit is vendored,
  the controls are migrated and measured in a headless browser (89 checks, 0 failed). The rest of section 11 was not
  re-run; physical-device, real-font and screen-reader proof are owed (UI_PROFILE section 6).

- S0004, 2026-11-10: the revised kit and locale resolver passed 140 headless checks. Other consumers must re-vendor; physical and assistive proof remains owed.
