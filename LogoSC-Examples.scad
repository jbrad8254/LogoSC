// ============================================================================
// LogoSC-Examples.scad
//
// Practical examples for LogoSC.
//
// This file is meant to be opened directly in OpenSCAD. It imports the current
// LogoSC core, defines several named command lists, and renders a small gallery
// with RenderAllLogoExamples().
//
// LogoSC itself generates 2D regions. Use native OpenSCAD operations such as
// linear_extrude(), rotate_extrude(), scale(), translate(), union(), and
// difference() around RenderLogo2D() for actual 3D modeling.
// ============================================================================

// Load Core plus the passive regression-test definitions so this file can keep
// offering Examples, Debug, and Tests as interactive run modes. Basic user
// models need only LogoSC-Foundation-Core.scad. Path analysis and validation
// remain optional companions loaded here for the explicit Tests run mode.
include <LogoSC-Foundation-Core.scad>
include <LogoSC-Foundation-Validation.scad>
include <LogoSC-Foundation-Tests.scad>
include <LogoSC-Foundation-Validation-Tests.scad>

// -----------------------------------------------------------------------------
// Example controls
// -----------------------------------------------------------------------------

/* [LogoSC Run] */

// Top-level Customizer selector for automatic preview output.
LogoSCRunMode = "Examples"; // [NoDemo, Examples, Debug, Tests]

// Keep routine example previews quiet unless the user explicitly raises tracing.
TraceLevel = 0; // [0:4]

// Optional test-diagnosis mode used when LogoSCRunMode is Tests.
LogoTestFailFast = false; // [false:true]

/* [LogoSC Debug Demo] */

// Preview-only debug-renderer demo controls. These controls are used when
// LogoSCRunMode is set to Debug.
DebugDemoOverlay = true; // [false:true]
DebugDemoFilled = true; // [false:true]
DebugDemoPenUp = true; // [false:true]

DebugDemoLayout = "Gallery"; // [Gallery, Selected]
DebugDemoExample = 0; // [0:Closed, 1:Open, 2:Crossed, 3:Rectangle, 4:PenUp, 5:Arc, 6:StrokePrim, 7:Prims]
DebugDemoLineWidth = 0.30; // [0:0.05:4]
DebugDemoPointRadius = 0.30; // [0:0.05:4]
DebugDemoLineHeight = 4; // [0.5:0.5:12]
DebugDemoPointHeight = 7; // [0.5:0.5:12]

/* [Logo Examples] */

LogoExampleHeight = 3;
LogoExampleConvexity = 10;
LogoExampleXStep = 80;
LogoExampleYStep = 60;
LogoExampleLabelYOffset = -26;

/* [Logo Example Wordmark] */

LogoExampleWordmarkWidth = 126;
LogoExampleWordmarkHeight = 36;

/* [Logo Example Colors] */

LogoExampleColor0 = "red";
LogoExampleColor1 = "orange";
LogoExampleColor2 = "gold";
LogoExampleColor3 = "green";
LogoExampleColor4 = "cyan";
LogoExampleColor5 = "blue";
LogoExampleColor6 = "violet";
LogoExampleColor7 = "magenta";
LogoExampleColor8 = "brown";
LogoExampleColor9 = "gray";
LogoExampleColorMax = "black";

LogoExampleColors =
[
    LogoExampleColor0,
    LogoExampleColor1,
    LogoExampleColor2,
    LogoExampleColor3,
    LogoExampleColor4,
    LogoExampleColor5,
    LogoExampleColor6,
    LogoExampleColor7,
    LogoExampleColor8,
    LogoExampleColor9
];

function LogoExampleColor(index) =
    index >= 0 && index < len(LogoExampleColors)
        ? LogoExampleColors[floor(index)]
        : LogoExampleColorMax;

function LogoExampleGridOffset(index) =
[
    index[0] * LogoExampleXStep,
    index[1] * LogoExampleYStep
];

// -----------------------------------------------------------------------------
// Small reusable command-list generators
// -----------------------------------------------------------------------------

