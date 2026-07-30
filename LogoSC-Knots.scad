// ============================================================================
// LogoSC Knots - optional sampled-knot companion
//
// Pure OpenSCAD functions define and validate sampled knot records and generate
// torus, circular-braid, and Celtic tile-grid routes. Native sphere/hull
// geometry produces diagnostics, manufacturable rounded cords, and untwisted
// adjacent cord bundles. The optional planar ribbon compiler uses LogoSC Core
// region records and RenderRegion2D(); it does not call evalLogo().
// ============================================================================

use <LogoSC-Foundation-Core.scad>

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
    len(crossings) == 0
    ? []
    : [
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

KNOT_CELTIC_NORTH = 0;
KNOT_CELTIC_EAST = 1;
KNOT_CELTIC_SOUTH = 2;
KNOT_CELTIC_WEST = 3;

function KnotCelticCanonicalTile(tile) =
    tile == "NE_SW" || tile == "/"
    ? ">"
    : tile == "NW_ES" || tile == "\\" || tile == "//"
        ? "<"
        : tile;

function KnotCelticTileIsValid(tile) =
    let(canonicalTile = KnotCelticCanonicalTile(tile))
    canonicalTile == "X" || canonicalTile == ">" || canonicalTile == "<";

function KnotCelticGridRowIsValid(row) =
    is_string(row) || is_list(row);

function KnotCelticCanonicalRow(row, index = 0, result = "") =
    index >= len(row)
    ? result
    : KnotCelticCanonicalRow(
        row,
        index + 1,
        str(result, KnotCelticCanonicalTile(row[index]))
    );

function KnotCelticCanonicalGrid(grid) =
[
    for (row = grid)
        KnotCelticCanonicalRow(row)
];

function KnotCelticGridColumnCount(grid) =
    is_list(grid) && len(grid) > 0 && KnotCelticGridRowIsValid(grid[0])
    ? len(grid[0])
    : 0;

function KnotCelticGridIsRectangular(grid) =
    is_list(grid)
    && len(grid) > 0
    && KnotCelticGridColumnCount(grid) > 0
    && len([
        for (row = grid)
            if (
                !KnotCelticGridRowIsValid(row)
                || len(row) != KnotCelticGridColumnCount(grid)
            )
                row
    ]) == 0;

function KnotCelticGridTilesAreValid(grid) =
    KnotCelticGridIsRectangular(grid)
    && len([
        for (row = grid)
            for (column = [0 : len(row) - 1])
                if (!KnotCelticTileIsValid(row[column]))
                    row[column]
    ]) == 0;

function KnotCelticOppositePort(port) = (port + 2) % 4;

function KnotCelticTilePairedPort(tile, port) =
    assert(KnotCelticTileIsValid(tile), "Unknown Celtic grid tile.")
    let(canonicalTile = KnotCelticCanonicalTile(tile))
    canonicalTile == "X"
    ? KnotCelticOppositePort(port)
    : canonicalTile == ">"
        ? port == KNOT_CELTIC_NORTH
            ? KNOT_CELTIC_EAST
            : port == KNOT_CELTIC_EAST
                ? KNOT_CELTIC_NORTH
                : port == KNOT_CELTIC_SOUTH
                    ? KNOT_CELTIC_WEST
                    : KNOT_CELTIC_SOUTH
        : port == KNOT_CELTIC_NORTH
            ? KNOT_CELTIC_WEST
            : port == KNOT_CELTIC_WEST
                ? KNOT_CELTIC_NORTH
                : port == KNOT_CELTIC_EAST
                    ? KNOT_CELTIC_SOUTH
                    : KNOT_CELTIC_EAST;

function KnotCelticStateId(row, column, port, columnCount) =
    (row * columnCount + column) * 4 + port;

function KnotCelticStateFromId(stateId, columnCount) =
    let(
        cellIndex = floor(stateId / 4),
        port = stateId % 4
    )
    [
        floor(cellIndex / columnCount),
        cellIndex % columnCount,
        port
    ];

function KnotCelticPortDelta(port) =
    port == KNOT_CELTIC_NORTH
    ? [-1, 0]
    : port == KNOT_CELTIC_EAST
        ? [0, 1]
        : port == KNOT_CELTIC_SOUTH
            ? [1, 0]
            : [0, -1];

function KnotCelticBoundaryStates(rowCount, columnCount) =
    concat(
        [
            for (column = [0 : columnCount - 1])
                [0, column, KNOT_CELTIC_NORTH]
        ],
        [
            for (row = [0 : rowCount - 1])
                [row, columnCount - 1, KNOT_CELTIC_EAST]
        ],
        [
            for (column = [columnCount - 1 : -1 : 0])
                [rowCount - 1, column, KNOT_CELTIC_SOUTH]
        ],
        [
            for (row = [rowCount - 1 : -1 : 0])
                [row, 0, KNOT_CELTIC_WEST]
        ]
    );

function KnotCelticStateEquals(a, b) =
    a[0] == b[0] && a[1] == b[1] && a[2] == b[2];

function KnotCelticStateIndex(states, state, index = 0) =
    index >= len(states)
    ? undef
    : KnotCelticStateEquals(states[index], state)
        ? index
        : KnotCelticStateIndex(states, state, index + 1);

function KnotCelticBoundaryPartner(state, rowCount, columnCount) =
    let(
        boundaryStates = KnotCelticBoundaryStates(rowCount, columnCount),
        boundaryIndex = KnotCelticStateIndex(boundaryStates, state),
        partnerIndex = boundaryIndex % 2 == 0
        ? boundaryIndex + 1
        : boundaryIndex - 1
    )
    assert(!is_undef(boundaryIndex), "Celtic boundary state was not found.")
    boundaryStates[partnerIndex];

function KnotCelticExternalState(state, rowCount, columnCount) =
    let(
        delta = KnotCelticPortDelta(state[2]),
        nextRow = state[0] + delta[0],
        nextColumn = state[1] + delta[1]
    )
    nextRow >= 0
    && nextRow < rowCount
    && nextColumn >= 0
    && nextColumn < columnCount
    ? [nextRow, nextColumn, KnotCelticOppositePort(state[2])]
    : KnotCelticBoundaryPartner(state, rowCount, columnCount);

function KnotCelticInternalState(grid, state) =
    [
        state[0],
        state[1],
        KnotCelticTilePairedPort(grid[state[0]][state[1]], state[2])
    ];

function KnotCelticSuccessorStateId(grid, stateId) =
    let(
        rowCount = len(grid),
        columnCount = KnotCelticGridColumnCount(grid),
        entryState = KnotCelticStateFromId(stateId, columnCount),
        exitState = KnotCelticInternalState(grid, entryState),
        nextState = KnotCelticExternalState(
            exitState,
            rowCount,
            columnCount
        )
    )
    KnotCelticStateId(
        nextState[0],
        nextState[1],
        nextState[2],
        columnCount
    );

function KnotCelticTraceCycle(
    grid,
    startStateId,
    stateId = undef,
    path = []) =
    let(currentStateId = is_undef(stateId) ? startStateId : stateId)
    len(path) > 0 && currentStateId == startStateId
    ? path
    : assert(
        !KnotListContains(path, currentStateId),
        "Celtic grid route entered a non-closing cycle."
    )
      KnotCelticTraceCycle(
          grid,
          startStateId,
          KnotCelticSuccessorStateId(grid, currentStateId),
          concat(path, [currentStateId])
      );

function KnotCelticReverseCycleStateIds(grid, cycle) =
    let(columnCount = KnotCelticGridColumnCount(grid))
[
    for (stateId = cycle)
        let(
            state = KnotCelticStateFromId(stateId, columnCount),
            reverseState = KnotCelticInternalState(grid, state)
        )
        KnotCelticStateId(
            reverseState[0],
            reverseState[1],
            reverseState[2],
            columnCount
        )
];

function KnotCelticFirstUnvisitedState(
    stateCount,
    visited,
    stateId = 0) =
    stateId >= stateCount
    ? undef
    : KnotListContains(visited, stateId)
        ? KnotCelticFirstUnvisitedState(
            stateCount,
            visited,
            stateId + 1
        )
        : stateId;

function KnotCelticTraceCycles(
    grid,
    visited = [],
    cycles = []) =
    let(
        stateCount = len(grid) * KnotCelticGridColumnCount(grid) * 4,
        startStateId = KnotCelticFirstUnvisitedState(
            stateCount,
            visited
        )
    )
    is_undef(startStateId)
    ? cycles
    : let(
        cycle = KnotCelticTraceCycle(grid, startStateId),
        reverseCycle = KnotCelticReverseCycleStateIds(grid, cycle)
    )
    KnotCelticTraceCycles(
        grid,
        concat(visited, cycle, reverseCycle),
        concat(cycles, [cycle])
    );

function KnotCelticPortPoint(state, cellSize) =
    let(
        center = [
            (state[1] + 0.5) * cellSize,
            -(state[0] + 0.5) * cellSize,
            0
        ],
        half = cellSize / 2
    )
    state[2] == KNOT_CELTIC_NORTH
    ? [center[0], center[1] + half, 0]
    : state[2] == KNOT_CELTIC_EAST
        ? [center[0] + half, center[1], 0]
        : state[2] == KNOT_CELTIC_SOUTH
            ? [center[0], center[1] - half, 0]
            : [center[0] - half, center[1], 0];

function KnotCelticCurveControl(entryState, exitState, cellSize) =
    let(
        entry = KnotCelticPortPoint(entryState, cellSize),
        exit = KnotCelticPortPoint(exitState, cellSize)
    )
    KnotCelticOppositePort(entryState[2]) == exitState[2]
    ? [(entry[0] + exit[0]) / 2, (entry[1] + exit[1]) / 2, 0]
    : [
        entryState[2] == KNOT_CELTIC_NORTH
        || entryState[2] == KNOT_CELTIC_SOUTH
        ? exit[0]
        : entry[0],
        entryState[2] == KNOT_CELTIC_NORTH
        || entryState[2] == KNOT_CELTIC_SOUTH
        ? entry[1]
        : exit[1],
        0
    ];

function KnotCelticQuadraticPoint(start, control, end, blend) =
    KnotVectorAdd(
        KnotVectorAdd(
            KnotVectorScale(start, (1 - blend) * (1 - blend)),
            KnotVectorScale(control, 2 * (1 - blend) * blend)
        ),
        KnotVectorScale(end, blend * blend)
    );

function KnotCelticTileBranchIsVertical(entryPort, exitPort) =
    (
        entryPort == KNOT_CELTIC_NORTH
        && exitPort == KNOT_CELTIC_SOUTH
    )
    || (
        entryPort == KNOT_CELTIC_SOUTH
        && exitPort == KNOT_CELTIC_NORTH
    );

function KnotCelticTilePoint(
    grid,
    state,
    blend,
    cellSize,
    crossingHeight) =
    let(
        exitState = KnotCelticInternalState(grid, state),
        start = KnotCelticPortPoint(state, cellSize),
        end = KnotCelticPortPoint(exitState, cellSize),
        control = KnotCelticCurveControl(state, exitState, cellSize),
        basePoint = KnotCelticQuadraticPoint(start, control, end, blend),
        tile = grid[state[0]][state[1]],
        verticalBranch = KnotCelticTileBranchIsVertical(
            state[2],
            exitState[2]
        ),
        verticalOver = (state[0] + state[1]) % 2 == 0,
        over = verticalBranch == verticalOver,
        height = tile == "X"
        ? (over ? 1 : -1) * crossingHeight * sin(180 * blend) / 2
        : 0
    )
    [basePoint[0], basePoint[1], height];

function KnotCelticStateHasBoundaryConnector(
    grid,
    stateId) =
    let(
        columnCount = KnotCelticGridColumnCount(grid),
        entryState = KnotCelticStateFromId(stateId, columnCount),
        exitState = KnotCelticInternalState(grid, entryState),
        delta = KnotCelticPortDelta(exitState[2]),
        nextRow = exitState[0] + delta[0],
        nextColumn = exitState[1] + delta[1]
    )
    nextRow < 0
    || nextRow >= len(grid)
    || nextColumn < 0
    || nextColumn >= columnCount;

function KnotCelticBoundaryConnectorPoint(
    grid,
    stateId,
    blend,
    cellSize) =
    let(
        columnCount = KnotCelticGridColumnCount(grid),
        entryState = KnotCelticStateFromId(stateId, columnCount),
        exitState = KnotCelticInternalState(grid, entryState),
        nextState = KnotCelticExternalState(
            exitState,
            len(grid),
            columnCount
        ),
        start = KnotCelticPortPoint(exitState, cellSize),
        end = KnotCelticPortPoint(nextState, cellSize),
        outward = KnotCelticPortDelta(exitState[2]),
        control = [
            (start[0] + end[0]) / 2 + outward[1] * cellSize * 0.45,
            (start[1] + end[1]) / 2 - outward[0] * cellSize * 0.45,
            0
        ]
    )
    KnotCelticQuadraticPoint(start, control, end, blend);

function KnotCelticCycleSamples(
    grid,
    cycle,
    cellSize,
    samplesPerTile,
    samplesPerBoundary,
    crossingHeight) =
    let(
        columnCount = KnotCelticGridColumnCount(grid),
        openSamples = [
            for (stateId = cycle)
                let(state = KnotCelticStateFromId(stateId, columnCount))
                each concat(
                    [
                        for (sampleIndex = [0 : samplesPerTile - 1])
                            KnotCelticTilePoint(
                                grid,
                                state,
                                sampleIndex / samplesPerTile,
                                cellSize,
                                crossingHeight
                            )
                    ],
                    KnotCelticStateHasBoundaryConnector(grid, stateId)
                    ? [
                        for (
                            sampleIndex = [0 : samplesPerBoundary - 1]
                        )
                            KnotCelticBoundaryConnectorPoint(
                                grid,
                                stateId,
                                sampleIndex / samplesPerBoundary,
                                cellSize
                            )
                    ]
                    : []
                )
        ]
    )
    concat(openSamples, [openSamples[0]]);

function KnotCelticCycleSegmentCount(
    grid,
    cycle,
    samplesPerTile,
    samplesPerBoundary) =
    len(cycle) * samplesPerTile
    + len([
        for (stateId = cycle)
            if (KnotCelticStateHasBoundaryConnector(grid, stateId))
                stateId
    ]) * samplesPerBoundary;

function KnotCelticCyclePointOffset(
    grid,
    cycle,
    statePosition,
    samplesPerTile,
    samplesPerBoundary,
    index = 0,
    offset = 0) =
    index >= statePosition
    ? offset
    : KnotCelticCyclePointOffset(
        grid,
        cycle,
        statePosition,
        samplesPerTile,
        samplesPerBoundary,
        index + 1,
        offset
        + samplesPerTile
        + (
            KnotCelticStateHasBoundaryConnector(grid, cycle[index])
            ? samplesPerBoundary
            : 0
        )
    );

function KnotCelticCycleStatePosition(
    cycle,
    candidateStateIds,
    index = 0) =
    index >= len(cycle)
    ? undef
    : KnotListContains(candidateStateIds, cycle[index])
        ? index
        : KnotCelticCycleStatePosition(
            cycle,
            candidateStateIds,
            index + 1
        );

function KnotCelticCrossingBranch(
    grid,
    cycles,
    row,
    column,
    ports,
    samplesPerTile,
    samplesPerBoundary) =
    let(
        columnCount = KnotCelticGridColumnCount(grid),
        candidateStateIds = [
            for (port = ports)
                KnotCelticStateId(row, column, port, columnCount)
        ],
        matches = [
            for (strandIndex = [0 : len(cycles) - 1])
                let(
                    statePosition = KnotCelticCycleStatePosition(
                        cycles[strandIndex],
                        candidateStateIds
                    )
                )
                if (!is_undef(statePosition))
                    [strandIndex, statePosition]
        ],
        match = matches[0],
        cycle = cycles[match[0]],
        sampleOffset = KnotCelticCyclePointOffset(
            grid,
            cycle,
            match[1],
            samplesPerTile,
            samplesPerBoundary
        ),
        segmentCount = KnotCelticCycleSegmentCount(
            grid,
            cycle,
            samplesPerTile,
            samplesPerBoundary
        )
    )
    [
        match[0],
        (sampleOffset + samplesPerTile / 2) / segmentCount
    ];

function KnotCelticGridCrossings(
    grid,
    cycles,
    cellSize,
    samplesPerTile,
    samplesPerBoundary) =
[
    for (row = [0 : len(grid) - 1])
        for (column = [0 : KnotCelticGridColumnCount(grid) - 1])
            if (grid[row][column] == "X")
                let(
                    vertical = KnotCelticCrossingBranch(
                        grid,
                        cycles,
                        row,
                        column,
                        [KNOT_CELTIC_NORTH, KNOT_CELTIC_SOUTH],
                        samplesPerTile,
                        samplesPerBoundary
                    ),
                    horizontal = KnotCelticCrossingBranch(
                        grid,
                        cycles,
                        row,
                        column,
                        [KNOT_CELTIC_EAST, KNOT_CELTIC_WEST],
                        samplesPerTile,
                        samplesPerBoundary
                    ),
                    verticalOver = (row + column) % 2 == 0
                )
                MakeKnotCrossing(
                    [
                        (column + 0.5) * cellSize,
                        -(row + 0.5) * cellSize
                    ],
                    vertical[0],
                    vertical[1],
                    horizontal[0],
                    horizontal[1],
                    verticalOver ? vertical[0] : horizontal[0],
                    verticalOver ? "A" : "B"
                )
];

function KnotCelticStrandCrossingEvents(knot, strandIndex) =
[
    for (crossing = KnotCrossings(knot))
        each concat(
            KnotCrossingStrandA(crossing) == strandIndex
            ? [[
                KnotCrossingParameterA(crossing),
                KnotCrossingOverBranch(crossing) == "A"
            ]]
            : [],
            KnotCrossingStrandB(crossing) == strandIndex
            ? [[
                KnotCrossingParameterB(crossing),
                KnotCrossingOverBranch(crossing) == "B"
            ]]
            : []
        )
];

function KnotCelticMinimumEventIndex(events, index = 1, minimumIndex = 0) =
    index >= len(events)
    ? minimumIndex
    : KnotCelticMinimumEventIndex(
        events,
        index + 1,
        events[index][0] < events[minimumIndex][0]
        ? index
        : minimumIndex
    );

function KnotCelticRemoveListIndex(values, removeIndex) =
[
    for (index = [0 : len(values) - 1])
        if (index != removeIndex)
            values[index]
];

function KnotCelticSortEvents(events) =
    len(events) <= 1
    ? events
    : let(minimumIndex = KnotCelticMinimumEventIndex(events))
      concat(
          [events[minimumIndex]],
          KnotCelticSortEvents(
              KnotCelticRemoveListIndex(events, minimumIndex)
          )
      );

function KnotCelticEventsAlternate(events, index = 0) =
    len(events) < 2
    || (
        events[index][1] != events[(index + 1) % len(events)][1]
        && (
            index + 1 >= len(events)
            || KnotCelticEventsAlternate(events, index + 1)
        )
    );

function KnotCelticKnotIsAlternating(knot) =
    len([
        for (strandIndex = [0 : len(KnotStrands(knot)) - 1])
            if (
                !KnotCelticEventsAlternate(
                    KnotCelticSortEvents(
                        KnotCelticStrandCrossingEvents(
                            knot,
                            strandIndex
                        )
                    )
                )
            )
                strandIndex
    ]) == 0;

function MakeCelticTileGridKnot(
    grid,
    cellSize = 12,
    samplesPerTile = 6,
    samplesPerBoundary = 4,
    crossingHeight = 4) =
    assert(
        KnotCelticGridIsRectangular(grid),
        "Celtic grid must be a nonempty rectangular list of rows."
    )
    assert(
        KnotCelticGridTilesAreValid(grid),
        "Celtic grid contains an unknown tile."
    )
    assert(is_num(cellSize) && cellSize > 0, "Celtic cell size must be positive.")
    assert(
        is_num(samplesPerTile)
        && floor(samplesPerTile) == samplesPerTile
        && samplesPerTile >= 4
        && samplesPerTile % 2 == 0,
        "Celtic tile samples must be an even integer of at least 4."
    )
    assert(
        is_num(samplesPerBoundary)
        && floor(samplesPerBoundary) == samplesPerBoundary
        && samplesPerBoundary >= 2,
        "Celtic boundary samples must be an integer of at least 2."
    )
    assert(
        is_num(crossingHeight) && crossingHeight > 0,
        "Celtic crossing height must be positive."
    )
    let(
        canonicalGrid = KnotCelticCanonicalGrid(grid),
        cycles = KnotCelticTraceCycles(canonicalGrid),
        crossings = KnotCelticGridCrossings(
            canonicalGrid,
            cycles,
            cellSize,
            samplesPerTile,
            samplesPerBoundary
        ),
        strands = [
            for (strandIndex = [0 : len(cycles) - 1])
                MakeKnotStrand(
                    true,
                        KnotCelticCycleSamples(
                        canonicalGrid,
                        cycles[strandIndex],
                        cellSize,
                        samplesPerTile,
                        samplesPerBoundary,
                        crossingHeight
                    ),
                    KnotBraidComponentEncounters(
                        crossings,
                        strandIndex
                    ),
                    metadata = [
                        "generator", "celticTileGrid",
                        "component", strandIndex,
                        "stateCycle", cycles[strandIndex]
                    ]
                )
        ],
        knot = MakeKnot(
            strands,
            crossings,
            [
                "generator", "celticTileGrid",
                "rows", len(grid),
                "columns", KnotCelticGridColumnCount(grid),
                "grid", canonicalGrid,
                "cellSize", cellSize,
                "samplesPerTile", samplesPerTile,
                "samplesPerBoundary", samplesPerBoundary,
                "crossingHeight", crossingHeight,
                "boundaryClosure", "clockwisePairs"
            ]
        )
    )
    assert(
        KnotCelticKnotIsAlternating(knot),
        "Celtic grid does not produce alternating crossing encounters."
    )
    knot;

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

// Interpolate a normalized route parameter through a sampled strand. Crossing
// parameters refer to segments, so a parameter of 1 selects the final sample.
function KnotStrandPointAtParameter(strand, parameter) =
    let(
        samples = KnotStrandSamples(strand),
        segmentCount = KnotStrandSegmentCount(strand),
        scaled = parameter * segmentCount,
        segmentIndex = min(segmentCount - 1, floor(scaled)),
        blend = parameter == 1 ? 1 : scaled - segmentIndex
    )
    assert(
        is_num(parameter) && parameter >= 0 && parameter <= 1,
        "Knot strand parameter must be normalized to [0, 1]."
    )
    assert(segmentCount > 0, "Knot strand interpolation requires a segment.")
    KnotVectorAdd(
        KnotVectorScale(samples[segmentIndex], 1 - blend),
        KnotVectorScale(samples[segmentIndex + 1], blend)
    );

function KnotBundleExpandedStrandIndex(masterIndex, laneIndex, cordCount) =
    masterIndex * cordCount + laneIndex;

function KnotBundleCrossingForLanes(
    crossing,
    bundleStrands,
    cordCount,
    laneA,
    laneB) =
    let(
        strandA = KnotBundleExpandedStrandIndex(
            KnotCrossingStrandA(crossing),
            laneA,
            cordCount
        ),
        strandB = KnotBundleExpandedStrandIndex(
            KnotCrossingStrandB(crossing),
            laneB,
            cordCount
        ),
        pointA = KnotStrandPointAtParameter(
            bundleStrands[strandA],
            KnotCrossingParameterA(crossing)
        ),
        pointB = KnotStrandPointAtParameter(
            bundleStrands[strandB],
            KnotCrossingParameterB(crossing)
        ),
        overBranch = KnotCrossingOverBranch(crossing)
    )
    MakeKnotCrossing(
        [
            (pointA[0] + pointB[0]) / 2,
            (pointA[1] + pointB[1]) / 2
        ],
        strandA,
        KnotCrossingParameterA(crossing),
        strandB,
        KnotCrossingParameterB(crossing),
        overBranch == "A" ? strandA : strandB,
        overBranch
    );

// Expand every master crossing into all lane-pair crossings. This N squared
// mapping lets validation and clearance analysis reason about actual cords.
function KnotBundleCrossings(knot, bundleStrands, cordCount) =
[
    for (crossing = KnotCrossings(knot))
        for (laneA = [0 : cordCount - 1])
            for (laneB = [0 : cordCount - 1])
                KnotBundleCrossingForLanes(
                    crossing,
                    bundleStrands,
                    cordCount,
                    laneA,
                    laneB
                )
];

function KnotCrossingCenterDistance(knot, crossing) =
    KnotPointDistance(
        KnotStrandPointAtParameter(
            KnotStrands(knot)[KnotCrossingStrandA(crossing)],
            KnotCrossingParameterA(crossing)
        ),
        KnotStrandPointAtParameter(
            KnotStrands(knot)[KnotCrossingStrandB(crossing)],
            KnotCrossingParameterB(crossing)
        )
    );

function KnotBundleCrossingClearances(
    knot,
    cordRadius,
    minimumClearance = 0) =
    assert(
        is_num(cordRadius) && cordRadius > 0,
        "Knot bundle clearance radius must be positive."
    )
    assert(
        is_num(minimumClearance) && minimumClearance >= 0,
        "Knot bundle minimum clearance must be nonnegative."
    )
    len(KnotCrossings(knot)) == 0
    ? []
    : [
        for (crossingIndex = [0 : len(KnotCrossings(knot)) - 1])
            let(
                crossing = KnotCrossings(knot)[crossingIndex],
                centerDistance = KnotCrossingCenterDistance(knot, crossing),
                requiredDistance = 2 * cordRadius + minimumClearance
            )
            [
                crossingIndex,
                centerDistance,
                requiredDistance,
                centerDistance >= requiredDistance
            ]
    ];

function KnotBundleHasCrossingClearance(
    knot,
    cordRadius,
    minimumClearance = 0) =
    len([
        for (
            result = KnotBundleCrossingClearances(
                knot,
                cordRadius,
                minimumClearance
            )
        )
            if (!result[3])
                result
    ]) == 0;

function MakeKnotBundle(
    knot,
    cordCount = 3,
    cordRadius = 1,
    cordGap = 0.4,
    bundleWidth = undef,
    minimumClearance = 0,
    checkCrossingClearance = true) =
    assert(
        KnotValidationIsValid(ValidateKnot(knot)),
        "MakeKnotBundle requires a structurally valid knot."
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
        routeStrands = [
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
        ],
        bundleCrossings = KnotBundleCrossings(
            knot,
            routeStrands,
            cordCount
        ),
        bundleStrands = [
            for (strandIndex = [0 : len(routeStrands) - 1])
                let(strand = routeStrands[strandIndex])
                MakeKnotStrand(
                    KnotStrandClosed(strand),
                    KnotStrandSamples(strand),
                    KnotBraidComponentEncounters(
                        bundleCrossings,
                        strandIndex
                    ),
                    KnotStrandLaneClosurePermutation(strand),
                    KnotStrandMetadata(strand)
                )
        ],
        bundle = MakeKnot(
            bundleStrands,
            bundleCrossings,
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
                    ),
                    "bundleMinimumClearance", minimumClearance
                ]
            )
        )
    )
    assert(
        !checkCrossingClearance
        || KnotBundleHasCrossingClearance(
            bundle,
            resolvedRadius,
            minimumClearance
        ),
        "Knot bundle cords do not preserve the requested crossing clearance."
    )
    bundle;

