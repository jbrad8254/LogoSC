// ============================================================================
// LogoSC-Foundation-Validation.scad
//
// Optional path analysis and contour validation for LogoSC.
//
// Include LogoSC-Foundation-Core.scad before this file. Core intentionally does
// not include this companion, so basic LogoSC models remain one-file users.
// Validation is non-rendering and does not change RenderLogo2D() or evalLogo().
// ============================================================================

// Path roles.
LOGO_PATH_ROLE_OUTER = 0 + 0;
LOGO_PATH_ROLE_HOLE  = 1 + 0;

// Path construction kinds.
LOGO_PATH_KIND_TURTLE    = 0 + 0;
LOGO_PATH_KIND_PRIMITIVE = 1 + 0;

// Path record: [role, kind, points, sourceOpcode, explicitlyClosed]
LP_ROLE            = 0 + 0;
LP_KIND            = 1 + 0;
LP_POINTS          = 2 + 0;
LP_SOURCE_OP       = 3 + 0;
LP_EXPLICIT_CLOSED = 4 + 0;

// Public path-evaluation result: [state, paths, stack, pen]
LPR_STATE = 0 + 0;
LPR_PATHS = 1 + 0;
LPR_STACK = 2 + 0;
LPR_PEN   = 3 + 0;

// Validation issue codes.
LOGO_VALIDATION_OPEN_PATH           = 1 + 0;
LOGO_VALIDATION_TOO_FEW_POINTS      = 2 + 0;
LOGO_VALIDATION_ZERO_LENGTH_SEGMENT = 3 + 0;

// Issue record: [pathIndex, issueCode]
LVI_PATH_INDEX = 0 + 0;
LVI_CODE       = 1 + 0;

// Validation result: [pathResult, issues, tolerance]
LVR_PATH_RESULT = 0 + 0;
LVR_ISSUES      = 1 + 0;
LVR_TOLERANCE   = 2 + 0;

LOGO_VALIDATION_DEFAULT_TOLERANCE = 0.001 + 0;
LOGO_PATH_CONTINUITY_TOLERANCE = 0.000000001 + 0;

function LogoPath(role, kind, points, sourceOp = undef, explicitlyClosed = false) =
[
    role,
    kind,
    points,
    sourceOp,
    explicitlyClosed
];

function PathRole(path) =
    path[LP_ROLE];

function PathKind(path) =
    path[LP_KIND];

function PathPoints(path) =
    path[LP_POINTS];

function PathSourceOpcode(path) =
    path[LP_SOURCE_OP];

function PathIsExplicitlyClosed(path) =
    path[LP_EXPLICIT_CLOSED];

function PathStart(path) =
    (len(PathPoints(path)) == 0) ? undef : PathPoints(path)[0];

function PathEnd(path) =
    (len(PathPoints(path)) == 0)
        ? undef
        : PathPoints(path)[len(PathPoints(path)) - 1];

function PathPointCount(path) =
    len(PathPoints(path));

function PathSegmentCount(path) =
    max2(0, PathPointCount(path) - 1);

