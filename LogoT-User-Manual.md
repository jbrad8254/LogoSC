# LogoT User Manual

LogoT is a small Logo-style geometry language embedded in OpenSCAD. It evaluates
integer-opcode command lists into closed 2D regions that can be rendered with
OpenSCAD `polygon(points=..., paths=...)` and then used directly in ordinary
OpenSCAD modeling operations.

LogoT is designed primarily for 3D-printable 2D profiles: plates, panels,
washers, outlines, rounded rectangles, decorative regions, and profiles that can
be passed to `linear_extrude()` or `rotate_extrude()`.

## 1. Files

Current project files:

```text
LogoT-Foundation-Core.scad        Core interpreter, geometry, and 2D renderer.
LogoT-Foundation-Tests.scad       Regression and visual tests.
LogoT-README.md                   Project overview and roadmap.
CHANGELOG.md                      Release history.
LogoT-ARC-Implementation.md        ARC tessellation design notes.
LogoT-Holes-Implementation.md     Region/hole design notes.
LogoT-User-Manual.md              This manual.
.gitattributes                    LF line-ending policy for Git.
```

Open `LogoT-Foundation-Core.scad` in OpenSCAD. Set:

```scad
RunLogoTests = true;
```

to run the regression/visual tests. Set:

```scad
RunLogoTests = false;
```

when using LogoT as a library in your own model.

## 2. Core idea

A LogoT program is an OpenSCAD vector of command vectors:

```scad
part =
[
    [RECT, 60, 30],
    [HOLE, [[CIRCLE, 5]]]
];
```

Render it as 2D geometry with:

```scad
RenderLogo2D(part);
```

Use normal OpenSCAD operations for 3D modeling:

```scad
linear_extrude(height = 4, center = false, convexity = 10)
{
    RenderLogo2D(part);
}
```

LogoT intentionally renders **2D regions only**. It does not wrap
`linear_extrude()`, `rotate_extrude()`, `difference()`, or `union()`. Keeping
those operations outside LogoT keeps the API small and lets OpenSCAD do normal
OpenSCAD work.

## 3. Coordinate model

LogoT maintains a current state:

```text
[x, y, heading, scale]
```

- `x`, `y`: current 2D position.
- `heading`: direction in degrees.
- `scale`: current multiplicative scale factor.

The default starting state is:

```text
[0, 0, 0, 1]
```

By convention:

```text
heading 0   points along +X
heading 90  points along +Y
heading 180 points along -X
heading 270 points along -Y
```

Movement commands update the current state. Closed-shape commands stamp geometry
at the current state but do not move the state.

## 4. Rendering model

LogoT evaluates commands into **regions**.

A region is:

```text
[outerContour, holeContour0, holeContour1, ...]
```

Each contour is a list of `[x, y]` points. Each region renders as one OpenSCAD
polygon call:

```scad
polygon(points = flatPoints, paths = regionPaths, convexity = convexity);
```

The first path is the outer filled contour. Later paths are holes.

OpenSCAD `polygon()` closes each path automatically. LogoT currently targets
closed printable 2D polygons, not open strokes. Stroke rendering, line width,
end caps, joins, and miter limits are future work.

## 5. Public rendering API

Most users should use only:

```scad
RenderLogo2D(cmds, convexity = 10);
```

Lower-level renderers are available for tests or advanced workflows:

```scad
RenderRegion2D(region, convexity = 10);
RenderContours2D(regions, convexity = 10);
```

Typical advanced pattern:

```scad
result = evalLogo(part);
regions = ResultContours(result);

RenderContours2D(regions, convexity = 10);
```

The old `RenderContours()` compatibility alias has been removed. Use
`RenderContours2D()` when rendering already-evaluated regions.

## 6. 3D printing workflow

### Linear extrusion

```scad
plate =
[
    [ROUNDEDRECT, 60, 30, 4],
    [HOLE, [[GOTO, -20, 0, 0], [CIRCLE, 3]]],
    [HOLE, [[GOTO,  20, 0, 0], [CIRCLE, 3]]]
];

linear_extrude(height = 4, center = false, convexity = 10)
{
    RenderLogo2D(plate);
}
```

### Twisted linear extrusion

```scad
linear_extrude(
    height = 10,
    center = true,
    convexity = 10,
    twist = 45,
    slices = 32)
{
    RenderLogo2D([[REGPOLY, 6, 8]]);
}
```

### Rotate extrusion

For `rotate_extrude()`, the 2D profile should normally live on the positive-X
side of the rotation axis.

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