function KnotSamplesArePlanar(samples, tolerance = 0.001, index = 0) =
    index >= len(samples)
    || (
        abs(samples[index][2]) <= tolerance
        && KnotSamplesArePlanar(samples, tolerance, index + 1)
    );

function KnotIsPlanar(knot, tolerance = 0.001) =
    KnotValidationIsValid(ValidateKnot(knot, tolerance))
    && len([
        for (strand = KnotStrands(knot))
            if (!KnotSamplesArePlanar(KnotStrandSamples(strand), tolerance))
                strand
    ]) == 0;

function KnotRibbonPoint2D(point) = [point[0], point[1]];

function KnotRibbonCapsuleContour(
    start,
    end,
    radius,
    arcFragments = 8) =
    let(
        start2D = KnotRibbonPoint2D(start),
        end2D = KnotRibbonPoint2D(end),
        delta = [
            end2D[0] - start2D[0],
            end2D[1] - start2D[1]
        ],
        length = sqrt(delta[0] * delta[0] + delta[1] * delta[1]),
        angle = length > 0 ? atan2(delta[1], delta[0]) : 0
    )
    assert(is_num(radius) && radius > 0, "Knot ribbon radius must be positive.")
    assert(
        is_num(arcFragments)
        && floor(arcFragments) == arcFragments
        && arcFragments >= 2,
        "Knot ribbon arc fragments must be an integer of at least 2."
    )
    length == 0
    ? [
        for (index = [0 : 2 * arcFragments - 1])
            [
                start2D[0] + radius * cos(360 * index / (2 * arcFragments)),
                start2D[1] + radius * sin(360 * index / (2 * arcFragments))
            ]
    ]
    : concat(
        [
            for (index = [0 : arcFragments])
                let(angleAtPoint = angle + 90 - 180 * index / arcFragments)
                [
                    end2D[0] + radius * cos(angleAtPoint),
                    end2D[1] + radius * sin(angleAtPoint)
                ]
        ],
        [
            for (index = [0 : arcFragments])
                let(angleAtPoint = angle - 90 - 180 * index / arcFragments)
                [
                    start2D[0] + radius * cos(angleAtPoint),
                    start2D[1] + radius * sin(angleAtPoint)
                ]
        ]
    );

