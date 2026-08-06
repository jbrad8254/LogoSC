// Passive tests for the optional LogoSC knot companion.

function KnotTestNearlyEqual(a, b, tolerance = 0.000001) =
    abs(a - b) <= tolerance;

function KnotTestPointNearlyEqual(a, b, tolerance = 0.000001) =
    len(a) == len(b)
    && len(a) == 3
    && KnotTestNearlyEqual(a[0], b[0], tolerance)
    && KnotTestNearlyEqual(a[1], b[1], tolerance)
    && KnotTestNearlyEqual(a[2], b[2], tolerance);

function KnotRecordTestResults() =
    let(
        crossing = MakeKnotCrossing([1, 2], 0, 0.25, 1, 0.75, 0),
        strand = MakeKnotStrand(
            true,
            [[0, 0, 0], [1, 0, 0], [0, 0, 0]],
            [0],
            [1, 0],
            ["name", "fixture"]
        ),
        knot = MakeKnot([strand, strand], [crossing], ["fixture", true]),
        validation = MakeKnotValidationResult(knot, [], 0.01),
        planarKnot = KnotForView(knot, "Planar"),
        spatialKnot = KnotForView(knot, "Spatial")
    )
[
    LogoTestResult(
        "knot record accessors",
        KnotStrands(knot) == [strand, strand]
        && KnotCrossings(knot) == [crossing]
        && KnotMetadata(knot) == ["fixture", true]
    ),
    LogoTestResult(
        "knot strand accessors",
        KnotStrandClosed(strand)
        && KnotStrandSamples(strand)[1] == [1, 0, 0]
        && KnotStrandCrossingEncounters(strand) == [0]
        && KnotStrandLaneClosurePermutation(strand) == [1, 0]
        && KnotStrandMetadata(strand) == ["name", "fixture"]
        && KnotStrandSampleCount(strand) == 3
        && KnotStrandSegmentCount(strand) == 2
    ),
    LogoTestResult(
        "knot crossing accessors",
        KnotCrossingPoint(crossing) == [1, 2]
        && KnotCrossingStrandA(crossing) == 0
        && KnotCrossingParameterA(crossing) == 0.25
        && KnotCrossingStrandB(crossing) == 1
        && KnotCrossingParameterB(crossing) == 0.75
        && KnotCrossingOverStrand(crossing) == 0
        && KnotCrossingOverBranch(crossing) == "A"
    ),
    LogoTestResult(
        "knot validation result accessors",
        KnotValidationKnot(validation) == knot
        && KnotValidationIssues(validation) == []
        && KnotValidationTolerance(validation) == 0.01
        && KnotValidationIsValid(validation)
    ),
    LogoTestResult(
        "knot debug view projection",
        KnotDebugViewPoint([1, 2, 3], "Planar") == [1, 2, 0]
        && KnotDebugViewPoint([1, 2, 3], "Spatial") == [1, 2, 3]
        && KnotStrandSamples(KnotStrands(planarKnot)[0])[1] == [1, 0, 0]
        && KnotCrossings(planarKnot) == KnotCrossings(knot)
        && KnotMetadata(planarKnot) == KnotMetadata(knot)
        && spatialKnot == knot
    )
];

function KnotValidationTestResults() =
    let(
        validCrossing = MakeKnotCrossing([0, 0], 0, 0.2, 1, 0.8, 1),
        validStrandA = MakeKnotStrand(
            true,
            [[0, 0, 0], [1, 0, 0], [0, 0, 0]],
            [0]
        ),
        validStrandB = MakeKnotStrand(
            true,
            [[0, 1, 0], [1, 1, 0], [0, 1, 0]],
            [0]
        ),
        validKnot = MakeKnot([validStrandA, validStrandB], [validCrossing]),
        openKnot = MakeKnot([
            MakeKnotStrand(true, [[0, 0, 0], [1, 0, 0], [2, 0, 0]])
        ]),
        malformedSampleKnot = MakeKnot([
            MakeKnotStrand(false, [[0, 0], [1, 0, 0]])
        ]),
        badEncounterKnot = MakeKnot([
            MakeKnotStrand(false, [[0, 0, 0], [1, 0, 0]], [2])
        ]),
        wrongStrandEncounterKnot = MakeKnot(
            [
                MakeKnotStrand(false, [[0, 0, 0], [1, 0, 0]], [0]),
                validStrandA,
                validStrandB
            ],
            [MakeKnotCrossing([0, 0], 1, 0.2, 2, 0.8, 1)]
        ),
        badPermutationKnot = MakeKnot([
            MakeKnotStrand(false, [[0, 0, 0], [1, 0, 0]], [], [0, 0])
        ]),
        badStrandCrossing = MakeKnot(
            [validStrandA],
            [MakeKnotCrossing([0, 0], 0, 0.2, 2, 0.8, 0)]
        ),
        badParameterCrossing = MakeKnot(
            [validStrandA, validStrandB],
            [MakeKnotCrossing([0, 0], 0, -0.1, 1, 1.1, 0)]
        ),
        badOverCrossing = MakeKnot(
            [validStrandA, validStrandB],
            [MakeKnotCrossing([0, 0], 0, 0.2, 1, 0.8, 2)]
        ),
        badBranchCrossing = MakeKnot(
            [validStrandA],
            [MakeKnotCrossing([0, 0], 0, 0.2, 0, 0.8, 0)]
        )
    )
