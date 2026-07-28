# LogoSC Validation Implementation and Test Notes

## Purpose and status

This document describes the optional validation companion's architecture, geometric
algorithms, policy decisions, complexity boundaries, and automated test matrix.

The implementation lives in:

- `LogoSC-Foundation-Validation.scad`
- `LogoSC-Foundation-Validation-Tests.scad`

The Validation companion is optional. Include `LogoSC-Foundation-Core.scad` first. Core
evaluation and rendering do not depend on Validation and do not automatically reject geometry
that the optional validator reports.

The User Manual is the public API reference. This document provides the deeper implementation
and test rationale needed by maintainers.

## Validation layers

Validation is intentionally divided into four layers:

1. Explicit path extraction preserves what LogoSC actually drew.
2. Per-path integrity checks report defects within one path.
3. General geometric relationship functions classify segments, contours, points, and regions.
4. Hole-topology policy converts selected inter-path relationships into validation issues.

This separation matters. For example, two independent outer regions may intentionally overlap,
while the same relationship between two holes is invalid. The geometric classifier reports the
relationship; the caller supplies the policy.

## Explicit path extraction

### Why a separate evaluator exists

Filled-region results are insufficient for diagnostics because they do not preserve every
drawing event. `evalLogoPaths()` uses the debug evaluator's command-event segments to retain:

- the starting point of a turtle path;
- `PENUP` and `PENDOWN` boundaries;
- primitive paths as separate records;
- source opcodes;
- explicit closure information;
- outer-versus-hole roles;
- state, stack, and pen results equivalent to Core evaluation.

The public path record remains:

```text
[role, kind, points, sourceOpcode, explicitlyClosed]
```

Callers should use accessors rather than numeric indexes.

### Continuity and path splitting

Consecutive pen-down segments append to one path only when:

- their roles match;
- their turtle/primitive kinds match; and
- the previous endpoint and next start point agree within the much smaller internal continuity
  tolerance.

`PENUP`, `PENDOWN`, a discontinuous `POP`, a change between turtle and primitive geometry, or a
true coordinate discontinuity finalizes the active path.

Primitives finalize when their emitted segment sequence returns to the starting point. Turtle
paths retain the endpoint sequence actually drawn; the validator does not invent OpenSCAD's
implicit polygon-closing edge.

### Hole ordering without splitting an outer path

A hole must appear after its owning outer path in the explicit path list, but a `HOLE` command
may occur while a turtle outer contour is still being constructed.

The internal builder therefore holds completed child hole paths in a pending-hole list. When
the active outer path eventually finalizes, the builder emits:

```text
outer path
pending hole path 0
pending hole path 1
...
```

This preserves most-recent-outer ownership without prematurely splitting a turtle contour.
When a primitive outer is already finalized, its holes can be appended immediately.

## Per-path integrity algorithms

### Closure and usable vertices

A path is closed when either:

- its record says that it was explicitly closed; or
- its first and last points are within the public validation tolerance.

A repeated closing point is not counted as a second usable vertex.

An open turtle path remains open even though OpenSCAD `polygon()` would later add an implicit
closing edge. This difference is deliberate: validation describes the command path, not an
edge silently supplied by the renderer.

### Zero-length and tiny edges

Every stored consecutive point pair is an edge.

- A zero-length edge has endpoints within `tolerance`.
- A tiny edge is not zero-length but has Euclidean length no greater than
  `tinyEdgeThreshold`.

Setting `tinyEdgeThreshold = 0` disables the tiny-edge check. The implementation also skips
the check when the threshold is no greater than the general tolerance, because no edge can
satisfy both classifications.

### Duplicate nonconsecutive points

The duplicate-point scan compares point pairs that are separated by at least one intervening
point. It ignores the legitimate first/last pair of a closed path. Matching index pairs are
available from `LogoPathDuplicatePointPairs()`.

For `P` stored points, this direct scan is worst-case `O(P^2)`.

### Proper self-intersections

