// Small documented gallery for the optional LogoSC knot companion.

include <LogoSC-Knots.scad>

KnotExample = "Gallery"; // [Gallery, Unknot, Trefoil, HopfLink, CrossingRecord]
KnotView = "Planar"; // [Planar, Spatial]
KnotShowSamples = false;
KnotCenterlineRadius = 2; // [0.01:0.01:5]

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

    RenderKnotDebug(
        knot,
        viewMode = KnotView,
        showSamples = KnotShowSamples,
        centerlineRadius = KnotCenterlineRadius
    );
}

if (KnotExample == "Gallery")
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
