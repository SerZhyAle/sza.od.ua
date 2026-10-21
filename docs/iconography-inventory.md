# Iconography inventory

This inventory records how the hub applies `ICON-SET` 0.36, `ICON-RENDER` 0.24, and `ICON-EXTERNAL` 0.12 (read 2026-10-21).

## Functional glyphs

Every glyph is the catalog's 24 x 24 `currentColor` path data, drawn by the kit as a vector mask (`.gi-*`) at the
profile's glyph size (16 px pointer, 20 px touch, scaled). The path data was compared with `glyphs/<id>.svg` on
2026-10-21: all nine kit glyphs are equal to the catalog's.

| Location | Vocabulary id | Kit class | Rendering |
| --- | --- | --- | --- |
| Back-to-top control (icon-only) | `nav.scroll-top` | `.gi-top` | Localized `title` and accessible name in EN, RU, and UK. |
| Theme control, leading | `app.theme` | `.gi-theme` | Beside the visible word Theme / Тема / Тема. |
| Header Contact and email command, leading | `action.email` | `.gi-email` | Beside the visible caption. |
| Phone and email copy controls, leading | `action.copy` | `.gi-copy` | Beside Copy / Copied in the page language. |
| Project links, trailing marker | `nav.open-external` | `.gi-external` | The ICON-SET name (Open in new window / Открыть в новом окне / Відкрити в новому вікні) is the link's visually hidden text. |

No other functional glyph is drawn. Hero commands and the language codes are text-only by the policy recorded in
[UI_PROFILE.md](UI_PROFILE.md) (variant V3).

## Identity artwork

The following assets are product or author identity artwork, outside the action-glyph vocabulary: `sz18_out_800x800_white_on_transp.png`, `fms_mob.png`, `fms_lite.png`, `cyrflip.png`, `doc_translate.ico`, `filedo.png`, `oneclickrunner.png`, `universal_agent_kit.svg`, `streamsplayer.png`, and `eltr.png`.

They may identify their corresponding product only. They must not be recoloured, redrawn, or repurposed as functional controls.

## Shared identity artwork

The mark of the exchange server (`EXCHANGE-MARK` 0.3) is identity artwork of a thing, not of a product, so the sentence
above is read to allow it beside the exchange server's name and nowhere else. The hub neither vendors nor draws it
(owner decision M1, 2026-10-21): the family map names its file, `exchange-mark-small.svg`, and the page shows no entry.
It is not a vocabulary glyph; its one-tone form is offered to `ICON-SET` by a catalog proposal and is not decided here.
If the page ever renders an entry, the mark takes a row in this inventory first, with its file, size and rule.
