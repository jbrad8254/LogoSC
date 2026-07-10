# LogoT Future Context and Handoff Notes

This note is for a future ChatGPT session continuing the LogoT OpenSCAD project from a
clean repository snapshot. It is intentionally different from the project README, user
manual, changelog, and implementation notes. Those files describe what the library is and
how to use it. This file describes the project intent, editing workflow, design priorities,
known pitfalls, and likely next steps.

## 1. Source of truth for the next chat

Use the user-uploaded repository snapshot as the only source of truth.

Do not use older files from ChatGPT File Library, previous chats, generated sandbox files,
or similarly named historical exports unless the user explicitly asks for comparison.
Older LogoT/Turtle versions caused confusion earlier.

Expected current project files include approximately:

```text
LogoT-Foundation-Core.scad
LogoT-Foundation-Tests.scad
LogoT-Examples.scad
LogoT-Experiments.scad
README.md
LogoT-README.md
LogoT-User-Manual.md
LogoT-CheatSheet.md
CHANGELOG.md
LogoT-ARC-Implementation.md
LogoT-Holes-Implementation.md
LogoT-LSystems-Notes.md
.gitattributes
```

There may also be checksum files or generated zip artifacts. Treat checksum files as
transfer artifacts unless the user says they are committed project files.

## 2. Naming and export rules

The user is using Git. Preserve exact project filenames.

Do not create replacement files named `-fixed`, `-v2`, `new`, `copy`, or similar. When a
project file changes, overwrite/export using the same filename. For every work session, deliver all changed or added project files in one combined update
zip containing exact repository filenames, suitable for extracting directly over the repo.
Do not split a session across several update zips unless the user explicitly asks. Preserve
this rule in future handoff notes. The zip workflow has been much more reliable than
individual file downloads in the ChatGPT/Windows app.

When exporting multiple files, include a checksum file in the artifact zip if practical,
but do not assume the checksum file belongs in Git.

Use LF line endings. The repository should include:

```text
*.scad text eol=lf
*.md   text eol=lf
*.txt  text eol=lf
```

## 3. Known ChatGPT / file-handling pitfalls

The ChatGPT Windows app and browser download layers have previously created duplicate
file names, numbered files, and temporary files. Do not infer source truth from UI display
names. The safest pattern is:

1. User uploads a clean zip snapshot.
2. Extract it into a working directory.
3. Patch files there.
4. Rebuild a zip with exact project filenames.
5. Provide the zip as the primary download.

The individual `/mnt/data/LogoT-Foundation-Core.scad` file has sometimes appeared stale
relative to the current zip bundle. Verify content from the active working directory before
making claims.

## 4. Project identity

LogoT is an OpenSCAD Logo-style geometry generator for creating 2D printable regions that
can be passed to native OpenSCAD operations such as `linear_extrude()`, `rotate_extrude()`,
`offset()`, `difference()`, `union()`, `translate()`, `scale()`, and `color()`.

LogoT should remain a 2D region generator. OpenSCAD should remain responsible for 3D
composition.

The main user-facing render function is:

```scad
RenderLogo2D(cmds, convexity = 10);
```

Users can then write:

```scad
linear_extrude(height = 4)
{
    RenderLogo2D(cmds);
}
```

or:

```scad
rotate_extrude(angle = 360)
{
    RenderLogo2D(profileCmds);
}
```

Do not reintroduce `RenderLogoLinear()`, `RenderLogoRotate()`, or extrusion wrapper APIs
unless the user explicitly decides to reverse that design choice.

## 5. Versioning policy

LogoT currently uses a manual Major.Minor style library version in core, approximately:

```scad
LogoTVersionMajor = 2026 + 0;
LogoTVersionMinor = 0 + 0;
LogoTVersion = str(LogoTVersionMajor, ".", LogoTVersionMinor);

function LogoTVersionAtLeast(major, minor) = ...;
```

Do not auto-update the version on every edit/export. Git tracks every commit. The LogoT
version should be bumped only for public API/feature milestones, especially changes that
users might want to test against.

## 6. Core design goals

Primary goals:

- Generate useful 2D geometry for OpenSCAD and 3D printing.
- Preserve a Logo-like programming style where reusable shapes use relative motion.
- Keep the interpreter functional and data-oriented rather than emitting geometry directly
  during evaluation.
- Keep API names using `Logo`, not `Turtle`.
- Keep low-level state functions named around `state*` conventions already established.
- Keep documentation practical and example-driven.
- Prefer small surgical edits over broad regex refactors.

Non-goals for now:

- Full Logo language compatibility.
- Text/font rendering as a first-class LogoT feature.
- Multi-color manufacturing semantics.
- Open stroke rendering with caps/joins.
- Boolean modeling wrappers that duplicate OpenSCAD.

## 7. Current conceptual model

LogoT command lists evaluate into a result containing:

- final Logo state;
- region/contour geometry;
- stack state;
- pen state;
- error state.

A region is conceptually:

```text
[outerContour, holeContour0, holeContour1, ...]
```

Rendering uses OpenSCAD `polygon(points = ..., paths = ...)` so holes are represented by
polygon paths rather than by `difference()`.

