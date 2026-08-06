// Small documented gallery for the optional LogoSC knot companion.

include <LogoSC-Knots.scad>

/* [Scene Selection] */

KnotExample = "PlaqueGallery"; // [Unknot,Trefoil,HopfLink,Lissajous,CelticGrid,CrossingRecord,CordGallery,BundleGallery,TwistGallery,LissajousGallery,BraidGallery,BraidBundleGallery,CelticGallery,RibbonGallery,ReliefGallery,PlaqueGallery]

/* [Individual Output - ignored by Gallery scenes] */

KnotOutput = "Plaque"; // [Debug, Cord, Bundle, Ribbon, Relief, Plaque]

/* [Route View - Debug Cord Bundle and 3D galleries] */

KnotView = "Planar"; // [Planar, Spatial]

/* [Gallery Presentation] */

KnotGalleryLabels = true;

/* [Print Quality] */

KnotPrintPreset = "Standard"; // [Draft, Standard, Fine, Custom]
KnotCordFragments = 24; // [6:1:96]
KnotRibbonArcFragments = 10; // [2:1:48]
KnotRouteSampleScale = 1; // [0.25:0.25:4]

/* [Debug Display] */

KnotShowSamples = false;
KnotCenterlineRadius = 2; // [0.01:0.01:5]

/* [Cord Geometry] */

KnotCordRadius = 1.2; // [0.1:0.1:5]

/* [Bundle Geometry] */

KnotBundleCordCount = 3; // [1:1:7]
KnotBundleCordGap = 0.4; // [0:0.1:3]
KnotBundleFitWidth = false;
KnotBundleWidth = 8; // [1:0.5:30]
KnotBundleMinimumClearance = 0; // [0:0.1:5]
KnotBundleTwistHalfTurns = 0; // [-6:1:6]

/* [Ribbon Geometry] */

KnotRibbonWidth = 2.4; // [0.2:0.1:8]
KnotRibbonCrossingClearance = 0.7; // [0:0.1:4]

/* [Bas-Relief Geometry] */

KnotReliefBaseHeight = 1.2; // [0.2:0.1:8]
KnotReliefOverpassHeight = 1; // [0.2:0.1:8]

/* [Backing Plate] */

KnotReliefPlateThickness = 1.2; // [0.2:0.1:8]
KnotReliefPlateMargin = 3; // [0:0.1:12]
KnotReliefPlateCornerRadius = 3; // [0:0.1:12]
KnotReliefPlateEdgeStyle = "Bevel"; // [None, Bevel]
KnotReliefPlateBevelWidth = 1; // [0.1:0.1:6]
KnotReliefPlateBevelHeight = 0.6; // [0.1:0.1:4]

/* [Plaque Preview Colors] */

KnotReliefUsePreviewColors = true;
KnotReliefPlateColor = [0.16, 0.22, 0.32]; // [0:0.01:1]
KnotReliefKnotColor = [0.92, 0.52, 0.10]; // [0:0.01:1]

function KnotExampleCordFragments() =
    KnotPrintPresetCordFragments(
        KnotPrintPreset,
        KnotCordFragments
    );

function KnotExampleRibbonArcFragments() =
    KnotPrintPresetRibbonArcFragments(
        KnotPrintPreset,
        KnotRibbonArcFragments
    );

function KnotExampleSampleCount(
    baseCount,
    minimum = 2,
    even = false) =
    KnotPrintPresetSampleCount(
        baseCount,
        KnotPrintPreset,
        KnotRouteSampleScale,
        minimum,
        even
    );

function KnotCelticExampleGrid(variant = 0) =
    variant == 1
    ? [
        ".X.",
        "X>X",
        ".X."
    ]
    : variant == 2
        ? [
            ">X<X",
            "X<X>",
            "<X>X",
            "X>X<"
        ]
        : [
            ">X<",
            "X>X",
            "<X>"
        ];

