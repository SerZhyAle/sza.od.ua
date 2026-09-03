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

## What this repo is (two roles, one repo)

1. **The portfolio website** `sza.od.ua` - a hand-authored single page served from the repo root via
   GitHub Pages, mirrored into Google Sites.
2. **The web-kit home** - `kit/` holds the SZA web style system consumed by the other properties.

## Site facts (overlay)

- **Live page:** root `index.html`, served by GitHub Pages, custom-domained to `sza.od.ua` (root
  `CNAME`). `embed.html` is the Google-Sites-embedded variant and is kept **byte-identical** to
  `index.html` - edit both in lockstep, and the compliance gate now enforces it. `google-sites-publish/`
  is a published render, never hand-edited in place. `github-root-redirect/` forwards the apex/origin to
  the canonical domain.
- **The hub card i18n trap:** `setLanguage()` overwrites `textContent` from the `i18n` dictionaries on
  load, so the English text inline in a card is only a pre-JS fallback. **Every card edit is four edits** -
  inline fallback plus the `en`, `ru` and `uk` dictionaries. Editing the card body alone is a no-op at
  runtime. All three locales are authored here and the page is continuously published, so there is no
  release boundary to batch the rest of a locale set to - the whole fan-out is part of the one edit.
- **Publish:** run `deploy.bat` (compliance gate, stage all, dated auto-commit, push `main`); Pages
  rebuilds on push and the domain updates within ~1 min. It clears `GITHUB_TOKEN` first so keyring auth
  wins. A site update is **not** a release - there is no version, tag, or changelog here.
- **The publish is the gate scope.** With no release boundary, anything wrong in the tree reaches
  sza.od.ua about a minute after the push, so `deploy.bat` runs the compliance gate first and refuses to
  commit or push when it reports an error. `SZA_SKIP_GATE=1` publishes anyway; a machine without
  PowerShell 7 or without the `sza` plugin skips the gate with a warning instead of blocking.
- **`.nojekyll`** at repo root keeps Pages serving the hand-authored HTML verbatim.

## Working here

- **The web page** follows `kit/SZA-WEB-STYLE-GUIDE.md` + `kit/sza-kit.css`; project-page content
  follows `kit/SZA-PROJECT-PAGE-CONTENT-SPEC.md`. Propagating a change across the surfaces is the
  `sza:feature-to-site` skill.
- **Compliance gate:** `pwsh -File tools/check.ps1` - it resolves the installed `sza` plugin and runs the
  canon gate against this repo. Do **not** call `$env:CLAUDE_PLUGIN_ROOT/tools/check-compliance.ps1`
  directly: that variable is expanded for the plugin's own hook registrations and is not exported into a
  tool shell, so the path collapses to `/tools/check-compliance.ps1` and exits 64.
- **Language:** one home, [AUTHOR.md](https://github.com/SerZhyAle/sza-unified-rules/blob/main/rules/AUTHOR.md)
  "Language" in the canon. Nothing about it is repo-specific here.
