// ============================================================================
// LogoSC Knots - optional sampled-knot companion
//
// This file is independent of LogoSC Core. It does not call evalLogo() or emit
// LogoSC command lists. Pure OpenSCAD functions define and validate sampled
// knot records; native OpenSCAD functions generate torus and circular-braid
// routes, while sphere/hull geometry produces diagnostics, manufacturable
// rounded cords, and untwisted adjacent cord bundles. Future planar motif and
// ribbon stages may consume LogoSC Core without making this 3D companion a
// Core dependency.
// ============================================================================

KNOT_STRANDS = 0;
KNOT_CROSSINGS = 1;
KNOT_METADATA = 2;

KNOT_STRAND_CLOSED = 0;
KNOT_STRAND_SAMPLES = 1;
KNOT_STRAND_ENCOUNTERS = 2;
KNOT_STRAND_LANE_PERMUTATION = 3;
KNOT_STRAND_METADATA = 4;

KNOT_CROSSING_POINT = 0;
KNOT_CROSSING_STRAND_A = 1;
KNOT_CROSSING_PARAMETER_A = 2;
KNOT_CROSSING_STRAND_B = 3;
KNOT_CROSSING_PARAMETER_B = 4;
KNOT_CROSSING_OVER_STRAND = 5;
KNOT_CROSSING_OVER_BRANCH = 6;

KNOT_VALIDATION_KNOT = 0;
KNOT_VALIDATION_ISSUES = 1;
KNOT_VALIDATION_TOLERANCE = 2;

KNOT_ISSUE_CODE = 0;
KNOT_ISSUE_NAME = 1;
KNOT_ISSUE_STRAND_INDEX = 2;
KNOT_ISSUE_CROSSING_INDEX = 3;
KNOT_ISSUE_DETAIL = 4;

KNOT_ISSUE_MALFORMED_KNOT = 1;
KNOT_ISSUE_MALFORMED_STRAND = 2;
KNOT_ISSUE_TOO_FEW_SAMPLES = 3;
KNOT_ISSUE_OPEN_CLOSURE = 4;
KNOT_ISSUE_MALFORMED_SAMPLE = 5;
KNOT_ISSUE_MALFORMED_CROSSING = 6;
KNOT_ISSUE_CROSSING_STRAND = 7;
KNOT_ISSUE_CROSSING_PARAMETER = 8;
KNOT_ISSUE_CROSSING_OVER = 9;
KNOT_ISSUE_ENCOUNTER_INDEX = 10;
KNOT_ISSUE_LANE_PERMUTATION = 11;
KNOT_ISSUE_ENCOUNTER_STRAND = 12;
KNOT_ISSUE_CROSSING_BRANCH = 13;

// Construct a shared knot result. Metadata is generator-defined and optional.
function MakeKnot(strands, crossings = [], metadata = []) =
    [strands, crossings, metadata];

function KnotStrands(knot) = knot[KNOT_STRANDS];
function KnotCrossings(knot) = knot[KNOT_CROSSINGS];
function KnotMetadata(knot) = len(knot) > KNOT_METADATA ? knot[KNOT_METADATA] : [];

// Construct one sampled strand. Closed strands repeat their first sample at the
// end. crossingEncounters contains indexes into KnotCrossings(). The lane
// permutation is reserved for later cord-bundle closure and defaults to identity.
function MakeKnotStrand(
    closed,
    centerlineSamples,
    crossingEncounters = [],
    laneClosurePermutation = [0],
    metadata = []) =
[
    closed,
    centerlineSamples,
    crossingEncounters,
    laneClosurePermutation,
    metadata
];

function KnotStrandClosed(strand) = strand[KNOT_STRAND_CLOSED];
function KnotStrandSamples(strand) = strand[KNOT_STRAND_SAMPLES];
function KnotStrandCrossingEncounters(strand) = strand[KNOT_STRAND_ENCOUNTERS];
function KnotStrandLaneClosurePermutation(strand) =
    strand[KNOT_STRAND_LANE_PERMUTATION];
function KnotStrandMetadata(strand) =
    len(strand) > KNOT_STRAND_METADATA ? strand[KNOT_STRAND_METADATA] : [];
function KnotStrandSampleCount(strand) = len(KnotStrandSamples(strand));
function KnotStrandSegmentCount(strand) =
    max(0, KnotStrandSampleCount(strand) - 1);

function KnotCordSegmentCountFromStrands(strands, index = 0) =
    index >= len(strands)
    ? 0
    : (
        KnotStructureIsStrand(strands[index])
        ? KnotStrandSegmentCount(strands[index])
        : 0
    )
    + KnotCordSegmentCountFromStrands(strands, index + 1);

function KnotCordSegmentCount(knot) =
    !KnotStructureIsKnot(knot)
    ? 0
    : KnotCordSegmentCountFromStrands(KnotStrands(knot));

// Construct one projected crossing. Parameters are normalized to [0, 1].
// overStrand must equal strandA or strandB. overBranch is "A" or "B";
// distinct-strand records infer it from overStrand, while self-crossings must
// supply it because both branches have the same strand index.
function MakeKnotCrossing(
    point2D,
    strandA,
    parameterA,
    strandB,
    parameterB,
    overStrand,
    overBranch = undef) =
[
    point2D,
    strandA,
    parameterA,
    strandB,
    parameterB,
    overStrand,
    !is_undef(overBranch)
    ? overBranch
    : strandA != strandB
        ? overStrand == strandA ? "A" : "B"
        : undef
];