function KnotExampleResult(name) =
    name == "Unknot"
    ? MakeTorusKnot(1, 1, 18, 5, KnotExampleSampleCount(72, 12))
    : name == "Lissajous"
        ? MakeLissajousKnot(
            amplitudes = [18, 18, 5],
            sampleCount = KnotExampleSampleCount(240, 48)
        )
    : name == "BraidHopf"
        ? MakeCircularBraidKnot(
            2,
            [1, 1],
            18,
            5,
            5,
            KnotExampleSampleCount(8, 4, true)
        )
        : name == "BraidTrefoil"
            ? MakeCircularBraidKnot(
                2,
                [1, 1, 1],
                18,
                5,
                5,
                KnotExampleSampleCount(8, 4, true)
            )
            : name == "BraidThree"
            ? MakeCircularBraidKnot(
                3,
                [1, -2, 1, -2],
                18,
                4,
                5,
                KnotExampleSampleCount(8, 4, true)
            )
            : name == "CelticGrid"
                ? MakeCelticTileGridKnot(
                    KnotCelticExampleGrid(),
                    10,
                    KnotExampleSampleCount(8, 4, true),
                    KnotExampleSampleCount(6, 2),
                    4
                )
    : name == "HopfLink"
        ? MakeTorusKnot(
            2,
            2,
            18,
            5,
            KnotExampleSampleCount(96, 12)
        )
        : name == "CrossingRecord"
            ? MakeKnot(
                [
                    MakeKnotStrand(
                        false,
                        [[-15, -15, 0], [15, 15, 0]],
                        [0]
                    ),
                    MakeKnotStrand(
                        false,
                        [[-15, 15, 0], [15, -15, 0]],
                        [0]
                    )
                ],
                [MakeKnotCrossing([0, 0], 0, 0.5, 1, 0.5, 0)]
            )
        : MakeTorusKnot(
            2,
            3,
            18,
            5,
            KnotExampleSampleCount(120, 12)
        );

function KnotOutputRequiresPlanarRoute(output) =
    output == "Ribbon"
    || output == "Relief"
    || output == "Plaque";

module RenderKnotExample(name)
{
    knot = KnotExampleResult(name);
    viewKnot = KnotForView(
        knot,
        KnotOutputRequiresPlanarRoute(KnotOutput)
        ? "Planar"
        : KnotView
    );

    if (KnotOutput == "Plaque")
    {
        RenderKnotBasReliefPlaque(
            viewKnot,
            ribbonWidth = KnotRibbonWidth,
            crossingClearance = KnotRibbonCrossingClearance,
            plateThickness = KnotReliefPlateThickness,
            plateMargin = KnotReliefPlateMargin,
            plateCornerRadius = KnotReliefPlateCornerRadius,
            baseHeight = KnotReliefBaseHeight,
            overpassHeight = KnotReliefOverpassHeight,
            arcFragments = KnotExampleRibbonArcFragments(),
            plateColor = KnotReliefUsePreviewColors
                ? KnotReliefPlateColor
                : undef,
            reliefColor = KnotReliefUsePreviewColors
                ? KnotReliefKnotColor
                : undef,
            plateEdgeStyle = KnotReliefPlateEdgeStyle,
            plateBevelWidth = KnotReliefPlateBevelWidth,
            plateBevelHeight = KnotReliefPlateBevelHeight
        );
    }
    else if (KnotOutput == "Relief")
    {
        RenderKnotBasRelief(
            viewKnot,
            ribbonWidth = KnotRibbonWidth,
            crossingClearance = KnotRibbonCrossingClearance,
            baseHeight = KnotReliefBaseHeight,
            overpassHeight = KnotReliefOverpassHeight,
            arcFragments = KnotExampleRibbonArcFragments()
        );
    }
    else if (KnotOutput == "Ribbon")
    {
        RenderKnotRibbons2D(
            viewKnot,
            ribbonWidth = KnotRibbonWidth,
            crossingClearance = KnotRibbonCrossingClearance,
            arcFragments = KnotExampleRibbonArcFragments()
        );
    }
    else if (KnotOutput == "Bundle" && name != "CrossingRecord")
    {
        RenderKnotCordBundle(
            viewKnot,
            cordCount = KnotBundleCordCount,
            cordRadius = KnotCordRadius,
            cordGap = KnotBundleCordGap,
            bundleWidth = KnotBundleFitWidth ? KnotBundleWidth : undef,
            fragments = KnotExampleCordFragments(),
            minimumClearance = KnotBundleMinimumClearance,
            checkCrossingClearance = KnotView == "Spatial",
            twistHalfTurns = KnotBundleTwistHalfTurns
        );
    }
    else if (KnotOutput == "Cord" && name != "CrossingRecord")
    {
        RenderKnotCords(
            viewKnot,
            cordRadius = KnotCordRadius,
            fragments = KnotExampleCordFragments()
        );
    }
    else
    {
        RenderKnotDebug(
            knot,
            viewMode = KnotView,
            showSamples = KnotShowSamples,
            centerlineRadius = KnotCenterlineRadius
        );
    }
}