function KnotRibbonCapsuleRegion(
    start,
    end,
    radius,
    arcFragments = 8) =
    MakeRegion(
        KnotRibbonCapsuleContour(start, end, radius, arcFragments)
    );

function KnotRibbonRectangleContour(start, end, halfWidth) =
    let(
        start2D = KnotRibbonPoint2D(start),
        end2D = KnotRibbonPoint2D(end),
        delta = [
            end2D[0] - start2D[0],
            end2D[1] - start2D[1]
        ],
        length = sqrt(delta[0] * delta[0] + delta[1] * delta[1]),
        normal = [-delta[1] / length, delta[0] / length],
        offset = [normal[0] * halfWidth, normal[1] * halfWidth]
    )
    assert(length > 0, "Knot ribbon rectangle requires a nonzero segment.")
    assert(
        is_num(halfWidth) && halfWidth > 0,
        "Knot ribbon rectangle half-width must be positive."
    )
    [
        [start2D[0] + offset[0], start2D[1] + offset[1]],
        [end2D[0] + offset[0], end2D[1] + offset[1]],
        [end2D[0] - offset[0], end2D[1] - offset[1]],
        [start2D[0] - offset[0], start2D[1] - offset[1]]
    ];

function KnotRibbonRectangleRegion(start, end, halfWidth) =
    MakeRegion(KnotRibbonRectangleContour(start, end, halfWidth));

