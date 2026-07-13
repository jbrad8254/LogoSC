# LogoSC Changelog

## Unreleased — MIT license

### Added

- Added a root `LICENSE` file using the MIT License.
- Updated README/project-overview license references to point to the new license
  file.

## Unreleased — quick start and run-mode cleanup

### Changed

- Updated README Quick Start to use a simple `MOVE`/`TURN` triangle as the first
  model instead of a rectangle-with-hole primitive example.
- Added early README guidance for using `RenderLogoDebug()` to inspect the same
  command path and diagnose crossing lines, wrong point order, pen-up movement,
  and unclosed polygons.
- Changed foundation test execution so tests run only when `LogoSCRunMode` is
  explicitly set to `"Tests"`; `"NoDemo"`, a blank string, or an undefined run
  mode suppresses the test grid.
- Removed the active `RunLogoTests` compatibility gate from the core/test path in
  favor of the unified `LogoSCRunMode` selector.
- Removed now-unneeded `LogoSCRunMode = "NoDemo"` assignments from ordinary
  Quick Start snippets; tests still run only when `LogoSCRunMode` is explicitly
  set to `"Tests"`.
- Updated Quick Start overlay snippets to use centered extrusion and a taller
  debug segment height so z-centered debug capsules remain visible.

## Unreleased — debug renderer documentation

### Added

- Updated public documentation for the unified `LogoSCRunMode` selector.
- Added User Manual coverage for `RenderLogoDebug()`, including how to use debug
  lines/points to diagnose crossing/self-intersecting contours and unclosed
  polygons.
- Added Cheat Sheet entries for debug visualization and the new run selector.

### Changed

- Replaced stale setup references that still described the older separate
  examples/tests/debug switches.
- Updated README/project-overview status text now that preview-only debug
  rendering is implemented and verified.

## Unreleased — debug demo selector cleanup

### Changed

- Renamed the debug demo `Right` option to `Rectangle` for clearer Customizer labeling.
- Rewrote the crossed-rectangle debug demo to use the same four corner points as
  the rectangle demo, with no explicit `PENUP`/`PENDOWN` commands.
- Added `DebugDemoOverlay` as a single checkbox to show or hide all debug overlay
  lines, point markers, and related debug objects while leaving the optional filled
  2D preview under `DebugDemoFilled`.

### Notes

- Public docs were updated later in the debug-renderer documentation pass.

## Unreleased — unified Customizer run selector

### Changed

- Replaced the separate example/test/debug top-level Customizer switches with a
  single `LogoSCRunMode` string selector using `NoDemo`, `Examples`, `Debug`, and
  `Tests` values.
- Kept `RunLogoTests` as a hidden compatibility gate so older client files can
  still override it after including `LogoSC-Foundation-Core.scad`.

### Notes

- Public docs were updated later to describe `LogoSCRunMode` and remove
  outdated `RunLogoTests`/`RunLogoExamples` demo-control guidance.

## Unreleased — debug renderer start-marker tuning

### Changed

- Restored debug end-point marker radius/height defaults to normal point-marker size.
- Changed debug start-point markers to be 15% taller and 5% narrower than normal
  point markers so co-located closed paths leave a visible lime start marker through
  the red end marker.

## Unreleased — debug renderer crossing example and endpoint tuning

### Changed

- Changed debug end-point markers from 10% shorter to 15% shorter than normal point
  markers so co-located start/end points leave more of the lime start marker visible.

### Added

- Added a crossed-rectangle debug demo with the lower two rectangle corners swapped in
  the polygon path order. This intentionally self-intersecting case demonstrates how
  the debug overlay makes unexpected crossing lines visible.

### Notes

- When user-facing documentation is updated, add a User Manual section explaining
  crossing-line/self-intersecting contours and how the debug renderer is intended to
  expose them.

## Unreleased — debug renderer overlap and example tuning

### Changed

- Changed default pen-up debug capsules to 50% of normal segment height and
  increased their default alpha to `0.75` for better visibility in overlaps.
- Changed the primitive debug segment color to a darker purple so primitive-generated
  edges are easier to distinguish from normal `MOVE` segments.
- Changed end-point debug markers to be 10% wider and 10% shorter than normal point
  markers so co-located start/end points show as a red cylinder with a green tip.

### Added

- Added an open-triangle debug demo immediately after the closed-triangle demo to
  show the difference between the turtle endpoint and the filled polygon closure.
- Added a stroke-vs-primitive triangle debug demo showing the same triangle constructed
  from `MOVE`/`TURN` commands and as a centered `REGPOLY` primitive.

