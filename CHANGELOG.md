# LogoT Changelog

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
- Geometry commands such as `ARC`, `CIRCLE`, and `REGPOLY` are deferred to `LogoT-Geometry`.
