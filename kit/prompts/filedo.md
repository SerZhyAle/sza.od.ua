# Unify: FileDO (SerZhyAle/FileDO)

You are working in the **FileDO** repo. Its GitHub Pages site is currently a Jekyll-rendered README
(generator Jekyll v3.10.0, default theme stylesheet). Replace it with a **self-contained, kit-styled page**.
Follow the SZA Web Style Guide and use `sza-kit.css` (both pasted above). Palette: **Pine + Gold**.

## What FileDO is
Windows **CLI**: storage speed-testing / benchmarking, **fake-capacity detection**, **secure wipe**, and
**duplicate file analysis & management**. Distributed as a **single static Go binary**.
Audience: power users, sysadmins, anyone verifying drives or cleaning duplicates from the terminal.

## Do
1. Create a static `index.html` at the Pages root that **takes over from the Jekyll README** (keep `README.md`
   for the repo itself). If Pages builds with Jekyll, add `.nojekyll` and/or front-matter so the static
   `index.html` is served as the home page. Detect the actual Pages source (root vs `/docs` vs branch) and adapt.
2. Bring in `sza-kit.css` (as `assets/sza-kit.css` or inlined) + the Outfit/Plus Jakarta Sans font link +
   the pre-paint theme/lang script in `<head>`.
3. Build the page in the guide's order:
   - Sticky header: brand `FileDO.` · lang **RU EN UA** (no flags) · theme toggle · Download.
   - H1 + one-line tagline. Then **"what it is & who it's for"** (1-2 sentences).
   - **Get-it block (above the fold):** GitHub Releases download (dynamic latest - fetch the `.exe`/binary asset;
     static fallback to `/releases/latest`); winget command in a `.copybox` **if** a winget package exists
     (verify in the repo/README - do not invent one); **quickstart**: download binary → put on PATH → run a first command.
   - Feature sections (use `.card` grid or numbered `<details>`): Benchmark, Fake-capacity check, Secure wipe, Duplicates.
     For a CLI, lean on **`.copybox` example commands** for each (real commands from the repo's docs/README).
   - Footer: "More tools by SZA" grid (all siblings per the guide's cross-link map) + contact (sza@ukr.net).
4. Subtle blobs background, light+dark toggle (persist, no flash), back-to-top on long scroll.
5. Localize all copy to **RU / EN / UA** via the pure-CSS `data-lang` mechanism.

## Preserve / cross-link
- Keep all real commands and behavior accurate to the repo; don't fabricate flags or packages.
- Contextual link: FileDO pairs well with FastMediaSorter (fake-capacity / duplicate cleanup) - mention + link.

## Done when
All boxes in Style-Guide Section 11 pass. No Jekyll theme remnants, no indigo colors, green primary + gold secondary,
RU/EN/UA switcher, working copy buttons, dynamic release link, tools-grid footer.
