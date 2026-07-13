// ============================================================================
// LogoSC-Foundation Core
//
// Core interpreter and renderer.
// See LogoSC-README.md for overview, command reference, and roadmap.
// ============================================================================

// -----------------------------------------------------------------------------
// LogoSC-Foundation
//
// OpenSCAD Logo / Logo-style command evaluator.
// Interpreter uses one Eval* handler function per opcode.
//
// This split-file baseline contains core interpreter controls, constants,
// state functions, trace functions, opcode handlers, and evaluator logic.
// The companion LogoSC-Foundation-Tests.scad file is included at parse time
// below, with test execution gated by LogoSCRunMode == "Tests".
//
// Command format:
//     [MOVE,   len]
//     [TURN,   deltaHeading]
//     [DIR,    absoluteHeading]
//     [SCALE,  scaleMultiplier]
//     [GOTO,   x, y, heading]
//
//     [ARC,         radius, degrees[, segments]]
//
//     [CIRCLE,      radius[, segments]]
//     [REGPOLY,     sides, radius[, rotation]]
//     [RECT,        width, height]
//     [ROUNDEDRECT, width, height, radius[, segments]]
//
//     [HOLE,        cmds]
//
//     [RUN,         cmds[, scale[, maxRec]]]
//
//     [PUSH]
//         Saves the current Logo state [x, y, heading, scale] onto the
//         interpreter state stack.
//
//     [POP]
//         Restores the most recently pushed Logo state. If the stack is empty,
//         this reports a soft error and continues when HardErrors = false.
//
//     [PENUP]
//         Stops adding MOVE/GOTO/ARC destinations to the current contour. Logo
//         position and heading still change.
//
//     [PENDOWN]
//         Starts a new contour at the current Logo location and resumes adding
//         MOVE/GOTO/ARC destinations.
//
//     [REPEAT, count, cmds]
//         Executes cmds count times. The command body can contain MOVE, TURN,
//         RUN, ARC, closed-shape commands, PUSH, POP, PENUP, PENDOWN,
//         nested REPEAT, and other supported Logo commands.
//
// RUN defaults:
//     scale  = 1
//     maxRec = 2
//
// Rendering model:
//     LogoSC returns regions. Each region is [outer, hole0, hole1, ...].
//     Regions render through polygon(points=..., paths=...), so holes are
//     represented by secondary paths inside the same polygon call. Open-stroke
//     rendering is intentionally deferred.
//
// Debug rendering model:
//     LogoSC also provides a preview-only debug renderer that records command
//     execution events directly. It draws z-centered 3D capsules and point
//     markers so low-level MOVE/GOTO/ARC/primitive behavior can be inspected
//     independently of final filled-region output.
// -----------------------------------------------------------------------------
// LogoSC library version
// -----------------------------------------------------------------------------
// Public API version. Bump manually on feature/API milestones; Git records
// normal per-commit source history. Use LogoSCVersionAtLeast() in downstream
// models when a model requires a minimum LogoSC API version.
LogoSCVersionMajor = 2026 + 0;
LogoSCVersionMinor = 2 + 0;
LogoSCVersion = str(LogoSCVersionMajor, ".", LogoSCVersionMinor);

function LogoSCVersionAtLeast(major, minor) =
    (LogoSCVersionMajor > major)
        ? true
        : (LogoSCVersionMajor == major && LogoSCVersionMinor >= minor);

// -----------------------------------------------------------------------------

/* [LogoSC Controls] */

// Circle divisions used for curved geometry. When $fn is greater than zero,
// it overrides $fa and $fs for automatic ARC tessellation. Set $fn to zero to
// use OpenSCAD-style $fa/$fs automatic fragment selection.
$fn = 256;     // [0:32:1024]

// Minimum fragment angle used for automatic ARC tessellation when $fn == 0.
$fa = 12;      // [1:1:90]

// Minimum fragment size used for automatic ARC tessellation when $fn == 0.
$fs = 2;       // [0.1:0.1:20]

// Segment-count convention for curved closed geometry:
//     Explicit ARC/CIRCLE/ROUNDEDRECT segment arguments override $fn/$fa/$fs.
//     Omitted segment arguments use OpenSCAD-style automatic selection:
//         $fn > 0 gives the full-circle fragment count; otherwise $fa/$fs apply.
//     ARC explicit segments count the arc itself. CIRCLE explicit segments count
//     the full circle. ROUNDEDRECT explicit segments count each rounded corner.
//     REGPOLY uses its side count directly and does not consult $fn/$fa/$fs.

// Enable hard-stop interpreter errors.
// false: print [ERROR] and continue the test suite.
// true: use assert() and stop immediately on serious interpreter errors.
HardErrors = false; // [false:true]

// Trace verbosity.
//
// 0 : No trace output.
// 1 : Major entry/exit messages and errors.
// 2 : Static command-list trace (TraceCmds) and summary information.
// 3 : Additional state/contour dumps.
// 4 : Full instruction-by-instruction execution trace from evalLogo().
//
// Higher levels include all lower levels.
TraceLevel = 2; // [0:4]

// Global safety limit for RUN command recursion inside evalLogo().
maxRunRecursions = 5; // [0:20]

// Default per-RUN recursion limit when RUN is written without maxRec.
DefaultRunMaxRecursions = 2; // [0:20]

// Default extrusion height used by LogoSCest().
DefaultTestHeight = 5; // [1:1:20]

// Default top-level run selector. LogoSC-Examples.scad exposes the same
// variable to OpenSCAD Customizer with NoDemo/Examples/Debug/Tests values.
// Tests run only when LogoSCRunMode is explicitly set to "Tests". NoDemo and
// blank strings both leave the foundation test grid suppressed.
LogoSCRunMode = "NoDemo"; // [NoDemo, Examples, Debug, Tests]

// Non-fatal error helper for use inside functions.
function ErrorOrZero(msg, value = undef) =
    HardErrors
        ? assert(false, msg) 0
        : echo("[ERROR]", msg, value) 0;

function SoftError(msg, value = undef) =
    ErrorOrZero(msg, value);

// -----------------------------------------------------------------------------
// Logo command opcodes
// -----------------------------------------------------------------------------
// The '+ 0' keeps implementation constants out of the OpenSCAD Customizer.
MOVE    = 0 + 0;  // [MOVE, len]
TURN    = 1 + 0;  // [TURN, deltaHeading]
DIR     = 2 + 0;  // [DIR, absoluteHeading]
SCALE   = 3 + 0;  // [SCALE, scaleMultiplier]
GOTO    = 4 + 0;  // [GOTO, x, y, heading]
RUN     = 5 + 0;  // [RUN, cmds[, scale[, maxRec]]]
PUSH    = 6 + 0;  // [PUSH] saves current Logo state on the stack.
POP     = 7 + 0;  // [POP] restores the most recently pushed Logo state.
REPEAT  = 8 + 0;  // [REPEAT, count, cmds] executes cmds count times.
PENUP   = 9 + 0;  // [PENUP] disables point emission while movement continues.
PENDOWN = 10 + 0; // [PENDOWN] starts a new contour and resumes point emission.
ARC         = 11 + 0; // [ARC, radius, degrees[, segments]]
CIRCLE      = 12 + 0; // [CIRCLE, radius[, segments]]
REGPOLY     = 13 + 0; // [REGPOLY, sides, radius[, rotation]]
RECT        = 14 + 0; // [RECT, width, height]
ROUNDEDRECT = 15 + 0; // [ROUNDEDRECT, width, height, radius[, segments]]
HOLE        = 16 + 0; // [HOLE, cmds] attaches child contours to the latest region.

// Mathematical constants.
LOGOT_PI = 3.141592653589793 + 0;

// -----------------------------------------------------------------------------
// Logo state indices: [x, y, heading, scale]
// -----------------------------------------------------------------------------
SX = 0 + 0;
SY = 1 + 0;
SH = 2 + 0;
SS = 3 + 0;

// -----------------------------------------------------------------------------
// Pen state values
// -----------------------------------------------------------------------------
PEN_UP   = 0 + 0;
PEN_DOWN = 1 + 0;

// -----------------------------------------------------------------------------
// Command field indices
// -----------------------------------------------------------------------------
COP = 0 + 0;
CA1 = 1 + 0;
CA2 = 2 + 0;
CA3 = 3 + 0;
CA4 = 4 + 0;

// -----------------------------------------------------------------------------
// Evaluator result indices: [state, regions, stack, pen]
// -----------------------------------------------------------------------------
ER_STATE    = 0 + 0;
ER_CONTOURS = 1 + 0;
ER_STACK    = 2 + 0;
ER_PEN      = 3 + 0;

// Access an optional command argument.
//
// Returns defaultValue if the requested command field is absent or undef.
function CmdArg(vCmd, fieldIndex, defaultValue = undef) =
    (vCmd != undef && len(vCmd) > fieldIndex && vCmd[fieldIndex] != undef)
        ? vCmd[fieldIndex]
        : defaultValue;

// Construct an evaluator result vector [state, regions, stack, pen].
function EvalResult(state, contours, stack, pen) =
[
    state,
    contours,
    stack,
    pen
];

function ResultState(result) =
    result[ER_STATE];

function ResultContours(result) =
    result[ER_CONTOURS];

function ResultStack(result) =
    result[ER_STACK];

function ResultPen(result) =
    result[ER_PEN];

// Region structure used by the renderer and evaluator names below:
//     region  = [outerContour, holeContour0, holeContour1, ...]
//     regions = [region0, region1, ...]
//
// A few older helper names still say "contour" because the mutable drawing path
// is one contour. The container is now a region list, not a raw contour list.

// Construct one filled region from an outer contour and optional hole contours.
function MakeRegion(outerContour, holeContours = []) =
    concat([outerContour], holeContours);

