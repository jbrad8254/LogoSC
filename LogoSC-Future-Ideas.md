# LogoSC Future Ideas

## Table of Contents

- [Purpose](#purpose)
- [Active Sequence](#active-sequence)
- [Deferred High-Value Ideas](#deferred-high-value-ideas)
- [Deferred Medium-Term Ideas](#deferred-medium-term-ideas)
- [Deferred Lower-Priority Ideas](#deferred-lower-priority-ideas)
- [Design Philosophy](#design-philosophy)
- [Historical 2026.3 Feature Milestone](#historical-20263-feature-milestone)

## Purpose

This document captures the selected active sequence plus feature ideas and longer-term directions.
Only the Active Sequence is a current commitment; all later sections are deferred candidates.

---

## Active Sequence

The authoritative near-term order is now:

1. complete: implement the optional L-system companion source, examples, tests, and general docs;
2. finish the agreed knot-companion scope, explicitly deferring anything that is not required for
   completion; and
3. prepare the next synchronized release.

The active details remain in `LogoSC-Developer-Notebook.md` and `LogoSC-Knots-Design.md`. Ideas
elsewhere in this file do not preempt that sequence.

### L-System Companion Library

Keep L-systems outside the core library in an optional `LogoSC-LSystems.scad` companion. Include
Koch, Hilbert, Dragon, Sierpiński, and plant examples. Define a reusable expansion and
interpretation boundary, deterministic tests, a compact gallery, and documentation rather than
leaving L-system logic embedded only in individual examples.

Status: the companion development files are implemented and independently tested. Distribution
packaging remains deferred until explicitly authorized.

---

## Deferred High-Value Ideas

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
- Inter-contour segment relationship classification
- Point-in-contour and point-in-region containment
- General region boundary and filled-region relationship queries
- Hole containment and overlap checks
- Contour, explicit-path, and filled-region convexity queries

Remaining ideas:

- Additional topology policies built on the general relationship helpers when clear use cases
  justify them

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

### Tiered Release Packaging

Status: accepted publication policy is now recorded in `LogoSC-Release-Manual.md`. The earlier
design below remains as the proposal that led to the Mini, Core, Developer, Knots & Celtic, and
Nuts & Bolts suite model.

The implemented Mini suite fulfills the beginner-facing Starter direction. Do not create a
second Starter dialect or independently evolving interpreter; refine Mini through the shared
canonical Core implementation.

Publish curated LogoSC editions for different audiences without creating independently evolving
language forks. A command list written against a smaller edition must run unchanged in every
larger edition.

Proposed editions:

| Edition | Audience | Included surface |
|---|---|---|
| LogoSC Starter | First-time and Thingiverse users | Drawing, motifs, primitives, holes, and rendering |
| LogoSC Maker | Regular model authors | Complete Core, regions, transforms, accessors, and debugging |
| LogoSC Engineering | Library and production users | Maker plus validation, tests, and CLI verification |
| Extension packs | Specialized users | Knots, fasteners, L-systems, and domain companions |

#### LogoSC Starter

The Starter package should let a new user make something useful within a few minutes. Its
documented language subset should emphasize:

- `MOVE`, `TURN`, and `ARC`;
- `REPEAT` and `RUN`;
- `CIRCLE`, `REGPOLY`, `RECT`, and `ROUNDEDRECT`;
- basic `HOLE` use;
- `RenderLogo2D()`; and
- one native `linear_extrude()` example.

Initially omit advanced positioning, affine transforms, stack and pen control, evaluator result
records, debug internals, validation, and companion libraries from the teaching surface. The
package should be small: one library entry point, one Customizer-friendly demonstration, several
short examples, a one-page command card, and a link to the complete project.

#### Compatibility and maintenance rules

- Preserve identical opcode values, command syntax, coordinate conventions, scaling behavior,
  and `RenderLogo2D()` results across every edition.
- Treat Starter as a tested subset of LogoSC, not a simplified dialect.
- Prefer curated packages around the canonical implementation before maintaining a second
  interpreter.
- If a physically smaller `LogoSC-Mini.scad` is later justified, generate it from shared source
  or run differential conformance tests against Core for every supported command.
- Keep domain libraries as optional extension packs rather than growing the core editions.

The central compatibility relationship is:

```text
Starter programs ⊂ Maker programs ⊂ Engineering programs
```

The practical dividing line is that Starter teaches the language, Maker creates complete
geometry, Engineering analyzes and verifies it, and extensions solve specialized problems.

---

## Deferred Medium-Term Ideas

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

### Transform Commands — Resolved

The canonical Logo state now provides the useful transform surface through `PUSH`/`POP`,
`MOVE`/`GOTO`, `TURN`/`DIR`, `SCALE`, and `SHEAR`. A second matrix stack plus `TRANSLATE` and
`ROTATE` aliases would duplicate existing Logo-style behavior, so this is no longer an active
feature candidate.

Advanced callers can convert canonical states with `LogoStateToAffine()` and
`LogoAffineToState()` without adding a general matrix command to the language.

---

### Generative Knot Companion

Status: active design work is recorded in `LogoSC-Knots-Design.md`.

Keep knot topology, parametric generators, Celtic tile tracing, ribbon expansion, bas-relief,
and rounded-cord construction outside Core. Reuse Core regions and transforms where appropriate,
with native OpenSCAD responsible for 3D hull, Minkowski, boolean, and extrusion operations.

---

## Deferred Lower-Priority Ideas

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

## Historical 2026.3 Feature Milestone

Release `2026.3` combines:

1. The customizable printable-fastener application and its detailed algorithm documentation.
2. Duplicate-point and configurable tiny-edge validation.
3. Proper self-intersection detection with a documented quadratic-cost boundary.

Manufacturable stroke rendering and SVG export remain candidates for later milestones. This
keeps `2026.3` centered on a coherent, verified feature set without implying that every earlier
theme candidate had to ship together.
