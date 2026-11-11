# CLAUDE.md - sza.od.ua (SZA portfolio hub)

Agent rules for this repo. Universal conventions are **not** restated here - they live in the canon;
this file carries only the canon pointer and this repo's specifics.

## Canon (source of truth)

The shared portfolio conventions live in the **`sza-unified-rules` repo**, installed as the `sza` Claude
Code plugin - so the rules and the skills that apply them are in every session without a path to follow:

```
/plugin marketplace add SerZhyAle/sza-unified-rules
/plugin install sza@sza-unified-rules
```

Consumption model here is **reference**. Load a skill rather than the whole canon: `sza:release`,
`sza:store-publish`, `sza:feature-to-site`, `sza:spec-to-audit`, `sza:adopt-canon`. This repo's delta record
is `rules/contrib/hub.md` in that repo, and its adoption stamp is `.sza-canon.json` here.

The canon moved out of this repository on 2026-07-27 (with its history) because a local path could not be
reached from CI, from another machine, or by anything that did not already know to look for it.

## Contracts catalog (the only place this repo names it)

The shared contracts catalog is at **`P:\Contracts`**. This line is the one pointer: nothing else in this
repository may carry that path, because whoever clones the repo does not have that drive. Contracts are
**cited by id** - `PAGE-STYLE section 11`, `SITE-FAMILY-MAP rule 3` - never linked.

`docs/contracts/` holds one pointer file per contract this repo touches: id, version, home, role, and what
this repo owes. A pointer is a few lines; a pointer that grows a second page has become a copy. This repo
**owns** `PAGE-CONTENT`, `PAGE-STYLE`, `SITE-FAMILY-MAP` and the `PAGE-CONTENT-VISION` record, so an
amendment is written in the catalog first and the page follows - never the other way round. Its rows live
in the catalog's `_meta/REGISTRY.md`; this repo edits only its own.

## What this repo is (two roles, one repo)

1. **The portfolio website** `sza.od.ua` - a hand-authored single page served via GitHub Pages from an
   allowlist of the site files (`.github/workflows/pages.yml`), mirrored into Google Sites.
2. **The web-kit home** - `kit/sza-kit.css` is the served deployment copy of the catalog's canonical
   `product-web-pages/reference/sza-kit.css`, and must stay byte-identical to it. The style guide and the
   content spec that used to sit beside it moved into the catalog on 2026-09-22; `kit/prompts/` stays, as
   one-off per-repo migration instructions that bind nobody.

## Site facts (overlay)

- **Live pages:** English at root `index.html` (also `x-default`), Ukrainian at `uk/index.html`, Russian at
  `ru/index.html`, served by GitHub Pages, custom-domained to `sza.od.ua` (root `CNAME`). `embed.html` is the
  Google-Sites-embedded variant, **byte-identical** to `index.html`; the compliance gate enforces it.
  `google-sites-publish/` is a published render, never hand-edited in place. `github-root-redirect/` forwards
  the apex/origin to the canonical domain. `llms.txt` and `llms-full.txt` are the AI-discovery files.
- **One source, rendered (PAGE-STYLE 3.7):** all of the above are render targets of `tools/build-locales.ps1`,
  which reads `tools/hub/template.html`, `tools/hub/strings.json` (en, ru, uk) and `tools/hub/products.json`
  (cards and their verified channels). **Never edit an output** - edit the source and run
  `pwsh -NoProfile -File tools/build-locales.ps1`. A card edit is the template or `products.json` plus the `en`,
  `ru` and `uk` entries in `strings.json`, in one edit; the build refuses a key missing from any locale. All three
  locales are authored here and the page is continuously published, so the whole fan-out is part of the one edit.
  `-Check` writes nothing and fails on a stale output; `deploy.bat` and `tools/fast-check.ps1` run it.
- **Card channels (SITE-FAMILY-MAP 1.11):** a card links its landing first, then one link or winget copy box per
  channel that answers and that the product's own landing or README names. No ads and no trackers on any page.
