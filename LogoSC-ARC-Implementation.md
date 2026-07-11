# LogoSC ARC Implementation Notes

## Purpose

`ARC` adds curved Logo movement while preserving the existing LogoSC architecture:
commands are evaluated into contour point lists, and rendering still happens later
through `polygon()` calls.

OpenSCAD does not provide a path-level operation such as "append this arc to an
existing polygon contour." LogoSC therefore tessellates arcs into short straight
segments and appends those generated points to the current contour.

## Command syntax

```scad
[ARC, radius, degrees[, segments]]
```

The optional `segments` field overrides automatic segment selection. When it is
omitted, LogoSC uses OpenSCAD-style `$fn/$fa/$fs` logic.

## Movement semantics

Given a current state:

```text
[x, y, heading, scale]
```

`ARC` behaves as follows:

- `radius` is measured before Logo scale is applied.
- The effective rendered radius is `radius * scale`.
- Positive `degrees` turns left.
- Negative `degrees` turns right.
- Final heading is `heading + degrees`.
- Final position is the final tessellated point on the arc.
- If the pen is down, tessellated points are appended to the current contour.
- If the pen is up, the state is updated but no points are emitted.

A quarter-left arc from the origin with heading `0`:

```scad
[ARC, 10, 90]
```

ends near:

```text
[10, 10, 90, 1]
```

## Arc geometry

For nonzero radius and nonzero angle, LogoSC computes the center of curvature from
the current heading and the turn direction.

```text
side = degrees >= 0 ? 1 : -1
scaledRadius = radius * scale
center = [
    x - side * scaledRadius * sin(heading),
    y + side * scaledRadius * cos(heading)
]
```

The generated point at fractional progress `t`, where `0 < t <= 1`, is:

```text
radialAngle = heading - side * 90 + degrees * t
point = [
    center.x + scaledRadius * cos(radialAngle),
    center.y + scaledRadius * sin(radialAngle)
]
```

The starting point is not duplicated. LogoSC appends only points for:

```text
i = 1..segments
```

This matches the existing `MOVE` behavior, which emits destination points rather
than explicitly emitting the starting point.

## Automatic segment selection

LogoSC follows OpenSCAD's `$fn`, `$fa`, and `$fs` resolution model as closely as is
useful for an arc command.

OpenSCAD's full-circle fragment selection can be summarized as:

```text
if $fn > 0:
    fullCircleFragments = max(3, floor($fn))
else:
    fullCircleFragments = ceil(
        max(
            min(360 / $fa, 2 * PI * radius / $fs),
            5
        )
    )
```

LogoSC applies that rule to the effective rendered radius, then scales the result
by the absolute arc angle:

```text
autoSegments = max(
    1,
    ceil(fullCircleFragments * abs(degrees) / 360)
)
```

That means the OpenSCAD-style minimum of five fragments applies to a full circle,
not to every partial arc. A small nonzero arc can use one segment.

## Explicit segment override

When the optional fourth command field is supplied, `segments` is interpreted as
the actual number of line segments along this arc, not as a full-circle fragment
count.

Examples:

```scad
[ARC, 10, 90, 4]    // four segments across the quarter arc
[ARC, 10, 180, 8]   // eight segments across the semicircle
[ARC, 10, 360, 32]  // thirty-two segments across the full circle
```

## Edge cases

| Case | Behavior |
|---|---|
| Missing radius or angle | Soft error, no-op |
| Negative radius | Soft error, no-op |
| Explicit `segments <= 0` | Soft error, no-op |
| `degrees == 0` | No-op |
| `radius == 0` | Position unchanged; heading changes by `degrees` |
| Effective scaled radius is zero | Position unchanged; heading changes by `degrees` |
| Pen up | State updates; no contour points emitted |
| Inside `REPEAT` | Normal recursive evaluation |
| Inside `RUN` | Uses the RUN-scaled state |

## Rounded rectangle example

A rounded rectangle is the canonical ARC smoke test: straight edges joined by
four quarter arcs. For a 30 x 16 rounded rectangle with radius 5, start at the
bottom edge after the lower-left corner radius:

```scad
[
    [GOTO, 5, 0, 0],
    [MOVE, 20],
    [ARC, 5, 90, 4],
    [MOVE, 6],
    [ARC, 5, 90, 4],
    [MOVE, 20],
    [ARC, 5, 90, 4],
    [MOVE, 6],
    [ARC, 5, 90, 4]
]
```

The final state should be near:

```text
[5, 0, 360, 1]
```

With four segments per corner, the emitted contour has 21 points: one initial
`GOTO` point, four `MOVE` endpoints, and sixteen arc points.

## Tests

The regression suite includes validation checks for:

- quarter arc;
- semicircle;
- full-circle-ish arc;
- pen-up arc;
- arc inside `REPEAT`;
- arc inside `RUN`;
- scaled arc;
- rounded rectangle built from four quarter arcs.

It also includes visual render tests for several polygon-friendly arc contours,
plus failure tests for malformed ARC commands.

## Related closed-shape commands

`CIRCLE`, `REGPOLY`, `RECT`, and `ROUNDEDRECT` are closed-contour commands added
after ARC. They are intentionally CAD/3D-printing-style shape stamps:

- the shape is centered on the current Logo position;
- the shape creates a separate closed contour when the pen is down;
- the Logo state is not moved;
- the heading is not changed;
- current scale is applied;
- heading orients `REGPOLY`, `RECT`, and `ROUNDEDRECT`.

This is different from classic Logo circle behavior. In LogoSC,
`[CIRCLE, r]` creates a filled circle centered at the current point. To make the
Logo cursor walk around a full tangent loop, use:

```scad
[ARC, r, 360]
```

Open-stroke rendering remains a separate future rendering problem. It should not
be approximated as unrelated tiny rectangles for production use. A better later
design is to convert centerline paths into one or more closed outline polygons
using explicit stroke width, cap style, join style, and miter-limit rules.