[
    LogoTestResult(
        "knot valid structure",
        KnotValidationIsValid(ValidateKnot(validKnot))
    ),
    LogoTestResult(
        "knot malformed root",
        KnotValidationIssueCode(KnotValidationIssues(ValidateKnot([1]))[0])
            == KNOT_ISSUE_MALFORMED_KNOT
    ),
    LogoTestResult(
        "knot closed endpoint validation",
        KnotValidationIssueCode(KnotValidationIssues(ValidateKnot(openKnot))[0])
            == KNOT_ISSUE_OPEN_CLOSURE
    ),
    LogoTestResult(
        "knot malformed sample validation",
        KnotListContains(
            [
                for (issue = KnotValidationIssues(ValidateKnot(malformedSampleKnot)))
                    KnotValidationIssueCode(issue)
            ],
            KNOT_ISSUE_MALFORMED_SAMPLE
        )
    ),
    LogoTestResult(
        "knot encounter index validation",
        KnotValidationIssueCode(
            KnotValidationIssues(ValidateKnot(badEncounterKnot))[0]
        ) == KNOT_ISSUE_ENCOUNTER_INDEX
    ),
    LogoTestResult(
        "knot encounter strand validation",
        KnotListContains(
            [
                for (
                    issue = KnotValidationIssues(
                        ValidateKnot(wrongStrandEncounterKnot)
                    )
                )
                    KnotValidationIssueCode(issue)
            ],
            KNOT_ISSUE_ENCOUNTER_STRAND
        )
    ),
    LogoTestResult(
        "knot lane permutation validation",
        KnotValidationIssueCode(
            KnotValidationIssues(ValidateKnot(badPermutationKnot))[0]
        ) == KNOT_ISSUE_LANE_PERMUTATION
    ),
    LogoTestResult(
        "knot crossing strand validation",
        KnotListContains(
            [
                for (issue = KnotValidationIssues(ValidateKnot(badStrandCrossing)))
                    KnotValidationIssueCode(issue)
            ],
            KNOT_ISSUE_CROSSING_STRAND
        )
    ),
    LogoTestResult(
        "knot crossing parameter validation",
        KnotListContains(
            [
                for (issue = KnotValidationIssues(ValidateKnot(badParameterCrossing)))
                    KnotValidationIssueCode(issue)
            ],
            KNOT_ISSUE_CROSSING_PARAMETER
        )
    ),
    LogoTestResult(
        "knot crossing over validation",
        KnotListContains(
            [
                for (issue = KnotValidationIssues(ValidateKnot(badOverCrossing)))
                    KnotValidationIssueCode(issue)
            ],
            KNOT_ISSUE_CROSSING_OVER
        )
    ),
    LogoTestResult(
        "knot self-crossing branch validation",
        KnotListContains(
            [
                for (issue = KnotValidationIssues(ValidateKnot(badBranchCrossing)))
                    KnotValidationIssueCode(issue)
            ],
            KNOT_ISSUE_CROSSING_BRANCH
        )
    )
];

function KnotTorusTestResults() =
    let(
        unknot = MakeTorusKnot(1, 1, 20, 6, 24),
        trefoil = MakeTorusKnot(2, 3, 20, 6, 60),
        hopf = MakeTorusKnot(2, 2, 20, 6, 32),
        threeComponent = MakeTorusKnot(3, 3, 20, 6, 30),
        hopfSamplesA = KnotStrandSamples(KnotStrands(hopf)[0]),
        hopfSamplesB = KnotStrandSamples(KnotStrands(hopf)[1])
    )
[
    LogoTestResult(
        "torus gcd helper",
        KnotGreatestCommonDivisor(2, 3) == 1
        && KnotGreatestCommonDivisor(4, 2) == 2
        && KnotGreatestCommonDivisor(12, 18) == 6
    ),
    LogoTestResult(
        "torus unknot component and samples",
        len(KnotStrands(unknot)) == 1
        && KnotStrandSampleCount(KnotStrands(unknot)[0]) == 25
    ),
    LogoTestResult(
        "torus trefoil component and samples",
        len(KnotStrands(trefoil)) == 1
        && KnotStrandSampleCount(KnotStrands(trefoil)[0]) == 61
    ),
    LogoTestResult(
        "torus Hopf link component count",
        len(KnotStrands(hopf)) == 2
        && KnotStrandSampleCount(KnotStrands(hopf)[0]) == 33
        && KnotStrandSampleCount(KnotStrands(hopf)[1]) == 33
    ),
    LogoTestResult(
        "torus three-component link count",
        len(KnotStrands(threeComponent)) == 3
    ),
    LogoTestResult(
        "torus exact component closure",
        KnotTestPointNearlyEqual(hopfSamplesA[0], hopfSamplesA[32])
        && KnotTestPointNearlyEqual(hopfSamplesB[0], hopfSamplesB[32])
    ),
    LogoTestResult(
        "torus link components are distinct",
        !KnotTestPointNearlyEqual(hopfSamplesA[0], hopfSamplesB[0])
    ),
    LogoTestResult(
        "torus generator validates",
        KnotValidationIsValid(ValidateKnot(unknot))
        && KnotValidationIsValid(ValidateKnot(trefoil))
        && KnotValidationIsValid(ValidateKnot(hopf))
        && KnotValidationIsValid(ValidateKnot(threeComponent))
    ),
    LogoTestResult(
        "torus generator reserves crossings",
        KnotCrossings(unknot) == []
        && KnotCrossings(trefoil) == []
        && KnotCrossings(hopf) == []
    )
];

function KnotLissajousTestResults() =
    let(
        knot = MakeLissajousKnot(sampleCount = 120),
        strand = KnotStrands(knot)[0],
        samples = KnotStrandSamples(strand),
        crossings = KnotCrossings(knot),
        properIntersection = KnotProperSegmentIntersection(
            [-1, -1, 0],
            [1, 1, 0],
            [-1, 1, 0],
            [1, -1, 0]
        )
    )