function LogoValidationPointsNear(a, b, tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    a != undef
    && b != undef
    && abs(a[0] - b[0]) <= tolerance
    && abs(a[1] - b[1]) <= tolerance;

function PathIsClosed(path, tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    PathIsExplicitlyClosed(path)
    || LogoValidationPointsNear(PathStart(path), PathEnd(path), tolerance);

// Closed paths store their repeated endpoint, so do not count it twice when
// checking whether polygon generation has at least three usable vertices.
function PathVertexCount(path, tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    PathPointCount(path) == 0
        ? 0
        : (
            PathIsClosed(path, tolerance)
            && LogoValidationPointsNear(PathStart(path), PathEnd(path), tolerance)
        )
            ? PathPointCount(path) - 1
            : PathPointCount(path);

function LogoPathResult(state, paths, stack, pen) =
[
    state,
    paths,
    stack,
    pen
];

function PathResultState(result) =
    result[LPR_STATE];

function PathResultPaths(result) =
    result[LPR_PATHS];

function PathResultStack(result) =
    result[LPR_STACK];

function PathResultPen(result) =
    result[LPR_PEN];

// Internal path-builder result:
//     [finishedPaths, currentRole, currentKind, currentSourceOpcode, currentPoints]
LPB_PATHS      = 0 + 0;
LPB_ROLE       = 1 + 0;
LPB_KIND       = 2 + 0;
LPB_SOURCE_OP  = 3 + 0;
LPB_POINTS     = 4 + 0;

function LogoPathBuilder(
    paths = [],
    currentRole = undef,
    currentKind = undef,
    currentSourceOp = undef,
    currentPoints = []) =
[
    paths,
    currentRole,
    currentKind,
    currentSourceOp,
    currentPoints
];

function LogoPathBuilderFinalize(builder, explicitlyClosed = undef) =
    let(
        points = builder[LPB_POINTS],
        useExplicitClosed = explicitlyClosed == undef
            ? builder[LPB_KIND] == LOGO_PATH_KIND_PRIMITIVE
            : explicitlyClosed,
        nextPaths = len(points) >= 2
            ? concat(
                builder[LPB_PATHS],
                [
                    LogoPath(
                        builder[LPB_ROLE],
                        builder[LPB_KIND],
                        points,
                        builder[LPB_SOURCE_OP],
                        useExplicitClosed
                    )
                ]
            )
            : builder[LPB_PATHS]
    )
    LogoPathBuilder(nextPaths);

function LogoPathBuilderStart(builder, role, kind, sourceOp, fromPoint, toPoint) =
    LogoPathBuilder(
        builder[LPB_PATHS],
        role,
        kind,
        sourceOp,
        [fromPoint, toPoint]
    );

function LogoPathBuilderAppend(builder, toPoint) =
    LogoPathBuilder(
        builder[LPB_PATHS],
        builder[LPB_ROLE],
        builder[LPB_KIND],
        builder[LPB_SOURCE_OP],
        concat(builder[LPB_POINTS], [toPoint])
    );

function LogoPathBuilderCurrentEnd(builder) =
    len(builder[LPB_POINTS]) == 0
        ? undef
        : builder[LPB_POINTS][len(builder[LPB_POINTS]) - 1];

function LogoPathBuilderConsumeSegment(builder, segment, role) =
    (segment[DS_PEN] != PEN_DOWN)
        ? LogoPathBuilderFinalize(builder)
        : let(
            segmentKind = segment[DS_KIND] == DEBUG_SEG_PRIMITIVE
                ? LOGO_PATH_KIND_PRIMITIVE
                : LOGO_PATH_KIND_TURTLE,
            fromPoint = segment[DS_FROM],
            toPoint = segment[DS_TO],
            currentPoints = builder[LPB_POINTS],
            canAppend = len(currentPoints) > 0
                && builder[LPB_ROLE] == role
                && builder[LPB_KIND] == segmentKind
                && LogoValidationPointsNear(
                    LogoPathBuilderCurrentEnd(builder),
                    fromPoint,
                    LOGO_PATH_CONTINUITY_TOLERANCE
                ),
            baseBuilder = canAppend
                ? builder
                : LogoPathBuilderFinalize(builder),
            nextBuilder = canAppend
                ? LogoPathBuilderAppend(baseBuilder, toPoint)
                : LogoPathBuilderStart(
                    baseBuilder,
                    role,
                    segmentKind,
                    segment[DS_OP],
                    fromPoint,
                    toPoint
                ),
            primitiveClosed = segmentKind == LOGO_PATH_KIND_PRIMITIVE
                && len(nextBuilder[LPB_POINTS]) >= 3
                && LogoValidationPointsNear(
                    nextBuilder[LPB_POINTS][0],
                    LogoPathBuilderCurrentEnd(nextBuilder),
                    LOGO_PATH_CONTINUITY_TOLERANCE
                )
        )
        primitiveClosed
            ? LogoPathBuilderFinalize(nextBuilder, true)
            : nextBuilder;

function LogoPathBuilderConsumeSegments(builder, segments, role, index = 0) =
    index >= len(segments)
        ? builder
        : LogoPathBuilderConsumeSegments(
            LogoPathBuilderConsumeSegment(builder, segments[index], role),
            segments,
            role,
            index + 1
        );

// Internal path-evaluator result: [state, stack, pen, builder]
LPER_STATE   = 0 + 0;
LPER_STACK   = 1 + 0;
LPER_PEN     = 2 + 0;
LPER_BUILDER = 3 + 0;

function LogoPathEvalResult(state, stack, pen, builder) =
[
    state,
    stack,
    pen,
    builder
];

function LogoPathEvalSimple(vCmd, state, stack, pen, builder, role, maxRec) =
    let(
        debugResult = DebugEvalOpcode(vCmd, state, stack, pen, [], [], maxRec),
        nextBuilder = LogoPathBuilderConsumeSegments(
            builder,
            ResultDebugSegments(debugResult),
            role
        )
    )
    LogoPathEvalResult(
        ResultDebugState(debugResult),
        ResultDebugStack(debugResult),
        ResultDebugPen(debugResult),
        nextBuilder
    );

function LogoPathEvalPen(vCmd, state, stack, pen, builder) =
    let(
        nextPen = vCmd[COP] == PENUP ? PEN_UP : PEN_DOWN,
        nextBuilder = LogoPathBuilderFinalize(builder)
    )
    LogoPathEvalResult(state, stack, nextPen, nextBuilder);

function LogoPathEvalRun(vCmd, state, stack, pen, builder, role, maxRec) =
    let(
        childCmds = RunCmds(vCmd),
        localMaxRec = RunMaxRec(vCmd)
    )
    len(childCmds) == 0
        ? LogoPathEvalResult(state, stack, pen, builder)
        : (maxRec <= 0 || localMaxRec <= 0)
            ? let(_err = SoftError("RUN recursion limit reached", vCmd))
            LogoPathEvalResult(state, stack, pen, builder)
            : let(
                nextMaxRec = min2(maxRec - 1, localMaxRec - 1),
                nextScale = RunScale(vCmd) * state[SS],
                nextState = stateMake(state[SX], state[SY], state[SH], nextScale)
            )
            evalLogoPathsR(
                childCmds,
                nextState,
                0,
                nextMaxRec,
                stack,
                pen,
                builder,
                role
            );

function LogoPathEvalRepeatR(
    childCmds,
    count,
    state,
    stack,
    pen,
    builder,
    role,
    maxRec) =
    count <= 0
        ? LogoPathEvalResult(state, stack, pen, builder)
        : let(
            result = evalLogoPathsR(
                childCmds,
                state,
                0,
                maxRec,
                stack,
                pen,
                builder,
                role
            )
        )
        LogoPathEvalRepeatR(
            childCmds,
            count - 1,
            result[LPER_STATE],
            result[LPER_STACK],
            result[LPER_PEN],
            result[LPER_BUILDER],
            role,
            maxRec
        );

function LogoPathEvalRepeat(vCmd, state, stack, pen, builder, role, maxRec) =
    (len(vCmd) <= CA2)
        ? let(_err = SoftError("Malformed REPEAT command", vCmd))
        LogoPathEvalResult(state, stack, pen, builder)
        : let(
            repeatCount = RepeatCount(vCmd),
            childCmds = RepeatCmds(vCmd)
        )
        (repeatCount <= 0 || len(childCmds) == 0)
            ? LogoPathEvalResult(state, stack, pen, builder)
            : LogoPathEvalRepeatR(
                childCmds,
                repeatCount,
                state,
                stack,
                pen,
                builder,
                role,
                maxRec
            );

function LogoPathEvalHole(vCmd, state, stack, pen, builder, maxRec) =
    (len(vCmd) <= CA1)
        ? let(_err = SoftError("Malformed HOLE command", vCmd))
        LogoPathEvalResult(state, stack, pen, builder)
        : let(childCmds = HoleCmds(vCmd))
        len(childCmds) == 0
            ? let(_err = SoftError("HOLE child command list is empty", vCmd))
            LogoPathEvalResult(state, stack, pen, builder)
            : let(
                childResult = evalLogoPathsR(
                    childCmds,
                    state,
                    0,
                    maxRec,
                    [],
                    PEN_DOWN,
                    LogoPathBuilder(),
                    LOGO_PATH_ROLE_HOLE
                ),
                childBuilder = LogoPathBuilderFinalize(childResult[LPER_BUILDER]),
                nextBuilder = LogoPathBuilder(
                    concat(builder[LPB_PATHS], childBuilder[LPB_PATHS]),
                    builder[LPB_ROLE],
                    builder[LPB_KIND],
                    builder[LPB_SOURCE_OP],
                    builder[LPB_POINTS]
                )
            )
            LogoPathEvalResult(state, stack, pen, nextBuilder);

function LogoPathEvalOpcode(vCmd, state, stack, pen, builder, role, maxRec) =
      (vCmd[COP] == PENUP || vCmd[COP] == PENDOWN)
        ? LogoPathEvalPen(vCmd, state, stack, pen, builder)
    : (vCmd[COP] == RUN)
        ? LogoPathEvalRun(vCmd, state, stack, pen, builder, role, maxRec)
    : (vCmd[COP] == REPEAT)
        ? LogoPathEvalRepeat(vCmd, state, stack, pen, builder, role, maxRec)
    : (vCmd[COP] == HOLE)
        ? LogoPathEvalHole(vCmd, state, stack, pen, builder, maxRec)
    : LogoPathEvalSimple(vCmd, state, stack, pen, builder, role, maxRec);

function evalLogoPathsR(
    vtCmds,
    state,
    index,
    maxRec,
    stack,
    pen,
    builder,
    role) =
    index >= len(vtCmds)
        ? LogoPathEvalResult(state, stack, pen, builder)
        : let(
            result = LogoPathEvalOpcode(
                vtCmds[index],
                state,
                stack,
                pen,
                builder,
                role,
                maxRec
            )
        )
        evalLogoPathsR(
            vtCmds,
            result[LPER_STATE],
            index + 1,
            maxRec,
            result[LPER_STACK],
            result[LPER_PEN],
            result[LPER_BUILDER],
            role
        );

// Evaluate commands into explicit drawable paths. Turtle paths include their
// starting point, and primitive paths include their repeated closing endpoint.
function evalLogoPaths(
    vtCmds,
    state = stateGoto(0, 0, 0, 1),
    maxRec = maxRunRecursions) =
    let(
        result = evalLogoPathsR(
            vtCmds,
            state,
            0,
            maxRec,
            [],
            PEN_DOWN,
            LogoPathBuilder(),
            LOGO_PATH_ROLE_OUTER
        ),
        finalBuilder = LogoPathBuilderFinalize(result[LPER_BUILDER])
    )
    LogoPathResult(
        result[LPER_STATE],
        finalBuilder[LPB_PATHS],
        result[LPER_STACK],
        result[LPER_PEN]
    );

function LogoPathHasZeroLengthSegment(
    path,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    index = 0) =
    index >= PathSegmentCount(path)
        ? false
        : LogoValidationPointsNear(
            PathPoints(path)[index],
            PathPoints(path)[index + 1],
            tolerance
        )
            ? true
            : LogoPathHasZeroLengthSegment(path, tolerance, index + 1);

function LogoPathIssueCodes(path, tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    concat(
        PathVertexCount(path, tolerance) < 3
            ? [LOGO_VALIDATION_TOO_FEW_POINTS]
            : [],
        PathIsClosed(path, tolerance)
            ? []
            : [LOGO_VALIDATION_OPEN_PATH],
        LogoPathHasZeroLengthSegment(path, tolerance)
            ? [LOGO_VALIDATION_ZERO_LENGTH_SEGMENT]
            : []
    );

function LogoValidationIssue(pathIndex, code) =
[
    pathIndex,
    code
];

function ValidationIssuePathIndex(issue) =
    issue[LVI_PATH_INDEX];

function ValidationIssueCode(issue) =
    issue[LVI_CODE];

function ValidationIssueName(code) =
      code == LOGO_VALIDATION_OPEN_PATH
        ? "open path"
    : code == LOGO_VALIDATION_TOO_FEW_POINTS
        ? "too few points"
    : code == LOGO_VALIDATION_ZERO_LENGTH_SEGMENT
        ? "zero-length segment"
    : str("unknown validation issue ", code);

function LogoValidationResult(pathResult, issues, tolerance) =
[
    pathResult,
    issues,
    tolerance
];

function ValidationPathResult(result) =
    result[LVR_PATH_RESULT];

function ValidationPaths(result) =
    PathResultPaths(ValidationPathResult(result));

function ValidationIssues(result) =
    result[LVR_ISSUES];

function ValidationTolerance(result) =
    result[LVR_TOLERANCE];

function ValidationIsValid(result) =
    len(ValidationIssues(result)) == 0;

// Validate every drawable path without changing filled-region evaluation or
// rendering. An empty command list has no path issues and is therefore valid.
function ValidateLogoPaths(
    vtCmds,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    state = stateGoto(0, 0, 0, 1),
    maxRec = maxRunRecursions) =
    let(
        pathResult = evalLogoPaths(vtCmds, state, maxRec),
        paths = PathResultPaths(pathResult),
        issues = len(paths) == 0
            ? []
            : [
                for (pathIndex = [0 : len(paths) - 1])
                    for (code = LogoPathIssueCodes(paths[pathIndex], tolerance))
                        LogoValidationIssue(pathIndex, code)
            ]
    )
    LogoValidationResult(pathResult, issues, tolerance);

// Print validation diagnostics. strict=false reports warnings and continues;
// strict=true asserts after reporting when any issue exists.
module ReportLogoValidation(
    vtCmds,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    strict = false)
{
    result = ValidateLogoPaths(vtCmds, tolerance);
    paths = ValidationPaths(result);

    for (issue = ValidationIssues(result))
    {
        pathIndex = ValidationIssuePathIndex(issue);
        path = paths[pathIndex];

        echo(
            "[WARNING] LogoSC validation",
            ValidationIssueName(ValidationIssueCode(issue)),
            "path=", pathIndex,
            "role=", PathRole(path),
            "kind=", PathKind(path),
            "start=", PathStart(path),
            "end=", PathEnd(path),
            "points=", PathPointCount(path)
        );
    }

    if (strict)
    {
        assert(
            ValidationIsValid(result),
            str("LogoSC validation failed with ", len(ValidationIssues(result)), " issue(s)")
        );
    }
}
