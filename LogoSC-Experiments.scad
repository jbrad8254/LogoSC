// ============================================================================
// LogoSC-Experiments.scad
//
// Experimental and exploratory tests for LogoSC.
//
// This file is meant to be opened directly in OpenSCAD. It imports the current
// LogoSC core, defines small experimental command lists, and renders them with
// RenderAllLogoExperiments().
//
// Keep experimental work here until it is stable enough to move into the core,
// formal tests, or the main examples gallery.
// ============================================================================

// Keep the regression-test grid and trace output out of the experiments view
// when this file is opened directly. OpenSCAD include behaves like textual
// insertion, so these settings live after the include to override core
// Customizer defaults.
include <LogoSC-Foundation-Core.scad>
RunLogoTests = false;
TraceLevel = 0; // [0:4]

// -----------------------------------------------------------------------------
// Experiment controls
// -----------------------------------------------------------------------------

RunLogoExperiments = true;

LogoExperimentHeight = 3;
LogoExperimentConvexity = 10;
LogoExperimentXStep = 80;
LogoExperimentYStep = 60;
StrokeTestEpsilon = 0.001;
CapsuleStrokeWidth = 4;
CapsuleStrokeFn = 24;

LogoExperimentColor0 = "red";
LogoExperimentColor1 = "orange";
LogoExperimentColor2 = "gold";
LogoExperimentColor3 = "green";
LogoExperimentColor4 = "cyan";
LogoExperimentColor5 = "blue";
LogoExperimentColor6 = "violet";
LogoExperimentColor7 = "magenta";
LogoExperimentColor8 = "brown";
LogoExperimentColor9 = "gray";
LogoExperimentColorMax = "black";

LogoExperimentColors =
[
    LogoExperimentColor0,
    LogoExperimentColor1,
    LogoExperimentColor2,
    LogoExperimentColor3,
    LogoExperimentColor4,
    LogoExperimentColor5,
    LogoExperimentColor6,
    LogoExperimentColor7,
    LogoExperimentColor8,
    LogoExperimentColor9
];

function LogoExperimentColor(index) =
    index >= 0 && index < len(LogoExperimentColors)
        ? LogoExperimentColors[floor(index)]
        : LogoExperimentColorMax;

function LogoExperimentGridOffset(index) =
[
    index[0] * LogoExperimentXStep,
    index[1] * LogoExperimentYStep
];

// -----------------------------------------------------------------------------
// Experimental geometry helpers
// -----------------------------------------------------------------------------

// Returns the input point list followed by the same points in reverse order.
// The repeated endpoint and start point are intentional: this creates the
// zero-area, doubled-back polygon used by the experimental stroke test.
function LogoSCReverseAppendPoints(points) =
    len(points) == 0
        ? []
        : concat(
            points,
            [for (i = [len(points) - 1 : -1 : 0]) points[i]]
        );

// Report that stroke conversion cannot preserve holes. In normal experiment
// mode the holes are discarded after a warning; HardErrors converts the same
// condition into an assertion failure.
function LogoSCWarnDiscardedStrokeHoles(region) =
    len(region) <= 1
        ? 0
        : HardErrors
            ? assert(
                false,
                str(
                    "Experimental stroke conversion discards ",
                    len(region) - 1,
                    " hole contour(s)"
                )
            ) 0
            : echo(
                "[WARNING]",
                "Experimental stroke conversion discards holes",
                len(region) - 1
            ) 0;

// Convert evaluated LogoSC regions into zero-width doubled-back regions.
//
// Input is normally ResultContours(evalLogo(cmds)). Each region's outer
// contour is reverse-appended and all hole contours are intentionally dropped.
// Complexity: O(P + H), where P is the number of outer points and H is the
// number of hole contours inspected.
// Precondition: regions uses LogoSC's [outer, hole0, ...] region structure.
// Postcondition: every returned region contains exactly one doubled-back outer
// contour and no holes.
function LogoSCReverseAppendRegions(regions) =
[
    for (region = regions)
        let(_warning = LogoSCWarnDiscardedStrokeHoles(region))
            MakeRegion(LogoSCReverseAppendPoints(RegionOuter(region)))
];



