# LogoT-Foundation

## Current files

- `LogoT-Foundation-Core.scad` — core interpreter and renderer.
- `LogoT-Foundation-Tests.scad` — regression and failure test suites.
- `LogoT-README.md` — this overview.
- `CHANGELOG.md` — milestone release history.
- `LogoT-ARC-Implementation.md` — design notes for ARC tessellation.
- `LogoT-Holes-Implementation.md` — design notes for regions and holes.

## Workflow

1. Open `LogoT-Foundation-Core.scad` in OpenSCAD.
2. Leave `RunLogoTests = true` to run the regression tests.
3. Set `RunLogoTests = false` when using the file as a library.
4. Commit stable milestones to Git.

## Current command format

```scad
[MOVE,        len]
[TURN,        deltaHeading]
[DIR,         absoluteHeading]
[SCALE,       scaleMultiplier]
[GOTO,        x, y, heading]

[ARC,         radius, degrees]
[ARC,         radius, degrees, segments]

[CIRCLE,      radius]
[CIRCLE,      radius, segments]
[REGPOLY,     sides, radius]
[REGPOLY,     sides, radius, rotation]
[RECT,        width, height]
[ROUNDEDRECT, width, height, radius]
[ROUNDEDRECT, width, height, radius, segments]

[HOLE,        cmds]

[RUN,         cmds]
[RUN,         cmds, scale]
[RUN,         cmds, scale, maxRec]

[PUSH]
[POP]

[PENUP]
[PENDOWN]

[REPEAT,      count, cmds]
```

## Geometry commands

`ARC` follows a circular arc from the current Logo position and heading. Positive
angles turn left; negative angles turn right. The optional `segments` argument
sets the exact number of line segments used for the arc. When omitted, LogoT uses
OpenSCAD-style `$fn`, `$fa`, and `$fs` controls to choose the segment count.

`CIRCLE`, `REGPOLY`, `RECT`, and `ROUNDEDRECT` are closed 2D shape commands for
3D-printing-oriented geometry. They create separate closed contours centered on
the current Logo position. They respect the current Logo scale; `REGPOLY`,
`RECT`, and `ROUNDEDRECT` also respect the current heading. They do not move the
Logo state or change the heading.

`CIRCLE` is intentionally not the classic Logo circle command. In LogoT,
`[CIRCLE, r]` creates a closed filled circle centered at the current position. To
make the Logo cursor walk a full tangent loop instead, use `[ARC, r, 360]`.

`HOLE` evaluates its child command list as one or more closed contours and
attaches those contours as holes to the most recently emitted outer region. This
supports common 3D-printing shapes such as washers, mounting plates, and rounded
rectangles with screw holes.

## Rendering model

LogoT evaluates command lists into regions. Each region is a list of closed
rings:

```text
[outerContour, holeContour0, holeContour1, ...]
```

Each region is rendered with one OpenSCAD `polygon(points=..., paths=...)` call.
The first path is the filled outer boundary; later paths become holes. Regions
with only one ring behave like the earlier independent-contour renderer.

`ARC` is tessellated into contour points before rendering. Closed-shape commands
emit separate outer-region contours before rendering. Open-stroke rendering is
intentionally deferred.

## Rendering API

The reusable renderer lives in `LogoT-Foundation-Core.scad`; user models do not
need to duplicate the test renderer. LogoT intentionally renders 2D regions only.
Use native OpenSCAD operations around `RenderLogo2D()` for 3D modeling.

```scad
plate =
[
    [ROUNDEDRECT, 60, 30, 4],
    [HOLE, [[GOTO, -20, 0, 0], [CIRCLE, 3]]],
    [HOLE, [[GOTO,  20, 0, 0], [CIRCLE, 3]]]
];

RenderLogo2D(plate, convexity = 10);

linear_extrude(height = 4, center = false, convexity = 10)
{
    RenderLogo2D(plate);
}

linear_extrude(
    height = 4,
    center = true,
    convexity = 10,
    twist = 30,
    slices = 24)
{
    RenderLogo2D(plate);
}
```

For rotational solids, create a 2D profile and wrap it with OpenSCAD's native
`rotate_extrude()`. Position the profile according to OpenSCAD's normal rotation
rules; in practice, keep the profile on the positive-X side of the rotation axis
unless you are intentionally using axis-touching behavior.

```scad
profile =
[
    [GOTO, 20, 0, 0],
    [RECT, 4, 12]
];

rotate_extrude(angle = 360, convexity = 10)
{
    RenderLogo2D(profile);
}
```

Lower-level renderers are also available if you want to evaluate once and render
the resulting regions yourself:

```scad
result = evalLogo(plate);
regions = ResultContours(result);

RenderContours2D(regions, convexity = 10);
```

Use OpenSCAD's `linear_extrude()`, `rotate_extrude()`, `difference()`, `union()`,
and transforms around `RenderLogo2D()` for final 3D parts.

## Future rendering work

LogoT currently targets closed polygons because that maps cleanly to OpenSCAD and
3D printing. Open-stroke rendering is deferred to a later rendering milestone.

A future stroke renderer should probably convert centerline paths into closed
outline polygons. That design needs explicit stroke width, end-cap style, join
style, and probably a miter limit. Common cap styles are butt, square, and round.
Common join styles are miter, bevel, and round.

Potential future geometry helpers include automatic path fillets and possibly a
`ROUNDEDREGPOLY` command. That should wait until the corner-rounding semantics
are clearer; for now `REGPOLY` plus explicit construction is less magical.

## Release history

See `CHANGELOG.md`.

## Milestone roadmap

- LogoT-Foundation
- LogoT-Geometry
- LogoT-Language
- LogoT-Rendering
- LogoT-Fractals
- LogoT-1.0
