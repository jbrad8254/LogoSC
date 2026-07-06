# LogoT User Manual

LogoT is a small Logo-style geometry language embedded in OpenSCAD. It evaluates
integer-opcode command lists into closed 2D regions that can be rendered with
OpenSCAD `polygon(points=..., paths=...)` and then used directly in ordinary
OpenSCAD modeling operations.

LogoT is designed primarily for 3D-printable 2D profiles: plates, panels,
washers, outlines, rounded rectangles, decorative regions, and profiles that can
be passed to `linear_extrude()` or `rotate_extrude()`.

## Table of Contents

- [1. Files and setup](#1-files)
  - [Setup](#setup)
  - [Library version](#library-version)
- [2. Core idea](#2-core-idea)
- [3. Quick lookup cheat sheet](#3-quick-lookup-cheat-sheet)
- [4. Runnable examples](#4-runnable-examples)
- [5. Coordinate model](#5-coordinate-model)
- [6. Rendering model](#6-rendering-model)
- [7. Public rendering and evaluation API](#7-public-rendering-and-evaluation-api)
- [8. 3D printing workflow](#8-3d-printing-workflow)
- [9. Segment-count controls](#9-segment-count-controls)
- [10. Command reference](#10-command-reference)
- [11. Recursion and recursive patterns](#11-recursion-and-recursive-patterns)
- [12. Practical examples](#12-practical-examples)
- [13. Error handling and tracing](#13-error-handling-and-tracing)
- [14. Limitations](#14-limitations)
- [15. Suggested style for LogoT programs](#15-suggested-style-for-logot-programs)
- [Index](#index)

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
LogoT-CheatSheet.md               Compact command and API reference.
LogoT-Examples.scad               Runnable example gallery.
.gitattributes                    LF line-ending policy for Git.
```

### Setup

For normal use, put the LogoT core file next to your model and include it from
OpenSCAD:

```scad
include <LogoT-Foundation-Core.scad>
RunLogoTests = false;
TraceLevel = 0; // [0:4]
```

The `RunLogoTests` and `TraceLevel` assignments should come **after** the
`include`. OpenSCAD `include` behaves like textual insertion, so post-include
assignments override the core file's Customizer defaults without creating a
second Customizer block or accidentally enabling the regression-test gallery in
your model.

For ordinary 2D output, wrap a LogoT command list with:

```scad
RenderLogo2D(cmds);
```

For 3D printing, use native OpenSCAD operations around the 2D output:

```scad
linear_extrude(height = 4, center = false, convexity = 10)
{
    RenderLogo2D(cmds);
}
```

To run the built-in tests, open `LogoT-Foundation-Core.scad` directly in
OpenSCAD and leave:

```scad
RunLogoTests = true;
```

The runnable gallery in `LogoT-Examples.scad` follows the same include pattern
and is a good starting point for user models.

### Library version

Current public API version: `2026.0`.

The core file exposes version constants and a helper for user-model compatibility
checks:

```scad
LogoTVersionMajor
LogoTVersionMinor
LogoTVersion
LogoTVersionAtLeast(major, minor)
```

Example:

```scad
assert(LogoTVersionAtLeast(2026, 0), "This model requires LogoT 2026.0+");
```

The version is bumped manually for public API or feature milestones. Git remains
the source of truth for ordinary commit-by-commit source history.

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


## 3. Quick lookup cheat sheet

`LogoT-CheatSheet.md` is the compact reference for command syntax, rendering
API calls, and common OpenSCAD wrappers used around LogoT output. Use it while
writing models; return to this manual for full explanations and examples.

## 4. Runnable examples

`LogoT-Examples.scad` is the best place to see the library used as an OpenSCAD
modeling tool rather than as a test harness. It contains a gallery module plus
individual named examples for washers, mounting plates, radial holes, Koch
snowflake geometry, rotate-extruded profiles, twisted extrusions, a small spiral
tower, and the LogoT feature wordmark.

Open `LogoT-Examples.scad` directly in OpenSCAD. The default setting renders the
full gallery:

```scad
RunLogoExamples = true;
```

The examples file includes the core and suppresses test/tracing output with:

```scad
include <LogoT-Foundation-Core.scad>
RunLogoTests = false;
TraceLevel = 0; // [0:4]
```

Use it as a cookbook: copy a command list such as `ExampleMountingPlate`, or use
one of the example rendering modules as a starting point for your own model.

## 5. Coordinate model

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

LogoT uses OpenSCAD's right-handed coordinate system. In the standard LogoT
test/example view, +X appears to the left and +Y appears upward; avoid assuming
a left-handed screen-coordinate convention when reasoning about turns and arcs.
Positive relative turns are right-handed rotations about the +Z axis. Viewed
from +Z toward the XY plane, positive turns are counterclockwise.

Movement commands update the current state. Closed-shape commands stamp geometry
at the current state but do not move the state.

### 5.1 Relative drawing vs. absolute layout

Prefer relative commands inside reusable command lists. Use `MOVE`, `TURN`,
`ARC`, `RUN`, `REPEAT`, and `SCALE` when defining a shape that should inherit
the caller's position, heading, and scale. Use `GOTO` and `DIR` primarily for
layout, anchoring, and deterministic setup.

| Situation | Prefer | Reason |
|---|---|---|
| Drawing a reusable glyph, shape, or path | `MOVE`, `TURN`, `ARC` | The shape inherits caller position, heading, and scale. |
| Placing objects in a larger design | `GOTO`, sometimes `DIR` | Layout usually needs explicit positions. |
| Resetting known state at the start of an example | `GOTO`, `DIR` | The example is deterministic and easy to inspect. |
| Decorative turtle/path geometry | `MOVE`, `TURN` | This preserves Logo-style relative motion. |
| CAD-style stamped primitives | `GOTO`, then `CIRCLE`, `RECT`, or `ROUNDEDRECT` | Stamped objects are centered at the current position. |

A good default pattern is absolute setup followed by relative drawing:

```scad
shape =
[
    [GOTO, 0, 0, 0],     // anchor the shape
    [MOVE, 20],
    [TURN, 90],
    [MOVE, 10],
    [TURN, 90],
    [MOVE, 20]
];
```

## 6. Rendering model

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

## 7. Public rendering and evaluation API

LogoT has two layers:

```text
command list -> evalLogo() -> EvalResult -> regions -> RenderLogo2D()
```

Most user models should call only `RenderLogo2D()`. The other APIs are useful
when you are writing tests, debugging generated paths, or evaluating a command
list once and rendering or inspecting it later.

### `RenderLogo2D(cmds, convexity = 10)`

Main user-facing renderer.

```scad
RenderLogo2D(cmds, convexity = 10);
```

- `cmds`: LogoT command list.
- `convexity`: forwarded to each OpenSCAD `polygon()` call.
- Output: 2D OpenSCAD geometry.
- Common use: wrap with native OpenSCAD operations such as `linear_extrude()`,
  `rotate_extrude()`, `offset()`, `translate()`, `scale()`, `union()`, or
  `difference()`.

Example:

```scad
plate =
[
    [ROUNDEDRECT, 60, 30, 4],
    [HOLE, [[GOTO, -20, 0, 0], [CIRCLE, 3]]],
    [HOLE, [[GOTO,  20, 0, 0], [CIRCLE, 3]]]
];

linear_extrude(height = 4, convexity = 10)
{
    RenderLogo2D(plate);
}
```

### `evalLogo(cmds)`

Evaluates a command list without rendering geometry.

```scad
result = evalLogo(cmds);
```

The full signature is available for recursive/internal use, but user code should
normally pass only `cmds`:

```scad
evalLogo(
    cmds,
    state = stateGoto(0, 0, 0, 1),
    index = 0,
    maxRec = maxRunRecursions,
    contours = [MakeRegion([])],
    stack = [],
    pen = PEN_DOWN
);
```

Return value:

```text
EvalResult(finalState, regions, stack, pen)
```

### Result accessors

Use these instead of indexing the result vector directly:

```scad
ResultState(result)     // final [x, y, heading, scale]
ResultContours(result)  // evaluated region list
ResultStack(result)     // final PUSH/POP stack
ResultPen(result)       // final pen state
```

`ResultContours()` keeps its old name for continuity. It now returns a **region
list**, not a raw flat list of independent contours:

```text
regions =
[
    [outerContour, holeContour0, holeContour1],
    [outerContour]
];
```

### `RenderContours2D(regions, convexity = 10)`

Renders an already-evaluated region list.

```scad
result = evalLogo(part);
regions = ResultContours(result);

RenderContours2D(regions, convexity = 10);
```

Use this when you want to inspect the evaluated result or avoid re-evaluating a
large generated command list.

### `RenderRegion2D(region, convexity = 10)`

Renders exactly one region:

```text
[outerContour, holeContour0, holeContour1, ...]
```

This is mainly a low-level testing/debugging hook. Normal models should call
`RenderLogo2D()`.

### OpenSCAD wrapper pattern

LogoT intentionally remains a 2D geometry generator. Use OpenSCAD modules around
LogoT output for final modeling:

```scad
color("cyan")
linear_extrude(height = 4, twist = 20, slices = 24)
{
    offset(r = 0.5)
    {
        RenderLogo2D(part);
    }
}
```

The old `RenderContours()` compatibility alias has been removed. Use
`RenderContours2D()` when rendering already-evaluated regions.

## 8. 3D printing workflow

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

## 9. Segment-count controls

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

## 10. Command reference

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

Adds `deltaHeading` degrees to the current heading. Positive values rotate
counterclockwise in the XY plane, using the standard right-handed +Z-axis
rotation convention.

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
[ARC, radius, degrees[, segments]]
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
[CIRCLE, radius[, segments]]
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
[REGPOLY, sides, radius[, rotation]]
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
[ROUNDEDRECT, width, height, radius[, segments]]
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
[RUN, cmds[, scale[, maxRec]]]
```

Evaluates a child command list from the current state.

The optional `scale` multiplies the child execution scale. The optional `maxRec`
limits nested `RUN` recursion. See [Section 9](#9-recursion-and-recursive-patterns)
for details on `REPEAT`, `RUN`, recursive OpenSCAD command generators, and
Koch-style fractals.

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

## 11. Recursion and recursive patterns

LogoT uses the word "recursion" in a few related but distinct ways. They are
worth separating because they have different costs and different failure modes.

### 9.1 `REPEAT`: bounded repetition

`REPEAT` is the simplest form. It repeats a child command list a fixed number of
times:

```scad
square =
[
    [REPEAT, 4,
        [
            [MOVE, 10],
            [TURN, 90]
        ]
    ]
];
```

Use `REPEAT` when the number of copies is known and the body does not need to
change structurally from one copy to the next.

Common uses:

- regular polygons;
- repeated screw holes;
- decorative radial patterns;
- simple gear-like or flower-like outlines.

### 9.2 `RUN`: reusable child command lists

`RUN` evaluates another command list from the current Logo state:

```scad
slot =
[
    [ROUNDEDRECT, 12, 4, 2]
];

plate =
[
    [RECT, 50, 20],
    [HOLE, [[GOTO, -15, 0, 0], [RUN, slot]]],
    [HOLE, [[GOTO,  15, 0, 0], [RUN, slot]]]
];
```

This is not recursion by itself; it is subroutine-like reuse. The child list can
also be scaled:

```scad
[RUN, slot, 0.5]
```

That runs `slot` at half the current scale.

### 9.3 Nested `RUN`: runtime recursion with a limit

A `RUN` body can itself contain another `RUN`. LogoT has a recursion limit so a
bad command list does not expand forever.

The syntax is:

```scad
[RUN, cmds, scale, maxRec]
```

Where:

- `cmds` is the child command list;
- `scale` multiplies the current scale while the child list runs;
- `maxRec` limits how deeply that `RUN` may recurse.

The default recursion limit is controlled by:

```scad
DefaultRunMaxRecursions = 2;
```

Use an explicit `maxRec` when writing recursive examples or tests. Otherwise the
example may stop earlier than expected.

### 9.4 Recursive OpenSCAD command generators

For most practical recursive geometry, use an OpenSCAD function that returns a
LogoT command list. This is usually cleaner than trying to create
self-referential command vectors.

OpenSCAD self-referential variables are not a reliable foundation for LogoT
programs. Prefer functions where the depth is an ordinary numeric argument:

```scad
function SpiralCmds(depth) =
    (depth <= 0)
        ? []
        :
        [
            [MOVE, 10],
            [TURN, 80],
            [RUN, SpiralCmds(depth - 1), 0.75, depth]
        ];

spiral =
[
    [RUN, SpiralCmds(4), 1.0, 4]
];
```

This combines two mechanisms:

1. The OpenSCAD function builds a finite command tree.
2. LogoT `RUN` evaluates the nested command lists with a runtime recursion guard.

The explicit depth makes the generated command list predictable. The `RUN`
`maxRec` value is the seat belt. It is less dramatic than debugging infinite
recursion in OpenSCAD, which is traditionally how one converts coffee into
regret.

### 9.5 Koch snowflake example

The Koch snowflake is a good example of recursive command-list generation. One
line segment is replaced by four smaller segments:

```text
forward, left 60, forward, right 120, forward, left 60, forward
```

In LogoT, write the segment generator as an OpenSCAD function:

```scad
function KochSegment(depth, len) =
    (depth <= 0)
        ? [[MOVE, len]]
        : concat(
            KochSegment(depth - 1, len / 3),
            [[TURN, 60]],
            KochSegment(depth - 1, len / 3),
            [[TURN, -120]],
            KochSegment(depth - 1, len / 3),
            [[TURN, 60]],
            KochSegment(depth - 1, len / 3)
        );
```

Then build the three sides of the snowflake:

```scad
kochSnowflake =
[
    [REPEAT, 3,
        concat(
            KochSegment(3, 36),
            [[TURN, -120]]
        )
    ]
];
```

Render it as a printable filled profile:

```scad
linear_extrude(height = 1.5, convexity = 10)
{
    RenderLogo2D(kochSnowflake);
}
```

Notes:

- The snowflake path returns to its starting point after the three repeated
  sides.
- `polygon()` closes the path automatically, so the result is a filled region.
- Depth grows quickly: one side has `4^depth` segments, so the full snowflake
  has `3 * 4^depth` segments.
- Depth `3` is already `192` segments. Depth `5` is `3072` segments. OpenSCAD
  will do it, but it may glare at you.

### 9.6 When to use each mechanism

| Mechanism | Use it for | Avoid it when |
|---|---|---|
| `REPEAT` | Fixed repetition with no structural growth | Each iteration needs a different generated body |
| `RUN` | Reusing a named command list at the current state | You only need a simple one-line command |
| `RUN` with scale | Reusing a shape at different sizes | You need nonuniform scaling; LogoT scale is uniform |
| `RUN` with `maxRec` | Nested generated command lists | The same result is simpler with `REPEAT` |
| OpenSCAD recursive functions | Fractals and depth-controlled structures | Simpler explicit commands would be clearer |

For 3D-printing parts, keep recursion depth modest. Fractals are excellent test
cases and decorative features, but dense recursive outlines can generate large
polygons that are slow to preview, render, slice, and print.

## 12. Practical examples

### Example 1: simple extruded plate

```scad
include <LogoT-Foundation-Core.scad>
RunLogoTests = false;

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
include <LogoT-Foundation-Core.scad>
RunLogoTests = false;

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

## 13. Error handling and tracing

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

## 14. Limitations

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

## 15. Suggested style for LogoT programs

Favor relative drawing inside reusable command lists. Use `GOTO` and `DIR` for
layout and setup; use `MOVE`, `TURN`, and `ARC` for the shape body when possible.
See [Relative drawing vs. absolute layout](#51-relative-drawing-vs-absolute-layout).

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

## Index

- [`$fa`](#9-segment-count-controls), [`$fn`](#9-segment-count-controls), [`$fs`](#9-segment-count-controls)
- [`ARC`](#arc)
- [`CHANGELOG.md`](#1-files)
- [`CIRCLE`](#circle)
- [`DIR`](#dir)
- [`evalLogo()`](#evallogocmds)
- [`GOTO`](#goto)
- [`HOLE`](#hole)
- [`LogoT-CheatSheet.md`](#3-quick-lookup-cheat-sheet)
- [`LogoT-Examples.scad`](#4-runnable-examples)
- [`LogoTVersion`](#library-version)
- [`LogoTVersionAtLeast()`](#library-version)
- [`MOVE`](#move)
- [`PENDOWN`](#penup-and-pendown), [`PENUP`](#penup-and-pendown)
- [`POP`](#push-and-pop), [`PUSH`](#push-and-pop)
- [`RECT`](#rect)
- [Relative drawing vs. absolute layout](#51-relative-drawing-vs-absolute-layout)
- [`REGPOLY`](#regpoly)
- [`REPEAT`](#repeat)
- [`RenderContours2D()`](#rendercontours2dregions-convexity-10)
- [`RenderLogo2D()`](#renderlogo2dcmds-convexity-10)
- [`RenderRegion2D()`](#renderregion2dregion-convexity-10)
- [`ResultContours()`](#result-accessors)
- [`ResultPen()`](#result-accessors)
- [`ResultStack()`](#result-accessors)
- [`ResultState()`](#result-accessors)
- [`ROUNDEDRECT`](#roundedrect)
- [`RUN`](#run)
- [`SCALE`](#scale)
- [`TURN`](#turn)
- [Coordinate system](#5-coordinate-model)
- [Error handling](#13-error-handling-and-tracing)
- [Holes and regions](#6-rendering-model)
- [Linear extrusion](#linear-extrusion)
- [OpenSCAD wrappers](#8-3d-printing-workflow)
- [Recursion](#11-recursion-and-recursive-patterns)
- [Rotate extrusion](#rotate-extrusion)
- [Setup](#setup)
- [Test grid and tracing](#13-error-handling-and-tracing)

