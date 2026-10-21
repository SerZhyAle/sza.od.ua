# PAGE-CONTENT

- **Id:** `PAGE-CONTENT`
- **Version:** 1.5
- **Home:** the shared contracts catalog, `product-web-pages/PAGE-CONTENT.md` - see [CLAUDE.md](../../CLAUDE.md) for where the catalog is
- **Role:** producer and consumer. This repo owns the contract; the hub page is bound by one part of it.

## What this repo must do to stay conformant

- Only the "Hub contract" section binds `index.html`: identity/hero, then the current-products grid,
  then the separate 1C/ELTR block, then contact. One visual language for every card, ELTR included.
- No flagship banner, no game framing, no "choose your task" flow. Neutral copy.
- Full width of the screen layout requirement (1.3); identity block rules in hero for app landings (1.3); documentation/method pages label lone repo-hosted ZIP as "Download kit (.zip)" (1.4).
- The mandatory app page order does **not** apply here - the hub is not an app page.
- Amendment of 2026-10-17 (1.5): the hub keeps its own footer exemption (copyright and contact, no grid), has no
  help page and no code surface, and draws only `ICON-SET` glyphs. The locale-URL item (`?lang=`, legacy `?l=`) is held
  as a dated exception in the registry until the owner answers whether a stored-preference landing must read it.
- Read at 1.5 on 2026-10-21 (ticket `PLAN/S0001_contract-sync-20261017.md`); `tools/ui-check.ps1` measures the full-width
  rule at 360, 768, 1280, 1920 and 2560 px. `partial` while that exception is open.
- Amendments are written in the catalog first, then here.
