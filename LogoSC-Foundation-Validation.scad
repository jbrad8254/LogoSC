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
LOGO_VALIDATION_DUPLICATE_POINT     = 4 + 0;
LOGO_VALIDATION_TINY_EDGE           = 5 + 0;
LOGO_VALIDATION_SELF_INTERSECTION   = 6 + 0;
LOGO_VALIDATION_HOLE_OUTSIDE_OUTER  = 7 + 0;
LOGO_VALIDATION_HOLE_INTERSECTION   = 8 + 0;
LOGO_VALIDATION_HOLE_OVERLAP        = 9 + 0;

// Issue record: [pathIndex, issueCode, relatedPathIndex]
// The optional third field is used for relationships between two paths.
LVI_PATH_INDEX = 0 + 0;
LVI_CODE       = 1 + 0;
LVI_RELATED_PATH_INDEX = 2 + 0;

// Validation result:
// [pathResult, issues, tolerance, tinyEdgeThreshold, checkSelfIntersections,
//  checkHoleTopology]
LVR_PATH_RESULT              = 0 + 0;
LVR_ISSUES                   = 1 + 0;
LVR_TOLERANCE                = 2 + 0;
LVR_TINY_EDGE_THRESHOLD      = 3 + 0;
LVR_CHECK_SELF_INTERSECTIONS = 4 + 0;
LVR_CHECK_HOLE_TOPOLOGY      = 5 + 0;

LOGO_VALIDATION_DEFAULT_TOLERANCE = 0.001 + 0;
LOGO_VALIDATION_DEFAULT_TINY_EDGE_THRESHOLD = 0.01 + 0;
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
//     [finishedPaths, currentRole, currentKind, currentSourceOpcode, currentPoints,
//      pendingHolePaths]
LPB_PATHS      = 0 + 0;
LPB_ROLE       = 1 + 0;
LPB_KIND       = 2 + 0;
LPB_SOURCE_OP  = 3 + 0;
LPB_POINTS     = 4 + 0;
LPB_PENDING_HOLES = 5 + 0;

function LogoPathBuilder(
    paths = [],
    currentRole = undef,
    currentKind = undef,
    currentSourceOp = undef,
    currentPoints = [],
    pendingHolePaths = []) =
[
    paths,
    currentRole,
    currentKind,
    currentSourceOp,
    currentPoints,
    pendingHolePaths
];

