// -----------------------------------------------------------------------------
// LogoSC-Foundation-Tests.scad
//
// Regression tests for LogoSC-Foundation-Core.scad.
// This file expects LogoSC-Foundation-Core.scad to have been included first.
// -----------------------------------------------------------------------------

// =============================================================================
//  TEST SUITES
// =============================================================================
//
// This file is intentionally noisy: it exercises the evaluator, RUN command
// expansion, scaling, recursion limiting, pen-state behavior, and soft-error
// behavior. It defines test modules but does not execute them automatically.
// Use LogoSC-Foundation-Test-Runner.scad, or call RunAllLogoSCests() explicitly
// from another entry point after including Core and this file.
//
// =============================================================================

// -----------------------------------------------------------------------------
// Test geometry
// -----------------------------------------------------------------------------
// Public render helpers live in LogoSC-Foundation-Core.scad. The tests use the
// same renderer modules that library users call.

DefaultTestHeight = 5; // [1:1:20]

BasicY     = 0;
RunY0      = 1;
RunY1      = 2;
StateFlowY = 3;
PenY       = 4;
ArcY       = 5;
ShapeY     = 6;
HoleY      = 7;
FailureY   = 8;

TestGridXStep = 35;
TestGridYStep = 35;
TestMarkerXIndex = -0.5;
TestMarkerSize = 7;
TestMarkerHoleRadius = 1.4;
TestMarkerCornerRadius = 1.5;

TestRowMarkerLogo =
[
    [ROUNDEDRECT, TestMarkerSize, TestMarkerSize, TestMarkerCornerRadius, 4],
    [HOLE, [[CIRCLE, TestMarkerHoleRadius, 12]]]
];

TestColor0 = "red";
TestColor1 = "orange";
TestColor2 = "gold";
TestColor3 = "green";
TestColor4 = "cyan";
TestColor5 = "blue";
TestColor6 = "violet";
TestColor7 = "magenta";
TestColor8 = "brown";
TestColor9 = "gray";
TestColorMax = "black";

TestColors =
[
    TestColor0,
    TestColor1,
    TestColor2,
    TestColor3,
    TestColor4,
    TestColor5,
    TestColor6,
    TestColor7,
    TestColor8,
    TestColor9
];

function LogoSCestColor(index) =
    index >= 0 && index < len(TestColors) ? TestColors[floor(index)] : TestColorMax;

function LogoSCestGridOffset(testIndex) =
[
    testIndex[0] * TestGridXStep,
    testIndex[1] * TestGridYStep
];

// Render a colored row marker just left of the visual test grid. The marker
// color is based on the Y index, so a rendered row can be mapped back to its
// suite even when the actual test geometry is complex. The marker itself is a
// tiny LogoSC command list, not a special OpenSCAD square, so the visual test
// image also exercises the public RenderLogo2D() path.
module LogoSCestRowMarker(yIndex, testColor = undef, height = DefaultTestHeight)
{
    useColor = testColor == undef ? LogoSCestColor(yIndex) : testColor;
    offset = LogoSCestGridOffset([TestMarkerXIndex, yIndex]);

    translate([offset[0], offset[1], 0])
    {
        color(useColor)
        {
            linear_extrude(height = height, center = true, convexity = 10)
            {
                RenderLogo2D(TestRowMarkerLogo);
            }
        }
    }
}

module LogoSCestRowMarkers()
{
    for (yIndex = [BasicY : FailureY])
    {
        LogoSCestRowMarker(yIndex);
    }
}

// Run one named Logo test and render all resulting regions.
//
// testIndex is a grid index [xIndex, yIndex], not an absolute drawing position.
// The grid scale constants below convert that logical index to an OpenSCAD
// translation. This makes it easier to map rendered output back to test calls.
// Test colors default to the X index. Columns past TestColor9 use TestColorMax.
module LogoSCest(
    testName,
    vtCmds,
    testIndex = [0, BasicY],
    height = DefaultTestHeight,
    testColor = undef)
{
    offset = LogoSCestGridOffset(testIndex);
    useColor = testColor == undef ? LogoSCestColor(testIndex[0]) : testColor;

    echo("");
    echo("============================================================");
    echo("LogoSCest:", testName);
    echo("Index:", testIndex);
    echo("Offset:", offset);
    echo("Color:", useColor);
    echo("============================================================");

    // Dump the command structure before execution. This is generally much
    // easier to read than the dynamic execution trace from evalLogo().
    TraceCmds(vtCmds);

    result = evalLogo(vtCmds);
    contours = ResultContours(result);

    translate([offset[0], offset[1], 0])
    {
        color(useColor)
        {
            if (CountContourPoints(contours) >= 3)
            {
                linear_extrude(height = height, center = true, convexity = 10)
                {
                    RenderContours2D(contours);
                }
            }
            else
            {
                echo("[ERROR]", "LogoSCest did not produce enough polygon points", [testName, contours]);

                linear_extrude(height = height, center = true)
                {
                    square([2, 2], center = true);
                }
            }
        }
    }

    echo("");
}

