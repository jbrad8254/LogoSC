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
        validation = MakeKnotValidationResult(knot, [], 0.01)
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

function KnotAutomatedTestResults() =
    concat(
        KnotRecordTestResults(),
        KnotValidationTestResults(),
        KnotTorusTestResults(),
        KnotCordTestResults()
    );

function KnotTestSuiteResult() =
    LogoTestSuiteResult("Knots", KnotAutomatedTestResults());

module RunAllKnotTests()
{
    ReportLogoTestRun([KnotTestSuiteResult()]);
}