// Render presentation geometry from the same generated knot records used by
// normal cord output. Per-strand colors make multi-component links legible
// without changing the manufacturable geometry contract.
module RenderKnotGalleryCords(
    knot,
    strandColors,
    cordRadius = KnotCordRadius)
{
    viewKnot = KnotForView(knot, KnotView);
    strands = KnotStrands(viewKnot);

    for (strandIndex = [0 : len(strands) - 1])
    {
        strand = strands[strandIndex];
        renderStrand = MakeKnotStrand(
            KnotStrandClosed(strand),
            KnotStrandSamples(strand),
            metadata = KnotStrandMetadata(strand)
        );

        color(strandColors[strandIndex % len(strandColors)])
            RenderKnotCords(
                MakeKnot([renderStrand]),
                cordRadius = cordRadius,
                fragments = KnotExampleCordFragments()
            );
    }
}

module RenderKnotGalleryLabel(label, position, size = 4.2)
{
    if (KnotGalleryLabels)
    {
        color([0.18, 0.22, 0.28])
        translate(position)
        linear_extrude(height = 0.8)
            text(
                label,
                size = size,
                halign = "center",
                valign = "center",
                font = "Liberation Sans:style=Bold"
            );
    }
}

module RenderKnotCordGallery()
{
    RenderKnotGalleryLabel(
        str("LogoSC  KNOT CORDS  -  ", KnotView),
        [85, 39, -8],
        7
    );

    translate([25, 4, 0])
    rotate(KnotView == "Planar" ? [0, 0, -12] : [56, 0, -12])
        RenderKnotGalleryCords(
            MakeTorusKnot(
                1,
                1,
                18,
                5,
                KnotExampleSampleCount(36, 12)
            ),
            [[0.08, 0.66, 0.78]]
        );
    RenderKnotGalleryLabel("UNKNOT", [25, -30, -8]);

    translate([85, 4, 0])
    rotate(KnotView == "Planar" ? [0, 0, 18] : [56, 0, 18])
        RenderKnotGalleryCords(
            MakeTorusKnot(
                2,
                3,
                18,
                5,
                KnotExampleSampleCount(60, 12)
            ),
            [[0.94, 0.58, 0.10]]
        );
    RenderKnotGalleryLabel("TREFOIL", [85, -30, -8]);

    translate([145, 4, 0])
    rotate(KnotView == "Planar" ? [0, 0, -12] : [56, 0, -12])
        RenderKnotGalleryCords(
            MakeTorusKnot(
                2,
                2,
                18,
                5,
                KnotExampleSampleCount(48, 12)
            ),
            [
                [0.90, 0.24, 0.22],
                [0.48, 0.28, 0.82]
            ]
        );
    RenderKnotGalleryLabel("HOPF LINK", [145, -30, -8]);
}

module RenderKnotLissajousGalleryExample(
    frequencies,
    phases,
    sampleCount,
    position,
    rotation,
    colorValue)
{
    translate(position)
    rotate(KnotView == "Planar" ? [0, 0, rotation[2]] : rotation)
        RenderKnotGalleryCords(
            MakeLissajousKnot(
                frequencies,
                [18, 18, 5],
                phases,
                KnotExampleSampleCount(sampleCount, 48)
            ),
            [colorValue],
            0.72
        );
}

module RenderKnotLissajousGallery()
{
    RenderKnotGalleryLabel(
        str("LogoSC  LISSAJOUS KNOTS  -  ", KnotView),
        [85, 39, -8],
        5.8
    );

    RenderKnotLissajousGalleryExample(
        [2, 3, 5], [11, 23, 37], 120,
        [25, 4, 0], [56, 0, -8], [0.08, 0.62, 0.76]
    );
    RenderKnotGalleryLabel("2 : 3 : 5", [25, -30, -8], 3.5);

    RenderKnotLissajousGalleryExample(
        [3, 4, 5], [0, 17, 31], 120,
        [85, 4, 0], [56, 0, 7], [0.94, 0.52, 0.08]
    );
    RenderKnotGalleryLabel("3 : 4 : 5", [85, -30, -8], 3.5);