function KnotRibbonRegions(
    knot,
    ribbonWidth = 2,
    arcFragments = 8,
    planarTolerance = 0.001) =
    assert(
        KnotIsPlanar(knot, planarTolerance),
        "KnotRibbonRegions requires a structurally valid planar knot."
    )
    assert(
        is_num(ribbonWidth) && ribbonWidth > 0,
        "Knot ribbon width must be positive."
    )
[
    for (strand = KnotStrands(knot))
        let(samples = KnotStrandSamples(strand))
        for (sampleIndex = [0 : len(samples) - 2])
            KnotRibbonCapsuleRegion(
                samples[sampleIndex],
                samples[sampleIndex + 1],
                ribbonWidth / 2,
                arcFragments
            )
];

function KnotStrandTangentAtParameter(strand, parameter) =
    let(
        samples = KnotStrandSamples(strand),
        segmentCount = KnotStrandSegmentCount(strand),
        segmentIndex = min(
            segmentCount - 1,
            floor(parameter * segmentCount)
        ),
        delta = KnotVectorSubtract(
            samples[segmentIndex + 1],
            samples[segmentIndex]
        ),
        planarDelta = [delta[0], delta[1], 0]
    )
    assert(
        is_num(parameter) && parameter >= 0 && parameter <= 1,
        "Knot ribbon tangent parameter must be normalized to [0, 1]."
    )
    assert(
        KnotVectorLength(planarDelta) > 0.000001,
        "Knot ribbon crossing tangent is degenerate."
    )
    KnotVectorNormalize(planarDelta);

