# Design QA

Source visual truth: `outputs/assets/server-first-reference.png` (853 x 1844 px).

Implementation target: `outputs/vpn-prototype.html`.

Viewport: intended mobile app layout, responsive between 320 and 480 CSS px.

State compared: initial connected state, Germany expanded, Munich selected.

## Evidence

- Source visual was inspected from the supplied reference image.
- Static validation passed: JavaScript parses with `new Function`, required interaction contracts are present, and all local visual assets resolve on disk.
- Browser-rendered screenshot: unavailable. The available in-app browser session is bound to a `file:` URL and its URL policy rejected page reload and navigation to the local preview route.

## Fidelity surfaces

- Typography: implemented with system UI fallback and matching display/body hierarchy; browser rendering could not be checked.
- Spacing and layout: the DOM follows the reference order and compact mobile proportions; browser rendering could not be checked.
- Colors and tokens: light translucent surfaces, orange premium accent, green secure status, and the supplied theme backgrounds are implemented as tokens.
- Image quality: the supplied forest, mountain, ocean, cosmos, and shield assets are referenced locally.
- Copy: the key Boonker VPN wording and server-first flow are implemented as editable UI text.

## Primary interactions included

- Connect/disconnect animation and live metric updates.
- Server search, all/favorites/recent filters, country expansion, and city selection.
- Best-ping selection, protocol selection, protection toggles, and themes.
- Settings, account/plan, login demo, premium plan selection, and support chat.

## Findings

- [P1] Browser visual QA is blocked.
  Evidence: the in-app browser URL policy rejected navigating or reloading the local file-backed preview.
  Impact: typography, spacing, and responsive behavior cannot be confirmed against the source image in a rendered browser state.
  Fix: open the prototype through a browser session that permits local preview URLs, then capture and compare the initial connected state at the same viewport.

## Comparison history

- Iteration 1: static structural and syntax verification passed; rendered screenshot comparison blocked by browser URL policy.
- Iteration 2: removed the duplicate power control, reduced the connection card, made the header sticky and transparent, made the bottom navigation fixed, and replaced the incorrect logo crop with a tight shield crop. Rendered screenshot comparison remains blocked by browser URL policy.

final result: blocked
