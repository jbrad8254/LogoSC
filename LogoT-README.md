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
[MOVE,   len]
[TURN,   deltaHeading]
[DIR,    absoluteHeading]
[SCALE,  scaleMultiplier]
[GOTO,   x, y, heading]

[ARC,    radius, degrees]
[ARC,    radius, degrees, segments]

[RUN,    cmds]
[RUN,    cmds, scale]
[RUN,    cmds, scale, maxRec]

[PUSH]
[POP]

[PENUP]
[PENDOWN]

[REPEAT, count, cmds]
```

## Geometry commands

`ARC` follows a circular arc from the current Logo position and heading. Positive
angles turn left; negative angles turn right. The optional `segments` argument
sets the exact number of line segments used for the arc. When omitted, LogoT uses
OpenSCAD-style `$fn`, `$fa`, and `$fs` controls to choose the segment count.

## Rendering model

LogoT evaluates command lists into multiple contours. Each contour is rendered with a
separate `polygon()` call. This supports disconnected filled shapes created with
`PENUP` and `PENDOWN`.

`ARC` is tessellated into contour points before rendering. Holes and open-stroke
rendering are intentionally deferred.

## Release history

See `CHANGELOG.md`.

## Milestone roadmap

- LogoT-Foundation
- LogoT-Geometry
- LogoT-Language
- LogoT-Rendering
- LogoT-Fractals
- LogoT-1.0