// Return true when two scalars are approximately equal.
function LogoNearlyEqual(a, b, tol = 0.001) =
    abs(a - b) <= tol;

// Return true when two Logo states are approximately equal.
function LogoStateNearlyEqual(a, b, tol = 0.001) =
    LogoNearlyEqual(a[SX], b[SX], tol)
    && LogoNearlyEqual(a[SY], b[SY], tol)
    && LogoNearlyEqual(a[SH], b[SH], tol)
    && LogoNearlyEqual(a[SS], b[SS], tol);

// Soft assertion helper for validation-only tests.
module LogoCheck(condition, msg, value = undef)
{
    if (!condition)
    {
        if (HardErrors)
        {
            assert(condition, str(msg, " ", value));
        }
        else
        {
            echo("[ERROR]", msg, value);
        }
    }
}

// Validate final state and total emitted point count for one command list.
module LogoCheckResult(
    label,
    testName,
    vtCmds,
    expectedState,
    expectedPointCount,
    tol = 0.001)
{
    result = evalLogo(vtCmds);
    state = ResultState(result);
    contours = ResultContours(result);
    pointCount = CountContourPoints(contours);

    LogoCheck(
        LogoStateNearlyEqual(state, expectedState, tol),
        str(label, " validation failed: ", testName, " final state"),
        [state, expectedState]
    );

    LogoCheck(
        pointCount == expectedPointCount,
        str(label, " validation failed: ", testName, " point count"),
        [pointCount, expectedPointCount, contours]
    );
}

// Validate final state and total emitted point count for one ARC command list.
module LogoCheckArcResult(
    testName,
    vtCmds,
    expectedState,
    expectedPointCount,
    tol = 0.001)
{
    LogoCheckResult("ARC", testName, vtCmds, expectedState, expectedPointCount, tol);
}

// Validate final state and total emitted point count for one closed-shape command list.
module LogoCheckShapeResult(
    testName,
    vtCmds,
    expectedState,
    expectedPointCount,
    tol = 0.001)
{
    LogoCheckResult("shape", testName, vtCmds, expectedState, expectedPointCount, tol);
}

// Validate outer ring lengths for every nonempty region.
module LogoCheckContourLengths(testName, vtCmds, expectedLengths)
{
    result = evalLogo(vtCmds);
    regions = ResultContours(result);
    actualLengths =
    [
        for (region = regions)
            if (len(RegionOuter(region)) > 0)
                len(RegionOuter(region))
    ];

    LogoCheck(
        actualLengths == expectedLengths,
        str("contour length validation failed: ", testName),
        [actualLengths, expectedLengths, regions]
    );
}

// Validate all ring lengths for every nonempty region.
module LogoCheckRegionRingLengths(testName, vtCmds, expectedRingLengths)
{
    result = evalLogo(vtCmds);
    regions = ResultContours(result);
    actualRingLengths =
    [
        for (region = regions)
            if (len(RegionOuter(region)) > 0)
                [
                    for (ring = region)
                        len(ring)
                ]
    ];

    LogoCheck(
        actualRingLengths == expectedRingLengths,
        str("region ring length validation failed: ", testName),
        [actualRingLengths, expectedRingLengths, regions]
    );
}

// Return every region/ring length, including empty mutable regions.
//
// Unlike LogoCheckRegionRingLengths(), this helper preserves empty regions so
// evaluator-state tests can verify the exact raw EvalResult structure.
function LogoAllRegionRingLengths(regions) =
[
    for (region = regions)
        [
            for (ring = region)
                len(ring)
        ]
];

// Validate the complete public evaluator result for one command list.
//
// This is intentionally independent of rendered geometry. Add further result
// invariants here as LogoSC gains contour validation and, later, open-path
// support without changing the existing focused test cases.
module LogoCheckEvaluatorResult(
    testName,
    vtCmds,
    expectedState,
    expectedRingLengths,
    expectedStack = [],
    expectedPen = PEN_DOWN,
    tol = 0.001)
{
    result = evalLogo(vtCmds);
    state = ResultState(result);
    ringLengths = LogoAllRegionRingLengths(ResultContours(result));
    stack = ResultStack(result);
    pen = ResultPen(result);

    echo("Logo evaluator invariant:", testName);

    LogoCheck(
        LogoStateNearlyEqual(state, expectedState, tol),
        str("evaluator invariant failed: ", testName, " final state"),
        [state, expectedState]
    );

    LogoCheck(
        ringLengths == expectedRingLengths,
        str("evaluator invariant failed: ", testName, " region ring lengths"),
        [ringLengths, expectedRingLengths, ResultContours(result)]
    );

    LogoCheck(
        stack == expectedStack,
        str("evaluator invariant failed: ", testName, " stack"),
        [stack, expectedStack]
    );

    LogoCheck(
        pen == expectedPen,
        str("evaluator invariant failed: ", testName, " pen state"),
        [pen, expectedPen]
    );
}

