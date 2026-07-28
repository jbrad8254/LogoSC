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
// Use LogoSC-Foundation-Test-Runner.scad, or call RunAllLogoTestSuites() after
// including Core, Validation, and both passive test-definition files.
//
// =============================================================================

// -----------------------------------------------------------------------------
// Test geometry
// -----------------------------------------------------------------------------
// Public render helpers live in LogoSC-Foundation-Core.scad. The tests use the
// same renderer modules that library users call.

DefaultTestHeight = 5; // [1:1:20]
LogoTestReportLevel = 1; // [0:2]
LogoTestFailFast = false;

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

function LogoSCTestColor(index) =
    index >= 0 && index < len(TestColors) ? TestColors[floor(index)] : TestColorMax;

function LogoSCTestGridOffset(testIndex) =
[
    testIndex[0] * TestGridXStep,
    testIndex[1] * TestGridYStep
];

// Render a colored row marker just left of the visual test grid. The marker
// color is based on the Y index, so a rendered row can be mapped back to its
// suite even when the actual test geometry is complex. The marker itself is a
// tiny LogoSC command list, not a special OpenSCAD square, so the visual test
// image also exercises the public RenderLogo2D() path.
module LogoSCTestRowMarker(yIndex, testColor = undef, height = DefaultTestHeight)
{
    useColor = testColor == undef ? LogoSCTestColor(yIndex) : testColor;
    offset = LogoSCTestGridOffset([TestMarkerXIndex, yIndex]);

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

module LogoSCTestRowMarkers()
{
    for (yIndex = [BasicY : FailureY])
    {
        LogoSCTestRowMarker(yIndex);
    }
}

// Run one named Logo test and render all resulting regions.
//
// testIndex is a grid index [xIndex, yIndex], not an absolute drawing position.
// The grid scale constants below convert that logical index to an OpenSCAD
// translation. This makes it easier to map rendered output back to test calls.
// Test colors default to the X index. Columns past TestColor9 use TestColorMax.
module LogoSCTest(
    testName,
    vtCmds,
    testIndex = [0, BasicY],
    height = DefaultTestHeight,
    testColor = undef,
    expectGeometry = true)
{
    offset = LogoSCTestGridOffset(testIndex);
    useColor = testColor == undef ? LogoSCTestColor(testIndex[0]) : testColor;

    echo("");
    echo("============================================================");
    echo("LogoSCTest:", testName);
    echo("Index:", testIndex);
    echo("Offset:", offset);
    echo("Color:", useColor);
    echo("============================================================");

    // Dump the command structure before execution. This is generally much
    // easier to read than the dynamic execution trace from evalLogo().
    TraceCmds(vtCmds);

    contours = ResultContours(evalLogo(vtCmds));

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
                if (expectGeometry)
                {
                    echo(
                        "[ERROR]",
                        "LogoSCTest did not produce enough polygon points",
                        [testName, contours]
                    );
                }
                else
                {
                    echo("[EXPECTED]", "LogoSCTest produced no polygon geometry", testName);
                }

                linear_extrude(height = height, center = true)
                {
                    square([2, 2], center = true);
                }
            }
        }
    }

    echo("");
}

// Immutable automated-test result: [name, passed, detail]
LTR_NAME   = 0 + 0;
LTR_PASSED = 1 + 0;
LTR_DETAIL = 2 + 0;

// Immutable suite result: [name, testResults]
LTS_NAME    = 0 + 0;
LTS_RESULTS = 1 + 0;

// Geometry test case:
//     [name, commands, gridIndex, expectGeometry, expectSoftError]
LTC_NAME            = 0 + 0;
LTC_COMMANDS        = 1 + 0;
LTC_GRID_INDEX      = 2 + 0;
LTC_EXPECT_GEOMETRY = 3 + 0;
LTC_EXPECT_ERROR    = 4 + 0;

// Aggregate every failure by default. The optional fail-fast assertion is useful
// when isolating one regression; OpenSCAD adds the assertion file/line and caller
// trace, while this message supplies the individual test name and result details.
function LogoTestResult(name, passed, detail = undef) =
    assert(
        !LogoTestFailFast || passed,
        str("LogoSC fail-fast test: ", name, "; detail: ", detail)
    )
    [
        name,
        passed,
        detail
    ];

function LogoTestResultName(result) =
    result[LTR_NAME];

function LogoTestResultPassed(result) =
    result[LTR_PASSED];

function LogoTestResultDetail(result) =
    result[LTR_DETAIL];

function LogoTestSuiteResult(name, results) =
[
    name,
    results
];

function LogoTestSuiteName(suite) =
    suite[LTS_NAME];

function LogoTestSuiteResults(suite) =
    suite[LTS_RESULTS];

function LogoFailedTestResults(results) =
[
    for (result = results)
        if (!LogoTestResultPassed(result))
            result
];

function LogoPassedTestCount(results) =
    len(results) - len(LogoFailedTestResults(results));

function LogoTestSuitePassed(suite) =
    len(LogoFailedTestResults(LogoTestSuiteResults(suite))) == 0;

function LogoGeometryTestCase(
    name,
    commands,
    gridIndex,
    expectGeometry = true,
    expectSoftError = false) =
[
    name,
    commands,
    gridIndex,
    expectGeometry,
    expectSoftError
];

function LogoExpectedErrorTestCase(
    name,
    commands,
    gridIndex,
    expectGeometry = false) =
    LogoGeometryTestCase(name, commands, gridIndex, expectGeometry, true);