function LogoHoleCircle(x, y, radius, segments = 32) =
[
    [HOLE, [[GOTO, x, y, 0], [CIRCLE, radius, segments]]]
];

function LogoStampedCircle(x, y, radius, segments = 48) =
[
    [GOTO, x, y, 0],
    [CIRCLE, radius, segments]
];

function LogoStampedRoundedRect(x, y, width, height, radius, segments = 8) =
[
    [GOTO, x, y, 0],
    [ROUNDEDRECT, width, height, radius, segments]
];

// Stepped command lists used by the optional debug-renderer demo. They start
// with simple shapes so individual MOVE/TURN/primitive events are easier to
// verify before trying denser or intentionally self-intersecting examples.
ExampleDebugTriangleCommands =
[
    [MOVE, 24],
    [TURN, 120],
    [MOVE, 24],
    [TURN, 120],
    [MOVE, 24]
];

// This intentionally leaves the final side short. The filled 2D polygon still
// closes the contour, while the debug renderer shows that the turtle endpoint
// did not return to the start point. Keep this as a visible design question.
ExampleDebugOpenTriangleCommands =
[
    [MOVE, 24],
    [TURN, 120],
    [MOVE, 24],
    [TURN, 120],
    [MOVE, 20]
];

// Classic crossed polygon: the same four rectangle-corner points as the
// rectangle demo, but with the bottom-right and top-left traversal order
// swapped. The filled 2D result is self-intersecting, while the debug overlay
// makes the unexpected crossing segments obvious. No pen commands are needed;
// the default state is pen-down and the implicit contour start is the first
// rectangle corner.
ExampleDebugCrossedRectangleCommands =
[
    [GOTO, 26, 16, 0],
    [GOTO, 0, 16, 0],
    [GOTO, 26, 0, 0]
];

ExampleDebugRectangleCommands =
[
    [MOVE, 26],
    [TURN, 90],
    [MOVE, 16],
    [TURN, 90],
    [MOVE, 26],
    [TURN, 90],
    [MOVE, 16]
];

ExampleDebugPenUpGapCommands =
[
    [MOVE, 14],
    [TURN, 90],
    [MOVE, 14],
    [TURN, 90],
    [MOVE, 14],
    [TURN, 90],
    [MOVE, 14],
    [PENUP],
    [TURN, 90],
    [MOVE, 24],
    [PENDOWN],
    [MOVE, 12],
    [TURN, 120],
    [MOVE, 12],
    [TURN, 120],
    [MOVE, 12]
];

ExampleDebugArcLoopCommands =
[
    [MOVE, 22],
    [ARC, 8, 180, 12],
    [MOVE, 22],
    [ARC, 8, 180, 12]
];

ExampleDebugPrimitiveCommands =
[
    [PENUP],
    [GOTO, -22, 0, 0],
    [PENDOWN],
    [CIRCLE, 6, 24],
    [PENUP],
    [GOTO, 0, 0, 0],
    [PENDOWN],
    [RECT, 12, 10],
    [PENUP],
    [GOTO, 22, 0, 0],
    [PENDOWN],
    [REGPOLY, 5, 7, 18],
    [PENUP],
    [GOTO, 44, 0, 0],
    [PENDOWN],
    [ROUNDEDRECT, 14, 10, 2, 4]
];

// Same-size equilateral triangles, constructed two ways. The left triangle is
// a stroked turtle path; the right triangle is a REGPOLY primitive centered on
// the current turtle point. The GOTO marker makes the primitive center visible.
ExampleDebugStrokePrimitiveTriangleCommands =
[
    [PENUP],
    [GOTO, -36, -24 / (2 * sqrt(3)), 0],
    [PENDOWN],
    [MOVE, 24],
    [TURN, 120],
    [MOVE, 24],
    [TURN, 120],
    [MOVE, 24],
    [PENUP],
    [GOTO, 24, 0, 0],
    [PENDOWN],
    [REGPOLY, 3, 24 / sqrt(3), -150]
];