[
    LogoTestResult(
        "Lissajous point evaluates three harmonic axes",
        KnotTestPointNearlyEqual(
            KnotLissajousPoint(0, [1, 1, 1], [2, 3, 4], [90, 0, -90]),
            [2, 0, -4]
        )
    ),
    LogoTestResult(
        "Lissajous proper segment intersection",
        !is_undef(properIntersection)
        && KnotTestNearlyEqual(properIntersection[0][0], 0)
        && KnotTestNearlyEqual(properIntersection[0][1], 0)
        && KnotTestNearlyEqual(properIntersection[1], 0.5)
        && KnotTestNearlyEqual(properIntersection[2], 0.5)
    ),
    LogoTestResult(
        "Lissajous adjacent segments do not self-intersect",
        KnotSegmentsAreAdjacent(2, 3, 12)
        && KnotSegmentsAreAdjacent(0, 11, 12)
        && !KnotSegmentsAreAdjacent(2, 4, 12)
    ),
    LogoTestResult(
        "Lissajous generator closes sampled route",
        len(KnotStrands(knot)) == 1
        && KnotStrandSampleCount(strand) == 121
        && KnotTestPointNearlyEqual(samples[0], samples[120])
    ),
    LogoTestResult(
        "Lissajous generator discovers projected crossings",
        len(crossings) == 8
        && len(KnotStrandCrossingEncounters(strand)) == 8
        && min([
            for (crossing = crossings)
                KnotCrossingOverBranch(crossing) == "A"
                || KnotCrossingOverBranch(crossing) == "B"
                ? 1
                : 0
        ]) == 1
    ),
    LogoTestResult(
        "Lissajous generator validates",
        KnotValidationIsValid(ValidateKnot(knot))
    )
];

function KnotCordTestResults() =
    let(
        unknot = MakeTorusKnot(1, 1, 20, 6, 24),
        trefoil = MakeTorusKnot(2, 3, 20, 6, 60),
        hopf = MakeTorusKnot(2, 2, 20, 6, 32),
        openStrand = MakeKnotStrand(
            false,
            [[0, 0, 0], [1, 0, 0], [2, 1, 0], [3, 1, 1]]
        ),
        malformedKnot = [1]
    )
[
    LogoTestResult(
        "knot cord closed segment count",
        KnotStrandSegmentCount(KnotStrands(unknot)[0]) == 24
        && KnotCordSegmentCount(unknot) == 24
        && KnotCordSegmentCount(trefoil) == 60
    ),
    LogoTestResult(
        "knot cord multi-component segment count",
        KnotCordSegmentCount(hopf) == 64
    ),
    LogoTestResult(
        "knot cord open strand segment count",
        KnotStrandSegmentCount(openStrand) == 3
        && KnotCordSegmentCount(MakeKnot([openStrand])) == 3
    ),
    LogoTestResult(
        "knot cord malformed root has no segments",
        KnotCordSegmentCount(malformedKnot) == 0
    )
];

function KnotBundleTestResults() =
    let(
        straightStrand = MakeKnotStrand(
            false,
            [[0, 0, 0], [5, 0, 0], [10, 0, 0]]
        ),
        straightLaterals = KnotStrandStableLaterals(straightStrand),
        trefoil = MakeTorusKnot(2, 3, 20, 6, 60),
        trefoilStrand = KnotStrands(trefoil)[0],
        trefoilTangents = [
            for (sampleIndex = [0 : KnotStrandUniqueSampleCount(trefoilStrand) - 1])
                KnotStrandSampleTangent(trefoilStrand, sampleIndex)
        ],
        trefoilLaterals = KnotStrandStableLaterals(trefoilStrand),
        threeCordTrefoil = MakeKnotBundle(trefoil, 3, 1, 0.5),
        bundledStrands = KnotStrands(threeCordTrefoil),
        masterSamples = KnotStrandSamples(trefoilStrand),
        leftSamples = KnotStrandSamples(bundledStrands[0]),
        centerSamples = KnotStrandSamples(bundledStrands[1]),
        rightSamples = KnotStrandSamples(bundledStrands[2]),
        fittedRadius = KnotBundleFittedRadius(3, 9, 0.75),
        fittedBundle = MakeKnotBundle(
            MakeTorusKnot(1, 1, 20, 6, 24),
            3,
            cordGap = 0.75,
            bundleWidth = 9
        ),
        planarTrefoilBundle = MakeKnotBundle(
            KnotForView(trefoil, "Planar"),
            3,
            1,
            0.5
        ),
        hopfBundle = MakeKnotBundle(
            MakeTorusKnot(2, 2, 20, 6, 24),
            3,
            0.8,
            0.3
        ),
        braidTrefoil = MakeCircularBraidKnot(
            2,
            [1, 1, 1],
            20,
            5,
            5,
            8
        ),
        braidedBundle = MakeKnotBundle(
            braidTrefoil,
            2,
            0.7,
            0.3,
            minimumClearance = 0.2
        ),
        braidedCrossings = KnotCrossings(braidedBundle),
        firstBraidedCrossing = braidedCrossings[0],
        oversizedUncheckedBundle = MakeKnotBundle(
            braidTrefoil,
            2,
            8,
            0,
            checkCrossingClearance = false
        ),
        twoCordHalfTwist = MakeKnotBundle(
            MakeTorusKnot(1, 1, 20, 6, 24),
            2,
            0.8,
            0.3,
            twistHalfTurns = 1
        ),
        threeCordHalfTwist = MakeKnotBundle(
            MakeTorusKnot(1, 1, 20, 6, 24),
            3,
            0.8,
            0.3,
            twistHalfTurns = 1
        ),
        twoCordFullTwist = MakeKnotBundle(
            MakeTorusKnot(1, 1, 20, 6, 24),
            2,
            0.8,
            0.3,
            twistHalfTurns = 2
        ),
        braidedHalfTwist = MakeKnotBundle(
            braidTrefoil,
            2,
            0.45,
            0.2,
            minimumClearance = 0.1,
            twistHalfTurns = 1
        )
    )