function LogoGeometryTestResult(testCase) =
    let(
        // Result lists may be traversed repeatedly by OpenSCAD. Render expected
        // diagnostics once in their visual row; suppress duplicate error echoes
        // while computing the immutable geometry-outcome record.
        $LogoSCSuppressErrors = testCase[LTC_EXPECT_ERROR],
        result = evalLogo(testCase[LTC_COMMANDS]),
        contours = ResultContours(result),
        pointCount = CountContourPoints(contours),
        expectGeometry = testCase[LTC_EXPECT_GEOMETRY],
        passed = expectGeometry ? pointCount >= 3 : pointCount < 3
    )
    LogoTestResult(
        testCase[LTC_NAME],
        passed,
        [
            "expectedGeometry", expectGeometry,
            "expectedSoftError", testCase[LTC_EXPECT_ERROR],
            "pointCount", pointCount,
            "contours", contours
        ]
    );

function LogoGeometryTestResults(testCases) =
[
    for (testCase = testCases)
        LogoGeometryTestResult(testCase)
];

module RenderLogoGeometryTestCases(testCases)
{
    for (testCase = testCases)
    {
        LogoSCTest(
            testCase[LTC_NAME],
            testCase[LTC_COMMANDS],
            testCase[LTC_GRID_INDEX],
            expectGeometry = testCase[LTC_EXPECT_GEOMETRY]
        );
    }
}

// Report every failure, then per-suite and global totals. Report level 0 emits
// only the global result, 1 adds suite summaries and failures, and 2 lists every
// named automated test. A failed aggregate run ends with a human-visible banner.
module ReportLogoTestRun(suites, reportLevel = LogoTestReportLevel)
{
    allResults =
    [
        for (suite = suites)
            for (result = LogoTestSuiteResults(suite))
                result
    ];
    failedResults = LogoFailedTestResults(allResults);
    failedSuites =
    [
        for (suite = suites)
            if (!LogoTestSuitePassed(suite))
                suite
    ];

    echo("");
    echo("============================================================");
    echo("LogoSC automated test summary");
    echo("============================================================");

    if (reportLevel >= 1)
    {
        for (suite = suites)
        {
            suiteResults = LogoTestSuiteResults(suite);
            suiteFailures = LogoFailedTestResults(suiteResults);

            echo(
                "LogoSC suite result",
                LogoTestSuiteName(suite),
                len(suiteFailures) == 0 ? "PASS" : "FAIL",
                "tests", len(suiteResults),
                "passed", LogoPassedTestCount(suiteResults),
                "failed", len(suiteFailures)
            );

            for (result = suiteResults)
            {
                if (reportLevel >= 2 || !LogoTestResultPassed(result))
                {
                    echo(
                        "LogoSC test result",
                        LogoTestSuiteName(suite),
                        LogoTestResultPassed(result) ? "PASS" : "FAIL",
                        LogoTestResultName(result),
                        LogoTestResultPassed(result)
                            ? undef
                            : LogoTestResultDetail(result)
                    );
                }
            }
        }
    }

    echo(
        "LOGOSC_AUTOMATED_TEST_RESULT",
        len(failedResults) == 0 ? "PASS" : "FAIL",
        "suites", len(suites),
        "failedSuites", len(failedSuites),
        "tests", len(allResults),
        "passed", LogoPassedTestCount(allResults),
        "failed", len(failedResults)
    );
    echo("============================================================");

    if (len(failedResults) > 0)
    {
        echo("*** Test Suite Failed ***");
    }
}

// Return true when two scalars are approximately equal.
function LogoNearlyEqual(a, b, tol = 0.001) =
    abs(a - b) <= tol;

// Return true when two Logo states are approximately equal.
function LogoStateNearlyEqual(a, b, tol = 0.001) =
    LogoNearlyEqual(a[SX], b[SX], tol)
    && LogoNearlyEqual(a[SY], b[SY], tol)
    && LogoNearlyEqual(a[SH], b[SH], tol)
    && LogoNearlyEqual(a[SSX], b[SSX], tol)
    && LogoNearlyEqual(a[SSY], b[SSY], tol)
    && LogoNearlyEqual(a[SSH], b[SSH], tol);

// Return true when corresponding 2D points are approximately equal.
function LogoPointNearlyEqual(a, b, tol = 0.001) =
    LogoNearlyEqual(a[0], b[0], tol)
    && LogoNearlyEqual(a[1], b[1], tol);

// Return true when two point lists have approximately equal coordinates.
function LogoPointListsNearlyEqual(a, b, tol = 0.001, index = 0) =
    len(a) != len(b)
        ? false
        : index >= len(a)
            ? true
            : LogoPointNearlyEqual(a[index], b[index], tol)
                && LogoPointListsNearlyEqual(a, b, tol, index + 1);

// Return true when two 2x3 affine matrices are approximately equal.
function LogoAffineNearlyEqual(a, b, tol = 0.001) =
    LogoAffineIs2x3(a)
    && LogoAffineIs2x3(b)
    && LogoNearlyEqual(a[0][0], b[0][0], tol)
    && LogoNearlyEqual(a[0][1], b[0][1], tol)
    && LogoNearlyEqual(a[0][2], b[0][2], tol)
    && LogoNearlyEqual(a[1][0], b[1][0], tol)
    && LogoNearlyEqual(a[1][1], b[1][1], tol)
    && LogoNearlyEqual(a[1][2], b[1][2], tol);

function LogoCheckResultResults(
    label,
    testName,
    vtCmds,
    expectedState,
    expectedPointCount,
    tol = 0.001) =
    let(
        result = evalLogo(vtCmds),
        state = ResultState(result),
        contours = ResultContours(result),
        pointCount = CountContourPoints(contours)
    )
    [
        LogoTestResult(
            str(label, ": ", testName, " final state"),
            LogoStateNearlyEqual(state, expectedState, tol),
            [state, expectedState]
        ),
        LogoTestResult(
            str(label, ": ", testName, " point count"),
            pointCount == expectedPointCount,
            [pointCount, expectedPointCount, contours]
        )
    ];