function KnotCrossingPoint(crossing) = crossing[KNOT_CROSSING_POINT];
function KnotCrossingStrandA(crossing) = crossing[KNOT_CROSSING_STRAND_A];
function KnotCrossingParameterA(crossing) = crossing[KNOT_CROSSING_PARAMETER_A];
function KnotCrossingStrandB(crossing) = crossing[KNOT_CROSSING_STRAND_B];
function KnotCrossingParameterB(crossing) = crossing[KNOT_CROSSING_PARAMETER_B];
function KnotCrossingOverStrand(crossing) = crossing[KNOT_CROSSING_OVER_STRAND];
function KnotCrossingOverBranch(crossing) =
    len(crossing) > KNOT_CROSSING_OVER_BRANCH
    ? crossing[KNOT_CROSSING_OVER_BRANCH]
    : KnotCrossingStrandA(crossing) != KnotCrossingStrandB(crossing)
        ? KnotCrossingOverStrand(crossing) == KnotCrossingStrandA(crossing)
            ? "A"
            : "B"
        : undef;

// Construct a validation result. The original knot is retained for diagnostics.
function MakeKnotValidationResult(knot, issues, tolerance = 0.001) =
    [knot, issues, tolerance];

function KnotValidationKnot(result) = result[KNOT_VALIDATION_KNOT];
function KnotValidationIssues(result) = result[KNOT_VALIDATION_ISSUES];
function KnotValidationTolerance(result) = result[KNOT_VALIDATION_TOLERANCE];
function KnotValidationIsValid(result) = len(KnotValidationIssues(result)) == 0;

function MakeKnotValidationIssue(
    code,
    name,
    strandIndex = undef,
    crossingIndex = undef,
    detail = undef) =
    [code, name, strandIndex, crossingIndex, detail];

function KnotValidationIssueCode(issue) = issue[KNOT_ISSUE_CODE];
function KnotValidationIssueName(issue) = issue[KNOT_ISSUE_NAME];
function KnotValidationIssueStrandIndex(issue) = issue[KNOT_ISSUE_STRAND_INDEX];
function KnotValidationIssueCrossingIndex(issue) = issue[KNOT_ISSUE_CROSSING_INDEX];
function KnotValidationIssueDetail(issue) = issue[KNOT_ISSUE_DETAIL];

function KnotPointIs2D(point) =
    is_list(point)
    && len(point) == 2
    && is_num(point[0])
    && is_num(point[1]);

function KnotPointIs3D(point) =
    is_list(point)
    && len(point) == 3
    && is_num(point[0])
    && is_num(point[1])
    && is_num(point[2]);

function KnotPointDistance(a, b) =
    sqrt(
        (a[0] - b[0]) * (a[0] - b[0])
        + (a[1] - b[1]) * (a[1] - b[1])
        + (a[2] - b[2]) * (a[2] - b[2])
    );

function KnotVectorAdd(a, b) =
    [a[0] + b[0], a[1] + b[1], a[2] + b[2]];

function KnotVectorSubtract(a, b) =
    [a[0] - b[0], a[1] - b[1], a[2] - b[2]];

function KnotVectorScale(vector, scale) =
    [vector[0] * scale, vector[1] * scale, vector[2] * scale];

function KnotVectorDot(a, b) =
    a[0] * b[0] + a[1] * b[1] + a[2] * b[2];

function KnotVectorCross(a, b) =
[
    a[1] * b[2] - a[2] * b[1],
    a[2] * b[0] - a[0] * b[2],
    a[0] * b[1] - a[1] * b[0]
];

function KnotVectorLength(vector) =
    sqrt(KnotVectorDot(vector, vector));

function KnotVectorNormalize(vector, tolerance = 0.000001) =
    let(length = KnotVectorLength(vector))
    assert(length > tolerance, "Cannot normalize a near-zero knot vector.")
    KnotVectorScale(vector, 1 / length);

function KnotVectorRotateAroundAxis(vector, axis, angle) =
    let(
        unitAxis = KnotVectorNormalize(axis),
        cosine = cos(angle),
        sine = sin(angle)
    )
    KnotVectorAdd(
        KnotVectorAdd(
            KnotVectorScale(vector, cosine),
            KnotVectorScale(KnotVectorCross(unitAxis, vector), sine)
        ),
        KnotVectorScale(
            unitAxis,
            KnotVectorDot(unitAxis, vector) * (1 - cosine)
        )
    );

function KnotVectorSignedAngle(from, to, axis) =
    atan2(
        KnotVectorDot(axis, KnotVectorCross(from, to)),
        KnotVectorDot(from, to)
    );

function KnotAllSamplesAre3D(samples, index = 0) =
    index >= len(samples)
    || (
        KnotPointIs3D(samples[index])
        && KnotAllSamplesAre3D(samples, index + 1)
    );

function KnotListContains(values, value, index = 0) =
    index < len(values)
    && (
        values[index] == value
        || KnotListContains(values, value, index + 1)
    );

function KnotIsPermutation(values, index = 0) =
    !is_list(values)
    ? false
    : index >= len(values)
        ? true
        : is_num(values[index])
            && floor(values[index]) == values[index]
            && values[index] >= 0
            && values[index] < len(values)
            && len([for (value = values) if (value == values[index]) value]) == 1
            && KnotIsPermutation(values, index + 1);

function KnotStructureIsKnot(knot) =
    is_list(knot)
    && len(knot) >= 2
    && is_list(knot[KNOT_STRANDS])
    && is_list(knot[KNOT_CROSSINGS]);

function KnotStructureIsStrand(strand) =
    is_list(strand)
    && len(strand) >= 4
    && is_bool(strand[KNOT_STRAND_CLOSED])
    && is_list(strand[KNOT_STRAND_SAMPLES])
    && is_list(strand[KNOT_STRAND_ENCOUNTERS])
    && is_list(strand[KNOT_STRAND_LANE_PERMUTATION]);