// Return the outer contour from a region.
function RegionOuter(region) =
    (len(region) == 0) ? [] : region[0];

// Return all hole contours from a region.
function RegionHoles(region) =
    (len(region) <= 1)
        ? []
        :
        [
            for (i = [1 : len(region) - 1])
                region[i]
        ];

// Replace a region outer contour while preserving any attached holes.
function ReplaceRegionOuter(region, outerContour) =
    MakeRegion(outerContour, RegionHoles(region));

// Return the current mutable contour from the last region.
function CurrentContour(regions) =
    (len(regions) == 0)
        ? []
        : RegionOuter(regions[len(regions) - 1]);

// Replace the current mutable contour in the last region.
function ReplaceCurrentContour(regions, contour) =
    (len(regions) == 0)
        ? [MakeRegion(contour)]
        :
        [
            for (i = [0 : len(regions) - 1])
                (i == len(regions) - 1)
                    ? ReplaceRegionOuter(regions[i], contour)
                    : regions[i]
        ];

// Append a point to the current mutable contour, creating one if needed.
function AddPointToContours(regions, point) =
    ReplaceCurrentContour(
        regions,
        concat(CurrentContour(regions), [point])
    );

// Append a point list to the current mutable contour, creating one if needed.
function AddPointsToContours(regions, points) =
    ReplaceCurrentContour(
        regions,
        concat(CurrentContour(regions), points)
    );

// Return all regions before the current mutable region.
function RegionsBeforeCurrent(regions) =
    (len(regions) <= 1)
        ? []
        :
        [
            for (i = [0 : len(regions) - 2])
                regions[i]
        ];

// Add a finished closed outer region and start a fresh mutable path after it.
//
// If a mutable path already has points, it is preserved as its own region before
// the new closed shape. This makes HOLE attach naturally to the latest stamped
// shape while still preserving partially drawn paths.
function AddClosedContourToContours(regions, contour) =
    (len(regions) == 0)
        ? [MakeRegion(contour), MakeRegion([])]
        : let(
            current = regions[len(regions) - 1],
            keepCurrent = (len(RegionOuter(current)) > 0) ? [current] : []
        )
        concat(
            RegionsBeforeCurrent(regions),
            keepCurrent,
            [MakeRegion(contour), MakeRegion([])]
        );

// Start a new mutable contour at the current Logo state.
function StartContour(regions, state) =
    concat(regions, [MakeRegion([[state[SX], state[SY]]])]);

// Count total points across all rings in one region.
function CountRegionPoints(region, ringIndex = 0) =
    (ringIndex >= len(region))
        ? 0
        : len(region[ringIndex]) + CountRegionPoints(region, ringIndex + 1);

// Count total points across all regions.
//
// Expected recursive use:
//     Calls itself with index + 1 until every region has been counted.
function CountContourPoints(regions, index = 0) =
    (index >= len(regions))
        ? 0
        : CountRegionPoints(regions[index]) + CountContourPoints(regions, index + 1);

// Find the most recent region that has a usable outer contour.
function LastDrawableRegionIndex(regions, index = undef) =
    let(
        i = (index == undef) ? len(regions) - 1 : index
    )
    (i < 0)
        ? -1
        : (len(RegionOuter(regions[i])) >= 3)
            ? i
            : LastDrawableRegionIndex(regions, i - 1);

// True when a HOLE command can attach to an existing region.
function HasHoleTargetRegion(regions) =
    LastDrawableRegionIndex(regions) >= 0;

// Append one hole contour to a specific region.
function AddHoleToRegion(region, holeContour) =
    concat(region, [holeContour]);

// Append one hole contour to the most recent drawable region.
function AddHoleToRegions(regions, holeContour) =
    let(
        targetIndex = LastDrawableRegionIndex(regions)
    )
    (targetIndex < 0)
        ? regions
        :
        [
            for (i = [0 : len(regions) - 1])
                (i == targetIndex)
                    ? AddHoleToRegion(regions[i], holeContour)
                    : regions[i]
        ];

// Append multiple hole contours to the most recent drawable region.
function AddHolesToRegions(regions, holeContours, index = 0) =
    (index >= len(holeContours))
        ? regions
        : AddHolesToRegions(
            AddHoleToRegions(regions, holeContours[index]),
            holeContours,
            index + 1
        );

// Extract all closed rings from a region list. Used by HOLE child evaluation.
function ClosedContoursFromRegions(regions) =
    [
        for (region = regions)
            for (ring = region)
                if (len(ring) >= 3)
                    ring
    ];

// Count closed rings in a region list.
function CountClosedContours(regions) =
    len(ClosedContoursFromRegions(regions));


// -----------------------------------------------------------------------------
// Rendering helpers and public 2D renderer modules
// -----------------------------------------------------------------------------
// LogoSC's evaluator returns regions, not OpenSCAD geometry. These helpers turn
// evaluated regions into 2D polygon() output. User models can wrap RenderLogo2D()
// in native OpenSCAD linear_extrude(), rotate_extrude(), difference(), union(),
// translate(), and related modeling operations.
//
// LogoSC intentionally does not wrap OpenSCAD's extrusion operators. Keeping the
// public renderer 2D-only avoids forwarding every extrusion parameter and leaves
// 3D composition under normal OpenSCAD control.

// Convert one region into the flat point list required by polygon().
function RegionRenderPoints(region) =
    [
        for (ring = region)
            for (point = ring)
                point
    ];

// Return the starting flat-point index for one ring inside a region.
function RegionPathStart(region, pathIndex, ringIndex = 0) =
    (ringIndex >= pathIndex)
        ? 0
        : len(region[ringIndex]) + RegionPathStart(region, pathIndex, ringIndex + 1);

// Convert one ring inside a region into polygon() path indices.
function RegionRenderPath(region, pathIndex) =
    let(
        start = RegionPathStart(region, pathIndex),
        count = len(region[pathIndex])
    )
    [
        for (i = [0 : count - 1])
            start + i
    ];

// Convert all drawable rings inside a region into polygon() paths.
function RegionRenderPaths(region) =
    [
        for (pathIndex = [0 : len(region) - 1])
            if (len(region[pathIndex]) >= 3)
                RegionRenderPath(region, pathIndex)
    ];

// Render one evaluated LogoSC region as a 2D polygon.
module RenderRegion2D(region, convexity = 10)
{
    outer = RegionOuter(region);

    if (len(outer) >= 3)
    {
        polygon(
            points = RegionRenderPoints(region),
            paths = RegionRenderPaths(region),
            convexity = convexity
        );
    }
    else if (len(outer) > 0)
    {
        echo("[ERROR]", "Region outer has fewer than three points", region);

        translate(outer[0])
        {
            square([2, 2], center = true);
        }
    }
}

// Render all evaluated LogoSC regions as 2D polygons.
module RenderContours2D(regions, convexity = 10)
{
    for (i = [0 : len(regions) - 1])
    {
        RenderRegion2D(regions[i], convexity);
    }
}


// Evaluate a LogoSC command list and render the resulting 2D regions.
module RenderLogo2D(cmds, convexity = 10)
{
    result = evalLogo(cmds);
    RenderContours2D(ResultContours(result), convexity);
}


// -----------------------------------------------------------------------------
// Preview-only debug event extraction and renderer
// -----------------------------------------------------------------------------
// These helpers are for visual debugging, not manufacturable model generation.
// They use a separate command-event evaluator instead of deriving paths from
// filled contours, so pen-up movement, primitive tessellation, RUN/REPEAT
// expansion, and command endpoints can be inspected directly.

// Debug segment kinds. These are implementation-facing values used by
// RenderLogoDebug(); callers should prefer the public renderer parameters over
// depending on the numeric values.
DEBUG_SEG_MOVE      = 0 + 0;
DEBUG_SEG_GOTO      = 1 + 0;
DEBUG_SEG_ARC       = 2 + 0;
DEBUG_SEG_PRIMITIVE = 3 + 0;

// Debug segment record indices:
//     [kind, fromPoint, toPoint, pen, opcode]
DS_KIND = 0 + 0;
DS_FROM = 1 + 0;
DS_TO   = 2 + 0;
DS_PEN  = 3 + 0;
DS_OP   = 4 + 0;

// Debug evaluator result indices:
//     [state, stack, pen, segments, points]
DR_STATE    = 0 + 0;
DR_STACK    = 1 + 0;
DR_PEN      = 2 + 0;
DR_SEGMENTS = 3 + 0;
DR_POINTS   = 4 + 0;

function DebugPointFromState(state) =
[
    state[SX],
    state[SY]
];

function DebugSegmentFromPoints(kind, fromPoint, toPoint, pen, op) =
[
    kind,
    fromPoint,
    toPoint,
    pen,
    op
];

function DebugSegmentFromStates(kind, fromState, toState, pen, op) =
    DebugSegmentFromPoints(
        kind,
        DebugPointFromState(fromState),
        DebugPointFromState(toState),
        pen,
        op
    );

function DebugResult(state, stack, pen, segments, points) =
[
    state,
    stack,
    pen,
    segments,
    points
];

function ResultDebugState(result) =
    result[DR_STATE];

function ResultDebugStack(result) =
    result[DR_STACK];

function ResultDebugPen(result) =
    result[DR_PEN];

function ResultDebugSegments(result) =
    result[DR_SEGMENTS];

function ResultDebugPoints(result) =
    result[DR_POINTS];

// Convert an open point path into debug segments.
function DebugOpenPathSegments(points, kind, pen, op) =
    (len(points) < 2)
        ? []
        :
        [
            for (i = [0 : len(points) - 2])
                DebugSegmentFromPoints(kind, points[i], points[i + 1], pen, op)
        ];