// Non-rendering evaluator contract tests.
//
// These tests cover today's filled-region evaluator. They do not introduce or
// imply support for open paths. Extend this suite when an open-path data model
// and its validation rules are deliberately added.
module TestEvaluatorInvariantSuiteLogo()
{
    LogoCheckEvaluatorResult(
        "PUSH saves the complete state",
        [
            [MOVE, 10],
            [PUSH],
            [TURN, 90]
        ],
        stateMake(10, 0, 90, 1),
        [[1]],
        [stateMake(10, 0, 0, 1)]
    );

    LogoCheckEvaluatorResult(
        "POP restores state and empties the stack",
        [
            [MOVE, 10],
            [PUSH],
            [TURN, 90],
            [SCALE, 0.5],
            [POP],
            [MOVE, 5]
        ],
        stateMake(15, 0, 0, 1),
        [[2]]
    );

    LogoCheckEvaluatorResult(
        "PENUP moves state without emitting points",
        [
            [PENUP],
            [MOVE, 12],
            [TURN, 90],
            [MOVE, 4]
        ],
        stateMake(12, 4, 90, 1),
        [[0]],
        [],
        PEN_UP
    );

    LogoCheckEvaluatorResult(
        "PENDOWN starts a new filled-region contour",
        [
            [PENUP],
            [MOVE, 10],
            [PENDOWN],
            [MOVE, 5]
        ],
        stateMake(15, 0, 0, 1),
        [[0], [2]]
    );

    LogoCheckEvaluatorResult(
        "scaled RUN preserves parent and child regions",
        [
            [RUN,
                [
                    [MOVE, 4],
                    [TURN, 90],
                    [MOVE, 2]
                ],
                2
            ]
        ],
        stateMake(8, 4, 90, 2),
        [[0], [2]]
    );

    LogoCheckEvaluatorResult(
        "REPEAT propagates state and emitted points",
        [
            [REPEAT, 4,
                [
                    [MOVE, 5],
                    [TURN, 90]
                ]
            ]
        ],
        stateMake(0, 0, 360, 1),
        [[4]]
    );
}

// Basic Logo geometry regression suite.
module TestBasicSuiteLogo()
{
    square =
    [
        [MOVE, 10],
        [TURN, 90],
        [MOVE, 10],
        [TURN, 90],
        [MOVE, 10],
        [TURN, 90],
        [MOVE, 10]
    ];

    rectangle =
    [
        [MOVE, 20],
        [TURN, 90],
        [MOVE, 8],
        [TURN, 90],
        [MOVE, 20],
        [TURN, 90],
        [MOVE, 8]
    ];

    triangle =
    [
        [MOVE, 12],
        [TURN, 120],
        [MOVE, 12],
        [TURN, 120],
        [MOVE, 12]
    ];

    diamond =
    [
        [TURN, 45],
        [MOVE, 10],
        [TURN, 90],
        [MOVE, 10],
        [TURN, 90],
        [MOVE, 10],
        [TURN, 90],
        [MOVE, 10]
    ];

    stepped =
    [
        [MOVE, 8],
        [TURN, 90],
        [MOVE, 4],
        [TURN, -90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 12],
        [TURN, 90],
        [MOVE, 8]
    ];

    smallSquare =
    [
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4]
    ];

    runScaled =
    [
        [RUN, smallSquare, 2],
        [TURN, 0]
    ];

    gotoShape =
    [
        [GOTO, 0, 0, 0],
        [MOVE, 12],
        [GOTO, 12, 8, 180],
        [MOVE, 12],
        [GOTO, 0, 8, -90],
        [MOVE, 8]
    ];

    LogoSCest("basic square", square, [0, BasicY]);
    LogoSCest("rectangle", rectangle, [1, BasicY]);
    LogoSCest("triangle", triangle, [2, BasicY]);
    LogoSCest("rotated diamond", diamond, [3, BasicY]);
    LogoSCest("stepped concave polygon", stepped, [4, BasicY]);
    LogoSCest("RUN scaled square x2", runScaled, [5, BasicY]);
    LogoSCest("GOTO rectangle path", gotoShape, [6, BasicY]);
}

