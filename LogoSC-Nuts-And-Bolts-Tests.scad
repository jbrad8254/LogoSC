// ============================================================================
// LogoSC-Nuts-And-Bolts-Tests.scad
//
// Passive, non-rendering tests for LogoSC-Nuts-And-Bolts.scad.
// Include Core and LogoSC-Foundation-Tests.scad, then use the fastener
// application before including this file. Run the tests through
// LogoSC-Nuts-And-Bolts-Test-Runner.scad.
// ============================================================================

function FastenerTestNearlyEqual(a, b, tolerance = 0.000001) =
    abs(a - b) <= tolerance;

function FastenerTestPointNearlyEqual(a, b, tolerance = 0.000001) =
    len(a) == 2
    && len(b) == 2
    && FastenerTestNearlyEqual(a[0], b[0], tolerance)
    && FastenerTestNearlyEqual(a[1], b[1], tolerance);

function FastenerTestPointsNearlyEqual(
    actual,
    expected,
    tolerance = 0.000001,
    index = 0) =
    len(actual) != len(expected)
        ? false
        : index >= len(actual)
            ? true
            : FastenerTestPointNearlyEqual(
                actual[index],
                expected[index],
                tolerance
            )
            && FastenerTestPointsNearlyEqual(
                actual,
                expected,
                tolerance,
                index + 1
            );

function FastenerTestNonEmptyContours(regions) =
[
    for (region = regions)
        if (len(RegionOuter(region)) >= 3)
            RegionOuter(region)
];

// [size, diameter, pitch, across-flats]
function FastenerPresetFixtures() =
[
    ["M3",       3,       0.5,       5.5],
    ["M4",       4,       0.7,       7],
    ["M5",       5,       0.8,       8],
    ["M6",       6,       1,         10],
    ["M8",       8,       1.25,      13],
    ["M10",      10,      1.5,       17],
    ["M12",      12,      1.75,      19],
    ["M14",      14,      2,         22],
    ["M16",      16,      2,         24],
    ["M18",      18,      2.5,       27],
    ["M20",      20,      2.5,       30],
    ["M22",      22,      2.5,       32],
    ["M24",      24,      3,         36],
    ["M27",      27,      3,         41],
    ["M30",      30,      3.5,       46],
    ["M33",      33,      3.5,       50],
    ["M36",      36,      4,         55],
    ["#8-32",    4.1656,  25.4 / 32, 8.7313],
    ["1/4-20",   6.35,    25.4 / 20, 11.1125],
    ["5/16-18",  7.9375,  25.4 / 18, 12.7],
    ["3/8-16",   9.525,   25.4 / 16, 14.2875],
    ["1/2-13",   12.7,    25.4 / 13, 19.05],
    ["5/8-11",   15.875,  25.4 / 11, 23.8125],
    ["3/4-10",   19.05,   25.4 / 10, 28.575],
    ["1-8",      25.4,    25.4 / 8,  38.1]
];

function FastenerPresetTestResults() =
[
    for (fixture = FastenerPresetFixtures())
        let(
            size = fixture[0],
            diameter = FastenerDiameter(size),
            pitch = FastenerPitch(size),
            acrossFlats = FastenerAcrossFlats(size, diameter),
            passed =
                FastenerTestNearlyEqual(diameter, fixture[1])
                && FastenerTestNearlyEqual(pitch, fixture[2])
                && FastenerTestNearlyEqual(acrossFlats, fixture[3])
                && diameter > 0
                && pitch > 0
                && pitch < diameter
                && acrossFlats > diameter
        )
        LogoTestResult(
            str("fastener preset ", size),
            passed,
            [
                "actual", [diameter, pitch, acrossFlats],
                "expected", [fixture[1], fixture[2], fixture[3]]
            ]
        )
];

// [profile, expected point count, expected depth ratio]
function FastenerProfileFixtures() =
[
    ["V60",          4,  0.61343],
    ["Whitworth55", 11,  0.640327],
    ["ACME29",       4,  0.5],
    ["Trapezoidal30",4,  0.5],
    ["Buttress7/45", 4,  0.6],
    ["Square",        4,  0.5]
];

function FastenerProfileTestResults(pitch = 2) =
[
    for (fixture = FastenerProfileFixtures())
        let(
            profile = fixture[0],
            points = FastenerProfilePoints(profile, pitch),
            depth = FastenerProfileDepth(profile, pitch),
            commands = FastenerLogoPath(points),
            result = evalLogo(commands),
            regions = ResultContours(result),
            contours = FastenerTestNonEmptyContours(regions),
            contour = contours[0]
        )
        LogoTestResult(
            str("fastener profile ", profile),
            len(points) == fixture[1]
            && FastenerTestNearlyEqual(depth, fixture[2] * pitch)
            && FastenerTestNearlyEqual(points[0][1], 0)
            && FastenerTestNearlyEqual(points[len(points) - 1][1], 0)
            && len(commands) == len(points) + 3
            && len(contours) == 1
            && len(contour) == len(points) + 1
            && FastenerTestPointNearlyEqual(contour[0], contour[len(contour) - 1]),
            [
                "points", points,
                "depth", depth,
                "commands", commands,
                "contour", contour
            ]
        )
];

