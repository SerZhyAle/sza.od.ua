# Repository Guidelines

Read `CLAUDE.md` in full; it is the authoritative agent contract for this repository, including its
`sza-unified-rules` canon pointer and reference consumption model.

## Project Structure & Publishing

This is a hand-authored, static portfolio hub served by GitHub Pages. `index.html` is the canonical site page; `embed.html` is the Google Sites variant and must remain byte-identical to it. Root-level `assets/` contains site images and icons, while `kit/sza-kit.css` is the shared stylesheet served by the page. Keep that CSS byte-identical to its canonical counterpart described in `docs/contracts/PAGE-STYLE.md`.

Use `google-sites-publish/` only for the published Google Sites render and supporting previews; do not edit its generated content in place. `github-root-redirect/` hosts the origin redirect. `docs/contracts/` contains concise pointers to the shared content, style, and site-family contracts.

## Development & Validation

There is no build system or automated test suite. Between publishes, inspect what changed and run the fast check; for page changes, a direct look at `index.html` is useful.

- `pwsh -NoProfile -File tools/fast-check.ps1` checks the page and embed for byte identity.
- Before publishing, follow the complete pre-flight in `CLAUDE.md`. `deploy.bat "Describe the change"` then runs the compliance gate, stages all changes, creates a dated commit (or uses the supplied message), and pushes `main`. Review `git status` first: this command publishes everything staged by `git add .`.

## Coding Style & Content

Preserve the existing HTML/CSS/JavaScript formatting and use two-space indentation in page markup. Prefer the existing CSS custom properties and component patterns over one-off inline styling. Name new assets descriptively in lowercase, for example `assets/project-name-preview.png`.

The pages `index.html` (en), `uk/index.html`, `ru/index.html`, the byte copy `embed.html`, and `llms.txt` / `llms-full.txt` are rendered by `tools/build-locales.ps1` from `tools/hub/template.html`, `tools/hub/strings.json` (en, ru, uk) and `tools/hub/products.json`. Never edit an output: change the source, every locale in the same edit, then run the build; `-Check` fails on a stale output.

## Commits & Pull Requests

Recent history uses concise imperative summaries such as `Hub: compact hero copy` and maintenance prefixes such as `chore:` or `contrib:`. Use a focused subject that names the affected surface; deployment commits may use the existing `Auto-publish portfolio: ...` format.

For pull requests, describe the visible change, note contract or localization updates, and include screenshots for layout or styling changes. Link relevant issues when available. Do not commit `.env`, tokens, signing material, or local editor/research files.