function LogoCheckContourLengthsResult(testName, vtCmds, expectedLengths) =
    let(
        result = evalLogo(vtCmds),
        regions = ResultContours(result),
        actualLengths =
        [
            for (region = regions)
                if (len(RegionOuter(region)) > 0)
                    len(RegionOuter(region))
        ]
    )
    LogoTestResult(
        str("contour lengths: ", testName),
        actualLengths == expectedLengths,
        [actualLengths, expectedLengths, regions]
    );

function LogoCheckRegionRingLengthsResult(
    testName,
    vtCmds,
    expectedRingLengths) =
    let(
        result = evalLogo(vtCmds),
        regions = ResultContours(result),
        actualRingLengths =
        [
            for (region = regions)
                if (len(RegionOuter(region)) > 0)
                    [
                        for (ring = region)
                            len(ring)
                    ]
        ]
    )
    LogoTestResult(
        str("region ring lengths: ", testName),
        actualRingLengths == expectedRingLengths,
        [actualRingLengths, expectedRingLengths, regions]
    );

// Return every region/ring length, including empty mutable regions.
//
// This preserves empty regions so evaluator-state tests can verify the exact
// raw EvalResult structure.
function LogoAllRegionRingLengths(regions) =
[
    for (region = regions)
        [
            for (ring = region)
                len(ring)
        ]
];

function LogoCheckEvaluatorResultResults(
    testName,
    vtCmds,
    expectedState,
    expectedRingLengths,
    expectedStack = [],
    expectedPen = PEN_DOWN,
    tol = 0.001) =
    let(
        result = evalLogo(vtCmds),
        state = ResultState(result),
        regions = ResultContours(result),
        ringLengths = LogoAllRegionRingLengths(regions),
        stack = ResultStack(result),
        pen = ResultPen(result)
    )
    [
        LogoTestResult(
            str("evaluator: ", testName, " final state"),
            LogoStateNearlyEqual(state, expectedState, tol),
            [state, expectedState]
        ),
        LogoTestResult(
            str("evaluator: ", testName, " region/ring lengths"),
            ringLengths == expectedRingLengths,
            [ringLengths, expectedRingLengths, regions]
        ),
        LogoTestResult(
            str("evaluator: ", testName, " stack"),
            stack == expectedStack,
            [stack, expectedStack]
        ),
        LogoTestResult(
            str("evaluator: ", testName, " pen state"),
            pen == expectedPen,
            [pen, expectedPen]
        )
    ];

// Non-rendering evaluator contract tests.
//
// These tests cover today's filled-region evaluator. They do not introduce or
// imply support for open paths. Extend this suite when an open-path data model
// and its validation rules are deliberately added.
function TestEvaluatorInvariantSuiteResultsLogo() =
concat(
    LogoCheckEvaluatorResultResults(
        "PUSH saves the complete state",
        [
            [MOVE, 10],
            [PUSH],
            [TURN, 90]
        ],
        stateMake(10, 0, 90, 1),
        [[1]],
        [stateMake(10, 0, 0, 1)]
    ),

    LogoCheckEvaluatorResultResults(
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
    ),

    LogoCheckEvaluatorResultResults(
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
    ),

    LogoCheckEvaluatorResultResults(
        "PENDOWN starts a new filled-region contour",
        [
            [PENUP],
            [MOVE, 10],
            [PENDOWN],
            [MOVE, 5]
        ],
        stateMake(15, 0, 0, 1),
        [[0], [2]]
    ),

    LogoCheckEvaluatorResultResults(
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
    ),

    LogoCheckEvaluatorResultResults(
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
    )
);

// Basic Logo geometry regression suite.
function TestBasicCasesLogo() =
let(
    square =
    [
        [MOVE, 10],
        [TURN, 90],
        [MOVE, 10],
        [TURN, 90],
        [MOVE, 10],
        [TURN, 90],
        [MOVE, 10]
    ],

    rectangle =
    [
        [MOVE, 20],
        [TURN, 90],
        [MOVE, 8],
        [TURN, 90],
        [MOVE, 20],
        [TURN, 90],
        [MOVE, 8]
    ],

    triangle =
    [
        [MOVE, 12],
        [TURN, 120],
        [MOVE, 12],
        [TURN, 120],
        [MOVE, 12]
    ],

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
    ],

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
    ],

    smallSquare =
    [
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4]
    ],

    runScaled =
    [
        [RUN, smallSquare, 2],
        [TURN, 0]
    ],

    gotoShape =
    [
        [GOTO, 0, 0, 0],
        [MOVE, 12],
        [GOTO, 12, 8, 180],
        [MOVE, 12],
        [GOTO, 0, 8, -90],
        [MOVE, 8]
    ]
)
[
    LogoGeometryTestCase("basic square", square, [0, BasicY]),
    LogoGeometryTestCase("rectangle", rectangle, [1, BasicY]),
    LogoGeometryTestCase("triangle", triangle, [2, BasicY]),
    LogoGeometryTestCase("rotated diamond", diamond, [3, BasicY]),
    LogoGeometryTestCase("stepped concave polygon", stepped, [4, BasicY]),
    LogoGeometryTestCase("RUN scaled square x2", runScaled, [5, BasicY]),
    LogoGeometryTestCase("GOTO rectangle path", gotoShape, [6, BasicY])
];

