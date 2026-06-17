# Unify: FastMediaSorter LITE (SerZhyAle/FastMediaSorter_Lite)

You are working in the **FastMediaSorter_Lite** repo. The Pages site is currently a Jekyll-rendered README
(default theme). Replace it with a **self-contained, kit-styled page**. Follow the SZA Web Style Guide and
use `sza-kit.css` (pasted above). Palette: **Pine + Gold**.

## What it is
Windows (WinForms / .NET 4.8) **image & video sorter**: fast folder navigation, slideshow / random view,
recent files, move/copy/rename/delete, image panel, customizable shortcuts, EN/RU UI. Broad video support —
H.264/MP4 in-window, everything else falls back to a bundled **LibVLC** engine (no external codecs).
Release bundles are **offline-ready** (VLC runtimes + OCR packs included).
Audience: Windows users who sort large photo/video folders fast, keyboard-first.

## Do
1. Create a static `index.html` at the Pages root that takes over from the Jekyll README (keep `README.md`).
   Add `.nojekyll`/front-matter as needed; detect the real Pages source and adapt.
2. Add `sza-kit.css` + font link + pre-paint script.
3. Page order:
   - Sticky header: brand `FastMediaSorter LITE.` · lang **RU EN UA** · theme · Download.
   - H1 + tagline → **"what & for whom"**.
   - **Get-it block (above the fold):** winget in a `.copybox` (`winget install --id SerZhyAle.FastMediaSorter`);
     GitHub Releases (dynamic latest — show `...-setup.exe` and portable `.zip`; static fallback to `/releases/latest`);
     **quickstart**: install → pick a folder → sort with keys.
   - Feature sections (`.card` grid or numbered `<details>`): Navigation & slideshow, File operations, Video/LibVLC fallback,
     Offline bundles & OCR, Shortcuts.
   - Footer: tools-grid + contact.
4. Blobs, light+dark toggle (no flash), RU/EN/UA via `data-lang`, back-to-top.

## Preserve / cross-link
- **Prominent contextual links:** "Need mobile? → FastMediaSorter v2 (Android)"; "Convert ebooks? → doc-html-translate (companion)".
  Also link FileDO (storage checks). Keep winget id and install notes accurate to the repo.

## Done when
Style-Guide Section 11 passes. No Jekyll/Primer remnants, green+gold, RU/EN/UA, copy buttons, dynamic release, tools-grid footer.