`LogoPathSelfIntersectionPairs()` compares unique nonadjacent segment pairs from one explicit
path. It excludes:

- ordinary adjacent joins;
- the first/last join of a closed path;
- endpoint touches;
- tolerance-level near touches;
- collinear overlap;
- intersections with other paths; and
- a hypothetical implicit closing edge.

The scan first rejects disjoint axis-aligned bounding boxes. Remaining candidates use
tolerance-aware orientation signs. A proper crossing requires the endpoints of each segment to
lie strictly on opposite sides of the other segment.

For `S` segments, the worst-case time is `O(S^2)` and reported-pair storage is `O(K)` for `K`
crossings. Set `checkSelfIntersections = false` for trusted, highly tessellated paths when that
cost is unwanted.

## General segment relationships

`LogoSegmentRelation(a, b, c, d, tolerance)` classifies two finite segments as:

- `LOGO_SEGMENT_RELATION_NONE`
- `LOGO_SEGMENT_RELATION_PROPER_CROSSING`
- `LOGO_SEGMENT_RELATION_TOUCH`
- `LOGO_SEGMENT_RELATION_COLLINEAR_OVERLAP`

The algorithm is:

1. Reject disjoint axis-aligned bounding boxes.
2. Compute four orientation signs with `LogoValidationSegmentSide()`.
3. Report a proper crossing when both pairs of signs are strictly opposite.
4. When all signs are zero, project the segments onto their dominant axis.
5. Report collinear overlap when the projected overlap is longer than `tolerance`.
6. Otherwise use tolerance-aware point-on-segment checks to report contact.
7. Report no relationship when none of the preceding conditions applies.

### Tolerance-scaled orientation

The raw two-dimensional cross product has squared-distance units. The side test compares:

```text
abs(crossValue) <= tolerance * segmentLength
```

Scaling by segment length makes the public tolerance behave like perpendicular distance in
model units rather than like a raw cross-product magnitude.

### Why project on the dominant axis

Collinear segments may be vertical or nearly vertical. Projecting on whichever segment axis has
the larger absolute change avoids choosing an unstable coordinate and reduces a two-dimensional
overlap question to an interval-overlap length.

`TOUCH` intentionally groups shared endpoints, endpoint-to-interior contact, and
tolerance-level contact. The current hole policy rejects all of them, so finer public
subclassification is not yet necessary.

## Contour intersections

`LogoContourIntersectionPairs()` compares every segment of one closed contour with every
segment of another. Each result contains:

```text
[firstSegmentIndex, secondSegmentIndex, segmentRelation]
```

Contour helpers accept both common representations:

- an implicit closing edge from the last point back to the first; or
- an explicitly repeated first point at the end.

For contours with `S` and `T` segments, worst-case time is `O(S * T)`. Bounding-box rejection
inside the segment classifier reduces typical work without changing the worst-case bound.

This contour behavior differs intentionally from self-intersection validation: general contour
relations describe closed polygon boundaries, while self-intersection describes only the
explicit path actually drawn.

## Point containment

### Boundary first

`LogoPointContourRelation()` returns outside, boundary, or inside. It first tests every contour
segment with the tolerance-aware point-on-segment predicate. Performing this step before ray
crossing makes boundary classification explicit and avoids depending on ambiguous vertex or
horizontal-edge behavior.

### Odd-even ray crossing

For a point not on the boundary, the function casts a conceptual horizontal ray toward
positive X. An edge contributes one crossing when its endpoints straddle the point's Y
coordinate and the computed crossing lies to the right of the point. An odd crossing count
means inside; an even count means outside.

The strict Y-straddle test counts a polygon vertex once rather than once for each incident
edge. Horizontal edges do not divide by zero because they do not straddle the query Y.

For `S` contour segments, point classification is `O(S)`.

### Regions with holes

`LogoPointRegionRelation()` applies the contour classifier in this order:

1. Outside the outer contour means outside the region.
2. On the outer contour means boundary.
3. On any hole contour means boundary.
4. Inside any hole means outside the filled region.
5. Otherwise the point is inside the filled region.

