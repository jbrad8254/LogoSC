# LogoT-Foundation

## Current files

- `LogoT-Foundation-Core.scad` — core interpreter and renderer.
- `LogoT-Foundation-Tests.scad` — regression and failure test suites.
- `LogoT-README.md` — this overview.

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

[RUN,    cmds]
[RUN,    cmds, scale]
[RUN,    cmds, scale, maxRec]

[PUSH]
[POP]

[PENUP]
[PENDOWN]

[REPEAT, count, cmds]
```

## Rendering model

LogoT evaluates command lists into multiple contours. Each contour is rendered with a
separate `polygon()` call. This supports disconnected filled shapes created with
`PENUP` and `PENDOWN`.

Holes and open-stroke rendering are intentionally deferred.

## Milestone roadmap

- LogoT-Foundation
- LogoT-Geometry
- LogoT-Language
- LogoT-Rendering
- LogoT-Fractals
- LogoT-1.0