module TestBasicSuiteLogo()
{
    RenderLogoGeometryTestCases(TestBasicCasesLogo());
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
function TestRunCasesLogo() =
let(
    smallSquare =
    [
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4]
    ],

    runDefault =
    [
        [RUN, smallSquare]
    ],

    runHalfScale =
    [
        [RUN, smallSquare, 0.5]
    ],

    runDoubleScale =
    [
        [RUN, smallSquare, 2]
    ],

    runExplicitMaxRec =
    [
        [RUN, smallSquare, 1, 4]
    ],

    nestedRunLeaf =
    [
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4],
        [TURN, 90],
        [MOVE, 4]
    ],

    nestedRunBranch =
    [
        [RUN, nestedRunLeaf, 1.0, 2],
        [TURN, 45],
        [RUN, nestedRunLeaf, 0.7, 2],
        [TURN, -90],
        [RUN, nestedRunLeaf, 0.7, 2]
    ],

    nestedRunTree =
    [
        [RUN, nestedRunBranch, 1.0, 3]
    ]
)
[
    LogoGeometryTestCase("RUN default scale/maxRec", runDefault, [0, RunY0]),
    LogoGeometryTestCase("RUN half scale", runHalfScale, [1, RunY0]),
    LogoGeometryTestCase("RUN double scale", runDoubleScale, [2, RunY0]),
    LogoGeometryTestCase("RUN explicit maxRec=4", runExplicitMaxRec, [3, RunY0]),
    LogoGeometryTestCase("nested RUN tree", nestedRunTree, [4, RunY0])
];

module TestRunSuiteLogo()
{
    RenderLogoGeometryTestCases(TestRunCasesLogo());
}

// Recursive RUN regression suite.
function TestRunRecursiveCasesLogo() =
let(
    recursiveBox = RecursiveBoxCmds(3),
    recursiveSpiral = RecursiveSpiralCmds(4),
    recursiveSharkFin = RecursiveSharkFinCmds(3),
    recursiveBoxShallow =
    [
        [RUN, RecursiveBoxCmds(5), 1.0, 1]
    ],

    recursiveBoxDeep =
    [
        [RUN, RecursiveBoxCmds(5), 1.0, 4]
    ]
)
[
    LogoGeometryTestCase("recursive box depth 3", recursiveBox, [0, RunY1]),
    LogoGeometryTestCase("recursive spiral depth 4", recursiveSpiral, [1, RunY1]),
    LogoGeometryTestCase("recursive shark fin depth 3", recursiveSharkFin, [2, RunY1]),
    LogoGeometryTestCase(
        "recursive box shallow maxRec=1",
        recursiveBoxShallow,
        [3, RunY1]
    ),
    LogoGeometryTestCase("recursive box deep maxRec=4", recursiveBoxDeep, [4, RunY1])
];

module TestRunRecursiveSuiteLogo()
{
    RenderLogoGeometryTestCases(TestRunRecursiveCasesLogo());
}

// PUSH/POP and REPEAT regression suite.
// PUSH/POP and REPEAT regression suite.
//
// These tests are intentionally polygon-friendly. Commands such as PUSH/POP can
// create nonlocal Logo-state jumps; because polygon() always connects emitted
// points in order, tests that draw visible branches can become self-intersecting.
// The tests below use PUSH/POP to verify state restoration without drawing
// disconnected branches.
function TestStateFlowCasesLogo() =
let(
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
    ],

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
    ],

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
    ],

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
    ],

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
    ],

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
    ]
)
[
    LogoGeometryTestCase("PUSH/POP state restore box", stateRestoreBox, [0, StateFlowY]),
    LogoGeometryTestCase("REPEAT square", repeatedSquare, [1, StateFlowY]),
    LogoGeometryTestCase("REPEAT triangle", repeatedTriangle, [2, StateFlowY]),
    LogoGeometryTestCase("REPEAT containing RUN hexagon", repeatWithRun, [3, StateFlowY]),
    LogoGeometryTestCase(
        "PUSH/POP inside REPEAT box",
        pushPopInsideRepeatBox,
        [4, StateFlowY]
    ),
    LogoGeometryTestCase("nested REPEAT box", nestedRepeatBox, [5, StateFlowY])
];

module TestStateFlowSuiteLogo()
{
    RenderLogoGeometryTestCases(TestStateFlowCasesLogo());
}

// PENUP/PENDOWN and multiple-contour regression suite.
function TestPenCasesLogo() =
let(
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
    ],

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
    ],

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
    ],

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
    ]
)
[
    LogoGeometryTestCase("PENUP/PENDOWN two disconnected squares", twoSquares, [0, PenY]),
    LogoGeometryTestCase("PENUP/PENDOWN three triangles", threeTriangles, [1, PenY]),
    LogoGeometryTestCase(
        "PUSH/POP satellite squares with pen control",
        pushPopSatellites,
        [2, PenY]
    ),
    LogoGeometryTestCase("REPEAT disconnected boxes", repeatDisconnected, [3, PenY])
];

module TestPenSuiteLogo()
{
    RenderLogoGeometryTestCases(TestPenCasesLogo());
}