    RenderKnotLissajousGalleryExample(
        [3, 5, 7], [7, 19, 41], 160,
        [145, 4, 0], [56, 0, -7], [0.52, 0.24, 0.78]
    );
    RenderKnotGalleryLabel("3 : 5 : 7", [145, -30, -8], 3.5);
}

module RenderKnotBundleGalleryExample(
    cordCount,
    position,
    rotation,
    strandColors)
{
    master = KnotForView(
        MakeTorusKnot(
            2,
            3,
            18,
            5,
            KnotExampleSampleCount(48, 12)
        ),
        KnotView
    );
    bundle = MakeKnotBundle(
        master,
        cordCount,
        cordRadius = 0.72,
        cordGap = 0.32
    );

    translate(position)
    rotate(rotation)
        RenderKnotGalleryCords(bundle, strandColors, 0.72);
}

module RenderKnotBundleGallery()
{
    RenderKnotGalleryLabel(
        str("LogoSC  CORD BUNDLES  -  ", KnotView),
        [85, 39, -8],
        7
    );

    RenderKnotBundleGalleryExample(
        2,
        [25, 4, 0],
        [56, 0, -12],
        [
            [0.02, 0.62, 0.76],
            [0.12, 0.82, 0.62]
        ]
    );
    RenderKnotGalleryLabel("2 CORDS", [25, -30, -8]);

    RenderKnotBundleGalleryExample(
        3,
        [85, 4, 0],
        [56, 0, 18],
        [
            [0.98, 0.70, 0.10],
            [0.94, 0.38, 0.08],
            [0.78, 0.16, 0.12]
        ]
    );
    RenderKnotGalleryLabel("3 CORDS", [85, -30, -8]);

    RenderKnotBundleGalleryExample(
        4,
        [145, 4, 0],
        [56, 0, -12],
        [
            [0.35, 0.18, 0.75],
            [0.58, 0.24, 0.84],
            [0.82, 0.32, 0.72],
            [0.94, 0.38, 0.52]
        ]
    );
    RenderKnotGalleryLabel("4 CORDS", [145, -30, -8]);
}

module RenderKnotTwistGalleryExample(
    twistHalfTurns,
    position,
    rotation,
    strandColors)
{
    master = KnotForView(
        MakeTorusKnot(
            1,
            1,
            18,
            5,
            KnotExampleSampleCount(72, 24)
        ),
        KnotView
    );
    bundle = MakeKnotBundle(
        master,
        3,
        cordRadius = 0.72,
        cordGap = 0.32,
        twistHalfTurns = twistHalfTurns
    );

    translate(position)
    rotate(KnotView == "Planar" ? [0, 0, rotation[2]] : rotation)
        RenderKnotGalleryCords(bundle, strandColors, 0.72);
}

module RenderKnotTwistGallery()
{
    RenderKnotGalleryLabel(
        "LogoSC  TWISTED CORD BUNDLES",
        [85, 39, -8],
        5.8
    );

    RenderKnotTwistGalleryExample(
        0,
        [25, 4, 0],
        [56, 0, -12],
        [
            [0.02, 0.62, 0.76],
            [0.12, 0.82, 0.62],
            [0.16, 0.48, 0.84]
        ]
    );
    RenderKnotGalleryLabel("UNTWISTED", [25, -30, -8], 3.5);

    RenderKnotTwistGalleryExample(
        1,
        [85, 4, 0],
        [56, 0, 18],
        [
            [0.98, 0.66, 0.08],
            [0.84, 0.16, 0.12]
        ]
    );
    RenderKnotGalleryLabel("HALF TWIST", [85, -30, -8], 3.5);

    RenderKnotTwistGalleryExample(
        2,
        [145, 4, 0],
        [56, 0, -12],
        [
            [0.35, 0.18, 0.75],
            [0.58, 0.24, 0.84],
            [0.82, 0.32, 0.72]
        ]
    );
    RenderKnotGalleryLabel("FULL TWIST", [145, -30, -8], 3.5);
}

module RenderKnotBraidGalleryExample(name, position, rotation, strandColors)
{
    translate(position)
    rotate(KnotView == "Planar" ? [0, 0, rotation[2]] : rotation)
        RenderKnotGalleryCords(
            KnotExampleResult(name),
            strandColors,
            0.82
        );
}

module RenderKnotBraidGallery()
{
    RenderKnotGalleryLabel(
        str("LogoSC  CIRCULAR BRAIDS  -  ", KnotView),
        [85, 39, -8],
        5.8
    );