## 7. Segment-count controls

Curved commands use tessellated line segments. If a command supplies an explicit
segment count, that value overrides OpenSCAD's `$fn`, `$fa`, and `$fs` controls.

```scad
[ARC, 10, 90, 8]      // exactly 8 segments along the arc
[CIRCLE, 10, 48]      // exactly 48 segments around the full circle
[ROUNDEDRECT, 40, 20, 4, 6]  // 6 segments per rounded corner
```

If the segment count is omitted, LogoT uses OpenSCAD-style automatic fragment
selection:

- `$fn > 0` sets the full-circle fragment count.
- `$fn == 0` lets `$fa` and `$fs` choose the fragment count.
- Partial arcs scale the full-circle count by the arc angle.

`REGPOLY` uses its side count directly and does not consult `$fn`, `$fa`, or
`$fs`.

## 8. Command reference

### `MOVE`

Syntax:

```scad
[MOVE, len]
```

Moves forward by `len * scale` in the current heading. If the pen is down, the
new position is appended to the active contour. If the pen is up, only the state
moves.

Example:

```scad
triangle =
[
    [MOVE, 20],
    [TURN, 120],
    [MOVE, 20],
    [TURN, 120],
    [MOVE, 20]
];

RenderLogo2D(triangle);
```

Notes:

- `polygon()` closes the contour automatically.
- This is useful for hand-built closed paths.

### `TURN`

Syntax:

```scad
[TURN, deltaHeading]
```

Adds `deltaHeading` degrees to the current heading.

Example:

```scad
path =
[
    [MOVE, 20],
    [TURN, 90],
    [MOVE, 10]
];
```

### `DIR`

Syntax:

```scad
[DIR, absoluteHeading]
```

Sets the heading to an absolute angle in degrees.

Example:

```scad
path =
[
    [DIR, 90],
    [MOVE, 10]
];
```

### `SCALE`

Syntax:

```scad
[SCALE, scaleMultiplier]
```

Multiplies the current scale by `scaleMultiplier`.

Example:

```scad
part =
[
    [CIRCLE, 5],
    [GOTO, 20, 0, 0],
    [SCALE, 2],
    [CIRCLE, 5]
];
```

The second circle has effective radius `10`.

### `GOTO`

Syntax:

```scad
[GOTO, x, y, heading]
```

Sets absolute position and heading.

If the pen is down, the new position is appended to the active contour. If the
pen is up, this repositions without drawing.

Example:

```scad
part =
[
    [PENUP],
    [GOTO, 10, 5, 0],
    [PENDOWN],
    [CIRCLE, 3]
];
```

### `ARC`

Syntax:

```scad
[ARC, radius, degrees]
[ARC, radius, degrees, segments]
```

Draws a circular arc from the current position, tangent to the current heading.
Positive angles turn left. Negative angles turn right.

State effects:

- Updates position to the end of the arc.
- Updates heading by `degrees`.
- Respects current scale.
- Emits tessellated points only when the pen is down.

Example: quarter turn from east to north.

```scad
curve =
[
    [ARC, 10, 90, 8]
];

RenderLogo2D(curve);
```

Example: classic Logo-style full circular walk.

```scad
loop =
[
    [ARC, 10, 360]
];
```

`ARC` is the command to use when you want the Logo cursor to walk around a
circle. `CIRCLE` means something different in LogoT.

### `CIRCLE`

Syntax:

```scad
[CIRCLE, radius]
[CIRCLE, radius, segments]
```

Creates a closed filled circle centered at the current Logo position.

State effects:

- Does not move the current position.
- Does not change heading.
- Respects current scale.
- Obeys pen state.

Example:

```scad
washerOuter =
[
    [CIRCLE, 20]
];
```

Important: this is not the classic Logo circle behavior. In LogoT,
`[CIRCLE, r]` is a CAD-style closed shape centered at the current position. To
walk a full tangent loop, use:

```scad
[ARC, r, 360]
```

### `REGPOLY`

Syntax:

```scad
[REGPOLY, sides, radius]
[REGPOLY, sides, radius, rotation]
```

Creates a closed regular polygon centered at the current Logo position.

State effects:

- Does not move position.
- Does not change heading.
- Respects current scale.
- Respects current heading.
- Optional `rotation` is relative to the current heading.
- Obeys pen state.

Example:

```scad
hex =
[
    [REGPOLY, 6, 10]
];

RenderLogo2D(hex);
```

### `RECT`

Syntax:

```scad
[RECT, width, height]
```