// ARC geometry regression suite.
function TestArcCasesLogo() =
let(
    quarterArc =
    [
        [ARC, 10, 90, 8],
        [GOTO, 0, 0, 0]
    ],

    semicircle =
    [
        [ARC, 10, 180, 16],
        [GOTO, 0, 0, 0]
    ],

    circleish =
    [
        [ARC, 10, 360, 32]
    ],

    repeatArcs =
    [
        [REPEAT, 4,
            [
                [ARC, 10, 90, 8]
            ]
        ]
    ],

    runArc =
    [
        [RUN,
            [
                [ARC, 10, 90, 8]
            ]
        ],
        [GOTO, 0, 0, 0]
    ],

    scaledArc =
    [
        [SCALE, 0.5],
        [ARC, 20, 180, 16],
        [GOTO, 0, 0, 0]
    ],

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
    ]
)
[
    LogoGeometryTestCase("ARC quarter sector", quarterArc, [0, ArcY]),
    LogoGeometryTestCase("ARC semicircle sector", semicircle, [1, ArcY]),
    LogoGeometryTestCase("ARC full-circle-ish", circleish, [2, ArcY]),
    LogoGeometryTestCase("ARC inside REPEAT", repeatArcs, [3, ArcY]),
    LogoGeometryTestCase("ARC inside RUN", runArc, [4, ArcY]),
    LogoGeometryTestCase("ARC scaled", scaledArc, [5, ArcY]),
    LogoGeometryTestCase("ARC rounded rectangle", roundedRect, [6, ArcY])
];

function TestArcDetailedResultsLogo() =
let(
    cases = TestArcCasesLogo(),
    roundedRect = cases[6][LTC_COMMANDS]
)
concat(
    LogoCheckResultResults(
        "ARC", "quarter arc", [[ARC, 10, 90, 4]],
        stateMake(10, 10, 90, 1), 4
    ),
    LogoCheckResultResults(
        "ARC", "semicircle", [[ARC, 10, 180, 4]],
        stateMake(0, 20, 180, 1), 4
    ),
    LogoCheckResultResults(
        "ARC", "full-circle-ish arc", [[ARC, 10, 360, 8]],
        stateMake(0, 0, 360, 1), 8
    ),
    LogoCheckResultResults(
        "ARC", "pen-up arc", [[PENUP], [ARC, 10, 90, 4]],
        stateMake(10, 10, 90, 1), 0
    ),
    LogoCheckResultResults(
        "ARC", "arc inside REPEAT", [[REPEAT, 4, [[ARC, 10, 90, 4]]]],
        stateMake(0, 0, 360, 1), 16
    ),
    LogoCheckResultResults(
        "ARC", "arc inside RUN", [[RUN, [[ARC, 10, 90, 4]]]],
        stateMake(10, 10, 90, 1), 4
    ),
    LogoCheckResultResults(
        "ARC", "scaled arc", [[SCALE, 2], [ARC, 10, 90, 4]],
        stateMake(20, 20, 90, 2), 4
    ),
    LogoCheckResultResults(
        "ARC", "rounded rectangle", roundedRect,
        stateMake(5, 0, 360, 1), 21
    )
);

module TestArcSuiteLogo()
{
    RenderLogoGeometryTestCases(TestArcCasesLogo());
}


// Closed-shape geometry regression suite.
function TestClosedShapeCasesLogo() =
let(
    circleShape =
    [
        [CIRCLE, 8, 24]
    ],

    regularHex =
    [
        [REGPOLY, 6, 8]
    ],

    rectShape =
    [
        [RECT, 20, 10]
    ],

    rotatedRect =
    [
        [DIR, 30],
        [RECT, 20, 8]
    ],

    roundedRectShape =
    [
        [ROUNDEDRECT, 24, 14, 4, 4]
    ],

    scaledCircle =
    [
        [SCALE, 0.5],
        [CIRCLE, 16, 16]
    ]
)
[
    LogoGeometryTestCase("CIRCLE centered closed contour", circleShape, [0, ShapeY]),
    LogoGeometryTestCase("REGPOLY hexagon", regularHex, [1, ShapeY]),
    LogoGeometryTestCase("RECT centered rectangle", rectShape, [2, ShapeY]),
    LogoGeometryTestCase("RECT rotated by heading", rotatedRect, [3, ShapeY]),
    LogoGeometryTestCase("ROUNDEDRECT centered", roundedRectShape, [4, ShapeY]),
    LogoGeometryTestCase("CIRCLE scaled", scaledCircle, [5, ShapeY])
];

function TestClosedShapeDetailedResultsLogo() =
concat(
    LogoCheckResultResults(
        "shape", "circle", [[CIRCLE, 10, 16]],
        stateMake(0, 0, 0, 1), 16
    ),
    LogoCheckResultResults(
        "shape", "regular polygon", [[REGPOLY, 6, 10]],
        stateMake(0, 0, 0, 1), 6
    ),
    LogoCheckResultResults(
        "shape", "rectangle", [[RECT, 20, 8]],
        stateMake(0, 0, 0, 1), 4
    ),
    LogoCheckResultResults(
        "shape", "rounded rectangle command", [[ROUNDEDRECT, 20, 10, 2, 4]],
        stateMake(0, 0, 0, 1), 20
    ),
    LogoCheckResultResults(
        "shape", "pen-up circle", [[PENUP], [CIRCLE, 10, 16]],
        stateMake(0, 0, 0, 1), 0
    ),
    LogoCheckResultResults(
        "shape", "scaled circle", [[SCALE, 2], [CIRCLE, 5, 8]],
        stateMake(0, 0, 0, 2), 8
    ),
    LogoCheckResultResults(
        "shape", "shape inside RUN", [[RUN, [[RECT, 10, 4]], 2]],
        stateMake(0, 0, 0, 2), 4
    ),
    [
        LogoCheckContourLengthsResult(
            "shape command does not become the current path",
            [[CIRCLE, 5, 8], [MOVE, 10]],
            [8, 1]
        )
    ]
);

module TestClosedShapeSuiteLogo()
{
    RenderLogoGeometryTestCases(TestClosedShapeCasesLogo());
}

