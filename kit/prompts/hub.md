# Unify: SZA Hub — sza.od.ua (SerZhyAle/sza.od.ua, this repo)

You are working in the **hub/portfolio** repo. Files: `index.html` and `embed.html` (the Google-Sites embed copy —
**keep the two identical**). Job: **recolor to Pine + Gold**, adopt the kit, add contact **copy boxes**, refresh the
project grid, and standardize the footer. Follow the SZA Web Style Guide; use `sza-kit.css` (pasted above).
The hub has **no distribution block** (it's not an app).

## Do
1. **Tokens:** replace the inline `:root` indigo/purple/cyan set with the kit's **Pine + Gold** tokens, and add the
   `html[data-theme="light"]` block. Recolor blobs and the avatar glow. Remove every `#6366f1` / `#a855f7` / `#06b6d4` /
   `#818cf8` literal.
2. **Header:** add the kit `.site-header` (brand `SZA.` · language · theme toggle · Email/Contact button). Add the
   **theme toggle** (new) + the pre-paint script.
3. **Language:** the switcher must read **RU EN UA** (order + labels; show Ukrainian as **UA**, not "UK"), no flags.
   Keep the existing `data-i18n` text-swap engine if you prefer, but reorder/relabel the buttons and set the default via
   `navigator.language` (ru→RU, uk→UA, else EN). (Converting to the pure-CSS `data-lang` engine is optional, not required.)
4. **Contact with copy boxes:** in the contact/footer area add `.copybox` entries for **phone `+356 9957 6364`** and
   **email `sza@ukr.net`** (each with a working Copy button). **Standardize the primary email to `sza@ukr.net`**
   (replace the current `serzhyale@gmail.com`; keep gmail only if you want a secondary line). Keep LinkedIn + GitHub links.
5. **Project grid:** keep the cards; ensure links are correct and add the now-live **FileDO site**
   (`https://serzhyale.github.io/FileDO/`) as its "Site" button. **OneClickRunner** stays GitHub-only.
   Optionally add product icons consistently. Confirm each card points to the right Pages site + GitHub.
6. **1C / ELTR highlight:** keep as-is (recolored) — ELTR stays on the hub only.
7. **Footer:** add the kit **"More tools by SZA" tools-grid** (all dev tools) + contact line (sza@ukr.net · GitHub · LinkedIn).
8. Keep all three languages' content in sync (translate any new strings to RU/EN/UA). Blobs + back-to-top.

## Done when
Style-Guide Section 11 passes (minus the app-only Get-it row). Green+gold, light/dark, RU/EN/UA switcher, phone + email
copy boxes, FileDO linked, tools-grid footer, `index.html` and `embed.html` identical.