This implements LogoSC's region structure:

```text
[outerContour, holeContour0, holeContour1, ...]
```

## Region relationships

`LogoRegionBoundaryIntersections()` compares every contour of the first region with every
contour of the second and retains both contour indexes plus the detailed segment relationship.

`LogoRegionRelation()` then reports:

- disjoint;
- touching;
- positive-area overlap through proper boundary crossing;
- first region contains second; or
- second region contains first.

When no boundary event exists, the current implementation classifies containment using one
outer-boundary vertex from each region and `LogoPointRegionRelation()`. This works because a
nonintersecting closed contour cannot move from inside to outside another valid closed boundary.

Collinear boundary overlap without a proper crossing is currently classified as touching.
There is no separate equality result. Callers that need exact equality or a complete
constructive-solid-geometry relation should inspect detailed boundary events rather than infer
it from the compact region enum.

`LogoRegionsIntersect()` is a Boolean convenience query: every relationship except disjoint
counts as intersection, including contact without positive area.

Region relationship queries are report-only. `ValidateLogoPaths()` does not reject overlap
between independent outer regions because such regions may intentionally union when rendered.

## Convexity queries

Convexity is useful for decomposition, extrusion strategy, optimization, collision reasoning,
and algorithms that require a convex input. Concavity itself is valid LogoSC geometry, so
convexity is exposed as a query rather than as a validation issue.

The public APIs are:

```scad
LogoContourIsConvex(points, tolerance = 0.001, strict = false);
LogoPathIsConvex(path, tolerance = 0.001, strict = false);
LogoRegionIsConvex(region, tolerance = 0.001, strict = false);
LogoRegionsAreIndividuallyConvex(regions, tolerance = 0.001, strict = false);
```

The LogoSC prefix and input-specific names avoid confusion with OpenSCAD's unrelated
`convexity` preview parameter.

### Contour algorithm

`LogoContourIsConvex()` proceeds in two phases.

First, it establishes that the boundary is simple enough for convexity to be meaningful:

1. Require at least three usable vertices.
2. Reject zero-length edges.
3. Reject collinear backtracking, where consecutive edges retrace rather than continue.
4. Compare every pair of nonadjacent segments and reject any crossing, touch, or collinear
   overlap.

Second, it computes the tolerance-aware turn sign at every vertex:

```text
previous -> current -> next
```

A simple contour is convex when:

- at least one turn is nonzero;
- all nonzero turns have the same sign; and
- in strict mode, no turn is zero.

Clockwise and counterclockwise winding are both accepted. In ordinary non-strict mode,
forward collinear boundary points are allowed because they do not create an inward corner.
`strict = true` requires every vertex to form a nonzero turn.

The simplicity scan is worst-case `O(S^2)` for `S` contour segments. Once simplicity is known,
turn-sign evaluation is `O(S)`. The implementation favors a correct answer for self-intersecting
and retraced inputs over a faster local-turn-only test that could misclassify them.

### Path and region semantics

`LogoPathIsConvex()` requires the explicit path to be closed with at least three usable
vertices, then applies the contour algorithm.

`LogoRegionIsConvex()` requires exactly one contour and tests that outer contour. Any region
containing a hole is nonconvex as a filled set: two material points can have a connecting line
segment that passes through the empty hole.

`LogoRegionsAreIndividuallyConvex()` applies the region query to every region and returns true
for an empty list. Its name is deliberately explicit: it does not compute the convexity of the
geometric union. Two disjoint squares are individually convex even though their combined filled
set is disconnected and therefore not convex. Likewise, overlapping convex polygons can have a
concave union. A future union-convexity query would first need a reliable merged-boundary or
constructive-geometry representation.

These functions return Booleans and do not add issues to `ValidateLogoPaths()`.

## Hole topology policy

### Ownership

Every hole belongs to the nearest preceding outer path. The pending-hole builder ordering makes
that rule deterministic for both primitive and turtle-drawn outers.