## Unreleased — debug renderer naming and pen-up visibility tuning

### Changed

- Shortened debug-demo Customizer variable names in `LogoSC-Examples.scad` from
  `LogoSCDebugDemo*`/`ShowLogoSCDebugDemo*` to compact `DebugDemo*` names.
- Changed the default pen-up debug color to pale semi-transparent pink so pen-up
  moves remain visible without overpowering normal movement segments.
- Added `penUpHeightScale` to the debug renderer path so pen-up capsules can be
  rendered shorter than normal capsules; the default scale is `0.75`.

## Unreleased — experimental debug renderer

### Added

- Added preview-only debug event extraction and rendering to `LogoSC-Foundation-Core.scad`.
- Added `RenderLogoDebug()` for z-centered 3D capsule/point-marker overlays.
- Added an optional Customizer-controlled debug overlay demo to `LogoSC-Examples.scad`.

### Changed

- Reduced default debug segment and point marker sizes for less cluttered previews.
- Shifted the default debug palette toward bright magenta, with dim magenta pen-up
  moves, darker green `GOTO` segments, and lime/red start/end markers.
- Grouped example Customizer controls under collapsible headings.
- Replaced the initial crossing debug demo with stepped non-crossing examples for
  simpler visual verification.
- Replaced demo capsule/point visibility checkboxes with zero-capable size controls.

### Notes

- This is a diagnostic renderer, not a manufacturable stroke/solid-output API.
- README, User Manual, and Cheat Sheet documentation are intentionally deferred until
  OpenSCAD visual verification.

## Unreleased — old working-name references removed

### Changed

- Removed public and historical documentation references to the discarded
  pre-release working name.
- `RunLogoTests` remains unchanged because it is the live test-control variable,
  not a project-name reference.

## Unreleased — test-control variable consistency patch

### Fixed

- Restored live test-control variable references to `RunLogoTests` across core,
  tests, examples, and user-facing documentation.
- Updated README public API version references to match the core `2026.1`
  version constants.

## Unreleased — Cheat Sheet rename typo fixed

### Fixed

- Restored the setup variable name `RunLogoTests` in `LogoSC-CheatSheet.md`.
  A mechanical identifier cleanup had changed it incorrectly.

## Unreleased — Gear icon image added

### Added

- Added `images/logosc-gear-icon.png` as the standalone LogoSC gear icon.
- Added the gear icon as a small right-aligned thumbnail near the top of `README.md`.
- Added the gear icon to the upper-right corner of `LogoSC-CheatSheet.md`.

## Unreleased — Wordmark image added

### Added

- Added `images/logosc-wordmark.png` as the project wordmark image.
- Added the wordmark image to the top of `README.md`.
- Added the wordmark image to the top of `LogoSC-User-Manual.md`.

## Unreleased — LogoSC project identity finalized

LogoSC is the sole project name used by the repository and documentation.

### Changed

- Repository naming, source filenames, and documentation links now use `LogoSC`
  and `LogoSC-*` naming.
- Project-specific public version symbols use:
  - `LogoSCVersionMajor`
  - `LogoSCVersionMinor`
  - `LogoSCVersion`
  - `LogoSCVersionAtLeast()`
- Project-prefixed internal/example helpers use `LogoSC...`.

### Preserved APIs

The main Logo programming APIs remain unchanged:

- `RenderLogo2D()`
- `RenderContours2D()`
- `RenderRegion2D()`
- `evalLogo()`
- `ResultState()`, `ResultContours()`, `ResultStack()`, `ResultPen()`
- `MakeRegion()`, `RegionOuter()`, `RegionHoles()`
- all command opcodes, including `MOVE`, `TURN`, `ARC`, `CIRCLE`, and `HOLE`

### Changed

- Public API version advanced from `2026.0` to `2026.1`.
- Includes and documentation links now use `LogoSC-*` filenames.

### Current include pattern

```scad
include <LogoSC-Foundation-Core.scad>
LogoSCVersionAtLeast(2026, 1);
```

## Documentation and Developer Context

### Added

- `LogoSC-Developer-Notebook.md`, a living engineering notebook containing
  project history, design rationale, non-goals, lessons learned, workflow rules,
  regression risks, roadmap items, and a ChatGPT restart/bootstrap sequence.
- Recommended restart reading order:
  1. `LogoSC-Developer-Notebook.md`
  2. `README.md`
  3. `CHANGELOG.md`
  4. User manual and implementation notes as needed