    RenderKnotBraidGalleryExample(
        "BraidHopf",
        [25, 4, 0],
        [56, 0, -12],
        [
            [0.02, 0.62, 0.76],
            [0.12, 0.82, 0.62]
        ]
    );
    RenderKnotGalleryLabel("HOPF CLOSURE", [25, -30, -8]);

    RenderKnotBraidGalleryExample(
        "BraidTrefoil",
        [85, 4, 0],
        [56, 0, 18],
        [[0.94, 0.48, 0.08]]
    );
    RenderKnotGalleryLabel("TREFOIL CLOSURE", [85, -30, -8]);

    RenderKnotBraidGalleryExample(
        "BraidThree",
        [145, 4, 0],
        [56, 0, -12],
        [[0.56, 0.24, 0.82]]
    );
    RenderKnotGalleryLabel("3-LANE BRAID", [145, -30, -8]);
}

module RenderKnotBraidBundleGalleryExample(
    name,
    cordCount,
    position,
    rotation,
    strandColors)
{
    bundle = MakeKnotBundle(
        KnotExampleResult(name),
        cordCount,
        cordRadius = 0.58,
        cordGap = 0.26,
        minimumClearance = 0.2
    );

    translate(position)
    rotate(KnotView == "Planar" ? [0, 0, rotation[2]] : rotation)
        RenderKnotGalleryCords(bundle, strandColors, 0.58);
}

module RenderKnotBraidBundleGallery()
{
    RenderKnotGalleryLabel(
        str("LogoSC  BRAIDED CORD BUNDLES  -  ", KnotView),
        [85, 39, -8],
        5.4
    );

    RenderKnotBraidBundleGalleryExample(
        "BraidHopf",
        2,
        [25, 4, 0],
        [56, 0, -12],
        [
            [0.02, 0.62, 0.76],
            [0.12, 0.82, 0.62],
            [0.96, 0.62, 0.10],
            [0.94, 0.30, 0.08]
        ]
    );
    RenderKnotGalleryLabel("HOPF  -  2 x 2 CORDS", [25, -30, -8], 3.5);

    RenderKnotBraidBundleGalleryExample(
        "BraidTrefoil",
        2,
        [85, 4, 0],
        [56, 0, 18],
        [
            [0.98, 0.66, 0.08],
            [0.84, 0.16, 0.12]
        ]
    );
    RenderKnotGalleryLabel("TREFOIL  -  2 CORDS", [85, -30, -8], 3.5);

    RenderKnotBraidBundleGalleryExample(
        "BraidThree",
        2,
        [145, 4, 0],
        [56, 0, -12],
        [
            [0.35, 0.18, 0.75],
            [0.82, 0.32, 0.72]
        ]
    );
    RenderKnotGalleryLabel("3-LANE  -  2 CORDS", [145, -30, -8], 3.5);
}

module RenderKnotCelticGalleryExample(
    variant,
    position,
    rotation,
    strandColors)
{
    grid = KnotCelticExampleGrid(variant);
    cellSize = variant == 2 ? 8 : 9;
    knot = MakeCelticTileGridKnot(
        grid,
        cellSize,
        KnotExampleSampleCount(8, 4, true),
        KnotExampleSampleCount(6, 2),
        4
    );
    width = KnotCelticGridColumnCount(grid) * cellSize;
    height = len(grid) * cellSize;

    translate(position)
    rotate(KnotView == "Planar" ? [0, 0, rotation[2]] : rotation)
    translate([-width / 2, height / 2, 0])
        RenderKnotGalleryCords(knot, strandColors, 0.62);
}

module RenderKnotCelticGallery()
{
    RenderKnotGalleryLabel(
        str("LogoSC  CELTIC TILE GRIDS  -  ", KnotView),
        [85, 39, -8],
        5.8
    );

    RenderKnotCelticGalleryExample(
        0,
        [25, 4, 0],
        [55, 0, -8],
        [
            [0.02, 0.62, 0.76],
            [0.12, 0.82, 0.62]
        ]
    );
    RenderKnotGalleryLabel("2 COMPONENTS", [25, -30, -8], 3.5);

    RenderKnotCelticGalleryExample(
        1,
        [85, 4, 0],
        [55, 0, 7],
        [[0.98, 0.58, 0.06]]
    );
    RenderKnotGalleryLabel("IRREGULAR GRID", [85, -30, -8], 3.5);

