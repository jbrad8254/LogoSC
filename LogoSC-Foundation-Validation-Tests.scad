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
    turtleOuterContinuesAfterHole =
    [
        [MOVE, 10], [TURN, 90], [MOVE, 10],
        [HOLE,
            [
                [PENUP], [GOTO, 5, 5, 0], [PENDOWN], [CIRCLE, 1, 12]
            ]
        ],
        [TURN, 90], [MOVE, 10], [TURN, 90], [MOVE, 10]
    ],
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
    crossedPath =
    [
        [GOTO, 10, 10, 0],
        [GOTO, 0, 10, 0],
        [GOTO, 10, 0, 0],
        [GOTO, 0, 0, 0]
    ],
    nearTouchPath =
    [
        [GOTO, 10, 0, 0],
        [GOTO, 5, 0.0005, 0],
        [GOTO, 5, 10, 0]
    ],
    collinearOverlapPath =
    [
        [GOTO, 10, 0, 0],
        [GOTO, 5, 0, 0],
        [GOTO, 15, 0, 0]
    ],
    implicitClosureCrossingPath =
    [
        [GOTO, 10, 0, 0],
        [GOTO, 0, 10, 0],
        [GOTO, 10, 10, 0]
    ],
    nearClosedTriangle =
    [
        [GOTO, 10, 0, 0], [GOTO, 5, 8, 0], [GOTO, 0.0005, 0, 0]
    ],
    holeOutsideOuter =
    [
        [RECT, 20, 14],
        [HOLE, [[PENUP], [GOTO, 20, 0, 0], [PENDOWN], [CIRCLE, 2, 12]]]
    ],
    holeCrossesOuter =
    [
        [RECT, 20, 14],
        [HOLE, [[PENUP], [GOTO, 9, 0, 0], [PENDOWN], [CIRCLE, 3, 12]]]
    ],
    holeTouchesOuter =
    [
        [RECT, 20, 14],
        [HOLE, [[PENUP], [GOTO, 8, 0, 0], [PENDOWN], [CIRCLE, 2, 12]]]
    ],
    overlappingHoles =
    [
        [RECT, 30, 20],
        [HOLE,
            [
                [PENUP], [GOTO, -2, 0, 0], [PENDOWN], [CIRCLE, 4, 16],
                [PENUP], [GOTO,  2, 0, 0], [PENDOWN], [CIRCLE, 4, 16]
            ]
        ]
    ],
    nestedHoles =
    [
        [RECT, 30, 20],
        [HOLE, [[CIRCLE, 4, 16], [CIRCLE, 2, 16]]]
    ],
    touchingHoles =
    [
        [RECT, 30, 20],
        [HOLE,
            [
                [PENUP], [GOTO, -2, 0, 0], [PENDOWN], [CIRCLE, 2, 16],
                [PENUP], [GOTO,  2, 0, 0], [PENDOWN], [CIRCLE, 2, 16]
            ]
        ]
    ],
    coincidentHoles =
    [
        [RECT, 30, 20],
        [HOLE, [[CIRCLE, 3, 16], [CIRCLE, 3, 16]]]
    ],
    separateHoles =
    [
        [RECT, 30, 20],
        [HOLE,
            [
                [PENUP], [GOTO, -5, 0, 0], [PENDOWN], [CIRCLE, 2, 12],
                [PENUP], [GOTO,  5, 0, 0], [PENDOWN], [CIRCLE, 2, 12]
            ]
        ]
    ],
    squareContour = [[-5, -5], [5, -5], [5, 5], [-5, 5]],
    clockwiseSquareContour = [[-5, -5], [-5, 5], [5, 5], [5, -5]],
    concaveContour = [[0, 0], [4, 0], [2, 2], [4, 4], [0, 4]],
    collinearConvexContour =
        [[0, 0], [2, 0], [4, 0], [4, 4], [0, 4]],
    selfIntersectingContour = [[0, 0], [4, 4], [0, 4], [4, 0]],
    backtrackingContour = [[0, 0], [4, 0], [2, 0], [4, 4], [0, 4]],
    innerContour = [[-2, -2], [2, -2], [2, 2], [-2, 2]],
    disjointContour = [[10, -2], [14, -2], [14, 2], [10, 2]],
    crossingContour = [[4, -2], [8, -2], [8, 2], [4, 2]],
    touchingContour = [[5, -2], [9, -2], [9, 2], [5, 2]],
    regionWithHole = [squareContour, innerContour],
    regionInsideHole = [[[-1, -1], [1, -1], [1, 1], [-1, 1]]],
    regionInsideMaterial = [[[-4, -4], [-3, -4], [-3, -3], [-4, -3]]],
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
    turtleOuterHoleResult = ValidateLogoPaths(turtleOuterContinuesAfterHole),
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
    crossingResult = ValidateLogoPaths(crossedPath),
    crossingIssues = ValidationIssues(crossingResult),
    crossingDisabledResult = ValidateLogoPaths(
        crossedPath,
        checkSelfIntersections = false
    ),
    nearTouchResult = ValidateLogoPaths(nearTouchPath),
    collinearOverlapResult = ValidateLogoPaths(collinearOverlapPath),
    implicitClosureResult = ValidateLogoPaths(implicitClosureCrossingPath),
    nearResult = ValidateLogoPaths(nearClosedTriangle, tolerance = 0.001),
    strictNearResult = ValidateLogoPaths(nearClosedTriangle, tolerance = 0.0001),
    holeOutsideResult = ValidateLogoPaths(holeOutsideOuter),
    holeCrossingResult = ValidateLogoPaths(holeCrossesOuter),
    holeTouchingResult = ValidateLogoPaths(holeTouchesOuter),
    overlappingHolesResult = ValidateLogoPaths(overlappingHoles),
    nestedHolesResult = ValidateLogoPaths(nestedHoles),
    touchingHolesResult = ValidateLogoPaths(touchingHoles),
    coincidentHolesResult = ValidateLogoPaths(coincidentHoles),
    separateHolesResult = ValidateLogoPaths(separateHoles),
    topologyDisabledResult = ValidateLogoPaths(
        overlappingHoles,
        checkHoleTopology = false
    ),
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
        "validation proper self-intersection issue",
        len(crossingIssues) == 1
        && ValidationIssueCode(crossingIssues[0])
            == LOGO_VALIDATION_SELF_INTERSECTION
        && ValidationIssueName(LOGO_VALIDATION_SELF_INTERSECTION)
            == "self-intersection",
        crossingIssues
    ),
    LogoTestResult(
        "validation self-intersection segment pair indexes",
        LogoPathSelfIntersectionPairs(ValidationPaths(crossingResult)[0]) == [[0, 2]],
        LogoPathSelfIntersectionPairs(ValidationPaths(crossingResult)[0])
    ),
    LogoTestResult(
        "validation self-intersection checking defaults on",
        ValidationChecksSelfIntersections(crossingResult),
        ValidationChecksSelfIntersections(crossingResult)
    ),
    LogoTestResult(
        "validation self-intersection checking can be disabled",
        ValidationIsValid(crossingDisabledResult)
        && !ValidationChecksSelfIntersections(crossingDisabledResult),
        [
            ValidationIssues(crossingDisabledResult),
            ValidationChecksSelfIntersections(crossingDisabledResult)
        ]
    ),
    LogoTestResult(
        "validation ordinary closed path has no crossing pairs",
        LogoPathSelfIntersectionPairs(closedPaths[0]) == [],
        LogoPathSelfIntersectionPairs(closedPaths[0])
    ),
    LogoTestResult(
        "validation nonadjacent endpoint touch is not a proper crossing",
        LogoPathSelfIntersectionPairs(ValidationPaths(duplicateResult)[0]) == [],
        LogoPathSelfIntersectionPairs(ValidationPaths(duplicateResult)[0])
    ),
    LogoTestResult(
        "validation tolerance-level near touch is not a proper crossing",
        LogoPathSelfIntersectionPairs(ValidationPaths(nearTouchResult)[0]) == [],
        LogoPathSelfIntersectionPairs(ValidationPaths(nearTouchResult)[0])
    ),
    LogoTestResult(
        "validation collinear overlap is not a proper crossing",
        LogoPathSelfIntersectionPairs(ValidationPaths(collinearOverlapResult)[0]) == [],
        LogoPathSelfIntersectionPairs(ValidationPaths(collinearOverlapResult)[0])
    ),
    LogoTestResult(
        "validation does not invent an implicit closing edge",
        LogoPathSelfIntersectionPairs(ValidationPaths(implicitClosureResult)[0]) == [],
        LogoPathSelfIntersectionPairs(ValidationPaths(implicitClosureResult)[0])
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
        "segment relation classifies proper crossing",
        LogoSegmentRelation(
            [0, 0], [10, 10], [0, 10], [10, 0]
        ) == LOGO_SEGMENT_RELATION_PROPER_CROSSING,
        LogoSegmentRelation([0, 0], [10, 10], [0, 10], [10, 0])
    ),
    LogoTestResult(
        "segment relation classifies endpoint touch",
        LogoSegmentRelation(
            [0, 0], [10, 0], [10, 0], [10, 5]
        ) == LOGO_SEGMENT_RELATION_TOUCH,
        LogoSegmentRelation([0, 0], [10, 0], [10, 0], [10, 5])
    ),
    LogoTestResult(
        "segment relation classifies collinear overlap",
        LogoSegmentRelation(
            [0, 0], [10, 0], [5, 0], [15, 0]
        ) == LOGO_SEGMENT_RELATION_COLLINEAR_OVERLAP,
        LogoSegmentRelation([0, 0], [10, 0], [5, 0], [15, 0])
    ),
    LogoTestResult(
        "segment relation rejects separated parallel segments",
        LogoSegmentRelation(
            [0, 0], [10, 0], [0, 2], [10, 2]
        ) == LOGO_SEGMENT_RELATION_NONE,
        LogoSegmentRelation([0, 0], [10, 0], [0, 2], [10, 2])
    ),
    LogoTestResult(
        "contour relation reports crossing segment indexes",
        len(LogoContourIntersectionPairs(squareContour, crossingContour)) == 2
        && ContourIntersectionRelation(
            LogoContourIntersectionPairs(squareContour, crossingContour)[0]
        ) == LOGO_SEGMENT_RELATION_PROPER_CROSSING,
        LogoContourIntersectionPairs(squareContour, crossingContour)
    ),
    LogoTestResult(
        "point-contour relation distinguishes inside boundary outside",
        LogoPointContourRelation([0, 0], squareContour)
            == LOGO_POINT_RELATION_INSIDE
        && LogoPointContourRelation([5, 0], squareContour)
            == LOGO_POINT_RELATION_BOUNDARY
        && LogoPointContourRelation([8, 0], squareContour)
            == LOGO_POINT_RELATION_OUTSIDE,
        [
            LogoPointContourRelation([0, 0], squareContour),
            LogoPointContourRelation([5, 0], squareContour),
            LogoPointContourRelation([8, 0], squareContour)
        ]
    ),
    LogoTestResult(
        "point-region relation excludes holes",
        LogoPointRegionRelation([0, 0], regionWithHole)
            == LOGO_POINT_RELATION_OUTSIDE
        && LogoPointRegionRelation([-4, -4], regionWithHole)
            == LOGO_POINT_RELATION_INSIDE,
        [
            LogoPointRegionRelation([0, 0], regionWithHole),
            LogoPointRegionRelation([-4, -4], regionWithHole)
        ]
    ),
    LogoTestResult(
        "region relation detects overlap",
        LogoRegionRelation([squareContour], [crossingContour])
            == LOGO_REGION_RELATION_OVERLAP,
        LogoRegionRelation([squareContour], [crossingContour])
    ),
    LogoTestResult(
        "region relation distinguishes touching",
        LogoRegionRelation([squareContour], [touchingContour])
            == LOGO_REGION_RELATION_TOUCH,
        LogoRegionRelation([squareContour], [touchingContour])
    ),
    LogoTestResult(
        "region relation detects containment",
        LogoRegionRelation([squareContour], regionInsideMaterial)
            == LOGO_REGION_RELATION_A_CONTAINS_B,
        LogoRegionRelation([squareContour], regionInsideMaterial)
    ),
    LogoTestResult(
        "region relation treats shape inside hole as disjoint",
        LogoRegionRelation(regionWithHole, regionInsideHole)
            == LOGO_REGION_RELATION_DISJOINT
        && !LogoRegionsIntersect(regionWithHole, regionInsideHole),
        LogoRegionRelation(regionWithHole, regionInsideHole)
    ),
    LogoTestResult(
        "convex contour accepts both winding directions",
        LogoContourIsConvex(squareContour)
        && LogoContourIsConvex(clockwiseSquareContour),
        [
            LogoContourTurnSigns(squareContour),
            LogoContourTurnSigns(clockwiseSquareContour)
        ]
    ),
    LogoTestResult(
        "concave contour is not convex",
        !LogoContourIsConvex(concaveContour),
        LogoContourTurnSigns(concaveContour)
    ),
    LogoTestResult(
        "collinear convex contour distinguishes strict mode",
        LogoContourIsConvex(collinearConvexContour)
        && !LogoContourIsConvex(collinearConvexContour, strict = true),
        LogoContourTurnSigns(collinearConvexContour)
    ),
    LogoTestResult(
        "self-intersecting contour is not convex",
        !LogoContourIsConvex(selfIntersectingContour)
        && !LogoContourIsSimple(selfIntersectingContour),
        LogoContourSelfIntersectionPairs(selfIntersectingContour)
    ),
    LogoTestResult(
        "backtracking contour is not convex",
        !LogoContourIsConvex(backtrackingContour)
        && LogoContourHasBacktrackingTurn(backtrackingContour),
        LogoContourTurnSigns(backtrackingContour)
    ),
    LogoTestResult(
        "too-few-point contour is not convex",
        !LogoContourIsConvex([[0, 0], [1, 0]]),
        LogoContourTurnSigns([[0, 0], [1, 0]])
    ),
    LogoTestResult(
        "path convexity requires a closed path",
        LogoPathIsConvex(closedPaths[0])
        && !LogoPathIsConvex(ValidationPaths(openResult)[0]),
        [
            LogoPathIsConvex(closedPaths[0]),
            LogoPathIsConvex(ValidationPaths(openResult)[0])
        ]
    ),
    LogoTestResult(
        "single-contour region is convex",
        LogoRegionIsConvex([squareContour]),
        LogoRegionIsConvex([squareContour])
    ),
    LogoTestResult(
        "region with a hole is not convex",
        !LogoRegionIsConvex(regionWithHole),
        LogoRegionIsConvex(regionWithHole)
    ),
    LogoTestResult(
        "multiple convex regions are individually convex",
        LogoRegionsAreIndividuallyConvex(
            [[squareContour], [disjointContour]]
        ),
        LogoRegionsAreIndividuallyConvex(
            [[squareContour], [disjointContour]]
        )
    ),
    LogoTestResult(
        "multiple regions detect a concave member",
        !LogoRegionsAreIndividuallyConvex(
            [[squareContour], [concaveContour]]
        ),
        LogoRegionsAreIndividuallyConvex(
            [[squareContour], [concaveContour]]
        )
    ),
    LogoTestResult(
        "multiple regions detect a member with a hole",
        !LogoRegionsAreIndividuallyConvex(
            [[squareContour], regionWithHole]
        ),
        LogoRegionsAreIndividuallyConvex(
            [[squareContour], regionWithHole]
        )
    ),
    LogoTestResult(
        "valid hole is ordered after owning outer",
        PathRole(holePaths[0]) == LOGO_PATH_ROLE_OUTER
        && PathRole(holePaths[1]) == LOGO_PATH_ROLE_HOLE
        && LogoPathOwningOuterIndex(holePaths, 1) == 0,
        holePaths
    ),
    LogoTestResult(
        "HOLE preserves active turtle outer continuity",
        ValidationIsValid(turtleOuterHoleResult)
        && len(ValidationPaths(turtleOuterHoleResult)) == 2
        && PathRole(ValidationPaths(turtleOuterHoleResult)[0])
            == LOGO_PATH_ROLE_OUTER
        && PathPointCount(ValidationPaths(turtleOuterHoleResult)[0]) == 5
        && PathRole(ValidationPaths(turtleOuterHoleResult)[1])
            == LOGO_PATH_ROLE_HOLE,
        ValidationPaths(turtleOuterHoleResult)
    ),
    LogoTestResult(
        "hole outside outer contour is invalid",
        !ValidationIsValid(holeOutsideResult)
        && ValidationIssueCode(ValidationIssues(holeOutsideResult)[0])
            == LOGO_VALIDATION_HOLE_OUTSIDE_OUTER
        && ValidationIssueRelatedPathIndex(
            ValidationIssues(holeOutsideResult)[0]
        ) == 0,
        ValidationIssues(holeOutsideResult)
    ),
    LogoTestResult(
        "hole crossing outer boundary is invalid",
        !ValidationIsValid(holeCrossingResult)
        && ValidationIssueCode(ValidationIssues(holeCrossingResult)[0])
            == LOGO_VALIDATION_HOLE_INTERSECTION,
        ValidationIssues(holeCrossingResult)
    ),
    LogoTestResult(
        "hole touching outer boundary is invalid",
        !ValidationIsValid(holeTouchingResult)
        && ValidationIssueCode(ValidationIssues(holeTouchingResult)[0])
            == LOGO_VALIDATION_HOLE_INTERSECTION,
        ValidationIssues(holeTouchingResult)
    ),
    LogoTestResult(
        "overlapping holes are invalid with related path",
        !ValidationIsValid(overlappingHolesResult)
        && len(ValidationIssues(overlappingHolesResult)) == 1
        && ValidationIssueCode(ValidationIssues(overlappingHolesResult)[0])
            == LOGO_VALIDATION_HOLE_OVERLAP
        && ValidationIssueRelatedPathIndex(
            ValidationIssues(overlappingHolesResult)[0]
        ) != undef,
        ValidationIssues(overlappingHolesResult)
    ),
    LogoTestResult(
        "nested holes are invalid",
        !ValidationIsValid(nestedHolesResult)
        && ValidationIssueCode(ValidationIssues(nestedHolesResult)[0])
            == LOGO_VALIDATION_HOLE_OVERLAP,
        ValidationIssues(nestedHolesResult)
    ),
    LogoTestResult(
        "touching holes are invalid",
        !ValidationIsValid(touchingHolesResult)
        && ValidationIssueCode(ValidationIssues(touchingHolesResult)[0])
            == LOGO_VALIDATION_HOLE_OVERLAP,
        ValidationIssues(touchingHolesResult)
    ),
    LogoTestResult(
        "coincident holes are invalid",
        !ValidationIsValid(coincidentHolesResult)
        && ValidationIssueCode(ValidationIssues(coincidentHolesResult)[0])
            == LOGO_VALIDATION_HOLE_OVERLAP,
        ValidationIssues(coincidentHolesResult)
    ),
    LogoTestResult(
        "separate contained holes are valid",
        ValidationIsValid(separateHolesResult),
        ValidationIssues(separateHolesResult)
    ),
    LogoTestResult(
        "hole topology checking defaults on",
        ValidationChecksHoleTopology(overlappingHolesResult),
        ValidationChecksHoleTopology(overlappingHolesResult)
    ),
    LogoTestResult(
        "hole topology checking can be disabled",
        ValidationIsValid(topologyDisabledResult)
        && !ValidationChecksHoleTopology(topologyDisabledResult),
        [
            ValidationIssues(topologyDisabledResult),
            ValidationChecksHoleTopology(topologyDisabledResult)
        ]
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

    RunAllLogoSCTests(false);
    RunAllLogoValidationTests(false);
    ReportLogoTestRun(suites);
}