function LogoPathBuilderFinalize(builder, explicitlyClosed = undef) =
    let(
        points = builder[LPB_POINTS],
        useExplicitClosed = explicitlyClosed == undef
            ? builder[LPB_KIND] == LOGO_PATH_KIND_PRIMITIVE
            : explicitlyClosed,
        completedPaths = len(points) >= 2
            ? concat(
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
            : [],
        nextPaths = concat(
            builder[LPB_PATHS],
            completedPaths,
            builder[LPB_PENDING_HOLES]
        )
    )
    LogoPathBuilder(nextPaths);

function LogoPathBuilderStart(builder, role, kind, sourceOp, fromPoint, toPoint) =
    LogoPathBuilder(
        builder[LPB_PATHS],
        role,
        kind,
        sourceOp,
        [fromPoint, toPoint],
        builder[LPB_PENDING_HOLES]
    );

function LogoPathBuilderAppend(builder, toPoint) =
    LogoPathBuilder(
        builder[LPB_PATHS],
        builder[LPB_ROLE],
        builder[LPB_KIND],
        builder[LPB_SOURCE_OP],
        concat(builder[LPB_POINTS], [toPoint]),
        builder[LPB_PENDING_HOLES]
    );

// Holes belong after the active outer path. Delay them while a turtle outer is
// still being assembled; a finalized primitive outer can accept them directly.
function LogoPathBuilderAddHoles(builder, holePaths) =
    len(builder[LPB_POINTS]) > 0
        ? LogoPathBuilder(
            builder[LPB_PATHS],
            builder[LPB_ROLE],
            builder[LPB_KIND],
            builder[LPB_SOURCE_OP],
            builder[LPB_POINTS],
            concat(builder[LPB_PENDING_HOLES], holePaths)
        )
        : LogoPathBuilder(
            concat(builder[LPB_PATHS], holePaths)
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
                nextBuilder = LogoPathBuilderAddHoles(
                    builder,
                    childBuilder[LPB_PATHS]
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

function LogoValidationPointDistance(a, b) =
    sqrt(pow(a[0] - b[0], 2) + pow(a[1] - b[1], 2));

// A tiny edge is not classified as zero-length under the tolerance, but is no
// longer than the configured threshold. Set the threshold to zero to disable.
function LogoPathHasTinyEdge(
    path,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    tinyEdgeThreshold = LOGO_VALIDATION_DEFAULT_TINY_EDGE_THRESHOLD,
    index = 0) =
    tinyEdgeThreshold <= tolerance || index >= PathSegmentCount(path)
        ? false
        : let(
            edgeLength = LogoValidationPointDistance(
                PathPoints(path)[index],
                PathPoints(path)[index + 1]
            )
        )
        !LogoValidationPointsNear(
            PathPoints(path)[index],
            PathPoints(path)[index + 1],
            tolerance
        )
        && edgeLength <= tinyEdgeThreshold
            ? true
            : LogoPathHasTinyEdge(path, tolerance, tinyEdgeThreshold, index + 1);

function LogoPathDuplicatePointPairs(
    path,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    let(
        points = PathPoints(path),
        pointCount = len(points)
    )
    pointCount < 3
        ? []
        : [
            for (firstIndex = [0 : pointCount - 3])
                for (secondIndex = [firstIndex + 2 : pointCount - 1])
                    if (
                        !(
                            firstIndex == 0
                            && secondIndex == pointCount - 1
                            && LogoValidationPointsNear(
                                points[firstIndex],
                                points[secondIndex],
                                tolerance
                            )
                        )
                        && LogoValidationPointsNear(
                            points[firstIndex],
                            points[secondIndex],
                            tolerance
                        )
                    )
                    [firstIndex, secondIndex]
        ];

function LogoPathHasDuplicateNonconsecutivePoint(
    path,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    len(LogoPathDuplicatePointPairs(path, tolerance)) > 0;

function LogoValidationSubtract2D(a, b) =
    [a[0] - b[0], a[1] - b[1]];

function LogoValidationCross2D(a, b) =
    a[0] * b[1] - a[1] * b[0];

// Return -1, 0, or 1 according to which side of directed segment a-b the
// point lies. Scaling tolerance by segment length is equivalent to comparing
// perpendicular distance in the same units as the public tolerance.
function LogoValidationSegmentSide(a, b, point, tolerance) =
    let(
        segmentLength = LogoValidationPointDistance(a, b),
        crossValue = LogoValidationCross2D(
            LogoValidationSubtract2D(b, a),
            LogoValidationSubtract2D(point, a)
        ),
        scaledTolerance = tolerance * segmentLength
    )
    LogoValidationPointsNear(a, b, tolerance)
    || abs(crossValue) <= scaledTolerance
        ? 0
        : crossValue < 0 ? -1 : 1;

function LogoValidationRangesOverlap(
    firstMin,
    firstMax,
    secondMin,
    secondMax,
    tolerance) =
    firstMax >= secondMin - tolerance
    && secondMax >= firstMin - tolerance;

function LogoValidationSegmentBoundsOverlap(a, b, c, d, tolerance) =
    LogoValidationRangesOverlap(
        min(a[0], b[0]),
        max(a[0], b[0]),
        min(c[0], d[0]),
        max(c[0], d[0]),
        tolerance
    )
    && LogoValidationRangesOverlap(
        min(a[1], b[1]),
        max(a[1], b[1]),
        min(c[1], d[1]),
        max(c[1], d[1]),
        tolerance
    );

// Detect a proper interior intersection. A side value of zero represents an
// endpoint touch, collinearity, or a tolerance-level near touch and is excluded.
function LogoValidationSegmentsProperlyCross(a, b, c, d, tolerance) =
    !LogoValidationSegmentBoundsOverlap(a, b, c, d, tolerance)
        ? false
        : let(
            cSide = LogoValidationSegmentSide(a, b, c, tolerance),
            dSide = LogoValidationSegmentSide(a, b, d, tolerance),
            aSide = LogoValidationSegmentSide(c, d, a, tolerance),
            bSide = LogoValidationSegmentSide(c, d, b, tolerance)
        )
        cSide * dSide < 0 && aSide * bSide < 0;

// Public segment relationship classifications.
LOGO_SEGMENT_RELATION_NONE              = 0 + 0;
LOGO_SEGMENT_RELATION_PROPER_CROSSING   = 1 + 0;
LOGO_SEGMENT_RELATION_TOUCH             = 2 + 0;
LOGO_SEGMENT_RELATION_COLLINEAR_OVERLAP = 3 + 0;

function LogoValidationPointOnSegment(point, a, b, tolerance) =
    LogoValidationSegmentSide(a, b, point, tolerance) == 0
    && LogoValidationSegmentBoundsOverlap(a, b, point, point, tolerance);

function LogoValidationCollinearOverlapLength(a, b, c, d) =
    let(
        useX = abs(b[0] - a[0]) >= abs(b[1] - a[1]),
        a0 = useX ? a[0] : a[1],
        b0 = useX ? b[0] : b[1],
        c0 = useX ? c[0] : c[1],
        d0 = useX ? d[0] : d[1]
    )
    min(max(a0, b0), max(c0, d0))
    - max(min(a0, b0), min(c0, d0));

// Classify the geometric relationship between two finite segments.
function LogoSegmentRelation(
    a,
    b,
    c,
    d,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    !LogoValidationSegmentBoundsOverlap(a, b, c, d, tolerance)
        ? LOGO_SEGMENT_RELATION_NONE
        : let(
            cSide = LogoValidationSegmentSide(a, b, c, tolerance),
            dSide = LogoValidationSegmentSide(a, b, d, tolerance),
            aSide = LogoValidationSegmentSide(c, d, a, tolerance),
            bSide = LogoValidationSegmentSide(c, d, b, tolerance),
            allCollinear =
                cSide == 0 && dSide == 0 && aSide == 0 && bSide == 0,
            overlapLength = allCollinear
                ? LogoValidationCollinearOverlapLength(a, b, c, d)
                : 0
        )
          cSide * dSide < 0 && aSide * bSide < 0
            ? LOGO_SEGMENT_RELATION_PROPER_CROSSING
        : allCollinear && overlapLength > tolerance
            ? LOGO_SEGMENT_RELATION_COLLINEAR_OVERLAP
        : LogoValidationPointOnSegment(c, a, b, tolerance)
          || LogoValidationPointOnSegment(d, a, b, tolerance)
          || LogoValidationPointOnSegment(a, c, d, tolerance)
          || LogoValidationPointOnSegment(b, c, d, tolerance)
            ? LOGO_SEGMENT_RELATION_TOUCH
        : LOGO_SEGMENT_RELATION_NONE;

// Closed-contour helpers accept either an implicit closing edge or a repeated
// closing point.
function LogoContourVertexCount(
    points,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    len(points) > 1
    && LogoValidationPointsNear(points[0], points[len(points) - 1], tolerance)
        ? len(points) - 1
        : len(points);

function LogoContourSegmentCount(
    points,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    LogoContourVertexCount(points, tolerance) < 2
        ? 0
        : LogoContourVertexCount(points, tolerance);

function LogoContourSegmentStart(points, index) =
    points[index];

function LogoContourSegmentEnd(
    points,
    index,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    let(vertexCount = LogoContourVertexCount(points, tolerance))
    points[(index + 1) % vertexCount];

// Contour intersection record:
// [firstSegmentIndex, secondSegmentIndex, segmentRelation]
LCI_FIRST_SEGMENT  = 0 + 0;
LCI_SECOND_SEGMENT = 1 + 0;
LCI_RELATION       = 2 + 0;

function LogoContourIntersection(
    firstSegmentIndex,
    secondSegmentIndex,
    relation) =
[
    firstSegmentIndex,
    secondSegmentIndex,
    relation
];

function ContourIntersectionFirstSegment(intersection) =
    intersection[LCI_FIRST_SEGMENT];

function ContourIntersectionSecondSegment(intersection) =
    intersection[LCI_SECOND_SEGMENT];

function ContourIntersectionRelation(intersection) =
    intersection[LCI_RELATION];

function LogoContourIntersectionPairs(
    firstPoints,
    secondPoints,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    let(
        firstCount = LogoContourSegmentCount(firstPoints, tolerance),
        secondCount = LogoContourSegmentCount(secondPoints, tolerance)
    )
    firstCount == 0 || secondCount == 0
        ? []
        : [
            for (firstIndex = [0 : firstCount - 1])
                for (secondIndex = [0 : secondCount - 1])
                    let(
                        relation = LogoSegmentRelation(
                            LogoContourSegmentStart(firstPoints, firstIndex),
                            LogoContourSegmentEnd(firstPoints, firstIndex, tolerance),
                            LogoContourSegmentStart(secondPoints, secondIndex),
                            LogoContourSegmentEnd(secondPoints, secondIndex, tolerance),
                            tolerance
                        )
                    )
                    if (relation != LOGO_SEGMENT_RELATION_NONE)
                        LogoContourIntersection(
                            firstIndex,
                            secondIndex,
                            relation
                        )
        ];

function LogoContourHasBoundaryIntersection(
    firstPoints,
    secondPoints,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    len(LogoContourIntersectionPairs(firstPoints, secondPoints, tolerance)) > 0;

// Public point relationship classifications.
LOGO_POINT_RELATION_OUTSIDE  = 0 + 0;
LOGO_POINT_RELATION_BOUNDARY = 1 + 0;
LOGO_POINT_RELATION_INSIDE   = 2 + 0;

function LogoPointOnContourBoundary(
    point,
    points,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    let(segmentCount = LogoContourSegmentCount(points, tolerance))
    segmentCount == 0
        ? false
        : len([
            for (index = [0 : segmentCount - 1])
                if (LogoValidationPointOnSegment(
                    point,
                    LogoContourSegmentStart(points, index),
                    LogoContourSegmentEnd(points, index, tolerance),
                    tolerance
                ))
                    index
        ]) > 0;

// Odd-even ray crossing after the explicit boundary test above.
function LogoPointContourRelation(
    point,
    points,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    LogoPointOnContourBoundary(point, points, tolerance)
        ? LOGO_POINT_RELATION_BOUNDARY
        : let(
            vertexCount = LogoContourVertexCount(points, tolerance),
            crossings = vertexCount < 3
                ? []
                : [
                    for (index = [0 : vertexCount - 1])
                        let(
                            a = points[index],
                            b = points[(index + 1) % vertexCount],
                            crossesY = (a[1] > point[1]) != (b[1] > point[1]),
                            crossingX = crossesY
                                ? a[0]
                                    + (point[1] - a[1])
                                    * (b[0] - a[0])
                                    / (b[1] - a[1])
                                : point[0]
                        )
                        if (crossesY && crossingX > point[0])
                            index
                ]
        )
        len(crossings) % 2 == 1
            ? LOGO_POINT_RELATION_INSIDE
            : LOGO_POINT_RELATION_OUTSIDE;

function LogoPointRegionRelation(
    point,
    region,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    len(region) == 0
        ? LOGO_POINT_RELATION_OUTSIDE
        : let(
            outerRelation = LogoPointContourRelation(point, region[0], tolerance),
            holeRelations = len(region) <= 1
                ? []
                : [
                    for (holeIndex = [1 : len(region) - 1])
                        LogoPointContourRelation(
                            point,
                            region[holeIndex],
                            tolerance
                        )
                ]
        )
          outerRelation == LOGO_POINT_RELATION_BOUNDARY
            ? LOGO_POINT_RELATION_BOUNDARY
        : outerRelation == LOGO_POINT_RELATION_OUTSIDE
            ? LOGO_POINT_RELATION_OUTSIDE
        : len([
            for (relation = holeRelations)
                if (relation == LOGO_POINT_RELATION_BOUNDARY)
                    relation
          ]) > 0
            ? LOGO_POINT_RELATION_BOUNDARY
        : len([
            for (relation = holeRelations)
                if (relation == LOGO_POINT_RELATION_INSIDE)
                    relation
          ]) > 0
            ? LOGO_POINT_RELATION_OUTSIDE
        : LOGO_POINT_RELATION_INSIDE;

// Region relationship classifications. Touching counts as an intersection but
// remains distinct from positive-area overlap.
LOGO_REGION_RELATION_DISJOINT    = 0 + 0;
LOGO_REGION_RELATION_TOUCH       = 1 + 0;
LOGO_REGION_RELATION_OVERLAP     = 2 + 0;
LOGO_REGION_RELATION_A_CONTAINS_B = 3 + 0;
LOGO_REGION_RELATION_B_CONTAINS_A = 4 + 0;

function LogoRegionBoundaryIntersections(
    firstRegion,
    secondRegion,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    len(firstRegion) == 0 || len(secondRegion) == 0
        ? []
        : [
            for (firstContourIndex = [0 : len(firstRegion) - 1])
                for (secondContourIndex = [0 : len(secondRegion) - 1])
                    for (intersection = LogoContourIntersectionPairs(
                        firstRegion[firstContourIndex],
                        secondRegion[secondContourIndex],
                        tolerance
                    ))
                        [
                            firstContourIndex,
                            secondContourIndex,
                            intersection
                        ]
        ];

function LogoRegionRelation(
    firstRegion,
    secondRegion,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    len(firstRegion) == 0 || len(secondRegion) == 0
        ? LOGO_REGION_RELATION_DISJOINT
        : let(
            intersections = LogoRegionBoundaryIntersections(
                firstRegion,
                secondRegion,
                tolerance
            ),
            properCrossings = [
                for (intersection = intersections)
                    if (
                        ContourIntersectionRelation(intersection[2])
                            == LOGO_SEGMENT_RELATION_PROPER_CROSSING
                    )
                        intersection
            ],
            firstInSecond = LogoPointRegionRelation(
                firstRegion[0][0],
                secondRegion,
                tolerance
            ),
            secondInFirst = LogoPointRegionRelation(
                secondRegion[0][0],
                firstRegion,
                tolerance
            )
        )
          len(properCrossings) > 0
            ? LOGO_REGION_RELATION_OVERLAP
        : len(intersections) > 0
            ? LOGO_REGION_RELATION_TOUCH
        : firstInSecond == LOGO_POINT_RELATION_INSIDE
            ? LOGO_REGION_RELATION_B_CONTAINS_A
        : secondInFirst == LOGO_POINT_RELATION_INSIDE
            ? LOGO_REGION_RELATION_A_CONTAINS_B
        : LOGO_REGION_RELATION_DISJOINT;

function LogoRegionsIntersect(
    firstRegion,
    secondRegion,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    LogoRegionRelation(firstRegion, secondRegion, tolerance)
        != LOGO_REGION_RELATION_DISJOINT;

function LogoValidationDot2D(a, b) =
    a[0] * b[0] + a[1] * b[1];

function LogoContourSegmentsAreAdjacent(firstIndex, secondIndex, segmentCount) =
    secondIndex == firstIndex + 1
    || (firstIndex == 0 && secondIndex == segmentCount - 1);

// Return every relationship between nonadjacent segments of one closed contour.
// A simple contour has no such relationships.
function LogoContourSelfIntersectionPairs(
    points,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    let(segmentCount = LogoContourSegmentCount(points, tolerance))
    segmentCount < 3
        ? []
        : [
            for (firstIndex = [0 : segmentCount - 2])
                for (secondIndex = [firstIndex + 1 : segmentCount - 1])
                    if (
                        !LogoContourSegmentsAreAdjacent(
                            firstIndex,
                            secondIndex,
                            segmentCount
                        )
                    )
                        let(
                            relation = LogoSegmentRelation(
                                LogoContourSegmentStart(points, firstIndex),
                                LogoContourSegmentEnd(
                                    points,
                                    firstIndex,
                                    tolerance
                                ),
                                LogoContourSegmentStart(points, secondIndex),
                                LogoContourSegmentEnd(
                                    points,
                                    secondIndex,
                                    tolerance
                                ),
                                tolerance
                            )
                        )
                        if (relation != LOGO_SEGMENT_RELATION_NONE)
                            LogoContourIntersection(
                                firstIndex,
                                secondIndex,
                                relation
                            )
        ];

function LogoContourHasZeroLengthEdge(
    points,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    let(segmentCount = LogoContourSegmentCount(points, tolerance))
    segmentCount == 0
        ? false
        : len([
            for (index = [0 : segmentCount - 1])
                if (LogoValidationPointsNear(
                    LogoContourSegmentStart(points, index),
                    LogoContourSegmentEnd(points, index, tolerance),
                    tolerance
                ))
                    index
        ]) > 0;

// A collinear reversal retraces an adjacent edge and is not a valid convex
// boundary. Forward collinear points remain valid in non-strict mode.
function LogoContourHasBacktrackingTurn(
    points,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    let(vertexCount = LogoContourVertexCount(points, tolerance))
    vertexCount < 3
        ? false
        : len([
            for (index = [0 : vertexCount - 1])
                let(
                    previous = points[(index + vertexCount - 1) % vertexCount],
                    current = points[index],
                    next = points[(index + 1) % vertexCount],
                    incoming = LogoValidationSubtract2D(current, previous),
                    outgoing = LogoValidationSubtract2D(next, current)
                )
                if (
                    LogoValidationSegmentSide(
                        previous,
                        current,
                        next,
                        tolerance
                    ) == 0
                    && LogoValidationDot2D(incoming, outgoing) < 0
                )
                    index
        ]) > 0;

function LogoContourIsSimple(
    points,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    LogoContourVertexCount(points, tolerance) >= 3
    && !LogoContourHasZeroLengthEdge(points, tolerance)
    && !LogoContourHasBacktrackingTurn(points, tolerance)
    && len(LogoContourSelfIntersectionPairs(points, tolerance)) == 0;

function LogoContourTurnSigns(
    points,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    let(vertexCount = LogoContourVertexCount(points, tolerance))
    vertexCount < 3
        ? []
        : [
            for (index = [0 : vertexCount - 1])
                LogoValidationSegmentSide(
                    points[(index + vertexCount - 1) % vertexCount],
                    points[index],
                    points[(index + 1) % vertexCount],
                    tolerance
                )
        ];

// Query geometric convexity without making concavity a validation error.
// strict=false permits forward collinear boundary points.
function LogoContourIsConvex(
    points,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    strict = false) =
    let(
        signs = LogoContourTurnSigns(points, tolerance),
        negativeSigns = [for (sign = signs) if (sign < 0) sign],
        zeroSigns = [for (sign = signs) if (sign == 0) sign],
        positiveSigns = [for (sign = signs) if (sign > 0) sign]
    )
    LogoContourIsSimple(points, tolerance)
    && len(signs) >= 3
    && len(negativeSigns) + len(positiveSigns) > 0
    && !(len(negativeSigns) > 0 && len(positiveSigns) > 0)
    && (!strict || len(zeroSigns) == 0);

function LogoPathIsConvex(
    path,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    strict = false) =
    PathIsClosed(path, tolerance)
    && PathVertexCount(path, tolerance) >= 3
    && LogoContourIsConvex(PathPoints(path), tolerance, strict);

// A filled region with any hole is nonconvex: a line segment between two
// material points can pass through the empty hole.
function LogoRegionIsConvex(
    region,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    strict = false) =
    len(region) == 1
    && LogoContourIsConvex(RegionOuter(region), tolerance, strict);

// Query each region independently. This does not compute whether the geometric
// union of multiple regions is one convex filled set.
function LogoRegionsAreIndividuallyConvex(
    regions,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    strict = false) =
    len(regions) == 0
    || len([
        for (region = regions)
            if (!LogoRegionIsConvex(region, tolerance, strict))
                region
    ]) == 0;

function LogoPathSegmentsAreAdjacent(path, firstIndex, secondIndex, tolerance) =
    secondIndex == firstIndex + 1
    || (
        firstIndex == 0
        && secondIndex == PathSegmentCount(path) - 1
        && PathIsClosed(path, tolerance)
    );

// Return [firstSegmentIndex, secondSegmentIndex] for every proper crossing in
// one explicit path. This intentionally does not invent an implicit closing edge.
function LogoPathSelfIntersectionPairs(
    path,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    let(
        points = PathPoints(path),
        segmentCount = PathSegmentCount(path)
    )
    segmentCount < 3
        ? []
        : [
            for (firstIndex = [0 : segmentCount - 2])
                for (secondIndex = [firstIndex + 1 : segmentCount - 1])
                    if (
                        !LogoPathSegmentsAreAdjacent(
                            path,
                            firstIndex,
                            secondIndex,
                            tolerance
                        )
                        && LogoValidationSegmentsProperlyCross(
                            points[firstIndex],
                            points[firstIndex + 1],
                            points[secondIndex],
                            points[secondIndex + 1],
                            tolerance
                        )
                    )
                    [firstIndex, secondIndex]
        ];

function LogoPathHasSelfIntersection(
    path,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    len(LogoPathSelfIntersectionPairs(path, tolerance)) > 0;

function LogoPathIssueCodes(
    path,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    tinyEdgeThreshold = LOGO_VALIDATION_DEFAULT_TINY_EDGE_THRESHOLD,
    checkSelfIntersections = true) =
    concat(
        PathVertexCount(path, tolerance) < 3
            ? [LOGO_VALIDATION_TOO_FEW_POINTS]
            : [],
        PathIsClosed(path, tolerance)
            ? []
            : [LOGO_VALIDATION_OPEN_PATH],
        LogoPathHasZeroLengthSegment(path, tolerance)
            ? [LOGO_VALIDATION_ZERO_LENGTH_SEGMENT]
            : [],
        LogoPathHasDuplicateNonconsecutivePoint(path, tolerance)
            ? [LOGO_VALIDATION_DUPLICATE_POINT]
            : [],
        LogoPathHasTinyEdge(path, tolerance, tinyEdgeThreshold)
            ? [LOGO_VALIDATION_TINY_EDGE]
            : [],
        checkSelfIntersections
            ? (
                LogoPathHasSelfIntersection(path, tolerance)
                    ? [LOGO_VALIDATION_SELF_INTERSECTION]
                    : []
            )
            : []
    );

function LogoPathOwningOuterIndex(paths, pathIndex, candidateIndex = undef) =
    let(
        index = candidateIndex == undef ? pathIndex - 1 : candidateIndex
    )
    index < 0
        ? undef
        : PathRole(paths[index]) == LOGO_PATH_ROLE_OUTER
            ? index
            : LogoPathOwningOuterIndex(paths, pathIndex, index - 1);

function LogoHolePathPairOverlaps(
    firstPath,
    secondPath,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    let(
        firstPoints = PathPoints(firstPath),
        secondPoints = PathPoints(secondPath),
        intersections = LogoContourIntersectionPairs(
            firstPoints,
            secondPoints,
            tolerance
        )
    )
    len(intersections) > 0
    || LogoPointContourRelation(firstPoints[0], secondPoints, tolerance)
        == LOGO_POINT_RELATION_INSIDE
    || LogoPointContourRelation(secondPoints[0], firstPoints, tolerance)
        == LOGO_POINT_RELATION_INSIDE;

function LogoHoleTopologyIssues(
    paths,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE) =
    len(paths) == 0
        ? []
        : concat(
            [
                for (holeIndex = [0 : len(paths) - 1])
                    if (PathRole(paths[holeIndex]) == LOGO_PATH_ROLE_HOLE)
                        let(
                            outerIndex = LogoPathOwningOuterIndex(paths, holeIndex),
                            boundaryIntersections = outerIndex == undef
                                ? []
                                : LogoContourIntersectionPairs(
                                    PathPoints(paths[outerIndex]),
                                    PathPoints(paths[holeIndex]),
                                    tolerance
                                ),
                            startRelation = outerIndex == undef
                                ? LOGO_POINT_RELATION_OUTSIDE
                                : LogoPointContourRelation(
                                    PathPoints(paths[holeIndex])[0],
                                    PathPoints(paths[outerIndex]),
                                    tolerance
                                )
                        )
                        if (
                            outerIndex == undef
                            || len(boundaryIntersections) > 0
                            || startRelation != LOGO_POINT_RELATION_INSIDE
                        )
                            LogoValidationIssue(
                                holeIndex,
                                len(boundaryIntersections) > 0
                                    ? LOGO_VALIDATION_HOLE_INTERSECTION
                                    : LOGO_VALIDATION_HOLE_OUTSIDE_OUTER,
                                outerIndex
                            )
            ],
            len(paths) < 2
                ? []
                : [
                for (firstIndex = [0 : len(paths) - 2])
                    if (PathRole(paths[firstIndex]) == LOGO_PATH_ROLE_HOLE)
                        for (secondIndex = [firstIndex + 1 : len(paths) - 1])
                            if (
                                PathRole(paths[secondIndex]) == LOGO_PATH_ROLE_HOLE
                                && LogoPathOwningOuterIndex(paths, firstIndex)
                                    == LogoPathOwningOuterIndex(paths, secondIndex)
                                && LogoHolePathPairOverlaps(
                                    paths[firstIndex],
                                    paths[secondIndex],
                                    tolerance
                                )
                            )
                                LogoValidationIssue(
                                    secondIndex,
                                    LOGO_VALIDATION_HOLE_OVERLAP,
                                    firstIndex
                                )
                ]
        );

function LogoValidationIssue(pathIndex, code, relatedPathIndex = undef) =
    relatedPathIndex == undef
        ? [pathIndex, code]
        : [pathIndex, code, relatedPathIndex];

function ValidationIssuePathIndex(issue) =
    issue[LVI_PATH_INDEX];

function ValidationIssueCode(issue) =
    issue[LVI_CODE];

function ValidationIssueRelatedPathIndex(issue) =
    len(issue) <= LVI_RELATED_PATH_INDEX
        ? undef
        : issue[LVI_RELATED_PATH_INDEX];

function ValidationIssueName(code) =
      code == LOGO_VALIDATION_OPEN_PATH
        ? "open path"
    : code == LOGO_VALIDATION_TOO_FEW_POINTS
        ? "too few points"
    : code == LOGO_VALIDATION_ZERO_LENGTH_SEGMENT
        ? "zero-length segment"
    : code == LOGO_VALIDATION_DUPLICATE_POINT
        ? "duplicate nonconsecutive point"
    : code == LOGO_VALIDATION_TINY_EDGE
        ? "tiny edge"
    : code == LOGO_VALIDATION_SELF_INTERSECTION
        ? "self-intersection"
    : code == LOGO_VALIDATION_HOLE_OUTSIDE_OUTER
        ? "hole outside outer contour"
    : code == LOGO_VALIDATION_HOLE_INTERSECTION
        ? "hole intersects outer contour"
    : code == LOGO_VALIDATION_HOLE_OVERLAP
        ? "overlapping holes"
    : str("unknown validation issue ", code);

function LogoValidationResult(
    pathResult,
    issues,
    tolerance,
    tinyEdgeThreshold = LOGO_VALIDATION_DEFAULT_TINY_EDGE_THRESHOLD,
    checkSelfIntersections = true,
    checkHoleTopology = true) =
[
    pathResult,
    issues,
    tolerance,
    tinyEdgeThreshold,
    checkSelfIntersections,
    checkHoleTopology
];

function ValidationPathResult(result) =
    result[LVR_PATH_RESULT];

function ValidationPaths(result) =
    PathResultPaths(ValidationPathResult(result));

function ValidationIssues(result) =
    result[LVR_ISSUES];

function ValidationTolerance(result) =
    result[LVR_TOLERANCE];

function ValidationTinyEdgeThreshold(result) =
    result[LVR_TINY_EDGE_THRESHOLD];

function ValidationChecksSelfIntersections(result) =
    result[LVR_CHECK_SELF_INTERSECTIONS];

function ValidationChecksHoleTopology(result) =
    len(result) <= LVR_CHECK_HOLE_TOPOLOGY
        ? false
        : result[LVR_CHECK_HOLE_TOPOLOGY];

function ValidationIsValid(result) =
    len(ValidationIssues(result)) == 0;

// Validate every drawable path without changing filled-region evaluation or
// rendering. An empty command list has no path issues and is therefore valid.
function ValidateLogoPaths(
    vtCmds,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    state = stateGoto(0, 0, 0, 1),
    maxRec = maxRunRecursions,
    tinyEdgeThreshold = LOGO_VALIDATION_DEFAULT_TINY_EDGE_THRESHOLD,
    checkSelfIntersections = true,
    checkHoleTopology = true) =
    let(
        pathResult = evalLogoPaths(vtCmds, state, maxRec),
        paths = PathResultPaths(pathResult),
        pathIssues = len(paths) == 0
            ? []
            : [
                for (pathIndex = [0 : len(paths) - 1])
                    for (code = LogoPathIssueCodes(
                        paths[pathIndex],
                        tolerance,
                        tinyEdgeThreshold,
                        checkSelfIntersections
                    ))
                        LogoValidationIssue(pathIndex, code)
            ],
        topologyIssues = checkHoleTopology
            ? LogoHoleTopologyIssues(paths, tolerance)
            : [],
        issues = concat(pathIssues, topologyIssues)
    )
    LogoValidationResult(
        pathResult,
        issues,
        tolerance,
        tinyEdgeThreshold,
        checkSelfIntersections,
        checkHoleTopology
    );

// Print validation diagnostics. strict=false reports warnings and continues;
// strict=true asserts after reporting when any issue exists.
module ReportLogoValidation(
    vtCmds,
    tolerance = LOGO_VALIDATION_DEFAULT_TOLERANCE,
    strict = false,
    tinyEdgeThreshold = LOGO_VALIDATION_DEFAULT_TINY_EDGE_THRESHOLD,
    checkSelfIntersections = true,
    checkHoleTopology = true)
{
    result = ValidateLogoPaths(
        vtCmds,
        tolerance = tolerance,
        tinyEdgeThreshold = tinyEdgeThreshold,
        checkSelfIntersections = checkSelfIntersections,
        checkHoleTopology = checkHoleTopology
    );
    paths = ValidationPaths(result);

    for (issue = ValidationIssues(result))
    {
        pathIndex = ValidationIssuePathIndex(issue);
        path = paths[pathIndex];

        echo(
            "[WARNING] LogoSC validation",
            ValidationIssueName(ValidationIssueCode(issue)),
            "path=", pathIndex,
            "relatedPath=", ValidationIssueRelatedPathIndex(issue),
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
