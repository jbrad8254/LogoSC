// Passive deterministic tests for LogoSC-LSystems.scad.

function LSystemTestNearlyEqual(a, b, tolerance = 0.000001) =
    abs(a - b) <= tolerance;

function LSystemTestPointNearlyEqual(a, b, tolerance = 0.000001) =
    len(a) == len(b)
    && LSystemTestNearlyEqual(a[0], b[0], tolerance)
    && LSystemTestNearlyEqual(a[1], b[1], tolerance);

function LSystemPresetValidationTestResults() =
    concat(
        [
            for (name = LSystemPresetNames())
                let(system = LSystemPreset(name))
                LogoTestResult(
                    str("L-system preset is valid: ", name),
                    LSystemIsValid(system)
                    && LSystemName(system) == name
                    && LSystemStepDivisor(system) > 0,
                    system
                )
        ],
        [
            LogoTestResult(
                "L-system malformed interpretation is rejected",
                !LSystemIsValid(
                    MakeLSystem(
                        "Bad",
                        [LSYS_F],
                        [],
                        90,
                        2,
                        [[LSYS_F, 99]]
                    )
                )
            )
        ]
    );

function LSystemRewriteTestResults() =
    let(
        koch = MakeKochLSystem(),
        kochDepth1 = LSystemExpand(koch, 1),
        kochDepth2 = LSystemExpand(koch, 2),
        identity = LSystemRewrite([LSYS_A, LSYS_PLUS], []),
        hilbertDepth1 = LSystemExpand(MakeHilbertLSystem(), 1),
        plantDepth2 = LSystemExpand(MakePlantLSystem(), 2)
    )
    [
        LogoTestResult(
            "L-system unmatched symbols rewrite to themselves",
            identity == [LSYS_A, LSYS_PLUS],
            identity
        ),
        LogoTestResult(
            "L-system Koch depth-one symbol count",
            len(kochDepth1) == 28,
            len(kochDepth1)
        ),
        LogoTestResult(
            "L-system Koch depth-two symbol count",
            len(kochDepth2) == 112,
            len(kochDepth2)
        ),
        LogoTestResult(
            "L-system Hilbert variables expand but remain non-drawing",
            len(hilbertDepth1) == 11
            && len(LSystemCommands(MakeHilbertLSystem(), 1, 20)) == 7,
            [hilbertDepth1, LSystemCommands(MakeHilbertLSystem(), 1, 20)]
        ),
        LogoTestResult(
            "L-system plant expansion preserves balanced branch symbols",
            len([for (symbol = plantDepth2) if (symbol == LSYS_PUSH) symbol])
                == len([for (symbol = plantDepth2) if (symbol == LSYS_POP) symbol]),
            plantDepth2
        )
    ];

function LSystemInterpretationTestResults() =
    let(
        commands = LSystemInterpret(
            [LSYS_F, LSYS_PLUS, LSYS_f, LSYS_MINUS, LSYS_PUSH, LSYS_POP, LSYS_X],
            5,
            30,
            LSystemStandardInterpretations()
        ),
        expected = [
            [MOVE, 5],
            [TURN, 30],
            [PENUP], [MOVE, 5], [PENDOWN],
            [TURN, -30],
            [PUSH],
            [POP]
        ]
    )
    [
        LogoTestResult(
            "L-system standard interpretation emits LogoSC commands",
            commands == expected,
            commands
        ),
        LogoTestResult(
            "L-system depth zero preserves axiom",
            LSystemExpand(MakeDragonLSystem(), 0)
                == LSystemAxiom(MakeDragonLSystem()),
            LSystemExpand(MakeDragonLSystem(), 0)
        ),
        LogoTestResult(
            "L-system step scaling follows preset divisor",
            LSystemTestNearlyEqual(LSystemStep(MakeKochLSystem(), 81, 3), 3)
            && LSystemTestNearlyEqual(LSystemStep(MakeDragonLSystem(), 16, 2), 8),
            [
                LSystemStep(MakeKochLSystem(), 81, 3),
                LSystemStep(MakeDragonLSystem(), 16, 2)
            ]
        )
    ];

function LSystemGeometryContractTestResults() =
    let(
        kochResult = evalLogo(LSystemCommands(MakeKochLSystem(), 2, 36)),
        kochState = ResultState(kochResult),
        quadraticResult = evalLogo(
            LSystemCommands(MakeQuadraticKochLSystem(), 2, 32)
        ),
        quadraticState = ResultState(quadraticResult),
        sierpinskiResult = evalLogo(LSystemCommands(MakeSierpinskiLSystem(), 2, 32)),
        sierpinskiState = ResultState(sierpinskiResult),
        hilbertResult = evalLogo(LSystemCommands(MakeHilbertLSystem(), 2, 24)),
        plantResult = evalLogo(LSystemCommands(MakePlantLSystem(), 3, 32))
    )
    [
        LogoTestResult(
            "L-system Koch commands close at their starting point",
            LSystemTestPointNearlyEqual([kochState[SX], kochState[SY]], [0, 0])
            && len(ResultContours(kochResult)) == 1,
            kochState
        ),
        LogoTestResult(
            "L-system Sierpinski commands close at their starting point",
            LSystemTestPointNearlyEqual(
                [sierpinskiState[SX], sierpinskiState[SY]],
                [0, 0]
            )
            && len(ResultContours(sierpinskiResult)) == 1,
            sierpinskiState
        ),
        LogoTestResult(
            "L-system quadratic Koch commands close at their starting point",
            LSystemTestPointNearlyEqual(
                [quadraticState[SX], quadraticState[SY]],
                [0, 0]
            )
            && len(ResultContours(quadraticResult)) == 1,
            [quadraticState, len(ResultContours(quadraticResult))]
        ),
        LogoTestResult(
            "L-system Hilbert evaluation leaves a balanced stack",
            len(ResultStack(hilbertResult)) == 0,
            ResultStack(hilbertResult)
        ),
        LogoTestResult(
            "L-system plant evaluation leaves a balanced stack",
            len(ResultStack(plantResult)) == 0,
            ResultStack(plantResult)
        )
    ];

function LSystemAutomatedTestResults() =
    concat(
        LSystemPresetValidationTestResults(),
        LSystemRewriteTestResults(),
        LSystemInterpretationTestResults(),
        LSystemGeometryContractTestResults()
    );

function LSystemTestSuiteResult() =
    LogoTestSuiteResult("L-Systems", LSystemAutomatedTestResults());

module RunAllLSystemTests()
{
    ReportLogoTestRun([LSystemTestSuiteResult()]);
}