// Explicit recursive command generators.
//
// These use functions rather than self-referential variables. OpenSCAD does not
// handle self-referential variable definitions reliably, and functions make the
// recursion depth concrete at construction time.

// Generate nested box commands for RUN recursion tests.
// Expected recursive use:
//     Calls itself with depth - 1 until depth <= 0.
function RecursiveBoxCmds(depth) =
    (depth <= 0)
        ? []
        :
        [
            [MOVE, 8],
            [TURN, 90],
            [MOVE, 8],
            [TURN, 90],
            [RUN, RecursiveBoxCmds(depth - 1), 0.65, depth],
            [MOVE, 8],
            [TURN, 90],
            [MOVE, 8],
            [TURN, 90]
        ];

// Generate nested spiral commands for RUN recursion tests.
// Expected recursive use:
//     Calls itself with depth - 1 until depth <= 0.
function RecursiveSpiralCmds(depth) =
    (depth <= 0)
        ? []
        :
        [
            [MOVE, 10],
            [TURN, 80],
            [RUN, RecursiveSpiralCmds(depth - 1), 0.75, depth]
        ];

// Generate nested shark-fin commands for RUN recursion tests.
// Expected recursive use:
//     Calls itself with depth - 1 until depth <= 0.
function RecursiveSharkFinCmds(depth) =
    (depth <= 0)
        ? []
        :
        [
            [MOVE, 10],
            [TURN, 135],
            [MOVE, 7],
            [TURN, -90],
            [RUN, RecursiveSharkFinCmds(depth - 1), 0.55, depth],
            [TURN, -45],
            [MOVE, 8]
        ];

// RUN, scaling, and recursion regression suite.
// RUN scaling and nested RUN regression suite.
module TestRunSuiteLogo()
{

    smallSquare =
    [
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4]
    ];

    runDefault =
    [
        [RUN, smallSquare]
    ];

    runHalfScale =
    [
        [RUN, smallSquare, 0.5]
    ];

    runDoubleScale =
    [
        [RUN, smallSquare, 2]
    ];

    runExplicitMaxRec =
    [
        [RUN, smallSquare, 1, 4]
    ];

    nestedRunLeaf =
    [
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4]
    ];

    nestedRunBranch =
    [
        [RUN, nestedRunLeaf, 1.0, 2],
        [TURN, 45],
        [RUN, nestedRunLeaf, 0.7, 2],
        [TURN, -90],
        [RUN, nestedRunLeaf, 0.7, 2]
    ];

    nestedRunTree =
    [
        [RUN, nestedRunBranch, 1.0, 3]
    ];

    LogoSCest("RUN default scale/maxRec", runDefault, [0, RunY0]);
    LogoSCest("RUN half scale", runHalfScale, [1, RunY0]);
    LogoSCest("RUN double scale", runDoubleScale, [2, RunY0]);
    LogoSCest("RUN explicit maxRec=4", runExplicitMaxRec, [3, RunY0]);
    LogoSCest("nested RUN tree", nestedRunTree, [4, RunY0]);
}

// Recursive RUN regression suite.
module TestRunRecursiveSuiteLogo()
{

    recursiveBox =
        RecursiveBoxCmds(3);

    recursiveSpiral =
        RecursiveSpiralCmds(4);

    recursiveSharkFin =
        RecursiveSharkFinCmds(3);

    recursiveBoxShallow =
    [
        [RUN, RecursiveBoxCmds(5), 1.0, 1]
    ];

    recursiveBoxDeep =
    [
        [RUN, RecursiveBoxCmds(5), 1.0, 4]
    ];

    LogoSCest("recursive box depth 3", recursiveBox, [0, RunY1]);
    LogoSCest("recursive spiral depth 4", recursiveSpiral, [1, RunY1]);
    LogoSCest("recursive shark fin depth 3", recursiveSharkFin, [2, RunY1]);
    LogoSCest("recursive box shallow maxRec=1", recursiveBoxShallow, [3, RunY1]);
    LogoSCest("recursive box deep maxRec=4", recursiveBoxDeep, [4, RunY1]);
}

// PUSH/POP and REPEAT regression suite.
// PUSH/POP and REPEAT regression suite.
//
// These tests are intentionally polygon-friendly. Commands such as PUSH/POP can
// create nonlocal Logo-state jumps; because polygon() always connects emitted
// points in order, tests that draw visible branches can become self-intersecting.
// The tests below use PUSH/POP to verify state restoration without drawing
// disconnected branches.
module TestStateFlowSuiteLogo()
{
    // Expected result:
    //     A simple rectangle. PUSH/POP temporarily changes heading and scale,
    //     then restores the original state before drawing continues, so the
    //     final shape is unaffected by the temporary changes.
    stateRestoreBox =
    [
        [MOVE, 12],
        [PUSH],
            [TURN, 45],
            [SCALE, 0.5],
        [POP],
        [TURN, 90],
        [MOVE, 8],
        [TURN, 90],
        [MOVE, 12],
        [TURN, 90],
        [MOVE, 8]
    ];

