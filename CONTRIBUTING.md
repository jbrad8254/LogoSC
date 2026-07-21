# Contributing to LogoSC

> **The repository is the authoritative source for the project.**
>
> **Documentation and implementation should evolve together.**

## Project Philosophy

LogoSC emphasizes:

- Simplicity over cleverness.
- Readability over brevity.
- Stable public APIs.
- Thorough documentation.
- Backward compatibility whenever practical.
- Small, incremental improvements.

## Repository Structure

```text
README.md
CHANGELOG.md
LICENSE
CONTRIBUTING.md
AGENTS.md
.gitattributes
.gitignore

docs/
    ai-engineering-kit/
        AI-Engineering-Kit-Handoff.md
        Codex-Git-Project-Quick-Start.md
        Generic-Project-Bootstrap.md
        ChatGPT-Project-Workflow.md
        Engineering-Preferences.md
        Project-Retrospective.md

LogoSC-Foundation-Core.scad
LogoSC-Foundation-Validation.scad
LogoSC-Foundation-Tests.scad
LogoSC-Foundation-Validation-Tests.scad
LogoSC-Foundation-Test-Runner.scad
LogoSC-Examples.scad
LogoSC-Experiments.scad
LogoSC-OpenSCAD-Command-Line.md

LogoSC-README.md
LogoSC-User-Manual.md
LogoSC-CheatSheet.md
LogoSC-Developer-Notebook.md
LogoSC-Future-Ideas.md

LogoSC-ARC-Implementation.md
LogoSC-Holes-Implementation.md
LogoSC-LSystems-Notes.md

images/
```

## AI Engineering Kit

The six AI Engineering Kit files are stored under `docs/ai-engineering-kit/` by explicit
user request. They remain maintainer-facing companion material rather than LogoSC public
API, implementation, or ordinary user documentation.

Read `docs/ai-engineering-kit/AI-Engineering-Kit-Handoff.md` first. It explains the
remaining kit order, including the short `Codex-Git-Project-Quick-Start.md`, and the
precedence rule: explicit user instructions and current LogoSC repository guidance override
generic preferences. Do not treat the kit as a substitute for this contributor guide or the
Developer Notebook.

## Public API Stability

The following APIs should remain stable whenever practical:

- `RenderLogo2D()`
- `RenderContours2D()`
- `RenderRegion2D()`
- `RenderLogoDebug()`
- `evalLogo()`
- `evalLogoPaths()`
- `ValidateLogoPaths()`
- `ReportLogoValidation()`
- `ResultState()`
- `ResultContours()`
- `ResultStack()`
- `ResultPen()`
- `MakeRegion()`
- `RegionOuter()`
- `RegionHoles()`
- Path-result, path-record, validation-result, and validation-issue accessors
- Existing command opcodes

Prefer extending existing functionality rather than changing established behavior.

## Coding Guidelines

- Prefer readability over compactness.
- Keep changes focused.
- Avoid unnecessary refactoring.
- Preserve existing behavior unless intentionally changing it.

## Documentation

Whenever user-visible behavior changes, update as appropriate:

- `README.md`
- `LogoSC-User-Manual.md`
- `LogoSC-CheatSheet.md`
- `LogoSC-Examples.scad`
- `CHANGELOG.md`

Screenshots should be stored in `images/` using relative Markdown links.

## Examples

Examples should favor clarity over cleverness.

Prefer:

- `MOVE` over `GOTO` when appropriate.
- `TURN` over `DIR` unless `DIR` better illustrates a concept.

## Testing

Before release:

- Update regression tests as needed.
- Run `LogoSC-Foundation-Test-Runner.scad`; do not add test dependencies to Core.
- Keep validation tests in the passive validation-test companion and run them through the runner.
- Require one final `LOGOSC_AUTOMATED_TEST_RESULT` with `PASS`; expected Core `[ERROR]`
  diagnostics in the bounded failure-condition row are not test-result failures.
- Add new automated checks as immutable result records so failures accumulate through the run
  and contribute to their suite and global totals.
- Keep `LogoTestFailFast = false` for acceptance runs. Use the optional `true` setting only to
  isolate the first failed result with OpenSCAD's assertion source trace.
- Verify examples still render correctly.
- Keep documentation synchronized with implementation.

See `LogoSC-OpenSCAD-Command-Line.md` for the tested PowerShell workflow used to run the
suite, capture diagnostics, export geometry, and generate PNG previews.

## Debug Rendering

`RenderLogoDebug()` is a stable public diagnostic API and a visualization aid only.

It must never modify generated geometry or be presented as a manufacturable stroke API.

## Versioning

Before a release, review and update as appropriate:

- `LogoSCVersionMajor`
- `LogoSCVersionMinor`
- `CHANGELOG.md`

`LogoSCVersion` is derived from the major and minor symbols; verify the resulting
value rather than editing it independently.

## Packaging

When an agent or tool edits the user's active Git working tree directly, no transfer ZIP is
required unless the user requests one. Verify the repository root, `git status`, and `git diff`,
then leave the changes in that working tree for normal review and commit.

When Git is unavailable or the work occurs in a temporary, sandbox-only, or attachment-based
copy that the user cannot inspect directly, deliver one ZIP containing every modified file
under its exact repository-relative path so it can be extracted over the repository.

## Developer Notebook

Record significant design decisions, rationale, and historical context in
`LogoSC-Developer-Notebook.md`. Record longer-term feature concepts in
`LogoSC-Future-Ideas.md` rather than expanding this file into another roadmap.

## Roadmap

Current areas of interest include:

- Stroke rendering
- Additional contour-validation checks
- SVG export
- Additional primitives
- Expanded examples
- Performance improvements

## Guiding Principles

When in doubt, choose the solution that is:

1. Backward compatible.
2. Simple.
3. Easy to document.
4. Easy to test.
5. Easy to maintain.