    RenderKnotCelticGalleryExample(
        2,
        [145, 4, 0],
        [55, 0, -7],
        [
            [0.35, 0.18, 0.75],
            [0.82, 0.32, 0.72]
        ]
    );
    RenderKnotGalleryLabel("4 x 4 GRID", [145, -30, -8], 3.5);
}

module RenderKnotRibbonGalleryExample(
    variant,
    position,
    rotation,
    masked = true,
    colorValue = [0.10, 0.50, 0.82])
{
    grid = KnotCelticExampleGrid(variant);
    cellSize = variant == 2 ? 8 : 9;
    spatialKnot = MakeCelticTileGridKnot(
        grid,
        cellSize,
        KnotExampleSampleCount(8, 4, true),
        KnotExampleSampleCount(6, 2),
        4
    );
    planarKnot = KnotForView(spatialKnot, "Planar");
    width = KnotCelticGridColumnCount(grid) * cellSize;
    height = len(grid) * cellSize;

    color(colorValue)
    translate(position)
    rotate([0, 0, rotation])
    translate([-width / 2, height / 2, 0])
    linear_extrude(height = 0.8)
    {
        if (masked)
        {
            RenderKnotRibbons2D(
                planarKnot,
                ribbonWidth = 2.1,
                crossingClearance = 0.65,
                arcFragments = KnotExampleRibbonArcFragments()
            );
        }
        else
        {
            RenderKnotRegionList(
                KnotRibbonRegions(planarKnot, 2.1, 8)
            );
        }
    }
}

module RenderKnotRibbonGallery()
{
    RenderKnotGalleryLabel(
        "LogoSC  PLANAR KNOT RIBBONS",
        [85, 39, -1],
        6.2
    );

    RenderKnotRibbonGalleryExample(
        0,
        [25, 4, 0],
        -8,
        false,
        [0.10, 0.58, 0.78]
    );
    RenderKnotGalleryLabel("CONTINUOUS", [25, -30, -1], 3.6);

    RenderKnotRibbonGalleryExample(
        0,
        [85, 4, 0],
        7,
        true,
        [0.94, 0.48, 0.08]
    );
    RenderKnotGalleryLabel("UNDERPASS MASKS", [85, -30, -1], 3.2);

    RenderKnotRibbonGalleryExample(
        2,
        [145, 4, 0],
        -7,
        true,
        [0.50, 0.24, 0.78]
    );
    RenderKnotGalleryLabel("4 x 4 INTERLACE", [145, -30, -1], 3.2);
}

module RenderKnotReliefGalleryExample(
    variant,
    position,
    rotation,
    baseHeight,
    overpassHeight,
    colorValue)
{
    grid = KnotCelticExampleGrid(variant);
    cellSize = variant == 2 ? 8 : 9;
    planarKnot = KnotForView(
        MakeCelticTileGridKnot(
            grid,
            cellSize,
            KnotExampleSampleCount(8, 4, true),
            KnotExampleSampleCount(6, 2),
            4
        ),
        "Planar"
    );
    width = KnotCelticGridColumnCount(grid) * cellSize;
    height = len(grid) * cellSize;

    color(colorValue)
    translate(position)
    rotate(rotation)
    translate([-width / 2, height / 2, 0])
        RenderKnotBasRelief(
            planarKnot,
            ribbonWidth = 2.1,
            crossingClearance = 0.65,
            baseHeight = baseHeight,
            overpassHeight = overpassHeight,
            arcFragments = KnotExampleRibbonArcFragments()
        );
}

module RenderKnotReliefGallery()
{
    RenderKnotGalleryLabel(
        "LogoSC  KNOT BAS-RELIEF",
        [85, 39, -1],
        6.2
    );

    RenderKnotReliefGalleryExample(
        0,
        [25, 4, 0],
        [55, 0, -8],
        0.8,
        0.6,
        [0.08, 0.58, 0.72]
    );
    RenderKnotGalleryLabel("LOW RELIEF", [25, -30, -1], 3.5);

    RenderKnotReliefGalleryExample(
        0,
        [85, 4, 0],
        [55, 0, 7],
        1.2,
        1,
        [0.92, 0.46, 0.08]
    );
    RenderKnotGalleryLabel("RAISED CROSSINGS", [85, -30, -1], 3.2);

    RenderKnotReliefGalleryExample(
        2,
        [145, 4, 0],
        [55, 0, -7],
        1.2,
        1.4,
        [0.48, 0.22, 0.76]
    );
    RenderKnotGalleryLabel("4 x 4 RELIEF", [145, -30, -1], 3.2);
}