### Changed

- Updated repository overview documents and the User Manual to reference the
  Developer Notebook and explain why it exists.
- Converted `LogoSC-Future-Context.md` into a compatibility/bootstrap pointer.
  Its previous detailed contents are preserved inside the Developer Notebook.
- Established a policy of preserving dated historical context rather than
  replacing earlier decisions with compressed summaries.

## LogoSC Geometry

Initial geometry milestone.

### Added

- Added `LogoSC-CheatSheet.md` and promoted rendering/evaluation API documentation.

- `ARC` command:
  - `[ARC, radius, degrees[, segments]]`
- ARC tessellation into contour points.
- OpenSCAD-style automatic segment selection using `$fn`, `$fa`, and `$fs`.
- ARC regression tests for quarter arcs, semicircles, full-circle-ish arcs, pen-up
  arcs, REPEAT, RUN, scaled arcs, and rounded-rectangle construction.
- Closed shape commands for 3D-printing-oriented geometry:
  - `[CIRCLE, radius[, segments]]`
  - `[REGPOLY, sides, radius[, rotation]]`
  - `[RECT, width, height]`
  - `[ROUNDEDRECT, width, height, radius[, segments]]`
- Closed-shape regression tests for circles, regular polygons, rectangles,
  rounded rectangles, pen-up behavior, scaling, and RUN scaling.
- `HOLE` command:
  - `[HOLE, cmds]`
- Region-based rendering where each region is `[outer, hole0, hole1, ...]`.
- OpenSCAD `polygon(points=..., paths=...)` output for regions with holes.
- Reusable 2D rendering API moved into `LogoSC-Foundation-Core.scad`:
  - `RenderRegion2D()`
  - `RenderContours2D()`
  - `RenderLogo2D()`
- Native OpenSCAD `linear_extrude()` and `rotate_extrude()` are intentionally
  left to user models rather than wrapped by LogoSC.
- Hole regression tests for washers, rectangular plates, rounded mounting plates,
  repeated holes, scaled holes, and failure cases.
- Visual regression-test colors based on grid X index, with colored LogoSC
  marker icons identifying Y-index rows left of the test grid.
- Public API version constants and compatibility helper:
  - `LogoSCVersionMajor = 2026`
  - `LogoSCVersionMinor = 0`
  - `LogoSCVersion = "2026.0"`
  - `LogoSCVersionAtLeast(major, minor)`

- `LogoSC-Examples.scad` runnable example gallery, including washers, mounting
  plates, radial hole patterns, Koch geometry, twist/rotate extrusions, a spiral
  tower, and the LogoSC feature wordmark.

### Removed

- `RenderContours()` compatibility alias. Use `RenderContours2D()` for
  pre-evaluated regions or `RenderLogo2D()` for command lists.

### Notes

- `CIRCLE` is a centered closed contour, not classic Logo circle motion.
  Use `[ARC, radius, 360]` when cursor-style full-loop motion is desired.
- `ROUNDEDREGPOLY` is intentionally deferred. It needs a clearer corner-rounding
  model before becoming a first-class command.

### Known limitations

- Geometry output is now closed-region `polygon(points=..., paths=...)` output.
- Holes are represented as secondary paths inside a region.
- Open-stroke rendering is deferred.
- Stroke width, cap style, join style, and miter limits are not implemented yet.

## LogoSC Foundation

Initial stable foundation baseline.

### Added

- OpenSCAD Logo-style interpreter.
- Integer opcodes.
- Named state, command, and result indices.
- Low-level state transform functions:
  - `stateMake`
  - `stateMove`
  - `stateTurn`
  - `stateDir`
  - `stateScale`
  - `stateGoto`
- One `Eval*()` handler per opcode.
- `evalLogo()` main evaluator.
- `evalLogoR()` recursive child-list evaluator.
- `evalRepeatLogo()` repeat evaluator.
- Regression test harness.
- Reusable 2D renderer.
- Core commands:
  - `MOVE`
  - `TURN`
  - `DIR`
  - `SCALE`
  - `GOTO`
  - `RUN`
  - `REPEAT`
  - `PUSH`
  - `POP`
  - `PENUP`
  - `PENDOWN`
- Multiple disconnected filled contours rendered as separate `polygon()` calls.
- Soft/hard error mode through `HardErrors`.
- Static and execution tracing through `TraceLevel`.
- Regression tests gated by `RunLogoTests`.

### Known limitations

- Filled contours only.
- No stroke/open-path rendering yet.
- `polygon()` automatically closes each contour.