    // Expected result:
    //     A square with four equal sides.
    repeatedSquare =
    [
        [REPEAT, 4,
            [
                [MOVE, 8],
                [TURN, 90]
            ]
        ]
    ];

    // Expected result:
    //     An equilateral-style triangle.
    repeatedTriangle =
    [
        [REPEAT, 3,
            [
                [MOVE, 10],
                [TURN, 120]
            ]
        ]
    ];

    // Expected result:
    //     A regular hexagon generated by repeatedly RUNning a two-command body.
    repeatWithRun =
    [
        [REPEAT, 6,
            [
                [RUN,
                    [
                        [MOVE, 5],
                        [TURN, 60]
                    ]
                ]
            ]
        ]
    ];

    // Expected result:
    //     Another rectangle. Each iteration performs a temporary PUSH/POP
    //     sequence before drawing the next side, verifying that the state
    //     stack is preserved correctly inside REPEAT.
    pushPopInsideRepeatBox =
    [
        [REPEAT, 4,
            [
                [PUSH],
                    [TURN, 30],
                    [SCALE, 0.25],
                [POP],
                [MOVE, 10],
                [TURN, 90]
            ]
        ]
    ];

    // Expected result:
    //     A square whose sides are produced by an inner REPEAT. Visually it
    //     should be indistinguishable from a normal square, but exercises
    //     nested REPEAT evaluation.
    nestedRepeatBox =
    [
        [REPEAT, 4,
            [
                [REPEAT, 2,
                    [
                        [MOVE, 5]
                    ]
                ],
                [TURN, 90]
            ]
        ]
    ];

    LogoSCest("PUSH/POP state restore box", stateRestoreBox, [0, StateFlowY]);
    LogoSCest("REPEAT square", repeatedSquare, [1, StateFlowY]);
    LogoSCest("REPEAT triangle", repeatedTriangle, [2, StateFlowY]);
    LogoSCest("REPEAT containing RUN hexagon", repeatWithRun, [3, StateFlowY]);
    LogoSCest("PUSH/POP inside REPEAT box", pushPopInsideRepeatBox, [4, StateFlowY]);
    LogoSCest("nested REPEAT box", nestedRepeatBox, [5, StateFlowY]);
}

// PENUP/PENDOWN and multiple-contour regression suite.
module TestPenSuiteLogo()
{
    // Expected result:
    //     Two disconnected squares. PENUP moves the Logo between them without
    //     creating a connecting polygon edge; PENDOWN starts a new contour.
    twoSquares =
    [
        [REPEAT, 4,
            [
                [MOVE, 8],
                [TURN, 90]
            ]
        ],
        [PENUP],
        [DIR, 0],
        [MOVE, 14],
        [PENDOWN],
        [REPEAT, 4,
            [
                [MOVE, 8],
                [TURN, 90]
            ]
        ]
    ];

    // Expected result:
    //     Three separate small triangles arranged left-to-right.
    threeTriangles =
    [
        [REPEAT, 3,
            [
                [MOVE, 6],
                [TURN, 120]
            ]
        ],
        [PENUP],
        [DIR, 0],
        [MOVE, 11],
        [PENDOWN],
        [REPEAT, 3,
            [
                [MOVE, 6],
                [TURN, 120]
            ]
        ],
        [PENUP],
        [DIR, 0],
        [MOVE, 11],
        [PENDOWN],
        [REPEAT, 3,
            [
                [MOVE, 6],
                [TURN, 120]
            ]
        ]
    ];

    // Expected result:
    //     A central square and four separated satellite squares. PUSH/POP moves
    //     around local drawing positions; PENUP/PENDOWN prevents cross-links.
    pushPopSatellites =
    [
        [REPEAT, 4,
            [
                [MOVE, 8],
                [TURN, 90]
            ]
        ],
        [REPEAT, 4,
            [
                [PUSH],
                    [PENUP],
                    [MOVE, 16],
                    [PENDOWN],
                    [REPEAT, 4,
                        [
                            [MOVE, 4],
                            [TURN, 90]
                        ]
                    ],
                [POP],
                [TURN, 90]
            ]
        ]
    ];

    // Expected result:
    //     A row of four disconnected boxes generated by REPEAT. Each iteration
    //     draws one square, lifts the pen, advances, and starts the next contour.
    repeatDisconnected =
    [
        [REPEAT, 4,
            [
                [REPEAT, 4,
                    [
                        [MOVE, 5],
                        [TURN, 90]
                    ]
                ],
                [PENUP],
                [DIR, 0],
                [MOVE, 9],
                [PENDOWN]
            ]
        ]
    ];