// Render one point list as the union of circular capsules. Each segment is the
// hull of two endpoint circles, producing round caps and round joins without
// explicit miter or fillet calculations.
// Complexity: O(N) hull operations for N points.
// Precondition: points contains 2D coordinate pairs and width is positive.
// Postcondition: emits a valid 2D stroked region centered on the input path.
module RenderCapsuleStrokePath(
    points,
    width = CapsuleStrokeWidth,
    fn = CapsuleStrokeFn)
{
    radius = width / 2;

    assert(width > 0, "Capsule stroke width must be positive");

    if (len(points) == 1)
    {
        translate(points[0])
        {
            circle(r = radius, $fn = fn);
        }
    }

    if (len(points) >= 2)
    {
        union()
        {
            for (i = [0 : len(points) - 2])
            {
                hull()
                {
                    translate(points[i])
                    {
                        circle(r = radius, $fn = fn);
                    }

                    translate(points[i + 1])
                    {
                        circle(r = radius, $fn = fn);
                    }
                }
            }
        }
    }
}

// Return the index of the first region with a nonempty outer contour.
// Complexity: O(R), where R is the number of regions.
// Precondition: regions uses LogoSC's region structure.
// Postcondition: returns -1 if no nonempty outer contour exists.
function LogoSCFirstNonemptyRegionIndex(regions, index = 0) =
    index >= len(regions)
        ? -1
        : len(RegionOuter(regions[index])) > 0
            ? index
            : LogoSCFirstNonemptyRegionIndex(regions, index + 1);

// Render evaluated LogoSC regions as capsule strokes using each region's outer
// contour as a centerline. Hole contours are warned about and discarded.
//
// The normal filled-region evaluator records MOVE destinations but does not
// seed the first mutable contour with the turtle's initial position. When
// addInitialPoint is true, initialPoint is prepended to only the first nonempty
// contour. Later contours created by PENUP/PENDOWN already include their own
// starting point and are left unchanged.
// Complexity: O(P + R) hull operations/search across P points and R regions.
// Precondition: regions uses LogoSC's [outer, hole0, ...] region structure.
// Postcondition: emits stroked 2D geometry for every nonempty outer contour.
module RenderCapsuleStrokeRegions(
    regions,
    width = CapsuleStrokeWidth,
    fn = CapsuleStrokeFn,
    addInitialPoint = true,
    initialPoint = [0, 0])
{
    firstRegionIndex = addInitialPoint
        ? LogoSCFirstNonemptyRegionIndex(regions)
        : -1;

    for (regionIndex = [0 : len(regions) - 1])
    {
        region = regions[regionIndex];
        _warning = LogoSCWarnDiscardedStrokeHoles(region);
        outer = RegionOuter(region);
        strokePoints = regionIndex == firstRegionIndex
            ? concat([initialPoint], outer)
            : outer;

        if (len(strokePoints) > 0)
        {
            RenderCapsuleStrokePath(strokePoints, width = width, fn = fn);
        }
    }
}

// -----------------------------------------------------------------------------
// Experimental command lists
// -----------------------------------------------------------------------------

// Minimal smoke test: draw a 30 x 30 square using only relative LogoSC movement
// and turns. The final TURN restores the original heading.
ExperimentSquare =
[
    [MOVE, 30],
    [TURN, 90],
    [MOVE, 30],
    [TURN, 90],
    [MOVE, 30],
    [TURN, 90],
    [MOVE, 30],
    [TURN, 90]
];

// Zero-width stroke inputs. Each list is evaluated normally, then every outer
// point list is reverse-appended before being passed to the polygon renderer.
ExperimentStrokeLine =
[
    [MOVE, StrokeTestEpsilon],
    [MOVE, 30]
];

ExperimentStrokeBentLine =
[
    [MOVE, StrokeTestEpsilon],
    [MOVE, 30],
    [TURN, 90],
    [MOVE, 30]
];

ExperimentStrokeCrossedLine =
[
    [MOVE, 30],
    [TURN, 135],
    [MOVE, 30],
    [TURN, 135],
    [MOVE, 30]
];

ExperimentStrokeClosedSquare =
[
    [MOVE, 30],
    [TURN, 90],
    [MOVE, 30],
    [TURN, 90],
    [MOVE, 30],
    [TURN, 90],
    [MOVE, 30],
    [TURN, 90]
];

// -----------------------------------------------------------------------------
// Rendering helpers
// -----------------------------------------------------------------------------

module RenderLogoExperiment(
    experimentName,
    cmds,
    index,
    height = LogoExperimentHeight,
    experimentScale = 1,
    experimentColor = undef)
{
    offset = LogoExperimentGridOffset(index);
    useColor = experimentColor == undef
        ? LogoExperimentColor(index[0])
        : experimentColor;

    echo("");
    echo("============================================================");
    echo("LogoExperiment:", experimentName);
    echo("Index:", index);
    echo("Offset:", offset);
    echo("Scale:", experimentScale);
    echo("Color:", useColor);
    echo("============================================================");

    translate([offset[0], offset[1], 0])
    {
        color(useColor)
        {
            linear_extrude(
                height = height,
                center = true,
                convexity = LogoExperimentConvexity
            )
            {
                scale([experimentScale, experimentScale])
                {
                    RenderLogo2D(cmds, convexity = LogoExperimentConvexity);
                }
            }
        }
    }
}