// Region/hole regression suite.
function TestHoleCasesLogo() =
let(
    washer =
    [
        [CIRCLE, 14, 32],
        [HOLE,
            [
                [CIRCLE, 5, 16]
            ]
        ]
    ],

    rectWithHole =
    [
        [RECT, 26, 14],
        [HOLE,
            [
                [CIRCLE, 4, 12]
            ]
        ]
    ],

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
    ],

    repeatedHoles =
    [
        [RECT, 26, 14],
        [REPEAT, 2,
            [
                [HOLE, [[GOTO, -7, 0, 0], [CIRCLE, 2, 8]]],
                [HOLE, [[GOTO,  7, 0, 0], [CIRCLE, 2, 8]]]
            ]
        ]
    ],

    scaledHole =
    [
        [SCALE, 2],
        [RECT, 12, 6],
        [HOLE, [[CIRCLE, 1.5, 8]]]
    ]
)
[
    LogoGeometryTestCase("HOLE washer", washer, [0, HoleY]),
    LogoGeometryTestCase("HOLE rectangle with circle", rectWithHole, [1, HoleY]),
    LogoGeometryTestCase("HOLE rounded mounting plate", roundedPlate, [2, HoleY]),
    LogoGeometryTestCase("HOLE repeated circular holes", repeatedHoles, [3, HoleY]),
    LogoGeometryTestCase("HOLE scaled", scaledHole, [4, HoleY])
];

function TestHoleDetailedResultsLogo() =
let(
    cases = TestHoleCasesLogo(),
    washer = cases[0][LTC_COMMANDS],
    rectWithHole = cases[1][LTC_COMMANDS],
    roundedPlate = cases[2][LTC_COMMANDS],
    repeatedHoles = cases[3][LTC_COMMANDS],
    scaledHole = cases[4][LTC_COMMANDS]
)
concat(
    LogoCheckResultResults(
        "shape", "washer", washer,
        stateMake(0, 0, 0, 1), 48
    ),
    [LogoCheckRegionRingLengthsResult("washer ring lengths", washer, [[32, 16]])],
    LogoCheckResultResults(
        "shape", "rectangle with circular hole", rectWithHole,
        stateMake(0, 0, 0, 1), 16
    ),
    [
        LogoCheckRegionRingLengthsResult(
            "rectangle with circular hole ring lengths",
            rectWithHole,
            [[4, 12]]
        )
    ],
    LogoCheckResultResults(
        "shape", "rounded plate with four screw holes", roundedPlate,
        stateMake(0, 0, 0, 1), 52
    ),
    [
        LogoCheckRegionRingLengthsResult(
            "rounded plate ring lengths",
            roundedPlate,
            [[20, 8, 8, 8, 8]]
        ),
        LogoCheckRegionRingLengthsResult(
            "repeated holes attach to same region",
            repeatedHoles,
            [[4, 8, 8, 8, 8]]
        ),
        LogoCheckRegionRingLengthsResult("scaled hole", scaledHole, [[4, 8]])
    ]
);

module TestHoleSuiteLogo()
{
    RenderLogoGeometryTestCases(TestHoleCasesLogo());
}

