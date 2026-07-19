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
.gitattributes
.gitignore

docs/
    ai-engineering-kit/
        AI-Engineering-Kit-Handoff.md
        Generic-Project-Bootstrap.md
        ChatGPT-Project-Workflow.md
        Engineering-Preferences.md
        Project-Retrospective.md

LogoSC-Foundation-Core.scad
LogoSC-Foundation-Tests.scad
LogoSC-Examples.scad
LogoSC-Experiments.scad

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

The five AI Engineering Kit files are stored under `docs/ai-engineering-kit/` by explicit
user request. They remain maintainer-facing companion material rather than LogoSC public
API, implementation, or ordinary user documentation.

Read `docs/ai-engineering-kit/AI-Engineering-Kit-Handoff.md` first. It explains the
remaining kit order and the precedence rule: explicit user instructions and current LogoSC
repository guidance override generic preferences. Do not treat the kit as a substitute for
this contributor guide or the Developer Notebook.

## Public API Stability

The following APIs should remain stable whenever practical:

- `RenderLogo2D()`
- `RenderContours2D()`
- `RenderRegion2D()`
- `RenderLogoDebug()`
- `evalLogo()`
- `ResultState()`
- `ResultContours()`
- `ResultStack()`
- `ResultPen()`
- `MakeRegion()`
- `RegionOuter()`
- `RegionHoles()`
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
- Verify examples still render correctly.
- Keep documentation synchronized with implementation.

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

Deliver one ZIP containing every modified file using the repository's exact directory
structure so it can be extracted directly over the repository.

## Developer Notebook

Record significant design decisions, rationale, and historical context in
`LogoSC-Developer-Notebook.md`. Record longer-term feature concepts in
`LogoSC-Future-Ideas.md` rather than expanding this file into another roadmap.

## Roadmap

Current areas of interest include:

- Stroke rendering
- Contour validation
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