function ExampleDebugRendererCommands(index) =
    index == 1
        ? ExampleDebugOpenTriangleCommands
        : index == 2
            ? ExampleDebugCrossedRectangleCommands
            : index == 3
                ? ExampleDebugRectangleCommands
                : index == 4
                    ? ExampleDebugPenUpGapCommands
                    : index == 5
                        ? ExampleDebugArcLoopCommands
                        : index == 6
                            ? ExampleDebugStrokePrimitiveTriangleCommands
                            : index == 7
                                ? ExampleDebugPrimitiveCommands
                                : ExampleDebugTriangleCommands;

// Map each debug example to a stable four-column gallery cell.
function DebugDemoGridIndex(debugExample) =
[
    debugExample % 4,
    floor(debugExample / 4)
];

// Recursive Koch segment generator. It emits LogoSC movement commands. The caller
// is responsible for placing the starting point and heading.
function KochSegment(depth, len) =
    depth <= 0
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

function KochSnowflake(x, y, side, depth) =
    let(height = side * sqrt(3) / 2)
    concat(
        // Start from the lower-left vertex of a downward-pointing triangle whose
        // centroid is [x, y]. This keeps snowflake holes optically centered in
        // circular and rectangular examples.
        [[GOTO, x - side / 2, y + height / 3, 0]],
        KochSegment(depth, side),
        [[TURN, -120]],
        KochSegment(depth, side),
        [[TURN, -120]],
        KochSegment(depth, side),
        [[TURN, -120]]
    );

// -----------------------------------------------------------------------------
// L-system example helpers
// -----------------------------------------------------------------------------
// These helpers intentionally live in the examples file rather than in the core
// interpreter. They show how a small symbol-rewrite layer can generate ordinary
// LogoSC command lists without creating new LogoSC opcodes.

LSYS_F     = 100 + 0;
LSYS_PLUS  = 101 + 0;
LSYS_MINUS = 102 + 0;
LSYS_PUSH  = 103 + 0;
LSYS_POP   = 104 + 0;

LSYS_SYSTEM_KOCH = 0 + 0;
LSYS_SYSTEM_QUADRATIC_KOCH = 1 + 0;

function LogoSCLSystemRule(systemId, symbol) =
    systemId == LSYS_SYSTEM_KOCH
        ? (symbol == LSYS_F
            ? [
                LSYS_F, LSYS_PLUS, LSYS_F, LSYS_MINUS,
                LSYS_MINUS, LSYS_F, LSYS_PLUS, LSYS_F
            ]
            : [symbol])
        : systemId == LSYS_SYSTEM_QUADRATIC_KOCH
            ? (symbol == LSYS_F
                ? [
                    LSYS_F, LSYS_MINUS, LSYS_F, LSYS_PLUS,
                    LSYS_F, LSYS_PLUS, LSYS_F, LSYS_F,
                    LSYS_MINUS, LSYS_F, LSYS_MINUS, LSYS_F,
                    LSYS_PLUS, LSYS_F
                ]
                : [symbol])
            : [symbol];

function LogoSCLSystemRewrite(systemId, symbols, index = 0) =
    index >= len(symbols)
        ? []
        : concat(
            LogoSCLSystemRule(systemId, symbols[index]),
            LogoSCLSystemRewrite(systemId, symbols, index + 1)
        );

function LogoSCLSystemExpand(systemId, axiom, depth) =
    depth <= 0
        ? axiom
        : LogoSCLSystemExpand(
            systemId,
            LogoSCLSystemRewrite(systemId, axiom),
            depth - 1
        );

function LogoSCLSystemSymbolCommands(symbol, step, angle) =
    symbol == LSYS_F
        ? [[MOVE, step]]
        : symbol == LSYS_PLUS
            ? [[TURN, angle]]
            : symbol == LSYS_MINUS
                ? [[TURN, -angle]]
                : symbol == LSYS_PUSH
                    ? [[PUSH]]
                    : symbol == LSYS_POP
                        ? [[POP]]
                        : [];

function LogoSCLSystemCommands(symbols, step, angle, index = 0) =
    index >= len(symbols)
        ? []
        : concat(
            LogoSCLSystemSymbolCommands(symbols[index], step, angle),
            LogoSCLSystemCommands(symbols, step, angle, index + 1)
        );

