// -----------------------------------------------------------------------------
// LogoT-Foundation-Tests.scad
//
// Regression tests for LogoT-Foundation-Core.scad.
// This file expects LogoT-Foundation-Core.scad to have been included first.
// -----------------------------------------------------------------------------

// =============================================================================
//  TEST SUITES
// =============================================================================
//
// This file is intentionally noisy: it exercises the evaluator, RUN command
// expansion, scaling, recursion limiting, pen-state behavior, and soft-error
// behavior. Test execution is guarded by RunLogoTests in the core file.
//
// =============================================================================

// -----------------------------------------------------------------------------
// Test geometry
// -----------------------------------------------------------------------------

// Render all contours from an evaluated Logo result.
//
// Each contour becomes one polygon() call. This supports disconnected filled
// shapes. Holes are deliberately not supported yet.
module RenderContours(contours, height = 5)
{
    for (i = [0 : len(contours) - 1])
    {
        contour = contours[i];

        if (len(contour) >= 3)
        {
            linear_extrude(height = height, center = true)
            {
                polygon(contour);
            }
        }
        else if (len(contour) > 0)
        {
            echo("[ERROR]", "Contour has fewer than three points", [i, contour]);

            translate(contour[0])
            {
                linear_extrude(height = height, center = true)
                {
                    square([2, 2], center = true);
                }
            }
        }
    }
}

// Run one named Logo test and render all resulting contours.
//
// testIndex is a grid index [xIndex, yIndex], not an absolute drawing position.
// The grid scale constants below convert that logical index to an OpenSCAD
// translation. This makes it easier to map rendered output back to test calls.
module LogoTest(testName, vtCmds, testIndex = [0, BasicY], height = DefaultTestHeight)
{
    TestGridXStep = 35;
    TestGridYStep = 35;

    offset =
    [
        testIndex[0] * TestGridXStep,
        testIndex[1] * TestGridYStep
    ];

    echo("");
    echo("============================================================");
    echo("LogoTest:", testName);
    echo("Index:", testIndex);
    echo("Offset:", offset);
    echo("============================================================");

    // Dump the command structure before execution. This is generally much
    // easier to read than the dynamic execution trace from evalLogo().
    TraceCmds(vtCmds);

    result = evalLogo(vtCmds);
    contours = ResultContours(result);

    translate([offset[0], offset[1], 0])
    {
        if (CountContourPoints(contours) >= 3)
        {
            RenderContours(contours, height);
        }
        else
        {
            echo("[ERROR]", "LogoTest did not produce enough polygon points", [testName, contours]);

            linear_extrude(height = height, center = true)
            {
                square([2, 2], center = true);
            }
        }
    }

    echo("");
}

// Basic Logo geometry regression suite.
module TestBasicSuiteLogo()
{
    BasicY = 0;
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

    LogoTest("basic square", square, [0, BasicY]);
    LogoTest("rectangle", rectangle, [1, BasicY]);
    LogoTest("triangle", triangle, [2, BasicY]);
    LogoTest("rotated diamond", diamond, [3, BasicY]);
    LogoTest("stepped concave polygon", stepped, [4, BasicY]);
    LogoTest("RUN scaled square x2", runScaled, [5, BasicY]);
    LogoTest("GOTO rectangle path", gotoShape, [6, BasicY]);
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
    RunY0 = 1;

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

    LogoTest("RUN default scale/maxRec", runDefault, [0, RunY0]);
    LogoTest("RUN half scale", runHalfScale, [1, RunY0]);
    LogoTest("RUN double scale", runDoubleScale, [2, RunY0]);
    LogoTest("RUN explicit maxRec=4", runExplicitMaxRec, [3, RunY0]);
    LogoTest("nested RUN tree", nestedRunTree, [4, RunY0]);
}

// Recursive RUN regression suite.
module TestRunRecursiveSuiteLogo()
{
    RunY1 = 2;

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

    LogoTest("recursive box depth 3", recursiveBox, [0, RunY1]);
    LogoTest("recursive spiral depth 4", recursiveSpiral, [1, RunY1]);
    LogoTest("recursive shark fin depth 3", recursiveSharkFin, [2, RunY1]);
    LogoTest("recursive box shallow maxRec=1", recursiveBoxShallow, [3, RunY1]);
    LogoTest("recursive box deep maxRec=4", recursiveBoxDeep, [4, RunY1]);
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
    StateFlowY = 3;
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

    LogoTest("PUSH/POP state restore box", stateRestoreBox, [0, StateFlowY]);
    LogoTest("REPEAT square", repeatedSquare, [1, StateFlowY]);
    LogoTest("REPEAT triangle", repeatedTriangle, [2, StateFlowY]);
    LogoTest("REPEAT containing RUN hexagon", repeatWithRun, [3, StateFlowY]);
    LogoTest("PUSH/POP inside REPEAT box", pushPopInsideRepeatBox, [4, StateFlowY]);
    LogoTest("nested REPEAT box", nestedRepeatBox, [5, StateFlowY]);
}

// PENUP/PENDOWN and multiple-contour regression suite.
module TestPenSuiteLogo()
{
    PenY = 4;
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

    LogoTest("PENUP/PENDOWN two disconnected squares", twoSquares, [0, PenY]);
    LogoTest("PENUP/PENDOWN three triangles", threeTriangles, [1, PenY]);
    LogoTest("PUSH/POP satellite squares with pen control", pushPopSatellites, [2, PenY]);
    LogoTest("REPEAT disconnected boxes", repeatDisconnected, [3, PenY]);
}

// Failure-condition regression suite.
//
// These tests are supposed to produce [ERROR] messages when HardErrors = false.
// They should not abort the complete OpenSCAD run unless HardErrors = true.
module TestFailureSuiteLogo()
{
    FailureY = 5;
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

    LogoTest(
        "FAIL expected: unknown opcode",
        badOpcode,
        [0, FailureY]
    );

    LogoTest(
        "FAIL expected: empty RUN is no-op",
        emptyProgram,
        [1, FailureY]
    );

    LogoTest(
        "FAIL expected: RUN recursion limit reached",
        recursionLimit,
        [2, FailureY]
    );

    LogoTest(
        "FAIL expected: malformed RUN without child list",
        malformedRunNoChildList,
        [3, FailureY]
    );

    LogoTest(
        "FAIL expected: malformed GOTO missing args",
        gotoMissingArgs,
        [4, FailureY]
    );

    LogoTest(
        "FAIL expected: POP with empty state stack",
        popEmptyStack,
        [5, FailureY]
    );

    LogoTest(
        "FAIL expected: malformed REPEAT no child list",
        malformedRepeat,
        [6, FailureY]
    );
}

// Run all current LogoT regression suites.
module RunAllLogoTests()
{
    TestBasicSuiteLogo();
    TestRunSuiteLogo();
    TestRunRecursiveSuiteLogo();
    TestStateFlowSuiteLogo();
    TestPenSuiteLogo();
    TestFailureSuiteLogo();
}

if (RunLogoTests)
{
    RunAllLogoTests();
}