function KnotStructureIsCrossing(crossing) =
    is_list(crossing)
    && len(crossing) >= 6
    && KnotPointIs2D(crossing[KNOT_CROSSING_POINT])
    && is_num(crossing[KNOT_CROSSING_STRAND_A])
    && is_num(crossing[KNOT_CROSSING_PARAMETER_A])
    && is_num(crossing[KNOT_CROSSING_STRAND_B])
    && is_num(crossing[KNOT_CROSSING_PARAMETER_B])
    && is_num(crossing[KNOT_CROSSING_OVER_STRAND]);

function KnotStrandValidationIssues(strand, strandIndex, crossings, tolerance) =
    !KnotStructureIsStrand(strand)
    ? [
        MakeKnotValidationIssue(
            KNOT_ISSUE_MALFORMED_STRAND,
            "malformed strand",
            strandIndex,
            detail = strand
        )
    ]
    : let(
        samples = KnotStrandSamples(strand),
        encounters = KnotStrandCrossingEncounters(strand),
        lanePermutation = KnotStrandLaneClosurePermutation(strand)
    )
    concat(
        len(samples) < 2
        ? [
            MakeKnotValidationIssue(
                KNOT_ISSUE_TOO_FEW_SAMPLES,
                "too few samples",
                strandIndex,
                detail = len(samples)
            )
        ]
        : [],
        KnotAllSamplesAre3D(samples)
        ? []
        : [
            MakeKnotValidationIssue(
                KNOT_ISSUE_MALFORMED_SAMPLE,
                "malformed 3D sample",
                strandIndex
            )
        ],
        KnotStrandClosed(strand)
        && len(samples) >= 2
        && KnotAllSamplesAre3D(samples)
        && KnotPointDistance(samples[0], samples[len(samples) - 1]) > tolerance
        ? [
            MakeKnotValidationIssue(
                KNOT_ISSUE_OPEN_CLOSURE,
                "closed strand endpoints differ",
                strandIndex,
                detail = [samples[0], samples[len(samples) - 1]]
            )
        ]
        : [],
        [
            for (encounter = encounters)
                if (
                    !is_num(encounter)
                    || floor(encounter) != encounter
                    || encounter < 0
                    || encounter >= len(crossings)
                )
                    MakeKnotValidationIssue(
                        KNOT_ISSUE_ENCOUNTER_INDEX,
                        "invalid crossing encounter index",
                        strandIndex,
                        crossingIndex = encounter
                    )
        ],
        [
            for (encounter = encounters)
                if (
                    is_num(encounter)
                    && floor(encounter) == encounter
                    && encounter >= 0
                    && encounter < len(crossings)
                    && KnotStructureIsCrossing(crossings[encounter])
                    && KnotCrossingStrandA(crossings[encounter]) != strandIndex
                    && KnotCrossingStrandB(crossings[encounter]) != strandIndex
                )
                    MakeKnotValidationIssue(
                        KNOT_ISSUE_ENCOUNTER_STRAND,
                        "crossing encounter does not involve strand",
                        strandIndex,
                        crossingIndex = encounter
                    )
        ],
        KnotIsPermutation(lanePermutation)
        ? []
        : [
            MakeKnotValidationIssue(
                KNOT_ISSUE_LANE_PERMUTATION,
                "invalid lane closure permutation",
                strandIndex,
                detail = lanePermutation
            )
        ]
    );

function KnotCrossingValidationIssues(crossing, crossingIndex, strandCount) =
    !KnotStructureIsCrossing(crossing)
    ? [
        MakeKnotValidationIssue(
            KNOT_ISSUE_MALFORMED_CROSSING,
            "malformed crossing",
            crossingIndex = crossingIndex,
            detail = crossing
        )
    ]
    : let(
        strandA = KnotCrossingStrandA(crossing),
        strandB = KnotCrossingStrandB(crossing),
        parameterA = KnotCrossingParameterA(crossing),
        parameterB = KnotCrossingParameterB(crossing),
        overStrand = KnotCrossingOverStrand(crossing),
        overBranch = KnotCrossingOverBranch(crossing)
    )
    concat(
        strandA < 0
        || floor(strandA) != strandA
        || strandA >= strandCount
        || strandB < 0
        || floor(strandB) != strandB
        || strandB >= strandCount
        ? [
            MakeKnotValidationIssue(
                KNOT_ISSUE_CROSSING_STRAND,
                "invalid crossing strand indexes",
                crossingIndex = crossingIndex,
                detail = [strandA, strandB]
            )
        ]
        : [],
        parameterA < 0
        || parameterA > 1
        || parameterB < 0
        || parameterB > 1
        || (strandA == strandB && parameterA == parameterB)
        ? [
            MakeKnotValidationIssue(
                KNOT_ISSUE_CROSSING_PARAMETER,
                "crossing parameter outside [0, 1]",
                crossingIndex = crossingIndex,
                detail = [parameterA, parameterB]
            )
        ]
        : [],
        overStrand != strandA && overStrand != strandB
        ? [
            MakeKnotValidationIssue(
                KNOT_ISSUE_CROSSING_OVER,
                "over strand is not a crossing participant",
                crossingIndex = crossingIndex,
                detail = overStrand
            )
        ]
        : [],
        overBranch != "A" && overBranch != "B"
        ? [
            MakeKnotValidationIssue(
                KNOT_ISSUE_CROSSING_BRANCH,
                "crossing over branch must be A or B",
                crossingIndex = crossingIndex,
                detail = overBranch
            )
        ]
        : []
    );