// Failure-condition regression suite.
//
// These tests are supposed to produce [ERROR] messages when HardErrors = false.
// They should not abort the complete OpenSCAD run unless HardErrors = true.
function TestFailureCasesLogo() =
let(
    badOpcode =
    [
        [999, 10]
    ],

    emptyProgram =
    [
        [RUN, []]
    ],

    recursionLimit =
    [
        [RUN, RecursiveBoxCmds(3), 1.0, 0]
    ],

    malformedRunNoChildList =
    [
        [RUN]
    ],

    gotoMissingArgs =
    [
        [GOTO, 1]
    ],

    popEmptyStack =
    [
        [POP]
    ],

    malformedRepeat =
    [
        [REPEAT]
    ],

    malformedArc =
    [
        [ARC, 10]
    ],

    negativeArcRadius =
    [
        [ARC, -10, 90, 4]
    ],

    badArcSegments =
    [
        [ARC, 10, 90, 0]
    ],


    malformedCircle =
    [
        [CIRCLE]
    ],

    badCircleSegments =
    [
        [CIRCLE, 10, 2]
    ],

    badRegPolySides =
    [
        [REGPOLY, 2, 10]
    ],

    malformedRect =
    [
        [RECT, 10]
    ],

    badRoundedRectRadius =
    [
        [ROUNDEDRECT, 20, 10, -2]
    ],

    malformedHole =
    [
        [HOLE]
    ],

    holeBeforeOuter =
    [
        [HOLE, [[CIRCLE, 3, 8]]]
    ],

    emptyHoleChild =
    [
        [RECT, 10, 10],
        [HOLE, []]
    ],

    holeChildNoClosedContour =
    [
        [RECT, 10, 10],
        [HOLE, [[MOVE, 5]]]
    ],

    zeroAxisScale =
    [
        [SCALE, 1, 0]
    ],

    zeroRunScale =
    [
        [RUN, [[MOVE, 5]], 0]
    ]
)
[
    LogoExpectedErrorTestCase("FAIL expected: unknown opcode", badOpcode, [0, FailureY]),
    LogoExpectedErrorTestCase("FAIL expected: empty RUN is no-op", emptyProgram, [1, FailureY]),
    LogoExpectedErrorTestCase(
        "FAIL expected: RUN recursion limit reached",
        recursionLimit,
        [2, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: malformed RUN without child list",
        malformedRunNoChildList,
        [3, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: malformed GOTO missing args",
        gotoMissingArgs,
        [4, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: POP with empty state stack",
        popEmptyStack,
        [5, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: malformed REPEAT no child list",
        malformedRepeat,
        [6, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: malformed ARC missing angle",
        malformedArc,
        [7, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: ARC negative radius",
        negativeArcRadius,
        [8, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: ARC bad segment count",
        badArcSegments,
        [9, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: malformed CIRCLE missing radius",
        malformedCircle,
        [10, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: CIRCLE bad segment count",
        badCircleSegments,
        [11, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: REGPOLY bad side count",
        badRegPolySides,
        [12, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: malformed RECT missing height",
        malformedRect,
        [13, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: ROUNDEDRECT negative radius",
        badRoundedRectRadius,
        [14, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: malformed HOLE missing child list",
        malformedHole,
        [15, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: HOLE before outer region",
        holeBeforeOuter,
        [16, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: HOLE empty child list",
        emptyHoleChild,
        [17, FailureY],
        true
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: HOLE child with no closed contour",
        holeChildNoClosedContour,
        [18, FailureY],
        true
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: SCALE zero axis is singular",
        zeroAxisScale,
        [19, FailureY],
        false
    ),
    LogoExpectedErrorTestCase(
        "FAIL expected: RUN zero scale is singular",
        zeroRunScale,
        [20, FailureY],
        false
    )
];

module TestFailureSuiteLogo()
{
    echo("LogoSC expected-error tests: BEGIN");
    RenderLogoGeometryTestCases(TestFailureCasesLogo());
    echo("LogoSC expected-error tests: END");
}

// Canonical affine-state and transformed-geometry contract tests.
function TestAffineTransformResultsLogo() =
    let(
        scaledMove = evalLogo([[SCALE, 2, 3], [MOVE, 10]]),
        scaledMoveState = ResultState(scaledMove),
        turned = evalLogo([[SCALE, 2, 1], [TURN, 45], [MOVE, 10]]),
        turnedState = ResultState(turned),
        reflected = evalLogo([[SCALE, -1, 1], [MOVE, 10]]),
        reflectedState = ResultState(reflected),
        absoluteDir = evalLogo([[SCALE, 2, 1], [TURN, 45], [DIR, 90]]),
        absoluteDirState = ResultState(absoluteDir),
        absoluteGoto = evalLogo(
            [[SCALE, 2, 1], [TURN, 45], [GOTO, 7, 8, 30]]
        ),
        absoluteGotoState = ResultState(absoluteGoto),
        restored = evalLogo(
            [[SCALE, 2, 1], [PUSH], [TURN, 45], [SCALE, -1, 3], [POP]]
        ),
        looped = evalLogo(
            [[REPEAT, 6, [[PUSH], [MOVE, 10], [POP], [TURN, 60]]]]
        ),
        loopPoints = RegionOuter(ResultContours(looped)[0]),
        arcResult = evalLogo([[SCALE, 2, 1], [ARC, 10, 90, 2]]),
        arcPoints = RegionOuter(ResultContours(arcResult)[0]),
        rectResult = evalLogo([[SCALE, 2, 3], [RECT, 10, 1]]),
        rectPoints = RegionOuter(ResultContours(rectResult)[0]),
        reflectedRect = evalLogo([[SCALE, -1, 1], [RECT, 2, 2]]),
        reflectedRectPoints = RegionOuter(ResultContours(reflectedRect)[0]),
        runResult = evalLogo([[SCALE, 2, 1], [RUN, [[MOVE, 5]], 3]]),
        holeResult = evalLogo(
            [
                [SCALE, 2, 1],
                [RECT, 10, 10],
                [HOLE, [[CIRCLE, 2, 4]]]
            ]
        ),
        holePoints = RegionHoles(ResultContours(holeResult)[0])[0],
        affineState = stateMake(10, -5, 390, 2, -3, 0.25),
        affineMatrix = LogoStateToAffine(affineState),
        affinePrincipalState = LogoAffineToState(affineMatrix),
        affineReferencedState = LogoAffineToState(affineMatrix, affineState[SH]),
        malformedAffineState =
            let($LogoSCSuppressErrors = true)
            LogoAffineToState([[1, 0], [0, 1]]),
        singularAffineState =
            let($LogoSCSuppressErrors = true)
            LogoAffineToState([[1, 2, 3], [2, 4, 5]]),
        debugResult = evalLogoDebug([[SCALE, 2, 1], [TURN, 45], [MOVE, 10]]),
        debugEnd =
            ResultDebugSegments(debugResult)[len(ResultDebugSegments(debugResult)) - 1][DS_TO]
    )
    [
        LogoTestResult(
            "affine: two-axis SCALE transforms MOVE and state",
            LogoStateNearlyEqual(scaledMoveState, stateMake(20, 0, 0, 2, 3, 0)),
            scaledMoveState
        ),
        LogoTestResult(
            "affine: TURN after anisotropic SCALE generates canonical shear",
            LogoStateNearlyEqual(
                turnedState,
                stateMake(10 * sqrt(2), 5 * sqrt(2), 26.565051, sqrt(2.5), sqrt(1.6), -0.75)
            ),
            turnedState
        ),
        LogoTestResult(
            "affine: negative axis SCALE reflects MOVE",
            LogoStateNearlyEqual(reflectedState, stateMake(-10, 0, 180, 1, -1, 0)),
            reflectedState
        ),
        LogoTestResult(
            "affine: DIR is world-absolute and preserves canonical linear factors",
            LogoStateNearlyEqual(
                absoluteDirState,
                stateMake(
                    0,
                    0,
                    90,
                    turnedState[SSX],
                    turnedState[SSY],
                    turnedState[SSH]
                )
            ),
            absoluteDirState
        ),
        LogoTestResult(
            "affine: GOTO is world-absolute and preserves canonical linear factors",
            LogoStateNearlyEqual(
                absoluteGotoState,
                stateMake(
                    7,
                    8,
                    30,
                    turnedState[SSX],
                    turnedState[SSY],
                    turnedState[SSH]
                )
            ),
            absoluteGotoState
        ),
        LogoTestResult(
            "affine: PUSH and POP restore the complete transform",
            LogoStateNearlyEqual(ResultState(restored), stateMake(0, 0, 0, 2, 1, 0)),
            ResultState(restored)
        ),
        LogoTestResult(
            "affine: REPEAT preserves turns between iterations",
            LogoPointListsNearlyEqual(
                loopPoints,
                [
                    [10, 0],
                    [5, 5 * sqrt(3)],
                    [-5, 5 * sqrt(3)],
                    [-10, 0],
                    [-5, -5 * sqrt(3)],
                    [5, -5 * sqrt(3)]
                ]
            ),
            loopPoints
        ),
        LogoTestResult(
            "affine: local ARC becomes an ellipse under anisotropic scale",
            LogoPointListsNearlyEqual(
                arcPoints,
                [[10 * sqrt(2), 10 - 5 * sqrt(2)], [20, 10]]
            ),
            arcPoints
        ),
        LogoTestResult(
            "affine: primitive vertices use the complete transform",
            LogoPointListsNearlyEqual(
                rectPoints,
                [[10, -1.5], [10, 1.5], [-10, 1.5], [-10, -1.5]]
            ),
            rectPoints
        ),
        LogoTestResult(
            "affine: reflection preserves generated primitive point order",
            LogoPointListsNearlyEqual(
                reflectedRectPoints,
                [[-1, -1], [-1, 1], [1, 1], [1, -1]]
            ),
            reflectedRectPoints
        ),
        LogoTestResult(
            "affine: automatic tessellation uses maximum linear stretch",
            ArcSegmentCount([ARC, 10, 90], stateMake(0, 0, 0, 2, 3, 0))
                == ArcAutoSegments(30, 90),
            ArcSegmentCount([ARC, 10, 90], stateMake(0, 0, 0, 2, 3, 0))
        ),
        LogoTestResult(
            "affine: RUN scale remains a uniform local multiplier",
            LogoStateNearlyEqual(ResultState(runResult), stateMake(30, 0, 0, 6, 3, 0)),
            ResultState(runResult)
        ),
        LogoTestResult(
            "affine: HOLE child inherits the parent transform",
            LogoPointListsNearlyEqual(
                holePoints,
                [[4, 0], [0, 2], [-4, 0], [0, -2]]
            ),
            holePoints
        ),
        LogoTestResult(
            "affine API: canonical state converts to standard 2x3 matrix",
            LogoAffineNearlyEqual(
                affineMatrix,
                [
                    [
                        2 * cos(390),
                        -3 * (0.25 * cos(390) - sin(390)),
                        10
                    ],
                    [
                        2 * sin(390),
                        -3 * (0.25 * sin(390) + cos(390)),
                        -5
                    ]
                ]
            ),
            affineMatrix
        ),
        LogoTestResult(
            "affine API: matrix converts to principal canonical state",
            LogoStateNearlyEqual(
                affinePrincipalState,
                stateMake(10, -5, 30, 2, -3, 0.25)
            ),
            affinePrincipalState
        ),
        LogoTestResult(
            "affine API: heading reference restores equivalent complete turns",
            LogoStateNearlyEqual(affineReferencedState, affineState),
            affineReferencedState
        ),
        LogoTestResult(
            "affine API: malformed matrix is rejected",
            malformedAffineState == undef,
            malformedAffineState
        ),
        LogoTestResult(
            "affine API: singular matrix is rejected",
            singularAffineState == undef,
            singularAffineState
        ),
        LogoTestResult(
            "affine: debug evaluator uses transformed MOVE geometry",
            LogoPointNearlyEqual(debugEnd, [10 * sqrt(2), 5 * sqrt(2)]),
            debugEnd
        )
    ];

function LogoFoundationAutomatedTestResults() =
concat(
    TestEvaluatorInvariantSuiteResultsLogo(),
    LogoGeometryTestResults(TestBasicCasesLogo()),
    LogoGeometryTestResults(TestRunCasesLogo()),
    LogoGeometryTestResults(TestRunRecursiveCasesLogo()),
    LogoGeometryTestResults(TestStateFlowCasesLogo()),
    LogoGeometryTestResults(TestPenCasesLogo()),
    LogoGeometryTestResults(TestArcCasesLogo()),
    TestArcDetailedResultsLogo(),
    LogoGeometryTestResults(TestClosedShapeCasesLogo()),
    TestClosedShapeDetailedResultsLogo(),
    LogoGeometryTestResults(TestHoleCasesLogo()),
    TestHoleDetailedResultsLogo(),
    LogoGeometryTestResults(TestFailureCasesLogo()),
    TestAffineTransformResultsLogo()
);

function LogoFoundationTestSuiteResult() =
    LogoTestSuiteResult(
        "Foundation",
        LogoFoundationAutomatedTestResults()
    );

// Run all current LogoSC regression suites.
module RunAllLogoSCTests(reportResults = true)
{
    LogoSCTestRowMarkers();

    TestBasicSuiteLogo();
    TestRunSuiteLogo();
    TestRunRecursiveSuiteLogo();
    TestStateFlowSuiteLogo();
    TestPenSuiteLogo();
    TestArcSuiteLogo();
    TestClosedShapeSuiteLogo();
    TestHoleSuiteLogo();
    TestFailureSuiteLogo();

    if (reportResults)
    {
        ReportLogoTestRun([LogoFoundationTestSuiteResult()]);
    }
}
