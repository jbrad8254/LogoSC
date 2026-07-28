// ============================================================================
// LogoSC Knots - optional sampled-knot companion
//
// This file is independent of LogoSC Core. It does not call evalLogo() or emit
// LogoSC command lists. Pure OpenSCAD functions define and validate sampled
// knot records; native OpenSCAD sphere/hull geometry produces diagnostics and
// manufacturable rounded cords. Future planar motif and ribbon stages may
// consume LogoSC Core without making this 3D companion a Core dependency.
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
// overStrand must equal strandA or strandB.
function MakeKnotCrossing(
    point2D,
    strandA,
    parameterA,
    strandB,
    parameterB,
    overStrand) =
[
    point2D,
    strandA,
    parameterA,
    strandB,
    parameterB,
    overStrand
];

function KnotCrossingPoint(crossing) = crossing[KNOT_CROSSING_POINT];
function KnotCrossingStrandA(crossing) = crossing[KNOT_CROSSING_STRAND_A];
function KnotCrossingParameterA(crossing) = crossing[KNOT_CROSSING_PARAMETER_A];
function KnotCrossingStrandB(crossing) = crossing[KNOT_CROSSING_STRAND_B];
function KnotCrossingParameterB(crossing) = crossing[KNOT_CROSSING_PARAMETER_B];
function KnotCrossingOverStrand(crossing) = crossing[KNOT_CROSSING_OVER_STRAND];

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
        overStrand = KnotCrossingOverStrand(crossing)
    )
    concat(
        strandA < 0
        || floor(strandA) != strandA
        || strandA >= strandCount
        || strandB < 0
        || floor(strandB) != strandB
        || strandB >= strandCount
        || strandA == strandB
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

function KnotDebugViewPoint(point, viewMode) =
    assert(
        viewMode == "Planar" || viewMode == "Spatial",
        "Knot debug view mode must be Planar or Spatial."
    )
    viewMode == "Planar"
    ? [point[0], point[1], 0]
    : point;

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
                    KnotDebugViewPoint(samples[sampleIndex], viewMode),
                    KnotDebugViewPoint(samples[sampleIndex + 1], viewMode),
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
                translate(KnotDebugViewPoint(samples[sampleIndex], viewMode))
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
