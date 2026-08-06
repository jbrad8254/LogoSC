include <LogoSC-Knots.scad>

/* [Large Celtic Scene] */

CelticLargeExample = "CELTIC *"; // [Diamond8,Ring16 *,Diamond24 *,Ring32 **,CELTIC *,LOGOSC128 ***]

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

function CelticLargeCanonicalExampleName(name) =
    name == "Ring16 *" || name == "Ring16 (*)" ? "Ring16"
    : name == "Diamond24 *" || name == "Diamond24 (*)" ? "Diamond24"
    : name == "Ring32 **" || name == "Ring32 (**)" ? "Ring32"
    : name == "CELTIC *" || name == "CELTIC (*)" ? "CELTIC"
    : name == "LOGOSC128 ***" || name == "LOGOSC128 (***)" ? "LOGOSC128"
    : name;

CelticLargeSelectedExample = CelticLargeCanonicalExampleName(CelticLargeExample);
CelticLargeSelectedOutput = CelticLargeOutput;

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
    : letter == "O"
        ? [".XXX.", "X...X", "X...X", "X...X", "X...X", "X...X", ".XXX."]
    : letter == "G"
        ? [".XXX.", "X...X", "X....", "X.XXX", "X...X", "X...X", ".XXX."]
    : letter == "S"
        ? [".XXXX", "X....", "X....", ".XXX.", "....X", "....X", "XXXX."]
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

CelticLogoWord = ["L", "O", "G", "O", "S", "C"];
CelticLogoColumns = 128;
CelticLogoRows = 32;
CelticLogoGlyphWidth = 18;
CelticLogoGlyphHeight = 24;
CelticLogoGlyphGap = 2;
CelticLogoLeftPadding = 5;
CelticLogoTopPadding = 4;

function CelticLogoHorizontalStroke(row, column, strokeRow) =
    row == strokeRow;

function CelticLogoLeftStroke(row, column, startRow, endRow) =
    column == 0 && row >= startRow && row <= endRow;

function CelticLogoRightStroke(row, column, startRow, endRow) =
    column == CelticLogoGlyphWidth - 1
    && row >= startRow
    && row <= endRow;

function CelticLogoGlyphCell(letter, row, column) =
    letter == "L"
    ? CelticLogoLeftStroke(row, column, 0, CelticLogoGlyphHeight - 1)
        || row == CelticLogoGlyphHeight - 1
    : letter == "O"
        ? CelticLogoHorizontalStroke(row, column, 0)
            || CelticLogoHorizontalStroke(
                row, column, CelticLogoGlyphHeight - 2
            )
            || CelticLogoLeftStroke(
                row, column, 0, CelticLogoGlyphHeight - 1
            )
            || CelticLogoRightStroke(
                row, column, 0, CelticLogoGlyphHeight - 1
            )
    : letter == "G"
        ? CelticLogoHorizontalStroke(row, column, 0)
            || CelticLogoHorizontalStroke(
                row, column, CelticLogoGlyphHeight - 2
            )
            || CelticLogoLeftStroke(
                row, column, 0, CelticLogoGlyphHeight - 1
            )
            || CelticLogoRightStroke(
                row, column, floor(CelticLogoGlyphHeight / 2),
                CelticLogoGlyphHeight - 1
            )
            || (
                row == floor(CelticLogoGlyphHeight / 2)
                && column >= 9
            )
    : letter == "S"
        ? CelticLogoHorizontalStroke(row, column, 0)
            || CelticLogoHorizontalStroke(
                row, column, floor(CelticLogoGlyphHeight / 2)
            )
            || CelticLogoHorizontalStroke(
                row, column, CelticLogoGlyphHeight - 2
            )
            || CelticLogoLeftStroke(
                row, column, 0, floor(CelticLogoGlyphHeight / 2)
            )
            || CelticLogoRightStroke(
                row, column, floor(CelticLogoGlyphHeight / 2),
                CelticLogoGlyphHeight - 1
            )
    : assert(letter == "C", "Unknown native LogoSC glyph.")
        CelticLogoHorizontalStroke(row, column, 0)
        || CelticLogoHorizontalStroke(
            row, column, CelticLogoGlyphHeight - 2
        )
        || CelticLogoLeftStroke(
            row, column, 0, CelticLogoGlyphHeight - 1
        );