[
    LogoTestResult(
        "knot bundle vector helpers",
        KnotVectorAdd([1, 2, 3], [4, 5, 6]) == [5, 7, 9]
        && KnotVectorSubtract([4, 5, 6], [1, 2, 3]) == [3, 3, 3]
        && KnotVectorDot([1, 0, 0], [0, 1, 0]) == 0
        && KnotVectorCross([1, 0, 0], [0, 1, 0]) == [0, 0, 1]
        && KnotTestPointNearlyEqual(
            KnotVectorNormalize([3, 0, 0]),
            [1, 0, 0]
        )
    ),
    LogoTestResult(
        "knot bundle width and fitted radius",
        KnotBundleOccupiedWidth(3, fittedRadius, 0.75) == 9
        && KnotTestNearlyEqual(fittedRadius, 1.25)
        && KnotTestNearlyEqual(
            KnotBundleResolvedRadius(3, 2, 0.75, 9),
            fittedRadius
        )
    ),
    LogoTestResult(
        "knot bundle symmetric lane offsets",
        KnotBundleLaneOffset(0, 3, 1, 0.5) == -2.5
        && KnotBundleLaneOffset(1, 3, 1, 0.5) == 0
        && KnotBundleLaneOffset(2, 3, 1, 0.5) == 2.5
        && KnotBundleLaneOffset(0, 4, 1, 0) == -3
        && KnotBundleLaneOffset(3, 4, 1, 0) == 3
    ),
    LogoTestResult(
        "knot bundle straight stable frame",
        len(straightLaterals) == 3
        && KnotTestPointNearlyEqual(straightLaterals[0], [0, 1, 0])
        && KnotTestPointNearlyEqual(straightLaterals[1], [0, 1, 0])
        && KnotTestPointNearlyEqual(straightLaterals[2], [0, 1, 0])
    ),
    LogoTestResult(
        "knot bundle curved frames are orthonormal",
        len(trefoilLaterals) == 60
        && len([
            for (sampleIndex = [0 : len(trefoilLaterals) - 1])
                if (
                    !KnotTestNearlyEqual(
                        KnotVectorLength(trefoilLaterals[sampleIndex]),
                        1
                    )
                    || !KnotTestNearlyEqual(
                        KnotVectorDot(
                            trefoilLaterals[sampleIndex],
                            trefoilTangents[sampleIndex]
                        ),
                        0
                    )
                    || (
                        sampleIndex > 0
                        && KnotVectorDot(
                            trefoilLaterals[sampleIndex - 1],
                            trefoilLaterals[sampleIndex]
                        ) <= 0
                    )
                )
                    sampleIndex
        ]) == 0
    ),
    LogoTestResult(
        "knot bundle expands strand and sample counts",
        len(bundledStrands) == 3
        && KnotStrandSampleCount(bundledStrands[0]) == 61
        && KnotStrandSampleCount(bundledStrands[1]) == 61
        && KnotStrandSampleCount(bundledStrands[2]) == 61
        && KnotCordSegmentCount(threeCordTrefoil) == 180
    ),
    LogoTestResult(
        "knot bundle center lane preserves master route",
        len([
            for (sampleIndex = [0 : len(masterSamples) - 1])
                if (!KnotTestPointNearlyEqual(
                    centerSamples[sampleIndex],
                    masterSamples[sampleIndex]
                ))
                    sampleIndex
        ]) == 0
    ),
    LogoTestResult(
        "knot bundle adjacent lane separation",
        KnotTestNearlyEqual(
            KnotPointDistance(leftSamples[0], centerSamples[0]),
            2.5
        )
        && KnotTestNearlyEqual(
            KnotPointDistance(centerSamples[0], rightSamples[0]),
            2.5
        )
    ),
    LogoTestResult(
        "knot bundle exact closure and validation",
        KnotTestPointNearlyEqual(
            leftSamples[0],
            leftSamples[len(leftSamples) - 1]
        )
        && KnotTestPointNearlyEqual(
            rightSamples[0],
            rightSamples[len(rightSamples) - 1]
        )
        && KnotValidationIsValid(ValidateKnot(threeCordTrefoil))
        && KnotValidationIsValid(ValidateKnot(fittedBundle))
        && len([
            for (strand = KnotStrands(planarTrefoilBundle))
                for (sample = KnotStrandSamples(strand))
                    if (sample[2] != 0)
                        sample
        ]) == 0
    ),
    LogoTestResult(
        "knot bundle expands every link component",
        len(KnotStrands(hopfBundle)) == 6
        && KnotCordSegmentCount(hopfBundle) == 144
        && KnotValidationIsValid(ValidateKnot(hopfBundle))
    ),
    LogoTestResult(
        "knot bundle remaps braid crossing lane pairs",
        len(KnotStrands(braidedBundle)) == 2
        && len(braidedCrossings) == 12
        && KnotCrossingStrandA(firstBraidedCrossing) == 0
        && KnotCrossingStrandB(firstBraidedCrossing) == 0
        && KnotCrossingOverStrand(firstBraidedCrossing) == 0
        && KnotCrossingOverBranch(firstBraidedCrossing) == "A"
        && KnotCrossingStrandA(braidedCrossings[1]) == 0
        && KnotCrossingStrandB(braidedCrossings[1]) == 1
        && KnotCrossingOverStrand(braidedCrossings[1]) == 0
    ),
    LogoTestResult(
        "knot bundle preserves crossing parameters and encounters",
        KnotCrossingParameterA(firstBraidedCrossing)
            == KnotCrossingParameterA(KnotCrossings(braidTrefoil)[0])
        && KnotCrossingParameterB(firstBraidedCrossing)
            == KnotCrossingParameterB(KnotCrossings(braidTrefoil)[0])
        && len(
            KnotStrandCrossingEncounters(KnotStrands(braidedBundle)[0])
        ) == 12
        && len(
            KnotStrandCrossingEncounters(KnotStrands(braidedBundle)[1])
        ) == 12
        && KnotValidationIsValid(ValidateKnot(braidedBundle))
    ),
    LogoTestResult(
        "knot bundle reports collective crossing clearance",
        len(KnotBundleCrossingClearances(braidedBundle, 0.7, 0.2))
            == 12
        && KnotBundleHasCrossingClearance(braidedBundle, 0.7, 0.2)
        && !KnotBundleHasCrossingClearance(
            oversizedUncheckedBundle,
            8,
            0
        )
    ),
    LogoTestResult(
        "knot bundle normalized interpolation",
        KnotTestPointNearlyEqual(
            KnotStrandPointAtParameter(KnotStrands(braidedBundle)[0], 0),
            KnotStrandSamples(KnotStrands(braidedBundle)[0])[0]
        )
        && KnotTestPointNearlyEqual(
            KnotStrandPointAtParameter(KnotStrands(braidedBundle)[0], 1),
            KnotStrandSamples(KnotStrands(braidedBundle)[0])[
                KnotStrandSampleCount(KnotStrands(braidedBundle)[0]) - 1
            ]
        )
    ),
    LogoTestResult(
        "knot bundle twist closure permutations",
        KnotBundleTwistPermutation(4, 0) == [0, 1, 2, 3]
        && KnotBundleTwistPermutation(4, 1) == [3, 2, 1, 0]
        && KnotBundleTwistPermutation(4, -1) == [3, 2, 1, 0]
        && KnotBundleTwistPermutation(4, 2) == [0, 1, 2, 3]
        && KnotBundleTwistCycles(3, 1) == [[0, 2], [1]]
    ),
    LogoTestResult(
        "knot bundle half twist traces permutation cycles",
        len(KnotStrands(twoCordHalfTwist)) == 1
        && KnotStrandSampleCount(KnotStrands(twoCordHalfTwist)[0]) == 49
        && KnotCordSegmentCount(twoCordHalfTwist) == 48
        && len(KnotStrands(threeCordHalfTwist)) == 2
        && KnotStrandSampleCount(KnotStrands(threeCordHalfTwist)[0]) == 49
        && KnotStrandSampleCount(KnotStrands(threeCordHalfTwist)[1]) == 25
        && KnotValidationIsValid(ValidateKnot(twoCordHalfTwist))
        && KnotValidationIsValid(ValidateKnot(threeCordHalfTwist))
    ),
    LogoTestResult(
        "knot bundle full twist preserves individual lanes",
        len(KnotStrands(twoCordFullTwist)) == 2
        && KnotCordSegmentCount(twoCordFullTwist) == 48
        && KnotValidationIsValid(ValidateKnot(twoCordFullTwist))
        && len([
            for (strand = KnotStrands(twoCordFullTwist))
                if (!KnotTestPointNearlyEqual(
                    KnotStrandSamples(strand)[0],
                    KnotStrandSamples(strand)[KnotStrandSampleCount(strand) - 1]
                ))
                    strand
        ]) == 0
    ),
    LogoTestResult(
        "knot bundle half twist remaps crossings into traced components",
        len(KnotStrands(braidedHalfTwist)) == 1
        && len(KnotCrossings(braidedHalfTwist)) == 12
        && len([
            for (crossing = KnotCrossings(braidedHalfTwist))
                if (
                    KnotCrossingStrandA(crossing) != 0
                    || KnotCrossingStrandB(crossing) != 0
                )
                    crossing
        ]) == 0
        && KnotValidationIsValid(ValidateKnot(braidedHalfTwist))
    )
];

