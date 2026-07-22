# LogoSC User Manual

![LogoSC wordmark](images/logosc-wordmark.png)

LogoSC is a small Logo-style geometry language embedded in OpenSCAD. It evaluates
integer-opcode command lists into closed 2D regions that can be rendered with
OpenSCAD `polygon(points=..., paths=...)` and then used directly in ordinary
OpenSCAD modeling operations.

LogoSC is designed primarily for 3D-printable 2D profiles: plates, panels,
washers, outlines, rounded rectangles, decorative regions, and profiles that can
be passed to `linear_extrude()` or `rotate_extrude()`.

## Table of Contents

- [1. Files and setup](#1-files)
  - [Setup](#setup)
  - [Library version](#library-version)
- [2. Quick Start](#2-quick-start)
- [3. Core idea](#3-core-idea)
  - [LogoSC and BOSL2 turtle](#logosc-and-bosl2-turtle)
  - [Other Logo-like OpenSCAD turtle tools](#other-logo-like-openscad-turtle-tools)
- [Quick lookup cheat sheet](#quick-lookup-cheat-sheet)
- [4. Runnable examples](#4-runnable-examples)
- [5. Coordinate model](#5-coordinate-model)
- [6. Rendering model](#6-rendering-model)
- [7. Public rendering and evaluation API](#7-public-rendering-and-evaluation-api)
  - [Input command-list format](#71-input-command-list-format)
  - [Public data formats](#72-public-data-formats)
  - [`RenderLogo2D()`](#73-renderlogo2d)
  - [`evalLogo()`](#74-evallogo)
  - [Evaluator-result accessors](#75-evaluator-result-accessors)
  - [Region constructor and accessors](#76-region-constructor-and-accessors)
  - [`RenderContours2D()`](#77-rendercontours2d)
  - [`RenderRegion2D()`](#78-renderregion2d)
  - [Choosing an entry point](#79-choosing-an-entry-point)
  - [Debug visualization](#710-debug-visualization)
  - [Path analysis and validation](#711-path-analysis-and-validation)
  - [OpenSCAD wrapper pattern](#712-openscad-wrapper-pattern)
- [8. 3D printing workflow](#8-3d-printing-workflow)
- [9. Segment-count controls](#9-segment-count-controls)
- [10. Command reference](#10-command-reference)
- [11. Recursion and recursive patterns](#11-recursion-and-recursive-patterns)
- [12. Practical examples](#12-practical-examples)
- [13. Error handling and tracing](#13-error-handling-and-tracing)
  - [Automated test summaries](#automated-test-summaries)
- [14. Limitations](#14-limitations)
- [15. Suggested style for LogoSC programs](#15-suggested-style-for-logosc-programs)
- [Index](#index)

## 1. Files

Current tracked project files and directories:

```text
README.md                          Repository landing page.
CHANGELOG.md                       Release history.
LICENSE                            MIT License.
CONTRIBUTING.md                    Contribution and maintenance guidelines.
AGENTS.md                          Compact repository-specific Codex guidance.
.gitattributes                     LF line-ending policy for Git.
.gitignore                         Repository ignore rules.

docs/ai-engineering-kit/           Maintainer-facing AI workflow and handoff documents.

LogoSC-Foundation-Core.scad        Standalone interpreter, geometry, and renderers.
LogoSC-Foundation-Validation.scad  Optional explicit-path evaluator and validator.
LogoSC-Foundation-Tests.scad       Passive regression and visual-test definitions.
LogoSC-Foundation-Validation-Tests.scad Passive focused validation tests.
LogoSC-Foundation-Test-Runner.scad Direct entry point for the complete test suite.
LogoSC-Examples.scad               Runnable example gallery.
LogoSC-Nuts-And-Bolts.scad         Customizable printable fastener model.
LogoSC-Nuts-And-Bolts-Customizer.md Detailed fastener Customizer guide.
LogoSC-Experiments.scad            Experimental rendering and geometry workbench.
LogoSC-OpenSCAD-Command-Line.md    Command-line testing, export, and PNG-preview guide.

LogoSC-README.md                   Detailed project overview and roadmap.
LogoSC-User-Manual.md              This manual.
LogoSC-CheatSheet.md               Compact command and API reference.
LogoSC-Developer-Notebook.md       Engineering history, design rationale, workflow,
                                  lessons learned, and ChatGPT restart guide.
LogoSC-Future-Ideas.md             Longer-term feature concepts and future directions.

LogoSC-ARC-Implementation.md        ARC tessellation design notes.
LogoSC-Holes-Implementation.md     Region/hole design notes.
LogoSC-LSystems-Notes.md           L-system design and example notes.

images/                            Documentation wordmark, icon, and screenshots.
```

Contributors should read [CONTRIBUTING.md](CONTRIBUTING.md) before preparing changes.
It summarizes the project's API-stability, coding, documentation, testing, versioning,
and packaging expectations. Significant design rationale remains in
`LogoSC-Developer-Notebook.md`, while longer-term concepts belong in
`LogoSC-Future-Ideas.md`.

The six AI Engineering Kit files are maintainer-facing companion records stored under
`docs/ai-engineering-kit/` by explicit user request. They help future AI-assisted
development sessions preserve collaboration style and engineering preferences, but they
do not define LogoSC APIs or user-facing behavior. The short
`Codex-Git-Project-Quick-Start.md` explains local Git workspace setup. Ordinary LogoSC users
can ignore the kit.

### Setup

For normal use, put the standalone LogoSC core file next to your model and
include it from OpenSCAD. No test or optional companion file is required:

```scad
include <LogoSC-Foundation-Core.scad>
TraceLevel = 0; // [0:4]
```

The Developer Notebook is maintainer documentation rather than part of the
public API. Its main purpose is to preserve historical engineering context
and reinitialize ChatGPT when development resumes in a new conversation.
Maintainers should read it before changing the project; ordinary LogoSC users
can ignore it.

`TraceLevel` should come **after** the `include`. OpenSCAD `include`
behaves like textual insertion, so post-include assignments override the core
file's defaults.

`LogoSCRunMode` is the preferred top-level selector for example/demo/test files:

| Value | Meaning |
|---|---|
| `NoDemo` | Suppress automatic examples, debug demos, and tests when you want an explicit no-output mode. |
| `""` | Also suppress automatic examples, debug demos, and tests. Useful when you want an explicit blank state. |
| `Examples` | Render the example gallery when using `LogoSC-Examples.scad`. |
| `Debug` | Render the indexed debug-visualization gallery when using `LogoSC-Examples.scad`. |
| `Tests` | Render the regression-test grid. |

The examples file runs the complete suite only when `LogoSCRunMode` is set to
`"Tests"`. The dedicated test runner executes the same Foundation and Validation suites
directly. Ordinary user
models can usually omit `LogoSCRunMode` entirely; use `"NoDemo"` or a blank
string only when you want an explicit no-output selector.

For ordinary 2D output, wrap a LogoSC command list with:

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

To run the built-in tests directly, open:

```text
LogoSC-Foundation-Test-Runner.scad
```

Alternatively, open `LogoSC-Examples.scad` and set:

```scad
LogoSCRunMode = "Tests";
```

Core never loads or executes the test definitions. This keeps basic LogoSC use
dependent on one file while preserving the test grid through explicit entry points.

For optional path analysis and validation, include Core first and then its companion:

```scad
include <LogoSC-Foundation-Core.scad>
include <LogoSC-Foundation-Validation.scad>
```

The companion is not required by ordinary rendering models.

Maintainers can also run the suite without opening the GUI. See
[Running LogoSC from the OpenSCAD Command Line](LogoSC-OpenSCAD-Command-Line.md)
for tested PowerShell commands, diagnostic capture, geometry export, PNG previews,
and links to the complete OpenSCAD command-line manual.

The runnable gallery in `LogoSC-Examples.scad` follows the same include pattern
and is a good starting point for user models.

### Library version

Current public API version: `2026.2`.

The core file exposes version constants and a helper for user-model compatibility
checks:

```scad
LogoSCVersionMajor
LogoSCVersionMinor
LogoSCVersion
LogoSCVersionAtLeast(major, minor)
```

Example:

```scad
assert(LogoSCVersionAtLeast(2026, 2), "This model requires LogoSC 2026.2+");
```

The version is bumped manually for public API or feature milestones. Git remains
the source of truth for ordinary commit-by-commit source history.

## 2. Quick Start

### Your First LogoSC Program

The simplest Logo programs are written using only forward movement and turns. The following program draws an equilateral triangle.

```scad
include <LogoSC-Foundation-Core.scad>

TraceLevel = 0;

triangle =
[
    [MOVE, 40],
    [TURN, 120],
    [MOVE, 40],
    [TURN, 120],
    [MOVE, 40]
];

RenderLogo2D(triangle);
```

**Result**

![Figure 2-1](images/quickstart-triangle.png)

*Figure 2-1. Three `MOVE` commands and two `TURN` commands produce a filled equilateral triangle. LogoSC generates closed 2D polygonal regions suitable for OpenSCAD modeling operations.*

Although the turtle walks only three line segments, **LogoSC produces a filled equilateral triangle**, not just three independent lines.

> **Debug tip:** `RenderLogoDebug()` can overlay colored capsules and point markers on this same command list. It is useful when you need to see the actual turtle path rather than only the filled polygon result.

To inspect the same triangle path, render the filled output and the debug overlay together:

```scad
linear_extrude(height = 4, center = true, convexity = 10)
{
    RenderLogo2D(triangle);
}

RenderLogoDebug(
    triangle,
    segmentRadius = 0.15,
    pointRadius = 0.30,
    segmentHeight = 5,
    pointHeight = 7
);
```

The debug view is especially useful for detecting crossing lines and unclosed
polygons. If the red end marker does not return to the lime start marker, the
filled result may still close because OpenSCAD polygons are implicitly closed,
but the command path itself is open.

### Beyond Classic Logo

Classic Logo approximates curves using many short line segments.

LogoSC also provides CAD-oriented primitives including circles, arcs, regular polygons, rectangles, rounded rectangles, and holes.

```scad
part =
[
    [RECT, 60, 30],
    [HOLE, [[CIRCLE, 5]]]
];

RenderLogo2D(part);
```

**Result**

![Figure 2-2](images/quickstart-plate-hole.png)

*Figure 2-2. Two LogoSC commands generate a rectangular plate with a centered circular hole suitable for extrusion into a 3D-printable part.*


## 3. Core idea

A LogoSC program is an OpenSCAD vector of command vectors:

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

LogoSC intentionally renders **2D regions only**. It does not wrap
`linear_extrude()`, `rotate_extrude()`, `difference()`, or `union()`. Keeping
those operations outside LogoSC keeps the API small and lets OpenSCAD do normal
OpenSCAD work.

### LogoSC and BOSL2 turtle

LogoSC overlaps slightly with BOSL2's turtle/path tools, but the two projects
optimize for different jobs.

BOSL2 is a broad OpenSCAD utility library with extensive shape, path, region,
attachment, and 3D modeling tools, including turtle-style path helpers. Get
BOSL2 from the [BelfrySCAD/BOSL2 GitHub repository](https://github.com/BelfrySCAD/BOSL2),
or from the [OpenSCAD Libraries page](https://openscad.org/libraries.html).

LogoSC is deliberately narrower. It evaluates compact Logo-style command lists
into closed 2D regions suitable for `polygon(points=..., paths=...)`, holes,
`linear_extrude()`, `rotate_extrude()`, `offset()`, and ordinary OpenSCAD
composition.

Use BOSL2 when you want its large general-purpose modeling toolkit, attachment
system, path utilities, or 3D turtle workflows. Use LogoSC when you want a small,
self-contained 2D region generator for reusable plate, panel, washer, outline,
and profile geometry. They can coexist in the same OpenSCAD model because LogoSC
returns normal OpenSCAD 2D geometry rather than owning the whole modeling stack.

### Other Logo-like OpenSCAD turtle tools

The OpenSCAD ecosystem has several turtle-graphics or Logo-like experiments.
Most are path generators, drawing helpers, tutorials, or broader CAD libraries
rather than direct substitutes for LogoSC's small 2D-region-and-hole workflow.

| Tool | Where to find it | Plus, relative to LogoSC | Minus, relative to LogoSC |
|---|---|---|---|
| BOSL2 `turtle()` / `turtle3d()` | [BelfrySCAD/BOSL2](https://github.com/BelfrySCAD/BOSL2) | Mature, broad OpenSCAD toolkit; strong path, region, attachment, and 3D workflows. | Larger dependency; optimized for BOSL2 path/modeling workflows rather than a small standalone LogoSC region DSL. |
| StoneAgeLib `turtle.scad` | [Stone-Age-Sculptor/StoneAgeLib](https://github.com/Stone-Age-Sculptor/StoneAgeLib) | Practical 3D-printing library; public-domain/CC0 licensing; turtle usage is described as similar to Python Turtle. | Part of a broader evolving library; not focused on LogoSC's closed-region, hole, and compact command-list API. |
| `phildubach/openscad-turtle` | [phildubach/openscad-turtle](https://github.com/phildubach/openscad-turtle) | Interesting CAD-style commands for lines, arcs, elastic lines, and references to stored prior turtle states. | Small GPL-3.0 project; less evidence of adoption; path construction rather than LogoSC-style filled regions with holes. |
| JustinSDK TurtleSCAD | [JustinSDK/TurtleSCAD](https://github.com/JustinSDK/TurtleSCAD) | Pure OpenSCAD turtle-graphics implementation with example models; historically relevant. | Archived/read-only; no releases; not a current foundation for new LogoSC work. |
| Kit Wallace `turtle.scad` examples | [Turtle Graphics in OpenSCAD](https://www.tumblr.com/kitwallace/112087448494/turtle-graphics-in-openscad) | Compact classic-Logo flavor; useful educational example of recursive OpenSCAD turtle command lists. | Tutorial/demo scale; older and not framed as a maintained LogoSC-like CAD-region library. |
| OpenHome 2D/3D turtle articles | [2D turtle graphics](https://openhome.cc/eGossip/OpenSCAD/TurtleGraphics.html) and [3D turtle graphics](https://openhome.cc/eGossip/OpenSCAD/3DTurtleGraphics.html) | Good implementation notes for turtle state, immutability, and coordinate-frame reasoning in OpenSCAD. | Article/example code rather than a packaged library; not aimed at LogoSC's reusable region primitives. |
| TheHans L-system gist | [L-system implementation in OpenSCAD](https://gist.github.com/thehans/a1494db8046a58832e2ebb10a5908a66) | Useful example of turtle interpretation with stack-style `[` / `]` branching for fractals and plant-like forms. | Specialized L-system interpreter, not a general Logo-style CAD geometry API. |

The practical conclusion is that LogoSC does not need to become a general BOSL2
competitor or a complete Logo clone. Its useful niche is a small, readable,
Git-friendly OpenSCAD mini-language that produces printable 2D regions and
region holes, then gets out of OpenSCAD's way.


## Quick lookup cheat sheet

`LogoSC-CheatSheet.md` is the compact reference for command syntax, rendering
API calls, and common OpenSCAD wrappers used around LogoSC output. Use it while
writing models; return to this manual for full explanations and examples.

## 4. Runnable examples

`LogoSC-Examples.scad` is the best place to see the library used as an OpenSCAD
modeling tool rather than as a test harness. It contains a gallery module plus
individual named examples for washers, mounting plates, radial holes, Koch
snowflake geometry, L-system-generated fractal outlines, rotate-extruded
profiles, twisted extrusions, a small spiral tower, and the LogoSC feature
wordmark.

![Figure 4-1](images/examples-gallery.png)

*Figure 4-1. The Examples gallery combines basic shapes, holes, native OpenSCAD linear and
rotational extrusions, and recursive L-system-inspired models.*

Open `LogoSC-Examples.scad` directly in OpenSCAD. The top-level Customizer
selector controls what is rendered:

```scad
LogoSCRunMode = "Examples"; // [NoDemo, Examples, Debug, Tests]
```

Use `Examples` for the gallery, `Debug` for the debug-visualization demo,
`Tests` for the regression grid, and `NoDemo` for no automatic preview output.

The examples file includes Core plus the passive tests so every interactive run
mode remains available. It selects the normal gallery by default and keeps routine
example previews quiet unless tracing is explicitly raised:

```scad
include <LogoSC-Foundation-Core.scad>
include <LogoSC-Foundation-Tests.scad>
LogoSCRunMode = "Examples"; // [NoDemo, Examples, Debug, Tests]
TraceLevel = 0; // [0:4]
```

Use it as a cookbook: copy a command list such as `ExampleMountingPlate`, or use
one of the example rendering modules as a starting point for your own model.
For the L-system examples, see `LogoSC-LSystems-Notes.md` for design context
and limitations.

Open `LogoSC-Nuts-And-Bolts.scad` for a more complete manufacturing example. Its Customizer
selects bolt, nut, assembly, profile, or gallery output; common metric and Unified sizes; six thread
profile families; right- or left-hand threads; multiple starts; independent head, drive, and
drive-size options; length; printable clearance; and mesh resolution. The profiles are practical
printable approximations rather than certified standard tolerance classes. See
`LogoSC-Nuts-And-Bolts-Customizer.md` for the detailed parameter and drive-preset guide and its
prominent warning about the unknown strength of printed fasteners.

## 5. Coordinate model

LogoSC maintains a current state:

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

LogoSC uses OpenSCAD's right-handed coordinate system. In the standard LogoSC
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

LogoSC evaluates command lists into structured 2D data rather than emitting
OpenSCAD geometry while each command executes. The public data hierarchy is:

```text
EvalResult
└── regions
    ├── region
    │   ├── outer contour
    │   └── zero or more hole contours
    └── ...
```

Section 7 defines these formats precisely, documents the accessors, and explains
which rendering entry point to use. The essential distinction is:

- evaluation functions return OpenSCAD values that can be inspected or reused;
- rendering modules emit 2D OpenSCAD geometry and do not return a value.

LogoSC currently targets closed printable 2D polygons for final geometry.
OpenSCAD `polygon()` closes drawable paths automatically. `RenderLogoDebug()` is
provided for preview-only path inspection, but manufacturable stroke width, end
caps, joins, and miter limits are future work.

## 7. Public rendering and evaluation API

LogoSC separates evaluation from rendering:

```text
command list
    │
    ▼
evalLogo()
    │
    ▼
EvalResult = [state, regions, stack, pen]
                         │
                         ▼
              RenderContours2D()
```

`RenderLogo2D()` is the normal convenience entry point. It performs both stages:

```text
RenderLogo2D(cmds) = RenderContours2D(ResultContours(evalLogo(cmds)))
```

Use the lower-level functions when generated geometry must be inspected,
transformed as data, tested, cached in a variable, or rendered more than once.

### 7.1 Input command-list format

The input to `RenderLogo2D()` and `evalLogo()` is an OpenSCAD list of LogoSC
commands:

```scad
cmds =
[
    [GOTO, -20, -10, 0],
    [MOVE, 40],
    [TURN, 90],
    [MOVE, 20],
    [TURN, 90],
    [MOVE, 40],
    [TURN, 90],
    [MOVE, 20]
];
```

Each command is itself a list whose first field is an integer opcode constant.
Later fields are command arguments. The command reference in Section 10 defines
each command's exact shape and optional arguments.

An empty command list is legal and evaluates as a no-op:

```scad
result = evalLogo([]);
```

### 7.2 Public data formats

#### Point and contour

A point is a two-element coordinate vector:

```text
point = [x, y]
```

A contour is an ordered list of points:

```text
contour = [point0, point1, point2, ...]
```

A contour requires at least three points to render as a polygon path. The final
point does not need to repeat the first point; OpenSCAD closes the path.

#### Region

A region contains one outer contour followed by zero or more hole contours:

```text
region = [outerContour, holeContour0, holeContour1, ...]
```

Examples:

```scad
solidRegion =
[
    [[0, 0], [40, 0], [40, 20], [0, 20]]
];

regionWithHole =
[
    [[0, 0], [40, 0], [40, 20], [0, 20]],
    [[10, 5], [10, 15], [30, 15], [30, 5]]
];
```

Each region is rendered by one OpenSCAD `polygon()` call with a flattened point
list and one path per drawable contour. When constructing regions manually, the
contours must describe valid, non-self-intersecting polygon boundaries suitable
for OpenSCAD `polygon(points=..., paths=...)`.

#### Region list

The evaluator returns a list of regions:

```text
regions = [region0, region1, ...]
```

For example:

```scad
regions =
[
    [outerContour0, holeContour0, holeContour1],
    [outerContour1]
];
```

The evaluator may retain an empty working region such as `[[]]`, commonly at the
end of a result after a stamped closed shape. This is valid. Rendering modules
skip an empty outer contour. User code should therefore inspect drawable
contours rather than assuming every region contains geometry.

#### Logo state

A Logo state is:

```text
state = [x, y, heading, scale]
```

The public field-index constants are:

```scad
state[SX]  // x coordinate
state[SY]  // y coordinate
state[SH]  // heading in degrees
state[SS]  // cumulative movement scale
```

The default initial state is equivalent to:

```scad
stateGoto(0, 0, 0, 1)
```

Headings use the coordinate and turn conventions described in Section 5.

#### State stack

The stack is a list of saved Logo states used by `PUSH` and `POP`:

```text
stack = [savedState0, savedState1, ...]
```

The last element is the top of the stack. A normal, balanced command list
usually returns an empty stack. A nonempty final stack is legal and can be useful
for diagnostics, although it often indicates unmatched `PUSH` commands.

#### Pen state

The pen state is one of the public constants:

```scad
PEN_UP
PEN_DOWN
```

`PEN_DOWN` is the default. `ResultPen()` reports the state after the final
command.

#### Evaluator result

`evalLogo()` returns a four-element evaluator result:

```text
EvalResult = [finalState, regions, finalStack, finalPen]
```

Do not depend on the numeric field positions. Use the result accessors described
below.

### 7.3 `RenderLogo2D()`

Main user-facing rendering module:

```scad
RenderLogo2D(cmds, convexity = 10);
```

| Parameter | Format | Meaning |
|---|---|---|
| `cmds` | command list | Commands to evaluate from the default initial state. |
| `convexity` | integer | Preview hint passed unchanged to OpenSCAD `polygon()`. Does not alter LogoSC geometry. |

The module emits 2D OpenSCAD geometry. It does not return the `EvalResult`.
Multiple regions are emitted as sibling polygon objects and behave as their
geometric union when consumed by ordinary OpenSCAD modeling operations.

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

Use `convexity` as an OpenSCAD preview aid; it does not change the evaluated
point data or the mathematical shape.

#### About the `convexity` parameter

The `convexity` parameter is passed unchanged to OpenSCAD's `polygon()` module.
It does **not** change the geometry generated by LogoSC. Instead, it is a preview
hint used by OpenSCAD's **Preview (F5)** renderer.

In OpenSCAD terminology, `convexity` is an upper bound on the number of
front-facing polygon surfaces that a viewing ray may intersect. This helps the
preview renderer determine visible surfaces for complex models. It does **not**
affect the final CGAL render (**F6**) or exported STL files.

For most LogoSC models, the default value:

```scad
convexity = 10;
```

is appropriate.

Increase it only if Preview (F5) shows missing faces or other display artifacts
for unusually complex geometry, such as deeply nested boolean operations,
multiple overlapping extrusions, or highly concave models.

Changing `convexity` does **not** affect:

- LogoSC-generated points
- Polygon topology
- Tessellation quality
- Exported STL files
- Final CGAL rendering (F6)

Unless you encounter Preview artifacts, simply leave the default at **10**.


### 7.4 `evalLogo()`

Evaluates a command list without emitting geometry:

```scad
result = evalLogo(cmds);
```

Normal user code should pass only `cmds`. The complete signature is exposed for
advanced continuation and evaluator testing:

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

| Parameter | Format | Meaning |
|---|---|---|
| `cmds` | command list | Command list being evaluated. |
| `state` | Logo state | Initial or continuation state. |
| `index` | integer | First command index to execute. Normally `0`. |
| `maxRec` | integer | Remaining `RUN` recursion allowance. |
| `contours` | region list | Existing geometry to append to. |
| `stack` | state list | Existing `PUSH`/`POP` stack. |
| `pen` | pen constant | Initial or continuation pen state. |

The returned value is:

```text
[finalState, regions, finalStack, finalPen]
```

The extended parameters are primarily evaluator plumbing. For ordinary staged
evaluation, pass the prior result through the accessors:

```scad
first = evalLogo(firstCmds);

second = evalLogo(
    secondCmds,
    ResultState(first),
    0,
    maxRunRecursions,
    ResultContours(first),
    ResultStack(first),
    ResultPen(first)
);
```

This continues position, heading, scale, regions, stack, and pen state. Starting
a fresh `evalLogo(secondCmds)` call would instead reset all of them to defaults.

### 7.5 Evaluator-result accessors

Use these functions instead of indexing an `EvalResult` directly:

```scad
finalState = ResultState(result);
regions    = ResultContours(result);
finalStack = ResultStack(result);
finalPen   = ResultPen(result);
```

| Accessor | Return format | Meaning |
|---|---|---|
| `ResultState(result)` | `[x, y, heading, scale]` | State after the last evaluated command. |
| `ResultContours(result)` | region list | All accumulated outer and hole contours. |
| `ResultStack(result)` | list of states | Remaining `PUSH`/`POP` stack. |
| `ResultPen(result)` | `PEN_UP` or `PEN_DOWN` | Final pen state. |

`ResultContours()` retains its historical name for source continuity. It returns
regions, not the older flat list of independent contours.

Example inspection:

```scad
result = evalLogo(part);
state = ResultState(result);

finalX       = state[SX];
finalY       = state[SY];
finalHeading = state[SH];
finalScale   = state[SS];

regions = ResultContours(result);
echo(finalX, finalY, finalHeading, finalScale, len(regions));
```

### 7.6 Region constructor and accessors

These functions are the supported way to construct or inspect a region without
assuming its internal indexing:

```scad
region = MakeRegion(outerContour, holeContours = []);
outer  = RegionOuter(region);
holes  = RegionHoles(region);
```

| Function | Return format | Meaning |
|---|---|---|
| `MakeRegion(outerContour, holeContours = [])` | region | Builds one region from an outer contour and a list of hole contours. |
| `RegionOuter(region)` | contour | Returns the first contour, or `[]` for an empty region. |
| `RegionHoles(region)` | list of contours | Returns all contours after the outer contour. |

Example:

```scad
outer = [[0, 0], [50, 0], [50, 30], [0, 30]];
hole  = [[10, 10], [10, 20], [40, 20], [40, 10]];

region = MakeRegion(outer, [hole]);
assert(RegionOuter(region) == outer);
assert(RegionHoles(region) == [hole]);
```

The lower-level mutation and polygon-path conversion helpers in the core file
are implementation details rather than stable public data-access APIs.

### 7.7 `RenderContours2D()`

Renders an already-evaluated region list:

```scad
RenderContours2D(regions, convexity = 10);
```

| Parameter | Format | Meaning |
|---|---|---|
| `regions` | region list | Evaluated or manually constructed regions. |
| `convexity` | number | Passed to each generated `polygon()` call. |

Typical evaluate-once use:

```scad
result = evalLogo(part);
regions = ResultContours(result);

translate([-50, 0])
{
    RenderContours2D(regions);
}

translate([50, 0])
{
    offset(r = 1)
    {
        RenderContours2D(regions);
    }
}
```

This avoids evaluating the same command list twice. It does not clone or alter
the input regions.

### 7.8 `RenderRegion2D()`

Renders exactly one region:

```scad
RenderRegion2D(region, convexity = 10);
```

The input must have the form:

```text
[outerContour, holeContour0, holeContour1, ...]
```

An empty outer contour emits no geometry. An outer contour containing one or two
points emits an error marker for diagnostics because it cannot form a polygon.
This module is mainly useful for tests, custom region filtering, and debugging.

```scad
result = evalLogo(part);
regions = ResultContours(result);

for (region = regions)
{
    if (len(RegionOuter(region)) >= 3)
    {
        RenderRegion2D(region);
    }
}
```

### 7.9 Choosing an entry point

| Need | Use |
|---|---|
| Evaluate and render a normal LogoSC model | `RenderLogo2D()` |
| Inspect final state, stack, pen, or point data | `evalLogo()` plus accessors |
| Evaluate once and render several times | `evalLogo()` then `RenderContours2D()` |
| Render manually generated region data | `RenderContours2D()` |
| Render or inspect one selected region | `RenderRegion2D()` |
| Inspect command-path order, crossings, pen-up motion, and endpoints | `RenderLogoDebug()` |
| Analyze explicit paths or basic integrity | `evalLogoPaths()` or `ValidateLogoPaths()` |
| Construct or inspect a region as data | `MakeRegion()`, `RegionOuter()`, `RegionHoles()` |

### 7.10 Debug visualization

`RenderLogoDebug()` renders a preview-only 3D diagnostic overlay for a LogoSC
command list:

```scad
RenderLogoDebug(cmds);
```

It records command/evaluation events directly instead of reconstructing geometry
from the final region contours. That matters because final `polygon()` output can
hide the path order that produced the shape. The debug renderer draws:

- colored capsules for `MOVE`, `GOTO`, `ARC`, and primitive-generated segments;
- pale pink capsules for pen-up movement when `showPenUpMoves = true`;
- point-marker cylinders at command points;
- lime start markers and red end markers.

The debug geometry is z-centered. Increasing the capsule or point height makes
it protrude through a normal extruded `RenderLogo2D()` preview without requiring
extra Z translations.

Typical overlay pattern:

```scad
cmds =
[
    [MOVE, 30],
    [TURN, 120],
    [MOVE, 30],
    [TURN, 120],
    [MOVE, 30]
];

linear_extrude(height = 4, center = true, convexity = 10)
{
    RenderLogo2D(cmds);
}

RenderLogoDebug(
    cmds,
    segmentRadius = 0.15,
    pointRadius = 0.30,
    segmentHeight = 5,
    pointHeight = 7
);
```

Use the debug overlay when filled output looks surprising. The most common cases
are crossing lines and unclosed contours.

**Crossing lines / self-intersections.** A polygon with points in the wrong order
can cross itself. The filled result may look invalid, ambiguous, or simply wrong.
The debug capsules show the actual point-to-point order, making swapped corners
or unexpected traversal order visible before you chase the wrong problem.

**Unclosed polygons.** OpenSCAD `polygon()` closes each path automatically. That
means a LogoSC contour whose turtle endpoint does not return to its start point
can still produce a filled shape. The debug overlay shows this clearly: the red
end marker will not sit on the lime start marker, and the implicit closing edge
is not shown as a command segment because the turtle did not actually draw it.

**Primitive placement.** Closed primitives such as `CIRCLE`, `RECT`,
`ROUNDEDRECT`, and `REGPOLY` are stamped at the current turtle state. The debug
primitive color makes their generated edges visible and helps distinguish a
centered primitive from a hand-walked turtle polygon.

In `LogoSC-Examples.scad`, set:

```scad
LogoSCRunMode = "Debug";
```

`DebugDemoLayout = "Gallery"` renders all eight cases in a four-column by two-row
grid with distinct logical indexes and offsets. Set `DebugDemoLayout = "Selected"`
to inspect only `DebugDemoExample`. The available cases are the closed triangle,
open triangle, crossed rectangle, ordinary rectangle, pen-up gap, arc loop,
stroke-vs-primitive triangle, and primitive demos.

![Figure 7-1](images/debug-renderer-gallery.png)

*Figure 7-1. The indexed Debug gallery overlays filled examples with movement capsules and
point markers so endpoints, crossings, pen-up travel, arcs, and primitive paths remain visible.*

`DebugDemoOverlay` toggles the debug capsules and points; `DebugDemoFilled`
toggles the filled 2D preview.

`RenderLogoDebug()` is not intended to produce STL-ready geometry. It is a visual
inspection tool. For final parts, continue to use `RenderLogo2D()` plus native
OpenSCAD operations.

### 7.11 Path analysis and validation

`LogoSC-Foundation-Validation.scad` is an optional companion that evaluates the
command stream into explicit drawable paths and checks basic path integrity. Include
Core before it:

```scad
include <LogoSC-Foundation-Core.scad>
include <LogoSC-Foundation-Validation.scad>

openTriangle =
[
    [MOVE, 10],
    [TURN, 120],
    [MOVE, 10]
];

validation = ValidateLogoPaths(openTriangle);
echo("valid", ValidationIsValid(validation));
echo("issues", ValidationIssues(validation));
ReportLogoValidation(openTriangle);
```

`evalLogoPaths(cmds)` returns `[state, paths, stack, pen]`. Use
`PathResultState()`, `PathResultPaths()`, `PathResultStack()`, and
`PathResultPen()` to inspect it. Each path records:

```text
[role, kind, points, sourceOpcode, explicitlyClosed]
```

Use `PathRole()`, `PathKind()`, `PathPoints()`, `PathSourceOpcode()`,
`PathIsExplicitlyClosed()`, `PathStart()`, `PathEnd()`, `PathPointCount()`,
`PathSegmentCount()`, `PathVertexCount()`, and `PathIsClosed()` to inspect a path.
Roles distinguish `LOGO_PATH_ROLE_OUTER` from `LOGO_PATH_ROLE_HOLE`; kinds distinguish
`LOGO_PATH_KIND_TURTLE` from `LOGO_PATH_KIND_PRIMITIVE`.

`ValidateLogoPaths(cmds, tolerance = 0.001)` returns the path result, issue list,
and applied tolerance. Its accessors are `ValidationPathResult()`,
`ValidationPaths()`, `ValidationIssues()`, `ValidationTolerance()`, and
`ValidationIsValid()`. Each issue is `[pathIndex, issueCode]`, inspected with
`ValidationIssuePathIndex()`, `ValidationIssueCode()`, and `ValidationIssueName()`.
Current issue codes are:

- `LOGO_VALIDATION_OPEN_PATH`
- `LOGO_VALIDATION_TOO_FEW_POINTS`
- `LOGO_VALIDATION_ZERO_LENGTH_SEGMENT`

`ReportLogoValidation(cmds, tolerance = 0.001, strict = false)` echoes readable
warnings. Set `strict = true` to assert after reporting when issues exist.

Validation is deliberately opt-in. It does not alter `evalLogo()`, `RenderLogo2D()`,
or OpenSCAD's implicit closing edge. Explicit path evaluation preserves initial
turtle points, `PENUP`/`PENDOWN` boundaries, primitive paths, and hole roles—details
that cannot be inferred reliably from the filled-region result alone.

The current suite does not detect self-intersections, tiny nonzero edges, duplicate
nonconsecutive points, hole containment, or hole overlap.

### 7.12 OpenSCAD wrapper pattern

LogoSC intentionally remains a 2D geometry generator. Wrap its output with native
OpenSCAD modules for final modeling:

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
`RenderContours2D()` for an already-evaluated region list.

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

If the segment count is omitted, LogoSC uses OpenSCAD-style automatic fragment
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
circle. `CIRCLE` means something different in LogoSC.

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

Important: this is not the classic Logo circle behavior. In LogoSC,
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

LogoSC does not currently validate whether holes are fully inside the outer
region, whether holes overlap, or whether regions are self-intersecting. Keep
geometry sane; CGAL is not a therapist.

### `RUN`

Syntax:

```scad
[RUN, cmds[, scale[, maxRec]]]
```

Evaluates a child command list from the current state.

The optional `scale` multiplies the child execution scale. The optional `maxRec`
limits nested `RUN` recursion. See [Section 11](#11-recursion-and-recursive-patterns)
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

LogoSC uses the word "recursion" in a few related but distinct ways. They are
worth separating because they have different costs and different failure modes.

### 11.1 `REPEAT`: bounded repetition

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

### 11.2 `RUN`: reusable child command lists

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

### 11.3 Nested `RUN`: runtime recursion with a limit

A `RUN` body can itself contain another `RUN`. LogoSC has a recursion limit so a
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

### 11.4 Recursive OpenSCAD command generators

For most practical recursive geometry, use an OpenSCAD function that returns a
LogoSC command list. This is usually cleaner than trying to create
self-referential command vectors.

OpenSCAD self-referential variables are not a reliable foundation for LogoSC
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
2. LogoSC `RUN` evaluates the nested command lists with a runtime recursion guard.

The explicit depth makes the generated command list predictable. The `RUN`
`maxRec` value is the seat belt. It is less dramatic than debugging infinite
recursion in OpenSCAD, which is traditionally how one converts coffee into
regret.

### 11.5 Koch snowflake example

The Koch snowflake is a good example of recursive command-list generation. One
line segment is replaced by four smaller segments:

```text
forward, left 60, forward, right 120, forward, left 60, forward
```

In LogoSC, write the segment generator as an OpenSCAD function:

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

### 11.6 When to use each mechanism

| Mechanism | Use it for | Avoid it when |
|---|---|---|
| `REPEAT` | Fixed repetition with no structural growth | Each iteration needs a different generated body |
| `RUN` | Reusing a named command list at the current state | You only need a simple one-line command |
| `RUN` with scale | Reusing a shape at different sizes | You need nonuniform scaling; LogoSC scale is uniform |
| `RUN` with `maxRec` | Nested generated command lists | The same result is simpler with `REPEAT` |
| OpenSCAD recursive functions | Fractals and depth-controlled structures | Simpler explicit commands would be clearer |

For 3D-printing parts, keep recursion depth modest. Fractals are excellent test
cases and decorative features, but dense recursive outlines can generate large
polygons that are slow to preview, render, slice, and print.

## 12. Practical examples

### Example 1: simple extruded plate

```scad
include <LogoSC-Foundation-Core.scad>

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
include <LogoSC-Foundation-Core.scad>

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

LogoSC defaults to soft errors:

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

### Automated test summaries

`LogoSC-Foundation-Test-Runner.scad` and the Examples `Tests` mode collect each automated
test as immutable `[name, passed, detail]` data. Those records form a Foundation suite and
a Validation suite; the complete runner examines both suite records at the end.

The default reporting level is:

```scad
LogoTestReportLevel = 1; // [0:2]
LogoTestFailFast = false;
```

- Level `0` prints only the global result.
- Level `1` prints every suite summary and the name and details of every failed test.
- Level `2` additionally prints every passing test name.

A successful run ends with output equivalent to:

```text
LogoSC suite result, Foundation, PASS, tests, 130, passed, 130, failed, 0
LogoSC suite result, Validation, PASS, tests, 21, passed, 21, failed, 0
LOGOSC_AUTOMATED_TEST_RESULT, PASS, suites, 2, failedSuites, 0, tests, 151, passed, 151, failed, 0
```

Counts grow as tests are added; use the final `PASS`/`FAIL` value rather than hard-coding
today's totals. A failing run continues through all result-producing tests, prints each
failure, and reports both the number of failed tests and failed suites.

![Figure 13-1](images/regression-test-gallery.png)

*Figure 13-1. The color-coded visual regression gallery rendered by the Tests run. It
complements the 151 current named results by making geometry changes visible across many
cases at once; the final structured result remains the automated authority.*

After the global record and closing divider, a failed aggregate run prints one additional final
line: `*** Test Suite Failed ***`. This is a conspicuous human cue; scripts should continue to
use the structured `LOGOSC_AUTOMATED_TEST_RESULT` record.

For focused diagnosis, temporarily enable `LogoTestFailFast` in the Examples file's
`LogoSC Run` Customizer section or set it with OpenSCAD's `-D` option. Each immutable result is
then guarded by `assert()`, so evaluation stops at the first failed result. The assertion message
contains the test name and detail record. OpenSCAD 2021.01 also prints the file and line containing
the shared assertion plus a caller trace; helper-generated geometry tests may trace through shared
functions, so the test name remains the most reliable identifier. Restore `false` for the complete
accumulated report.
When exporting `.echo` output, OpenSCAD 2021.01 may return process exit code `0` even after an
assertion failure; the assertion text and final automated-result token remain authoritative.
Because fail-fast mode aborts during result evaluation, it may stop before the aggregate report
and its final failure banner are emitted.

The failure-condition row intentionally exercises Core soft errors. Its `[ERROR]` messages
are expected diagnostics and are bounded by `LogoSC expected-error tests: BEGIN` and `END`.
Some visual smoke cases also intentionally exercise renderer diagnostics outside that row.
Diagnostic echo lines do not determine the final test result. The immutable records do.

## 14. Limitations

Current limitations:

- LogoSC targets closed 2D regions for final geometry, not manufacturable open strokes.
- `RenderLogoDebug()` is preview-only diagnostic geometry, not a stroke/export API.
- No stroke width, caps, joins, or miter limits for final geometry yet.
- No automatic path filleting yet.
- No `ROUNDEDREGPOLY` yet.
- No variable/procedure system beyond OpenSCAD variables and `RUN` child lists.
- Holes are attached to the most recently emitted outer region.
- Hole containment and hole overlap are not validated by LogoSC.
- Crossing/self-intersecting contours are not rejected automatically.
- `polygon()` closes paths automatically, so unclosed contours can still render as filled shapes.
- Optional validation detects open paths, too few vertices, and zero-length segments,
  but not the more advanced topology cases listed in section 7.11.

For now, use closed shapes, `HOLE`, native OpenSCAD boolean/modeling operations,
and `RenderLogoDebug()` when you need to inspect suspicious path order, crossing
segments, or unclosed contours.

## 15. Suggested style for LogoSC programs

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
- [`evalLogo()`](#74-evallogo)
- [`evalLogoPaths()`](#711-path-analysis-and-validation)
- [`GOTO`](#goto)
- [`HOLE`](#hole)
- [`LogoSC-CheatSheet.md`](#quick-lookup-cheat-sheet)
- [`LogoSC-Examples.scad`](#4-runnable-examples)
- [`LogoSCVersion`](#library-version)
- [`LogoSCVersionAtLeast()`](#library-version)
- [`LogoTestReportLevel`](#automated-test-summaries)
- [`MOVE`](#move)
- [`PENDOWN`](#penup-and-pendown), [`PENUP`](#penup-and-pendown)
- [`POP`](#push-and-pop), [`PUSH`](#push-and-pop)
- [`RECT`](#rect)
- [Relative drawing vs. absolute layout](#51-relative-drawing-vs-absolute-layout)
- [`REGPOLY`](#regpoly)
- [`REPEAT`](#repeat)
- [`RenderContours2D()`](#77-rendercontours2d)
- [`RenderLogo2D()`](#73-renderlogo2d)
- [`RenderLogoDebug()`](#710-debug-visualization)
- [`ReportLogoValidation()`](#711-path-analysis-and-validation)
- [`RenderRegion2D()`](#78-renderregion2d)
- [`ResultContours()`](#75-evaluator-result-accessors)
- [`ResultPen()`](#75-evaluator-result-accessors)
- [`ResultStack()`](#75-evaluator-result-accessors)
- [`ResultState()`](#75-evaluator-result-accessors)
- [`ROUNDEDRECT`](#roundedrect)
- [`RUN`](#run)
- [`SCALE`](#scale)
- [`TURN`](#turn)
- [`ValidateLogoPaths()`](#711-path-analysis-and-validation)
- [Coordinate system](#5-coordinate-model)
- [Error handling](#13-error-handling-and-tracing)
- [Holes and regions](#6-rendering-model)
- [Linear extrusion](#linear-extrusion)
- [OpenSCAD wrappers](#8-3d-printing-workflow)
- [Recursion](#11-recursion-and-recursive-patterns)
- [Rotate extrusion](#rotate-extrusion)
- [Setup](#setup)
- [Test grid and tracing](#13-error-handling-and-tracing)
- [Debug visualization](#710-debug-visualization)
- [Automated test summaries](#automated-test-summaries)
- [Path analysis and validation](#711-path-analysis-and-validation)
