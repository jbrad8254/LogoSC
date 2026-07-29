// Small documented gallery for the optional LogoSC knot companion.

include <LogoSC-Knots.scad>

KnotExample = "CordGallery"; // [CordGallery, Gallery, Unknot, Trefoil, HopfLink, CrossingRecord]
KnotView = "Planar"; // [Planar, Spatial]
KnotOutput = "Debug"; // [Debug, Cord]
KnotShowSamples = false;
KnotCenterlineRadius = 2; // [0.01:0.01:5]
KnotCordRadius = 1.2; // [0.1:0.1:5]
KnotCordFragments = 24; // [6:1:64]
KnotGalleryLabels = true;

function KnotExampleResult(name) =
    name == "Unknot"
    ? MakeTorusKnot(1, 1, 18, 5, 72)
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

    if (KnotOutput == "Cord" && name != "CrossingRecord")
    {
        RenderKnotCords(
            knot,
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
module RenderKnotGalleryCords(knot, strandColors)
{
    strands = KnotStrands(knot);

    for (strandIndex = [0 : len(strands) - 1])
    {
        color(strandColors[strandIndex % len(strandColors)])
            RenderKnotCords(
                MakeKnot([strands[strandIndex]]),
                cordRadius = KnotCordRadius,
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
    RenderKnotGalleryLabel("LogoSC  KNOT CORDS", [85, 39, -8], 7);

    translate([25, 4, 0])
    rotate([56, 0, -12])
        RenderKnotGalleryCords(
            MakeTorusKnot(1, 1, 18, 5, 36),
            [[0.08, 0.66, 0.78]]
        );
    RenderKnotGalleryLabel("UNKNOT", [25, -30, -8]);

    translate([85, 4, 0])
    rotate([56, 0, 18])
        RenderKnotGalleryCords(
            MakeTorusKnot(2, 3, 18, 5, 60),
            [[0.94, 0.58, 0.10]]
        );
    RenderKnotGalleryLabel("TREFOIL", [85, -30, -8]);

    translate([145, 4, 0])
    rotate([56, 0, -12])
        RenderKnotGalleryCords(
            MakeTorusKnot(2, 2, 18, 5, 48),
            [
                [0.90, 0.24, 0.22],
                [0.48, 0.28, 0.82]
            ]
        );
    RenderKnotGalleryLabel("HOPF LINK", [145, -30, -8]);
}

if (KnotExample == "CordGallery")
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
