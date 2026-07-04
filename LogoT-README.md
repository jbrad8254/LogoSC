# LogoT-Foundation

## Current files

- `LogoT-Foundation-Core.scad` — core interpreter and renderer.
- `LogoT-Foundation-Tests.scad` — regression and failure test suites.
- `LogoT-README.md` — this overview.
- `CHANGELOG.md` — milestone release history.
- `LogoT-ARC-Implementation.md` — design notes for ARC tessellation.

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

## Rendering model

LogoT evaluates command lists into multiple contours. Each contour is rendered
with a separate `polygon()` call. This supports disconnected filled shapes
created with `PENUP` and `PENDOWN`.

`ARC` is tessellated into contour points before rendering. Closed-shape commands
emit separate contour point lists before rendering. Holes and open-stroke
rendering are intentionally deferred.

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
