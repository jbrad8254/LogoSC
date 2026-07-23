# LogoSC Future Ideas

## Purpose

This document captures feature ideas and longer-term directions that are intentionally
separate from the active roadmap. Items are not prioritized commitments.

---

## High Priority

### Stroke Rendering

Add a rendering path for line art without changing the existing filled-region API.

Possible API:

```scad
RenderLogoStroke(region,
    width = 1,
    cap = "round",
    join = "round");
```

Benefits:

- Laser cutters
- CNC toolpaths
- SVG workflows
- PCB traces
- Decorative line art

---

### Contour Validation

Status: initial optional path validation is implemented.

`LogoSC-Foundation-Validation.scad` remains an optional companion rather than a dependency
of the standalone Core file. Its focused tests live in
`LogoSC-Foundation-Validation-Tests.scad` and are assembled by the test runner.

Implemented:

- Open contour detection
- Zero-length segments
- Too-few-points detection
- Configurable closure tolerance
- Duplicate nonconsecutive points
- Configurable tiny nonzero edges

Remaining ideas:

- Optional self-intersection detection
- Hole containment and overlap checks

---

### Image-Comparison Regression Testing

Render stable examples and galleries to PNG files and compare them with approved reference
images. Use deterministic camera and rendering settings plus a configurable comparison
tolerance to avoid false failures from minor platform or anti-aliasing differences.

This would catch visual regressions automatically and reduce the live user interaction needed
to verify that the code remains working. Manual review would still be required when an intended
visual change updates a reference image.

---

### SVG Export

Export LogoSC geometry to SVG for downstream editing.

Potential API:

```scad
LogoToSVG(region);
```

---

## Medium Priority

### Additional Drawing Primitives

Candidate primitives:

- Ellipse
- Elliptical Arc
- Star
- Star Polygon
- Gear Outline
- Spiral
- Text-on-path helpers

---

### Transformation Stack

Investigate introducing transform stack operations rather than transformed variants of
individual drawing commands.

Possible operations:

- PUSHMATRIX
- POPMATRIX
- TRANSLATE
- ROTATE
- SCALE

---

### L-System Companion Library

Keep L-systems outside the core library.

Suggested module:

```
LogoSC-LSystems.scad
```

Include Koch, Hilbert, Dragon, Sierpiński, and plant examples.

---

## Lower Priority

### Performance

Only optimize after feature stabilization.

Ideas:

- Reduce temporary allocations
- Cache generated geometry
- Minimize recursion overhead

---

### Example Gallery

Expand the example collection into a showcase and regression suite.

Possible additions:

- Fractals
- Celtic knots
- Decorative borders
- Gears
- Flowers
- Mazes
- PCB traces
- Logos
- Architectural plans

---

## Design Philosophy

Prefer:

- Stable public APIs
- Orthogonal features
- Companion modules over core complexity
- Backward compatibility

Avoid:

- Large numbers of narrowly useful turtle commands
- Breaking existing drawing semantics
- Premature optimization

---

## Suggested 2026.3 Theme

1. Stroke rendering
2. Expanded contour validation
3. SVG export

These complement one another and represent a substantial functional expansion while
preserving the existing LogoSC architecture.