// Validate record shape, closed-sample endpoints, crossing references and
// parameters, encounter indexes, and lane-closure permutations.
function ValidateKnot(knot, tolerance = 0.001) =
    assert(tolerance >= 0, "Knot validation tolerance must be nonnegative.")
    !KnotStructureIsKnot(knot)
    ? MakeKnotValidationResult(
        knot,
        [
            MakeKnotValidationIssue(
                KNOT_ISSUE_MALFORMED_KNOT,
                "malformed knot",
                detail = knot
            )
        ],
        tolerance
    )
    : let(
        strands = KnotStrands(knot),
        crossings = KnotCrossings(knot),
        strandIssues = len(strands) == 0
        ? []
        : [
            for (strandIndex = [0 : len(strands) - 1])
                each KnotStrandValidationIssues(
                    strands[strandIndex],
                    strandIndex,
                    crossings,
                    tolerance
                )
        ],
        crossingIssues = len(crossings) == 0
        ? []
        : [
            for (crossingIndex = [0 : len(crossings) - 1])
                each KnotCrossingValidationIssues(
                    crossings[crossingIndex],
                    crossingIndex,
                    len(strands)
                )
        ]
    )
    MakeKnotValidationResult(
        knot,
        concat(strandIssues, crossingIssues),
        tolerance
    );

// Echo structural diagnostics. strict=true stops evaluation after reporting.
module ReportKnotValidation(knot, tolerance = 0.001, strict = false)
{
    validation = ValidateKnot(knot, tolerance);
    issues = KnotValidationIssues(validation);

    echo(
        "LogoSC knot validation",
        KnotValidationIsValid(validation) ? "PASS" : "FAIL",
        "strands",
        KnotStructureIsKnot(knot) ? len(KnotStrands(knot)) : undef,
        "crossings",
        KnotStructureIsKnot(knot) ? len(KnotCrossings(knot)) : undef,
        "issues",
        len(issues)
    );

    for (issue = issues)
    {
        echo(
            "LogoSC knot issue",
            KnotValidationIssueName(issue),
            "strand",
            KnotValidationIssueStrandIndex(issue),
            "crossing",
            KnotValidationIssueCrossingIndex(issue),
            "detail",
            KnotValidationIssueDetail(issue)
        );
    }

    assert(
        !strict || KnotValidationIsValid(validation),
        "LogoSC knot validation failed."
    );
}

function KnotGreatestCommonDivisor(a, b) =
    b == 0
    ? abs(a)
    : KnotGreatestCommonDivisor(abs(b), abs(a) % abs(b));

function TorusKnotPoint(
    angle,
    pReduced,
    qReduced,
    majorRadius,
    minorRadius,
    componentPhase) =
    let(
        minorAngle = qReduced * angle + componentPhase,
        radial = majorRadius + minorRadius * cos(minorAngle),
        majorAngle = pReduced * angle
    )
    [
        radial * cos(majorAngle),
        radial * sin(majorAngle),
        minorRadius * sin(minorAngle)
    ];

function TorusKnotComponentSamples(
    pReduced,
    qReduced,
    majorRadius,
    minorRadius,
    samplesPerComponent,
    componentIndex,
    componentCount) =
[
    for (sampleIndex = [0 : samplesPerComponent])
        TorusKnotPoint(
            360 * sampleIndex / samplesPerComponent,
            pReduced,
            qReduced,
            majorRadius,
            minorRadius,
            360 * componentIndex / componentCount
        )
];

// Generate a torus knot when gcd(p,q)=1, or a torus link with gcd(p,q)
// independently closed components. Each component contains samplesPerComponent
// segments and repeats its first sample exactly at the end.
function MakeTorusKnot(
    p,
    q,
    majorRadius = 20,
    minorRadius = 7,
    samplesPerComponent = 120) =
    assert(is_num(p) && floor(p) == p && p > 0, "Torus p must be a positive integer.")
    assert(is_num(q) && floor(q) == q && q > 0, "Torus q must be a positive integer.")
    assert(majorRadius > 0, "Torus major radius must be positive.")
    assert(minorRadius > 0, "Torus minor radius must be positive.")
    assert(majorRadius > minorRadius, "Torus major radius must exceed minor radius.")
    assert(
        is_num(samplesPerComponent)
        && floor(samplesPerComponent) == samplesPerComponent
        && samplesPerComponent >= 3,
        "Torus samples per component must be an integer of at least 3."
    )
    let(
        componentCount = KnotGreatestCommonDivisor(p, q),
        pReduced = p / componentCount,
        qReduced = q / componentCount,
        strands = [
            for (componentIndex = [0 : componentCount - 1])
                MakeKnotStrand(
                    true,
                    TorusKnotComponentSamples(
                        pReduced,
                        qReduced,
                        majorRadius,
                        minorRadius,
                        samplesPerComponent,
                        componentIndex,
                        componentCount
                    ),
                    metadata = [
                        "generator", "torus",
                        "component", componentIndex
                    ]
                )
        ]
    )
    MakeKnot(
        strands,
        [],
        [
            "generator", "torus",
            "p", p,
            "q", q,
            "componentCount", componentCount,
            "majorRadius", majorRadius,
            "minorRadius", minorRadius,
            "samplesPerComponent", samplesPerComponent
        ]
    );

function KnotBraidWordIsValid(word, laneCount, index = 0) =
    !is_list(word)
    || !is_num(laneCount)
    || floor(laneCount) != laneCount
    || laneCount < 2
    ? false
    : index >= len(word)
        ? len(word) > 0
        : is_num(word[index])
            && floor(word[index]) == word[index]
            && word[index] != 0
            && abs(word[index]) < laneCount
            && KnotBraidWordIsValid(word, laneCount, index + 1);

function KnotBraidSwapLanes(laneLabels, lowerLane) =
[
    for (lane = [0 : len(laneLabels) - 1])
        lane == lowerLane
        ? laneLabels[lowerLane + 1]
        : lane == lowerLane + 1
            ? laneLabels[lowerLane]
            : laneLabels[lane]
];