    LogoSCest("PENUP/PENDOWN two disconnected squares", twoSquares, [0, PenY]);
    LogoSCest("PENUP/PENDOWN three triangles", threeTriangles, [1, PenY]);
    LogoSCest("PUSH/POP satellite squares with pen control", pushPopSatellites, [2, PenY]);
    LogoSCest("REPEAT disconnected boxes", repeatDisconnected, [3, PenY]);
}

// ARC geometry regression suite.
module TestArcSuiteLogo()
{

    quarterArc =
    [
        [ARC, 10, 90, 8],
        [GOTO, 0, 0, 0]
    ];

    semicircle =
    [
        [ARC, 10, 180, 16],
        [GOTO, 0, 0, 0]
    ];

    circleish =
    [
        [ARC, 10, 360, 32]
    ];

    repeatArcs =
    [
        [REPEAT, 4,
            [
                [ARC, 10, 90, 8]
            ]
        ]
    ];

    runArc =
    [
        [RUN,
            [
                [ARC, 10, 90, 8]
            ]
        ],
        [GOTO, 0, 0, 0]
    ];

    scaledArc =
    [
        [SCALE, 0.5],
        [ARC, 20, 180, 16],
        [GOTO, 0, 0, 0]
    ];

    roundedRect =
    [
        [GOTO, 5, 0, 0],
        [MOVE, 20],
        [ARC, 5, 90, 4],
        [MOVE, 6],
        [ARC, 5, 90, 4],
        [MOVE, 20],
        [ARC, 5, 90, 4],
        [MOVE, 6],
        [ARC, 5, 90, 4]
    ];

    LogoCheckArcResult(
        "quarter arc",
        [[ARC, 10, 90, 4]],
        stateMake(10, 10, 90, 1),
        4
    );

    LogoCheckArcResult(
        "semicircle",
        [[ARC, 10, 180, 4]],
        stateMake(0, 20, 180, 1),
        4
    );

    LogoCheckArcResult(
        "full-circle-ish arc",
        [[ARC, 10, 360, 8]],
        stateMake(0, 0, 360, 1),
        8
    );

    LogoCheckArcResult(
        "pen-up arc",
        [[PENUP], [ARC, 10, 90, 4]],
        stateMake(10, 10, 90, 1),
        0
    );

    LogoCheckArcResult(
        "arc inside REPEAT",
        [[REPEAT, 4, [[ARC, 10, 90, 4]]]],
        stateMake(0, 0, 360, 1),
        16
    );

    LogoCheckArcResult(
        "arc inside RUN",
        [[RUN, [[ARC, 10, 90, 4]]]],
        stateMake(10, 10, 90, 1),
        4
    );

    LogoCheckArcResult(
        "scaled arc",
        [[SCALE, 2], [ARC, 10, 90, 4]],
        stateMake(20, 20, 90, 2),
        4
    );

    LogoCheckArcResult(
        "rounded rectangle",
        roundedRect,
        stateMake(5, 0, 360, 1),
        21
    );

    LogoSCest("ARC quarter sector", quarterArc, [0, ArcY]);
    LogoSCest("ARC semicircle sector", semicircle, [1, ArcY]);
    LogoSCest("ARC full-circle-ish", circleish, [2, ArcY]);
    LogoSCest("ARC inside REPEAT", repeatArcs, [3, ArcY]);
    LogoSCest("ARC inside RUN", runArc, [4, ArcY]);
    LogoSCest("ARC scaled", scaledArc, [5, ArcY]);
    LogoSCest("ARC rounded rectangle", roundedRect, [6, ArcY]);
}


// Closed-shape geometry regression suite.
module TestClosedShapeSuiteLogo()
{

    circleShape =
    [
        [CIRCLE, 8, 24]
    ];

    regularHex =
    [
        [REGPOLY, 6, 8]
    ];

    rectShape =
    [
        [RECT, 20, 10]
    ];

    rotatedRect =
    [
        [DIR, 30],
        [RECT, 20, 8]
    ];

    roundedRectShape =
    [
        [ROUNDEDRECT, 24, 14, 4, 4]
    ];

    scaledCircle =
    [
        [SCALE, 0.5],
        [CIRCLE, 16, 16]
    ];

    LogoCheckShapeResult(
        "circle",
        [[CIRCLE, 10, 16]],
        stateMake(0, 0, 0, 1),
        16
    );

    LogoCheckShapeResult(
        "regular polygon",
        [[REGPOLY, 6, 10]],
        stateMake(0, 0, 0, 1),
        6
    );