Creates a closed rectangle centered at the current Logo position and oriented by
the current heading.

State effects:

- Does not move position.
- Does not change heading.
- Respects current scale.
- Obeys pen state.

Example:

```scad
plate =
[
    [RECT, 50, 20]
];
```

Rotated rectangle:

```scad
rotatedPlate =
[
    [DIR, 30],
    [RECT, 50, 20]
];
```

### `ROUNDEDRECT`

Syntax:

```scad
[ROUNDEDRECT, width, height, radius]
[ROUNDEDRECT, width, height, radius, segments]
```

Creates a closed rounded rectangle centered at the current Logo position and
oriented by the current heading.

State effects:

- Does not move position.
- Does not change heading.
- Respects current scale.
- Obeys pen state.

The optional `segments` argument controls the number of segments per rounded
corner.

Example:

```scad
panel =
[
    [ROUNDEDRECT, 60, 30, 4]
];
```

### `HOLE`

Syntax:

```scad
[HOLE, cmds]
```

Evaluates `cmds` as one or more closed contours and attaches those contours as
holes to the most recently emitted outer region.

State effects:

- Does not change the parent Logo position.
- Does not change the parent heading.
- Does not change the parent stack.
- Does not change the parent pen state.
- Child commands are evaluated with the pen down.

Example: washer.

```scad
washer =
[
    [CIRCLE, 20],
    [HOLE, [[CIRCLE, 8]]]
];

RenderLogo2D(washer);
```

Example: rounded plate with four screw holes.

```scad
mountingPlate =
[
    [ROUNDEDRECT, 60, 30, 4],

    [HOLE, [[GOTO, -20, -8, 0], [CIRCLE, 2.5]]],
    [HOLE, [[GOTO,  20, -8, 0], [CIRCLE, 2.5]]],
    [HOLE, [[GOTO, -20,  8, 0], [CIRCLE, 2.5]]],
    [HOLE, [[GOTO,  20,  8, 0], [CIRCLE, 2.5]]]
];
```

Multiple child contours can become multiple holes:

```scad
multiHolePlate =
[
    [RECT, 50, 20],
    [HOLE,
        [
            [GOTO, -15, 0, 0],
            [CIRCLE, 3],
            [GOTO,  15, 0, 0],
            [CIRCLE, 3]
        ]
    ]
];
```

LogoT does not currently validate whether holes are fully inside the outer
region, whether holes overlap, or whether regions are self-intersecting. Keep
geometry sane; CGAL is not a therapist.

### `RUN`

Syntax:

```scad
[RUN, cmds]
[RUN, cmds, scale]
[RUN, cmds, scale, maxRec]
```

Evaluates a child command list from the current state.

The optional `scale` multiplies the child execution scale. The optional `maxRec`
limits nested `RUN` recursion.

Example:

```scad
holeShape = [[CIRCLE, 2.5]];

plate =
[
    [ROUNDEDRECT, 60, 30, 4],
    [HOLE, [[GOTO, -20, 0, 0], [RUN, holeShape]]],
    [HOLE, [[GOTO,  20, 0, 0], [RUN, holeShape]]]
];
```

### `REPEAT`

Syntax:

```scad
[REPEAT, count, cmds]
```

Runs `cmds` repeatedly.

Example: four mounting holes around the origin.

```scad
holePattern =
[
    [REPEAT, 4,
        [
            [PUSH],
                [MOVE, 20],
                [CIRCLE, 2],
            [POP],
            [TURN, 90]
        ]
    ]
];
```

Use this inside `HOLE` to cut repeated holes:

```scad
roundPlate =
[
    [CIRCLE, 30],
    [HOLE,
        [
            [REPEAT, 4,
                [
                    [PUSH],
                        [MOVE, 18],
                        [CIRCLE, 2],
                    [POP],
                    [TURN, 90]
                ]
            ]
        ]
    ]
];
```

### `PUSH` and `POP`

Syntax:

```scad
[PUSH]
[POP]
```

`PUSH` saves the current Logo state. `POP` restores the most recently saved
state.

The stack stores:

```text
[x, y, heading, scale]
```

It does not store the contour list or pen state.

Example:

```scad
part =
[
    [PUSH],
        [GOTO, -10, 0, 0],
        [CIRCLE, 3],
    [POP],

    [PUSH],
        [GOTO, 10, 0, 0],
        [CIRCLE, 3],
    [POP]
];
```

### `PENUP` and `PENDOWN`

Syntax:

```scad
[PENUP]
[PENDOWN]
```

