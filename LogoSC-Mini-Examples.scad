// ============================================================================
// LogoSC-Mini-Examples.scad
//
// Five small, progressive LogoSC examples. Open this file directly in
// OpenSCAD and choose an example in the Customizer.
// ============================================================================

include <LogoSC-Foundation-Core.scad>

/* [Mini Example] */

MiniExample = "Triangle"; // [Triangle,Flower,Badge,PlateWithHole,PrintableToken]

/* [Output] */

MiniHeight = 3; // [1:0.5:10]
MiniArcSegments = 32; // [12:4:96]

triangle =
[
    [MOVE, 40],
    [TURN, 120],
    [MOVE, 40],
    [TURN, 120],
    [MOVE, 40]
];

petal =
[
    [ARC, 14, 60, MiniArcSegments],
    [TURN, 120],
    [ARC, 14, 60, MiniArcSegments],
    [TURN, 120]
];

flower =
[
    [REPEAT, 6,
        [
            [RUN, petal],
            [TURN, 60]
        ]
    ]
];

badge =
[
    [ROUNDEDRECT, 56, 34, 6, MiniArcSegments],
    [HOLE,
        [
            [GOTO, 0, 0, 0],
            [CIRCLE, 8, MiniArcSegments]
        ]
    ]
];

plateWithHole =
[
    [RECT, 60, 36],
    [HOLE,
        [
            [GOTO, -20, 0, 0],
            [CIRCLE, 4, MiniArcSegments]
        ]
    ],
    [HOLE,
        [
            [GOTO, 20, 0, 0],
            [CIRCLE, 4, MiniArcSegments]
        ]
    ]
];

printableToken =
[
    [REGPOLY, 6, 24],
    [HOLE,
        [
            [GOTO, 0, 0, 0],
            [CIRCLE, 6, MiniArcSegments]
        ]
    ]
];

selectedCommands =
    MiniExample == "Triangle" ? triangle
    : MiniExample == "Flower" ? flower
    : MiniExample == "Badge" ? badge
    : MiniExample == "PlateWithHole" ? plateWithHole
    : MiniExample == "PrintableToken" ? printableToken
    : assert(false, str("Unknown Mini example: ", MiniExample));

assert(
    MiniExample == "Triangle"
    || MiniExample == "Flower"
    || MiniExample == "Badge"
    || MiniExample == "PlateWithHole"
    || MiniExample == "PrintableToken",
    "MiniExample must be a supported Customizer choice."
);

linear_extrude(height = MiniHeight, convexity = 10)
{
    RenderLogo2D(selectedCommands);
}
