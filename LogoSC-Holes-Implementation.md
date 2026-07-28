# LogoSC Holes and Regions Implementation

## Rationale

LogoSC originally rendered every contour as a separate OpenSCAD `polygon()` call.
That model works for disconnected filled islands, but it cannot represent a hole
inside a filled island. A circular mounting hole, for example, would render as a
separate filled disk instead of subtracting material from the plate.

For 3D-printing-oriented geometry, holes should be part of the same 2D region as
their surrounding outer boundary. OpenSCAD's `polygon()` supports this directly
with its `paths` argument: the first path is the outer boundary and later paths
inside it are interpreted as holes. LogoSC therefore represents holes with
`polygon(points=..., paths=...)`, not with boolean `difference()` at this layer.

Boolean `difference()` is still useful later, especially for higher-level 3D
modeling, but the 2D LogoSC evaluator should first produce clean region data.
That keeps the interpreter functional and makes the rendering model explicit.

## Data model

LogoSC now treats evaluated geometry as a list of regions:

```text
regions = [
    [outerContour, holeContour0, holeContour1],
    [outerContour],
    [outerContour, holeContour0]
]
```

Terminology:

```text
contour = one closed ring of 2D points
region  = one filled area: [outerContour, holeContour0, holeContour1, ...]
scene   = list of regions
```

The outer contour and all hole contours are ordinary point lists:

```text
outerContour = [[x0, y0], [x1, y1], [x2, y2], ...]
```

The old single-contour case is still represented naturally:

```text
[[outerContour]]
```

so disconnected filled shapes become multiple one-ring regions.

## Rendering

Each region is rendered with one OpenSCAD polygon call:

```scad
polygon(
    points = flatPointList,
    paths  = [outerPath, holePath0, holePath1]
);
```

For a region such as:

```text
[
    outer,  // 4 points
    hole0, // 16 points
    hole1  // 16 points
]
```

LogoSC flattens the points:

```text
points = outer + hole0 + hole1
```

and builds matching paths:

```text
paths = [
    [0, 1, 2, 3],
    [4, 5, ..., 19],
    [20, 21, ..., 35]
]
```

OpenSCAD then treats the first path as the filled boundary and the later paths as
holes when they lie inside the first path.

## `HOLE` command

The new command is:

```scad
[HOLE, cmds]
```

`HOLE` evaluates its child command list as a scoped drawing operation. Every
closed contour produced by the child list is attached as a hole to the most
recent drawable region.

The parent Logo state is not changed:

- parent position is unchanged;
- parent heading is unchanged;
- parent scale is unchanged;
- parent stack is unchanged;
- parent pen state is unchanged.

The child command list starts with pen down by default. Commands inside the child
may still use `PENUP` and `PENDOWN` if needed.

## Target-region rule

A hole attaches to the most recently emitted region whose outer contour has at
least three points.

Example:

```scad
[
    [RECT, 40, 20],
    [HOLE, [[CIRCLE, 5]]],
    [CIRCLE, 10]
]
```

Result:

```text
region 0: rectangle with one circular hole
region 1: filled circle
```

Example:

```scad
[
    [RECT, 40, 20],
    [CIRCLE, 10],
    [HOLE, [[CIRCLE, 3]]]
]
```

Result:

```text
region 0: filled rectangle
region 1: circle with one circular hole
```

This "latest region" rule makes shape construction simple and avoids a separate
hole mode with explicit begin/end state.

## Multiple holes from one command

A single `HOLE` command can attach multiple child contours:

```scad
[
    [RECT, 50, 30],
    [HOLE,
        [
            [GOTO, -15, 0, 0],
            [CIRCLE, 3],
            [GOTO,  15, 0, 0],
            [CIRCLE, 3]
        ]
    ]
]
```

The child evaluation may produce temporary non-closed movement paths. LogoSC only
attaches child rings with at least three points as holes.

## Examples

### Washer

```scad
[
    [CIRCLE, 20],
    [HOLE, [[CIRCLE, 8]]]
]
```

Creates one circular outer region with one circular inner hole.

### Rectangular mounting plate

```scad
[
    [RECT, 50, 30],

    [HOLE,
        [
            [GOTO, -15, -8, 0],
            [CIRCLE, 2],
            [GOTO,  15, -8, 0],
            [CIRCLE, 2],
            [GOTO, -15,  8, 0],
            [CIRCLE, 2],
            [GOTO,  15,  8, 0],
            [CIRCLE, 2]
        ]
    ]
]
```

Creates a rectangle with four screw holes.

### Rounded mounting plate

```scad
[
    [ROUNDEDRECT, 60, 30, 4],

    [HOLE,
        [
            [GOTO, -22, -10, 0],
            [CIRCLE, 2],
            [GOTO,  22, -10, 0],
            [CIRCLE, 2],
            [GOTO, -22,  10, 0],
            [CIRCLE, 2],
            [GOTO,  22,  10, 0],
            [CIRCLE, 2]
        ]
    ]
]
```

This is the typical 3D-printing use case: a printable rounded rectangle with
clearance holes.

## Validation policy

LogoSC Core validates command structure. The optional Validation companion also checks selected
polygon topology without changing Core evaluation or rendering.

Validated cases:

- malformed `[HOLE]` without child commands;
- `HOLE` before any drawable outer region;
- empty child command list;
- child commands that produce no closed contours.

Optional topology checks:

- holes must be strictly inside their owning outer contour;
- holes may not touch, cross, or share an edge with the outer boundary;
- holes may not overlap, touch, coincide, or nest inside one another.

Still deferred:

- winding orientation;
- automatic topology repair.

These checks use reusable tolerance-aware segment, contour, containment, and region-relation
helpers in `LogoSC-Foundation-Validation.scad`. They default on when callers explicitly invoke
the validator and can be disabled with `checkHoleTopology = false`. See
`LogoSC-Validation-Implementation.md` for the algorithms and focused test matrix.

## Why not `difference()` here?

A boolean implementation would look like this:

```scad
difference()
{
    polygon(outer);
    polygon(hole0);
    polygon(hole1);
}
```

That is reasonable for downstream 3D modeling, but it is not the cleanest
representation for LogoSC's 2D evaluator. Region data is more compact, easier to
test, and maps directly to OpenSCAD's polygon path model.

Keeping holes in the region structure also leaves `difference()` free for later
3D operations, such as subtracting extruded bosses, countersinks, sockets, or
non-planar features.

## Deferred stroke work

Open strokes are still separate from holes. A future stroke renderer should
convert centerline paths into closed outline polygons with explicit stroke width,
cap style, join style, and miter limit. That belongs in a later LogoSC-Rendering
milestone, not in the holes implementation.