function KnotBraidStates(
    word,
    laneCount,
    stepIndex = 0,
    laneLabels = undef) =
    let(
        currentLabels = is_undef(laneLabels)
        ? [for (lane = [0 : laneCount - 1]) lane]
        : laneLabels
    )
    stepIndex >= len(word)
    ? [currentLabels]
    : concat(
        [currentLabels],
        KnotBraidStates(
            word,
            laneCount,
            stepIndex + 1,
            KnotBraidSwapLanes(
                currentLabels,
                abs(word[stepIndex]) - 1
            )
        )
    );

function KnotBraidLabelLane(laneLabels, label) =
    [
        for (lane = [0 : len(laneLabels) - 1])
            if (laneLabels[lane] == label)
                lane
    ][0];

function KnotBraidClosurePermutation(word, laneCount) =
    let(finalState = KnotBraidStates(word, laneCount)[len(word)])
[
    for (label = [0 : laneCount - 1])
        KnotBraidLabelLane(finalState, label)
];

function KnotPermutationCycle(
    permutation,
    start,
    current = undef,
    accumulated = []) =
    let(
        value = is_undef(current) ? start : current,
        next = permutation[value],
        nextAccumulated = concat(accumulated, [value])
    )
    next == start
    ? nextAccumulated
    : KnotPermutationCycle(permutation, start, next, nextAccumulated);

function KnotPermutationCycles(permutation) =
[
    for (start = [0 : len(permutation) - 1])
        let(cycle = KnotPermutationCycle(permutation, start))
        if (min(cycle) == start)
            cycle
];

function KnotBraidComponentForLabel(cycles, label) =
    [
        for (componentIndex = [0 : len(cycles) - 1])
            if (KnotListContains(cycles[componentIndex], label))
                componentIndex
    ][0];

function KnotBraidCyclePosition(cycle, label) =
    [
        for (position = [0 : len(cycle) - 1])
            if (cycle[position] == label)
                position
    ][0];

function KnotBraidBlend(u) =
    (1 - cos(180 * u)) / 2;

function KnotBraidPointForLabel(
    word,
    states,
    laneCount,
    label,
    stepIndex,
    u,
    majorRadius,
    laneSpacing,
    crossingHeight) =
    let(
        generator = word[stepIndex],
        lowerLane = abs(generator) - 1,
        lane = KnotBraidLabelLane(states[stepIndex], label),
        blend = KnotBraidBlend(u),
        lanePosition = lane == lowerLane
        ? lane + blend
        : lane == lowerLane + 1
            ? lane - blend
            : lane,
        radius = majorRadius
            + (lanePosition - (laneCount - 1) / 2) * laneSpacing,
        angle = 360 * (stepIndex + u) / len(word),
        involved = lane == lowerLane || lane == lowerLane + 1,
        overLabel = generator > 0
        ? states[stepIndex][lowerLane]
        : states[stepIndex][lowerLane + 1],
        height = !involved
        ? 0
        : (label == overLabel ? 1 : -1)
            * crossingHeight / 2
            * sin(180 * u)
    )
    [radius * cos(angle), radius * sin(angle), height];

function KnotBraidComponentSamples(
    word,
    states,
    laneCount,
    cycle,
    majorRadius,
    laneSpacing,
    crossingHeight,
    samplesPerGenerator) =
    let(
        uniqueSamples = [
            for (label = cycle)
                for (stepIndex = [0 : len(word) - 1])
                    for (sampleIndex = [0 : samplesPerGenerator - 1])
                        KnotBraidPointForLabel(
                            word,
                            states,
                            laneCount,
                            label,
                            stepIndex,
                            sampleIndex / samplesPerGenerator,
                            majorRadius,
                            laneSpacing,
                            crossingHeight
                        )
        ]
    )
    concat(uniqueSamples, [uniqueSamples[0]]);

function KnotBraidCrossingParameter(
    word,
    cycles,
    label,
    stepIndex) =
    let(
        component = KnotBraidComponentForLabel(cycles, label),
        cycle = cycles[component],
        cyclePosition = KnotBraidCyclePosition(cycle, label)
    )
    (cyclePosition * len(word) + stepIndex + 0.5)
        / (len(cycle) * len(word));

function KnotBraidCrossings(
    word,
    states,
    laneCount,
    cycles,
    majorRadius,
    laneSpacing) =
[
    for (stepIndex = [0 : len(word) - 1])
        let(
            generator = word[stepIndex],
            lowerLane = abs(generator) - 1,
            labelA = states[stepIndex][lowerLane],
            labelB = states[stepIndex][lowerLane + 1],
            strandA = KnotBraidComponentForLabel(cycles, labelA),
            strandB = KnotBraidComponentForLabel(cycles, labelB),
            parameterA = KnotBraidCrossingParameter(
                word,
                cycles,
                labelA,
                stepIndex
            ),
            parameterB = KnotBraidCrossingParameter(
                word,
                cycles,
                labelB,
                stepIndex
            ),
            crossingRadius = majorRadius
                + (lowerLane + 0.5 - (laneCount - 1) / 2) * laneSpacing,
            crossingAngle = 360 * (stepIndex + 0.5) / len(word),
            overBranch = generator > 0 ? "A" : "B"
        )
        MakeKnotCrossing(
            [
                crossingRadius * cos(crossingAngle),
                crossingRadius * sin(crossingAngle)
            ],
            strandA,
            parameterA,
            strandB,
            parameterB,
            overBranch == "A" ? strandA : strandB,
            overBranch
        )
];

