# CLAUDE.md - sza.od.ua (SZA portfolio hub)

Agent rules for this repo. Universal conventions are **not** restated here - they live in the canon;
this file carries only the canon pointer and this repo's specifics.

## Canon (source of truth)

The shared portfolio conventions live in [Unified_Rules/](Unified_Rules/README.md) - read it for
repository layout, documentation, development discipline, testing, release, localization, security,
support, agent usage, and site configuration. Consumption model here is **reference**: the canon is
in-repo, nothing is mirrored. This repo's own delta record is
[Unified_Rules/contrib/hub.md](Unified_Rules/contrib/hub.md) - read it before working here.

Most relevant canon docs for this repo:
[SITE_CONFIGURATION.md](Unified_Rules/SITE_CONFIGURATION.md) (hosting, domain, deploy),
[DOCUMENTATION_CONCEPT.md](Unified_Rules/DOCUMENTATION_CONCEPT.md) (SEO, mandatory pages, house text
style), [LOCALIZATION.md](Unified_Rules/LOCALIZATION.md), and the web style kit in `kit/`.

## What this repo is (three roles, one repo)

1. **The portfolio website** `sza.od.ua` - a hand-authored single page served from the repo root via
   GitHub Pages, mirrored into Google Sites.
2. **The canon home** - `Unified_Rules/` is the single canonical home for every project's shared rules.
3. **The web-kit home** - `kit/` holds the SZA web style system consumed by the other properties.

## Site facts (overlay)

- **Live page:** root `index.html`, served by GitHub Pages, custom-domained to `sza.od.ua` (root
  `CNAME`). `embed.html` is the Google-Sites-embedded variant and is kept **byte-identical** to
  `index.html` - edit both in lockstep. `google-sites-publish/` is a published render, never hand-edited
  in place. `github-root-redirect/` forwards the apex/origin to the canonical domain.
- **Publish:** run `deploy.bat` (stage all, dated auto-commit, push `main`); Pages rebuilds on push and
  the domain updates within ~1 min. It clears `GITHUB_TOKEN` first so keyring auth wins. A site update
  is **not** a release - there is no version, tag, or changelog here.
- **`.nojekyll`** at repo root keeps Pages serving the hand-authored HTML verbatim.

## Working here

- **The web page** follows `kit/SZA-WEB-STYLE-GUIDE.md` + `kit/sza-kit.css`; project-page content
  follows `kit/SZA-PROJECT-PAGE-CONTENT-SPEC.md`.
- **The canon** (`Unified_Rules/`): before committing any change under it, run the gate
  `pwsh -File Unified_Rules/tools/check-rules.ps1` (exit 0 required). To spread the canon into another
  repo, use `Unified_Rules/SPREAD_BACK_PROMPT.md` (one repo per session).
- **House text style** (`..` not `...`; plain hyphen `-`; Russian `ё`; prose + UI only, never code):
  [DOCUMENTATION_CONCEPT.md §5](Unified_Rules/DOCUMENTATION_CONCEPT.md).
- **Language:** chat in Russian; files, code, and commits in English (co-author trailer per the canon's
  GITHUB_INTERACTION.md).