// Render a command list after converting each evaluated outer contour into a
// zero-width doubled-back polygon. This is intentionally experimental and may
// expose degenerate-polygon behavior in OpenSCAD/CGAL.
module RenderLogoReverseAppendExperiment(
    experimentName,
    cmds,
    index,
    height = LogoExperimentHeight,
    experimentScale = 1,
    experimentColor = undef)
{
    offset = LogoExperimentGridOffset(index);
    useColor = experimentColor == undef
        ? LogoExperimentColor(index[0])
        : experimentColor;
    result = evalLogo(cmds);
    strokeRegions = LogoSCReverseAppendRegions(ResultContours(result));

    echo("");
    echo("============================================================");
    echo("Logo reverse-append experiment:", experimentName);
    echo("Index:", index);
    echo("Offset:", offset);
    echo("Scale:", experimentScale);
    echo("Color:", useColor);
    echo("============================================================");

    translate([offset[0], offset[1], 0])
    {
        color(useColor)
        {
            linear_extrude(
                height = height,
                center = true,
                convexity = LogoExperimentConvexity
            )
            {
                scale([experimentScale, experimentScale])
                {
                    RenderContours2D(
                        strokeRegions,
                        convexity = LogoExperimentConvexity
                    );
                }
            }
        }
    }
}



// Render a command list as round-ended capsule strokes. This provides a valid
// geometry reference implementation for comparison with the failed zero-width
// reverse-append polygon experiment.
// Complexity: O(P) hull operations across P evaluated path points.
// Precondition: cmds is a valid LogoSC command list and width is positive.
// Postcondition: emits extruded capsule-stroke geometry at the requested grid cell.
module RenderLogoCapsuleExperiment(
    experimentName,
    cmds,
    index,
    width = CapsuleStrokeWidth,
    fn = CapsuleStrokeFn,
    height = LogoExperimentHeight,
    experimentScale = 1,
    experimentColor = undef)
{
    offset = LogoExperimentGridOffset(index);
    useColor = experimentColor == undef
        ? LogoExperimentColor(index[0])
        : experimentColor;
    result = evalLogo(cmds);
    regions = ResultContours(result);

    echo("");
    echo("============================================================");
    echo("Logo capsule-stroke experiment:", experimentName);
    echo("Index:", index);
    echo("Offset:", offset);
    echo("Scale:", experimentScale);
    echo("Width:", width);
    echo("Color:", useColor);
    echo("============================================================");

    translate([offset[0], offset[1], 0])
    {
        color(useColor)
        {
            linear_extrude(
                height = height,
                center = true,
                convexity = LogoExperimentConvexity
            )
            {
                scale([experimentScale, experimentScale])
                {
                    RenderCapsuleStrokeRegions(
                        regions,
                        width = width,
                        fn = fn,
                        addInitialPoint = true,
                        initialPoint = [0, 0]
                    );
                }
            }
        }
    }
}

// Gallery routine similar to RenderAllLogoExamples(), but reserved for work that
// has not yet graduated into the main examples file.
module RenderAllLogoExperiments()
{
    RenderLogoExperiment("square smoke test", ExperimentSquare, [0, 0]);

    RenderLogoReverseAppendExperiment(
        "single line",
        ExperimentStrokeLine,
        [0, 1]
    );
    RenderLogoReverseAppendExperiment(
        "two-line 90-degree bend",
        ExperimentStrokeBentLine,
        [1, 1]
    );
    RenderLogoReverseAppendExperiment(
        "three-line crossed curve",
        ExperimentStrokeCrossedLine,
        [2, 1]
    );
    RenderLogoReverseAppendExperiment(
        "four-line closed square",
        ExperimentStrokeClosedSquare,
        [3, 1]
    );

    RenderLogoCapsuleExperiment(
        "capsule single line",
        ExperimentStrokeLine,
        [0, 2]
    );
    RenderLogoCapsuleExperiment(
        "capsule two-line 90-degree bend",
        ExperimentStrokeBentLine,
        [1, 2]
    );
    RenderLogoCapsuleExperiment(
        "capsule three-line crossed curve",
        ExperimentStrokeCrossedLine,
        [2, 2]
    );
    RenderLogoCapsuleExperiment(
        "capsule four-line closed square",
        ExperimentStrokeClosedSquare,
        [3, 2]
    );
}

if (RunLogoExperiments)
{
    RenderAllLogoExperiments();
}