function KnotBraidComponentEncounters(crossings, componentIndex) =
[
    for (crossingIndex = [0 : len(crossings) - 1])
        each concat(
            KnotCrossingStrandA(crossings[crossingIndex]) == componentIndex
            ? [crossingIndex]
            : [],
            KnotCrossingStrandB(crossings[crossingIndex]) == componentIndex
            ? [crossingIndex]
            : []
        )
];

// Generate the standard closure of a signed braid word around a circular axis.
// Positive generator i makes the strand entering lower lane i cross over lane
// i+1; negative i reverses the height relationship. Permutation cycles become
// independently closed knot or link components.
function MakeCircularBraidKnot(
    laneCount,
    word,
    majorRadius = 24,
    laneSpacing = 4,
    crossingHeight = 4,
    samplesPerGenerator = 8) =
    assert(
        KnotBraidWordIsValid(word, laneCount),
        "Braid word must contain valid signed adjacent-lane generators."
    )
    assert(is_num(majorRadius) && majorRadius > 0, "Braid radius must be positive.")
    assert(is_num(laneSpacing) && laneSpacing > 0, "Braid lane spacing must be positive.")
    assert(
        majorRadius - (laneCount - 1) * laneSpacing / 2 > 0,
        "Braid radius must keep the innermost lane positive."
    )
    assert(
        is_num(crossingHeight) && crossingHeight > 0,
        "Braid crossing height must be positive."
    )
    assert(
        is_num(samplesPerGenerator)
        && floor(samplesPerGenerator) == samplesPerGenerator
        && samplesPerGenerator >= 2,
        "Braid samples per generator must be an integer of at least 2."
    )
    let(
        states = KnotBraidStates(word, laneCount),
        permutation = KnotBraidClosurePermutation(word, laneCount),
        cycles = KnotPermutationCycles(permutation),
        crossings = KnotBraidCrossings(
            word,
            states,
            laneCount,
            cycles,
            majorRadius,
            laneSpacing
        ),
        strands = [
            for (componentIndex = [0 : len(cycles) - 1])
                MakeKnotStrand(
                    true,
                    KnotBraidComponentSamples(
                        word,
                        states,
                        laneCount,
                        cycles[componentIndex],
                        majorRadius,
                        laneSpacing,
                        crossingHeight,
                        samplesPerGenerator
                    ),
                    KnotBraidComponentEncounters(crossings, componentIndex),
                    metadata = [
                        "generator", "circularBraid",
                        "component", componentIndex,
                        "closureCycle", cycles[componentIndex]
                    ]
                )
        ]
    )
    MakeKnot(
        strands,
        crossings,
        [
            "generator", "circularBraid",
            "laneCount", laneCount,
            "word", word,
            "closurePermutation", permutation,
            "closureCycles", cycles,
            "majorRadius", majorRadius,
            "laneSpacing", laneSpacing,
            "crossingHeight", crossingHeight,
            "samplesPerGenerator", samplesPerGenerator
        ]
    );

function KnotBundleOccupiedWidth(cordCount, cordRadius, cordGap = 0) =
    assert(
        is_num(cordCount) && floor(cordCount) == cordCount && cordCount > 0,
        "Knot bundle cord count must be a positive integer."
    )
    assert(
        is_num(cordRadius) && cordRadius > 0,
        "Knot bundle cord radius must be positive."
    )
    assert(is_num(cordGap) && cordGap >= 0, "Knot bundle gap must be nonnegative.")
    2 * cordCount * cordRadius + (cordCount - 1) * cordGap;

function KnotBundleFittedRadius(cordCount, bundleWidth, cordGap = 0) =
    assert(
        is_num(cordCount) && floor(cordCount) == cordCount && cordCount > 0,
        "Knot bundle cord count must be a positive integer."
    )
    assert(
        is_num(bundleWidth) && bundleWidth > 0,
        "Knot bundle width must be positive."
    )
    assert(is_num(cordGap) && cordGap >= 0, "Knot bundle gap must be nonnegative.")
    assert(
        bundleWidth > (cordCount - 1) * cordGap,
        "Knot bundle width must leave positive space for every cord."
    )
    (bundleWidth - (cordCount - 1) * cordGap) / (2 * cordCount);

function KnotBundleResolvedRadius(
    cordCount,
    cordRadius,
    cordGap,
    bundleWidth) =
    is_undef(bundleWidth)
    ? assert(
        is_num(cordRadius) && cordRadius > 0,
        "Knot bundle cord radius must be positive when width is not supplied."
    )
      cordRadius
    : KnotBundleFittedRadius(cordCount, bundleWidth, cordGap);

function KnotBundleLaneOffset(
    laneIndex,
    cordCount,
    cordRadius,
    cordGap = 0) =
    assert(
        is_num(laneIndex)
        && floor(laneIndex) == laneIndex
        && laneIndex >= 0
        && laneIndex < cordCount,
        "Knot bundle lane index is outside the bundle."
    )
    (laneIndex - (cordCount - 1) / 2) * (2 * cordRadius + cordGap);

function KnotStrandUniqueSampleCount(strand) =
    KnotStrandClosed(strand)
    ? max(0, KnotStrandSampleCount(strand) - 1)
    : KnotStrandSampleCount(strand);

function KnotStrandSampleTangent(strand, sampleIndex) =
    let(
        samples = KnotStrandSamples(strand),
        uniqueCount = KnotStrandUniqueSampleCount(strand),
        previousIndex = KnotStrandClosed(strand)
        ? (sampleIndex - 1 + uniqueCount) % uniqueCount
        : max(0, sampleIndex - 1),
        nextIndex = KnotStrandClosed(strand)
        ? (sampleIndex + 1) % uniqueCount
        : min(uniqueCount - 1, sampleIndex + 1)
    )
    assert(uniqueCount >= 2, "Knot bundle strands require at least two unique samples.")
    assert(
        sampleIndex >= 0 && sampleIndex < uniqueCount,
        "Knot bundle tangent sample index is outside the strand."
    )
    KnotVectorNormalize(
        KnotVectorSubtract(samples[nextIndex], samples[previousIndex])
    );

