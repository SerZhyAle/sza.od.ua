# Per-repo unification prompts

How to run each one:

1. Open an agent **inside the target repository**.
2. Paste, in this order:
   - `kit/SZA-WEB-STYLE-GUIDE.md` (the full guide)
   - `kit/sza-kit.css` (the drop-in CSS)
   - the matching prompt file from this folder
3. Let the agent work, then verify against the **acceptance checklist** (Section 11 of the guide).

**Suggested order** (greenfield first to validate the kit, hardest last):

1. `filedo.md` — Jekyll → kit (greenfield reskin, validates the kit end-to-end)
2. `fms-lite.md` — Jekyll → kit (same shape as FileDO)
3. `cyrflip.md` — already shares DNA, small
4. `doc-html-translate.md` — closest to kit already
5. `universal-agent-kit.md` — recolor + fonts, keep its strong docs UX
6. `fms-mob.md` — biggest, most hardcoded colors + canvas JS
7. `hub.md` — sza.od.ua (this repo)

**Standing assumptions (change here if wrong):**
- Primary contact email = **sza@ukr.net** (hub currently shows gmail; switch it).
- Phone (hub only) = **+356 9957 6364**, in a copy box.
- Palette = **Pine + Gold** (green primary, gold secondary).
- Languages = **RU / EN / UA**, no flags; default auto-detected, fallback EN.
- **ELTR** stays Hub-only; not restyled, not in the tools grid.
- **OneClickRunner** = footer link to GitHub only (page deferred).