function LSystemKochSnowflake(x, y, side, depth) =
    let(
        height = side * sqrt(3) / 2,
        axiom = [
            LSYS_F, LSYS_MINUS, LSYS_MINUS,
            LSYS_F, LSYS_MINUS, LSYS_MINUS,
            LSYS_F
        ],
        symbols = LogoSCLSystemExpand(LSYS_SYSTEM_KOCH, axiom, depth),
        step = side / pow(3, depth)
    )
    concat(
        [[GOTO, x - side / 2, y + height / 3, 0]],
        LogoSCLSystemCommands(symbols, step, 60)
    );

function LSystemQuadraticKochIsland(x, y, side, depth) =
    let(
        axiom = [LSYS_F, LSYS_PLUS, LSYS_F, LSYS_PLUS, LSYS_F, LSYS_PLUS, LSYS_F],
        symbols = LogoSCLSystemExpand(LSYS_SYSTEM_QUADRATIC_KOCH, axiom, depth),
        step = side / pow(4, depth)
    )
    concat(
        [[GOTO, x - side / 2, y - side / 2, 0]],
        LogoSCLSystemCommands(symbols, step, 90)
    );

// -----------------------------------------------------------------------------
// Basic practical examples
// -----------------------------------------------------------------------------

ExampleWasher =
[
    [CIRCLE, 18, 96],
    [HOLE, [[CIRCLE, 7, 48]]]
];

ExampleMountingPlate =
concat(
    [[ROUNDEDRECT, 60, 30, 4, 10]],
    LogoHoleCircle(-22, -10, 2.5, 24),
    LogoHoleCircle( 22, -10, 2.5, 24),
    LogoHoleCircle(-22,  10, 2.5, 24),
    LogoHoleCircle( 22,  10, 2.5, 24)
);

// A circular plate with repeated radial holes. The holes are created inside one
// HOLE child list using REPEAT, PUSH, POP, TURN, and CIRCLE.
ExampleRadialHoleDisk =
[
    [CIRCLE, 20, 96],
    [HOLE,
        [
            [REPEAT, 10,
                [
                    [PUSH],
                    [MOVE, 13],
                    [CIRCLE, 1.8, 20],
                    [POP],
                    [TURN, 36]
                ]
            ]
        ]
    ]
];

ExampleKochSnowflakePlaque =
[
    [ROUNDEDRECT, 54, 34, 4, 10],
    [HOLE, KochSnowflake(0, 0, 22, 2)]
];

ExampleLSystemKochMedallion =
concat(
    LSystemKochSnowflake(0, 0, 32, 2),
    [[HOLE, [[CIRCLE, 4.5, 40]]]]
);

ExampleLSystemKochHoleDisk =
[
    [CIRCLE, 20, 96],
    [HOLE, LSystemKochSnowflake(0, 0, 24, 2)]
];

ExampleLSystemQuadraticIsland =
    LSystemQuadraticKochIsland(0, 0, 30, 2);

ExampleLSystemQuadraticHolePlate =
[
    [ROUNDEDRECT, 56, 38, 4, 10],
    [HOLE, LSystemQuadraticKochIsland(0, 0, 22, 2)]
];

// 2D profile intended for native OpenSCAD rotate_extrude(). The profile is on
// the positive-X side of the rotation axis. This one is path-built rather than
// stamp-built so the whole profile is one closed region.
ExampleKnobProfile =
[
    [GOTO, 8, -11, 0],
    [MOVE, 10],
    [TURN, 90],
    [MOVE, 4],
    [TURN, 90],
    [MOVE, 2],
    [TURN, -90],
    [MOVE, 14],
    [TURN, -90],
    [MOVE, 2],
    [TURN, 90],
    [MOVE, 4],
    [TURN, 90],
    [MOVE, 10],
    [TURN, 90],
    [MOVE, 22]
];

