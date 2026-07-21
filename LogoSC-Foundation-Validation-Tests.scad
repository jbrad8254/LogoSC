// ============================================================================
// LogoSC-Foundation-Validation-Tests.scad
//
// Focused tests for LogoSC-Foundation-Validation.scad.
// Include Core, Validation, and LogoSC-Foundation-Tests.scad before this file.
// ============================================================================

module TestLogoValidationSuite()
{
    closedTriangle =
    [
        [MOVE, 10],
        [TURN, 120],
        [MOVE, 10],
        [TURN, 120],
        [MOVE, 10]
    ];

    openTriangle =
    [
        [MOVE, 10],
        [TURN, 120],
        [MOVE, 10],
        [TURN, 120],
        [MOVE, 8]
    ];

    twoClosedPaths =
    [
        [REPEAT, 4, [[MOVE, 8], [TURN, 90]]],
        [PENUP],
        [MOVE, 20],
        [PENDOWN],
        [REPEAT, 3, [[MOVE, 8], [TURN, 120]]]
    ];

    twoPrimitives =
    [
        [CIRCLE, 5, 12],
        [RECT, 8, 6]
    ];

    outerWithHole =
    [
        [RECT, 20, 14],
        [HOLE, [[CIRCLE, 4, 12]]]
    ];

    repeatedSquare =
    [
        [RUN, [[REPEAT, 4, [[MOVE, 6], [TURN, 90]]]]]
    ];

    fullArcLoop =
    [
        [ARC, 10, 360, 8]
    ];

    popDiscontinuity =
    [
        [MOVE, 10],
        [PUSH],
        [MOVE, 5],
        [POP],
        [TURN, 90],
        [MOVE, 10]
    ];

    zeroLength =
    [
        [MOVE, 0]
    ];

    nearClosedTriangle =
    [
        [GOTO, 10, 0, 0],
        [GOTO, 5, 8, 0],
        [GOTO, 0.0005, 0, 0]
    ];

    stateParityProgram =
    [
        [PUSH],
        [RUN, [[MOVE, 5], [TURN, 45]], 2],
        [PENUP],
        [MOVE, 3]
    ];

    closedResult = ValidateLogoPaths(closedTriangle);
    closedPaths = ValidationPaths(closedResult);
    LogoCheck(
        len(closedPaths) == 1,
        "validation closed triangle path count",
        len(closedPaths)
    );
    LogoCheck(
        ValidationIsValid(closedResult),
        "validation closed triangle is valid",
        ValidationIssues(closedResult)
    );
    LogoCheck(
        PathPointCount(closedPaths[0]) == 4,
        "validation closed triangle preserves start point",
        PathPoints(closedPaths[0])
    );

    openResult = ValidateLogoPaths(openTriangle);
    LogoCheck(
        !ValidationIsValid(openResult),
        "validation open triangle is invalid",
        ValidationIssues(openResult)
    );
    LogoCheck(
        len(ValidationIssues(openResult)) == 1
        && ValidationIssueCode(ValidationIssues(openResult)[0])
            == LOGO_VALIDATION_OPEN_PATH,
        "validation open triangle reports open path",
        ValidationIssues(openResult)
    );

    penResult = ValidateLogoPaths(twoClosedPaths);
    LogoCheck(
        len(ValidationPaths(penResult)) == 2,
        "validation PENUP/PENDOWN creates two paths",
        ValidationPaths(penResult)
    );
    LogoCheck(
        ValidationIsValid(penResult),
        "validation PENUP/PENDOWN closed paths are valid",
        ValidationIssues(penResult)
    );

    primitiveResult = ValidateLogoPaths(twoPrimitives);
    primitivePaths = ValidationPaths(primitiveResult);
    LogoCheck(
        len(primitivePaths) == 2,
        "validation consecutive primitives remain separate",
        primitivePaths
    );
    LogoCheck(
        ValidationIsValid(primitiveResult)
        && PathKind(primitivePaths[0]) == LOGO_PATH_KIND_PRIMITIVE
        && PathKind(primitivePaths[1]) == LOGO_PATH_KIND_PRIMITIVE
        && PathIsExplicitlyClosed(primitivePaths[0])
        && PathIsExplicitlyClosed(primitivePaths[1])
        && PathSourceOpcode(primitivePaths[0]) == CIRCLE
        && PathSourceOpcode(primitivePaths[1]) == RECT,
        "validation primitives are explicitly closed",
        primitivePaths
    );