The current renderer should expose:

```scad
RenderLogo2D(cmds, convexity = 10);
RenderContours2D(regions, convexity = 10);
RenderRegion2D(region, convexity = 10);
```

`RenderContours()` compatibility alias was intentionally removed to reduce future churn.

## 8. Command design conventions

Document and implement optional arguments as single command forms, not multiple overload
entries. Use notation such as:

```scad
[ARC, radius, degrees[, segments]]
[CIRCLE, radius[, segments]]
[REGPOLY, sides, radius[, rotation]]
[ROUNDEDRECT, width, height, radius[, segments]]
[RUN, cmds[, scale[, maxRec]]]
```

Commands should use soft errors by default unless `HardErrors` is enabled. OpenSCAD
`assert()` stops the whole run, so soft errors are important for test visibility.

## 9. Relative drawing style

The user prefers relative drawing commands inside reusable command lists.

Rule of thumb:

| Situation | Prefer | Reason |
|---|---|---|
| Reusable shape/path/glyph | `MOVE`, `TURN`, `ARC` | Inherits caller position/heading/scale |
| Absolute layout/anchoring | `GOTO`, sometimes `DIR` | Explicit positioning |
| Starting a deterministic example | `GOTO` with heading | Known initial state |
| Stamped CAD-style primitives | `GOTO`, then `CIRCLE`/`RECT`/etc. | Shapes are centered at current state |

Examples were updated to remove internal `DIR` usage and prefer relative `TURN` where
practical. Keep `GOTO` for layout and hole placement.

## 10. Coordinate and turn conventions

LogoT uses OpenSCAD's right-handed coordinate system. In the standard LogoT test/example
view, +X appears left and +Y appears upward. Positive relative turns are right-handed
rotations about the +Z axis; viewed from +Z toward the XY plane, positive turns are
counterclockwise.

This matters because left-handed screen coordinate assumptions have bitten the user before.

## 11. Geometry feature status

Implemented concepts include:

- motion/state: `MOVE`, `TURN`, `DIR`, `SCALE`, `GOTO`;
- structure: `RUN`, `REPEAT`, `PUSH`, `POP`;
- pen control: `PENUP`, `PENDOWN`;
- curves: `ARC` with OpenSCAD-like segment selection;
- closed shape stamps: `CIRCLE`, `REGPOLY`, `RECT`, `ROUNDEDRECT`;
- holes: `[HOLE, cmds]`;
- region rendering through `polygon(points, paths)`;
- test-grid coloring and row markers;
- example gallery including a LogoT wordmark, plates, profiles, L-system-generated fractal
  outlines, a spiral tower, and 3D OpenSCAD wrappers around `RenderLogo2D()`.

The `CIRCLE` command is intentionally CAD-like, not classic Logo-like. It creates a closed
circle centered at the current state and does not move the Logo state. For classic turtle
full-loop behavior, use:

```scad
[ARC, radius, 360]
```

## 12. Segment-count convention

Curved geometry should follow this rule:

- Explicit segment arguments override `$fn`, `$fa`, and `$fs`.
- Omitted segment arguments use OpenSCAD-style automatic selection.
- `$fn > 0` gives the full-circle fragment count; otherwise `$fa` and `$fs` apply.
- `ARC` explicit segments count the arc itself.
- `CIRCLE` explicit segments count the full circle.
- `ROUNDEDRECT` explicit segments count each rounded corner.
- `REGPOLY` uses side count directly and does not consult `$fn`, `$fa`, or `$fs`.

Details belong in `LogoT-ARC-Implementation.md`, not in the README.

## 13. Holes design

Holes are implemented by polygon paths, not OpenSCAD `difference()`.

`[HOLE, cmds]` evaluates child commands and attaches the child contours as holes to the
most recently emitted outer region. It should not move or alter the parent state. Child
commands can create multiple contours, and those can become multiple holes.

For 3D modeling, users may still wrap LogoT output in OpenSCAD `difference()` when they
want to subtract non-LogoT objects such as cylinders, imported meshes, or other solids.

## 14. Color design

Color should remain outside LogoT geometry semantics.

Do not add color to:

- command lists;
- evaluated regions;
- core rendering data;
- `RenderLogo2D()`.

Color is currently useful in the test/example presentation layer through OpenSCAD
`color()` wrappers. Test colors are based on grid position. This is for visual debugging
and screenshots, not 3D-printing semantics.

## 15. Test suite conventions

The core includes tests unconditionally because OpenSCAD `include <>` cannot be reliably
conditionalized. Actual test execution is guarded by `RunLogoTests`.

Important OpenSCAD include pattern for examples/user files:

```scad
include <LogoT-Foundation-Core.scad>
RunLogoTests = false;
TraceLevel = 0; // [0:4]
```

Do not put `RunLogoTests = false;` before the include. Doing so has previously polluted or
confused the Customizer behavior.

The test grid uses logical grid indices, not absolute positions. Row markers and X-index
colors make the test output more readable.

## 16. Documentation status and doc roles

Current docs are split by purpose:

