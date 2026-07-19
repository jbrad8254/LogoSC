# Contributing to LogoSC

> **The repository is the authoritative source for the project. Documentation and implementation should evolve together.**

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

LogoSC-Foundation-Core.scad
LogoSC-Examples.scad
LogoSC-Tests.scad

LogoSC-User-Manual.md
LogoSC-CheatSheet.md
LogoSC-Developer-Notebook.md

images/
```

## Public API Stability

The following APIs should remain stable whenever practical:

- RenderLogo2D()
- evalLogo()
- ResultContours()
- MakeRegion()
- Turtle command opcodes

Prefer extending existing functionality rather than changing established behavior.

## Coding Guidelines

- Prefer readability over compactness.
- Keep changes focused.
- Avoid unnecessary refactoring.
- Preserve existing behavior unless intentionally changing it.

## Documentation

Whenever user-visible behavior changes, update as appropriate:

- README
- User Manual
- Cheat Sheet
- Examples
- CHANGELOG

Screenshots should be stored in `images/` using relative Markdown links.

## Examples

Examples should favor clarity over cleverness.

Prefer:

- MOVE over GOTO when appropriate.
- TURN over DIR unless DIR better illustrates a concept.

## Testing

Before release:

- Update regression tests as needed.
- Verify examples still render correctly.
- Keep documentation synchronized with implementation.

## Debug Rendering

RenderLogoDebug() is a visualization aid only.

It must never modify generated geometry.

## Versioning

Update:

- LogoSCVersionMajor
- LogoSCVersionMinor
- LogoSCVersion

and CHANGELOG.md before each release.

## Packaging

Deliver one ZIP containing every modified file using the repository's exact directory structure so it can be extracted directly over the repository.

## Developer Notebook

Record significant design decisions, rationale, future ideas, and historical context in the Developer Notebook rather than this file.

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
