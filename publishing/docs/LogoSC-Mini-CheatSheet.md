# LogoSC Mini Cheat Sheet

Include the runtime:

```scad
include <LogoSC-Foundation-Core.scad>
```

Render a command list:

```scad
RenderLogo2D(commands);
```

## Movement and reuse

```text
[MOVE, distance]
[TURN, degrees]
[ARC, radius, angle, segments]
[RUN, commands]
[REPEAT, count, commands]
```

Positive turns are counterclockwise. Prefer relative movement inside reusable shapes.

## Common primitives

```text
[CIRCLE, radius]
[CIRCLE, radius, segments]
[REGPOLY, sides, radius]
[RECT, width, height]
[ROUNDEDRECT, width, height, radius]
[ROUNDEDRECT, width, height, radius, segments]
```

## Holes

```scad
plate =
[
    [ROUNDEDRECT, 60, 36, 5],
    [HOLE, [[CIRCLE, 6]]]
];
```

## Native OpenSCAD composition

```scad
linear_extrude(height = 3, convexity = 10)
{
    RenderLogo2D(commands);
}
```

OpenSCAD remains responsible for extrusion, transforms around rendered geometry, booleans, and
color. Get the Core suite for the complete command and API reference.
