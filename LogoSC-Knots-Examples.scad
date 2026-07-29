// Small documented gallery for the optional LogoSC knot companion.

include <LogoSC-Knots.scad>

KnotExample = "CelticGallery"; // [CelticGallery,BraidBundleGallery,BraidGallery,BundleGallery,CordGallery,CelticGrid,Unknot,Trefoil,HopfLink,CrossingRecord]
KnotView = "Spatial"; // [Planar, Spatial]
KnotOutput = "Debug"; // [Debug, Cord, Bundle]
KnotShowSamples = false;
KnotCenterlineRadius = 2; // [0.01:0.01:5]
KnotCordRadius = 1.2; // [0.1:0.1:5]
KnotCordFragments = 24; // [6:1:64]
KnotBundleCordCount = 3; // [1:1:7]
KnotBundleCordGap = 0.4; // [0:0.1:3]
KnotBundleFitWidth = false;
KnotBundleWidth = 8; // [1:0.5:30]
KnotBundleMinimumClearance = 0; // [0:0.1:5]
KnotGalleryLabels = true;

function KnotCelticExampleGrid(variant = 0) =
    variant == 1
    ? [
        ["X", "X", "X"],
        ["X", "X", "X"],
        ["X", "X", "X"]
    ]
    : variant == 2
        ? [
            ["NE_SW", "X", "NW_ES", "X"],
            ["X", "NW_ES", "X", "NE_SW"],
            ["NW_ES", "X", "NE_SW", "X"],
            ["X", "NE_SW", "X", "NW_ES"]
        ]
        : [
            ["NE_SW", "X", "NW_ES"],
            ["X", "NE_SW", "X"],
            ["NW_ES", "X", "NE_SW"]
        ];

function KnotExampleResult(name) =
    name == "Unknot"
    ? MakeTorusKnot(1, 1, 18, 5, 72)
    : name == "BraidHopf"
        ? MakeCircularBraidKnot(2, [1, 1], 18, 5, 5, 8)
        : name == "BraidTrefoil"
            ? MakeCircularBraidKnot(2, [1, 1, 1], 18, 5, 5, 8)
            : name == "BraidThree"
            ? MakeCircularBraidKnot(3, [1, -2, 1, -2], 18, 4, 5, 8)
            : name == "CelticGrid"
                ? MakeCelticTileGridKnot(
                    KnotCelticExampleGrid(),
                    10,
                    8,
                    6,
                    4
                )
    : name == "HopfLink"
        ? MakeTorusKnot(2, 2, 18, 5, 96)
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
        : MakeTorusKnot(2, 3, 18, 5, 120);

module RenderKnotExample(name)
{
    knot = KnotExampleResult(name);
    viewKnot = KnotForView(knot, KnotView);

    if (KnotOutput == "Bundle" && name != "CrossingRecord")
    {
        RenderKnotCordBundle(
            viewKnot,
            cordCount = KnotBundleCordCount,
            cordRadius = KnotCordRadius,
            cordGap = KnotBundleCordGap,
            bundleWidth = KnotBundleFitWidth ? KnotBundleWidth : undef,
            fragments = KnotCordFragments,
            minimumClearance = KnotBundleMinimumClearance,
            checkCrossingClearance = KnotView == "Spatial"
        );
    }
    else if (KnotOutput == "Cord" && name != "CrossingRecord")
    {
        RenderKnotCords(
            viewKnot,
            cordRadius = KnotCordRadius,
            fragments = KnotCordFragments
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
                fragments = KnotCordFragments
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
            MakeTorusKnot(1, 1, 18, 5, 36),
            [[0.08, 0.66, 0.78]]
        );
    RenderKnotGalleryLabel("UNKNOT", [25, -30, -8]);

    translate([85, 4, 0])
    rotate(KnotView == "Planar" ? [0, 0, 18] : [56, 0, 18])
        RenderKnotGalleryCords(
            MakeTorusKnot(2, 3, 18, 5, 60),
            [[0.94, 0.58, 0.10]]
        );
    RenderKnotGalleryLabel("TREFOIL", [85, -30, -8]);

    translate([145, 4, 0])
    rotate(KnotView == "Planar" ? [0, 0, -12] : [56, 0, -12])
        RenderKnotGalleryCords(
            MakeTorusKnot(2, 2, 18, 5, 48),
            [
                [0.90, 0.24, 0.22],
                [0.48, 0.28, 0.82]
            ]
        );
    RenderKnotGalleryLabel("HOPF LINK", [145, -30, -8]);
}

module RenderKnotBundleGalleryExample(
    cordCount,
    position,
    rotation,
    strandColors)
{
    master = KnotForView(MakeTorusKnot(2, 3, 18, 5, 48), KnotView);
    bundle = MakeKnotBundle(
        master,
        cordCount,
        cordRadius = 0.72,
        cordGap = 0.32
    );

    translate(position)
    rotate(KnotView == "Planar" ? [0, 0, rotation[2]] : rotation)
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
    knot = MakeCelticTileGridKnot(grid, cellSize, 8, 6, 4);
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
    RenderKnotGalleryLabel("1 COMPONENT", [85, -30, -8], 3.5);

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

if (KnotExample == "CelticGallery")
{
    RenderKnotCelticGallery();
}
else if (KnotExample == "BraidBundleGallery")
{
    RenderKnotBraidBundleGallery();
}
else if (KnotExample == "BraidGallery")
{
    RenderKnotBraidGallery();
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