module RenderKnotPlaqueGalleryExample(
    variant,
    position,
    rotation,
    plateMargin,
    plateCornerRadius,
    plateEdgeStyle,
    plateBevelWidth,
    plateBevelHeight,
    colorValue)
{
    grid = KnotCelticExampleGrid(variant);
    cellSize = variant == 2 ? 8 : 9;
    planarKnot = KnotForView(
        MakeCelticTileGridKnot(
            grid,
            cellSize,
            KnotExampleSampleCount(8, 4, true),
            KnotExampleSampleCount(6, 2),
            4
        ),
        "Planar"
    );
    width = KnotCelticGridColumnCount(grid) * cellSize;
    height = len(grid) * cellSize;

    RenderKnotOptionalColor(
        KnotReliefUsePreviewColors ? undef : colorValue
    )
    translate(position)
    rotate(rotation)
    translate([-width / 2, height / 2, 0])
        RenderKnotBasReliefPlaque(
            planarKnot,
            ribbonWidth = 2.1,
            crossingClearance = 0.65,
            plateThickness = 1.2,
            plateMargin = plateMargin,
            plateCornerRadius = plateCornerRadius,
            baseHeight = 1.1,
            overpassHeight = 1,
            arcFragments = KnotExampleRibbonArcFragments(),
            plateColor = KnotReliefUsePreviewColors
                ? KnotReliefPlateColor
                : undef,
            reliefColor = KnotReliefUsePreviewColors
                ? colorValue
                : undef,
            plateEdgeStyle = plateEdgeStyle,
            plateBevelWidth = plateBevelWidth,
            plateBevelHeight = plateBevelHeight
        );
}

module RenderKnotPlaqueGallery()
{
    RenderKnotGalleryLabel(
        "LogoSC  KNOT RELIEF PLAQUES",
        [85, 39, -1],
        5.8
    );

    RenderKnotPlaqueGalleryExample(
        0,
        [25, 4, 0],
        [55, 0, -8],
        2,
        1.5,
        "None",
        1,
        0.6,
        [0.08, 0.58, 0.72]
    );
    RenderKnotGalleryLabel("COMPACT", [25, -30, -1], 3.5);

    RenderKnotPlaqueGalleryExample(
        0,
        [85, 4, 0],
        [55, 0, 7],
        4,
        4,
        "Bevel",
        1.2,
        0.8,
        [0.92, 0.46, 0.08]
    );
    RenderKnotGalleryLabel("BEVELED PLAQUE", [85, -30, -1], 3.2);

    RenderKnotPlaqueGalleryExample(
        2,
        [145, 4, 0],
        [55, 0, -7],
        3,
        3,
        "Bevel",
        0.9,
        0.6,
        [0.48, 0.22, 0.76]
    );
    RenderKnotGalleryLabel("4 x 4 PLAQUE", [145, -30, -1], 3.2);
}

if (KnotExample == "PlaqueGallery")
{
    RenderKnotPlaqueGallery();
}
else if (KnotExample == "ReliefGallery")
{
    RenderKnotReliefGallery();
}
else if (KnotExample == "RibbonGallery")
{
    RenderKnotRibbonGallery();
}
else if (KnotExample == "CelticGallery")
{
    RenderKnotCelticGallery();
}
else if (KnotExample == "TwistGallery")
{
    RenderKnotTwistGallery();
}
else if (KnotExample == "BraidBundleGallery")
{
    RenderKnotBraidBundleGallery();
}
else if (KnotExample == "BraidGallery")
{
    RenderKnotBraidGallery();
}
else if (KnotExample == "LissajousGallery")
{
    RenderKnotLissajousGallery();
}
else if (KnotExample == "BundleGallery")
{
    RenderKnotBundleGallery();
}
else if (KnotExample == "CordGallery")
{
    RenderKnotCordGallery();
}
else if (KnotExample == "Gallery")
{
    translate([24, 24, 0])
        RenderKnotExample("Unknot");

    translate([72, 24, 0])
        RenderKnotExample("Trefoil");

    translate([120, 24, 0])
        RenderKnotExample("HopfLink");

    translate([168, 24, 0])
        RenderKnotExample("CrossingRecord");
}
else
{
    translate([24, 24, 0])
        RenderKnotExample(KnotExample);
}