// A small path-built part that exercises MOVE, TURN, ARC, and polygon closure.
ExamplePathBracket =
[
    [GOTO, -24, -10, 0],
    [MOVE, 40],
    [ARC, 8, 90, 8],
    [MOVE, 4],
    [ARC, 8, 90, 8],
    [MOVE, 40],
    [TURN, 90],
    [MOVE, 20]
];

// A compact 2D profile for a visibly 3D twisted extrusion example.
ExampleTwistedRoundedSquare =
[
    [ROUNDEDRECT, 24, 24, 4, 10],
    [HOLE, [[CIRCLE, 5, 48]]]
];

// Reusable tile for the spiral tower example. The 3D module below arranges many
// copies of this LogoSC-generated 2D part in a rising spiral.
ExampleSpiralTowerTile =
[
    [ROUNDEDRECT, 10, 5, 1.2, 5],
    [HOLE, [[CIRCLE, 1.0, 16]]]
];

ExampleSpiralTowerCore =
[
    [CIRCLE, 3.0, 40],
    [HOLE, [[CIRCLE, 1.0, 24]]]
];

// -----------------------------------------------------------------------------
// LogoSC feature wordmark
// -----------------------------------------------------------------------------
// Nominal wordmark size: approximately 126 units wide.
// Resize with native OpenSCAD scale(), not by parameterizing the glyphs.

// Local-origin glyph command lists. The wordmark renderer below positions glyphs
// with native OpenSCAD translate() calls. That keeps LogoSC geometry focused on
// shape construction while OpenSCAD handles layout and scaling.
LogoGlyphL =
[
    [GOTO, 0, 0, 0],
    [MOVE, 24],
    [TURN, 90],
    [MOVE, 8],
    [TURN, 90],
    [MOVE, 16],
    [TURN, -90],
    [MOVE, 24],
    [TURN, 90],
    [MOVE, 8],
    [TURN, 90],
    [MOVE, 32]
];

LogoGlyphO =
[
    [CIRCLE, 8, 64],
    [HOLE, [[CIRCLE, 4, 32]]]
];

LogoGlyphGBody =
[
    [CIRCLE, 8, 64],
    [HOLE, [[CIRCLE, 4, 32]]]
];

LogoGlyphGTail0 =
[
    [ROUNDEDRECT, 5, 14, 2, 6]
];

LogoGlyphGTail1 =
[
    [ROUNDEDRECT, 12, 4, 2, 6]
];

function LogoGlyphKochOOuter(side = 18, depth = 2) =
    KochSnowflake(0, 0, side, depth);

function LogoGlyphKochOHole(radius = 4, segments = 36) =
[
    [GOTO, 0, 0, 0],
    [CIRCLE, radius, segments]
];

// Gear-like O: a Koch snowflake outline with a larger center hole.
// This keeps the mark as filled region geometry; no stroke API is used.
LogoGlyphKochO =
    concat(
        LogoGlyphKochOOuter(),
        [[HOLE, LogoGlyphKochOHole()]]
    );

// The S and C use overlapping filled rounded rectangles rather than a stroke
// renderer. This keeps the wordmark entirely within LogoSC's normal region API.
//
// The S is built from three horizontal lozenges plus two alternating vertical
// connectors. The C uses broad rounded terminals and a left spine, giving the
// final two letters a related mechanical/"machined badge" appearance.
LogoGlyphSCrossbar =
[
    [ROUNDEDRECT, 17, 4, 2, 6]
];

LogoGlyphSConnector =
[
    [ROUNDEDRECT, 4, 11, 2, 6]
];

LogoGlyphCTerminal =
[
    [ROUNDEDRECT, 16, 4, 2, 6]
];

LogoGlyphCSpine =
[
    [ROUNDEDRECT, 4, 24, 2, 6]
];

LogoGlyphCEndCap =
[
    [CIRCLE, 2, 20]
];

module RenderLogoGlyphG2D(convexity = LogoExampleConvexity)
{
    RenderLogo2D(LogoGlyphGBody, convexity = convexity);

    translate([5, -10])
    {
        RenderLogo2D(LogoGlyphGTail0, convexity = convexity);
    }