`PENUP` stops movement commands from appending points to contours.

`PENDOWN` starts a new contour at the current position and resumes point
emission. If the pen is already down, `PENDOWN` still starts a new contour.

Example: two disconnected movement-built shapes.

```scad
part =
[
    [MOVE, 10],
    [TURN, 90],
    [MOVE, 10],

    [PENUP],
    [GOTO, 30, 0, 0],
    [PENDOWN],

    [MOVE, 10],
    [TURN, 90],
    [MOVE, 10]
];
```

Closed-shape commands also obey pen state. For example, `[PENUP], [CIRCLE, 5]`
does not emit a circle.

## 9. Practical examples

### Example 1: simple extruded plate

```scad
RunLogoTests = false;
include <LogoT-Foundation-Core.scad>

plate =
[
    [RECT, 60, 25]
];

linear_extrude(height = 3, convexity = 10)
{
    RenderLogo2D(plate);
}
```

### Example 2: rounded mounting plate

```scad
RunLogoTests = false;
include <LogoT-Foundation-Core.scad>

mountingPlate =
[
    [ROUNDEDRECT, 70, 35, 5],

    [HOLE, [[GOTO, -25, -10, 0], [CIRCLE, 2.6]]],
    [HOLE, [[GOTO,  25, -10, 0], [CIRCLE, 2.6]]],
    [HOLE, [[GOTO, -25,  10, 0], [CIRCLE, 2.6]]],
    [HOLE, [[GOTO,  25,  10, 0], [CIRCLE, 2.6]]]
];

linear_extrude(height = 4, convexity = 10)
{
    RenderLogo2D(mountingPlate);
}
```

### Example 3: washer

```scad
washer =
[
    [CIRCLE, 18],
    [HOLE, [[CIRCLE, 8]]]
];

linear_extrude(height = 2.5, convexity = 10)
{
    RenderLogo2D(washer);
}
```

### Example 4: decorative hex plate

```scad
hexPlate =
[
    [REGPOLY, 6, 25],
    [HOLE, [[CIRCLE, 5]]],

    [HOLE,
        [
            [REPEAT, 6,
                [
                    [PUSH],
                        [MOVE, 14],
                        [CIRCLE, 1.8],
                    [POP],
                    [TURN, 60]
                ]
            ]
        ]
    ]
];

linear_extrude(height = 3, convexity = 10)
{
    RenderLogo2D(hexPlate);
}
```

### Example 5: rotate-extruded ring profile

```scad
profile =
[
    [GOTO, 20, 0, 0],
    [RECT, 4, 10]
];

rotate_extrude(angle = 360, convexity = 10)
{
    RenderLogo2D(profile);
}
```

## 10. Error handling and tracing

LogoT defaults to soft errors:

```scad
HardErrors = false;
```

In soft-error mode, malformed commands emit `[ERROR]` messages and evaluation
continues. This is useful because OpenSCAD `assert()` stops the whole run.

Set:

```scad
HardErrors = true;
```

when you want invalid input to stop immediately.

Tracing is controlled by:

```scad
TraceLevel = 0; // quiet
TraceLevel = 2; // static command-list trace and summaries
TraceLevel = 4; // full execution trace
```

Higher levels include lower levels.

## 11. Limitations

Current limitations:

- LogoT targets closed 2D regions, not open strokes.
- No stroke width, caps, joins, or miter limits yet.
- No automatic path filleting yet.
- No `ROUNDEDREGPOLY` yet.
- No variable/procedure system beyond OpenSCAD variables and `RUN` child lists.
- Holes are attached to the most recently emitted outer region.
- Hole containment and hole overlap are not validated by LogoT.
- `polygon()` closes paths automatically.

For now, use closed shapes, `HOLE`, and native OpenSCAD boolean/modeling
operations to build printable parts.

## 12. Suggested style for LogoT programs

Use named OpenSCAD variables for repeated command lists:

```scad
screwHole = [[CIRCLE, 2.5]];

plate =
[
    [ROUNDEDRECT, 60, 30, 4],
    [HOLE, [[GOTO, -20, 0, 0], [RUN, screwHole]]],
    [HOLE, [[GOTO,  20, 0, 0], [RUN, screwHole]]]
];
```

Prefer explicit segment counts in tests and examples when point counts matter:

```scad
[CIRCLE, 10, 32]
[ARC, 5, 90, 8]
[ROUNDEDRECT, 40, 20, 4, 6]
```

Omit segment counts in real models when you want `$fn`, `$fa`, and `$fs` to
control smoothness globally.