function FastenerDimensionTestResults() =
[
    LogoTestResult(
        "fastener custom preset defaults",
        FastenerTestNearlyEqual(FastenerDiameter("Custom"), 8)
        && FastenerTestNearlyEqual(FastenerPitch("Custom"), 1.25)
        && FastenerTestNearlyEqual(FastenerAcrossFlats("Custom", 8), 12.8),
        [
            FastenerDiameter("Custom"),
            FastenerPitch("Custom"),
            FastenerAcrossFlats("Custom", 8)
        ]
    ),
    LogoTestResult(
        "fastener head heights",
        FastenerTestNearlyEqual(FastenerHeadHeight("Pan", 10), 5.5)
        && FastenerTestNearlyEqual(FastenerHeadHeight("Round", 10), 6.5)
        && FastenerTestNearlyEqual(
            FastenerHeadHeight("Countersunk Flat Head", 10),
            6
        )
        && FastenerTestNearlyEqual(FastenerHeadHeight("Carriage", 10), 5.5)
        && FastenerTestNearlyEqual(
            FastenerHeadHeight("Grub (Headless)", 10),
            0
        )
        && FastenerTestNearlyEqual(FastenerHeadHeight("Hex", 10), 6.5)
    ),
    LogoTestResult(
        "fastener nut automatic and explicit heights",
        FastenerTestNearlyEqual(FastenerNutHeight(10, 0), 8)
        && FastenerTestNearlyEqual(FastenerNutHeight(10, 6), 6)
    ),
    LogoTestResult(
        "fastener handedness signs",
        FastenerTwistDirection("Right") == -1
        && FastenerTwistDirection("Left") == 1
    )
];

function FastenerDriveTestResults() =
[
    LogoTestResult(
        "fastener automatic drive thresholds",
        [
            for (diameter = [2.5, 2.6, 4, 4.1, 7, 7.1, 10, 10.1, 14, 14.1])
                FastenerAutoDriveIndex(diameter)
        ] == [0, 1, 1, 2, 2, 3, 3, 4, 4, 5]
    ),
    LogoTestResult(
        "fastener explicit drive indexes",
        [
            for (driveSize = ["#0", "#1", "#2", "#3", "#4", "#5"])
                FastenerDriveIndex(driveSize, 8)
        ] == [0, 1, 2, 3, 4, 5]
    ),
    LogoTestResult(
        "fastener automatic drive dimensions",
        FastenerTestNearlyEqual(FastenerPhillipsSpan("Auto", 8), 6)
        && FastenerTestNearlyEqual(FastenerSlotWidth("Auto", 8), 1.2)
        && FastenerTestNearlyEqual(
            FastenerHexSocketAcrossFlats("Auto", 8),
            4
        )
    ),
    LogoTestResult(
        "fastener custom drive dimensions",
        FastenerTestNearlyEqual(FastenerPhillipsSpan("Custom", 8, 3.25), 3.25)
        && FastenerTestNearlyEqual(FastenerSlotWidth("Custom", 8, 3.25), 3.25)
        && FastenerTestNearlyEqual(
            FastenerHexSocketAcrossFlats("Custom", 8, 3.25),
            3.25
        )
    )
];

function FastenerAlgorithmTestResults() =
let(
    pitch = 3,
    starts = 3,
    lead = pitch * starts,
    profilePoints = FastenerProfilePoints("V60", pitch),
    profileCommands = FastenerLogoPath(profilePoints),
    profileResult = evalLogo(profileCommands),
    contours = FastenerTestNonEmptyContours(ResultContours(profileResult)),
    contour = contours[0],
    sampledContour = FastenerResampleContour(contour, lead),
    documentedSampledContour = FastenerResampleContour(contour, lead, 48),
    coreRadius = 10,
    rightQuarter = FastenerWrapPoint([lead / 4, 0], coreRadius, lead, -1),
    leftQuarter = FastenerWrapPoint([lead / 4, 0], coreRadius, lead, 1)
)
[
    LogoTestResult(
        "fastener documented V60 contour count",
        len(contour) == 5,
        contour
    ),
    LogoTestResult(
        "fastener default V60 resampling count",
        len(sampledContour) == 15,
        sampledContour
    ),
    LogoTestResult(
        "fastener documented V60 resampling count",
        len(documentedSampledContour) == 28,
        documentedSampledContour
    ),
    LogoTestResult(
        "fastener resampling keeps unique cyclic points",
        !FastenerSamePoint(
            sampledContour[0],
            sampledContour[len(sampledContour) - 1]
        ),
        [sampledContour[0], sampledContour[len(sampledContour) - 1]]
    ),
    LogoTestResult(
        "fastener segment sampling axial and radial weights",
        FastenerProfileSegmentSamples([0, 0], [lead, 0], lead) == 25
        && FastenerProfileSegmentSamples([0, 0], [0, 2 * lead], lead) == 25
        && FastenerProfileSegmentSamples([0, 0], [0, 0], lead) == 1
    ),
    LogoTestResult(
        "fastener wrap preserves radial height",
        FastenerTestPointNearlyEqual(
            FastenerWrapPoint([0, 2], coreRadius, lead, -1),
            [12, 0]
        )
    ),
    LogoTestResult(
        "fastener right-hand quarter-turn phase",
        FastenerTestPointNearlyEqual(rightQuarter, [0, -coreRadius]),
        rightQuarter
    ),
    LogoTestResult(
        "fastener left-hand quarter-turn phase",
        FastenerTestPointNearlyEqual(leftQuarter, [0, coreRadius]),
        leftQuarter
    ),
    LogoTestResult(
        "fastener multi-start phase offsets",
        [
            for (startIndex = [0 : starts - 1])
                startIndex * 360 / starts
        ] == [0, 120, 240]
    )
];

function LogoFastenerAutomatedTestResults() =
concat(
    FastenerPresetTestResults(),
    FastenerDimensionTestResults(),
    FastenerDriveTestResults(),
    FastenerProfileTestResults(),
    FastenerAlgorithmTestResults()
);

function LogoFastenerTestSuiteResult() =
    LogoTestSuiteResult("Fasteners", LogoFastenerAutomatedTestResults());

module RunAllLogoFastenerTests()
{
    ReportLogoTestRun([LogoFastenerTestSuiteResult()]);
}