    LogoCheckShapeResult(
        "rectangle",
        [[RECT, 20, 8]],
        stateMake(0, 0, 0, 1),
        4
    );

    LogoCheckShapeResult(
        "rounded rectangle command",
        [[ROUNDEDRECT, 20, 10, 2, 4]],
        stateMake(0, 0, 0, 1),
        20
    );

    LogoCheckShapeResult(
        "pen-up circle",
        [[PENUP], [CIRCLE, 10, 16]],
        stateMake(0, 0, 0, 1),
        0
    );

    LogoCheckShapeResult(
        "scaled circle",
        [[SCALE, 2], [CIRCLE, 5, 8]],
        stateMake(0, 0, 0, 2),
        8
    );

    LogoCheckShapeResult(
        "shape inside RUN",
        [[RUN, [[RECT, 10, 4]], 2]],
        stateMake(0, 0, 0, 2),
        4
    );

    LogoCheckContourLengths(
        "shape command does not become the current path",
        [[CIRCLE, 5, 8], [MOVE, 10]],
        [8, 1]
    );

    LogoSCest("CIRCLE centered closed contour", circleShape, [0, ShapeY]);
    LogoSCest("REGPOLY hexagon", regularHex, [1, ShapeY]);
    LogoSCest("RECT centered rectangle", rectShape, [2, ShapeY]);
    LogoSCest("RECT rotated by heading", rotatedRect, [3, ShapeY]);
    LogoSCest("ROUNDEDRECT centered", roundedRectShape, [4, ShapeY]);
    LogoSCest("CIRCLE scaled", scaledCircle, [5, ShapeY]);
}

// Region/hole regression suite.
module TestHoleSuiteLogo()
{

    washer =
    [
        [CIRCLE, 14, 32],
        [HOLE,
            [
                [CIRCLE, 5, 16]
            ]
        ]
    ];

    rectWithHole =
    [
        [RECT, 26, 14],
        [HOLE,
            [
                [CIRCLE, 4, 12]
            ]
        ]
    ];

    roundedPlate =
    [
        [ROUNDEDRECT, 28, 18, 3, 4],
        [HOLE,
            [
                [GOTO, -9, -5, 0],
                [CIRCLE, 1.5, 8],
                [GOTO,  9, -5, 0],
                [CIRCLE, 1.5, 8],
                [GOTO, -9,  5, 0],
                [CIRCLE, 1.5, 8],
                [GOTO,  9,  5, 0],
                [CIRCLE, 1.5, 8]
            ]
        ]
    ];

    repeatedHoles =
    [
        [RECT, 26, 14],
        [REPEAT, 2,
            [
                [HOLE, [[GOTO, -7, 0, 0], [CIRCLE, 2, 8]]],
                [HOLE, [[GOTO,  7, 0, 0], [CIRCLE, 2, 8]]]
            ]
        ]
    ];

    scaledHole =
    [
        [SCALE, 2],
        [RECT, 12, 6],
        [HOLE, [[CIRCLE, 1.5, 8]]]
    ];

    LogoCheckShapeResult(
        "washer",
        washer,
        stateMake(0, 0, 0, 1),
        48
    );

    LogoCheckRegionRingLengths(
        "washer ring lengths",
        washer,
        [[32, 16]]
    );

    LogoCheckShapeResult(
        "rectangle with circular hole",
        rectWithHole,
        stateMake(0, 0, 0, 1),
        16
    );

    LogoCheckRegionRingLengths(
        "rectangle with circular hole ring lengths",
        rectWithHole,
        [[4, 12]]
    );

    LogoCheckShapeResult(
        "rounded plate with four screw holes",
        roundedPlate,
        stateMake(0, 0, 0, 1),
        52
    );

    LogoCheckRegionRingLengths(
        "rounded plate ring lengths",
        roundedPlate,
        [[20, 8, 8, 8, 8]]
    );

    LogoCheckRegionRingLengths(
        "repeated holes attach to same region",
        repeatedHoles,
        [[4, 8, 8, 8, 8]]
    );

    LogoCheckRegionRingLengths(
        "scaled hole",
        scaledHole,
        [[4, 8]]
    );

    LogoSCest("HOLE washer", washer, [0, HoleY]);
    LogoSCest("HOLE rectangle with circle", rectWithHole, [1, HoleY]);
    LogoSCest("HOLE rounded mounting plate", roundedPlate, [2, HoleY]);
    LogoSCest("HOLE repeated circular holes", repeatedHoles, [3, HoleY]);
    LogoSCest("HOLE scaled", scaledHole, [4, HoleY]);
}

