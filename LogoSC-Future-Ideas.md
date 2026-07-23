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
- Proper self-intersections within one explicit path

Remaining ideas:

- Collinear segment overlap and intersections between separate contours
- Hole containment and overlap checks

#### Deliberate non-goal: sweep-line crossing optimization

The self-intersection validator compares each path's unique nonadjacent segment pairs. It skips
neighboring segments, rejects pairs with disjoint bounding boxes, and uses tolerance-aware
orientation tests only for the remaining candidates. It detects proper interior crossings;
endpoint touches, collinear overlaps, intersections between separate contours, and hole-boundary
relationships remain distinct checks with their own documented semantics.

For a path with `S` segments, direct pairwise testing considers at most `S * (S - 1) / 2`
pairs, so its worst-case time complexity is `O(S^2)`. Adjacency filtering and bounding-box
rejection should make ordinary LogoSC contours cheaper in practice without changing that bound.
The check needs `O(1)` working data per candidate pair and `O(K)` result storage when it reports
`K` crossing pairs. For multiple independent paths, the initial within-path cost is the sum of
the squared path sizes rather than the square of every segment in the model.

Do not initially implement a sweep-line intersection algorithm. Although a conventional
sweep-line design can approach `O((S + K) log S)` time for `K` reported intersections, it needs
an event queue, an ordered active-segment structure, neighbor updates, and careful handling of
vertical segments, coincident endpoints, collinear overlaps, and tolerance-dependent ordering.
Those structures and degeneracies are disproportionately complicated in OpenSCAD's immutable,
list-oriented language and would increase code size, allocations, recursion, testing burden,
and maintenance risk in an optional validator.

The public option allows self-intersection checking to be disabled for highly tessellated paths.
Reconsider a sweep-line or spatial-index design only if measurements on real LogoSC models show
that bounding-box-filtered pairwise testing is a material bottleneck.

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

## 2026.3 Feature Milestone

Release `2026.3` combines:

1. The customizable printable-fastener application and its detailed algorithm documentation.
2. Duplicate-point and configurable tiny-edge validation.
3. Proper self-intersection detection with a documented quadratic-cost boundary.

Manufacturable stroke rendering and SVG export remain candidates for later milestones. This
keeps `2026.3` centered on a coherent, verified feature set without implying that every earlier
theme candidate had to ship together.
