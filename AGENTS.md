# Repository Guidelines

## Project Structure & Publishing

This is a hand-authored, static portfolio hub served by GitHub Pages. `index.html` is the canonical site page; `embed.html` is the Google Sites variant and must remain byte-identical to it. Root-level `assets/` contains site images and icons, while `kit/sza-kit.css` is the shared stylesheet served by the page. Keep that CSS byte-identical to its canonical counterpart described in `docs/contracts/PAGE-STYLE.md`.

Use `google-sites-publish/` only for the published Google Sites render and supporting previews; do not edit its generated content in place. `github-root-redirect/` hosts the origin redirect. `docs/contracts/` contains concise pointers to the shared content, style, and site-family contracts.

## Development & Validation

There is no build system or automated test suite. Work directly in the HTML, CSS, and assets, then open `index.html` in a browser for a visual smoke test.

- `pwsh -NoProfile -File tools/check.ps1` runs the SZA compliance gate. It reports `SKIPPED` and exits successfully when the optional `sza` plugin is unavailable.
- `deploy.bat "Describe the change"` runs the gate, stages all changes, creates a dated commit (or uses the supplied message), and pushes `main`. Review `git status` first: this command publishes everything staged by `git add .`.

## Coding Style & Content

Preserve the existing HTML/CSS/JavaScript formatting and use two-space indentation in page markup. Prefer the existing CSS custom properties and component patterns over one-off inline styling. Name new assets descriptively in lowercase, for example `assets/project-name-preview.png`.

The page has EN, RU, and UK content dictionaries. Because `setLanguage()` replaces card text at runtime, every card copy change requires four matching edits: the inline fallback plus `en`, `ru`, and `uk` entries. Keep `index.html` and `embed.html` identical after every edit.

## Commits & Pull Requests

Recent history uses concise imperative summaries such as `Hub: compact hero copy` and maintenance prefixes such as `chore:` or `contrib:`. Use a focused subject that names the affected surface; deployment commits may use the existing `Auto-publish portfolio: ...` format.

For pull requests, describe the visible change, note contract or localization updates, and include screenshots for layout or styling changes. Link relevant issues when available. Do not commit `.env`, tokens, signing material, or local editor/research files.