function KnotCrossingBranchStrand(crossing, branch) =
    assert(branch == "A" || branch == "B", "Knot crossing branch must be A or B.")
    branch == "A"
    ? KnotCrossingStrandA(crossing)
    : KnotCrossingStrandB(crossing);

function KnotCrossingBranchParameter(crossing, branch) =
    assert(branch == "A" || branch == "B", "Knot crossing branch must be A or B.")
    branch == "A"
    ? KnotCrossingParameterA(crossing)
    : KnotCrossingParameterB(crossing);

function KnotRibbonCrossingSpan(
    ribbonWidth,
    crossingClearance,
    expanded) =
    assert(
        is_num(ribbonWidth) && ribbonWidth > 0,
        "Knot ribbon width must be positive."
    )
    assert(
        is_num(crossingClearance) && crossingClearance >= 0,
        "Knot ribbon crossing clearance must be nonnegative."
    )
    2 * ribbonWidth
    + 2 * crossingClearance
    + (
        expanded
        ? 0
        : 2 * crossingClearance
    );

function KnotRibbonCrossingRegion(
    knot,
    crossing,
    branch,
    ribbonWidth,
    crossingClearance,
    arcFragments,
    expanded) =
    assert(
        is_num(ribbonWidth) && ribbonWidth > 0,
        "Knot ribbon width must be positive."
    )
    assert(
        is_num(crossingClearance) && crossingClearance >= 0,
        "Knot ribbon crossing clearance must be nonnegative."
    )
    let(
        strandIndex = KnotCrossingBranchStrand(crossing, branch),
        parameter = KnotCrossingBranchParameter(crossing, branch),
        strand = KnotStrands(knot)[strandIndex],
        center3D = KnotStrandPointAtParameter(strand, parameter),
        tangent = KnotStrandTangentAtParameter(strand, parameter),
        span = KnotRibbonCrossingSpan(
            ribbonWidth,
            crossingClearance,
            expanded
        ),
        halfSpan = span / 2,
        start = KnotVectorSubtract(
            center3D,
            KnotVectorScale(tangent, halfSpan)
        ),
        end = KnotVectorAdd(
            center3D,
            KnotVectorScale(tangent, halfSpan)
        ),
        radius = ribbonWidth / 2
            + (expanded ? crossingClearance : 0)
    )
    KnotRibbonRectangleRegion(start, end, radius);

