# LogoSC Changelog

## Unreleased — Cheat Sheet rename typo fixed

### Fixed

- Restored the setup variable name `RunLogoTests` in `LogoSC-CheatSheet.md`.
  A mechanical project rename had incorrectly changed it to `RunLogoSCests`.

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

## Unreleased — Project renamed to LogoSC

LogoT has been renamed **LogoSC** to make the OpenSCAD target immediately clear.

### Renamed

- Repository: `LogoT` → `LogoSC` (the GitHub repository will be renamed after
  this source change is committed).
- All project files named `LogoT-*` → `LogoSC-*`.
- Project-specific public version symbols:
  - `LogoTVersionMajor` → `LogoSCVersionMajor`
  - `LogoTVersionMinor` → `LogoSCVersionMinor`
  - `LogoTVersion` → `LogoSCVersion`
  - `LogoTVersionAtLeast()` → `LogoSCVersionAtLeast()`
- Project-prefixed internal/example helpers named `LogoT...` → `LogoSC...`.

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
- Historical entries below retain the LogoT name because that was the project
  name when those milestones occurred.

### Migration

```scad
// Old
include <LogoT-Foundation-Core.scad>
LogoTVersionAtLeast(2026, 0);

// New
include <LogoSC-Foundation-Core.scad>
LogoSCVersionAtLeast(2026, 1);
```

## Documentation and Developer Context

### Added

- `LogoT-Developer-Notebook.md`, a living engineering notebook containing
  project history, design rationale, non-goals, lessons learned, workflow rules,
  regression risks, roadmap items, and a ChatGPT restart/bootstrap sequence.
- Recommended restart reading order:
  1. `LogoT-Developer-Notebook.md`
  2. `README.md`
  3. `CHANGELOG.md`
  4. User manual and implementation notes as needed

### Changed

- Updated repository overview documents and the User Manual to reference the
  Developer Notebook and explain why it exists.
- Converted `LogoT-Future-Context.md` into a compatibility/bootstrap pointer.
  Its previous detailed contents are preserved inside the Developer Notebook.
- Established a policy of preserving dated historical context rather than
  replacing earlier decisions with compressed summaries.

## LogoT-Geometry

Initial geometry milestone.

### Added

- Added `LogoT-CheatSheet.md` and promoted rendering/evaluation API documentation.

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
- Reusable 2D rendering API moved into `LogoT-Foundation-Core.scad`:
  - `RenderRegion2D()`
  - `RenderContours2D()`
  - `RenderLogo2D()`
- Native OpenSCAD `linear_extrude()` and `rotate_extrude()` are intentionally
  left to user models rather than wrapped by LogoT.
- Hole regression tests for washers, rectangular plates, rounded mounting plates,
  repeated holes, scaled holes, and failure cases.
- Visual regression-test colors based on grid X index, with colored LogoT
  marker icons identifying Y-index rows left of the test grid.
- Public API version constants and compatibility helper:
  - `LogoTVersionMajor = 2026`
  - `LogoTVersionMinor = 0`
  - `LogoTVersion = "2026.0"`
  - `LogoTVersionAtLeast(major, minor)`

- `LogoT-Examples.scad` runnable example gallery, including washers, mounting
  plates, radial hole patterns, Koch geometry, twist/rotate extrusions, a spiral
  tower, and the LogoT feature wordmark.

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

## LogoT-Foundation

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
- `LogoTest()` test harness.
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
