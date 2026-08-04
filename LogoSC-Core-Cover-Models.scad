// ============================================================================
// LogoSC-Core-Cover-Models.scad
//
// Printable LogoSC interpretations of the eight figures in the AI-generated
// LogoSC Core Thingiverse cover. The image is promotional artwork, so these
// models use deliberate dimensions rather than inferred measurements.
// ============================================================================

include <LogoSC-Foundation-Core.scad>
TraceLevel = 0;

/* [Model] */

CoverModel = "FeaturePanel"; // [All,FeaturePanel,RadialPaddleFan,KochCutoutPlate,PeanoCurve,AstroidSculpture,SlottedLink,PerforatedRing,CurvyWireSpool]

/* [Print] */

ModelHeight = 4; // [1:0.5:12]
CurveSegments = 32; // [12:4:96]
KochDepth = 2; // [0:1:3]
PeanoDepth = 2; // [1:1:3]
PeanoCurveWidth = 2.5; // [1:0.5:8]
AstroidHeight = 18; // [4:1:40]
AstroidTopScale = 0.28; // [0.1:0.05:1]
AstroidTwist = 0; // [-90:5:90]
SpoolHoleCount = 12; // [6:1:24]
SpoolHoleRadius = 2.2; // [1:0.2:4]

// Return one LogoSC hole command containing a centered circle at x/y.
function CircleHole(x, y, radius) =
[
    HOLE,
    [
        [GOTO, x, y, 0],
        [CIRCLE, radius, CurveSegments]
    ]
];

// Return one LogoSC hole command containing a centered rectangle at x/y.
function RectHole(x, y, width, height) =
[
    HOLE,
    [
        [GOTO, x, y, 0],
        [RECT, width, height]
    ]
];

// Recursive Koch segment generator copied from the canonical Core examples.
function KochSegment(depth, length) =
    depth <= 0
        ? [[MOVE, length]]
        : concat(
            KochSegment(depth - 1, length / 3),
            [[TURN, 60]],
            KochSegment(depth - 1, length / 3),
            [[TURN, -120]],
            KochSegment(depth - 1, length / 3),
            [[TURN, 60]],
            KochSegment(depth - 1, length / 3)
        );

// Build a centered, downward-pointing Koch snowflake command list.
function KochSnowflake(x, y, side, depth) =
    let(height = side * sqrt(3) / 2)
    concat(
        [[GOTO, x - side / 2, y + height / 3, 0]],
        KochSegment(depth, side),
        [[TURN, -120]],
        KochSegment(depth, side),
        [[TURN, -120]],
        KochSegment(depth, side),
        [[TURN, -120]]
    );

// Signed integer power used to sample the concave-sided astroid outline.
function SignedPower(value, exponent) =
    (value < 0 ? -1 : 1) * pow(abs(value), exponent);

// Sample x=a*cos(t)^3, y=a*sin(t)^3 into an explicitly closed LogoSC path.
function AstroidCommands(radius, samples) =
[
    for (index = [0 : samples])
        let(angle = 360 * index / samples)
        [
            GOTO,
            radius * SignedPower(cos(angle), 3),
            radius * SignedPower(sin(angle), 3),
            0
        ]
];

featurePanel = concat(
    [[ROUNDEDRECT, 95, 68, 8, CurveSegments]],
    [
        CircleHole(-40, -27, 2.8),
        CircleHole(40, -27, 2.8),
        CircleHole(-40, 27, 2.8),
        CircleHole(40, 27, 2.8),
        CircleHole(-33, 7, 9),
        CircleHole(10, 8, 6),
        CircleHole(34, 16, 6),
        CircleHole(4, -17, 10),
        RectHole(34, -16, 8, 8)
    ]
);

kochCutoutPlate = concat(
    [[ROUNDEDRECT, 70, 55, 7, CurveSegments]],
    [
        CircleHole(-27, -20, 2.8),
        CircleHole(27, -20, 2.8),
        CircleHole(-27, 20, 2.8),
        CircleHole(27, 20, 2.8),
        [HOLE, KochSnowflake(0, 0, 25, KochDepth)]
    ]
);

PEANO_L = 200 + 0;
PEANO_R = 201 + 0;
PEANO_F = 202 + 0;
PEANO_PLUS = 203 + 0;
PEANO_MINUS = 204 + 0;

function PeanoRule(symbol) =
    symbol == PEANO_L
        ? [
            PEANO_L, PEANO_F, PEANO_R, PEANO_F, PEANO_L,
            PEANO_MINUS, PEANO_F, PEANO_MINUS,
            PEANO_R, PEANO_F, PEANO_L, PEANO_F, PEANO_R,
            PEANO_PLUS, PEANO_F, PEANO_PLUS,
            PEANO_L, PEANO_F, PEANO_R, PEANO_F, PEANO_L
        ]
        : symbol == PEANO_R
            ? [
                PEANO_R, PEANO_F, PEANO_L, PEANO_F, PEANO_R,
                PEANO_PLUS, PEANO_F, PEANO_PLUS,
                PEANO_L, PEANO_F, PEANO_R, PEANO_F, PEANO_L,
                PEANO_MINUS, PEANO_F, PEANO_MINUS,
                PEANO_R, PEANO_F, PEANO_L, PEANO_F, PEANO_R
            ]
            : [symbol];