function KnotBraidTestResults() =
    let(
        positiveStates = KnotBraidStates([1], 2),
        trefoil = MakeCircularBraidKnot(2, [1, 1, 1], 20, 4, 4, 4),
        negativeTrefoil = MakeCircularBraidKnot(2, [-1, -1, -1], 20, 4, 4, 4),
        hopf = MakeCircularBraidKnot(2, [1, 1], 20, 4, 4, 4),
        threeLane = MakeCircularBraidKnot(3, [1, 2], 22, 3, 4, 4),
        trefoilStrand = KnotStrands(trefoil)[0],
        trefoilSamples = KnotStrandSamples(trefoilStrand),
        trefoilCrossings = KnotCrossings(trefoil),
        firstTrefoilCrossing = trefoilCrossings[0],
        firstNegativeCrossing = KnotCrossings(negativeTrefoil)[0],
        positiveOverPoint = KnotBraidPointForLabel(
            [1],
            positiveStates,
            2,
            0,
            0,
            0.5,
            20,
            4,
            4
        ),
        positiveUnderPoint = KnotBraidPointForLabel(
            [1],
            positiveStates,
            2,
            1,
            0,
            0.5,
            20,
            4,
            4
        )
    )
[
    LogoTestResult(
        "braid signed word validation",
        KnotBraidWordIsValid([1, -1, 1], 2)
        && KnotBraidWordIsValid([1, -2, 2], 3)
        && !KnotBraidWordIsValid([], 2)
        && !KnotBraidWordIsValid([0], 2)
        && !KnotBraidWordIsValid([2], 2)
        && !KnotBraidWordIsValid([1.5], 3)
    ),
    LogoTestResult(
        "braid lane state evolution",
        positiveStates == [[0, 1], [1, 0]]
        && KnotBraidStates([1, 1], 2) == [[0, 1], [1, 0], [0, 1]]
        && KnotBraidSwapLanes([0, 1, 2], 1) == [0, 2, 1]
    ),
    LogoTestResult(
        "braid closure permutation",
        KnotBraidClosurePermutation([1, 1], 2) == [0, 1]
        && KnotBraidClosurePermutation([1, 1, 1], 2) == [1, 0]
        && KnotBraidClosurePermutation([1, 2], 3) == [2, 0, 1]
    ),
    LogoTestResult(
        "braid closure permutation cycles",
        KnotPermutationCycles([0, 1]) == [[0], [1]]
        && KnotPermutationCycles([1, 0]) == [[0, 1]]
        && KnotPermutationCycles([2, 0, 1]) == [[0, 2, 1]]
    ),
    LogoTestResult(
        "braid cosine exchange blend",
        KnotBraidBlend(0) == 0
        && KnotTestNearlyEqual(KnotBraidBlend(0.5), 0.5)
        && KnotBraidBlend(1) == 1
    ),
    LogoTestResult(
        "braid trefoil component samples and closure",
        len(KnotStrands(trefoil)) == 1
        && KnotStrandSampleCount(trefoilStrand) == 25
        && KnotTestPointNearlyEqual(
            trefoilSamples[0],
            trefoilSamples[len(trefoilSamples) - 1]
        )
    ),
    LogoTestResult(
        "braid Hopf link components and samples",
        len(KnotStrands(hopf)) == 2
        && KnotStrandSampleCount(KnotStrands(hopf)[0]) == 9
        && KnotStrandSampleCount(KnotStrands(hopf)[1]) == 9
    ),
    LogoTestResult(
        "braid self-crossing branch records",
        len(trefoilCrossings) == 3
        && KnotCrossingStrandA(firstTrefoilCrossing) == 0
        && KnotCrossingStrandB(firstTrefoilCrossing) == 0
        && KnotCrossingParameterA(firstTrefoilCrossing)
            != KnotCrossingParameterB(firstTrefoilCrossing)
        && KnotCrossingOverBranch(firstTrefoilCrossing) == "A"
        && KnotCrossingOverBranch(firstNegativeCrossing) == "B"
    ),
    LogoTestResult(
        "braid signed crossing height",
        KnotTestNearlyEqual(positiveOverPoint[2], 2)
        && KnotTestNearlyEqual(positiveUnderPoint[2], -2)
    ),
    LogoTestResult(
        "braid crossing encounter indexes",
        KnotStrandCrossingEncounters(trefoilStrand) == [0, 0, 1, 1, 2, 2]
        && KnotStrandCrossingEncounters(KnotStrands(hopf)[0]) == [0, 1]
        && KnotStrandCrossingEncounters(KnotStrands(hopf)[1]) == [0, 1]
    ),
    LogoTestResult(
        "braid generated results validate",
        KnotValidationIsValid(ValidateKnot(trefoil))
        && KnotValidationIsValid(ValidateKnot(negativeTrefoil))
        && KnotValidationIsValid(ValidateKnot(hopf))
        && KnotValidationIsValid(ValidateKnot(threeLane))
    ),
    LogoTestResult(
        "braid three-lane closure component",
        len(KnotStrands(threeLane)) == 1
        && len(KnotCrossings(threeLane)) == 2
        && KnotStrandSampleCount(KnotStrands(threeLane)[0]) == 25
    )
];

