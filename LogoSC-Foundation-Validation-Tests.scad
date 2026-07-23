// ============================================================================
// LogoSC-Foundation-Validation-Tests.scad
//
// Focused tests for LogoSC-Foundation-Validation.scad.
// Include Core, Validation, and LogoSC-Foundation-Tests.scad before this file.
// ============================================================================

function LogoValidationAutomatedTestResults() =
let(
    closedTriangle =
    [
        [MOVE, 10], [TURN, 120], [MOVE, 10], [TURN, 120], [MOVE, 10]
    ],
    openTriangle =
    [
        [MOVE, 10], [TURN, 120], [MOVE, 10], [TURN, 120], [MOVE, 8]
    ],
    twoClosedPaths =
    [
        [REPEAT, 4, [[MOVE, 8], [TURN, 90]]],
        [PENUP], [MOVE, 20], [PENDOWN],
        [REPEAT, 3, [[MOVE, 8], [TURN, 120]]]
    ],
    twoPrimitives = [[CIRCLE, 5, 12], [RECT, 8, 6]],
    outerWithHole = [[RECT, 20, 14], [HOLE, [[CIRCLE, 4, 12]]]],
    repeatedSquare = [[RUN, [[REPEAT, 4, [[MOVE, 6], [TURN, 90]]]]]],
    fullArcLoop = [[ARC, 10, 360, 8]],
    popDiscontinuity =
    [
        [MOVE, 10], [PUSH], [MOVE, 5], [POP], [TURN, 90], [MOVE, 10]
    ],
    zeroLength = [[MOVE, 0]],
    duplicatePoint =
    [
        [GOTO, 10.0005, 0, 0],
        [GOTO, 10, 10, 0],
        [GOTO, 10, 0, 0],
        [GOTO, 0, 0, 0]
    ],
    tinyEdge =
    [
        [GOTO, 0.005, 0, 0],
        [GOTO, 10, 0, 0],
        [GOTO, 0, 10, 0],
        [GOTO, 0, 0, 0]
    ],
    nearClosedTriangle =
    [
        [GOTO, 10, 0, 0], [GOTO, 5, 8, 0], [GOTO, 0.0005, 0, 0]
    ],
    stateParityProgram =
    [
        [PUSH], [RUN, [[MOVE, 5], [TURN, 45]], 2], [PENUP], [MOVE, 3]
    ],
    closedResult = ValidateLogoPaths(closedTriangle),
    closedPaths = ValidationPaths(closedResult),
    openResult = ValidateLogoPaths(openTriangle),
    penResult = ValidateLogoPaths(twoClosedPaths),
    primitiveResult = ValidateLogoPaths(twoPrimitives),
    primitivePaths = ValidationPaths(primitiveResult),
    holeResult = ValidateLogoPaths(outerWithHole),
    holePaths = ValidationPaths(holeResult),
    repeatResult = ValidateLogoPaths(repeatedSquare),
    arcResult = ValidateLogoPaths(fullArcLoop),
    popResult = ValidateLogoPaths(popDiscontinuity),
    zeroResult = ValidateLogoPaths(zeroLength),
    zeroIssues = ValidationIssues(zeroResult),
    duplicateResult = ValidateLogoPaths(duplicatePoint),
    duplicateIssues = ValidationIssues(duplicateResult),
    tinyResult = ValidateLogoPaths(tinyEdge),
    tinyIssues = ValidationIssues(tinyResult),
    tinyDisabledResult = ValidateLogoPaths(tinyEdge, tinyEdgeThreshold = 0),
    nearResult = ValidateLogoPaths(nearClosedTriangle, tolerance = 0.001),
    strictNearResult = ValidateLogoPaths(nearClosedTriangle, tolerance = 0.0001),
    emptyResult = ValidateLogoPaths([]),
    pathParityResult = evalLogoPaths(stateParityProgram),
    coreParityResult = evalLogo(stateParityProgram)
)
[
    LogoTestResult(
        "validation closed triangle path count",
        len(closedPaths) == 1,
        len(closedPaths)
    ),
    LogoTestResult(
        "validation closed triangle is valid",
        ValidationIsValid(closedResult),
        ValidationIssues(closedResult)
    ),
    LogoTestResult(
        "validation closed triangle preserves start point",
        PathPointCount(closedPaths[0]) == 4,
        PathPoints(closedPaths[0])
    ),
    LogoTestResult(
        "validation open triangle is invalid",
        !ValidationIsValid(openResult),
        ValidationIssues(openResult)
    ),
    LogoTestResult(
        "validation open triangle reports open path",
        len(ValidationIssues(openResult)) == 1
        && ValidationIssueCode(ValidationIssues(openResult)[0])
            == LOGO_VALIDATION_OPEN_PATH,
        ValidationIssues(openResult)
    ),
    LogoTestResult(
        "validation PENUP/PENDOWN creates two paths",
        len(ValidationPaths(penResult)) == 2,
        ValidationPaths(penResult)
    ),
    LogoTestResult(
        "validation PENUP/PENDOWN closed paths are valid",
        ValidationIsValid(penResult),
        ValidationIssues(penResult)
    ),
    LogoTestResult(
        "validation consecutive primitives remain separate",
        len(primitivePaths) == 2,
        primitivePaths
    ),
    LogoTestResult(
        "validation primitives are explicitly closed",
        ValidationIsValid(primitiveResult)
        && PathKind(primitivePaths[0]) == LOGO_PATH_KIND_PRIMITIVE
        && PathKind(primitivePaths[1]) == LOGO_PATH_KIND_PRIMITIVE
        && PathIsExplicitlyClosed(primitivePaths[0])
        && PathIsExplicitlyClosed(primitivePaths[1])
        && PathSourceOpcode(primitivePaths[0]) == CIRCLE
        && PathSourceOpcode(primitivePaths[1]) == RECT,
        primitivePaths
    ),
    LogoTestResult(
        "validation outer and hole path count",
        len(holePaths) == 2,
        holePaths
    ),
    LogoTestResult(
        "validation distinguishes outer and hole roles",
        ValidationIsValid(holeResult)
        && PathRole(holePaths[0]) == LOGO_PATH_ROLE_OUTER
        && PathRole(holePaths[1]) == LOGO_PATH_ROLE_HOLE,
        holePaths
    ),
    LogoTestResult(
        "validation RUN and REPEAT preserve one closed path",
        ValidationIsValid(repeatResult)
        && len(ValidationPaths(repeatResult)) == 1,
        ValidationPaths(repeatResult)
    ),
    LogoTestResult(
        "validation full ARC loop is closed",
        ValidationIsValid(arcResult)
        && PathPointCount(ValidationPaths(arcResult)[0]) == 9,
        ValidationPaths(arcResult)
    ),
    LogoTestResult(
        "validation POP discontinuity splits paths",
        len(ValidationPaths(popResult)) == 2,
        ValidationPaths(popResult)
    ),
    LogoTestResult(
        "validation POP discontinuity reports path issues",
        len(ValidationIssues(popResult)) == 3,
        ValidationIssues(popResult)
    ),
    LogoTestResult(
        "validation zero-length path issue count",
        len(zeroIssues) == 2,
        zeroIssues
    ),
    LogoTestResult(
        "validation zero-length path issue types",
        ValidationIssueCode(zeroIssues[0]) == LOGO_VALIDATION_TOO_FEW_POINTS
        && ValidationIssueCode(zeroIssues[1]) == LOGO_VALIDATION_ZERO_LENGTH_SEGMENT,
        zeroIssues
    ),
    LogoTestResult(
        "validation repeated closure point is not a duplicate",
        len(LogoPathDuplicatePointPairs(ValidationPaths(closedResult)[0])) == 0,
        LogoPathDuplicatePointPairs(ValidationPaths(closedResult)[0])
    ),
    LogoTestResult(
        "validation duplicate nonconsecutive point issue",
        len(duplicateIssues) == 1
        && ValidationIssueCode(duplicateIssues[0])
            == LOGO_VALIDATION_DUPLICATE_POINT,
        duplicateIssues
    ),
    LogoTestResult(
        "validation duplicate point pair indexes",
        LogoPathDuplicatePointPairs(ValidationPaths(duplicateResult)[0]) == [[1, 3]],
        LogoPathDuplicatePointPairs(ValidationPaths(duplicateResult)[0])
    ),
    LogoTestResult(
        "validation tiny nonzero edge issue",
        len(tinyIssues) == 1
        && ValidationIssueCode(tinyIssues[0]) == LOGO_VALIDATION_TINY_EDGE,
        tinyIssues
    ),
    LogoTestResult(
        "validation tiny-edge threshold is recorded",
        ValidationTinyEdgeThreshold(tinyResult)
            == LOGO_VALIDATION_DEFAULT_TINY_EDGE_THRESHOLD,
        ValidationTinyEdgeThreshold(tinyResult)
    ),
    LogoTestResult(
        "validation tiny-edge check can be disabled",
        ValidationIsValid(tinyDisabledResult),
        ValidationIssues(tinyDisabledResult)
    ),
    LogoTestResult(
        "validation closure tolerance accepts near endpoint",
        ValidationIsValid(nearResult),
        ValidationIssues(nearResult)
    ),
    LogoTestResult(
        "validation closure tolerance rejects distant endpoint",
        !ValidationIsValid(strictNearResult)
        && ValidationIssueCode(ValidationIssues(strictNearResult)[0])
            == LOGO_VALIDATION_OPEN_PATH,
        ValidationIssues(strictNearResult)
    ),
    LogoTestResult(
        "validation empty program has no path issues",
        ValidationIsValid(emptyResult)
        && len(ValidationPaths(emptyResult)) == 0,
        emptyResult
    ),
    LogoTestResult(
        "path evaluator preserves Core state, stack, and pen results",
        LogoStateNearlyEqual(
            PathResultState(pathParityResult),
            ResultState(coreParityResult)
        )
        && PathResultStack(pathParityResult) == ResultStack(coreParityResult)
        && PathResultPen(pathParityResult) == ResultPen(coreParityResult),
        [pathParityResult, coreParityResult]
    )
];

function LogoValidationTestSuiteResult() =
    LogoTestSuiteResult("Validation", LogoValidationAutomatedTestResults());

module RunAllLogoValidationTests(reportResults = true)
{
    echo("");
    echo("============================================================");
    echo("LogoSC validation suite");
    echo("============================================================");

    if (reportResults)
    {
        ReportLogoTestRun([LogoValidationTestSuiteResult()]);
    }
}

function LogoAllTestSuiteResults() =
[
    LogoFoundationTestSuiteResult(),
    LogoValidationTestSuiteResult()
];

// Execute both visual/diagnostic suites, then examine their immutable result
// lists together so the final line reports the complete run.
module RunAllLogoTestSuites()
{
    suites = LogoAllTestSuiteResults();

    RunAllLogoSCests(false);
    RunAllLogoValidationTests(false);
    ReportLogoTestRun(suites);
}