### Outer containment

For each hole:

1. Compare its boundary against its owning outer boundary.
2. Any proper crossing, touch, or collinear overlap reports
   `LOGO_VALIDATION_HOLE_INTERSECTION`.
3. If boundaries are disjoint, classify a hole point against the outer contour.
4. Anything other than strictly inside reports `LOGO_VALIDATION_HOLE_OUTSIDE_OUTER`.

This rejects holes that cross, touch, share an edge with, coincide with, lie outside, or contain
their outer boundary.

### Sibling holes

Every pair of holes with the same owner is compared.

- Any boundary relationship means overlap under the strict hole policy.
- With disjoint boundaries, a point from either hole inside the other detects nesting.

The validator therefore rejects crossing, touching, coincident, and nested holes. LogoSC's
region data has no alternating hole/island hierarchy, so nested hole paths are not interpreted
as islands.

Two-path issues append a related-path index:

```text
[pathIndex, issueCode, relatedPathIndex]
```

Older one-path issues retain their exact two-field shape:

```text
[pathIndex, issueCode]
```

Set `checkHoleTopology = false` to disable these inter-path checks while retaining basic
per-path validation.

## Automated test matrix

`LogoValidationAutomatedTestResults()` currently contains 71 immutable Validation results.
Together with the Foundation suite, the complete acceptance run contains 201 results.

### Explicit-path extraction and evaluator parity — 15 results

| Coverage | What the results prove |
|---|---|
| Closed triangle | One path is produced, it is valid, and its starting point is preserved. |
| Open triangle | The path is invalid and reports exactly the open-path issue. |
| `PENUP`/`PENDOWN` | Pen boundaries create two independent valid paths. |
| Consecutive primitives | Primitive contours remain separate and retain closure, kind, and source opcode. |
| Outer plus hole | Two paths are produced and their outer/hole roles are retained. |
| `RUN` and `REPEAT` | Nested evaluation preserves one correctly closed explicit path. |
| Full `ARC` | Tessellation returns to the start with the expected point count. |
| `POP` discontinuity | Restoring position splits the path and exposes the resulting integrity issues. |

### Basic path defects and tolerance — 10 results

| Coverage | What the results prove |
|---|---|
| Zero-length `MOVE` | Both too-few-points and zero-length-edge issues are retained. |
| Repeated closure point | The normal first/last closure pair is not reported as a duplicate. |
| Duplicate nonconsecutive point | The issue and exact matching point-index pair are reported. |
| Tiny edge | Detection, stored threshold, and the zero-threshold opt-out work. |
| Closure tolerance | A near endpoint is accepted at one tolerance and rejected at a stricter tolerance. |

### Proper self-intersection — 9 results

| Coverage | What the results prove |
|---|---|
| Bow-tie contour | A proper crossing issue and exact segment pair are reported. |
| Default/disabled behavior | The check defaults on and can be disabled. |
| Ordinary closed contour | Adjacent joins do not become crossings. |
| Nonadjacent endpoint contact | Contact is not conflated with proper crossing. |
| Near contact | Tolerance-level contact is not a proper crossing. |
| Collinear overlap | Collinearity is not a proper crossing. |
| Implicit closing edge | The self-intersection scan does not invent an undrawn edge. |

### General segment and contour predicates — 5 results

| Coverage | What the results prove |
|---|---|
| Proper crossing | Opposite orientation signs select the crossing classification. |
| Endpoint contact | Shared-endpoint geometry selects touch. |
| Collinear overlap | Dominant-axis projection selects overlap rather than touch. |
| Separated parallel segments | Bounding-box/side logic reports no relationship. |
| Crossing contours | Inter-contour results retain the correct segment indexes and relation. |

### Point and region relationships — 6 results

| Coverage | What the results prove |
|---|---|
| Point versus contour | Inside, boundary, and outside are distinct. |
| Point versus region | A point inside a hole is outside filled material. |
| Overlapping regions | Proper boundary crossings report positive-area overlap. |
| Touching regions | Shared boundary without a proper crossing reports touch. |
| Region containment | Boundary-disjoint nesting reports the correct containing side. |
| Region inside a hole | Filled-region semantics report disjoint and the Boolean query agrees. |