function KnotCelticTestResults() =
    let(
        grid = [
            ">X<",
            "X>X",
            "<X>"
        ],
        cycles = KnotCelticTraceCycles(grid),
        celtic = MakeCelticTileGridKnot(grid, 12, 6, 4, 4),
        irregularGrid = [
            ".X.",
            "X>X",
            ".X."
        ],
        irregular = MakeCelticTileGridKnot(
            irregularGrid,
            10,
            6,
            4,
            4
        ),
        holeGrid = [
            ">X<",
            "X.X",
            "<X>"
        ],
        hole = MakeCelticTileGridKnot(holeGrid, 10, 6, 4, 4),
        holeBoundaryLoops = KnotCelticBoundaryLoops(holeGrid),
        diagonalBoundaryLoops = KnotCelticBoundaryLoops([
            ">.",
            ".>"
        ]),
        strands = KnotStrands(celtic),
        crossings = KnotCrossings(celtic),
        firstCrossing = crossings[0],
        firstEvents = KnotCelticSortEvents(
            KnotCelticStrandCrossingEvents(celtic, 0)
        )
    )
[
    LogoTestResult(
        "Celtic tile vocabulary and pairings",
        KnotCelticTileIsValid("X")
        && KnotCelticTileIsValid(">")
        && KnotCelticTileIsValid("<")
        && KnotCelticTileIsValid(".")
        && KnotCelticTileIsBlank(".")
        && KnotCelticTileIsValid("/")
        && KnotCelticTileIsValid("//")
        && KnotCelticTileIsValid("NE_SW")
        && KnotCelticTileIsValid("NW_ES")
        && KnotCelticTileIsValid("\\")
        && !KnotCelticTileIsValid(" ")
        && !KnotCelticTileIsValid("UNKNOWN")
        && KnotCelticTilePairedPort("X", KNOT_CELTIC_NORTH)
            == KNOT_CELTIC_SOUTH
        && KnotCelticTilePairedPort(">", KNOT_CELTIC_NORTH)
            == KNOT_CELTIC_EAST
        && KnotCelticTilePairedPort("<", KNOT_CELTIC_NORTH)
            == KNOT_CELTIC_WEST
        && KnotCelticCanonicalTile("NE_SW") == ">"
        && KnotCelticCanonicalTile("/") == ">"
        && KnotCelticCanonicalTile("NW_ES") == "<"
        && KnotCelticCanonicalTile("\\") == "<"
        && KnotCelticCanonicalTile("//") == "<"
        && KnotCelticCanonicalTile(".") == "."
    ),
    LogoTestResult(
        "Celtic grid structure validation",
        KnotCelticGridIsRectangular(grid)
        && KnotCelticGridTilesAreValid(grid)
        && KnotCelticCanonicalGrid([
            ["NE_SW", "X", "NW_ES"],
            ["/", "X", "//"]
        ]) == [">X<", ">X<"]
        && !KnotCelticGridIsRectangular([
            "X",
            "XX"
        ])
        && !KnotCelticGridTilesAreValid(["BAD"])
        && KnotCelticGridTilesAreValid([".X.", "..."])
        && KnotCelticGridHasOccupiedTile([".X.", "..."])
        && !KnotCelticGridHasOccupiedTile(["...", "..."])
    ),
    LogoTestResult(
        "Celtic boundary enumeration and pairing",
        len(KnotCelticBoundaryStates(3, 3)) == 12
        && KnotCelticBoundaryPartner(
            [0, 0, KNOT_CELTIC_NORTH],
            3,
            3
        ) == [0, 1, KNOT_CELTIC_NORTH]
        && KnotCelticBoundaryPartner(
            [0, 2, KNOT_CELTIC_NORTH],
            3,
            3
        ) == [0, 2, KNOT_CELTIC_EAST]
    ),
    LogoTestResult(
        "Celtic blank tiles form independent boundary loops",
        len(KnotCelticExposedStateIds(holeGrid)) == 16
        && len(holeBoundaryLoops) == 2
        && len(holeBoundaryLoops[0]) == 12
        && len(holeBoundaryLoops[1]) == 4
        && len(diagonalBoundaryLoops) == 2
        && len(diagonalBoundaryLoops[0]) == 4
        && len(diagonalBoundaryLoops[1]) == 4
    ),
    LogoTestResult(
        "Celtic route tracing removes reverse duplicates",
        len(cycles) == 2
        && len(cycles[0]) == 9
        && len(cycles[1]) == 9
        && len([
            for (cycle = cycles)
                each concat(
                    cycle,
                    KnotCelticReverseCycleStateIds(grid, cycle)
                )
        ]) == 36
    ),
    LogoTestResult(
        "Celtic generated component and sample counts",
        len(strands) == 2
        && KnotStrandSampleCount(strands[0]) == 67
        && KnotStrandSampleCount(strands[1]) == 67
        && KnotCordSegmentCount(celtic) == 132
    ),
    LogoTestResult(
        "Celtic generated routes close and validate",
        KnotTestPointNearlyEqual(
            KnotStrandSamples(strands[0])[0],
            KnotStrandSamples(strands[0])[
                KnotStrandSampleCount(strands[0]) - 1
            ]
        )
        && KnotTestPointNearlyEqual(
            KnotStrandSamples(strands[1])[0],
            KnotStrandSamples(strands[1])[
                KnotStrandSampleCount(strands[1]) - 1
            ]
        )
        && KnotValidationIsValid(ValidateKnot(celtic))
    ),
    LogoTestResult(
        "Celtic irregular occupied region closes and validates",
        len(KnotStrands(irregular)) == 1
        && len(KnotCrossings(irregular)) == 4
        && KnotCordSegmentCount(irregular) == 84
        && KnotValidationIsValid(ValidateKnot(irregular))
        && KnotCelticKnotIsAlternating(irregular)
        && KnotMetadata(irregular)[7] == irregularGrid
    ),
    LogoTestResult(
        "Celtic internal blank region closes and validates",
        len(KnotStrands(hole)) == 1
        && len(KnotCrossings(hole)) == 4
        && KnotCordSegmentCount(hole) == 128
        && KnotValidationIsValid(ValidateKnot(hole))
        && KnotCelticKnotIsAlternating(hole)
    ),
    LogoTestResult(
        "Celtic crossing records and height",
        len(crossings) == 4
        && KnotCrossingStrandA(firstCrossing) == 0
        && KnotCrossingStrandB(firstCrossing) == 0
        && KnotCrossingParameterA(firstCrossing)
            != KnotCrossingParameterB(firstCrossing)
        && KnotCrossingOverBranch(firstCrossing) == "B"
        && KnotTestNearlyEqual(
            KnotCrossingCenterDistance(celtic, firstCrossing),
            4
        )
    ),
    LogoTestResult(
        "Celtic crossing encounters cover both branches",
        KnotStrandCrossingEncounters(strands[0]) == [0, 0, 2, 2]
        && KnotStrandCrossingEncounters(strands[1]) == [1, 1, 3, 3]
    ),
    LogoTestResult(
        "Celtic crossing events alternate around closure",
        len(firstEvents) == 4
        && firstEvents[0][1]
        && !firstEvents[1][1]
        && firstEvents[2][1]
        && !firstEvents[3][1]
        && KnotCelticKnotIsAlternating(celtic)
    ),
    LogoTestResult(
        "Celtic metadata records deterministic boundary policy",
        KnotMetadata(celtic) == [
            "generator", "celticTileGrid",
            "rows", 3,
            "columns", 3,
            "grid", grid,
            "cellSize", 12,
            "samplesPerTile", 6,
            "samplesPerBoundary", 4,
            "crossingHeight", 4,
            "boundaryClosure", "clockwisePairs"
        ]
    )
];

