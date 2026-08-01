// ============================================================================
// LogoSC-Core-Examples.scad
//
// Standalone Core-only examples. Unlike the engineering gallery, this file
// does not include validation or passive test definitions.
// ============================================================================

include <LogoSC-Foundation-Core.scad>

/* [Core Example] */

CoreExample = "Motif"; // [Motif,Panel,Transformed,Debug]

/* [Output] */

CoreHeight = 3; // [1:0.5:10]
CoreSegments = 48; // [12:4:120]

motifStep =
[
    [MOVE, 24],
    [ARC, 10, 90, CoreSegments],
    [TURN, 90]
];

motif =
[
    [REPEAT, 4, [[RUN, motifStep]]]
];

panel =
[
    [ROUNDEDRECT, 90, 48, 7, CoreSegments],
    [HOLE, [[GOTO, -32, 0, 0], [CIRCLE, 4, CoreSegments]]],
    [HOLE, [[GOTO,  32, 0, 0], [CIRCLE, 4, CoreSegments]]],
    [HOLE, [[GOTO,   0, 0, 0], [REGPOLY, 6, 12]]]
];

transformed =
[
    [SCALE, 1.45, 0.75],
    [ROTATE, 22.5],
    [RUN, motif]
];

selectedCommands =
    CoreExample == "Motif" ? motif
    : CoreExample == "Panel" ? panel
    : CoreExample == "Transformed" ? transformed
    : CoreExample == "Debug" ? panel
    : assert(false, str("Unknown Core example: ", CoreExample));

assert(
    CoreExample == "Motif"
    || CoreExample == "Panel"
    || CoreExample == "Transformed"
    || CoreExample == "Debug",
    "CoreExample must be a supported Customizer choice."
);

if (CoreExample == "Debug")
{
    color("lightgray")
        linear_extrude(height = CoreHeight, convexity = 10)
            RenderLogo2D(selectedCommands);

    RenderLogoDebug(
        selectedCommands,
        segmentRadius = 0.18,
        pointRadius = 0.34,
        segmentHeight = CoreHeight + 1,
        pointHeight = CoreHeight + 3
    );
}
else
{
    linear_extrude(height = CoreHeight, convexity = 10)
        RenderLogo2D(selectedCommands);
}