function PeanoRewrite(symbols, index = 0) =
    index >= len(symbols)
        ? []
        : concat(PeanoRule(symbols[index]), PeanoRewrite(symbols, index + 1));

function PeanoExpand(symbols, depth) =
    depth <= 0 ? symbols : PeanoExpand(PeanoRewrite(symbols), depth - 1);

function PeanoSymbolCommands(symbol, step) =
    symbol == PEANO_F ? [[MOVE, step]]
    : symbol == PEANO_PLUS ? [[TURN, 90]]
    : symbol == PEANO_MINUS ? [[TURN, -90]]
    : [];

function PeanoCommands(symbols, step, index = 0) =
    index >= len(symbols)
        ? []
        : concat(
            PeanoSymbolCommands(symbols[index], step),
            PeanoCommands(symbols, step, index + 1)
        );

function PrintablePeanoCommands(size, depth) =
    let(
        symbols = PeanoExpand([PEANO_L], depth),
        step = size / (pow(3, depth) - 1)
    )
    concat(
        [[PENUP], [GOTO, -size / 2, -size / 2, 0], [PENDOWN]],
        PeanoCommands(symbols, step)
    );

peanoCurveCommands = PrintablePeanoCommands(51, PeanoDepth);

astroidSculpture = AstroidCommands(31, CurveSegments * 2);

slottedLink =
[
    [ROUNDEDRECT, 65, 16, 8, CurveSegments],
    [HOLE, [[ROUNDEDRECT, 49, 5, 2.5, CurveSegments]]]
];

perforatedRing = concat(
    [
        [CIRCLE, 28, CurveSegments],
        CircleHole(0, 0, 12)
    ],
    [
        for (angle = [0 : 30 : 330])
            CircleHole(21 * cos(angle), 21 * sin(angle), 2)
    ]
);

// Sample one gently curved flange shoulder in the radial/profile plane.
function SpoolShoulderPoints(top, samples = 12) =
[
    for (index = [1 : samples])
        let(
            amount = index / samples,
            radius = top ? 11 + 17 * amount : 28 - 17 * amount,
            z = top
                ? 15 - 4 * amount * amount
                : -11 - 4 * amount * amount
        )
        [radius, z]
];

// Pull the outside wall deeply inward between the flanges for a C-shaped
// radial section rather than the D-shaped section made by a straight wall.
function SpoolOuterWaistPoints(samples = 16) =
[
    for (index = [1 : samples])
        let(
            amount = index / samples,
            centered = 2 * amount - 1,
            radius = 15 + 13 * centered * centered,
            z = 11 - 22 * amount
        )
        [radius, z]
];

spoolProfilePoints = concat(
    [[11, -15], [11, 15]],
    SpoolShoulderPoints(true),
    SpoolOuterWaistPoints(),
    SpoolShoulderPoints(false)
);

spoolProfile =
[
    for (point = spoolProfilePoints)
        [GOTO, point[0], point[1], 0]
];

// One tapered fan paddle centered on the origin and pointing along +X.
fanPaddle =
[
    [GOTO, -14, -4, 0],
    [GOTO, 14, -7, 0],
    [GOTO, 14, 7, 0],
    [GOTO, -14, 4, 0],
    [GOTO, -14, -4, 0]
];

function CoverCommands(model) =
    model == "FeaturePanel" ? featurePanel
    : model == "KochCutoutPlate" ? kochCutoutPlate
    : model == "AstroidSculpture" ? astroidSculpture
    : model == "SlottedLink" ? slottedLink
    : model == "PerforatedRing" ? perforatedRing
    : assert(false, str("Unknown Core cover model: ", model));

allModelLayout =
[
    ["FeaturePanel", -55, 70],
    ["RadialPaddleFan", 55, 70],
    ["KochCutoutPlate", -75, -18],
    ["PeanoCurve", 5, -18],
    ["PerforatedRing", 80, -18],
    ["AstroidSculpture", -73, -88],
    ["SlottedLink", 0, -88],
    ["CurvyWireSpool", 75, -88]
];

assert(ModelHeight > 0, "ModelHeight must be positive.");
assert(CurveSegments >= 12, "CurveSegments must be at least 12.");
assert(KochDepth >= 0 && KochDepth <= 3, "KochDepth must be from 0 through 3.");
assert(PeanoDepth >= 1 && PeanoDepth <= 3, "PeanoDepth must be from 1 through 3.");
assert(PeanoCurveWidth > 0, "PeanoCurveWidth must be positive.");
assert(AstroidHeight > 0, "AstroidHeight must be positive.");
assert(AstroidTopScale > 0, "AstroidTopScale must be positive.");
assert(SpoolHoleCount >= 1, "SpoolHoleCount must be at least 1.");
assert(SpoolHoleRadius > 0, "SpoolHoleRadius must be positive.");