function KnotRibbonTestResults() =
    let(
        spatialCeltic = MakeCelticTileGridKnot(
            [
                ">X<",
                "X>X",
                "<X>"
            ],
            12,
            6,
            4,
            4
        ),
        planarCeltic = KnotForView(spatialCeltic, "Planar"),
        ribbonRegions = KnotRibbonRegions(planarCeltic, 2.4, 6),
        maskRegions = KnotRibbonCrossingMaskRegions(
            planarCeltic,
            2.4,
            0.7,
            6
        ),
        overpassRegions = KnotRibbonOverpassRegions(
            planarCeltic,
            2.4,
            0.7,
            6
        ),
        firstCrossing = KnotCrossings(planarCeltic)[0],
        firstOverBranch = KnotCrossingOverBranch(firstCrossing),
        firstOverStrand = KnotStrands(planarCeltic)[
            KnotCrossingBranchStrand(firstCrossing, firstOverBranch)
        ],
        firstOverParameter = KnotCrossingBranchParameter(
            firstCrossing,
            firstOverBranch
        ),
        firstTangent = KnotStrandTangentAtParameter(
            firstOverStrand,
            firstOverParameter
        ),
        unknot = KnotForView(
            MakeTorusKnot(1, 1, 18, 5, 24),
            "Planar"
        )
    )