    translate([2, -17])
    {
        RenderLogo2D(LogoGlyphGTail1, convexity = convexity);
    }
}

module RenderLogoGlyphS2D(convexity = LogoExampleConvexity)
{
    // Three rounded crossbars.
    for (y = [-10, 0, 10])
    {
        translate([0, y])
        {
            RenderLogo2D(LogoGlyphSCrossbar, convexity = convexity);
        }
    }

    // Alternating connectors create the classic S path as a filled region.
    translate([-6.5, 5])
    {
        RenderLogo2D(LogoGlyphSConnector, convexity = convexity);
    }

    translate([6.5, -5])
    {
        RenderLogo2D(LogoGlyphSConnector, convexity = convexity);
    }
}

module RenderLogoGlyphC2D(convexity = LogoExampleConvexity)
{
    // Rounded top and bottom terminals.
    for (y = [-10, 10])
    {
        translate([0, y])
        {
            RenderLogo2D(LogoGlyphCTerminal, convexity = convexity);
        }
    }

    // Left spine joins the terminals into a solid open C.
    translate([-6, 0])
    {
        RenderLogo2D(LogoGlyphCSpine, convexity = convexity);
    }

    // Circular terminal caps emphasize that the right side is intentionally open.
    for (y = [-10, 10])
    {
        translate([8, y])
        {
            RenderLogo2D(LogoGlyphCEndCap, convexity = convexity);
        }
    }
}

module RenderLogoSCFeatureWordmark2D(convexity = LogoExampleConvexity)
{
    RenderLogo2D(LogoGlyphL, convexity = convexity);

    translate([34, 16])
    {
        RenderLogo2D(LogoGlyphO, convexity = convexity);
    }

    translate([52, 16])
    {
        RenderLogoGlyphG2D(convexity = convexity);
    }

    translate([72, 16])
    {
        RenderLogo2D(LogoGlyphKochO, convexity = convexity);
    }

    translate([92, 16])
    {
        RenderLogoGlyphS2D(convexity = convexity);
    }

    translate([112, 16])
    {
        RenderLogoGlyphC2D(convexity = convexity);
    }
}

// -----------------------------------------------------------------------------
// Rendering helpers
// -----------------------------------------------------------------------------

module RenderLogoExample(
    exampleName,
    cmds,
    index,
    height = LogoExampleHeight,
    exampleScale = 1,
    exampleColor = undef)
{
    offset = LogoExampleGridOffset(index);
    useColor = exampleColor == undef ? LogoExampleColor(index[0]) : exampleColor;

    echo("");
    echo("============================================================");
    echo("LogoExample:", exampleName);
    echo("Index:", index);
    echo("Offset:", offset);
    echo("Scale:", exampleScale);
    echo("Color:", useColor);
    echo("============================================================");

    translate([offset[0], offset[1], 0])
    {
        color(useColor)
        {
            linear_extrude(height = height, center = true, convexity = LogoExampleConvexity)
            {
                scale([exampleScale, exampleScale])
                {
                    RenderLogo2D(cmds, convexity = LogoExampleConvexity);
                }
            }
        }
    }
}

// Render the wordmark as a 2D extruded badge. The wordmark is designed around
// 126 units wide; the gallery scales it down to fit a cell.
module RenderLogoSCWordmarkExample(index = [0, 2], exampleScale = 0.46)
{
    offset = LogoExampleGridOffset(index);

    echo("");
    echo("============================================================");
    echo("LogoExample:", "LogoSC feature wordmark");
    echo("Index:", index);
    echo("Offset:", offset);
    echo("Scale:", exampleScale);
    echo("Color:", "blue");
    echo("============================================================");

    translate([offset[0], offset[1], 0])
    {
        color("blue")
        {
            linear_extrude(
                height = LogoExampleHeight,
                center = true,
                convexity = LogoExampleConvexity
            )
            {
                scale([exampleScale, exampleScale])
                {
                    RenderLogoSCFeatureWordmark2D(convexity = LogoExampleConvexity);
                }
            }
        }
    }
}