// Render one six-lobed cutter made from overlapping LogoSC circles.
module RenderFlowerCutter2D(radius = 6.5)
{
    RenderLogo2D([[CIRCLE, radius * 0.48, CurveSegments]]);

    for (angle = [0 : 60 : 300])
    {
        rotate(angle)
        translate([radius * 0.62, 0])
        RenderLogo2D([[CIRCLE, radius * 0.42, CurveSegments]]);
    }
}

// Render the panel and subtract the cover image's scalloped flower holes.
module RenderFeaturePanel()
{
    difference()
    {
        linear_extrude(height = ModelHeight, convexity = 10)
        {
            RenderLogo2D(featurePanel);
        }

        for (position = [[-14, 7], [-8, 25], [27, -2], [-28, -19]])
        {
            translate([position[0], position[1], -0.01])
            linear_extrude(height = ModelHeight + 0.02, convexity = 10)
            {
                RenderFlowerCutter2D();
            }
        }
    }
}

// Turn the evaluated open Peano path into a printable union of round-ended
// segment capsules. This is specialized example geometry, not a Core stroke API.
module RenderPeanoCurve2D()
{
    debugResult = evalLogoDebug(peanoCurveCommands);
    segments = ResultDebugSegments(debugResult);
    points = ResultDebugPoints(debugResult);
    minX = min([for (point = points) point[0]]);
    maxX = max([for (point = points) point[0]]);
    minY = min([for (point = points) point[1]]);
    maxY = max([for (point = points) point[1]]);
    center = [(minX + maxX) / 2, (minY + maxY) / 2];

    for (segment = segments)
    {
        if (segment[DS_PEN] == PEN_DOWN)
        {
            hull()
            {
                translate(segment[DS_FROM] - center)
                RenderLogo2D([[CIRCLE, PeanoCurveWidth / 2, CurveSegments]]);

                translate(segment[DS_TO] - center)
                RenderLogo2D([[CIRCLE, PeanoCurveWidth / 2, CurveSegments]]);
            }
        }
    }
}

// Render one printable radial fan with twelve independent LogoSC paddles.
module RenderRadialPaddleFan()
{
    linear_extrude(height = ModelHeight, convexity = 10)
    {
        RenderLogo2D(
            [
                [CIRCLE, 17, CurveSegments],
                CircleHole(0, 0, 7)
            ]
        );
    }

    for (angle = [0 : 30 : 330])
    {
        rotate(angle)
        translate([29, 0, 0])
        difference()
        {
            linear_extrude(height = ModelHeight, convexity = 10)
            {
                RenderLogo2D(fanPaddle);
            }

            translate([9, 0, -0.01])
            linear_extrude(height = ModelHeight + 0.02, convexity = 10)
            {
                RenderLogo2D([[CIRCLE, 2.5, CurveSegments]]);
            }
        }
    }
}

// Revolve the LogoSC R/Z profile and drill aligned holes through both flanges.
module RenderCurvyWireSpool()
{
    translate([0, 0, 15])
    difference()
    {
        rotate_extrude(
            angle = 360,
            convexity = 10,
            $fn = max(48, CurveSegments * 2)
        )
        {
            RenderLogo2D(spoolProfile);
        }

        for (angle = [0 : 360 / SpoolHoleCount : 360 - 360 / SpoolHoleCount])
        {
            rotate(angle)
            translate([22, 0, -18])
            cylinder(
                h = 36,
                r = SpoolHoleRadius,
                $fn = max(16, CurveSegments)
            );
        }
    }
}

// Render one named cover model at the origin.
module RenderCoreCoverModel(model)
{
    if (model == "FeaturePanel")
    {
        RenderFeaturePanel();
    }
    else if (model == "RadialPaddleFan")
    {
        RenderRadialPaddleFan();
    }
    else if (model == "PeanoCurve")
    {
        linear_extrude(height = ModelHeight, convexity = 10)
        {
            RenderPeanoCurve2D();
        }
    }
    else if (model == "AstroidSculpture")
    {
        difference()
        {
            linear_extrude(
                height = AstroidHeight,
                scale = AstroidTopScale,
                twist = AstroidTwist,
                slices = max(16, CurveSegments),
                convexity = 10
            )
            {
                RenderLogo2D(astroidSculpture);
            }

            translate([0, 0, -0.01])
            linear_extrude(
                height = AstroidHeight + 0.02,
                scale = AstroidTopScale,
                slices = max(16, CurveSegments),
                convexity = 10
            )
            {
                RenderLogo2D([[ROUNDEDRECT, 19.5, 6, 3, CurveSegments]]);
            }
        }
    }
    else if (model == "CurvyWireSpool")
    {
        RenderCurvyWireSpool();
    }
    else
    {
        linear_extrude(height = ModelHeight, convexity = 10)
        {
            RenderLogo2D(CoverCommands(model));
        }
    }
}

if (CoverModel == "All")
{
    for (entry = allModelLayout)
    {
        translate([entry[1], entry[2], 0])
        render(convexity = 10)
        RenderCoreCoverModel(entry[0]);
    }
}
else
{
    RenderCoreCoverModel(CoverModel);
}