[
    LogoTestResult(
        "knot print quality preset resolution",
        KnotPrintPresetCordFragments("Draft", 30) == 12
        && KnotPrintPresetCordFragments("Standard", 30) == 24
        && KnotPrintPresetCordFragments("Fine", 30) == 48
        && KnotPrintPresetCordFragments("Custom", 30) == 30
        && KnotPrintPresetRibbonArcFragments("Draft", 14) == 4
        && KnotPrintPresetRibbonArcFragments("Standard", 14) == 10
        && KnotPrintPresetRibbonArcFragments("Fine", 14) == 20
        && KnotPrintPresetRibbonArcFragments("Custom", 14) == 14
    ),
    LogoTestResult(
        "knot print quality preset route sampling",
        KnotPrintPresetSampleCount(120, "Draft") == 60
        && KnotPrintPresetSampleCount(120, "Standard") == 120
        && KnotPrintPresetSampleCount(120, "Fine") == 240
        && KnotPrintPresetSampleCount(8, "Custom", 1.5, 4, true)
            == 12
        && KnotPrintPresetSampleCount(5, "Draft", 1, 4, true)
            == 4
    ),
    LogoTestResult(
        "knot ribbon requires planar samples",
        KnotIsPlanar(planarCeltic)
        && !KnotIsPlanar(spatialCeltic)
        && KnotValidationIsValid(ValidateKnot(planarCeltic))
    ),
    LogoTestResult(
        "knot ribbon capsule contour",
        len(KnotRibbonCapsuleContour([0, 0, 0], [10, 0, 0], 1, 4))
            == 10
        && len(KnotRibbonCapsuleContour([0, 0, 0], [0, 0, 0], 1, 4))
            == 8
        && KnotRibbonCapsuleContour(
            [0, 0, 0],
            [10, 0, 0],
            1,
            4
        )[0] == [10, 1]
    ),
    LogoTestResult(
        "knot ribbon crossing rectangle has flat ends",
        KnotRibbonRectangleContour([0, 0, 0], [10, 0, 0], 1)
            == [[0, 1], [10, 1], [10, -1], [0, -1]]
    ),
    LogoTestResult(
        "knot ribbon regions use LogoSC region records",
        len(ribbonRegions) == KnotCordSegmentCount(planarCeltic)
        && len(ribbonRegions) == 132
        && len(RegionOuter(ribbonRegions[0])) == 14
        && RegionHoles(ribbonRegions[0]) == []
    ),
    LogoTestResult(
        "knot ribbon crossing mask accounting",
        len(maskRegions) == len(KnotCrossings(planarCeltic))
        && len(overpassRegions) == len(KnotCrossings(planarCeltic))
        && len(maskRegions) == 4
        && RegionOuter(maskRegions[0]) != RegionOuter(overpassRegions[0])
    ),
    LogoTestResult(
        "knot ribbon overpass reconnects beyond mask",
        KnotTestNearlyEqual(KnotRibbonCrossingSpan(2.4, 0.7, true), 6.2)
        && KnotTestNearlyEqual(
            KnotRibbonCrossingSpan(2.4, 0.7, false),
            7.6
        )
        && KnotRibbonCrossingSpan(2.4, 0.7, false)
            > KnotRibbonCrossingSpan(2.4, 0.7, true)
    ),
    LogoTestResult(
        "knot ribbon crossing branch accessors",
        KnotCrossingBranchStrand(firstCrossing, "A")
            == KnotCrossingStrandA(firstCrossing)
        && KnotCrossingBranchStrand(firstCrossing, "B")
            == KnotCrossingStrandB(firstCrossing)
        && KnotCrossingBranchParameter(firstCrossing, "A")
            == KnotCrossingParameterA(firstCrossing)
        && KnotCrossingBranchParameter(firstCrossing, "B")
            == KnotCrossingParameterB(firstCrossing)
    ),
    LogoTestResult(
        "knot ribbon crossing tangent is planar and normalized",
        KnotTestNearlyEqual(KnotVectorLength(firstTangent), 1)
        && firstTangent[2] == 0
    ),
    LogoTestResult(
        "knot ribbon no-crossing mask identity",
        len(KnotRibbonCrossingMaskRegions(unknot, 2, 0.5, 4)) == 0
        && len(KnotRibbonOverpassRegions(unknot, 2, 0.5, 4)) == 0
        && len(KnotRibbonRegions(unknot, 2, 4))
            == KnotCordSegmentCount(unknot)
    ),
    LogoTestResult(
        "knot bas-relief height accounting",
        KnotTestNearlyEqual(KnotBasReliefTotalHeight(1.2, 1), 2.2)
        && KnotTestNearlyEqual(
            KnotBasReliefTotalHeight(0.8, 0.6),
            1.4
        )
    ),
    LogoTestResult(
        "knot relief plaque bounds include ribbon and margin",
        let(
            routeBounds = KnotPlanarBounds(unknot),
            plaqueBounds = KnotReliefPlaqueBounds(unknot, 2, 3)
        )
        KnotTestNearlyEqual(plaqueBounds[0][0], routeBounds[0][0] - 4)
        && KnotTestNearlyEqual(plaqueBounds[0][1], routeBounds[0][1] - 4)
        && KnotTestNearlyEqual(plaqueBounds[1][0], routeBounds[1][0] + 4)
        && KnotTestNearlyEqual(plaqueBounds[1][1], routeBounds[1][1] + 4)
    ),
    LogoTestResult(
        "knot relief plaque height accounting",
        KnotTestNearlyEqual(
            KnotReliefPlaqueTotalHeight(1.4, 1.2, 1),
            3.6
        )
    ),
    LogoTestResult(
        "knot relief plaque bevel preserves outer bounds",
        let(
            outerBounds = [[-10, -8], [10, 8]],
            topBounds = KnotReliefPlaqueTopBounds(
                outerBounds,
                "Bevel",
                1.5
            )
        )
        outerBounds == [[-10, -8], [10, 8]]
        && topBounds == [[-8.5, -6.5], [8.5, 6.5]]
        && KnotReliefPlaqueTopBounds(
            outerBounds,
            "None",
            1.5
        ) == outerBounds
    ),
    LogoTestResult(
        "knot relief plaque bevel adjusts top corner radius",
        KnotReliefPlaqueEdgeStyleIsValid("None")
        && KnotReliefPlaqueEdgeStyleIsValid("Bevel")
        && !KnotReliefPlaqueEdgeStyleIsValid("Round")
        && KnotReliefPlaqueTopCornerRadius(4, "Bevel", 1.5) == 2.5
        && KnotReliefPlaqueTopCornerRadius(1, "Bevel", 1.5) == 0
    )
];

function KnotAutomatedTestResults() =
    concat(
        KnotRecordTestResults(),
        KnotValidationTestResults(),
        KnotTorusTestResults(),
        KnotLissajousTestResults(),
        KnotCordTestResults(),
        KnotBundleTestResults(),
        KnotBraidTestResults(),
        KnotCelticTestResults(),
        KnotRibbonTestResults()
    );

function KnotTestSuiteResult() =
    LogoTestSuiteResult("Knots", KnotAutomatedTestResults());

module RunAllKnotTests()
{
    ReportLogoTestRun([KnotTestSuiteResult()]);
}
