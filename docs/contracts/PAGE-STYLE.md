# PAGE-STYLE

- **Id:** `PAGE-STYLE`
- **Version:** 1.6
- **Home:** the shared contracts catalog, `product-web-pages/PAGE-STYLE.md` - see [CLAUDE.md](../../CLAUDE.md) for where the catalog is
- **Role:** producer and consumer. This repo owns the contract and its page is built from it.

## What this repo must do to stay conformant

- `kit/sza-kit.css` is the deployment copy of the catalog's `product-web-pages/reference/sza-kit.css`,
  which is canonical (15661 bytes, SHA-256 `27501a1078653b78a7150250857313625bfe884bcc41a1272b7d7d483cef2895`).
  They must be byte-identical; `index.html` serves this repo's copy.
- The kit is never edited in a repo; `.gitattributes` marks `kit/sza-kit.css -text`.
- `index.html` passes `PAGE-STYLE` section 11, in the hub role: no distribution block, no tools grid.
- Pre-paint theme and language resolver, RU / EN / UA switcher and copy boxes stay as section 7 defines
  them (`ua` key against `uk` `lang`/`hreflang` code). `embed.html` is byte-identical to `index.html`.
- 44px min-height/width on buttons (`.btn`, `.seg button`, `.theme-btn`) for every pointer (1.4); reduced-motion
  covers `*, *::before, *::after` (1.5); theme button is labelled (1.4); secondary pages may use language picker (1.6).
- Amendments are written in the catalog first, then here.
