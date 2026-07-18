# SZA Project Page Content Specification

Version 1.1 · 2026-07-18

This is a mandatory content and information-architecture contract for every SZA
project page. It complements `SZA-WEB-STYLE-GUIDE.md`: this document controls
meaning, order, and interaction intent; the style guide controls visual and
technical implementation.

## Non-commercial position

The page is a useful working reference, not a sales page. A first-time visitor
must understand, without scrolling far:

1. what the project is;
2. which of their situations it helps with;
3. the first useful outcome they can get;
4. where to start: install, open, or read the right guide.

Audience priority: everyday user first; developer colleague second; recruiter third.
Technical depth and profile context must be easy to reach, but must not displace the
ordinary user's use case, core functions, or first safe action.

This audience model is an internal design rule. Do **not** render a literal
“Who this site is for” section unless the project itself genuinely needs an
audience selector.

Installation and download are neutral navigation actions. Do not use urgency,
superlatives, marketing claims, invented channels, or repeated CTAs.

## Required source facts

Before editing, extract and verify from the repository and public release
channels:

- name, platform, current editions, and real distribution channels;
- one job to be done, audience, and first useful outcome;
- three to five top user scenarios;
- exact quick-start steps and commands;
- limitations, compatibility constraints, permissions, and data risks;
- screenshots/demo material and documentation URLs;
- one genuinely relevant sibling-tool relationship.

Never invent an install method, command, capability, platform, release asset, or
compatibility claim. If a fact is unclear, leave a clear TODO in the proposed
copy and ask the maintainer rather than guessing.

## Mandatory page order for apps

1. Sticky header: brand, RU / EN / UA, theme, and one neutral link to `#get`.
2. H1 and one-line outcome tagline.
3. **What it is and who it is for**: one or two plain sentences.
4. **Proof of the use case**: one demo strip, screenshot, or three to five
   scenario cards. The core functions/scenarios belong near the top. Use a
   scenario before a feature catalogue.
5. **Get started** (`#get`): real channels; GitHub Releases; two or three
   steps from install to the first useful result. Make the safe path primary.
6. Three to six feature groups, described through user outcomes. Put extensive
   detail in disclosure sections or child documentation.
7. Variant/edition selector only when variants exist and the choice affects the
   user.
8. Practical guides, FAQ, and troubleshooting.
9. Technical details, full compatibility information, source code, privacy,
   licence, and honest caveats.
10. Footer: related SZA tools and contact.

Use expandable `<details>` groups to keep the page dense and make good use of the
available screen area. Put full feature inventories, compatibility, editions,
FAQ, troubleshooting, technical implementation, legal material, and release
history there. Never hide the project purpose, three to five core
functions/scenarios, first safe action, or a material safety warning.

## Layout contract

- Use the full available content width on wide screens. Ordinary text, headings,
  and section introductions outside cards, callouts, and disclosure groups start
  at the left edge of the container and have **no arbitrary narrow max-width**.
- Cards and expandable groups may have their own constrained internal layout;
  they are the exception, not the page default.
- A product page shows its recognisable program mark **once** in the header or
  hero, never both. Follow the SZA hub hierarchy: the header contains one compact
  brand unit (optional small monochrome mark + product name); the hero starts with
  a category/platform eyebrow and an outcome-focused H1, without repeating the
  mark or product name. Do not duplicate an app icon just to fill space.
- Do not use emoji. Use a small single-colour SVG only where it is familiar and
  meaningful. A product mark is permitted only in a monochrome variant; otherwise
  use a neutral outline icon. Icons accompany labels and never replace them.

## Hub contract

The hub is a curated index of **main current products**, not a complete archive
of the author's work. Its order is: compact identity/hero → current products
grid → separate current business/1C product where relevant → contact. Product
cards use the same visual language, including the 1C product; no oversized
“flagship” banner. Do not frame navigation as a game or a “choose your task”
flow. Use neutral copy such as “My main current products”.

For a dangerous operation (delete, wipe, overwrite, elevated action), the first
path must be inspect / preview / dry-run / backup where available. The risk and
its irreversibility must be visible before the action is introduced.

## Variants

- **Small utility:** hero → proof → get started → three-step use → features →
  caveats.
- **Medium app:** hero → what/for whom → scenarios → get started → features →
  guides → details.
- **Large app:** hero → what/for whom → three to five priority scenarios → get
  started → task explorer → guides → technical map.
- **Documentation/method:** hero → audience → choose a path → minimum start →
  detailed method → download and reference.
- **Business product (ELTR):** business/accounting situation → suitable business
  types → typical first workflow → screenshots and short guide → functional
  groups → setup and documentation. It does not have to imitate a dev-tool site.

## Copy rules

- Lead with a verb and result: “Check a drive”, “Sort a folder”, “Fix typed
  text”, “Open an EPUB in the browser”.
- Name the audience through a situation, not “everyone”.
- One card = one recognisable task, not a compressed feature list.
- Place caveats next to the affected action.
- Use stable action labels: **Install**, **Get started**, **Guides**,
  **Documentation**, **Source code**.
- Put commands in copy boxes and show their expected effect.
- Related tools occur in body copy only when contextually useful; the complete
  family is in the footer.
- No pomp or promotional language: no “best”, “revolutionary”, “unmissable”,
  urgency, pressure, or claims that cannot be demonstrated.
- No emoji. Use a small single-colour SVG only when it is familiar and helps
  identify a section or action; use a product icon only when it is recognisable
  to the product's users and has a monochrome variant. Icons support labels and
  never replace them.

## Acceptance test

An unfamiliar visitor should be able to say, before a deep scroll: “This is
___; it is for me when ___; I start by ___.” They should then reach the first
useful result in two or three documented steps.

Also pass the technical checklist in Section 11 of `SZA-WEB-STYLE-GUIDE.md`.
