// Customizer examples for the optional LogoSC L-system companion.
//
// The Gallery is a centered 3-by-3 comparison:
//   Koch, Quadratic Koch, Sierpinski
//   Hilbert, Dragon, Levy C
//   Gosper, Plant, Canopy
//
// LogoSC-LSystems-Guide.md tabulates each axiom, compact rewrite rules, turn
// angle, and the idea that makes the example distinct.

include <LogoSC-Foundation-Core.scad>
include <LogoSC-LSystems.scad>

TraceLevel = 0;

/* [Scene] */

LSystemExample = "Gallery"; // [Gallery,Koch,QuadraticKoch,Hilbert,Dragon,Sierpinski,Plant,Levy C,Gosper,Canopy]

/* [Grammar] */

LSystemDepth = 3; // [0:1:5]
LSystemSize = 48; // [10:1:120]

/* [Seeded Angle Variation] */

// Closed examples remain exact so their filled polygons still close.
LSystemAngleVariationScope = "Branching Only"; // [Off,Branching Only,All Open Curves]
// Each turn uses base angle +/- this many degrees.
LSystemAngleVariation = 10; // [0:1:30]
// The same seed reproduces the same model.
LSystemRandomSeed = 1; // [0:1:10000]

/* [Filled Output] */

LSystemHeight = 3; // [0.5:0.5:12]
// Enlarge Sierpinski triangles so point contacts become printable overlaps.
SierpinskiOverlapPercent = 10; // [0:1:30]

/* [Printable Open-Curve Output] */

LSystemStrokeWidth = 1.2; // [0.4:0.1:5]
HilbertDragonWidthScale = 1.5; // [1:0.1:3]
PlantTrunkWidthScale = 10; // [1:0.5:12]
// F -> FF halves each new level; 1.5 compensation makes the net scale 3/4.
PlantBranchStepCompensation = 1.5;
// Compact the overall model without changing its printable stroke widths.
PlantLowerLevelLengthScale = 0.5;
PlantOverallLengthScale = 0.7;
LSystemStrokeFragments = 20; // [8:1:64]

function LSystemExampleIsClosed(name) =
    name == "Koch"
    || name == "Quadratic Koch"
    || name == "Sierpinski";

function LSystemExamplePresetName(name) =
    name == "QuadraticKoch" ? "Quadratic Koch"
    : name == "LevyC" ? "Levy C"
    : name;

function LSystemExampleHeading(name) =
    name == "Plant" || name == "Canopy" ? 90 : 0;

function LSystemExampleAngleVariation(name) =
    LSystemAngleVariationScope == "All Open Curves"
        ? LSystemAngleVariation
        : LSystemAngleVariationScope == "Branching Only"
            && (name == "Plant" || name == "Canopy")
            ? LSystemAngleVariation
            : 0;

function LSystemTurnJitter(variation, symbolIndex) =
    variation <= 0
        ? 0
        : rands(
            -variation,
            variation,
            1,
            LSystemRandomSeed + symbolIndex
        )[0];

function LSystemExampleDepth(name, requestedDepth) =
    name == "Plant" ? min(requestedDepth + 1, 4)
    : name == "Dragon" ? min(requestedDepth + 2, 10)
    : name == "Levy C" ? min(requestedDepth, 8)
    : name == "Gosper" ? min(requestedDepth, 4)
    : name == "Canopy" ? min(requestedDepth, 6)
    : min(requestedDepth, 5);

// Offset needed to increase an equilateral triangle's side by the requested
// percentage: newSide = side + 2 * sqrt(3) * offset.
function SierpinskiOverlapOffset(depth, size, percent) =
    LSystemStep(MakeSierpinskiLSystem(), size, depth)
    * percent / 100
    / (2 * sqrt(3));

function LSystemPlacedCommands(name, depth, size) =
    concat(
        [
            [PENUP],
            [GOTO, 0, 0, LSystemExampleHeading(name)],
            [PENDOWN]
        ],
        LSystemCommands(
            LSystemPreset(name),
            depth,
            size
        )
    );

function LSystemExampleBounds(commands) =
    let(points = ResultDebugPoints(evalLogoDebug(commands)))
    len(points) == 0
        ? [[0, 0], [0, 0]]
        : [
            [
                min([for (point = points) point[0]]),
                min([for (point = points) point[1]])
            ],
            [
                max([for (point = points) point[0]]),
                max([for (point = points) point[1]])
            ]
        ];

