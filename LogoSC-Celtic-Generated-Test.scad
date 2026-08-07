// Cross-language parity test for the generated Celtic knot record.
// This is intentionally separate from the fast routine knot suite because the
// pure-OpenSCAD reference compiler takes about 30 seconds for this fixture.

include <LogoSC-Knots.scad>
include <generated/LogoSC-Celtic-Generated.scad>
include <generated/LogoSC-Celtic-Generated-Knot.scad>

function CelticGeneratedAllNear(left, right, tolerance, index = 0) =
    index >= len(left)
    ? true
    : CelticGeneratedValueNear(left[index], right[index], tolerance)
        && CelticGeneratedAllNear(left, right, tolerance, index + 1);

function CelticGeneratedValueNear(left, right, tolerance = 0.000000001) =
    is_num(left) && is_num(right)
    ? abs(left - right) <= tolerance
    : is_list(left) && is_list(right)
        ? len(left) == len(right)
            && CelticGeneratedAllNear(left, right, tolerance)
        : left == right;

referenceKnot = MakeCelticTileGridKnot(
    GeneratedCelticGrid,
    cellSize = 4,
    samplesPerTile = 4,
    samplesPerBoundary = 2,
    crossingHeight = 2
);

generatedSamples = [
    for (strand = KnotStrands(GeneratedCelticKnot))
        KnotStrandSamples(strand)
];
referenceSamples = [
    for (strand = KnotStrands(referenceKnot))
        KnotStrandSamples(strand)
];

assert(
    KnotValidationIsValid(ValidateKnot(GeneratedCelticKnot)),
    "Generated C++ knot record must pass LogoSC knot validation."
);
assert(len(KnotStrands(GeneratedCelticKnot)) == 38, "Expected 38 components.");
assert(len(KnotCrossings(GeneratedCelticKnot)) == 32, "Expected 32 crossings.");
assert(KnotCordSegmentCount(GeneratedCelticKnot) == 928, "Expected 928 segments.");
assert(
    CelticGeneratedValueNear(generatedSamples, referenceSamples),
    "C++ and OpenSCAD sampled routes differ."
);
assert(
    CelticGeneratedValueNear(
        KnotCrossings(GeneratedCelticKnot),
        KnotCrossings(referenceKnot)
    ),
    "C++ and OpenSCAD crossing records differ."
);

echo(
    "LOGOSC_CPP_KNOT_PARITY",
    "PASS",
    "components",
    len(KnotStrands(GeneratedCelticKnot)),
    "crossings",
    len(KnotCrossings(GeneratedCelticKnot)),
    "segments",
    KnotCordSegmentCount(GeneratedCelticKnot)
);