function CelticLogoCellIsOccupied(row, column) =
    let(
        glyphRow = row - CelticLogoTopPadding,
        wordColumn = column - CelticLogoLeftPadding,
        glyphStride = CelticLogoGlyphWidth + CelticLogoGlyphGap,
        glyphIndex = floor(wordColumn / glyphStride),
        glyphColumn = wordColumn % glyphStride
    )
    glyphRow >= 0
    && glyphRow < CelticLogoGlyphHeight
    && wordColumn >= 0
    && wordColumn < len(CelticLogoWord) * CelticLogoGlyphWidth
        + (len(CelticLogoWord) - 1) * CelticLogoGlyphGap
    && glyphIndex < len(CelticLogoWord)
    && glyphColumn < CelticLogoGlyphWidth
    && CelticLogoGlyphCell(
        CelticLogoWord[glyphIndex], glyphRow, glyphColumn
    );

function CelticLogoRow(row, column = 0, result = "") =
    column >= CelticLogoColumns
    ? result
    : CelticLogoRow(
        row,
        column + 1,
        str(
            result,
            CelticLogoCellIsOccupied(row, column)
            ? CelticLargeTile(row, column)
            : "."
        )
    );

function CelticLogoGrid() =
[
    for (row = [0 : CelticLogoRows - 1])
        CelticLogoRow(row)
];

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
    example == "LOGOSC128"
    ? CelticLogoGrid()
    : example == "CELTIC"
    ? CelticLargeWordGrid()
    : CelticLargeMaskGrid(
        CelticLargeExampleSize(example),
        CelticLargeExamplePattern(example)
    );

function CelticLargeTimeEstimate(example, output) =
    example == "LOGOSC128"
    ? output == "Topology"
        ? "several minutes"
        : output == "Cord"
            ? "at least 3 minutes"
            : "potentially much longer than 3 minutes"
    : output == "Topology"
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
    CelticLargeSelectedExample == "Diamond8"
    || CelticLargeSelectedExample == "Ring16"
    || CelticLargeSelectedExample == "Diamond24"
    || CelticLargeSelectedExample == "Ring32"
    || CelticLargeSelectedExample == "CELTIC"
    || CelticLargeSelectedExample == "LOGOSC128",
    "Unknown large Celtic example."
);
assert(
    CelticLargeSelectedOutput == "Topology"
    || CelticLargeSelectedOutput == "Cord"
    || CelticLargeSelectedOutput == "Ribbon"
    || CelticLargeSelectedOutput == "Plaque",
    "Large Celtic output must be Topology, Cord, Ribbon, or Plaque."
);
assert(
    CelticLargeView == "Planar" || CelticLargeView == "Spatial",
    "Large Celtic view must be Planar or Spatial."
);

echo(
    "LogoSC large Celtic grid: working; this may take time",
    "scene",
    CelticLargeSelectedExample,
    "output",
    CelticLargeSelectedOutput,
    "estimated on the development machine",
    CelticLargeTimeEstimate(CelticLargeSelectedExample, CelticLargeSelectedOutput),
    "actual time may vary"
);

celticLargeGrid = CelticLargeExampleGrid(CelticLargeSelectedExample);
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
    CelticLargeSelectedExample,
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

if (CelticLargeSelectedOutput != "Topology")
{
    translate([-celticLargeWidth / 2, celticLargeHeight / 2, 0])
    {
        if (CelticLargeSelectedOutput == "Cord")
        {
            RenderKnotCords(
                celticLargeDisplayKnot,
                cordRadius = CelticLargeCordRadius,
                fragments = CelticLargeCordFragments
            );
        }
        else if (CelticLargeSelectedOutput == "Ribbon")
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