// Companion-example stroke evaluator result: [state, stack, branchLevel, segments].
// Each segment is [fromPoint, toPoint, branchLevel]. This deliberately remains
// example-owned rather than becoming a general Core stroke API.
function LSystemStrokeEval(
    symbols,
    index,
    step,
    angle,
    angleVariation,
    branchStepCompensation,
    lowerLevelLengthScale,
    gScale,
    state,
    stack = [],
    branchLevel = 0,
    segments = []) =
    index >= len(symbols)
        ? [state, stack, branchLevel, segments]
        : let(symbol = symbols[index])
        (symbol == LSYS_F || symbol == LSYS_G)
            ? let(
                // Plant uses G as a printable half-step arm segment.
                symbolScale = symbol == LSYS_G ? gScale : 1,
                lowerLevelScale = branchLevel <= 1
                    ? lowerLevelLengthScale
                    : 1,
                nextState = stateMove(
                    state,
                    step
                        * symbolScale
                        * lowerLevelScale
                        * pow(branchStepCompensation, branchLevel)
                ),
                segment = [
                    [state[SX], state[SY]],
                    [nextState[SX], nextState[SY]],
                    branchLevel
                ]
            )
            LSystemStrokeEval(
                symbols, index + 1, step, angle,
                angleVariation,
                branchStepCompensation, lowerLevelLengthScale, gScale, nextState,
                stack, branchLevel, concat(segments, [segment])
            )
            : symbol == LSYS_f
                ? LSystemStrokeEval(
                    symbols, index + 1, step, angle,
                    angleVariation,
                    branchStepCompensation, lowerLevelLengthScale, gScale,
                    stateMove(
                        state,
                        step
                            * (branchLevel <= 1 ? lowerLevelLengthScale : 1)
                            * pow(branchStepCompensation, branchLevel)
                    ),
                    stack, branchLevel, segments
                )
                : symbol == LSYS_PLUS
                    ? let(turn = angle + LSystemTurnJitter(angleVariation, index))
                    LSystemStrokeEval(
                        symbols, index + 1, step, angle,
                        angleVariation,
                        branchStepCompensation, lowerLevelLengthScale, gScale,
                        stateTurn(state, turn),
                        stack, branchLevel, segments
                    )
                    : symbol == LSYS_MINUS
                        ? let(turn = angle + LSystemTurnJitter(angleVariation, index))
                        LSystemStrokeEval(
                            symbols, index + 1, step, angle,
                            angleVariation,
                            branchStepCompensation, lowerLevelLengthScale, gScale,
                            stateTurn(state, -turn),
                            stack, branchLevel, segments
                        )
                        : symbol == LSYS_PUSH
                            ? LSystemStrokeEval(
                                symbols, index + 1, step, angle,
                                angleVariation,
                                branchStepCompensation, lowerLevelLengthScale, gScale, state,
                                concat(stack, [[state, branchLevel]]),
                                branchLevel + 1,
                                segments
                            )
                            : symbol == LSYS_POP && len(stack) > 0
                                ? let(saved = stack[len(stack) - 1])
                                LSystemStrokeEval(
                                    symbols, index + 1, step, angle,
                                    angleVariation,
                                    branchStepCompensation, lowerLevelLengthScale,
                                    gScale, saved[0],
                                    len(stack) <= 1
                                        ? []
                                        : [for (i = [0 : len(stack) - 2]) stack[i]],
                                    saved[1],
                                    segments
                                )
                                : LSystemStrokeEval(
                                    symbols, index + 1, step, angle,
                                    angleVariation,
                                    branchStepCompensation, lowerLevelLengthScale,
                                    gScale, state,
                                    stack, branchLevel, segments
                                );

function LSystemStrokeSegments(name, depth, size) =
    let(
        system = LSystemPreset(name),
        symbols = LSystemExpand(system, depth),
        step = LSystemStep(system, size, depth)
            * (name == "Plant" ? PlantOverallLengthScale : 1),
        initialState = stateGoto(0, 0, LSystemExampleHeading(name), 1),
        result = LSystemStrokeEval(
            symbols, 0, step, LSystemAngle(system),
            LSystemExampleAngleVariation(name),
            name == "Plant" ? PlantBranchStepCompensation : 1,
            name == "Plant" ? PlantLowerLevelLengthScale : 1,
            name == "Plant" ? 0.5 : 1,
            initialState
        )
    )
    result[3];

