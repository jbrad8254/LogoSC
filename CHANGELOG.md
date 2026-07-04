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

### Known limitations

- No `CIRCLE` helper yet.
- No `REGPOLY` helper yet.
- ARC emits polygon contour points; open-stroke rendering is still deferred.

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
- `RenderContours()` renderer.
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
- No holes yet.
- `polygon()` automatically closes each contour.
- Geometry commands such as `CIRCLE` and `REGPOLY` are deferred to later `LogoT-Geometry` work.
