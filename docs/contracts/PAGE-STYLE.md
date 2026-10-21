# PAGE-STYLE

- **Id:** `PAGE-STYLE`
- **Version:** 3.4
- **Home:** the shared contracts catalog, `product-web-pages/PAGE-STYLE.md` - see [CLAUDE.md](../../CLAUDE.md) for where the catalog is
- **Role:** producer and consumer. This repo owns the contract and its page is built from it.

## What this repo must do to stay conformant

- `kit/sza-kit.css` is the deployment copy of the catalog's `product-web-pages/reference/sza-kit.css`,
  which is canonical (30629 bytes, SHA-256 `4aba1dee10cb902ee21ca4d86e4fbeed3bf7931c64b69fe15619727fd038c141`,
  the 2026-10-21 revision that implements BUTTONS, UI-SIZING, COLLAPSIBLE-GROUP and BOOLEAN-OPTION).
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
- 3.4 (section 9): the mark of the exchange server is the second full-colour picture a page may carry, unaltered,
  as a head image or inline beside the name, never an action glyph; the kit has no component for it and gains none
  (owner decision K1). The hub page draws no mark, so nothing on it changes.

## Current adoption

- Read at 3.3 on 2026-10-21 (ticket `docs/PLAN-2026-10-17-unified-ui-contracts.md`): the revised kit is vendored,
  the controls are migrated and measured in a headless browser (89 checks, 0 failed). The rest of section 11 was not
  re-run; physical-device, real-font and screen-reader proof are owed (UI_PROFILE section 6).