// Standalone 3D use case: a twisted rounded square with a central hole.
module RenderTwistedRoundedSquare3D(height = 18, twist = 90, slices = 32)
{
    linear_extrude(
        height = height,
        center = false,
        convexity = LogoExampleConvexity,
        twist = twist,
        slices = slices
    )
    {
        RenderLogo2D(ExampleTwistedRoundedSquare, convexity = LogoExampleConvexity);
    }
}

// Standalone 3D use case: rotate-extruded knob/profile.
module RenderKnobProfile3D(angle = 360)
{
    rotate_extrude(angle = angle, convexity = LogoExampleConvexity)
    {
        RenderLogo2D(ExampleKnobProfile, convexity = LogoExampleConvexity);
    }
}

// Standalone 3D use case: a rising spiral made from repeated LogoSC tiles.
module RenderLogoSCSpiralTower3D(
    stepCount = 14,
    radiusStart = 5.5,
    radiusStep = 0.8,
    angleStep = 32,
    heightStep = 0.7,
    tileHeight = 1.1)
{
    coreHeight = stepCount * heightStep + tileHeight;

    color("gray")
    {
        linear_extrude(height = coreHeight, center = false, convexity = LogoExampleConvexity)
        {
            RenderLogo2D(ExampleSpiralTowerCore, convexity = LogoExampleConvexity);
        }
    }

    for (i = [0 : stepCount - 1])
    {
        angle = i * angleStep;
        radius = radiusStart + i * radiusStep;
        useColor = LogoExampleColor(i % len(LogoExampleColors));

        translate([radius * cos(angle), radius * sin(angle), i * heightStep])
        {
            rotate([0, 0, angle + 12])
            {
                color(useColor)
                {
                    linear_extrude(
                        height = tileHeight,
                        center = false,
                        convexity = LogoExampleConvexity
                    )
                    {
                        RenderLogo2D(
                            ExampleSpiralTowerTile,
                            convexity = LogoExampleConvexity
                        );
                    }
                }
            }
        }
    }
}

// Gallery wrapper for the standalone twisted extrusion example.
module RenderTwistedRoundedSquare3DExample(index = [0, 1], exampleScale = 1.0)
{
    offset = LogoExampleGridOffset(index);

    echo("");
    echo("============================================================");
    echo("LogoExample:", "twisted rounded square 3D");
    echo("Index:", index);
    echo("Offset:", offset);
    echo("Scale:", exampleScale);
    echo("Color:", "green");
    echo("============================================================");

    translate([offset[0], offset[1], 0])
    {
        color("green")
        {
            scale([exampleScale, exampleScale, exampleScale])
            {
                RenderTwistedRoundedSquare3D(height = 18, twist = 105, slices = 36);
            }
        }
    }
}

// Gallery wrapper for the standalone LogoSC spiral tower example.
module RenderLogoSCSpiralTower3DExample(index = [1, 1], exampleScale = 1.0)
{
    offset = LogoExampleGridOffset(index);

    echo("");
    echo("============================================================");
    echo("LogoExample:", "LogoSC spiral tower 3D");
    echo("Index:", index);
    echo("Offset:", offset);
    echo("Scale:", exampleScale);
    echo("Color:", "rainbow by step");
    echo("============================================================");

    translate([offset[0], offset[1], 0])
    {
        scale([exampleScale, exampleScale, exampleScale])
        {
            RenderLogoSCSpiralTower3D();
        }
    }
}

// Gallery wrapper for the standalone rotate-extruded knob/profile.
module RenderKnobProfile3DExample(index = [3, 1], exampleScale = 1.0)
{
    offset = LogoExampleGridOffset(index);

    echo("");
    echo("============================================================");
    echo("LogoExample:", "rotate-extruded knob 3D");
    echo("Index:", index);
    echo("Offset:", offset);
    echo("Scale:", exampleScale);
    echo("Color:", "violet");
    echo("============================================================");

    translate([offset[0], offset[1], 0])
    {
        color("violet")
        {
            scale([exampleScale, exampleScale, exampleScale])
            {
                RenderKnobProfile3D(angle = 360);
            }
        }
    }
}

