// ============================================================================
// LogoSC-Mini-Cover-Models.scad
//
// Printable LogoSC interpretations of the eight figures in the AI-generated
// LogoSC Mini Thingiverse cover. The cover is promotional artwork, so these
// models use deliberate, printable dimensions rather than inferred dimensions.
// ============================================================================

include <LogoSC-Foundation-Core.scad>
TraceLevel = 0;

/* [Model] */

CoverModel = "RoundedMountingPlate"; // [All,RoundedMountingPlate,TrianglePlaque,PerforatedRing,EightPetalFlower,PlainWasher,EightLobedRotor,CapsuleToken,ThickWasher]

/* [Print] */

ModelHeight = 4; // [1:0.5:12]
CurveSegments = 32; // [12:4:96]

/* [Optional flower detail] */

FlowerCenterRecess = true;
FlowerRecessDepth = 0.6; // [0.2:0.1:2]

// Return one LogoSC circle-hole command centered at x/y.
function CircleHole(x, y, radius) =
[
    HOLE,
    [
        [GOTO, x, y, 0],
        [CIRCLE, radius, CurveSegments]
    ]
];

// Rounded 70 x 54 mm plate with four mounting holes and one center opening.
roundedMountingPlate = concat(
    [[ROUNDEDRECT, 70, 54, 6, CurveSegments]],
    [
        CircleHole(-27, -19, 3),
        CircleHole(27, -19, 3),
        CircleHole(-27, 19, 3),
        CircleHole(27, 19, 3),
        CircleHole(0, 0, 8)
    ]
);

// Equilateral triangle with a 58 mm side, centered around the origin.
triangleHeight = 58 * sqrt(3) / 2;
trianglePlaque =
[
    [GOTO, -29, -triangleHeight / 3, 0],
    [MOVE, 58],
    [TURN, 120],
    [MOVE, 58],
    [TURN, 120],
    [MOVE, 58]
];

// Large ring with twelve evenly spaced ventilation or lacing holes.
perforatedRing = concat(
    [
        [CIRCLE, 30, CurveSegments],
        CircleHole(0, 0, 11)
    ],
    [
        for (angle = [0 : 30 : 330])
            CircleHole(21 * cos(angle), 21 * sin(angle), 2.6)
    ]
);

// Native OpenSCAD places the repeated LogoSC lobe regions around this center.
eightPetalFlower = [[CIRCLE, 11, CurveSegments]];

plainWasher =
[
    [CIRCLE, 20, CurveSegments],
    CircleHole(0, 0, 8)
];

eightLobedRotor = [[CIRCLE, 11, CurveSegments]];

capsuleToken =
[
    [ROUNDEDRECT, 42, 18, 9, CurveSegments]
];

thickWasher =
[
    [CIRCLE, 22, CurveSegments],
    CircleHole(0, 0, 7)
];

function CoverCommands(model) =
    model == "RoundedMountingPlate" ? roundedMountingPlate
    : model == "TrianglePlaque" ? trianglePlaque
    : model == "PerforatedRing" ? perforatedRing
    : model == "EightPetalFlower" ? eightPetalFlower
    : model == "PlainWasher" ? plainWasher
    : model == "EightLobedRotor" ? eightLobedRotor
    : model == "CapsuleToken" ? capsuleToken
    : model == "ThickWasher" ? thickWasher
    : assert(false, str("Unknown cover model: ", model));

allModelLayout =
[
    ["RoundedMountingPlate", -75, 65],
    ["TrianglePlaque", 0, 65],
    ["PerforatedRing", 75, 65],
    ["EightPetalFlower", -75, 0],
    ["EightLobedRotor", 0, 0],
    ["CapsuleToken", 75, 0],
    ["PlainWasher", -37, -65],
    ["ThickWasher", 37, -65]
];

assert(ModelHeight > 0, "ModelHeight must be positive.");
assert(CurveSegments >= 3, "CurveSegments must be at least 3.");
assert(FlowerRecessDepth >= 0, "FlowerRecessDepth must not be negative.");
assert(
    !FlowerCenterRecess || FlowerRecessDepth < ModelHeight,
    "FlowerRecessDepth must be less than the model height."
);

// Render the selected LogoSC regions. OpenSCAD handles repeated placement and
// union, consistent with LogoSC's boundary as a 2D region generator.
module RenderModelLogo2D(model, commands)
{
    RenderLogo2D(commands);

    if (model == "EightPetalFlower")
    {
        for (angle = [0 : 45 : 315])
        {
            rotate(angle)
            translate([14, 0])
            RenderLogo2D([[ROUNDEDRECT, 26, 11, 5.5, CurveSegments]]);
        }
    }

    if (model == "EightLobedRotor")
    {
        for (angle = [0 : 45 : 315])
        {
            rotate(angle)
            translate([12, 0])
            RenderLogo2D([[ROUNDEDRECT, 22, 10, 5, CurveSegments]]);
        }
    }
}

// Extrude one selected model and apply its optional top or through details.
module RenderCoverModel(model)
{
    commands = CoverCommands(model);
    height = model == "ThickWasher" ? ModelHeight * 1.5 : ModelHeight;

    difference()
    {
        linear_extrude(height = height, convexity = 10)
        {
            RenderModelLogo2D(model, commands);
        }

        if (model == "EightPetalFlower" && FlowerCenterRecess)
        {
            translate([0, 0, height - FlowerRecessDepth])
            linear_extrude(height = FlowerRecessDepth + 0.01, convexity = 10)
            {
                RenderLogo2D([[CIRCLE, 7, CurveSegments]]);
            }
        }

        if (model == "EightLobedRotor")
        {
            translate([0, 0, -0.01])
            linear_extrude(height = height + 0.02, convexity = 10)
            {
                RenderLogo2D([[CIRCLE, 4.5, CurveSegments]]);
            }
        }
    }
}

if (CoverModel == "All")
{
    for (entry = allModelLayout)
    {
        translate([entry[1], entry[2], 0])
        RenderCoverModel(entry[0]);
    }
}
else
{
    RenderCoverModel(CoverModel);
}