- **Publish:** complete the pre-flight below, then run `deploy.bat` (compliance gate, stage all, dated auto-commit, push `main`); Pages
  rebuilds on push and the domain updates within ~1 min. It clears `GITHUB_TOKEN` first so keyring auth
  wins. A site update is **not** a release - there is no version, tag, or changelog here.
- **The publish is the gate scope.** With no release boundary, anything wrong in the tree reaches
  sza.od.ua about a minute after the push, so `deploy.bat` runs the compliance gate first and refuses to
  commit or push when it reports an error. `SZA_SKIP_GATE=1` publishes anyway; a machine without
  PowerShell 7 or without the `sza` plugin skips the gate with a warning instead of blocking.
- **What is served (S0007 F3):** `.github/workflows/pages.yml` publishes only the site files it lists - the
  pages, `assets/`, `kit/sza-kit.css`, `robots.txt`, `sitemap.xml`, the `llms` files, the favicons,
  `site.webmanifest` and `CNAME`. Everything else stays tracked and is not served; a new served file is added to
  that list in the same edit. The list takes effect once the Pages source is "GitHub Actions"; until that switch
  the legacy branch build serves the whole root and `.nojekyll` keeps it from running Jekyll.

## Working here

- **The web page** follows `PAGE-STYLE` + `kit/sza-kit.css`; its content follows the "Hub contract"
  section of `PAGE-CONTENT`, and its footer and contact follow `SITE-FAMILY-MAP`. All three live in the
  contracts catalog, with pointers in `docs/contracts/`. Propagating a change across the surfaces is the
  `sza:feature-to-site` skill.
- **Between publishes:** no full build or check longer than 5 seconds, unless the owner names the run
  (canon TESTING_AND_QA section 2). Inspect what changed and run `pwsh -NoProfile -File tools/fast-check.ps1`.
  Record each deferred slow rung in the ticket audit as a `RELEASE` item naming its command and say
  "not built, not tested until the release".
- **Publish pre-flight:** before `deploy.bat`, run `pwsh -NoProfile -File tools/docs-check.ps1`,
  `pwsh -NoProfile -File tools/ui-check.ps1`, and `pwsh -NoProfile -File tools/promotion-checkpoint.ps1`;
  resolve findings before publishing. The docs check needs the local corpus and registry, which are absent
  in some clones, and does not check anchors. The UI check covers rendered geometry, contrast and behaviour
  of the page and kit showcase; it writes captures to `docs/ui-evidence/`. Its limits are in
  `docs/UI_PROFILE.md`. The promotion checkpoint probes live endpoints and writes a report under
  `docs/promotion-checkpoints/`; review that report and `git status` before publishing. These checks remain
  manual pre-flight steps so the existing deploy gate and `SZA_SKIP_GATE` behavior stay unchanged.
- **Publish gate:** `deploy.bat` runs `pwsh -NoProfile -File tools/check.ps1`, the full canon gate. It
  resolves the installed `sza` plugin. Do **not** call `$env:CLAUDE_PLUGIN_ROOT/tools/check-compliance.ps1`
  directly: the variable is not exported into a tool shell and the path collapses to `/tools/check-compliance.ps1`.
- **Measured tiers (2026-11-10):** `tools/fast-check.ps1`, 0.297 s, fast, timed direct PowerShell process
  including startup (exit 0); `tools/docs-check.ps1`, 0.541 s, fast on this corpus, timed the same way
  (exit 0), and also required at publish. Reclassify a check if it grows beyond 5 seconds. The full
  `tools/check.ps1`, `tools/ui-check.ps1` and `tools/promotion-checkpoint.ps1` have no recorded wall time
  and are release tier until a publish measures them. UI evidence from 2026-11-10 records 140 passes but
  no duration; no slow check was run to obtain a time.
- **Language:** one home, [AUTHOR.md](https://github.com/SerZhyAle/sza-unified-rules/blob/main/rules/AUTHOR.md)
  "Language" in the canon. Nothing about it is repo-specific here.
