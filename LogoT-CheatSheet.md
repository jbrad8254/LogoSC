# LogoT Cheat Sheet

Compact reference for LogoT `2026.0`. For full explanations, see
[`LogoT-User-Manual.md`](LogoT-User-Manual.md),
[`LogoT-README.md`](LogoT-README.md), and
[`LogoT-Examples.scad`](LogoT-Examples.scad).

This layout is intentionally similar in spirit to the
[OpenSCAD cheat sheet](https://openscad.org/cheatsheet/index.html?version=2021.01),
but this file documents LogoT's command vectors and public API.

## Setup

```scad
include <LogoT-Foundation-Core.scad>
RunLogoTests = false;
TraceLevel = 0; // [0:4]
```

For examples, open:

```scad
LogoT-Examples.scad
```

## Version

```scad
LogoTVersionMajor
LogoTVersionMinor
LogoTVersion
LogoTVersionAtLeast(major, minor)
```

```scad
assert(LogoTVersionAtLeast(2026, 0), "This model requires LogoT 2026.0+");
```

## Command-list syntax

A LogoT program is an OpenSCAD vector of command vectors:

```scad
part =
[
    [ROUNDEDRECT, 60, 30, 4],
    [HOLE, [[CIRCLE, 5]]]
];
```

Nested square brackets in this cheat sheet mean optional trailing fields:

```scad
[ARC, radius, degrees[, segments]]
```

## Motion and state commands

| Command | Meaning |
|---|---|
| `[MOVE, len]` | Move along current heading; emits a point when pen is down. |
| `[TURN, deltaHeading]` | Add a relative heading. Positive is counterclockwise about +Z. |
| `[DIR, absoluteHeading]` | Set absolute heading in degrees. |
| `[SCALE, scaleMultiplier]` | Multiply the current Logo scale. |
| `[GOTO, x, y, heading]` | Set absolute position and heading. |

Coordinate convention: OpenSCAD right-handed coordinates. Heading 0 is +X;
heading 90 is +Y.

## Closed geometry commands

| Command | Meaning |
|---|---|
| `[ARC, radius, degrees[, segments]]` | Walk a tangent arc from current state; updates position and heading. |
| `[CIRCLE, radius[, segments]]` | Stamp a closed circle centered at current position. |
| `[REGPOLY, sides, radius[, rotation]]` | Stamp a regular polygon centered at current position. |
| `[RECT, width, height]` | Stamp a rectangle centered at current position. |
| `[ROUNDEDRECT, width, height, radius[, segments]]` | Stamp a rounded rectangle centered at current position. |
| `[HOLE, cmds]` | Attach child contours as holes to the most recent outer region. |

`CIRCLE` is CAD-style, not classic Logo-style. It does not move the state. Use
`[ARC, radius, 360]` when you want the Logo cursor to walk a full tangent loop.

## Control and structure commands

| Command | Meaning |
|---|---|
| `[RUN, cmds[, scale[, maxRec]]]` | Evaluate a child command list; optional temporary scale and recursion limit. |
| `[REPEAT, count, cmds]` | Evaluate a child command list `count` times. |
| `[PUSH]` | Push current state on the state stack. |
| `[POP]` | Restore the most recent pushed state. |
| `[PENUP]` | Stop emitting movement points. |
| `[PENDOWN]` | Start a new drawable contour. |

## Segment-count convention

| Case | Rule |
|---|---|
| Explicit `segments` | Overrides `$fn`, `$fa`, and `$fs`. |
| Omitted `segments` | Uses OpenSCAD-style `$fn`, `$fa`, `$fs` selection. |
| `ARC` explicit segments | Counts line segments along that arc. |
| `CIRCLE` explicit segments | Counts full-circle fragments. |
| `ROUNDEDRECT` explicit segments | Counts segments per rounded corner. |
| `REGPOLY` | Uses `sides`; does not consult `$fn`, `$fa`, or `$fs`. |

Detailed design note: [`LogoT-ARC-Implementation.md`](LogoT-ARC-Implementation.md).

## Public rendering and evaluation API

| API | Kind | Purpose |
|---|---|---|
| `RenderLogo2D(cmds, convexity = 10)` | module | Main user-facing renderer. Evaluates and renders 2D regions. |
| `evalLogo(cmds)` | function | Evaluate commands without rendering. |
| `ResultState(result)` | function | Final `[x, y, heading, scale]`. |
| `ResultContours(result)` | function | Evaluated region list. Historical name; returns regions. |
| `ResultStack(result)` | function | Final state stack. |
| `ResultPen(result)` | function | Final pen state. |
| `RenderContours2D(regions, convexity = 10)` | module | Render already-evaluated regions. |
| `RenderRegion2D(region, convexity = 10)` | module | Render one region. |

Main pattern:

```scad
linear_extrude(height = 4, convexity = 10)
{
    RenderLogo2D(part);
}
```

Advanced pattern:

```scad
result = evalLogo(part);
state = ResultState(result);
regions = ResultContours(result);

RenderContours2D(regions, convexity = 10);
```

Full docs:
[User Manual API section](LogoT-User-Manual.md#7-public-rendering-and-evaluation-api).

## Region structure

LogoT renders closed regions:

```text
region  = [outerContour, holeContour0, holeContour1, ...]
regions = [region0, region1, ...]
```

Each region becomes one OpenSCAD `polygon(points=..., paths=...)` call. Holes
are paths after the outer path. Detailed note:
[`LogoT-Holes-Implementation.md`](LogoT-Holes-Implementation.md).

## Common OpenSCAD wrappers around LogoT output

LogoT intentionally emits 2D geometry only. Use native OpenSCAD modules around
`RenderLogo2D()`.

| OpenSCAD wrapper | Common use with LogoT output |
|---|---|
| `linear_extrude(height, center, convexity, twist, slices)` | Make printable 3D solids from LogoT 2D regions. |
| `rotate_extrude(angle, convexity)` | Revolve a LogoT 2D profile around the Z axis. |
| `offset(r)` | Expand/round a 2D profile; possible basis for crude stroke-like effects. |
| `offset(delta, chamfer)` | Inset/outset with optional chamfer behavior. |
| `translate([x, y, z])` | Position LogoT output. |
| `rotate([x, y, z])` | Rotate LogoT output. |
| `scale([x, y, z])` | Resize LogoT output. |
| `color("name")` | Color previews/tests; not part of LogoT geometry semantics. |
| `union()` | Combine several LogoT outputs. |
| `difference()` | Subtract 3D features or alternate hole strategies. |
| `intersection()` | Clip LogoT output. |

OpenSCAD references:
[cheat sheet](https://openscad.org/cheatsheet/index.html?version=2021.01),
[2D-to-3D extrusion](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/2D_to_3D_Extrusion),
[transformations and offset](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations).

Examples:

```scad
linear_extrude(height = 4, center = false, convexity = 10)
{
    RenderLogo2D(part);
}
```

```scad
linear_extrude(height = 10, twist = 45, slices = 32, convexity = 10)
{
    RenderLogo2D([[ROUNDEDRECT, 20, 20, 3]]);
}
```

```scad
rotate_extrude(angle = 360, convexity = 10)
{
    RenderLogo2D(profileOnPositiveX);
}
```

```scad
offset(r = 0.5)
{
    RenderLogo2D(part);
}
```

## Global controls

| Variable | Meaning |
|---|---|
| `RunLogoTests` | Run regression/visual tests from the core include. |
| `HardErrors` | Turn soft errors into OpenSCAD `assert()` failures. |
| `TraceLevel` | Static/execution tracing level, 0 through 4. |
| `maxRunRecursions` | Global recursion safety limit for `RUN`. |
| `$fn`, `$fa`, `$fs` | OpenSCAD-style curved-geometry tessellation controls. |

## Test helpers

These are mainly for `LogoT-Foundation-Tests.scad`:

```scad
LogoTest(testName, vtCmds, testIndex, height, testColor)
```

Visual tests are color-coded by grid index. Test geometry color follows the X
index; row markers identify Y indices.

## Further reading

- [`LogoT-README.md`](LogoT-README.md) — project overview.
- [`LogoT-User-Manual.md`](LogoT-User-Manual.md) — full command documentation.
- [`LogoT-Examples.scad`](LogoT-Examples.scad) — runnable examples.
- [`LogoT-ARC-Implementation.md`](LogoT-ARC-Implementation.md) — arc tessellation.
- [`LogoT-Holes-Implementation.md`](LogoT-Holes-Implementation.md) — regions and holes.
- [`CHANGELOG.md`](CHANGELOG.md) — release history.
