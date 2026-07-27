# Unify: CyrFlip (SerZhyAle/CyrFlip)

You are working in the **CyrFlip** repo. Good news: it already shares the old design DNA (same fonts, blobs,
`btn` naming) via `style.css`. Recolor to **Pine + Gold**, add light/dark, modernize i18n, and lift install
info into the header. Follow the SZA Web Style Guide; use `sza-kit.css` (pasted above).

## What it is
Tiny Windows tray tool: fixes text typed in the wrong keyboard layout (QWERTY ↔ ЙЦУКЕН) in place via a global
hotkey, and shows a live EN/RU/UA layout marker on the text caret. Single `.exe`, < 50 MB RAM.

## Do
1. Replace `style.css` `:root` tokens with the kit's **Pine + Gold** tokens (it currently mirrors the old
   `#080b11` / `#818cf8` indigo set). Add the `html[data-theme="light"]` token block + a theme toggle (currently none).
   Pull tokens/components straight from `sza-kit.css` - prefer linking it over duplicating.
2. **Language:** today it uses separate folders (`./`, `ru/`, `uk/`) with an EN/RU/UK langbar. Convert to a
   **single page** with the pure-CSS `data-lang` mechanism, labels **RU EN UA** (no flags), folding the `ru/` and
   `uk/` content into `data-l` blocks. (If a full merge is risky, at minimum relabel to RU/EN/UA, reorder, drop any
   flags, and restyle the bar to `.seg` - but single-page is preferred.)
3. Header → kit `.site-header` (brand `CyrFlip.`, lang, theme, Download).
4. **Get-it block (above the fold):** keep the great **demo strip** (`ghbdtn → Ctrl+Shift+F12 → привет`) near the top;
   then channels - **Microsoft Store** button + **winget** in a `.copybox` (`winget install SerZhyAle.CyrFlip`) +
   GitHub Releases (dynamic latest, fallback `/releases`); **quickstart**: run `CyrFlip.exe` (sits in tray) →
   select wrong-layout text → press the hotkey.
5. Keep sections: What it does, How to use (with `kbd`), Features, Install. Use `.note` for the autostart caveat.
6. Footer → kit tools-grid + contact (it already links UAK + hub; expand to the full grid).
7. Blobs (recolored), back-to-top optional (page is short).

## Done when
Style-Guide Section 11 passes. Green+gold, light/dark, RU/EN/UA single-page switcher, demo strip kept, Store+winget+release in header, tools-grid footer.
