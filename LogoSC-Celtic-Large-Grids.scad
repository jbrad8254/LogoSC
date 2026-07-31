include <LogoSC-Knots.scad>

/* [Large Celtic Scene] */

CelticLargeExample = "CELTIC"; // [Diamond8,Ring16,Diamond24,Ring32,CELTIC]

/* [Output] */

CelticLargeOutput = "Cord"; // [Topology,Cord,Ribbon,Plaque]
CelticLargeView = "Spatial"; // [Planar,Spatial]

/* [Geometry] */

CelticLargeCellSize = 4; // [2:0.5:12]
CelticLargeCrossingHeight = 2; // [0.5:0.5:8]
CelticLargeCordRadius = 0.45; // [0.1:0.05:2]
CelticLargeCordFragments = 8; // [4:1:32]
CelticLargeRibbonWidth = 0.9; // [0.2:0.1:4]
CelticLargeRibbonClearance = 0.3; // [0:0.05:2]
CelticLargeRibbonFragments = 6; // [2:1:24]

/* [Plaque] */

CelticLargeReliefBaseHeight = 1.2; // [0.2:0.1:8]
CelticLargeReliefOverpassHeight = 1; // [0.2:0.1:8]
CelticLargePlateThickness = 1.2; // [0.2:0.1:8]
CelticLargePlateMargin = 3; // [0:0.1:12]
CelticLargePlateCornerRadius = 3; // [0:0.1:12]
CelticLargePlateEdgeStyle = "Bevel"; // [None,Bevel]
CelticLargePlateBevelWidth = 1; // [0.1:0.1:6]
CelticLargePlateBevelHeight = 0.6; // [0.1:0.1:4]

/* [Plaque Preview Colors] */

CelticLargeUsePreviewColors = true;
CelticLargePlateColor = [0.16, 0.22, 0.32]; // [0:0.01:1]
CelticLargeKnotColor = [0.92, 0.52, 0.10]; // [0:0.01:1]

function CelticLargeTile(row, column) =
    (row + column) % 3 == 0
    ? "X"
    : (row + column) % 2 == 0
        ? ">"
        : "<";

function CelticLargeMaskOccupied(size, row, column, pattern) =
    let(
        center = (size - 1) / 2,
        distance = abs(row - center) + abs(column - center)
    )
    pattern == "Diamond"
    ? distance <= size * 0.55
    : pattern == "Ring"
        ? distance <= size * 0.65 && distance >= size * 0.22
        : true;

function CelticLargeMaskRow(
    size,
    row,
    pattern,
    column = 0,
    result = "") =
    column >= size
    ? result
    : CelticLargeMaskRow(
        size,
        row,
        pattern,
        column + 1,
        str(
            result,
            CelticLargeMaskOccupied(size, row, column, pattern)
            ? CelticLargeTile(row, column)
            : "."
        )
    );

function CelticLargeMaskGrid(size, pattern) =
[
    for (row = [0 : size - 1])
        CelticLargeMaskRow(size, row, pattern)
];

function CelticLargeGlyph(letter) =
    letter == "C"
    ? [".XXX.", "X...X", "X....", "X....", "X....", "X...X", ".XXX."]
    : letter == "E"
        ? ["XXXXX", "X....", "X....", "XXXX.", "X....", "X....", "XXXXX"]
        : letter == "L"
            ? ["X....", "X....", "X....", "X....", "X....", "X....", "XXXXX"]
            : letter == "T"
                ? ["XXXXX", "..X..", "..X..", "..X..", "..X..", "..X..", "..X.."]
                : assert(letter == "I", "Unknown large Celtic word glyph.")
                  ["XXXXX", "..X..", "..X..", "..X..", "..X..", "..X..", "XXXXX"];

CelticLargeWord = ["C", "E", "L", "T", "I", "C"];

function CelticLargeWordCellIsOccupied(row, column) =
    let(
        glyphIndex = floor(column / 6),
        glyphColumn = column % 6
    )
    glyphIndex < len(CelticLargeWord)
    && glyphColumn < 5
    && CelticLargeGlyph(CelticLargeWord[glyphIndex])[row][glyphColumn] == "X";

function CelticLargeWordRow(row, column = 0, result = ".") =
    column >= len(CelticLargeWord) * 6 - 1
    ? str(result, ".")
    : CelticLargeWordRow(
        row,
        column + 1,
        str(
            result,
            CelticLargeWordCellIsOccupied(row, column)
            ? CelticLargeTile(row + 1, column + 1)
            : "."
        )
    );

function CelticLargeBlankRow(count, index = 0, result = "") =
    index >= count
    ? result
    : CelticLargeBlankRow(count, index + 1, str(result, "."));

function CelticLargeWordGrid() =
    concat(
        [CelticLargeBlankRow(len(CelticLargeWord) * 6 + 1)],
        [
            for (row = [0 : 6])
                CelticLargeWordRow(row)
        ],
        [CelticLargeBlankRow(len(CelticLargeWord) * 6 + 1)]
    );

function CelticLargeExampleSize(example) =
    example == "Diamond8"
    ? 8
    : example == "Ring16"
        ? 16
        : example == "Diamond24"
            ? 24
            : 32;

function CelticLargeExamplePattern(example) =
    example == "Diamond8" || example == "Diamond24"
    ? "Diamond"
    : "Ring";

function CelticLargeExampleGrid(example) =
    example == "CELTIC"
    ? CelticLargeWordGrid()
    : CelticLargeMaskGrid(
        CelticLargeExampleSize(example),
        CelticLargeExamplePattern(example)
    );

