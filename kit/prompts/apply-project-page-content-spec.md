# Apply the SZA project-page specification

Use this prompt in the target project repository together with:

1. `kit/SZA-PROJECT-PAGE-CONTENT-SPEC.md` — mandatory content contract;
2. `kit/SZA-WEB-STYLE-GUIDE.md` — visual and technical contract;
3. `kit/sza-kit.css` — shared implementation tokens.

## Task

Rework the project's public landing page so an ordinary visitor first understands
the practical use case, its core functions/scenarios, and the safe route to a
first result. A developer colleague and recruiter are secondary audiences: make
technical/project context easy to reach without placing it before the ordinary
user's route. Treat this as an internal hierarchy; do not add a literal audience
block unless the product actually needs one. This is not a sales page. Preserve
real existing functionality and documentation; reorganise it instead of deleting
useful material.

## Required process

1. Inspect the repository, current public page, README, release metadata, and
   existing documentation. Identify the actual Pages source before editing.
2. Write a short implementation note in your response containing: job to be
   done, audience, first outcome, 3–5 scenarios, real install channels, exact
   quickstart, constraints/risks, and relevant sibling link. Ask for a decision
   only if a fact cannot be verified.
3. Build the page in the exact order required by the content specification.
   Do not put a full feature list, technology stack, badges, author biography,
   or architecture before “what it is and who it is for”.
   Put three to five core user functions/scenarios near the top; keep exhaustive
   material in expandable groups.
   Use the full available content width for ordinary headings and text outside
   cards/callouts/disclosures; do not leave an arbitrary narrow text column.
   Follow the SZA hub identity structure: one compact brand unit in the header
   (optional small monochrome mark + product name), then a hero with a
   category/platform eyebrow and an outcome-focused H1. Do not repeat the mark
   or product name in the hero.
4. Reuse real commands and release assets. For destructive operations, lead
   with inspection, preview, dry-run, or backup where the product supports it.
5. Apply the SZA visual guide: Pine + Gold, light/dark, RU EN UA, accessibility,
   responsive layout, copy boxes, release fallback, correct footer links, and no
   emoji. Use small single-colour SVG/product icons only where they are familiar
   and meaningful.
6. Verify all links, anchor navigation, language strings, theme persistence,
   copy buttons, and the project’s own build/static-site workflow.

## Definition of done

- Before scrolling far, a new visitor can answer: what it is, whether it is for
  them, what outcome it gives, and how to start.
- The get-started block is above the fold on common desktop and mobile layouts,
  after the what/for-whom statement.
- Three to five main functions/scenarios are visible near the beginning, before
  exhaustive reference material.
- Detail is available on demand and does not compete with the first action.
- No capability, command, channel, version, compatibility, or safety claim was
  invented.
- The content specification and style-guide acceptance checks pass.