function LSystemStrokeBounds(segments) =
    let(points = concat(
        [for (segment = segments) segment[0]],
        [for (segment = segments) segment[1]]
    ))
    [
        min([for (point = points) point[1]]),
        max([for (point = points) point[1]])
    ];

function LSystemStrokeExtentBounds(segments) =
    let(points = concat(
        [for (segment = segments) segment[0]],
        [for (segment = segments) segment[1]]
    ))
    [
        [
            min([for (point = points) point[0]]),
            min([for (point = points) point[1]])
        ],
        [
            max([for (point = points) point[0]]),
            max([for (point = points) point[1]])
        ]
    ];

function LSystemSegmentWidth(name, point, bounds) =
    name == "Hilbert" || name == "Dragon"
        ? LSystemStrokeWidth * HilbertDragonWidthScale
        : name == "Plant"
            ? let(
                height = bounds[1] == bounds[0]
                    ? 0
                    : (point[1] - bounds[0]) / (bounds[1] - bounds[0])
            )
            LSystemStrokeWidth
                * PlantTrunkWidthScale
                * pow(1 / PlantTrunkWidthScale, height)
            : LSystemStrokeWidth;

module RenderLSystemRoundSegment2D(fromPoint, toPoint, fromWidth, toWidth)
{
    hull()
    {
        translate(fromPoint)
        circle(r = fromWidth / 2, $fn = LSystemStrokeFragments);

        translate(toPoint)
        circle(r = toWidth / 2, $fn = LSystemStrokeFragments);
    }
}

module RenderLSystemOpenStroke2D(name, depth, size)
{
    segments = LSystemStrokeSegments(name, depth, size);
    bounds = LSystemStrokeBounds(segments);

    for (segment = segments)
    {
        RenderLSystemRoundSegment2D(
            segment[0],
            segment[1],
            LSystemSegmentWidth(name, segment[0], bounds),
            LSystemSegmentWidth(name, segment[1], bounds)
        );
    }
}

module RenderLSystemExample(
    name,
    depth = LSystemDepth,
    size = LSystemSize,
    height = LSystemHeight)
{
    presetName = LSystemExamplePresetName(name);
    effectiveDepth = LSystemExampleDepth(presetName, depth);
    commands = LSystemPlacedCommands(presetName, effectiveDepth, size);
    bounds = LSystemExampleIsClosed(presetName)
        ? LSystemExampleBounds(commands)
        : LSystemStrokeExtentBounds(
            LSystemStrokeSegments(presetName, effectiveDepth, size)
        );
    center = [
        (bounds[0][0] + bounds[1][0]) / 2,
        (bounds[0][1] + bounds[1][1]) / 2
    ];

    translate([-center[0], -center[1], 0])
    if (LSystemExampleIsClosed(presetName))
    {
        linear_extrude(height = height, convexity = 10)
        {
            if (presetName == "Sierpinski")
            {
                offset(
                    delta = SierpinskiOverlapOffset(
                        effectiveDepth,
                        size,
                        SierpinskiOverlapPercent
                    )
                )
                RenderLogo2D(commands);
            }
            else
            {
                RenderLogo2D(commands);
            }
        }
    }
    else
    {
        linear_extrude(height = height, convexity = 10)
        {
            RenderLSystemOpenStroke2D(
                presetName,
                effectiveDepth,
                size
            );
        }
    }
}

module RenderLSystemGallery()
{
    names = LSystemPresetNames();
    spacingX = 75;
    spacingY = 70;

    for (index = [0 : len(names) - 1])
    {
        name = names[index];
        column = index % 3;
        row = floor(index / 3);

        translate([spacingX * column, -spacingY * row, 0])
        scale(name == "Plant" ? 0.8 : 1)
        RenderLSystemExample(
            name,
            depth = name == "Dragon" ? 6
                : name == "Hilbert" ? 4
                : name == "Levy C" ? 8
                : name == "Gosper" ? 3
                : name == "Canopy" ? 5
                : name == "Plant" ? 3
                : 2,
            size = name == "Plant" ? 34
                : name == "Canopy" ? 56
                : name == "Levy C" ? 30
                : 42,
            height = 2.4
        );
    }
}

if (LSystemExample == "Gallery")
{
    RenderLSystemGallery();
}
else
{
    RenderLSystemExample(LSystemExample);
}