function CelticLargeTimeEstimate(example, output) =
    output == "Topology"
    ? example == "Diamond8"
        ? "about 1 second"
        : example == "Ring16"
            ? "about 5 seconds"
            : example == "Diamond24"
                ? "about 20 seconds"
                : example == "Ring32"
                    ? "about 75 seconds"
                    : "about 45 seconds"
    : output == "Cord"
        ? example == "Diamond8"
            ? "about 1 second"
            : example == "Ring16"
                ? "roughly 10-20 seconds"
                : example == "Diamond24"
                    ? "roughly 25-45 seconds"
                    : example == "Ring32"
                        ? "roughly 1-2 minutes"
                        : "roughly 40-60 seconds"
        : output == "Ribbon"
            ? example == "Diamond8"
                ? "roughly 2-10 seconds"
                : example == "Ring16"
                    ? "roughly 15-60 seconds"
                    : example == "Diamond24"
                        ? "roughly 1-5 minutes"
                        : example == "Ring32"
                            ? "roughly 3-10 minutes"
                            : "roughly 1-5 minutes"
            : example == "Diamond8"
                ? "roughly 1-5 seconds"
                : example == "Ring16"
                    ? "roughly 10-30 seconds"
                    : example == "Diamond24"
                        ? "roughly 30 seconds to 2 minutes"
                        : example == "Ring32"
                            ? "roughly 2-5 minutes"
                            : "roughly 1-3 minutes";

assert(
    CelticLargeExample == "Diamond8"
    || CelticLargeExample == "Ring16"
    || CelticLargeExample == "Diamond24"
    || CelticLargeExample == "Ring32"
    || CelticLargeExample == "CELTIC",
    "Unknown large Celtic example."
);
assert(
    CelticLargeOutput == "Topology"
    || CelticLargeOutput == "Cord"
    || CelticLargeOutput == "Ribbon"
    || CelticLargeOutput == "Plaque",
    "Large Celtic output must be Topology, Cord, Ribbon, or Plaque."
);
assert(
    CelticLargeView == "Planar" || CelticLargeView == "Spatial",
    "Large Celtic view must be Planar or Spatial."
);

echo(
    "LogoSC large Celtic grid: working; this may take time",
    "scene",
    CelticLargeExample,
    "output",
    CelticLargeOutput,
    "estimated on the development machine",
    CelticLargeTimeEstimate(CelticLargeExample, CelticLargeOutput),
    "actual time may vary"
);

celticLargeGrid = CelticLargeExampleGrid(CelticLargeExample);
celticLargeKnot = MakeCelticTileGridKnot(
    celticLargeGrid,
    cellSize = CelticLargeCellSize,
    samplesPerTile = 4,
    samplesPerBoundary = 2,
    crossingHeight = CelticLargeCrossingHeight
);
celticLargeDisplayKnot = KnotForView(celticLargeKnot, CelticLargeView);
celticLargeWidth =
    KnotCelticGridColumnCount(celticLargeGrid) * CelticLargeCellSize;
celticLargeHeight = len(celticLargeGrid) * CelticLargeCellSize;

echo(
    "LogoSC large Celtic grid",
    CelticLargeExample,
    "rows",
    len(celticLargeGrid),
    "columns",
    KnotCelticGridColumnCount(celticLargeGrid),
    "occupied",
    len([
        for (row = celticLargeGrid)
            for (column = [0 : len(row) - 1])
                if (!KnotCelticTileIsBlank(row[column]))
                    row[column]
    ]),
    "components",
    len(KnotStrands(celticLargeKnot)),
    "crossings",
    len(KnotCrossings(celticLargeKnot)),
    "segments",
    KnotCordSegmentCount(celticLargeKnot)
);

if (CelticLargeOutput != "Topology")
{
    translate([-celticLargeWidth / 2, celticLargeHeight / 2, 0])
    {
        if (CelticLargeOutput == "Cord")
        {
            RenderKnotCords(
                celticLargeDisplayKnot,
                cordRadius = CelticLargeCordRadius,
                fragments = CelticLargeCordFragments
            );
        }
        else if (CelticLargeOutput == "Ribbon")
        {
            RenderKnotRibbons2D(
                KnotForView(celticLargeKnot, "Planar"),
                ribbonWidth = CelticLargeRibbonWidth,
                crossingClearance = CelticLargeRibbonClearance,
                arcFragments = CelticLargeRibbonFragments
            );
        }
        else
        {
            RenderKnotBasReliefPlaque(
                KnotForView(celticLargeKnot, "Planar"),
                ribbonWidth = CelticLargeRibbonWidth,
                crossingClearance = CelticLargeRibbonClearance,
                plateThickness = CelticLargePlateThickness,
                plateMargin = CelticLargePlateMargin,
                plateCornerRadius = CelticLargePlateCornerRadius,
                baseHeight = CelticLargeReliefBaseHeight,
                overpassHeight = CelticLargeReliefOverpassHeight,
                arcFragments = CelticLargeRibbonFragments,
                plateColor = CelticLargeUsePreviewColors
                    ? CelticLargePlateColor
                    : undef,
                reliefColor = CelticLargeUsePreviewColors
                    ? CelticLargeKnotColor
                    : undef,
                plateEdgeStyle = CelticLargePlateEdgeStyle,
                plateBevelWidth = CelticLargePlateBevelWidth,
                plateBevelHeight = CelticLargePlateBevelHeight
            );
        }
    }
}