// Failure-condition regression suite.
//
// These tests are supposed to produce [ERROR] messages when HardErrors = false.
// They should not abort the complete OpenSCAD run unless HardErrors = true.
module TestFailureSuiteLogo()
{
    badOpcode =
    [
        [999, 10]
    ];

    emptyProgram =
    [
        [RUN, []]
    ];

    recursionLimit =
    [
        [RUN, RecursiveBoxCmds(3), 1.0, 0]
    ];

    malformedRunNoChildList =
    [
        [RUN]
    ];

    gotoMissingArgs =
    [
        [GOTO, 1]
    ];

    popEmptyStack =
    [
        [POP]
    ];

    malformedRepeat =
    [
        [REPEAT]
    ];

    malformedArc =
    [
        [ARC, 10]
    ];

    negativeArcRadius =
    [
        [ARC, -10, 90, 4]
    ];

    badArcSegments =
    [
        [ARC, 10, 90, 0]
    ];


    malformedCircle =
    [
        [CIRCLE]
    ];

    badCircleSegments =
    [
        [CIRCLE, 10, 2]
    ];

    badRegPolySides =
    [
        [REGPOLY, 2, 10]
    ];

    malformedRect =
    [
        [RECT, 10]
    ];

    badRoundedRectRadius =
    [
        [ROUNDEDRECT, 20, 10, -2]
    ];

    malformedHole =
    [
        [HOLE]
    ];

    holeBeforeOuter =
    [
        [HOLE, [[CIRCLE, 3, 8]]]
    ];

    emptyHoleChild =
    [
        [RECT, 10, 10],
        [HOLE, []]
    ];

    holeChildNoClosedContour =
    [
        [RECT, 10, 10],
        [HOLE, [[MOVE, 5]]]
    ];

    LogoSCest(
        "FAIL expected: unknown opcode",
        badOpcode,
        [0, FailureY]
    );

    LogoSCest(
        "FAIL expected: empty RUN is no-op",
        emptyProgram,
        [1, FailureY]
    );

    LogoSCest(
        "FAIL expected: RUN recursion limit reached",
        recursionLimit,
        [2, FailureY]
    );

    LogoSCest(
        "FAIL expected: malformed RUN without child list",
        malformedRunNoChildList,
        [3, FailureY]
    );

    LogoSCest(
        "FAIL expected: malformed GOTO missing args",
        gotoMissingArgs,
        [4, FailureY]
    );

    LogoSCest(
        "FAIL expected: POP with empty state stack",
        popEmptyStack,
        [5, FailureY]
    );

    LogoSCest(
        "FAIL expected: malformed REPEAT no child list",
        malformedRepeat,
        [6, FailureY]
    );

    LogoSCest(
        "FAIL expected: malformed ARC missing angle",
        malformedArc,
        [7, FailureY]
    );

    LogoSCest(
        "FAIL expected: ARC negative radius",
        negativeArcRadius,
        [8, FailureY]
    );

    LogoSCest(
        "FAIL expected: ARC bad segment count",
        badArcSegments,
        [9, FailureY]
    );

    LogoSCest(
        "FAIL expected: malformed CIRCLE missing radius",
        malformedCircle,
        [10, FailureY]
    );

    LogoSCest(
        "FAIL expected: CIRCLE bad segment count",
        badCircleSegments,
        [11, FailureY]
    );

    LogoSCest(
        "FAIL expected: REGPOLY bad side count",
        badRegPolySides,
        [12, FailureY]
    );

    LogoSCest(
        "FAIL expected: malformed RECT missing height",
        malformedRect,
        [13, FailureY]
    );

    LogoSCest(
        "FAIL expected: ROUNDEDRECT negative radius",
        badRoundedRectRadius,
        [14, FailureY]
    );

    LogoSCest(
        "FAIL expected: malformed HOLE missing child list",
        malformedHole,
        [15, FailureY]
    );

    LogoSCest(
        "FAIL expected: HOLE before outer region",
        holeBeforeOuter,
        [16, FailureY]
    );

    LogoSCest(
        "FAIL expected: HOLE empty child list",
        emptyHoleChild,
        [17, FailureY]
    );

    LogoSCest(
        "FAIL expected: HOLE child with no closed contour",
        holeChildNoClosedContour,
        [18, FailureY]
    );
}

// Run all current LogoSC regression suites.
module RunAllLogoSCests()
{
    LogoSCestRowMarkers();

    TestEvaluatorInvariantSuiteLogo();
    TestBasicSuiteLogo();
    TestRunSuiteLogo();
    TestRunRecursiveSuiteLogo();
    TestStateFlowSuiteLogo();
    TestPenSuiteLogo();
    TestArcSuiteLogo();
    TestClosedShapeSuiteLogo();
    TestHoleSuiteLogo();
    TestFailureSuiteLogo();
}