// Convert a closed point path into debug segments, including the closing edge.
function DebugClosedPathSegments(points, kind, pen, op) =
    (len(points) < 2)
        ? []
        :
        [
            for (i = [0 : len(points) - 1])
                DebugSegmentFromPoints(
                    kind,
                    points[i],
                    points[(i + 1) % len(points)],
                    pen,
                    op
                )
        ];

function DebugAppendStationaryPoint(state, stack, pen, segments, points) =
    DebugResult(state, stack, pen, segments, concat(points, [DebugPointFromState(state)]));

function DebugEvalMove(vCmd, state, stack, pen, segments, points) =
    (len(vCmd) <= CA1)
        ? let(_err = SoftError("Malformed MOVE command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : let(
            nextState = stateMove(state, CmdArg(vCmd, CA1), state[SS]),
            nextSegment = DebugSegmentFromStates(
                DEBUG_SEG_MOVE,
                state,
                nextState,
                pen,
                MOVE
            )
        )
        DebugResult(
            nextState,
            stack,
            pen,
            concat(segments, [nextSegment]),
            concat(points, [DebugPointFromState(nextState)])
        );

function DebugEvalGoto(vCmd, state, stack, pen, segments, points) =
    (len(vCmd) <= CA3)
        ? let(_err = SoftError("Malformed GOTO command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : let(
            nextState = stateGoto(
                CmdArg(vCmd, CA1),
                CmdArg(vCmd, CA2),
                CmdArg(vCmd, CA3),
                state[SS]
            ),
            nextSegment = DebugSegmentFromStates(
                DEBUG_SEG_GOTO,
                state,
                nextState,
                pen,
                GOTO
            )
        )
        DebugResult(
            nextState,
            stack,
            pen,
            concat(segments, [nextSegment]),
            concat(points, [DebugPointFromState(nextState)])
        );

function DebugEvalTurn(vCmd, state, stack, pen, segments, points) =
    (len(vCmd) <= CA1)
        ? let(_err = SoftError("Malformed TURN command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : DebugAppendStationaryPoint(
            stateTurn(state, CmdArg(vCmd, CA1)),
            stack,
            pen,
            segments,
            points
        );

function DebugEvalDir(vCmd, state, stack, pen, segments, points) =
    (len(vCmd) <= CA1)
        ? let(_err = SoftError("Malformed DIR command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : DebugAppendStationaryPoint(
            stateDir(state, CmdArg(vCmd, CA1)),
            stack,
            pen,
            segments,
            points
        );

function DebugEvalScale(vCmd, state, stack, pen, segments, points) =
    (len(vCmd) <= CA1)
        ? let(_err = SoftError("Malformed SCALE command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : DebugAppendStationaryPoint(
            stateScale(state, CmdArg(vCmd, CA1)),
            stack,
            pen,
            segments,
            points
        );

function DebugEvalPush(vCmd, state, stack, pen, segments, points) =
    DebugAppendStationaryPoint(state, concat(stack, [state]), pen, segments, points);

function DebugEvalPop(vCmd, state, stack, pen, segments, points) =
    (len(stack) == 0)
        ? let(_err = SoftError("POP with empty state stack", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : let(
            restoredState = stack[len(stack) - 1],
            nextStack =
                (len(stack) <= 1)
                    ? []
                    :
                    [
                        for (i = [0 : len(stack) - 2])
                            stack[i]
                    ]
        )
        DebugAppendStationaryPoint(restoredState, nextStack, pen, segments, points);

function DebugEvalPenUp(vCmd, state, stack, pen, segments, points) =
    DebugAppendStationaryPoint(state, stack, PEN_UP, segments, points);

function DebugEvalPenDown(vCmd, state, stack, pen, segments, points) =
    DebugAppendStationaryPoint(state, stack, PEN_DOWN, segments, points);

function DebugEvalArc(vCmd, state, stack, pen, segments, points) =
    (len(vCmd) <= CA2)
        ? let(_err = SoftError("Malformed ARC command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : (ArcRadius(vCmd) < 0)
            ? let(_err = SoftError("ARC radius must be nonnegative", vCmd))
            DebugResult(state, stack, pen, segments, points)
            : (ArcHasExplicitSegments(vCmd) && ArcExplicitSegments(vCmd) <= 0)
                ? let(_err = SoftError("ARC segment count must be positive", vCmd))
                DebugResult(state, stack, pen, segments, points)
                : (ArcDegrees(vCmd) == 0)
                    ? DebugResult(state, stack, pen, segments, points)
                    : (ArcRadius(vCmd) == 0 || ArcRadius(vCmd) * state[SS] == 0)
                        ? DebugAppendStationaryPoint(
                            stateTurn(state, ArcDegrees(vCmd)),
                            stack,
                            pen,
                            segments,
                            points
                        )
                        : let(
                            radius = ArcRadius(vCmd),
                            degrees = ArcDegrees(vCmd),
                            scaledRadius = radius * state[SS],
                            arcSegments = ArcSegmentCount(vCmd, state),
                            arcPoints = ArcPoints(state, scaledRadius, degrees, arcSegments),
                            pathPoints = concat([DebugPointFromState(state)], arcPoints),
                            nextState = stateArc(state, radius, degrees, state[SS])
                        )
                        DebugResult(
                            nextState,
                            stack,
                            pen,
                            concat(
                                segments,
                                DebugOpenPathSegments(pathPoints, DEBUG_SEG_ARC, pen, ARC)
                            ),
                            concat(points, arcPoints)
                        );

function DebugEvalCircle(vCmd, state, stack, pen, segments, points) =
    (len(vCmd) <= CA1)
        ? let(_err = SoftError("Malformed CIRCLE command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : (CircleRadius(vCmd) < 0)
            ? let(_err = SoftError("CIRCLE radius must be nonnegative", vCmd))
            DebugResult(state, stack, pen, segments, points)
            : (CircleHasExplicitSegments(vCmd) && CircleExplicitSegments(vCmd) < 3)
                ? let(_err = SoftError("CIRCLE segment count must be at least 3", vCmd))
                DebugResult(state, stack, pen, segments, points)
                : let(
                    scaledRadius = CircleRadius(vCmd) * abs(state[SS])
                )
                (scaledRadius == 0)
                    ? DebugResult(state, stack, pen, segments, points)
                    : let(
                        contour = CircleContour(
                            state,
                            scaledRadius,
                            CircleSegmentCount(vCmd, state)
                        )
                    )
                    DebugResult(
                        state,
                        stack,
                        pen,
                        concat(
                            segments,
                            DebugClosedPathSegments(
                                contour,
                                DEBUG_SEG_PRIMITIVE,
                                pen,
                                CIRCLE
                            )
                        ),
                        concat(points, contour)
                    );

function DebugEvalRegPoly(vCmd, state, stack, pen, segments, points) =
    (len(vCmd) <= CA2)
        ? let(_err = SoftError("Malformed REGPOLY command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : (RegPolySides(vCmd) < 3)
            ? let(_err = SoftError("REGPOLY side count must be at least 3", vCmd))
            DebugResult(state, stack, pen, segments, points)
            : (RegPolyRadius(vCmd) < 0)
                ? let(_err = SoftError("REGPOLY radius must be nonnegative", vCmd))
                DebugResult(state, stack, pen, segments, points)
                : let(
                    scaledRadius = RegPolyRadius(vCmd) * abs(state[SS])
                )
                (scaledRadius == 0)
                    ? DebugResult(state, stack, pen, segments, points)
                    : let(
                        contour = RegPolyContour(
                            state,
                            scaledRadius,
                            RegPolySides(vCmd),
                            RegPolyRotation(vCmd)
                        )
                    )
                    DebugResult(
                        state,
                        stack,
                        pen,
                        concat(
                            segments,
                            DebugClosedPathSegments(
                                contour,
                                DEBUG_SEG_PRIMITIVE,
                                pen,
                                REGPOLY
                            )
                        ),
                        concat(points, contour)
                    );

function DebugEvalRect(vCmd, state, stack, pen, segments, points) =
    (len(vCmd) <= CA2)
        ? let(_err = SoftError("Malformed RECT command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : (RectWidth(vCmd) <= 0 || RectHeight(vCmd) <= 0)
            ? let(_err = SoftError("RECT width and height must be positive", vCmd))
            DebugResult(state, stack, pen, segments, points)
            : let(
                scaledWidth = RectWidth(vCmd) * abs(state[SS]),
                scaledHeight = RectHeight(vCmd) * abs(state[SS])
            )
            (scaledWidth == 0 || scaledHeight == 0)
                ? DebugResult(state, stack, pen, segments, points)
                : let(
                    contour = RectContour(state, scaledWidth, scaledHeight)
                )
                DebugResult(
                    state,
                    stack,
                    pen,
                    concat(
                        segments,
                        DebugClosedPathSegments(contour, DEBUG_SEG_PRIMITIVE, pen, RECT)
                    ),
                    concat(points, contour)
                );

function DebugEvalRoundedRect(vCmd, state, stack, pen, segments, points) =
    (len(vCmd) <= CA3)
        ? let(_err = SoftError("Malformed ROUNDEDRECT command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : (RoundedRectWidth(vCmd) <= 0 || RoundedRectHeight(vCmd) <= 0)
            ? let(
                _err = SoftError(
                    "ROUNDEDRECT width and height must be positive",
                    vCmd
                )
            )
            DebugResult(state, stack, pen, segments, points)
            : (RoundedRectRadius(vCmd) < 0)
                ? let(_err = SoftError("ROUNDEDRECT radius must be nonnegative", vCmd))
                DebugResult(state, stack, pen, segments, points)
                : (
                    RoundedRectHasExplicitSegments(vCmd)
                    && RoundedRectExplicitSegments(vCmd) <= 0
                )
                    ? let(
                        _err = SoftError(
                            "ROUNDEDRECT segment count must be positive",
                            vCmd
                        )
                    )
                    DebugResult(state, stack, pen, segments, points)
                    : let(
                        scaledWidth = RoundedRectWidth(vCmd) * abs(state[SS]),
                        scaledHeight = RoundedRectHeight(vCmd) * abs(state[SS]),
                        scaledRadius = RoundedRectRadius(vCmd) * abs(state[SS])
                    )
                    (scaledWidth == 0 || scaledHeight == 0)
                        ? DebugResult(state, stack, pen, segments, points)
                        : let(
                            contour = RoundedRectContour(
                                state,
                                scaledWidth,
                                scaledHeight,
                                scaledRadius,
                                RoundedRectSegmentCount(vCmd, state)
                            )
                        )
                        DebugResult(
                            state,
                            stack,
                            pen,
                            concat(
                                segments,
                                DebugClosedPathSegments(
                                    contour,
                                    DEBUG_SEG_PRIMITIVE,
                                    pen,
                                    ROUNDEDRECT
                                )
                            ),
                            concat(points, contour)
                        );

function DebugEvalHole(vCmd, state, stack, pen, segments, points, maxRec) =
    (len(vCmd) <= CA1)
        ? let(_err = SoftError("Malformed HOLE command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : let(
            childCmds = HoleCmds(vCmd)
        )
        (len(childCmds) == 0)
            ? let(_err = SoftError("HOLE child command list is empty", vCmd))
            DebugResult(state, stack, pen, segments, points)
            : let(
                childResult = evalLogoDebug(
                    childCmds,
                    state,
                    0,
                    maxRec,
                    [],
                    PEN_DOWN,
                    [],
                    []
                )
            )
            DebugResult(
                state,
                stack,
                pen,
                concat(segments, ResultDebugSegments(childResult)),
                concat(points, ResultDebugPoints(childResult))
            );

function DebugEvalRun(vCmd, state, stack, pen, segments, points, maxRec) =
    let(
        childCmds = RunCmds(vCmd),
        localMaxRec = RunMaxRec(vCmd)
    )
    (len(childCmds) == 0)
        ? DebugResult(state, stack, pen, segments, points)
        : (maxRec <= 0 || localMaxRec <= 0)
            ? let(_err = SoftError("RUN recursion limit reached", vCmd))
            DebugResult(state, stack, pen, segments, points)
            : let(
                nextMaxRec = min2(maxRec - 1, localMaxRec - 1),
                nextScale = RunScale(vCmd) * state[SS],
                nextState = stateMake(state[SX], state[SY], state[SH], nextScale),
                childResult = evalLogoDebug(
                    childCmds,
                    nextState,
                    0,
                    nextMaxRec,
                    stack,
                    pen,
                    [],
                    []
                )
            )
            DebugResult(
                ResultDebugState(childResult),
                ResultDebugStack(childResult),
                ResultDebugPen(childResult),
                concat(segments, ResultDebugSegments(childResult)),
                concat(points, ResultDebugPoints(childResult))
            );

function DebugEvalRepeat(vCmd, state, stack, pen, segments, points, maxRec) =
    (len(vCmd) <= CA2)
        ? let(_err = SoftError("Malformed REPEAT command", vCmd))
        DebugResult(state, stack, pen, segments, points)
        : let(
            repeatCount = RepeatCount(vCmd),
            childCmds = RepeatCmds(vCmd)
        )
        (repeatCount <= 0 || len(childCmds) == 0)
            ? DebugResult(state, stack, pen, segments, points)
            : evalRepeatLogoDebug(
                childCmds,
                repeatCount,
                state,
                maxRec,
                stack,
                pen,
                segments,
                points
            );

function DebugEvalOpcode(vCmd, state, stack, pen, segments, points, maxRec) =
      (vCmd == undef)
        ? let(_err = SoftError("Empty or out-of-range command list", undef))
        DebugResult(state, stack, pen, segments, points)
    : (vCmd[COP] == MOVE)
        ? DebugEvalMove(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == TURN)
        ? DebugEvalTurn(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == DIR)
        ? DebugEvalDir(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == SCALE)
        ? DebugEvalScale(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == GOTO)
        ? DebugEvalGoto(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == RUN)
        ? DebugEvalRun(vCmd, state, stack, pen, segments, points, maxRec)
    : (vCmd[COP] == PUSH)
        ? DebugEvalPush(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == POP)
        ? DebugEvalPop(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == PENUP)
        ? DebugEvalPenUp(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == PENDOWN)
        ? DebugEvalPenDown(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == ARC)
        ? DebugEvalArc(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == CIRCLE)
        ? DebugEvalCircle(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == REGPOLY)
        ? DebugEvalRegPoly(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == RECT)
        ? DebugEvalRect(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == ROUNDEDRECT)
        ? DebugEvalRoundedRect(vCmd, state, stack, pen, segments, points)
    : (vCmd[COP] == HOLE)
        ? DebugEvalHole(vCmd, state, stack, pen, segments, points, maxRec)
    : (vCmd[COP] == REPEAT)
        ? DebugEvalRepeat(vCmd, state, stack, pen, segments, points, maxRec)
    : let(
        _err = SoftError(str("Invalid Logo command: ", CmdName(vCmd[COP])), vCmd)
    )
    DebugResult(state, stack, pen, segments, points);

// Evaluate LogoSC commands into preview-only debug events.
//
// Unlike evalLogo(), this records execution events directly instead of final
// filled contours. The result is intended for RenderLogoDebug() and related
// diagnostics. It is not a substitute for RenderLogo2D().
function evalLogoDebug(
    vtCmds,
    state = stateGoto(0, 0, 0, 1),
    index = 0,
    maxRec = maxRunRecursions,
    stack = [],
    pen = PEN_DOWN,
    segments = [],
    points = undef
) =
    let(
        startPoints = points == undef ? [DebugPointFromState(state)] : points,
        vCmd = (len(vtCmds) == 0 || index >= len(vtCmds)) ? undef : vtCmds[index],
        thisResult = DebugEvalOpcode(
            vCmd,
            state,
            stack,
            pen,
            segments,
            startPoints,
            maxRec
        )
    )
    (vCmd == undef)
        ? thisResult
        : (index < len(vtCmds) - 1)
            ? evalLogoDebug(
                vtCmds,
                ResultDebugState(thisResult),
                index + 1,
                maxRec,
                ResultDebugStack(thisResult),
                ResultDebugPen(thisResult),
                ResultDebugSegments(thisResult),
                ResultDebugPoints(thisResult)
            )
            : thisResult;

function evalRepeatLogoDebug(
    childCmds,
    count,
    state,
    maxRec,
    stack,
    pen,
    segments,
    points
) =
    (count <= 0)
        ? DebugResult(state, stack, pen, segments, points)
        : let(
            result = evalLogoDebug(
                childCmds,
                state,
                0,
                maxRec,
                stack,
                pen,
                segments,
                points
            )
        )
        evalRepeatLogoDebug(
            childCmds,
            count - 1,
            ResultDebugState(result),
            maxRec,
            ResultDebugStack(result),
            ResultDebugPen(result),
            ResultDebugSegments(result),
            ResultDebugPoints(result)
        );

function DebugSegmentVisible(segment, showPenUpMoves) =
    showPenUpMoves || segment[DS_PEN] == PEN_DOWN;

function DebugSegmentColor(
    segment,
    moveColor,
    gotoColor,
    arcColor,
    primitiveColor,
    penUpColor) =
    (segment[DS_PEN] == PEN_UP)
        ? penUpColor
        : (segment[DS_KIND] == DEBUG_SEG_GOTO)
            ? gotoColor
            : (segment[DS_KIND] == DEBUG_SEG_ARC)
                ? arcColor
                : (segment[DS_KIND] == DEBUG_SEG_PRIMITIVE)
                    ? primitiveColor
                    : moveColor;

function DebugPointColor(index, pointCount, pointColor, startColor, endColor) =
    (index == 0)
        ? startColor
        : (index == pointCount - 1)
            ? endColor
            : pointColor;

function DebugPointRadius(index, pointCount, pointRadius, startPointRadiusScale, endPointRadiusScale) =
    (index == 0)
        ? pointRadius * startPointRadiusScale
        : (index == pointCount - 1 && pointCount > 1)
            ? pointRadius * endPointRadiusScale
            : pointRadius;

function DebugPointHeight(index, pointCount, pointHeight, startPointHeightScale, endPointHeightScale) =
    (index == 0)
        ? pointHeight * startPointHeightScale
        : (index == pointCount - 1 && pointCount > 1)
            ? pointHeight * endPointHeightScale
            : pointHeight;

module RenderLogoDebugCapsule(
    fromPoint,
    toPoint,
    radius,
    height,
    z = 0,
    fn = 16)
{
    if (radius > 0)
    {
        assert(height > 0, "Debug capsule height must be positive");

        if (fromPoint == toPoint)
        {
            translate([fromPoint[0], fromPoint[1], z])
            {
                cylinder(h = height, r = radius, center = true, $fn = fn);
            }
        }
        else
        {
            hull()
            {
                translate([fromPoint[0], fromPoint[1], z])
                {
                    cylinder(h = height, r = radius, center = true, $fn = fn);
                }

                translate([toPoint[0], toPoint[1], z])
                {
                    cylinder(h = height, r = radius, center = true, $fn = fn);
                }
            }
        }
    }
}

module RenderLogoDebugSegments(
    segments,
    segmentRadius = 0.15,
    segmentHeight = 1,
    showPenUpMoves = true,
    z = 0,
    fn = 16,
    moveColor = [1.0, 0.0, 0.90],
    gotoColor = [0.0, 0.40, 0.12],
    arcColor = [0.95, 0.0, 1.0],
    primitiveColor = [0.42, 0.0, 0.75],
    penUpColor = [1.0, 0.80, 0.90, 0.75],
    penUpHeightScale = 0.50)
{
    if (len(segments) > 0)
    {
        for (i = [0 : len(segments) - 1])
        {
            segment = segments[i];

            if (DebugSegmentVisible(segment, showPenUpMoves))
            {
                color(
                    DebugSegmentColor(
                        segment,
                        moveColor,
                        gotoColor,
                        arcColor,
                        primitiveColor,
                        penUpColor
                    )
                )
                {
                    RenderLogoDebugCapsule(
                        segment[DS_FROM],
                        segment[DS_TO],
                        segmentRadius,
                        segmentHeight * ((segment[DS_PEN] == PEN_UP) ? penUpHeightScale : 1),
                        z = z,
                        fn = fn
                    );
                }
            }
        }
    }
}

module RenderLogoDebugPointMarkers(
    points,
    pointRadius = 0.30,
    pointHeight = 2,
    z = 0,
    fn = 20,
    pointColor = [1.0, 0.0, 1.0],
    startColor = "Lime",
    endColor = "Red",
    startPointRadiusScale = 0.95,
    startPointHeightScale = 1.15,
    endPointRadiusScale = 1.00,
    endPointHeightScale = 1.00)
{
    if (pointRadius > 0)
    {
        assert(pointHeight > 0, "Debug point height must be positive");

        if (len(points) > 0)
        {
            for (i = [0 : len(points) - 1])
            {
                point = points[i];

                color(DebugPointColor(i, len(points), pointColor, startColor, endColor))
                {
                    translate([point[0], point[1], z])
                    {
                        cylinder(
                            h = DebugPointHeight(
                                i,
                                len(points),
                                pointHeight,
                                startPointHeightScale,
                                endPointHeightScale
                            ),
                            r = DebugPointRadius(
                                i,
                                len(points),
                                pointRadius,
                                startPointRadiusScale,
                                endPointRadiusScale
                            ),
                            center = true,
                            $fn = fn
                        );
                    }
                }
            }
        }
    }
}

// Evaluate and render a preview-only debug overlay for a LogoSC command list.
//
// Segments and points are z-centered so changing segmentHeight/pointHeight makes
// the markers protrude through or above normal extruded RenderLogo2D() output
// without needing extra z translation.
module RenderLogoDebug(
    cmds,
    segmentRadius = 0.15,
    pointRadius = 0.30,
    segmentHeight = 1,
    pointHeight = 2,
    showSegments = true,
    showPoints = true,
    showPenUpMoves = true,
    z = 0,
    fn = 16,
    moveColor = [1.0, 0.0, 0.90],
    gotoColor = [0.0, 0.40, 0.12],
    arcColor = [0.95, 0.0, 1.0],
    primitiveColor = [0.42, 0.0, 0.75],
    penUpColor = [1.0, 0.80, 0.90, 0.75],
    penUpHeightScale = 0.50,
    pointColor = [1.0, 0.0, 1.0],
    startColor = "Lime",
    endColor = "Red",
    startPointRadiusScale = 0.95,
    startPointHeightScale = 1.15,
    endPointRadiusScale = 1.00,
    endPointHeightScale = 1.00)
{
    debugResult = evalLogoDebug(cmds);

    if (showSegments)
    {
        RenderLogoDebugSegments(
            ResultDebugSegments(debugResult),
            segmentRadius = segmentRadius,
            segmentHeight = segmentHeight,
            showPenUpMoves = showPenUpMoves,
            z = z,
            fn = fn,
            moveColor = moveColor,
            gotoColor = gotoColor,
            arcColor = arcColor,
            primitiveColor = primitiveColor,
            penUpColor = penUpColor,
            penUpHeightScale = penUpHeightScale
        );
    }

    if (showPoints)
    {
        RenderLogoDebugPointMarkers(
            ResultDebugPoints(debugResult),
            pointRadius = pointRadius,
            pointHeight = pointHeight,
            z = z,
            fn = fn,
            pointColor = pointColor,
            startColor = startColor,
            endColor = endColor,
            startPointRadiusScale = startPointRadiusScale,
            startPointHeightScale = startPointHeightScale,
            endPointRadiusScale = endPointRadiusScale,
            endPointHeightScale = endPointHeightScale
        );
    }
}

// Return the smaller of two scalar values.
function min2(a, b) =
    (a < b) ? a : b;

// Return the larger of two scalar values.
function max2(a, b) =
    (a > b) ? a : b;

// Construct a Logo state vector [x, y, heading, scale].
function stateMake(x, y, heading, scale) =
[
    x,
    y,
    heading,
    scale
];

// Create a new absolute Logo state at x/y with heading h and scale s.
function stateGoto(x, y, h, s = 1) =
    stateMake(x, y, h, s);

// Low-level Logo state transform: move by len * scale along the current heading.
function stateMove(vState, len, scale) =
    let(
        h = vState[SH],
        x = vState[SX] + scale * len * cos(h),
        y = vState[SY] + scale * len * sin(h),
        s = vState[SS]
    )
    stateMake(x, y, h, s);

// Low-level Logo state transform: rotate heading by a relative angle.
function stateTurn(vState, dh) =
    let(
        x = vState[SX],
        y = vState[SY],
        h = vState[SH] + dh,
        s = vState[SS]
    )
    stateMake(x, y, h, s);

// Low-level Logo state transform: set the heading to an absolute angle.
function stateDir(vState, absh) =
    let(
        x = vState[SX],
        y = vState[SY],
        h = absh,
        s = vState[SS]
    )
    stateMake(x, y, h, s);

// Low-level Logo state transform: multiply the movement scale.
function stateScale(vState, ss) =
    let(
        x = vState[SX],
        y = vState[SY],
        h = vState[SH],
        s = vState[SS] * ss
    )
    stateMake(x, y, h, s);

// Return the side of the heading vector used as the center of curvature.
function ArcSign(degrees) =
    (degrees >= 0) ? 1 : -1;

// Return the center point for an arc beginning at vState.
function ArcCenter(vState, scaledRadius, degrees) =
    let(
        side = ArcSign(degrees),
        h = vState[SH]
    )
    [
        vState[SX] - side * scaledRadius * sin(h),
        vState[SY] + side * scaledRadius * cos(h)
    ];

// Return one tessellated point along an arc.
function ArcPoint(vState, scaledRadius, degrees, fraction) =
    let(
        side = ArcSign(degrees),
        center = ArcCenter(vState, scaledRadius, degrees),
        radialAngle = vState[SH] - side * 90 + degrees * fraction
    )
    [
        center[0] + scaledRadius * cos(radialAngle),
        center[1] + scaledRadius * sin(radialAngle)
    ];

// Return the tessellated point list for an arc, excluding the starting point.
function ArcPoints(vState, scaledRadius, degrees, segments) =
    [
        for (i = [1 : segments])
            ArcPoint(vState, scaledRadius, degrees, i / segments)
    ];

// Low-level Logo state transform: follow a circular arc.
function stateArc(vState, radius, degrees, scale) =
    let(
        scaledRadius = radius * scale,
        nextPoint = ArcPoint(vState, scaledRadius, degrees, 1)
    )
    stateMake(
        nextPoint[0],
        nextPoint[1],
        vState[SH] + degrees,
        vState[SS]
    );


// Convert a local point into world coordinates using current position and heading.
function LocalPointToWorld(vState, localPoint) =
    let(
        h = vState[SH]
    )
    [
        vState[SX] + localPoint[0] * cos(h) - localPoint[1] * sin(h),
        vState[SY] + localPoint[0] * sin(h) + localPoint[1] * cos(h)
    ];

// Return a radial point around the current Logo position.
function ShapeRadialPoint(vState, scaledRadius, angle) =
    LocalPointToWorld(
        vState,
        [
            scaledRadius * cos(angle),
            scaledRadius * sin(angle)
        ]
    );

// Return a closed circle contour centered on the current Logo position.
function CircleContour(vState, scaledRadius, segments) =
    [
        for (i = [0 : segments - 1])
            ShapeRadialPoint(vState, scaledRadius, 360 * i / segments)
    ];

// Return a closed regular-polygon contour centered on the current Logo position.
function RegPolyContour(vState, scaledRadius, sides, rotation) =
    [
        for (i = [0 : sides - 1])
            ShapeRadialPoint(vState, scaledRadius, rotation + 360 * i / sides)
    ];

// Return a closed rectangle contour centered on the current Logo position.
function RectContour(vState, scaledWidth, scaledHeight) =
    let(
        hw = scaledWidth / 2,
        hh = scaledHeight / 2
    )
    [
        LocalPointToWorld(vState, [ hw, -hh]),
        LocalPointToWorld(vState, [ hw,  hh]),
        LocalPointToWorld(vState, [-hw,  hh]),
        LocalPointToWorld(vState, [-hw, -hh])
    ];

// Return one rounded-rectangle corner as local-to-world points.
function RoundedRectCornerPoints(
    vState,
    cornerCenter,
    scaledRadius,
    startAngle,
    segments) =
    [
        for (i = [0 : segments])
            LocalPointToWorld(
                vState,
                [
                    cornerCenter[0] + scaledRadius * cos(startAngle + 90 * i / segments),
                    cornerCenter[1] + scaledRadius * sin(startAngle + 90 * i / segments)
                ]
            )
    ];

// Return a closed rounded-rectangle contour centered on the current Logo position.
function RoundedRectContour(vState, scaledWidth, scaledHeight, scaledRadius, segments) =
    let(
        hw = scaledWidth / 2,
        hh = scaledHeight / 2,
        r = min2(scaledRadius, min2(scaledWidth, scaledHeight) / 2)
    )
    (r <= 0)
        ? RectContour(vState, scaledWidth, scaledHeight)
        : concat(
            RoundedRectCornerPoints(vState, [ hw - r,  hh - r], r,   0, segments),
            RoundedRectCornerPoints(vState, [-hw + r,  hh - r], r,  90, segments),
            RoundedRectCornerPoints(vState, [-hw + r, -hh + r], r, 180, segments),
            RoundedRectCornerPoints(vState, [ hw - r, -hh + r], r, 270, segments)
        );

// Emit a closed contour only when the pen is down.
function EmitClosedContour(contours, contour, pen) =
    (pen == PEN_DOWN && len(contour) >= 3)
        ? AddClosedContourToContours(contours, contour)
        : contours;


// -----------------------------------------------------------------------------
// RUN, REPEAT, ARC, and closed-shape command helpers
// -----------------------------------------------------------------------------

// Extract the child command list from a RUN command.
function RunCmds(logoCmd) =
    CmdArg(logoCmd, CA1, []);

// Extract the optional RUN scale; defaults to 1.
function RunScale(logoCmd) =
    CmdArg(logoCmd, CA2, 1);

// Extract the optional RUN recursion limit; defaults to DefaultRunMaxRecursions.
function RunMaxRec(logoCmd) =
    CmdArg(logoCmd, CA3, DefaultRunMaxRecursions);

// Extract the repeat count from a REPEAT command.
function RepeatCount(logoCmd) =
    CmdArg(logoCmd, CA1, 0);

// Extract the child command list from a REPEAT command.
function RepeatCmds(logoCmd) =
    CmdArg(logoCmd, CA2, []);

// Extract the child command list from a HOLE command.
function HoleCmds(logoCmd) =
    CmdArg(logoCmd, CA1, []);

// Extract the ARC radius.
function ArcRadius(logoCmd) =
    CmdArg(logoCmd, CA1, 0);

// Extract the ARC angle in degrees.
function ArcDegrees(logoCmd) =
    CmdArg(logoCmd, CA2, 0);

// Return true when an ARC command contains an explicit segment count.
function ArcHasExplicitSegments(logoCmd) =
    len(logoCmd) > CA3 && logoCmd[CA3] != undef;

// Extract the explicit ARC segment count, if present.
function ArcExplicitSegments(logoCmd) =
    floor(CmdArg(logoCmd, CA3, 0));

// Compute the OpenSCAD-style full-circle fragment count for an effective radius.
function ArcFullFragments(effectiveRadius) =
    ($fn > 0)
        ? max2(3, floor($fn))
        : ceil(
            max2(
                min2(
                    360 / max2($fa, 0.01),
                    2 * LOGOT_PI * abs(effectiveRadius) / max2($fs, 0.01)
                ),
                5
            )
        );

// Compute automatic ARC segment count from OpenSCAD-style fragment controls.
function ArcAutoSegments(effectiveRadius, degrees) =
    max2(1, ceil(ArcFullFragments(effectiveRadius) * abs(degrees) / 360));

// Return the effective ARC segment count for a command in the current state.
function ArcSegmentCount(logoCmd, state) =
    ArcHasExplicitSegments(logoCmd)
        ? ArcExplicitSegments(logoCmd)
        : ArcAutoSegments(ArcRadius(logoCmd) * state[SS], ArcDegrees(logoCmd));


// Extract the CIRCLE radius.
function CircleRadius(logoCmd) =
    CmdArg(logoCmd, CA1, 0);

// Return true when a CIRCLE command contains an explicit segment count.
function CircleHasExplicitSegments(logoCmd) =
    len(logoCmd) > CA2 && logoCmd[CA2] != undef;

// Extract the explicit CIRCLE segment count, if present.
function CircleExplicitSegments(logoCmd) =
    floor(CmdArg(logoCmd, CA2, 0));

// Return the effective CIRCLE segment count for a command in the current state.
function CircleSegmentCount(logoCmd, state) =
    CircleHasExplicitSegments(logoCmd)
        ? CircleExplicitSegments(logoCmd)
        : ArcAutoSegments(CircleRadius(logoCmd) * abs(state[SS]), 360);

// Extract the REGPOLY side count.
function RegPolySides(logoCmd) =
    floor(CmdArg(logoCmd, CA1, 0));

// Extract the REGPOLY circumradius.
function RegPolyRadius(logoCmd) =
    CmdArg(logoCmd, CA2, 0);

// Extract the optional REGPOLY rotation relative to the current heading.
function RegPolyRotation(logoCmd) =
    CmdArg(logoCmd, CA3, 0);

// Extract the RECT width.
function RectWidth(logoCmd) =
    CmdArg(logoCmd, CA1, 0);

// Extract the RECT height.
function RectHeight(logoCmd) =
    CmdArg(logoCmd, CA2, 0);

// Extract the ROUNDEDRECT width.
function RoundedRectWidth(logoCmd) =
    CmdArg(logoCmd, CA1, 0);

// Extract the ROUNDEDRECT height.
function RoundedRectHeight(logoCmd) =
    CmdArg(logoCmd, CA2, 0);

// Extract the ROUNDEDRECT corner radius.
function RoundedRectRadius(logoCmd) =
    CmdArg(logoCmd, CA3, 0);

// Return true when ROUNDEDRECT contains an explicit per-corner segment count.
function RoundedRectHasExplicitSegments(logoCmd) =
    len(logoCmd) > CA4 && logoCmd[CA4] != undef;

// Extract the explicit ROUNDEDRECT per-corner segment count, if present.
function RoundedRectExplicitSegments(logoCmd) =
    floor(CmdArg(logoCmd, CA4, 0));

// Return the effective ROUNDEDRECT segment count per rounded corner.
function RoundedRectSegmentCount(logoCmd, state) =
    RoundedRectHasExplicitSegments(logoCmd)
        ? RoundedRectExplicitSegments(logoCmd)
        : ArcAutoSegments(RoundedRectRadius(logoCmd) * abs(state[SS]), 90);

// Convert an opcode to a printable command name.
function CmdName(op) =
      (op == MOVE)   ? "MOVE"
    : (op == TURN)   ? "TURN"
    : (op == DIR)    ? "DIR"
    : (op == SCALE)  ? "SCALE"
    : (op == GOTO)   ? "GOTO"
    : (op == RUN)    ? "RUN"
    : (op == PUSH)   ? "PUSH"
    : (op == POP)    ? "POP"
    : (op == REPEAT) ? "REPEAT"
    : (op == PENUP)  ? "PENUP"
    : (op == PENDOWN)? "PENDOWN"
    : (op == ARC)        ? "ARC"
    : (op == CIRCLE)     ? "CIRCLE"
    : (op == REGPOLY)    ? "REGPOLY"
    : (op == RECT)       ? "RECT"
    : (op == ROUNDEDRECT)? "ROUNDEDRECT"
    : (op == HOLE)       ? "HOLE"
    : str("UNKNOWN(", op, ")");

// Emit one command-execution trace line from inside a function.
function TraceExec(level, index, state, vCmd, tag = "TRACE") =
    (level <= TraceLevel)
        ? echo(
            str("[", tag, "]"),
            "index=", index,
            "op=", (vCmd == undef) ? "UNDEF" : CmdName(vCmd[COP]),
            "pos=", [state[SX], state[SY]],
            "heading=", state[SH],
            "scale=", state[SS],
            "cmd=", vCmd
          )
          0
        : 0;

// Emit one generic trace message from inside a function.
function TraceMsg(level, msg, value = undef, tag = "TRACE") =
    (level <= TraceLevel)
        ? echo(str("[", tag, "]"), msg, value) 0
        : 0;

// Print a static trace line for one command. Used by TraceCmds().
module TraceCmd(level, index, state, vCmd, indent = "")
{
    if (level <= TraceLevel)
    {
        echo(
            indent,
            "[", index, "] ",
            (vCmd == undef) ? "UNDEF" : CmdName(vCmd[COP]),
            " Pos=(",
            state[SX], ",", state[SY],
            ") H=", state[SH],
            " S=", state[SS],
            " Cmd=", vCmd
        );
    }
}

// Recursively print the static structure of a command list.
//
// Expected recursive use:
//     Calls itself when a RUN or REPEAT command contains a nonempty child list.
module TraceCmds(
    vtCmds,
    state = stateGoto(0, 0, 0, 1),
    indent = "",
    maxRec = DefaultRunMaxRecursions,
    level = 2)
{
    if (maxRec < 0)
    {
        echo(indent, "*** Maximum trace recursion exceeded ***");
    }
    else if (len(vtCmds) == 0)
    {
        echo(indent, "<empty command list>");
    }
    else
    {
        for (i = [0 : len(vtCmds) - 1])
        {
            cmd = vtCmds[i];
            TraceCmd(level, i, state, cmd, indent);

            if (cmd[COP] == RUN)
            {
                childCmds = RunCmds(cmd);

                if (len(childCmds) == 0)
                {
                    echo(str(indent, "    "), "<empty command list>");
                }
                else
                {
                    TraceCmds(
                        childCmds,
                        state,
                        str(indent, "    "),
                        min2(maxRec - 1, RunMaxRec(cmd) - 1),
                        level
                    );
                }
            }
            else if (cmd[COP] == REPEAT)
            {
                echo(
                    str(indent, "    "),
                    "REPEAT count=",
                    RepeatCount(cmd),
                    " childCmds=",
                    len(RepeatCmds(cmd))
                );

                TraceCmds(
                    RepeatCmds(cmd),
                    state,
                    str(indent, "    "),
                    maxRec,
                    level
                );
            }
            else if (cmd[COP] == HOLE)
            {
                echo(
                    str(indent, "    "),
                    "HOLE childCmds=",
                    len(HoleCmds(cmd))
                );

                TraceCmds(
                    HoleCmds(cmd),
                    state,
                    str(indent, "    "),
                    maxRec,
                    level
                );
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Evaluator
// -----------------------------------------------------------------------------

// Handler result format:
//     EvalResult(nextState, nextRegions, nextStack, nextPen)
//
// Each opcode handler returns this format so evalLogo() can remain a compact
// dispatcher. This also keeps opcode-specific behavior localized.

// Handle MOVE.
//
// Moves the Logo. If the pen is down, adds the destination point to the
// current contour. If the pen is up, only the state changes.
function EvalMove(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA1)
        ? let(
            _err = SoftError("Malformed MOVE command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : let(
            nextState = stateMove(state, CmdArg(vCmd, CA1), state[SS]),
            nextPoint = [nextState[SX], nextState[SY]],
            nextContours =
                (pen == PEN_DOWN)
                    ? AddPointToContours(contours, nextPoint)
                    : contours
        )
        EvalResult(nextState, nextContours, stack, pen);

// Handle GOTO.
//
// Sets absolute position and heading, preserving the current movement scale. If
// the pen is down, the destination point is added to the current contour.
function EvalGoto(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA3)
        ? let(
            _err = SoftError("Malformed GOTO command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : let(
            nextState = stateGoto(
                CmdArg(vCmd, CA1),
                CmdArg(vCmd, CA2),
                CmdArg(vCmd, CA3),
                state[SS]
            ),
            nextPoint = [nextState[SX], nextState[SY]],
            nextContours =
                (pen == PEN_DOWN)
                    ? AddPointToContours(contours, nextPoint)
                    : contours
        )
        EvalResult(nextState, nextContours, stack, pen);

// Handle TURN.
//
// Changes heading by a relative angle.
function EvalTurn(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA1)
        ? let(
            _err = SoftError("Malformed TURN command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : EvalResult(stateTurn(state, CmdArg(vCmd, CA1)), contours, stack, pen);

// Handle DIR.
//
// Sets heading to an absolute angle.
function EvalDir(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA1)
        ? let(
            _err = SoftError("Malformed DIR command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : EvalResult(stateDir(state, CmdArg(vCmd, CA1)), contours, stack, pen);

// Handle SCALE.
//
// Multiplies the current movement scale.
function EvalScale(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA1)
        ? let(
            _err = SoftError("Malformed SCALE command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : EvalResult(stateScale(state, CmdArg(vCmd, CA1)), contours, stack, pen);

// Handle PUSH.
//
// Saves the full Logo state [x, y, heading, scale].
function EvalPush(vCmd, state, contours, stack, pen) =
    EvalResult(state, contours, concat(stack, [state]), pen);

// Handle POP.
//
// Restores the most recently pushed Logo state. It does not draw a connector
// line. If the pen is down and the restored state should begin a new polygon,
// use PENUP before POP and PENDOWN after POP.
function EvalPop(vCmd, state, contours, stack, pen) =
    (len(stack) == 0)
        ? let(
            _err = SoftError("POP with empty state stack", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : let(
            restoredState = stack[len(stack) - 1],
            nextStack =
                (len(stack) <= 1)
                    ? []
                    :
                    [
                        for (i = [0 : len(stack) - 2])
                            stack[i]
                    ]
        )
        EvalResult(restoredState, contours, nextStack, pen);

// Handle PENUP.
//
// Stops adding MOVE/GOTO destinations to contours.
function EvalPenUp(vCmd, state, contours, stack, pen) =
    EvalResult(state, contours, stack, PEN_UP);

// Handle PENDOWN.
//
// Starts a new contour at the current Logo location and resumes adding
// MOVE/GOTO/ARC destinations. If the pen is already down, this still starts a new
// contour, which is useful for intentionally disconnected polygons.
function EvalPenDown(vCmd, state, contours, stack, pen) =
    EvalResult(state, StartContour(contours, state), stack, PEN_DOWN);

// Handle ARC.
//
// Tessellates a circular arc into contour points. Positive angles turn left;
// negative angles turn right. The final heading changes by the requested angle.
function EvalArc(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA2)
        ? let(
            _err = SoftError("Malformed ARC command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : (ArcRadius(vCmd) < 0)
            ? let(
                _err = SoftError("ARC radius must be nonnegative", vCmd)
            )
            EvalResult(state, contours, stack, pen)
            : (ArcHasExplicitSegments(vCmd) && ArcExplicitSegments(vCmd) <= 0)
                ? let(
                    _err = SoftError("ARC segment count must be positive", vCmd)
                )
                EvalResult(state, contours, stack, pen)
                : (ArcDegrees(vCmd) == 0)
                    ? EvalResult(state, contours, stack, pen)
                    : (ArcRadius(vCmd) == 0 || ArcRadius(vCmd) * state[SS] == 0)
                        ? EvalResult(
                            stateTurn(state, ArcDegrees(vCmd)),
                            contours,
                            stack,
                            pen
                        )
                        : let(
                            radius = ArcRadius(vCmd),
                            degrees = ArcDegrees(vCmd),
                            scaledRadius = radius * state[SS],
                            segments = ArcSegmentCount(vCmd, state),
                            arcPoints = ArcPoints(
                                state,
                                scaledRadius,
                                degrees,
                                segments
                            ),
                            nextState = stateArc(state, radius, degrees, state[SS]),
                            nextContours =
                                (pen == PEN_DOWN)
                                    ? AddPointsToContours(contours, arcPoints)
                                    : contours
                        )
                        EvalResult(nextState, nextContours, stack, pen);


// Handle CIRCLE.
//
// Creates a closed filled contour centered on the current Logo position. This is
// a CAD/3D-printing circle, not classic Logo full-circle movement.
function EvalCircle(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA1)
        ? let(
            _err = SoftError("Malformed CIRCLE command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : (CircleRadius(vCmd) < 0)
            ? let(
                _err = SoftError("CIRCLE radius must be nonnegative", vCmd)
            )
            EvalResult(state, contours, stack, pen)
            : (CircleHasExplicitSegments(vCmd) && CircleExplicitSegments(vCmd) < 3)
                ? let(
                    _err = SoftError("CIRCLE segment count must be at least 3", vCmd)
                )
                EvalResult(state, contours, stack, pen)
                : let(
                    scaledRadius = CircleRadius(vCmd) * abs(state[SS])
                )
                (scaledRadius == 0)
                    ? EvalResult(state, contours, stack, pen)
                    : let(
                        segments = CircleSegmentCount(vCmd, state),
                        contour = CircleContour(state, scaledRadius, segments)
                    )
                    EvalResult(
                        state,
                        EmitClosedContour(contours, contour, pen),
                        stack,
                        pen
                    );

// Handle REGPOLY.
//
// Creates a closed regular polygon centered on the current Logo position.
function EvalRegPoly(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA2)
        ? let(
            _err = SoftError("Malformed REGPOLY command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : (RegPolySides(vCmd) < 3)
            ? let(
                _err = SoftError("REGPOLY side count must be at least 3", vCmd)
            )
            EvalResult(state, contours, stack, pen)
            : (RegPolyRadius(vCmd) < 0)
                ? let(
                    _err = SoftError("REGPOLY radius must be nonnegative", vCmd)
                )
                EvalResult(state, contours, stack, pen)
                : let(
                    scaledRadius = RegPolyRadius(vCmd) * abs(state[SS])
                )
                (scaledRadius == 0)
                    ? EvalResult(state, contours, stack, pen)
                    : let(
                        contour = RegPolyContour(
                            state,
                            scaledRadius,
                            RegPolySides(vCmd),
                            RegPolyRotation(vCmd)
                        )
                    )
                    EvalResult(
                        state,
                        EmitClosedContour(contours, contour, pen),
                        stack,
                        pen
                    );

// Handle RECT.
//
// Creates a closed rectangle centered on the current Logo position and oriented
// by the current heading.
function EvalRect(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA2)
        ? let(
            _err = SoftError("Malformed RECT command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : (RectWidth(vCmd) <= 0 || RectHeight(vCmd) <= 0)
            ? let(
                _err = SoftError("RECT width and height must be positive", vCmd)
            )
            EvalResult(state, contours, stack, pen)
            : let(
                scaledWidth = RectWidth(vCmd) * abs(state[SS]),
                scaledHeight = RectHeight(vCmd) * abs(state[SS])
            )
            (scaledWidth == 0 || scaledHeight == 0)
                ? EvalResult(state, contours, stack, pen)
                : let(
                    contour = RectContour(state, scaledWidth, scaledHeight)
                )
                EvalResult(
                    state,
                    EmitClosedContour(contours, contour, pen),
                    stack,
                    pen
                );

// Handle ROUNDEDRECT.
//
// Creates a closed rounded rectangle centered on the current Logo position.
function EvalRoundedRect(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA3)
        ? let(
            _err = SoftError("Malformed ROUNDEDRECT command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : (RoundedRectWidth(vCmd) <= 0 || RoundedRectHeight(vCmd) <= 0)
            ? let(
                _err = SoftError(
                    "ROUNDEDRECT width and height must be positive",
                    vCmd
                )
            )
            EvalResult(state, contours, stack, pen)
            : (RoundedRectRadius(vCmd) < 0)
                ? let(
                    _err = SoftError("ROUNDEDRECT radius must be nonnegative", vCmd)
                )
                EvalResult(state, contours, stack, pen)
                : (
                    RoundedRectHasExplicitSegments(vCmd)
                    && RoundedRectExplicitSegments(vCmd) <= 0
                )
                    ? let(
                        _err = SoftError(
                            "ROUNDEDRECT segment count must be positive",
                            vCmd
                        )
                    )
                    EvalResult(state, contours, stack, pen)
                    : let(
                        scaledWidth = RoundedRectWidth(vCmd) * abs(state[SS]),
                        scaledHeight = RoundedRectHeight(vCmd) * abs(state[SS]),
                        scaledRadius = RoundedRectRadius(vCmd) * abs(state[SS])
                    )
                    (scaledWidth == 0 || scaledHeight == 0)
                        ? EvalResult(state, contours, stack, pen)
                        : let(
                            segments = RoundedRectSegmentCount(vCmd, state),
                            contour = RoundedRectContour(
                                state,
                                scaledWidth,
                                scaledHeight,
                                scaledRadius,
                                segments
                            )
                        )
                        EvalResult(
                            state,
                            EmitClosedContour(contours, contour, pen),
                            stack,
                            pen
                        );

// Handle HOLE.
//
// Evaluates a child command list as one or more closed contours and attaches
// those contours as holes to the most recently emitted outer region. The parent
// Logo state, stack, and pen state are intentionally unchanged.
function EvalHole(vCmd, state, regions, stack, pen, maxRec) =
    (len(vCmd) <= CA1)
        ? let(
            _err = SoftError("Malformed HOLE command", vCmd)
        )
        EvalResult(state, regions, stack, pen)
        : (!HasHoleTargetRegion(regions))
            ? let(
                _err = SoftError("HOLE has no preceding outer region", vCmd)
            )
            EvalResult(state, regions, stack, pen)
            : let(
                childCmds = HoleCmds(vCmd)
            )
            (len(childCmds) == 0)
                ? let(
                    _err = SoftError("HOLE child command list is empty", vCmd)
                )
                EvalResult(state, regions, stack, pen)
                : let(
                    childResult = evalLogoR(
                        childCmds,
                        state,
                        0,
                        maxRec,
                        [],
                        [],
                        PEN_DOWN
                    ),
                    holeContours = ClosedContoursFromRegions(ResultContours(childResult))
                )
                (len(holeContours) == 0)
                    ? let(
                        _err = SoftError("HOLE child produced no closed contours", vCmd)
                    )
                    EvalResult(state, regions, stack, pen)
                    : EvalResult(
                        state,
                        AddHolesToRegions(regions, holeContours),
                        stack,
                        pen
                    );


// Handle RUN.
//
// Expected recursive use:
//     Calls evalLogoR() to evaluate the child command list.
//
// Notes:
//     Empty child command lists are legal no-ops. Recursion-limit exhaustion is
//     also treated as a soft no-op/error so test suites can continue.
function EvalRun(vCmd, state, contours, stack, pen, maxRec) =
    let(
        childCmds = RunCmds(vCmd),
        localMaxRec = RunMaxRec(vCmd)
    )
    (len(childCmds) == 0)
        ? EvalResult(state, contours, stack, pen)
        : (maxRec <= 0 || localMaxRec <= 0)
            ? let(
                _err = SoftError("RUN recursion limit reached", vCmd)
            )
            EvalResult(state, contours, stack, pen)
            : let(
                nextMaxRec = min2(maxRec - 1, localMaxRec - 1),
                nextScale = RunScale(vCmd) * state[SS],
                nextState = stateMake(
                    state[SX],
                    state[SY],
                    state[SH],
                    nextScale
                ),
                recResult = evalLogoR(
                    childCmds,
                    nextState,
                    0,
                    nextMaxRec,
                    [],
                    stack,
                    pen
                ),
                recState = ResultState(recResult),
                recContours = ResultContours(recResult),
                recStack = ResultStack(recResult),
                recPen = ResultPen(recResult),
                nextContours = concat(contours, recContours)
            )
            EvalResult(recState, nextContours, recStack, recPen);

// Handle REPEAT.
//
// Expected recursive use:
//     Calls evalRepeatLogo(), which calls evalLogo() once per iteration.
function EvalRepeat(vCmd, state, contours, stack, pen, maxRec) =
    (len(vCmd) <= CA2)
        ? let(
            _err = SoftError("Malformed REPEAT command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : let(
            repeatCount = RepeatCount(vCmd),
            childCmds = RepeatCmds(vCmd)
        )
        (repeatCount <= 0 || len(childCmds) == 0)
            ? EvalResult(state, contours, stack, pen)
            : evalRepeatLogo(
                childCmds,
                repeatCount,
                state,
                maxRec,
                contours,
                stack,
                pen
            );

// Dispatch one Logo command to its opcode handler.
function EvalOpcode(vCmd, state, contours, stack, pen, maxRec) =
      (vCmd == undef)
        ? let(
            _err = SoftError("Empty or out-of-range command list", undef)
        )
        EvalResult(state, contours, stack, pen)
    : (vCmd[COP] == MOVE)
        ? EvalMove(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == TURN)
        ? EvalTurn(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == DIR)
        ? EvalDir(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == SCALE)
        ? EvalScale(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == GOTO)
        ? EvalGoto(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == RUN)
        ? EvalRun(vCmd, state, contours, stack, pen, maxRec)
    : (vCmd[COP] == PUSH)
        ? EvalPush(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == POP)
        ? EvalPop(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == PENUP)
        ? EvalPenUp(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == PENDOWN)
        ? EvalPenDown(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == ARC)
        ? EvalArc(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == CIRCLE)
        ? EvalCircle(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == REGPOLY)
        ? EvalRegPoly(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == RECT)
        ? EvalRect(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == ROUNDEDRECT)
        ? EvalRoundedRect(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == HOLE)
        ? EvalHole(vCmd, state, contours, stack, pen, maxRec)
    : (vCmd[COP] == REPEAT)
        ? EvalRepeat(vCmd, state, contours, stack, pen, maxRec)
    : let(
        _err = SoftError(str("Invalid Logo command: ", CmdName(vCmd[COP])), vCmd)
    )
    EvalResult(state, contours, stack, pen);

// Evaluate a child Logo command list.
//
// Expected recursive use:
//     Called by EvalRun() when a RUN command expands a child command list.
//
// Notes:
//     Empty command lists are legal no-ops. This is useful for recursive command
//     generators whose base case returns [].
function evalLogoR(
    vtCmds,
    state,
    index,
    maxRec,
    contours = [],
    stack = [],
    pen = PEN_DOWN
) =
    let(
        _traceEnter = TraceMsg(1, "evalLogoR Enter", maxRunRecursions - maxRec)
    )
    (maxRec == undef || maxRec < 0 || maxRec >= 100)
        ? let(
            _err = SoftError("Bad recursion depth", maxRec)
        )
        EvalResult(state, contours, stack, pen)
        : let(
            result = evalLogo(vtCmds, state, index, maxRec, contours, stack, pen),
            _traceExit = TraceMsg(1, "evalLogoR Exit", maxRunRecursions - maxRec),
            _traceState = TraceMsg(2, "evalLogoR State", ResultState(result)),
            _traceContours = TraceMsg(
                3,
                "evalLogoR Contours",
                [len(ResultContours(result)), CountContourPoints(ResultContours(result))]
            )
        )
        result;

// Evaluate Logo commands into a final Logo state and a region list.
//
// Expected recursive use:
//     This function calls itself to iterate through a command list. It also calls
//     evalLogoR() to evaluate RUN child command lists.
//
// State stack:
//     PUSH saves the current Logo state.
//     POP restores the most recently saved Logo state.
//
// Pen state:
//     PENUP stops point emission.
//     PENDOWN starts a new contour and resumes point emission.
//
// Returns:
//     EvalResult(finalState, regions, stack, pen)
//
// Soft-error behavior:
//     If HardErrors is false, bad commands are reported with [ERROR] and treated
//     as no-ops so the full test suite can continue.
function evalLogo(
    vtCmds,
    state = stateGoto(0, 0, 0, 1),
    index = 0,
    maxRec = maxRunRecursions,
    contours = [MakeRegion([])],
    stack = [],
    pen = PEN_DOWN
) =
    let(
        vCmd = (len(vtCmds) == 0 || index >= len(vtCmds)) ? undef : vtCmds[index],
        _traceIndex = TraceMsg(
            2,
            "evalLogo index/maxRec",
            [index, len(vtCmds), maxRec]
        ),
        _traceState = TraceMsg(
            3,
            "evalLogo State/Contours/Stack/Pen",
            [state, contours, stack, pen]
        ),
        _traceCmd = (vCmd == undef)
            ? TraceMsg(1, "Empty or out-of-range command list", index)
            : TraceExec(4, index, state, vCmd),
        thisResult = EvalOpcode(vCmd, state, contours, stack, pen, maxRec)
    )
    (vCmd == undef)
        ? thisResult
        : (index < len(vtCmds) - 1)
            ? evalLogo(
                vtCmds,
                ResultState(thisResult),
                index + 1,
                maxRec,
                ResultContours(thisResult),
                ResultStack(thisResult),
                ResultPen(thisResult)
            )
            : let(
                _traceReturnState = TraceMsg(2, "evalLogo Returning state", ResultState(thisResult)),
                _traceReturnContours = TraceMsg(
                    3,
                    "evalLogo Returning contours",
                    [len(ResultContours(thisResult)), CountContourPoints(ResultContours(thisResult))]
                )
            )
            thisResult;

// Evaluate a REPEAT command body count times.
//
// Expected recursive use:
//     Calls itself with count - 1 until count <= 0.
function evalRepeatLogo(
    childCmds,
    count,
    state,
    maxRec,
    contours,
    stack,
    pen
) =
    (count <= 0)
        ? EvalResult(state, contours, stack, pen)
        : let(
            result = evalLogo(childCmds, state, 0, maxRec, contours, stack, pen)
        )
        evalRepeatLogo(
            childCmds,
            count - 1,
            ResultState(result),
            maxRec,
            ResultContours(result),
            ResultStack(result),
            ResultPen(result)
        );

// -----------------------------------------------------------------------------
// Optional test-suite include
// -----------------------------------------------------------------------------
// OpenSCAD include/use directives are parse-time constructs, so this include is
// unconditional. Test execution is guarded in LogoSC-Foundation-Tests.scad by
// LogoSCRunMode == "Tests".
include <LogoSC-Foundation-Tests.scad>