- `LogoT-README.md`: overview, file list, public API quick reference, roadmap.
- `LogoT-User-Manual.md`: full user documentation, setup, command reference, workflows.
- `LogoT-CheatSheet.md`: compact one-page-style reference with method signatures and links.
- `CHANGELOG.md`: release history and milestone notes.
- `LogoT-ARC-Implementation.md`: arc/segment-count design details.
- `LogoT-Holes-Implementation.md`: region/hole rendering design details.
- `LogoT-LSystems-Notes.md`: design notes for L-system example helpers and future fractal examples.
- `LogoT-Examples.scad`: runnable examples and gallery.
- `LogoT-Experiments.scad`: experimental lab bench for unproven rendering approaches.
- `README.md`: short GitHub repository landing page.

The cheat sheet should stay compact, similar in spirit to the OpenSCAD cheat sheet. It
should not become another manual.

## 17. Current release baseline and experiment status

The known-good public baseline is:

```text
GitHub release/tag: v0.2.0-alpha
Release URL: https://github.com/jbrad8254/LogoT/releases/tag/v0.2.0-alpha
Status: core tests and example gallery verified by the user before release
Purpose: stable pre-stroke-rendering baseline
```

`LogoT-Experiments.scad` was added after that release as a separate lab bench. Keep
experimental code there until behavior is understood and the user explicitly approves
promotion into the core.

Stroke experiments completed so far:

1. A reverse-and-append helper converted each outer contour into a doubled-back,
   nominally zero-width polygon. Holes were warned about and discarded.
2. OpenSCAD did not render these degenerate zero-area polygons, even when wrapped in
   `offset()`. Keep this only as a documented negative experiment; it is not a viable
   implementation path.
3. A capsule stroke renderer using `hull()` between circles at consecutive points worked
   and produced visually good round caps, round joins, closed squares, bends, and
   crossings.
4. LogoT's region evaluator stores `MOVE` destinations but does not include the initial
   turtle point in the first contour. For centerline strokes this initially omitted the
   first segment. Do not modify the evaluator just for strokes. The preferred experimental
   direction is for `RenderCapsuleStrokeRegions()` to optionally prepend a supplied initial
   point to the first nonempty contour. Later pen-generated contours should retain their
   normal semantics.

Current experimental renderer controls include stroke width and circle fragment count.
The exact API is not final.

## 18. Near-term likely next steps

Follow this conservative order:

1. Keep `v0.2.0-alpha` as the known-good baseline.
2. Continue work in `LogoT-Experiments.scad`; do not edit core stroke APIs yet.
3. Consider a debug path renderer before promoting capsule strokes. A useful
   `DebugLogoPath2D()`-style module would draw small circles at path vertices, thin
   capsule/hull segments between consecutive points, and distinct start/end markers. It
   should help diagnose initial-point handling, `PENUP`/`PENDOWN` path breaks, `PUSH`/`POP`,
   `ARC` tessellation, L-system output, and accidental closure. The user explicitly wants
   to consider this next.
4. Add non-rendering geometry-invariant tests for path point counts, pen breaks, stack
   restoration, arc endpoints, and scaled `RUN` behavior.
5. Create `LogoT-Strokes-Implementation.md` once the experimental data model and rendering
   behavior are clearer. Document filled regions versus open centerlines, initial-point
   policy, hole behavior, capsule rendering, and the failed zero-width approach.
6. Add additional stroke-oriented L-system examples such as a dragon curve, Hilbert curve,
   or bracketed tree after path extraction/debugging is stable.
7. Promote a public `RenderLogoStroke2D()` API only after the experimental renderer and
   path semantics have been validated. Round caps and round joins are the likely first
   supported behavior.

## 19. Deferred feature ideas

Potential future features:

- first-class procedures or named command-list helpers;
- variables or parameters in the LogoT language;
- better reusable shape libraries;
- automatic fillets;
- `ROUNDEDREGPOLY`, but only after defining clear corner-rounding semantics;
- stroke/open-path renderer;
- cap styles: butt, square, round;
- join styles: miter, bevel, round;
- miter limits;
- hole containment/validity checks;
- explicit examples of `offset()` for thickened paths or clearances;
- documentation for slicer/3D-printing tolerances.

Be cautious about wrapping OpenSCAD features unnecessarily. If native OpenSCAD already
composes cleanly around `RenderLogo2D()`, prefer documentation and examples over new LogoT
opcodes.

## 20. Current user preferences for this project

The user prefers:

- concise but technically precise explanations;
- small surgical edits;
- exact filenames;
- one combined exact-filename update zip containing every changed/added file from the session;
- no unnecessary file variants;
- Git-friendly workflow;
- relative Logo-style commands inside reusable shapes;
- OpenSCAD-native 3D composition outside LogoT;
- clear documentation and cheat sheets;
- practical 3D-printing examples.

Humor is fine, but keep project artifacts themselves professional and useful.

## 21. Suggested first message in the next chat

The user may say something like:

```text
We are continuing the LogoT project. Use the uploaded repository zip as the source of
truth. Ignore older versions from prior chats and File Library. Read LogoT-Future-Context.md
for project handoff notes before making changes.
```

Future assistant: obey that. Do not try to resurrect old sandbox files.