function KnotInitialLateral(tangent) =
    let(
        reference = abs(KnotVectorDot(tangent, [0, 0, 1])) < 0.9
        ? [0, 0, 1]
        : [0, 1, 0]
    )
    KnotVectorNormalize(KnotVectorCross(reference, tangent));

function KnotTransportLateral(priorLateral, tangent, tolerance = 0.000001) =
    let(
        projected = KnotVectorSubtract(
            priorLateral,
            KnotVectorScale(tangent, KnotVectorDot(priorLateral, tangent))
        )
    )
    KnotVectorLength(projected) > tolerance
    ? KnotVectorNormalize(projected)
    : KnotInitialLateral(tangent);

function KnotStrandRawLaterals(strand, sampleIndex = 0, priorLateral = undef) =
    let(uniqueCount = KnotStrandUniqueSampleCount(strand))
    sampleIndex >= uniqueCount
    ? []
    : let(
        tangent = KnotStrandSampleTangent(strand, sampleIndex),
        lateral = is_undef(priorLateral)
        ? KnotInitialLateral(tangent)
        : KnotTransportLateral(priorLateral, tangent)
    )
    concat(
        [lateral],
        KnotStrandRawLaterals(strand, sampleIndex + 1, lateral)
    );

function KnotStrandClosureCorrection(strand, rawLaterals) =
    !KnotStrandClosed(strand) || len(rawLaterals) < 2
    ? 0
    : let(
        firstTangent = KnotStrandSampleTangent(strand, 0),
        transportedEnd = KnotTransportLateral(
            rawLaterals[len(rawLaterals) - 1],
            firstTangent
        )
    )
    KnotVectorSignedAngle(transportedEnd, rawLaterals[0], firstTangent);

function KnotStrandStableLaterals(strand) =
    let(
        rawLaterals = KnotStrandRawLaterals(strand),
        correction = KnotStrandClosureCorrection(strand, rawLaterals),
        uniqueCount = len(rawLaterals)
    )
[
    for (sampleIndex = [0 : uniqueCount - 1])
        KnotVectorNormalize(
            KnotVectorRotateAroundAxis(
                rawLaterals[sampleIndex],
                KnotStrandSampleTangent(strand, sampleIndex),
                correction * sampleIndex / uniqueCount
            )
        )
];

function KnotBundleLaneSamples(strand, laneOffset) =
    let(
        samples = KnotStrandSamples(strand),
        uniqueCount = KnotStrandUniqueSampleCount(strand),
        laterals = KnotStrandStableLaterals(strand),
        uniqueLaneSamples = [
            for (sampleIndex = [0 : uniqueCount - 1])
                KnotVectorAdd(
                    samples[sampleIndex],
                    KnotVectorScale(laterals[sampleIndex], laneOffset)
                )
        ]
    )
    KnotStrandClosed(strand)
    ? concat(uniqueLaneSamples, [uniqueLaneSamples[0]])
    : uniqueLaneSamples;

function MakeKnotBundle(
    knot,
    cordCount = 3,
    cordRadius = 1,
    cordGap = 0.4,
    bundleWidth = undef) =
    assert(
        KnotValidationIsValid(ValidateKnot(knot)),
        "MakeKnotBundle requires a structurally valid knot."
    )
    assert(
        len(KnotCrossings(knot)) == 0,
        "Initial knot bundles require routes without recorded crossings."
    )
    assert(
        is_num(cordCount) && floor(cordCount) == cordCount && cordCount > 0,
        "Knot bundle cord count must be a positive integer."
    )
    assert(is_num(cordGap) && cordGap >= 0, "Knot bundle gap must be nonnegative.")
    let(
        resolvedRadius = KnotBundleResolvedRadius(
            cordCount,
            cordRadius,
            cordGap,
            bundleWidth
        ),
        masterStrands = KnotStrands(knot),
        bundleStrands = [
            for (masterIndex = [0 : len(masterStrands) - 1])
                for (laneIndex = [0 : cordCount - 1])
                    let(
                        masterStrand = masterStrands[masterIndex],
                        laneOffset = KnotBundleLaneOffset(
                            laneIndex,
                            cordCount,
                            resolvedRadius,
                            cordGap
                        )
                    )
                    MakeKnotStrand(
                        KnotStrandClosed(masterStrand),
                        KnotBundleLaneSamples(masterStrand, laneOffset),
                        laneClosurePermutation = [0],
                        metadata = concat(
                            KnotStrandMetadata(masterStrand),
                            [
                                "bundleMasterStrand", masterIndex,
                                "bundleLane", laneIndex,
                                "bundleLaneOffset", laneOffset
                            ]
                        )
                    )
        ]
    )
    MakeKnot(
        bundleStrands,
        [],
        concat(
            KnotMetadata(knot),
            [
                "bundleCordCount", cordCount,
                "bundleCordRadius", resolvedRadius,
                "bundleCordGap", cordGap,
                "bundleWidth", KnotBundleOccupiedWidth(
                    cordCount,
                    resolvedRadius,
                    cordGap
                )
            ]
        )
    );

module RenderKnotDebugSegment(a, b, radius, colorValue, fragments)
{
    color(colorValue)
    hull()
    {
        translate(a)
            sphere(r = radius, $fn = fragments);
        translate(b)
            sphere(r = radius, $fn = fragments);
    }
}