function KnotRibbonCrossingMaskRegions(
    knot,
    ribbonWidth = 2,
    crossingClearance = 0.6,
    arcFragments = 8,
    planarTolerance = 0.001) =
    assert(
        KnotIsPlanar(knot, planarTolerance),
        "Knot ribbon masks require a structurally valid planar knot."
    )
    assert(
        is_num(crossingClearance) && crossingClearance >= 0,
        "Knot ribbon crossing clearance must be nonnegative."
    )
[
    for (crossing = KnotCrossings(knot))
        KnotRibbonCrossingRegion(
            knot,
            crossing,
            KnotCrossingOverBranch(crossing),
            ribbonWidth,
            crossingClearance,
            arcFragments,
            true
        )
];

function KnotRibbonOverpassRegions(
    knot,
    ribbonWidth = 2,
    crossingClearance = 0.6,
    arcFragments = 8,
    planarTolerance = 0.001) =
    assert(
        KnotIsPlanar(knot, planarTolerance),
        "Knot ribbon overpasses require a structurally valid planar knot."
    )
[
    for (crossing = KnotCrossings(knot))
        KnotRibbonCrossingRegion(
            knot,
            crossing,
            KnotCrossingOverBranch(crossing),
            ribbonWidth,
            crossingClearance,
            arcFragments,
            false
        )
];