    holeResult = ValidateLogoPaths(outerWithHole);
    holePaths = ValidationPaths(holeResult);
    LogoCheck(
        len(holePaths) == 2,
        "validation outer and hole path count",
        holePaths
    );
    LogoCheck(
        ValidationIsValid(holeResult)
        && PathRole(holePaths[0]) == LOGO_PATH_ROLE_OUTER
        && PathRole(holePaths[1]) == LOGO_PATH_ROLE_HOLE,
        "validation distinguishes outer and hole roles",
        holePaths
    );

    repeatResult = ValidateLogoPaths(repeatedSquare);
    LogoCheck(
        ValidationIsValid(repeatResult)
        && len(ValidationPaths(repeatResult)) == 1,
        "validation RUN and REPEAT preserve one closed path",
        ValidationPaths(repeatResult)
    );

    arcResult = ValidateLogoPaths(fullArcLoop);
    LogoCheck(
        ValidationIsValid(arcResult)
        && PathPointCount(ValidationPaths(arcResult)[0]) == 9,
        "validation full ARC loop is closed",
        ValidationPaths(arcResult)
    );

    popResult = ValidateLogoPaths(popDiscontinuity);
    LogoCheck(
        len(ValidationPaths(popResult)) == 2,
        "validation POP discontinuity splits paths",
        ValidationPaths(popResult)
    );
    LogoCheck(
        len(ValidationIssues(popResult)) == 3,
        "validation POP discontinuity reports path issues",
        ValidationIssues(popResult)
    );

    zeroResult = ValidateLogoPaths(zeroLength);
    zeroIssues = ValidationIssues(zeroResult);
    LogoCheck(
        len(zeroIssues) == 2,
        "validation zero-length path issue count",
        zeroIssues
    );
    LogoCheck(
        ValidationIssueCode(zeroIssues[0]) == LOGO_VALIDATION_TOO_FEW_POINTS
        && ValidationIssueCode(zeroIssues[1]) == LOGO_VALIDATION_ZERO_LENGTH_SEGMENT,
        "validation zero-length path issue types",
        zeroIssues
    );

    nearResult = ValidateLogoPaths(nearClosedTriangle, tolerance = 0.001);
    strictNearResult = ValidateLogoPaths(nearClosedTriangle, tolerance = 0.0001);
    LogoCheck(
        ValidationIsValid(nearResult),
        "validation closure tolerance accepts near endpoint",
        ValidationIssues(nearResult)
    );
    LogoCheck(
        !ValidationIsValid(strictNearResult)
        && ValidationIssueCode(ValidationIssues(strictNearResult)[0])
            == LOGO_VALIDATION_OPEN_PATH,
        "validation closure tolerance rejects distant endpoint",
        ValidationIssues(strictNearResult)
    );

    emptyResult = ValidateLogoPaths([]);
    LogoCheck(
        ValidationIsValid(emptyResult)
        && len(ValidationPaths(emptyResult)) == 0,
        "validation empty program has no path issues",
        emptyResult
    );

    pathParityResult = evalLogoPaths(stateParityProgram);
    coreParityResult = evalLogo(stateParityProgram);
    LogoCheck(
        LogoStateNearlyEqual(
            PathResultState(pathParityResult),
            ResultState(coreParityResult)
        )
        && PathResultStack(pathParityResult) == ResultStack(coreParityResult)
        && PathResultPen(pathParityResult) == ResultPen(coreParityResult),
        "path evaluator preserves Core state, stack, and pen results",
        [pathParityResult, coreParityResult]
    );
}

module RunAllLogoValidationTests()
{
    echo("");
    echo("============================================================");
    echo("LogoSC validation suite");
    echo("============================================================");

    TestLogoValidationSuite();
}