// Render one rounded capsule between adjacent centerline samples. This is an
// implementation helper for RenderKnotCords(), not a general Core stroke API.
module RenderKnotCordSegment(a, b, radius, fragments)
{
    hull()
    {
        translate(a)
            sphere(r = radius, $fn = fragments);
        translate(b)
            sphere(r = radius, $fn = fragments);
    }
}

// Convert every sampled strand into a manufacturable round cord by unioning
// sphere-hulled capsules. Closed strands already repeat their first sample, so
// their final segment closes exactly. The caller remains responsible for
// choosing a radius and sampling density that preserve intended clearance.
module RenderKnotCords(
    knot,
    cordRadius = 1,
    fragments = 24,
    validationTolerance = 0.001)
{
    validation = ValidateKnot(knot, validationTolerance);

    assert(
        KnotValidationIsValid(validation),
        "RenderKnotCords requires a structurally valid knot."
    );
    assert(
        is_num(cordRadius) && cordRadius > 0,
        "Knot cord radius must be positive."
    );
    assert(
        is_num(fragments) && floor(fragments) == fragments && fragments >= 3,
        "Knot cord fragments must be an integer of at least 3."
    );

    union()
    {
        for (strand = KnotStrands(knot))
        {
            samples = KnotStrandSamples(strand);

            for (sampleIndex = [0 : len(samples) - 2])
            {
                RenderKnotCordSegment(
                    samples[sampleIndex],
                    samples[sampleIndex + 1],
                    cordRadius,
                    fragments
                );
            }
        }
    }
}

// Expand each master strand into symmetric, untwisted lanes and render every
// lane through the existing capsule-cord path. Recorded crossing remapping,
// crossing lifts, explicit bundle twist, and Möbius closure remain deferred.
module RenderKnotCordBundle(
    knot,
    cordCount = 3,
    cordRadius = 1,
    cordGap = 0.4,
    bundleWidth = undef,
    fragments = 24,
    validationTolerance = 0.001)
{
    resolvedRadius = KnotBundleResolvedRadius(
        cordCount,
        cordRadius,
        cordGap,
        bundleWidth
    );
    bundle = MakeKnotBundle(
        knot,
        cordCount,
        resolvedRadius,
        cordGap,
        bundleWidth
    );

    RenderKnotCords(
        bundle,
        cordRadius = resolvedRadius,
        fragments = fragments,
        validationTolerance = validationTolerance
    );
}

function KnotViewPoint(point, viewMode) =
    assert(
        viewMode == "Planar" || viewMode == "Spatial",
        "Knot view mode must be Planar or Spatial."
    )
    viewMode == "Planar"
    ? [point[0], point[1], 0]
    : point;

// Return a view-specific copy without modifying the source record. Planar
// projection flattens strand samples only; crossing records are already 2D.
function KnotStrandForView(strand, viewMode) =
    MakeKnotStrand(
        KnotStrandClosed(strand),
        [
            for (sample = KnotStrandSamples(strand))
                KnotViewPoint(sample, viewMode)
        ],
        KnotStrandCrossingEncounters(strand),
        KnotStrandLaneClosurePermutation(strand),
        KnotStrandMetadata(strand)
    );

function KnotForView(knot, viewMode) =
    assert(
        KnotValidationIsValid(ValidateKnot(knot)),
        "KnotForView requires a structurally valid knot."
    )
    MakeKnot(
        [
            for (strand = KnotStrands(knot))
                KnotStrandForView(strand, viewMode)
        ],
        KnotCrossings(knot),
        KnotMetadata(knot)
    );

// Compatibility alias retained for existing diagnostic callers.
function KnotDebugViewPoint(point, viewMode) =
    KnotViewPoint(point, viewMode);

// Preview sampled centerlines, individual samples, and recorded crossings.
// This diagnostic module does not create a manufacturable cord contract.
module RenderKnotDebug(
    knot,
    viewMode = "Spatial",
    showCenterlines = true,
    showSamples = true,
    showCrossings = true,
    centerlineRadius = 0.12,
    sampleRadius = 0.28,
    crossingRadius = 0.55,
    fragments = 12)
{
    strandColors =
    [
        [0.10, 0.55, 0.95],
        [0.95, 0.35, 0.15],
        [0.25, 0.75, 0.30],
        [0.70, 0.30, 0.85],
        [0.95, 0.75, 0.10]
    ];

    strands = KnotStrands(knot);

    for (strandIndex = [0 : len(strands) - 1])
    {
        samples = KnotStrandSamples(strands[strandIndex]);
        strandColor = strandColors[strandIndex % len(strandColors)];

        if (showCenterlines)
        {
            for (sampleIndex = [0 : len(samples) - 2])
            {
                RenderKnotDebugSegment(
                    KnotViewPoint(samples[sampleIndex], viewMode),
                    KnotViewPoint(samples[sampleIndex + 1], viewMode),
                    centerlineRadius,
                    strandColor,
                    fragments
                );
            }
        }

        if (showSamples)
        {
            for (sampleIndex = [0 : len(samples) - 1])
            {
                color(
                    sampleIndex == 0
                    ? [0.10, 0.90, 0.20]
                    : sampleIndex == len(samples) - 1
                        ? [0.95, 0.10, 0.10]
                        : strandColor
                )
                translate(KnotViewPoint(samples[sampleIndex], viewMode))
                    sphere(r = sampleRadius, $fn = fragments);
            }
        }
    }

    if (showCrossings)
    {
        for (crossing = KnotCrossings(knot))
        {
            point = KnotCrossingPoint(crossing);
            color([1.00, 0.10, 0.75])
            translate([point[0], point[1], 0])
                sphere(r = crossingRadius, $fn = fragments);
        }
    }
}