### Convexity queries — 12 results

| Coverage | What the results prove |
|---|---|
| Both winding directions | Clockwise and counterclockwise convex contours are accepted. |
| Concave contour | Mixed nonzero turn signs reject an inward corner. |
| Collinear vertex | Non-strict mode accepts forward collinearity and strict mode rejects it. |
| Self-intersection | A bow-tie is rejected before local turn signs can misclassify it. |
| Collinear backtracking | A retraced adjacent edge is not treated as harmless collinearity. |
| Too few points | A segment cannot be a convex polygon. |
| Path query | A convex closed path passes while an open path fails. |
| Single-contour region | A convex outer-only filled region passes. |
| Region with a hole | A hole makes the filled region nonconvex. |
| Multiple convex regions | Every member can be reported individually convex without claiming their union is convex. |
| Mixed convex/concave regions | One concave member makes the all-members query false. |
| Multiple regions with a hole | A hole-containing member makes the all-members query false. |

### Hole ownership and topology — 12 results

| Coverage | What the results prove |
|---|---|
| Owner ordering | A valid hole follows and identifies its owning outer path. |
| Active turtle outer | A `HOLE` command does not split a turtle outer that continues afterward. |
| Hole outside outer | Strict containment fails with the owning path in the diagnostic. |
| Hole crossing outer | Proper boundary crossing is invalid. |
| Hole touching outer | Zero-area boundary contact is invalid. |
| Crossing/overlapping holes | The issue identifies the related sibling path. |
| Nested holes | Containment without boundary crossing is still invalid. |
| Touching holes | Sibling boundary contact is invalid. |
| Coincident holes | Complete boundary coincidence is invalid. |
| Separate contained holes | Ordinary multiple holes remain valid. |
| Default/disabled behavior | Hole topology defaults on and can be disabled independently. |

### Empty input and Core parity — 2 results

| Coverage | What the results prove |
|---|---|
| Empty command list | No paths and no issues is a valid result. |
| Evaluator parity | Path evaluation preserves Core state, stack, and pen results. |

## Why these tests are immutable records

Each check returns:

```text
[name, passed, detail]
```

The suite evaluates every record, reports all failures, and contributes its totals to the final
`LOGOSC_AUTOMATED_TEST_RESULT`. This is preferable to immediate assertions for acceptance runs
because one defect cannot hide later failures. Optional fail-fast mode remains available to
obtain OpenSCAD's assertion trace for the first failed record.

Several nearby cases intentionally use separate fixtures. A proper crossing, endpoint touch,
near touch, and collinear overlap can look similar in a rendered preview but exercise different
branches and policies. Likewise, an overlapping hole and a nested hole require different
algorithms: boundary comparison detects the first, while containment detects the second.

## Verification

Run `LogoSC-Foundation-Test-Runner.scad` according to
`LogoSC-OpenSCAD-Command-Line.md`. Acceptance requires exactly one final:

```text
"LOGOSC_AUTOMATED_TEST_RESULT", "PASS"
```

Keep `LogoTestFailFast = false` for the complete run. The current verified total is:

```text
suites 2, tests 201, passed 201, failed 0
```

## Known limits

- Direct pair scans are quadratic in the number of compared segments.
- Convexity queries include a quadratic simplicity check rather than assuming valid input.
- Tolerance is axis-aligned for point-nearness checks and perpendicular-distance-like for
  orientation checks; callers should choose it in model units.
- Region relations do not currently return an equality classification.
- Multiple-region convexity checks members independently and do not analyze the geometric union.
- General region relations assume ordinary valid closed contours; validate malformed paths
  first.
- Validation diagnoses but does not repair geometry.
- Winding orientation is not currently validated or normalized.
- Core rendering remains permissive unless callers explicitly invoke Validation.
