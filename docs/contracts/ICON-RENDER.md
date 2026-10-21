# ICON-RENDER

- **Id:** `ICON-RENDER`
- **Version:** 0.24
- **Home:** the shared contracts catalog, `iconography/README.md` - see [CLAUDE.md](../../CLAUDE.md) for where the catalog is
- **Role:** consumer. This hub renders any adopted action glyph according to the shared web rules.

## What this repo must do to stay conformant

- Use the supplied 24 x 24, `currentColor` geometry; do not redraw a vocabulary glyph locally. The hub gets its glyphs
  from the kit's `.gi-*` vector masks, whose path data equals the catalog's `glyphs/*.svg`.
- Use the mono look for controls; target size and glyph size come from UI-SIZING and the kit's stable profile, not
  from a fixed floor.
- Use a product mark or other identity artwork only where it represents that product, never as an action glyph.

## Current adoption

- Read at 0.24 on 2026-10-21. Five glyph controls render from catalog geometry at the profile's size; measured with
  the ticket's checks (glyph size per scenario, glyph contrast 3:1 on the actual face). See [../iconography-inventory.md](../iconography-inventory.md).