// Preview one debug-renderer example at a logical gallery index. Open this file
// directly in OpenSCAD and set LogoSCRunMode to Debug in Customizer to see the
// filled output and colored debug capsules/points overlaid.
module RenderDebugDemo(
    index = [0, 0],
    exampleScale = 1.0,
    debugExample = DebugDemoExample)
{
    offset = LogoExampleGridOffset(index);
    cmds = ExampleDebugRendererCommands(debugExample);

    echo("");
    echo("============================================================");
    echo("LogoExample:", "debug renderer overlay");
    echo("Index:", index);
    echo("Offset:", offset);
    echo("Scale:", exampleScale);
    echo("Debug demo example:", debugExample);
    echo("============================================================");

    translate([offset[0], offset[1], 0])
    {
        scale([exampleScale, exampleScale, exampleScale])
        {
            if (DebugDemoFilled)
            {
                color("Gold")
                {
                    linear_extrude(
                        height = LogoExampleHeight,
                        center = true,
                        convexity = LogoExampleConvexity
                    )
                    {
                        RenderLogo2D(cmds, convexity = LogoExampleConvexity);
                    }
                }
            }

            if (DebugDemoOverlay)
            {
                RenderLogoDebug(
                    cmds,
                    segmentRadius = DebugDemoLineWidth / 2,
                    pointRadius = DebugDemoPointRadius,
                    segmentHeight = DebugDemoLineHeight,
                    pointHeight = DebugDemoPointHeight,
                    showPenUpMoves = DebugDemoPenUp
                );
            }
        }
    }
}

// Render every debug example in a stable four-by-two grid. Each call receives
// its own example number and logical index so the console output maps directly
// to the displayed gallery cell.
module RenderAllDebugDemos()
{
    for (debugExample = [0 : 7])
    {
        RenderDebugDemo(
            index = DebugDemoGridIndex(debugExample),
            debugExample = debugExample
        );
    }
}

// Gallery routine similar in spirit to LogoSCTest(): render all examples at once.
module RenderAllLogoExamples()
{
    RenderLogoExample("washer", ExampleWasher, [0, 0]);
    RenderLogoExample("rounded mounting plate", ExampleMountingPlate, [1, 0], exampleScale = 0.8);
    RenderLogoExample("radial hole disk", ExampleRadialHoleDisk, [2, 0]);
    RenderLogoExample("Koch snowflake plaque", ExampleKochSnowflakePlaque, [3, 0], exampleScale = 0.85);

    RenderTwistedRoundedSquare3DExample([0, 1], exampleScale = 1.0);
    RenderLogoSCSpiralTower3DExample([1, 1], exampleScale = 1.0);
    RenderLogoExample(
        "rotate-extrude knob profile",
        ExampleKnobProfile,
        [2, 1],
        exampleColor = "violet"
    );
    RenderKnobProfile3DExample([3, 1], exampleScale = 1.0);

    RenderLogoSCWordmarkExample([0, 2], exampleScale = 0.46);

    RenderLogoExample("L-system Koch medallion", ExampleLSystemKochMedallion, [0, 3]);
    RenderLogoExample("L-system Koch hole disk", ExampleLSystemKochHoleDisk, [1, 3]);
    RenderLogoExample(
        "L-system quadratic island",
        ExampleLSystemQuadraticIsland,
        [2, 3],
        exampleScale = 0.95
    );
    RenderLogoExample(
        "L-system quadratic hole plate",
        ExampleLSystemQuadraticHolePlate,
        [3, 3],
        exampleScale = 0.85
    );
}

if (LogoSCRunMode == "Examples")
{
    RenderAllLogoExamples();
}

if (LogoSCRunMode == "Debug")
{
    if (DebugDemoLayout == "Gallery")
    {
        RenderAllDebugDemos();
    }
    else
    {
        RenderDebugDemo(debugExample = DebugDemoExample);
    }
}

if (LogoSCRunMode == "Tests")
{
    RunAllLogoTestSuites();
}
