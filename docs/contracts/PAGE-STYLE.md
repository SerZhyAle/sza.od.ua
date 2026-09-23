# PAGE-STYLE

- **Id:** `PAGE-STYLE`
- **Version:** 1.0
- **Home:** the shared contracts catalog, `product-web-pages/PAGE-STYLE.md` - see [CLAUDE.md](../../CLAUDE.md) for where the catalog is
- **Role:** producer and consumer. This repo owns the contract and its page is built from it.

## What this repo must do to stay conformant

- `kit/sza-kit.css` is the deployment copy of the catalog's `product-web-pages/reference/sza-kit.css`,
  which is canonical. They must be byte-identical; `index.html` serves this repo's copy.
- `index.html` passes `PAGE-STYLE` section 11, in the hub role: no distribution block, no tools grid.
- The pre-paint theme and language resolver, the RU / EN / UA switcher and the copy boxes stay as
  section 7 defines them. `embed.html` is byte-identical to `index.html`, so every change lands twice.
- Amendments are written in the catalog first, then here.