module RenderKnotRegionList(regions, convexity = 10)
{
    for (region = regions)
        RenderRegion2D(region, convexity);
}

// Render a planar interlace through LogoSC Core regions. The base ribbon is
// cut by an expanded flat-ended mask around each over branch, then a longer
// normal-width flat-ended overpass footprint is restored. Native
// difference/union performs only the final region composition.
module RenderKnotRibbons2D(
    knot,
    ribbonWidth = 2,
    crossingClearance = 0.6,
    arcFragments = 8,
    convexity = 10,
    planarTolerance = 0.001)
{
    ribbonRegions = KnotRibbonRegions(
        knot,
        ribbonWidth,
        arcFragments,
        planarTolerance
    );
    maskRegions = KnotRibbonCrossingMaskRegions(
        knot,
        ribbonWidth,
        crossingClearance,
        arcFragments,
        planarTolerance
    );
    overpassRegions = KnotRibbonOverpassRegions(
        knot,
        ribbonWidth,
        crossingClearance,
        arcFragments,
        planarTolerance
    );

    union()
    {
        difference()
        {
            union()
                RenderKnotRegionList(ribbonRegions, convexity);

            union()
                RenderKnotRegionList(maskRegions, convexity);
        }

        union()
            RenderKnotRegionList(overpassRegions, convexity);
    }
}

function KnotBasReliefTotalHeight(baseHeight, overpassHeight) =
    assert(
        is_num(baseHeight) && baseHeight > 0,
        "Knot bas-relief base height must be positive."
    )
    assert(
        is_num(overpassHeight) && overpassHeight > 0,
        "Knot bas-relief overpass height must be positive."
    )
    baseHeight + overpassHeight;

function KnotPlanarBounds(
    knot,
    padding = 0,
    planarTolerance = 0.001) =
    assert(
        KnotIsPlanar(knot, planarTolerance),
        "Knot planar bounds require a structurally valid planar knot."
    )
    assert(
        is_num(padding) && padding >= 0,
        "Knot planar bounds padding must be nonnegative."
    )
    let(
        points = [
            for (strand = KnotStrands(knot))
                for (sample = KnotStrandSamples(strand))
                    KnotRibbonPoint2D(sample)
        ],
        xValues = [for (point = points) point[0]],
        yValues = [for (point = points) point[1]]
    )
    [
        [min(xValues) - padding, min(yValues) - padding],
        [max(xValues) + padding, max(yValues) + padding]
    ];

