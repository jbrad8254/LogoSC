# LogoSC Changelog

## [Unreleased]

### Added

- Added a four-column by two-row debug-renderer gallery that gives all eight debug
  examples distinct logical indexes and offsets.
- Added `DebugDemoLayout` with `Gallery` and `Selected` choices, retaining focused
  inspection through `DebugDemoExample`.
- Added `LogoSC-Foundation-Test-Runner.scad` as the direct regression-suite entry point.
- Added optional `LogoSC-Foundation-Validation.scad` path analysis without adding a Core
  dependency or changing filled-region rendering.
- Added `evalLogoPaths()`, `ValidateLogoPaths()`, `ReportLogoValidation()`, explicit path
  records, and public path/validation accessors.
- Added open-path, too-few-points, and zero-length-segment issue detection with configurable
  endpoint tolerance and warning or strict reporting.

### Changed

- Made `LogoSC-Foundation-Core.scad` a standalone one-file library with no test-file
  dependency.
- Changed `LogoSC-Foundation-Tests.scad` to provide passive test definitions invoked by
  the runner or the explicit `Tests` branch in `LogoSC-Examples.scad`.
- Changed automated checks from independent soft-error echoes to immutable named result
  records aggregated into Foundation and Validation suite results.

### Documentation and maintenance

- Added root `AGENTS.md` with compact repository-specific guidance for Codex.
- Added `docs/ai-engineering-kit/Codex-Git-Project-Quick-Start.md` as a short reusable guide
  to setting up and using a local Git repository as a Codex workspace.
- Added `CONTRIBUTING.md` and `LogoSC-Future-Ideas.md` after the `v2026.2` tag.
- Added `LogoSC-OpenSCAD-Command-Line.md` with tested PowerShell examples for regression
  diagnostics, geometry export, and PNG preview generation, plus official OpenSCAD references.
- Added the maintainer-facing AI Engineering Kit under `docs/ai-engineering-kit/` by
  explicit user request.
- Clarified that `RenderLogoDebug()` is a stable public diagnostic API while remaining
  preview-only and unsuitable for manufacturable stroke output.
- Updated the Developer Notebook's live checkpoint and roadmap to distinguish completed
  debug-renderer work from future contour-validation and stroke-rendering work.
- Corrected User Manual section numbering, recursion links, and repository inventory.
- Kept post-release documentation work separate from the contents of the `v2026.2` tag.
- Recorded that future contour validation belongs in an optional implementation companion
  with separate tests, assembled by the test runner rather than included from Core.
- Added `images/examples-gallery.png` showing basic shapes, holes, native linear and rotational
  extrusions, and recursive L-system-inspired examples.
- Added `images/regression-test-gallery.png` showing the color-coded visual regression suite,
  and referenced both galleries from the relevant public, testing, and submission docs.

### Testing

- Added a non-rendering evaluator-invariant suite covering complete `EvalResult` state,
  raw region/ring structure, stack contents, pen state, scaled `RUN`, and `REPEAT` behavior.
- Kept the suite focused on current filled-region semantics while making it straightforward
  to extend as validation grows and open-path rendering is deliberately introduced.
- Added focused path-validation tests covering closure, tolerance, pen boundaries, primitives,
  holes, `RUN`, `REPEAT`, arcs, stack discontinuities, zero-length moves, and empty programs.
- Added per-suite and global pass/fail summaries that retain all failures, distinguish expected
  Core error diagnostics, and end with `LOGOSC_AUTOMATED_TEST_RESULT`.
- Added optional `LogoTestFailFast` diagnosis that asserts at the first failed immutable result
  with its test name and details while preserving aggregate reporting as the default; the
  Examples file exposes it in the `LogoSC Run` Customizer section.
- Added a final `*** Test Suite Failed ***` banner to failed aggregate reports for immediate
  human recognition without changing the structured automated-result record.
- Restored the empty-program validation expectation to zero paths while converting the check
  to an immutable test-result record.
- Suppressed duplicate expected-error echoes during repeated functional result-list traversal;
  the visual failure row still executes and displays each intended diagnostic once.

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
- Removed the active legacy test compatibility gate from normal execution.
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
