# LogoT Changelog

## LogoT-Geometry

Initial geometry milestone.

### Added

- `ARC` command:
  - `[ARC, radius, degrees]`
  - `[ARC, radius, degrees, segments]`
- ARC tessellation into contour points.
- OpenSCAD-style automatic segment selection using `$fn`, `$fa`, and `$fs`.
- ARC regression tests for quarter arcs, semicircles, full-circle-ish arcs, pen-up
  arcs, REPEAT, RUN, scaled arcs, and rounded-rectangle construction.
- Closed shape commands for 3D-printing-oriented geometry:
  - `[CIRCLE, radius]`
  - `[CIRCLE, radius, segments]`
  - `[REGPOLY, sides, radius]`
  - `[REGPOLY, sides, radius, rotation]`
  - `[RECT, width, height]`
  - `[ROUNDEDRECT, width, height, radius]`
  - `[ROUNDEDRECT, width, height, radius, segments]`
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