function KnotReliefPlaqueBounds(
    knot,
    ribbonWidth = 2,
    plateMargin = 3,
    planarTolerance = 0.001) =
    assert(
        is_num(ribbonWidth) && ribbonWidth > 0,
        "Knot relief plaque ribbon width must be positive."
    )
    assert(
        is_num(plateMargin) && plateMargin >= 0,
        "Knot relief plaque margin must be nonnegative."
    )
    KnotPlanarBounds(
        knot,
        ribbonWidth / 2 + plateMargin,
        planarTolerance
    );

function KnotReliefPlaqueTotalHeight(
    plateThickness,
    baseHeight,
    overpassHeight) =
    assert(
        is_num(plateThickness) && plateThickness > 0,
        "Knot relief plaque thickness must be positive."
    )
    plateThickness + KnotBasReliefTotalHeight(baseHeight, overpassHeight);

module RenderKnotRoundedRectangle2D(
    bounds,
    cornerRadius,
    arcFragments = 8)
{
    lower = bounds[0];
    upper = bounds[1];
    width = upper[0] - lower[0];
    height = upper[1] - lower[1];

    assert(width > 0 && height > 0);
    assert(
        is_num(cornerRadius)
        && cornerRadius >= 0
        && 2 * cornerRadius < min(width, height),
        "Knot relief plaque corner radius must fit inside its bounds."
    );
    assert(
        is_num(arcFragments)
        && floor(arcFragments) == arcFragments
        && arcFragments >= 2,
        "Knot relief plaque arc fragments must be an integer of at least 2."
    );

    if (cornerRadius == 0)
    {
        translate(lower)
            square([width, height]);
    }
    else
    {
        translate([
            lower[0] + cornerRadius,
            lower[1] + cornerRadius
        ])
        offset(r = cornerRadius, $fn = 4 * arcFragments)
            square([
                width - 2 * cornerRadius,
                height - 2 * cornerRadius
            ]);
    }
}

module RenderKnotOptionalColor(colorValue = undef)
{
    if (is_undef(colorValue))
        children();
    else
        color(colorValue)
            children();
}

module RenderKnotBasRelief(
    knot,
    ribbonWidth = 2,
    crossingClearance = 0.6,
    baseHeight = 1.2,
    overpassHeight = 1,
    arcFragments = 8,
    convexity = 10,
    planarTolerance = 0.001)
{
    totalHeight = KnotBasReliefTotalHeight(baseHeight, overpassHeight);
    layerOverlap = min(0.01, baseHeight / 10);

    overpassRegions = KnotRibbonOverpassRegions(
        knot,
        ribbonWidth,
        crossingClearance,
        arcFragments,
        planarTolerance
    );

    union()
    {
        assert(totalHeight > baseHeight);

        linear_extrude(height = baseHeight, convexity = convexity)
            RenderKnotRibbons2D(
                knot,
                ribbonWidth,
                crossingClearance,
                arcFragments,
                convexity,
                planarTolerance
            );

        translate([0, 0, baseHeight - layerOverlap])
        linear_extrude(
            height = overpassHeight + layerOverlap,
            convexity = convexity
        )
            RenderKnotRegionList(overpassRegions, convexity);
    }
}

// Add a rounded rectangular backing plate beneath a bas-relief knot. The
// ribbon layer sinks slightly into the plate, while the externally requested
// plate, base, overpass, and total heights remain exact.
module RenderKnotBasReliefPlaque(
    knot,
    ribbonWidth = 2,
    crossingClearance = 0.6,
    plateThickness = 1.2,
    plateMargin = 3,
    plateCornerRadius = 3,
    baseHeight = 1.2,
    overpassHeight = 1,
    arcFragments = 8,
    convexity = 10,
    planarTolerance = 0.001,
    plateColor = undef,
    reliefColor = undef)
{
    plateBounds = KnotReliefPlaqueBounds(
        knot,
        ribbonWidth,
        plateMargin,
        planarTolerance
    );
    totalHeight = KnotReliefPlaqueTotalHeight(
        plateThickness,
        baseHeight,
        overpassHeight
    );
    plateOverlap = min(0.01, plateThickness / 10);

    union()
    {
        assert(totalHeight > plateThickness);

        RenderKnotOptionalColor(plateColor)
            linear_extrude(height = plateThickness, convexity = convexity)
                RenderKnotRoundedRectangle2D(
                    plateBounds,
                    plateCornerRadius,
                    arcFragments
                );

        RenderKnotOptionalColor(reliefColor)
            translate([0, 0, plateThickness - plateOverlap])
                RenderKnotBasRelief(
                    knot,
                    ribbonWidth,
                    crossingClearance,
                    baseHeight + plateOverlap,
                    overpassHeight,
                    arcFragments,
                    convexity,
                    planarTolerance
                );
    }
}

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
// lane through the existing capsule-cord path. Crossing-aware lanes inherit
// the master lift and are checked pairwise; explicit twist remains deferred.
module RenderKnotCordBundle(
    knot,
    cordCount = 3,
    cordRadius = 1,
    cordGap = 0.4,
    bundleWidth = undef,
    fragments = 24,
    validationTolerance = 0.001,
    minimumClearance = 0,
    checkCrossingClearance = true)
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
        bundleWidth,
        minimumClearance,
        checkCrossingClearance
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
