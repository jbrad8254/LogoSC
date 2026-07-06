// ============================================================================
// LogoT-Examples.scad
//
// Practical examples for LogoT.
//
// This file is meant to be opened directly in OpenSCAD. It imports the current
// LogoT core, defines several named command lists, and renders a small gallery
// with RenderAllLogoExamples().
//
// LogoT itself generates 2D regions. Use native OpenSCAD operations such as
// linear_extrude(), rotate_extrude(), scale(), translate(), union(), and
// difference() around RenderLogo2D() for actual 3D modeling.
// ============================================================================

// Keep the regression-test grid and trace output out of the examples view when
// this file is opened directly. OpenSCAD include behaves like textual insertion,
// so these settings live after the include to override core Customizer defaults.
include <LogoT-Foundation-Core.scad>
RunLogoTests = false;
TraceLevel = 0; // [0:4]

// -----------------------------------------------------------------------------
// Example controls
// -----------------------------------------------------------------------------

RunLogoExamples = true;

LogoExampleHeight = 3;
LogoExampleConvexity = 10;
LogoExampleXStep = 80;
LogoExampleYStep = 60;
LogoExampleLabelYOffset = -26;

LogoExampleWordmarkWidth = 100;
LogoExampleWordmarkHeight = 36;

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

// Recursive Koch segment generator. It emits LogoT movement commands. The caller
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
// copies of this LogoT-generated 2D part in a rising spiral.
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
// LogoT feature wordmark
// -----------------------------------------------------------------------------
// Nominal wordmark size: approximately 100 units wide.
// Resize with native OpenSCAD scale(), not by parameterizing the glyphs.

// Local-origin glyph command lists. The wordmark renderer below positions glyphs
// with native OpenSCAD translate() calls. That keeps LogoT geometry focused on
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

function LogoGlyphKochOOuter(side = 15, depth = 2) =
    KochSnowflake(0, 0, side, depth);

function LogoGlyphKochOHole(radius = 3, segments = 32) =
[
    [GOTO, 0, 0, 0],
    [CIRCLE, radius, segments]
];

LogoGlyphKochO =
    concat(
        LogoGlyphKochOOuter(),
        [[HOLE, LogoGlyphKochOHole()]]
    );

LogoGlyphTBar =
[
    [ROUNDEDRECT, 18, 5, 1.5, 5]
];

LogoGlyphTStem =
[
    [ROUNDEDRECT, 5, 24, 1.5, 5]
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

module RenderLogoGlyphT2D(convexity = LogoExampleConvexity)
{
    translate([0, 10])
    {
        RenderLogo2D(LogoGlyphTBar, convexity = convexity);
    }

    translate([0, -2])
    {
        RenderLogo2D(LogoGlyphTStem, convexity = convexity);
    }
}

module RenderLogoTFeatureWordmark2D(convexity = LogoExampleConvexity)
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
        RenderLogoGlyphT2D(convexity = convexity);
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
// 100 units wide; the gallery scales it down to fit a cell.
module RenderLogoTWordmarkExample(index = [0, 2], exampleScale = 0.55)
{
    offset = LogoExampleGridOffset(index);

    echo("");
    echo("============================================================");
    echo("LogoExample:", "LogoT feature wordmark");
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
                    RenderLogoTFeatureWordmark2D(convexity = LogoExampleConvexity);
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

// Standalone 3D use case: a rising spiral made from repeated LogoT tiles.
module RenderLogoTSpiralTower3D(
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

// Gallery wrapper for the standalone LogoT spiral tower example.
module RenderLogoTSpiralTower3DExample(index = [1, 1], exampleScale = 1.0)
{
    offset = LogoExampleGridOffset(index);

    echo("");
    echo("============================================================");
    echo("LogoExample:", "LogoT spiral tower 3D");
    echo("Index:", index);
    echo("Offset:", offset);
    echo("Scale:", exampleScale);
    echo("Color:", "rainbow by step");
    echo("============================================================");

    translate([offset[0], offset[1], 0])
    {
        scale([exampleScale, exampleScale, exampleScale])
        {
            RenderLogoTSpiralTower3D();
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

// Gallery routine similar in spirit to LogoTest(): render all examples at once.
module RenderAllLogoExamples()
{
    RenderLogoExample("washer", ExampleWasher, [0, 0]);
    RenderLogoExample("rounded mounting plate", ExampleMountingPlate, [1, 0], exampleScale = 0.8);
    RenderLogoExample("radial hole disk", ExampleRadialHoleDisk, [2, 0]);
    RenderLogoExample("Koch snowflake plaque", ExampleKochSnowflakePlaque, [3, 0], exampleScale = 0.85);

    RenderTwistedRoundedSquare3DExample([0, 1], exampleScale = 1.0);
    RenderLogoTSpiralTower3DExample([1, 1], exampleScale = 1.0);
    RenderLogoExample(
        "rotate-extrude knob profile",
        ExampleKnobProfile,
        [2, 1],
        exampleColor = "violet"
    );
    RenderKnobProfile3DExample([3, 1], exampleScale = 1.0);

    RenderLogoTWordmarkExample([0, 2], exampleScale = 0.58);
}

if (RunLogoExamples)
{
    RenderAllLogoExamples();
}
