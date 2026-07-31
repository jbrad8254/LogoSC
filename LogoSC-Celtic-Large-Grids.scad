include <LogoSC-Knots.scad>

/* [Large Celtic Scene] */

CelticLargeExample = "CELTIC"; // [Diamond8,Ring16,Diamond24,Ring32,CELTIC]

/* [Output] */

CelticLargeOutput = "Cord"; // [Topology,Cord,Ribbon]
CelticLargeView = "Spatial"; // [Planar,Spatial]

/* [Geometry] */

CelticLargeCellSize = 4; // [2:0.5:12]
CelticLargeCrossingHeight = 2; // [0.5:0.5:8]
CelticLargeCordRadius = 0.45; // [0.1:0.05:2]
CelticLargeCordFragments = 8; // [4:1:32]
CelticLargeRibbonWidth = 0.9; // [0.2:0.1:4]
CelticLargeRibbonClearance = 0.3; // [0:0.05:2]
CelticLargeRibbonFragments = 6; // [2:1:24]

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
    || CelticLargeOutput == "Ribbon",
    "Large Celtic output must be Topology, Cord, or Ribbon."
);
assert(
    CelticLargeView == "Planar" || CelticLargeView == "Spatial",
    "Large Celtic view must be Planar or Spatial."
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
        else
        {
            RenderKnotRibbons2D(
                KnotForView(celticLargeKnot, "Planar"),
                ribbonWidth = CelticLargeRibbonWidth,
                crossingClearance = CelticLargeRibbonClearance,
                arcFragments = CelticLargeRibbonFragments
            );
        }
    }
}
