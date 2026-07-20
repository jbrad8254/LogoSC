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

Provide optional validation of contours before polygon generation.

Keep this in `LogoSC-Foundation-Validation.scad` as an optional companion rather than a
dependency of the standalone Core file. Focused validation tests should live in
`LogoSC-Foundation-Validation-Tests.scad` and be assembled by the test runner.

Ideas:

- Open contour detection
- Duplicate points
- Zero-length segments
- Tiny edges
- Optional self-intersection detection

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
2. Contour validation
3. SVG export

These complement one another and represent a substantial functional expansion while
preserving the existing LogoSC architecture.
