# LogoSC Changelog

## [2026.2] - 2026-07-13

This release consolidates the accumulated LogoSC development work that had
previously been recorded as multiple `Unreleased` entries. Version `2026.1` was
an internal development snapshot and was not published as a separate release.

### Added

- Final LogoSC project identity, repository naming, and `LogoSCVersion*` public
  version symbols.
- `LogoSC-Developer-Notebook.md` as the living engineering history, design
  rationale, workflow, regression-risk, and restart document.
- Preview-only `RenderLogoDebug()` rendering with z-centered movement capsules
  and point markers.
- Debug event extraction for normal movement, pen-up movement, `GOTO`, primitive
  geometry, and start/end points.
- Debug examples for open and closed triangles, crossed/self-intersecting paths,
  rectangles, and stroke-versus-primitive construction.
- Unified `LogoSCRunMode` selector with `NoDemo`, `Examples`, `Debug`, and `Tests`.
- LogoSC wordmark and gear-icon images.
- README Quick Start screenshots for normal and debug triangle rendering.
- Root MIT `LICENSE` file.
- Public API version and compatibility helper:
  - `LogoSCVersionMajor`
  - `LogoSCVersionMinor`
  - `LogoSCVersion`
  - `LogoSCVersionAtLeast()`

### Changed

- Advanced the public API version from the unreleased `2026.1` development
  snapshot to `2026.2`.
- Preserved generic public APIs, including `RenderLogo2D()`, `evalLogo()`,
  `ResultContours()`, `MakeRegion()`, and the existing command opcodes.
- Replaced separate example, debug, and test controls with `LogoSCRunMode`.
- Changed test execution so tests run only when `LogoSCRunMode` is explicitly
  set to `"Tests"`.
- Removed the active `RunLogoTests` compatibility gate from normal execution.
- Reworked the README Quick Start around a simple `MOVE`/`TURN` triangle and an
  immediate debug-overlay example.
- Updated README, User Manual, Cheat Sheet, detailed project overview, and
  developer documentation for LogoSC naming, versioning, run modes, debug
  rendering, licensing, and images.
- Tuned debug marker geometry, heights, transparency, and palette so overlapping
  start/end markers and pen-up segments remain visible.
- Renamed the debug demo `Right` option to `Rectangle` and simplified the crossed
  rectangle example to expose point-order errors directly.
- Added one `DebugDemoOverlay` control for all debug capsules, point markers, and
  related overlay objects while keeping filled-preview control separate.

### Fixed

- Corrected stale or mechanically renamed test-control references in public
  documentation.
- Corrected the Cheat Sheet setup variable after the project-name transition.
- Removed obsolete working-name references without renaming generic APIs.
- Corrected README version references to match the source version constants.
- Centered Quick Start extrusion examples and increased debug segment height so
  z-centered overlays remain visible against the filled model.
- Verified README image references use repository-relative paths and that the
  corresponding PNG files are present under `images/`.

### Documentation

- Documented `RenderLogoDebug()` as diagnostic preview geometry rather than a
  manufacturable stroke API.
- Added guidance for diagnosing crossing paths, unexpected point order, pen-up
  motion, primitive-generated edges, and contours that rely on implicit polygon
  closure.
- Added a compact README version-history table.
- Recorded optional open-contour validation and separate manufacturable stroke
  rendering as future design work.

### Known limitations

- Final geometry is filled-region output; manufacturable open-stroke rendering
  with width, caps, joins, and miter limits is not implemented.
- OpenSCAD `polygon()` implicitly closes each contour. LogoSC currently preserves
  that behavior even when the turtle endpoint differs from the starting point.
  Optional warning or strict validation remains a future design decision.

## [2026.0] - Initial public foundation

### Added

- OpenSCAD Logo-style interpreter with integer opcodes and named state, command,
  and result indices.
- Core commands: `MOVE`, `TURN`, `DIR`, `SCALE`, `GOTO`, `RUN`, `REPEAT`, `PUSH`,
  `POP`, `PENUP`, and `PENDOWN`.
- Geometry commands: `ARC`, `CIRCLE`, `REGPOLY`, `RECT`, `ROUNDEDRECT`, and `HOLE`.
- Region-based rendering with outer paths and holes.
- `RenderLogo2D()`, `RenderContours2D()`, and `RenderRegion2D()`.
- Recursive command evaluation, state stack, tracing, hard/soft error handling,
  regression tests, examples, Cheat Sheet, User Manual, and geometry design notes.

### Notes

- `CIRCLE` creates a centered closed contour. Use `[ARC, radius, 360]` for
  cursor-style full-loop motion.
- 3D composition remains the responsibility of native OpenSCAD operations such
  as `linear_extrude()` and `rotate_extrude()`.
