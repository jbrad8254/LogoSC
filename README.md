# LogoT

LogoT is a small Logo-inspired turtle geometry layer for OpenSCAD. It turns compact command lists into 2D printable regions that can be extruded, subtracted, combined, and otherwise composed with ordinary OpenSCAD code.

LogoT is not trying to be a full Logo language. It is a lightweight OpenSCAD geometry DSL for making reusable 2D shapes, holes, ornaments, plaques, cutouts, and 3D-printing-friendly parts.

## What LogoT does

- Evaluates turtle-style command lists such as `MOVE`, `TURN`, `ARC`, `RUN`, and `REPEAT`.
- Creates filled 2D regions using commands such as `CIRCLE`, `RECT`, `ROUNDEDRECT`, and `REGPOLY`.
- Supports region holes through `HOLE`.
- Supports reusable relative command lists through `RUN`.
- Leaves 3D composition to native OpenSCAD tools such as `linear_extrude()`, `difference()`, `union()`, and `translate()`.

## Quick start

Open `LogoT-Examples.scad` in OpenSCAD to see the example gallery.

For your own model, include the core file and call `RenderLogo2D()`:

```scad
include <LogoT-Foundation-Core.scad>

part =
[
    [ROUNDEDRECT, 40, 20, 3],
    [HOLE, [[CIRCLE, 3]]]
];

linear_extrude(height = 4, convexity = 10)
{
    RenderLogo2D(part);
}
```

## Current public API

The main user-facing renderer is:

```scad
RenderLogo2D(cmds, convexity = 10);
```

Advanced helpers include:

```scad
evalLogo(cmds);
ResultContours(result);
ResultState(result);
RenderContours2D(regions, convexity = 10);
RenderRegion2D(region, convexity = 10);
```

The current public API version is `2026.0`.

## Command examples

```scad
[MOVE,        len]
[TURN,        deltaHeading]
[DIR,         absoluteHeading]
[GOTO,        x, y, heading]
[ARC,         radius, degrees]
[CIRCLE,      radius]
[RECT,        width, height]
[ROUNDEDRECT, width, height, radius]
[REGPOLY,     sides, radius]
[HOLE,        cmds]
[RUN,         cmds]
[REPEAT,      count, cmds]
[PUSH]
[POP]
[PENUP]
[PENDOWN]
```

See `LogoT-CheatSheet.md` and `LogoT-User-Manual.md` for the complete command reference.

## Repository files

- `LogoT-Foundation-Core.scad` — core interpreter and renderer.
- `LogoT-Foundation-Tests.scad` — regression and failure tests.
- `LogoT-Examples.scad` — runnable gallery and example models.
- `LogoT-User-Manual.md` — practical user documentation.
- `LogoT-CheatSheet.md` — compact command/API reference.
- `LogoT-README.md` — detailed project overview and roadmap.
- `LogoT-ARC-Implementation.md` — arc tessellation design notes.
- `LogoT-Holes-Implementation.md` — region and hole design notes.
- `LogoT-LSystems-Notes.md` — L-system design/example notes.
- `CHANGELOG.md` — release history.

## Design philosophy

LogoT keeps the core narrow:

- LogoT generates 2D regions.
- OpenSCAD handles 3D composition.
- Command lists should stay readable and reusable.
- Relative movement is preferred inside reusable shapes.
- Color and material choices stay outside the LogoT geometry core.

## Current status

LogoT currently focuses on filled 2D region rendering. Stroke/open-path rendering is planned as a future experimental area, especially for L-systems, engraving paths, and decorative centerline geometry.

## Requirements

- OpenSCAD
- No external OpenSCAD library dependency for the core files

## License

License not specified yet. Add a project license before publishing broadly or accepting external contributions.
