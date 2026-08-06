#include <algorithm>
#include <chrono>
#include <cctype>
#include <condition_variable>
#include <cstdint>
#include <cstdlib>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <map>
#include <mutex>
#include <numbers>
#include <sstream>
#include <stdexcept>
#include <string>
#include <thread>
#include <unordered_map>
#include <utility>
#include <vector>

namespace
{
using Grid = std::vector<std::string>;

struct Glyph
{
    Grid pixels;
    int advance = 0;
};
struct Font
{
    std::map<unsigned char, Glyph> glyphs;
};
struct Options
{
    std::string text;
    std::filesystem::path inputPath;
    std::filesystem::path outputPath = "logosc-knot.grid";
    std::filesystem::path scadOutputPath;
    std::filesystem::path knotScadOutputPath;
    std::filesystem::path svgOutputPath;
    std::string scadVariable = "GeneratedCelticGrid";
    std::string knotScadVariable = "GeneratedCelticKnot";
    std::string font = "builtin-5x7";
    std::string pattern = "cycle";
    std::string scaleMode = "pixels";
    std::string lineEnding = "native";
    int width = 128, height = 32, marginX = 2, marginY = 2, glyphGap = 1, scale = 0;
    int samplesPerTile = 4, samplesPerBoundary = 2;
    double cellSize = 4.0, crossingHeight = 2.0, ribbonWidth = 0.9, crossingClearance = 0.3;
    bool quiet = false, selfTest = false, help = false;
};

class ProgressReporter
{
  public:
    explicit ProgressReporter(bool enabled) : enabled_(enabled)
    {
        if (enabled_)
            worker_ = std::thread(
                [this]
                {
                    std::unique_lock lock(mutex_);
                    if (condition_.wait_for(lock, std::chrono::seconds(2), [this] { return done_; }))
                        return;
                    started_ = true;
                    std::cerr << "Working" << std::flush;
                    while (!condition_.wait_for(lock, std::chrono::seconds(1), [this] { return done_; }))
                        std::cerr << '.' << std::flush;
                });
    }
    ProgressReporter(const ProgressReporter&) = delete;
    ~ProgressReporter()
    {
        {
            std::lock_guard lock(mutex_);
            done_ = true;
        }
        condition_.notify_all();
        if (worker_.joinable())
            worker_.join();
        if (started_)
            std::cerr << '\n';
    }

  private:
    bool enabled_ = false, done_ = false, started_ = false;
    std::mutex mutex_;
    std::condition_variable condition_;
    std::thread worker_;
};

[[noreturn]] void Fail(const std::string& message)
{
    throw std::runtime_error(message);
}

int ParseInt(const std::string& value, const std::string& option, bool allowZero = false)
{
    std::size_t consumed = 0;
    int result = 0;
    try
    {
        result = std::stoi(value, &consumed);
    }
    catch (...)
    {
        Fail(option + " requires an integer, received: " + value);
    }
    if (consumed != value.size() || result < (allowZero ? 0 : 1))
        Fail(option + " requires a " + std::string(allowZero ? "non-negative" : "positive") + " integer.");
    return result;
}

// Parses one finite nonnegative CLI quantity and reports the originating option on failure.
// Preconditions: value is a complete numeric token. Postcondition: returns an accepted value.
// Time O(value length), space O(1).
double ParseDouble(const std::string& value, const std::string& option, bool allowZero = false)
{
    std::size_t consumed = 0;
    double result = 0;
    try
    {
        result = std::stod(value, &consumed);
    }
    catch (...)
    {
        Fail(option + " requires a number, received: " + value);
    }
    if (consumed != value.size() || !std::isfinite(result) || result < 0 || (!allowZero && result == 0))
        Fail(option + " requires a " + std::string(allowZero ? "non-negative" : "positive") + " number.");
    return result;
}

Options ParseOptions(int argc, char** argv)
{
    Options options;
    auto value = [&](int& index, const std::string& option)
    {
        if (++index >= argc)
            Fail(option + " requires a value.");
        return std::string(argv[index]);
    };
    for (int index = 1; index < argc; ++index)
    {
        const std::string argument = argv[index];
        if (argument == "--text")
            options.text = value(index, argument);
        else if (argument == "--input")
            options.inputPath = value(index, argument);
        else if (argument == "--output" || argument == "-o")
            options.outputPath = value(index, argument);
        else if (argument == "--scad-output")
            options.scadOutputPath = value(index, argument);
        else if (argument == "--knot-scad-output")
            options.knotScadOutputPath = value(index, argument);
        else if (argument == "--svg-output")
            options.svgOutputPath = value(index, argument);
        else if (argument == "--scad-variable")
            options.scadVariable = value(index, argument);
        else if (argument == "--knot-scad-variable")
            options.knotScadVariable = value(index, argument);
        else if (argument == "--font")
            options.font = value(index, argument);
        else if (argument == "--pattern")
            options.pattern = value(index, argument);
        else if (argument == "--scale-mode")
            options.scaleMode = value(index, argument);
        else if (argument == "--line-ending")
            options.lineEnding = value(index, argument);
        else if (argument == "--width")
            options.width = ParseInt(value(index, argument), argument);
        else if (argument == "--height")
            options.height = ParseInt(value(index, argument), argument);
        else if (argument == "--margin-x")
            options.marginX = ParseInt(value(index, argument), argument, true);
        else if (argument == "--margin-y")
            options.marginY = ParseInt(value(index, argument), argument, true);
        else if (argument == "--glyph-gap")
            options.glyphGap = ParseInt(value(index, argument), argument, true);
        else if (argument == "--scale")
            options.scale = ParseInt(value(index, argument), argument, true);
        else if (argument == "--samples-per-tile")
            options.samplesPerTile = ParseInt(value(index, argument), argument);
        else if (argument == "--samples-per-boundary")
            options.samplesPerBoundary = ParseInt(value(index, argument), argument);
        else if (argument == "--cell-size")
            options.cellSize = ParseDouble(value(index, argument), argument);
        else if (argument == "--crossing-height")
            options.crossingHeight = ParseDouble(value(index, argument), argument);
        else if (argument == "--ribbon-width")
            options.ribbonWidth = ParseDouble(value(index, argument), argument);
        else if (argument == "--crossing-clearance")
            options.crossingClearance = ParseDouble(value(index, argument), argument, true);
        else if (argument == "--quiet")
            options.quiet = true;
        else if (argument == "--self-test")
            options.selfTest = true;
        else if (argument == "--help" || argument == "-h")
            options.help = true;
        else
            Fail("Unknown option: " + argument);
    }
    return options;
}

void PrintHelp()
{
    std::cout << R"(logosc-knot-grid - generate or validate LogoSC Celtic tile grids

Usage:
  logosc-knot-grid --text TEXT [options]
  logosc-knot-grid --input GRID [options]

Options:
  --output, -o PATH       Plain ASCII grid output (default logosc-knot.grid)
  --width N               Output columns for text generation (default 128)
  --height N              Output rows for text generation (default 32)
  --font NAME_OR_BDF      builtin-5x7 or a BDF bitmap-font path
  --scale N               Integer pixel scale; 0 selects the largest fit
  --scale-mode NAME       pixels or stroke (default pixels)
  --glyph-gap N           Unscaled columns between glyphs (default 1)
  --margin-x N            Minimum horizontal margin (default 2)
  --margin-y N            Minimum vertical margin (default 2)
  --pattern NAME          cycle, checker, or cross (default cycle)
  --line-ending NAME      native, crlf, cr, or lf (default native)
  --scad-output PATH      Also write an OpenSCAD adapter containing the rows
  --scad-variable NAME    Adapter variable (default GeneratedCelticGrid)
  --knot-scad-output PATH Write compatible sampled knot/crossing records
  --knot-scad-variable N  Knot record variable (default GeneratedCelticKnot)
  --svg-output PATH       Write finished interlaced ribbon SVG
  --cell-size N           Tile size in output units (default 4)
  --samples-per-tile N    Even samples per tile, at least 4 (default 4)
  --samples-per-boundary N  Samples per boundary connector, at least 2
  --crossing-height N     Sampled record crossing height (default 2)
  --ribbon-width N        SVG ribbon width (default 0.9)
  --crossing-clearance N  SVG underpass clearance (default 0.3)
  --quiet                 Suppress summary and delayed progress dots
  --self-test             Run deterministic built-in tests
  --help, -h              Show this help

Grid files contain only rectangular rows of X, >, <, and . characters. Rows
are not quoted and have no separators other than their line endings.
)";
}

Glyph MakeGlyph(std::initializer_list<const char*> rows)
{
    Glyph glyph;
    for (const char* row : rows)
        glyph.pixels.emplace_back(row);
    glyph.advance = glyph.pixels.empty() ? 0 : static_cast<int>(glyph.pixels.front().size());
    return glyph;
}

Font BuiltinFont()
{
    Font font;
    auto add = [&](char c, std::initializer_list<const char*> rows)
    { font.glyphs[static_cast<unsigned char>(c)] = MakeGlyph(rows); };
    add('A', {".XXX.", "X...X", "X...X", "XXXXX", "X...X", "X...X", "X...X"});
    add('B', {"XXXX.", "X...X", "X...X", "XXXX.", "X...X", "X...X", "XXXX."});
    add('C', {".XXX.", "X...X", "X....", "X....", "X....", "X...X", ".XXX."});
    add('D', {"XXXX.", "X...X", "X...X", "X...X", "X...X", "X...X", "XXXX."});
    add('E', {"XXXXX", "X....", "X....", "XXXX.", "X....", "X....", "XXXXX"});
    add('F', {"XXXXX", "X....", "X....", "XXXX.", "X....", "X....", "X...."});
    add('G', {".XXX.", "X...X", "X....", "X.XXX", "X...X", "X...X", ".XXX."});
    add('H', {"X...X", "X...X", "X...X", "XXXXX", "X...X", "X...X", "X...X"});
    add('I', {"XXXXX", "..X..", "..X..", "..X..", "..X..", "..X..", "XXXXX"});
    add('J', {"..XXX", "...X.", "...X.", "...X.", "X..X.", "X..X.", ".XX.."});
    add('K', {"X...X", "X..X.", "X.X..", "XX...", "X.X..", "X..X.", "X...X"});
    add('L', {"X....", "X....", "X....", "X....", "X....", "X....", "XXXXX"});
    add('M', {"X...X", "XX.XX", "X.X.X", "X.X.X", "X...X", "X...X", "X...X"});
    add('N', {"X...X", "XX..X", "XX..X", "X.X.X", "X..XX", "X..XX", "X...X"});
    add('O', {".XXX.", "X...X", "X...X", "X...X", "X...X", "X...X", ".XXX."});
    add('P', {"XXXX.", "X...X", "X...X", "XXXX.", "X....", "X....", "X...."});
    add('Q', {".XXX.", "X...X", "X...X", "X...X", "X.X.X", "X..X.", ".XX.X"});
    add('R', {"XXXX.", "X...X", "X...X", "XXXX.", "X.X..", "X..X.", "X...X"});
    add('S', {".XXXX", "X....", "X....", ".XXX.", "....X", "....X", "XXXX."});
    add('T', {"XXXXX", "..X..", "..X..", "..X..", "..X..", "..X..", "..X.."});
    add('U', {"X...X", "X...X", "X...X", "X...X", "X...X", "X...X", ".XXX."});
    add('V', {"X...X", "X...X", "X...X", "X...X", "X...X", ".X.X.", "..X.."});
    add('W', {"X...X", "X...X", "X...X", "X.X.X", "X.X.X", "XX.XX", "X...X"});
    add('X', {"X...X", "X...X", ".X.X.", "..X..", ".X.X.", "X...X", "X...X"});
    add('Y', {"X...X", "X...X", ".X.X.", "..X..", "..X..", "..X..", "..X.."});
    add('Z', {"XXXXX", "....X", "...X.", "..X..", ".X...", "X....", "XXXXX"});
    add('0', {".XXX.", "X...X", "X..XX", "X.X.X", "XX..X", "X...X", ".XXX."});
    add('1', {"..X..", ".XX..", "..X..", "..X..", "..X..", "..X..", ".XXX."});
    add('2', {".XXX.", "X...X", "....X", "...X.", "..X..", ".X...", "XXXXX"});
    add('3', {"XXXX.", "....X", "....X", ".XXX.", "....X", "....X", "XXXX."});
    add('4', {"...X.", "..XX.", ".X.X.", "X..X.", "XXXXX", "...X.", "...X."});
    add('5', {"XXXXX", "X....", "X....", "XXXX.", "....X", "....X", "XXXX."});
    add('6', {".XXX.", "X....", "X....", "XXXX.", "X...X", "X...X", ".XXX."});
    add('7', {"XXXXX", "....X", "...X.", "..X..", ".X...", ".X...", ".X..."});
    add('8', {".XXX.", "X...X", "X...X", ".XXX.", "X...X", "X...X", ".XXX."});
    add('9', {".XXX.", "X...X", "X...X", ".XXXX", "....X", "....X", ".XXX."});
    add('-', {".....", ".....", ".....", "XXXXX", ".....", ".....", "....."});
    add('_', {".....", ".....", ".....", ".....", ".....", ".....", "XXXXX"});
    add('?', {".XXX.", "X...X", "....X", "...X.", "..X..", ".....", "..X.."});
    add(' ', {"...", "...", "...", "...", "...", "...", "..."});
    return font;
}

int HexValue(char c)
{
    if (c >= '0' && c <= '9')
        return c - '0';
    if (c >= 'A' && c <= 'F')
        return c - 'A' + 10;
    if (c >= 'a' && c <= 'f')
        return c - 'a' + 10;
    Fail(std::string("Invalid hexadecimal digit in BDF bitmap: ") + c);
}

Font LoadBdfFont(const std::filesystem::path& path)
{
    std::ifstream input(path);
    if (!input)
        Fail("Cannot open BDF font: " + path.string());
    Font font;
    std::string line;
    int encoding = -1, width = 0, height = 0, advance = 0;
    bool inBitmap = false;
    Grid bitmap;
    auto finish = [&]
    {
        if (encoding >= 0 && encoding <= 255 && !bitmap.empty())
            font.glyphs[static_cast<unsigned char>(encoding)] = Glyph{bitmap, advance > 0 ? advance : width};
        encoding = -1;
        width = height = advance = 0;
        inBitmap = false;
        bitmap.clear();
    };
    while (std::getline(input, line))
    {
        if (!line.empty() && line.back() == '\r')
            line.pop_back();
        if (line.rfind("STARTCHAR ", 0) == 0)
            finish();
        else if (line.rfind("ENCODING ", 0) == 0)
            encoding = std::stoi(line.substr(9));
        else if (line.rfind("DWIDTH ", 0) == 0)
        {
            std::istringstream values(line.substr(7));
            values >> advance;
        }
        else if (line.rfind("BBX ", 0) == 0)
        {
            std::istringstream values(line.substr(4));
            int ignored;
            values >> width >> height >> ignored >> ignored;
        }
        else if (line == "BITMAP")
            inBitmap = true;
        else if (line == "ENDCHAR")
            finish();
        else if (inBitmap)
        {
            std::string row;
            for (int column = 0; column < width; ++column)
            {
                const std::size_t hexIndex = static_cast<std::size_t>(column / 4);
                const int bit = 3 - column % 4;
                row.push_back(hexIndex < line.size() && ((HexValue(line[hexIndex]) >> bit) & 1) ? 'X' : '.');
            }
            bitmap.push_back(std::move(row));
        }
    }
    finish();
    if (font.glyphs.empty())
        Fail("BDF font contains no byte-addressable glyphs: " + path.string());
    return font;
}

Font LoadFont(const std::string& name)
{
    return name == "builtin-5x7" ? BuiltinFont() : LoadBdfFont(name);
}

const Glyph& FindGlyph(const Font& font, unsigned char character)
{
    auto found = font.glyphs.find(character);
    if (found == font.glyphs.end() && character >= 'a' && character <= 'z')
        found = font.glyphs.find(static_cast<unsigned char>(character - 'a' + 'A'));
    if (found == font.glyphs.end())
        found = font.glyphs.find('?');
    if (found == font.glyphs.end())
        Fail("Font does not contain glyph code " + std::to_string(character) + '.');
    return found->second;
}

int GlyphLayoutWidth(const Glyph& glyph)
{
    std::size_t bitmapWidth = 0;
    for (const auto& row : glyph.pixels)
        bitmapWidth = std::max(bitmapWidth, row.size());
    return std::max(glyph.advance, static_cast<int>(bitmapWidth));
}

Grid RenderTextMask(const Options& options, const Font& font)
{
    if (options.text.empty())
        Fail("--text must not be empty.");
    if (options.width <= 2 * options.marginX || options.height <= 2 * options.marginY)
        Fail("Output dimensions must exceed twice their margins.");
    int contentWidth = 0, contentHeight = 0;
    for (std::size_t index = 0; index < options.text.size(); ++index)
    {
        const Glyph& glyph = FindGlyph(font, static_cast<unsigned char>(options.text[index]));
        contentWidth += GlyphLayoutWidth(glyph) + (index + 1 < options.text.size() ? options.glyphGap : 0);
        contentHeight = std::max(contentHeight, static_cast<int>(glyph.pixels.size()));
    }
    const int availableWidth = options.width - 2 * options.marginX;
    const int availableHeight = options.height - 2 * options.marginY;
    const int fitScale = std::min(availableWidth / contentWidth, availableHeight / contentHeight);
    const int scale = options.scale == 0 ? fitScale : options.scale;
    if (scale < 1 || contentWidth * scale > availableWidth || contentHeight * scale > availableHeight)
        Fail("Text does not fit the requested dimensions, margins, and scale.");

    if (options.scaleMode != "pixels" && options.scaleMode != "stroke")
        Fail("--scale-mode must be pixels or stroke.");

    Grid source(static_cast<std::size_t>(contentHeight), std::string(static_cast<std::size_t>(contentWidth), '.'));
    int sourceCursorX = 0;
    for (unsigned char character : options.text)
    {
        const Glyph& glyph = FindGlyph(font, character);
        const int top = contentHeight - static_cast<int>(glyph.pixels.size());
        for (std::size_t row = 0; row < glyph.pixels.size(); ++row)
            for (std::size_t column = 0; column < glyph.pixels[row].size(); ++column)
                if (glyph.pixels[row][column] != '.')
                    source[static_cast<std::size_t>(top + static_cast<int>(row))]
                          [static_cast<std::size_t>(sourceCursorX + static_cast<int>(column))] = 'X';
        sourceCursorX += GlyphLayoutWidth(glyph) + options.glyphGap;
    }

    Grid mask(static_cast<std::size_t>(options.height), std::string(static_cast<std::size_t>(options.width), '.'));
    const int originX = (options.width - contentWidth * scale) / 2;
    const int originY = (options.height - contentHeight * scale) / 2;
    if (options.scaleMode == "pixels")
    {
        for (int row = 0; row < contentHeight; ++row)
            for (int column = 0; column < contentWidth; ++column)
                if (source[static_cast<std::size_t>(row)][static_cast<std::size_t>(column)] != '.')
                    for (int dy = 0; dy < scale; ++dy)
                        for (int dx = 0; dx < scale; ++dx)
                            mask[static_cast<std::size_t>(originY + row * scale + dy)]
                                [static_cast<std::size_t>(originX + column * scale + dx)] = 'X';
    }
    else
    {
        auto occupied = [&](int row, int column)
        {
            return row >= 0 && row < contentHeight && column >= 0 && column < contentWidth &&
                   source[static_cast<std::size_t>(row)][static_cast<std::size_t>(column)] != '.';
        };
        auto point = [&](int row, int column)
        { return std::pair<int, int>{originX + column * scale + scale / 2, originY + row * scale + scale / 2}; };
        auto drawLine = [&](std::pair<int, int> start, std::pair<int, int> end)
        {
            int x = start.first, y = start.second;
            const int dx = std::abs(end.first - x), sx = x < end.first ? 1 : -1;
            const int dy = -std::abs(end.second - y), sy = y < end.second ? 1 : -1;
            int error = dx + dy;
            while (true)
            {
                mask[static_cast<std::size_t>(y)][static_cast<std::size_t>(x)] = 'X';
                if (x == end.first && y == end.second)
                    break;
                const int twiceError = 2 * error;
                if (twiceError >= dy)
                {
                    error += dy;
                    x += sx;
                }
                if (twiceError <= dx)
                {
                    error += dx;
                    y += sy;
                }
            }
        };
        for (int row = 0; row < contentHeight; ++row)
            for (int column = 0; column < contentWidth; ++column)
                if (occupied(row, column))
                {
                    const auto start = point(row, column);
                    drawLine(start, start);
                    if (occupied(row, column + 1))
                        drawLine(start, point(row, column + 1));
                    if (occupied(row + 1, column))
                        drawLine(start, point(row + 1, column));
                    if (occupied(row + 1, column + 1) && !occupied(row, column + 1) && !occupied(row + 1, column))
                        drawLine(start, point(row + 1, column + 1));
                    if (occupied(row + 1, column - 1) && !occupied(row, column - 1) && !occupied(row + 1, column))
                        drawLine(start, point(row + 1, column - 1));
                }
    }
    return mask;
}

char TileFor(const std::string& pattern, int row, int column)
{
    if (pattern == "cross")
        return 'X';
    if (pattern == "checker")
        return (row + column) % 2 == 0 ? '>' : '<';
    if (pattern == "cycle")
        return (row + column) % 3 == 0 ? 'X' : ((row + column) % 2 == 0 ? '>' : '<');
    Fail("Unknown tile pattern: " + pattern + ". Expected cycle, checker, or cross.");
}

Grid ApplyPattern(Grid grid, const std::string& pattern)
{
    for (std::size_t row = 0; row < grid.size(); ++row)
        for (std::size_t column = 0; column < grid[row].size(); ++column)
            if (grid[row][column] != '.')
                grid[row][column] = TileFor(pattern, static_cast<int>(row), static_cast<int>(column));
    return grid;
}

void ValidateGrid(const Grid& grid)
{
    if (grid.empty() || grid.front().empty())
        Fail("Grid must contain at least one non-empty row.");
    const std::size_t width = grid.front().size();
    for (std::size_t row = 0; row < grid.size(); ++row)
    {
        if (grid[row].size() != width)
            Fail("Grid row " + std::to_string(row + 1) + " is not rectangular.");
        for (char tile : grid[row])
            if (tile != 'X' && tile != '>' && tile != '<' && tile != '.')
                Fail("Grid row " + std::to_string(row + 1) + " contains invalid tile character: " + tile);
    }
}

Grid ReadGrid(const std::filesystem::path& path)
{
    std::ifstream input(path, std::ios::binary);
    if (!input)
        Fail("Cannot open grid input: " + path.string());
    const std::string contents{std::istreambuf_iterator<char>(input), std::istreambuf_iterator<char>()};
    Grid grid;
    std::string row;
    for (std::size_t index = 0; index < contents.size(); ++index)
    {
        const char character = contents[index];
        if (character == '\r' || character == '\n')
        {
            if (row.empty())
                Fail("Grid contains an empty row.");
            grid.push_back(row);
            row.clear();
            if (character == '\r' && index + 1 < contents.size() && contents[index + 1] == '\n')
                ++index;
        }
        else
            row.push_back(character);
    }
    if (!row.empty())
        grid.push_back(row);
    ValidateGrid(grid);
    return grid;
}

std::string LineEnding(const std::string& requested)
{
    if (requested == "crlf")
        return "\r\n";
    if (requested == "cr")
        return "\r";
    if (requested == "lf")
        return "\n";
    if (requested != "native")
        Fail("--line-ending must be native, crlf, cr, or lf.");
#ifdef _WIN32
    return "\r\n";
#else
    return "\n";
#endif
}

void WriteGrid(const Grid& grid, const std::filesystem::path& path, const std::string& ending)
{
    std::ofstream output(path, std::ios::binary);
    if (!output)
        Fail("Cannot open grid output: " + path.string());
    for (const std::string& row : grid)
        output << row << ending;
    if (!output)
        Fail("Failed while writing grid output: " + path.string());
}

bool IsIdentifier(const std::string& value)
{
    if (value.empty() || !(std::isalpha(static_cast<unsigned char>(value[0])) || value[0] == '_'))
        return false;
    return std::all_of(value.begin() + 1, value.end(), [](unsigned char c) { return std::isalnum(c) || c == '_'; });
}

void WriteScad(const Grid& grid, const Options& options)
{
    if (options.scadOutputPath.empty())
        return;
    if (!IsIdentifier(options.scadVariable))
        Fail("--scad-variable must be a valid OpenSCAD identifier.");
    std::ofstream output(options.scadOutputPath, std::ios::binary);
    if (!output)
        Fail("Cannot open OpenSCAD output: " + options.scadOutputPath.string());
    output << "// Generated by logosc-knot-grid. Do not edit by hand.\n" << options.scadVariable << " = [\n";
    for (std::size_t row = 0; row < grid.size(); ++row)
        output << "    \"" << grid[row] << "\"" << (row + 1 == grid.size() ? "\n" : ",\n");
    output << "];\n"
           << options.scadVariable << "Rows = " << grid.size() << ";\n"
           << options.scadVariable << "Columns = " << grid.front().size() << ";\n";
    int minimumRow = static_cast<int>(grid.size()), minimumColumn = static_cast<int>(grid.front().size());
    int maximumRow = -1, maximumColumn = -1;
    for (int row = 0; row < static_cast<int>(grid.size()); ++row)
        for (int column = 0; column < static_cast<int>(grid.front().size()); ++column)
            if (grid[static_cast<std::size_t>(row)][static_cast<std::size_t>(column)] != '.')
            {
                minimumRow = std::min(minimumRow, row);
                minimumColumn = std::min(minimumColumn, column);
                maximumRow = std::max(maximumRow, row);
                maximumColumn = std::max(maximumColumn, column);
            }
    output << options.scadVariable << "OccupiedCellBounds = [" << minimumColumn << ',' << minimumRow << ','
           << maximumColumn + 1 << ',' << maximumRow + 1 << "];\n";
}

std::uint64_t GridHash(const Grid& grid)
{
    std::uint64_t hash = 14695981039346656037ull;
    for (const auto& row : grid)
    {
        for (unsigned char c : row)
        {
            hash ^= c;
            hash *= 1099511628211ull;
        }
        hash ^= '\n';
        hash *= 1099511628211ull;
    }
    return hash;
}

enum Port
{
    North = 0,
    East = 1,
    South = 2,
    West = 3
};

struct State
{
    int row = 0, column = 0, port = 0;
};
struct Point3
{
    double x = 0, y = 0, z = 0;
};
struct Crossing
{
    double x = 0, y = 0;
    int strandA = 0, strandB = 0, overStrand = 0;
    double parameterA = 0, parameterB = 0;
    char overBranch = 'A';
};
struct Strand
{
    std::vector<Point3> samples;
    std::vector<int> encounters;
    std::vector<int> stateCycle;
};
struct CompiledKnot
{
    std::vector<Strand> strands;
    std::vector<Crossing> crossings;
    int rows = 0, columns = 0, occupied = 0, boundaryLoops = 0;
    double cellSize = 0, crossingHeight = 0;
    int samplesPerTile = 0, samplesPerBoundary = 0;
};

State StateFromId(int id, int columns)
{
    const int cell = id / 4;
    return {cell / columns, cell % columns, id % 4};
}

int StateId(const State& state, int columns)
{
    return (state.row * columns + state.column) * 4 + state.port;
}

std::pair<int, int> PortDelta(int port)
{
    if (port == North)
        return {-1, 0};
    if (port == East)
        return {0, 1};
    if (port == South)
        return {1, 0};
    return {0, -1};
}

int OppositePort(int port)
{
    return (port + 2) % 4;
}

bool Occupied(const Grid& grid, int row, int column)
{
    return row >= 0 && row < static_cast<int>(grid.size()) && column >= 0 &&
           column < static_cast<int>(grid.front().size()) &&
           grid[static_cast<std::size_t>(row)][static_cast<std::size_t>(column)] != '.';
}

int PairedPort(char tile, int port)
{
    if (tile == 'X')
        return OppositePort(port);
    if (tile == '>')
    {
        if (port == North)
            return East;
        if (port == East)
            return North;
        if (port == South)
            return West;
        return South;
    }
    if (tile == '<')
    {
        if (port == North)
            return West;
        if (port == West)
            return North;
        if (port == East)
            return South;
        return East;
    }
    Fail("Blank Celtic tile does not pair ports.");
}

State InternalState(const Grid& grid, const State& state)
{
    return {state.row, state.column,
            PairedPort(grid[static_cast<std::size_t>(state.row)][static_cast<std::size_t>(state.column)], state.port)};
}

std::pair<int, int> BoundaryStart(const State& state)
{
    if (state.port == North)
        return {state.row, state.column};
    if (state.port == East)
        return {state.row, state.column + 1};
    if (state.port == South)
        return {state.row + 1, state.column + 1};
    return {state.row + 1, state.column};
}

std::pair<int, int> BoundaryEnd(const State& state)
{
    if (state.port == North)
        return {state.row, state.column + 1};
    if (state.port == East)
        return {state.row + 1, state.column + 1};
    if (state.port == South)
        return {state.row + 1, state.column};
    return {state.row, state.column};
}

std::uint64_t VertexKey(const std::pair<int, int>& vertex)
{
    return (static_cast<std::uint64_t>(static_cast<std::uint32_t>(vertex.first)) << 32) |
           static_cast<std::uint32_t>(vertex.second);
}

int BoundaryTurnRank(int currentPort, int candidatePort)
{
    const int turn = (candidatePort - currentPort + 4) % 4;
    if (turn == 1)
        return 0;
    if (turn == 0)
        return 1;
    if (turn == 3)
        return 2;
    return 3;
}

struct Topology
{
    std::vector<std::vector<int>> boundaryLoops;
    std::vector<int> boundaryPartner;
    std::vector<std::vector<int>> cycles;
};

// Builds indexed boundary pairings and unique closed state cycles for a validated grid.
// Preconditions: grid is rectangular, valid, and nonempty. Postcondition: every occupied port
// belongs to one cycle. Time O(rows*columns + occupied ports), matching auxiliary space.
Topology TraceTopology(const Grid& grid)
{
    const int rows = static_cast<int>(grid.size());
    const int columns = static_cast<int>(grid.front().size());
    const int stateCount = rows * columns * 4;
    std::vector<int> exposed;
    std::unordered_map<std::uint64_t, std::vector<int>> startsAt;
    for (int row = 0; row < rows; ++row)
        for (int column = 0; column < columns; ++column)
            if (Occupied(grid, row, column))
                for (int port = 0; port < 4; ++port)
                {
                    const auto delta = PortDelta(port);
                    if (!Occupied(grid, row + delta.first, column + delta.second))
                    {
                        const int id = StateId({row, column, port}, columns);
                        exposed.push_back(id);
                        startsAt[VertexKey(BoundaryStart({row, column, port}))].push_back(id);
                    }
                }

    std::vector<int> successor(static_cast<std::size_t>(stateCount), -1);
    for (int id : exposed)
    {
        const State state = StateFromId(id, columns);
        const auto found = startsAt.find(VertexKey(BoundaryEnd(state)));
        if (found == startsAt.end() || found->second.empty())
            Fail("Exposed boundary edge has no successor.");
        int best = found->second.front();
        for (int candidate : found->second)
            if (BoundaryTurnRank(state.port, StateFromId(candidate, columns).port) <
                BoundaryTurnRank(state.port, StateFromId(best, columns).port))
                best = candidate;
        successor[static_cast<std::size_t>(id)] = best;
    }

    Topology topology;
    topology.boundaryPartner.assign(static_cast<std::size_t>(stateCount), -1);
    std::vector<bool> boundaryVisited(static_cast<std::size_t>(stateCount), false);
    for (int start : exposed)
        if (!boundaryVisited[static_cast<std::size_t>(start)])
        {
            std::vector<int> loop;
            int current = start;
            do
            {
                if (current < 0 || boundaryVisited[static_cast<std::size_t>(current)])
                    Fail("Exposed boundary entered a non-closing loop.");
                boundaryVisited[static_cast<std::size_t>(current)] = true;
                loop.push_back(current);
                current = successor[static_cast<std::size_t>(current)];
            } while (current != start);
            if (loop.size() % 2 != 0)
                Fail("Celtic boundary loop must have even length.");
            for (std::size_t index = 0; index < loop.size(); index += 2)
            {
                topology.boundaryPartner[static_cast<std::size_t>(loop[index])] = loop[index + 1];
                topology.boundaryPartner[static_cast<std::size_t>(loop[index + 1])] = loop[index];
            }
            topology.boundaryLoops.push_back(std::move(loop));
        }

    auto external = [&](const State& exit)
    {
        const auto delta = PortDelta(exit.port);
        const int nextRow = exit.row + delta.first, nextColumn = exit.column + delta.second;
        if (Occupied(grid, nextRow, nextColumn))
            return State{nextRow, nextColumn, OppositePort(exit.port)};
        const int partner = topology.boundaryPartner[static_cast<std::size_t>(StateId(exit, columns))];
        if (partner < 0)
            Fail("Celtic boundary partner was not found.");
        return StateFromId(partner, columns);
    };
    auto successorState = [&](int id)
    { return StateId(external(InternalState(grid, StateFromId(id, columns))), columns); };

    std::vector<bool> visited(static_cast<std::size_t>(stateCount), false);
    for (int start = 0; start < stateCount; ++start)
    {
        const State startState = StateFromId(start, columns);
        if (!Occupied(grid, startState.row, startState.column) || visited[static_cast<std::size_t>(start)])
            continue;
        std::vector<int> cycle;
        std::vector<bool> inPath(static_cast<std::size_t>(stateCount), false);
        int current = start;
        do
        {
            if (inPath[static_cast<std::size_t>(current)])
                Fail("Celtic route entered a non-closing cycle.");
            inPath[static_cast<std::size_t>(current)] = true;
            cycle.push_back(current);
            current = successorState(current);
        } while (current != start);
        for (int id : cycle)
        {
            visited[static_cast<std::size_t>(id)] = true;
            visited[static_cast<std::size_t>(StateId(InternalState(grid, StateFromId(id, columns)), columns))] = true;
        }
        topology.cycles.push_back(std::move(cycle));
    }
    return topology;
}

Point3 PortPoint(const State& state, double cellSize)
{
    const double x = (state.column + 0.5) * cellSize;
    const double y = -(state.row + 0.5) * cellSize;
    const double half = cellSize / 2;
    if (state.port == North)
        return {x, y + half, 0};
    if (state.port == East)
        return {x + half, y, 0};
    if (state.port == South)
        return {x, y - half, 0};
    return {x - half, y, 0};
}

Point3 Quadratic(const Point3& start, const Point3& control, const Point3& end, double blend)
{
    const double inverse = 1 - blend;
    return {start.x * inverse * inverse + control.x * 2 * inverse * blend + end.x * blend * blend,
            start.y * inverse * inverse + control.y * 2 * inverse * blend + end.y * blend * blend,
            start.z * inverse * inverse + control.z * 2 * inverse * blend + end.z * blend * blend};
}

Point3 TilePoint(const Grid& grid, const State& entry, double blend, const Options& options)
{
    const State exit = InternalState(grid, entry);
    const Point3 start = PortPoint(entry, options.cellSize), end = PortPoint(exit, options.cellSize);
    Point3 control;
    if (OppositePort(entry.port) == exit.port)
        control = {(start.x + end.x) / 2, (start.y + end.y) / 2, 0};
    else
        control = {entry.port == North || entry.port == South ? end.x : start.x,
                   entry.port == North || entry.port == South ? start.y : end.y, 0};
    Point3 point = Quadratic(start, control, end, blend);
    if (grid[static_cast<std::size_t>(entry.row)][static_cast<std::size_t>(entry.column)] == 'X')
    {
        const bool vertical =
            (entry.port == North && exit.port == South) || (entry.port == South && exit.port == North);
        const bool verticalOver = (entry.row + entry.column) % 2 == 0;
        point.z =
            (vertical == verticalOver ? 1 : -1) * options.crossingHeight * std::sin(3.14159265358979323846 * blend) / 2;
    }
    return point;
}

bool HasBoundaryConnector(const Grid& grid, int stateId)
{
    const int columns = static_cast<int>(grid.front().size());
    const State exit = InternalState(grid, StateFromId(stateId, columns));
    const auto delta = PortDelta(exit.port);
    return !Occupied(grid, exit.row + delta.first, exit.column + delta.second);
}

// Samples traced cycles and creates crossings compatible with LogoSC-Knots.scad records.
// Preconditions: grid and sampling options are valid. Postcondition: all strands are closed and
// crossing encounters are indexed. Time O(grid cells + output samples), space O(the same).
CompiledKnot CompileKnot(const Grid& grid, const Options& options)
{
    if (options.samplesPerTile < 4 || options.samplesPerTile % 2 != 0)
        Fail("--samples-per-tile must be an even integer of at least 4.");
    if (options.samplesPerBoundary < 2)
        Fail("--samples-per-boundary must be at least 2.");
    const int columns = static_cast<int>(grid.front().size());
    const int stateCount = static_cast<int>(grid.size()) * columns * 4;
    const Topology topology = TraceTopology(grid);
    CompiledKnot knot;
    knot.rows = static_cast<int>(grid.size());
    knot.columns = columns;
    knot.cellSize = options.cellSize;
    knot.crossingHeight = options.crossingHeight;
    knot.samplesPerTile = options.samplesPerTile;
    knot.samplesPerBoundary = options.samplesPerBoundary;
    knot.boundaryLoops = static_cast<int>(topology.boundaryLoops.size());
    for (const auto& row : grid)
        knot.occupied += static_cast<int>(std::count_if(row.begin(), row.end(), [](char c) { return c != '.'; }));

    auto external = [&](const State& exit)
    {
        const auto delta = PortDelta(exit.port);
        if (Occupied(grid, exit.row + delta.first, exit.column + delta.second))
            return State{exit.row + delta.first, exit.column + delta.second, OppositePort(exit.port)};
        return StateFromId(topology.boundaryPartner[static_cast<std::size_t>(StateId(exit, columns))], columns);
    };

    std::vector<std::pair<int, int>> stateOwner(static_cast<std::size_t>(stateCount), {-1, -1});
    std::vector<std::vector<int>> offsets(topology.cycles.size());
    for (std::size_t strandIndex = 0; strandIndex < topology.cycles.size(); ++strandIndex)
    {
        const auto& cycle = topology.cycles[strandIndex];
        Strand strand;
        strand.stateCycle = cycle;
        offsets[strandIndex].resize(cycle.size());
        for (std::size_t position = 0; position < cycle.size(); ++position)
        {
            const int stateId = cycle[position];
            offsets[strandIndex][position] = static_cast<int>(strand.samples.size());
            stateOwner[static_cast<std::size_t>(stateId)] = {static_cast<int>(strandIndex), static_cast<int>(position)};
            const State entry = StateFromId(stateId, columns);
            for (int sample = 0; sample < options.samplesPerTile; ++sample)
                strand.samples.push_back(
                    TilePoint(grid, entry, static_cast<double>(sample) / options.samplesPerTile, options));
            if (HasBoundaryConnector(grid, stateId))
            {
                const State exit = InternalState(grid, entry), next = external(exit);
                const Point3 start = PortPoint(exit, options.cellSize), end = PortPoint(next, options.cellSize);
                const auto outward = PortDelta(exit.port);
                const Point3 control{(start.x + end.x) / 2 + outward.second * options.cellSize * 0.45,
                                     (start.y + end.y) / 2 - outward.first * options.cellSize * 0.45, 0};
                for (int sample = 0; sample < options.samplesPerBoundary; ++sample)
                    strand.samples.push_back(
                        Quadratic(start, control, end, static_cast<double>(sample) / options.samplesPerBoundary));
            }
        }
        strand.samples.push_back(strand.samples.front());
        knot.strands.push_back(std::move(strand));
    }

    auto branch = [&](int row, int column, int portA, int portB)
    {
        std::pair<int, int> owner{-1, -1};
        for (int port : {portA, portB})
        {
            const auto candidate = stateOwner[static_cast<std::size_t>(StateId({row, column, port}, columns))];
            if (candidate.first >= 0)
            {
                owner = candidate;
                break;
            }
        }
        if (owner.first < 0)
            Fail("Celtic crossing branch was not found in a traced cycle.");
        const int offset = offsets[static_cast<std::size_t>(owner.first)][static_cast<std::size_t>(owner.second)];
        const int segments = static_cast<int>(knot.strands[static_cast<std::size_t>(owner.first)].samples.size()) - 1;
        return std::pair<int, double>{owner.first, static_cast<double>(offset + options.samplesPerTile / 2) / segments};
    };
    for (int row = 0; row < knot.rows; ++row)
        for (int column = 0; column < knot.columns; ++column)
            if (grid[static_cast<std::size_t>(row)][static_cast<std::size_t>(column)] == 'X')
            {
                const auto vertical = branch(row, column, North, South);
                const auto horizontal = branch(row, column, East, West);
                const bool verticalOver = (row + column) % 2 == 0;
                knot.crossings.push_back({(column + 0.5) * options.cellSize, -(row + 0.5) * options.cellSize,
                                          vertical.first, horizontal.first,
                                          verticalOver ? vertical.first : horizontal.first, vertical.second,
                                          horizontal.second, verticalOver ? 'A' : 'B'});
            }
    for (std::size_t crossingIndex = 0; crossingIndex < knot.crossings.size(); ++crossingIndex)
    {
        const Crossing& crossing = knot.crossings[crossingIndex];
        knot.strands[static_cast<std::size_t>(crossing.strandA)].encounters.push_back(static_cast<int>(crossingIndex));
        knot.strands[static_cast<std::size_t>(crossing.strandB)].encounters.push_back(static_cast<int>(crossingIndex));
    }
    return knot;
}

void WriteNumber(std::ostream& output, double value)
{
    if (std::abs(value) < 0.0000000001)
        value = 0;
    output << std::setprecision(12) << value;
}

void WriteIntList(std::ostream& output, const std::vector<int>& values)
{
    output << '[';
    for (std::size_t index = 0; index < values.size(); ++index)
        output << (index ? "," : "") << values[index];
    output << ']';
}

// Serializes a compiled knot using LogoSC's public strand/crossing record layout.
// Preconditions: knot is compiled and the variable is an identifier. Postcondition: the complete
// output file is written or an exception is raised. Time/space O(serialized samples + crossings).
void WriteKnotScad(const CompiledKnot& knot, const Grid& grid, const Options& options)
{
    if (options.knotScadOutputPath.empty())
        return;
    if (!IsIdentifier(options.knotScadVariable))
        Fail("--knot-scad-variable must be a valid OpenSCAD identifier.");
    std::ofstream output(options.knotScadOutputPath, std::ios::binary);
    if (!output)
        Fail("Cannot open knot OpenSCAD output: " + options.knotScadOutputPath.string());
    output << "// Generated by logosc-knot-grid. Compatible with LogoSC-Knots.scad records.\n";
    output << options.knotScadVariable << " = [\n  [\n";
    for (std::size_t strandIndex = 0; strandIndex < knot.strands.size(); ++strandIndex)
    {
        const Strand& strand = knot.strands[strandIndex];
        output << "    [true,[";
        for (std::size_t sample = 0; sample < strand.samples.size(); ++sample)
        {
            const Point3& point = strand.samples[sample];
            output << (sample ? "," : "") << '[';
            WriteNumber(output, point.x);
            output << ',';
            WriteNumber(output, point.y);
            output << ',';
            WriteNumber(output, point.z);
            output << ']';
        }
        output << "],";
        WriteIntList(output, strand.encounters);
        output << ",[0],[\"generator\",\"celticTileGridCpp\",\"component\"," << strandIndex << ",\"stateCycle\",";
        WriteIntList(output, strand.stateCycle);
        output << "]]" << (strandIndex + 1 == knot.strands.size() ? "\n" : ",\n");
    }
    output << "  ],\n  [\n";
    for (std::size_t index = 0; index < knot.crossings.size(); ++index)
    {
        const Crossing& crossing = knot.crossings[index];
        output << "    [[";
        WriteNumber(output, crossing.x);
        output << ',';
        WriteNumber(output, crossing.y);
        output << "]," << crossing.strandA << ',';
        WriteNumber(output, crossing.parameterA);
        output << ',' << crossing.strandB << ',';
        WriteNumber(output, crossing.parameterB);
        output << ',' << crossing.overStrand << ",\"" << crossing.overBranch << "\"]"
               << (index + 1 == knot.crossings.size() ? "\n" : ",\n");
    }
    output << "  ],\n  [\"generator\",\"celticTileGridCpp\",\"rows\"," << knot.rows << ",\"columns\"," << knot.columns
           << ",\"grid\",[";
    for (std::size_t row = 0; row < grid.size(); ++row)
        output << (row ? "," : "") << '\"' << grid[row] << '\"';
    output << "],\"cellSize\",";
    WriteNumber(output, knot.cellSize);
    output << ",\"samplesPerTile\"," << knot.samplesPerTile << ",\"samplesPerBoundary\"," << knot.samplesPerBoundary;
    output << ",\"crossingHeight\",";
    WriteNumber(output, knot.crossingHeight);
    output << ",\"boundaryClosure\",\"clockwisePairs\"]\n];\n";
    double minimumX = 1e100, minimumY = 1e100, maximumX = -1e100, maximumY = -1e100;
    for (const Strand& strand : knot.strands)
        for (const Point3& point : strand.samples)
        {
            minimumX = std::min(minimumX, point.x);
            maximumX = std::max(maximumX, point.x);
            minimumY = std::min(minimumY, -point.y);
            maximumY = std::max(maximumY, -point.y);
        }
    output << options.knotScadVariable << "SvgSize = [";
    WriteNumber(output, maximumX - minimumX + options.ribbonWidth);
    output << ',';
    WriteNumber(output, maximumY - minimumY + options.ribbonWidth);
    output << "];\n";
    output << options.knotScadVariable << "RibbonWidth = ";
    WriteNumber(output, options.ribbonWidth);
    output << ";\n";
    output << options.knotScadVariable << "CrossingClearance = ";
    WriteNumber(output, options.crossingClearance);
    output << ";\n";
}

double Distance2D(const Point3& a, const Point3& b)
{
    return std::hypot(b.x - a.x, b.y - a.y);
}

// Interpolates a sampled polyline at cumulative arc length using binary search.
// Preconditions: points and cumulative are aligned and nonempty. Time O(log samples), space O(1).
Point3 PointAtLength(const std::vector<Point3>& points, const std::vector<double>& cumulative, double distance)
{
    if (distance <= 0)
        return points.front();
    if (distance >= cumulative.back())
        return points.back();
    const auto upper = std::upper_bound(cumulative.begin(), cumulative.end(), distance);
    const std::size_t end = static_cast<std::size_t>(upper - cumulative.begin());
    const std::size_t start = end - 1;
    const double span = cumulative[end] - cumulative[start];
    const double blend = span <= 0 ? 0 : (distance - cumulative[start]) / span;
    return {points[start].x + (points[end].x - points[start].x) * blend,
            points[start].y + (points[end].y - points[start].y) * blend, 0};
}

// Extracts one arc-length interval while interpolating its exact two endpoints.
// Preconditions: 0 <= start <= end <= total length. Time and output space O(samples).
std::vector<Point3> SpanPoints(const std::vector<Point3>& points, const std::vector<double>& cumulative, double start,
                               double end)
{
    std::vector<Point3> result{PointAtLength(points, cumulative, start)};
    for (std::size_t index = 1; index + 1 < points.size(); ++index)
        if (cumulative[index] > start && cumulative[index] < end)
            result.push_back(points[index]);
    result.push_back(PointAtLength(points, cumulative, end));
    return result;
}

// Writes one closed polygonal capsule; overlapping capsules form a watertight imported region.
// Preconditions: width is positive. Degenerate segments emit nothing. Time and space O(capSegments).
void WriteSvgCapsule(std::ostream& output, const Point3& start, const Point3& end, double minimumX, double minimumY,
                     double width)
{
    const double dx = end.x - start.x;
    const double dy = end.y - start.y;
    const double length = std::hypot(dx, dy);
    if (length <= 0.0000000001)
        return;

    constexpr int capSegments = 8;
    const double radius = width / 2;
    const double angle = std::atan2(-dy, dx);
    output << "    <polygon points=\"";
    for (int index = 0; index <= capSegments; ++index)
    {
        const double capAngle = angle - std::numbers::pi / 2 + std::numbers::pi * index / capSegments;
        if (index)
            output << ' ';
        WriteNumber(output, end.x - minimumX + radius * std::cos(capAngle));
        output << ',';
        WriteNumber(output, -end.y - minimumY + radius * std::sin(capAngle));
    }
    for (int index = 0; index <= capSegments; ++index)
    {
        const double capAngle = angle + std::numbers::pi / 2 + std::numbers::pi * index / capSegments;
        output << ' ';
        WriteNumber(output, start.x - minimumX + radius * std::cos(capAngle));
        output << ',';
        WriteNumber(output, -start.y - minimumY + radius * std::sin(capAngle));
    }
    output << "\"/>\n";
}

// Resolves underpass cut intervals and serializes all visible spans as closed SVG capsules.
// Preconditions: knot and ribbon options are valid. Postcondition: SVG is complete or writing
// raises an exception. Time O(samples + crossings log crossings), space O(samples + crossings).
void WriteSvg(const CompiledKnot& knot, const Options& options)
{
    if (options.svgOutputPath.empty())
        return;
    struct Interval
    {
        double start, end;
    };
    std::vector<std::vector<Interval>> cuts(knot.strands.size());
    for (const Crossing& crossing : knot.crossings)
    {
        const bool underA = crossing.overBranch != 'A';
        const int underStrand = underA ? crossing.strandA : crossing.strandB;
        const int overStrand = underA ? crossing.strandB : crossing.strandA;
        const double underParameter = underA ? crossing.parameterA : crossing.parameterB;
        const double overParameter = underA ? crossing.parameterB : crossing.parameterA;
        const auto tangent = [&](int strandIndex, double parameter)
        {
            const auto& samples = knot.strands[static_cast<std::size_t>(strandIndex)].samples;
            const int segments = static_cast<int>(samples.size()) - 1;
            const int center = std::clamp(static_cast<int>(std::llround(parameter * segments)), 1, segments - 1);
            return Point3{
                samples[static_cast<std::size_t>(center + 1)].x - samples[static_cast<std::size_t>(center - 1)].x,
                samples[static_cast<std::size_t>(center + 1)].y - samples[static_cast<std::size_t>(center - 1)].y, 0};
        };
        const Point3 underTangent = tangent(underStrand, underParameter),
                     overTangent = tangent(overStrand, overParameter);
        const double denominator =
            std::hypot(underTangent.x, underTangent.y) * std::hypot(overTangent.x, overTangent.y);
        const double sine =
            denominator <= 0 ? 1
                             : std::max(0.1, std::abs(underTangent.x * overTangent.y - underTangent.y * overTangent.x) /
                                                 denominator);
        const auto& samples = knot.strands[static_cast<std::size_t>(underStrand)].samples;
        std::vector<double> cumulative(samples.size(), 0);
        for (std::size_t index = 1; index < samples.size(); ++index)
            cumulative[index] = cumulative[index - 1] + Distance2D(samples[index - 1], samples[index]);
        const int centerIndex = std::clamp(static_cast<int>(std::llround(underParameter * (samples.size() - 1))), 0,
                                           static_cast<int>(samples.size()) - 1);
        const double center = cumulative[static_cast<std::size_t>(centerIndex)], total = cumulative.back();
        const double halfCut = (options.ribbonWidth / 2 + options.crossingClearance) / sine + options.ribbonWidth / 2;
        double start = center - halfCut, end = center + halfCut;
        if (start < 0)
        {
            cuts[static_cast<std::size_t>(underStrand)].push_back({0, end});
            cuts[static_cast<std::size_t>(underStrand)].push_back({total + start, total});
        }
        else if (end > total)
        {
            cuts[static_cast<std::size_t>(underStrand)].push_back({start, total});
            cuts[static_cast<std::size_t>(underStrand)].push_back({0, end - total});
        }
        else
            cuts[static_cast<std::size_t>(underStrand)].push_back({start, end});
    }

    double minimumX = 1e100, minimumY = 1e100, maximumX = -1e100, maximumY = -1e100;
    for (const Strand& strand : knot.strands)
        for (const Point3& point : strand.samples)
        {
            minimumX = std::min(minimumX, point.x);
            maximumX = std::max(maximumX, point.x);
            minimumY = std::min(minimumY, -point.y);
            maximumY = std::max(maximumY, -point.y);
        }
    const double padding = options.ribbonWidth / 2;
    minimumX -= padding;
    minimumY -= padding;
    maximumX += padding;
    maximumY += padding;
    std::ofstream output(options.svgOutputPath, std::ios::binary);
    if (!output)
        Fail("Cannot open SVG output: " + options.svgOutputPath.string());
    output << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 ";
    WriteNumber(output, maximumX - minimumX);
    output << ' ';
    WriteNumber(output, maximumY - minimumY);
    output << "\" width=\"";
    WriteNumber(output, maximumX - minimumX);
    output << "mm\" height=\"";
    WriteNumber(output, maximumY - minimumY);
    output << "mm\">\n  <g fill=\"#000000\" stroke=\"none\">\n";
    for (std::size_t strandIndex = 0; strandIndex < knot.strands.size(); ++strandIndex)
    {
        const auto& samples = knot.strands[strandIndex].samples;
        std::vector<double> cumulative(samples.size(), 0);
        for (std::size_t index = 1; index < samples.size(); ++index)
            cumulative[index] = cumulative[index - 1] + Distance2D(samples[index - 1], samples[index]);
        auto intervals = cuts[strandIndex];
        std::sort(intervals.begin(), intervals.end(),
                  [](const Interval& a, const Interval& b) { return a.start < b.start; });
        std::vector<Interval> merged;
        for (const Interval& interval : intervals)
            if (merged.empty() || interval.start > merged.back().end)
                merged.push_back(interval);
            else
                merged.back().end = std::max(merged.back().end, interval.end);
        std::vector<Interval> visible;
        double cursor = 0;
        for (const Interval& cut : merged)
        {
            if (cut.start > cursor)
                visible.push_back({cursor, cut.start});
            cursor = std::max(cursor, cut.end);
        }
        if (cursor < cumulative.back())
            visible.push_back({cursor, cumulative.back()});
        if (merged.empty())
            visible = {{0, cumulative.back()}};
        for (const Interval& span : visible)
        {
            const auto points = SpanPoints(samples, cumulative, span.start, span.end);
            if (points.size() < 2)
                continue;
            for (std::size_t index = 1; index < points.size(); ++index)
                WriteSvgCapsule(output, points[index - 1], points[index], minimumX, minimumY, options.ribbonWidth);
        }
    }
    output << "  </g>\n</svg>\n";
}

int SelfTest()
{
    Options options;
    options.text = "LogoSC";
    Grid grid = ApplyPattern(RenderTextMask(options, BuiltinFont()), "cycle");
    ValidateGrid(grid);
    if (grid.size() != 32 || grid.front().size() != 128)
        Fail("Self-test dimensions failed.");
    if (std::none_of(grid.begin(), grid.end(),
                     [](const auto& row) { return row.find_first_not_of('.') != std::string::npos; }))
        Fail("Self-test empty mask.");
    if (TileFor("cycle", 0, 0) != 'X' || TileFor("checker", 0, 1) != '<')
        Fail("Self-test pattern failed.");
    if (GridHash(grid) != 0x1c57984c6671a6b5ull)
        Fail("Self-test deterministic hash failed.");

    const auto stamp = std::chrono::high_resolution_clock::now().time_since_epoch().count();
    const auto roundTripPath =
        std::filesystem::temp_directory_path() / ("logosc-knot-grid-self-test-" + std::to_string(stamp) + ".grid");
    WriteGrid(grid, roundTripPath, "\r\n");
    const Grid loaded = ReadGrid(roundTripPath);
    WriteGrid(grid, roundTripPath, "\r");
    const Grid carriageReturnLoaded = ReadGrid(roundTripPath);
    std::filesystem::remove(roundTripPath);
    if (loaded != grid || carriageReturnLoaded != grid)
        Fail("Self-test line-ending round trip failed.");

    const auto bdfPath =
        std::filesystem::temp_directory_path() / ("logosc-knot-grid-self-test-" + std::to_string(stamp) + ".bdf");
    {
        std::ofstream bdf(bdfPath, std::ios::binary);
        bdf << "STARTFONT 2.1\nSTARTCHAR A\nENCODING 65\nDWIDTH 5 0\n"
               "BBX 5 7 0 0\nBITMAP\n70\n88\n88\nF8\n88\n88\n88\n"
               "ENDCHAR\nENDFONT\n";
    }
    const Font bdf = LoadBdfFont(bdfPath);
    std::filesystem::remove(bdfPath);
    if (FindGlyph(bdf, 'A').pixels != MakeGlyph({".XXX.", "X...X", "X...X", "XXXXX", "X...X", "X...X", "X...X"}).pixels)
        Fail("Self-test BDF loading failed.");

    Options topologyOptions;
    topologyOptions.cellSize = 12;
    topologyOptions.samplesPerTile = 6;
    topologyOptions.samplesPerBoundary = 4;
    topologyOptions.crossingHeight = 4;
    const CompiledKnot topology = CompileKnot({">X<", "X>X", "<X>"}, topologyOptions);
    std::size_t topologySegments = 0;
    for (const Strand& strand : topology.strands)
        topologySegments += strand.samples.size() - 1;
    if (topology.strands.size() != 2 || topology.crossings.size() != 4 || topologySegments != 132 ||
        topology.strands[0].samples.size() != 67 || topology.strands[1].samples.size() != 67)
        Fail("Self-test Celtic topology fixture failed.");

    const auto svgPath =
        std::filesystem::temp_directory_path() / ("logosc-knot-grid-self-test-" + std::to_string(stamp) + ".svg");
    topologyOptions.svgOutputPath = svgPath;
    WriteSvg(topology, topologyOptions);
    std::ifstream svgInput(svgPath, std::ios::binary);
    const std::string svg((std::istreambuf_iterator<char>(svgInput)), std::istreambuf_iterator<char>());
    svgInput.close();
    std::filesystem::remove(svgPath);
    if (svg.find("<polygon points=\"") == std::string::npos || svg.find("<path") != std::string::npos ||
        !svg.ends_with("</svg>\n"))
        Fail("Self-test closed-polygon SVG failed.");
    std::cout << "logosc-knot-grid self-test: PASS\n";
    return 0;
}
} // namespace

int main(int argc, char** argv)
{
    try
    {
        const Options options = ParseOptions(argc, argv);
        if (options.help)
        {
            PrintHelp();
            return 0;
        }
        if (options.selfTest)
            return SelfTest();
        if (options.text.empty() == options.inputPath.empty())
            Fail("Specify exactly one of --text or --input.");
        const auto started = std::chrono::steady_clock::now();
        Grid grid;
        CompiledKnot compiled;
        const bool compileTopology = !options.knotScadOutputPath.empty() || !options.svgOutputPath.empty();
        double topologySeconds = 0;
        {
            ProgressReporter progress(!options.quiet);
            grid = options.inputPath.empty()
                       ? ApplyPattern(RenderTextMask(options, LoadFont(options.font)), options.pattern)
                       : ReadGrid(options.inputPath);
            ValidateGrid(grid);
            WriteGrid(grid, options.outputPath, LineEnding(options.lineEnding));
            WriteScad(grid, options);
            if (compileTopology)
            {
                const auto topologyStarted = std::chrono::steady_clock::now();
                compiled = CompileKnot(grid, options);
                topologySeconds =
                    std::chrono::duration<double>(std::chrono::steady_clock::now() - topologyStarted).count();
                WriteKnotScad(compiled, grid, options);
                WriteSvg(compiled, options);
            }
        }
        if (!options.quiet)
        {
            std::size_t occupied = 0;
            for (const auto& row : grid)
                occupied +=
                    static_cast<std::size_t>(std::count_if(row.begin(), row.end(), [](char c) { return c != '.'; }));
            const double seconds = std::chrono::duration<double>(std::chrono::steady_clock::now() - started).count();
            std::cout << "Wrote " << grid.front().size() << 'x' << grid.size() << " grid to "
                      << options.outputPath.string() << '\n';
            if (!options.scadOutputPath.empty())
                std::cout << "Wrote OpenSCAD adapter to " << options.scadOutputPath.string() << '\n';
            if (!options.knotScadOutputPath.empty())
                std::cout << "Wrote sampled knot record to " << options.knotScadOutputPath.string() << '\n';
            if (!options.svgOutputPath.empty())
                std::cout << "Wrote interlaced ribbon SVG to " << options.svgOutputPath.string() << '\n';
            std::cout << "Occupied cells: " << occupied << '\n'
                      << "FNV-1a grid hash: " << std::hex << std::setw(16) << std::setfill('0') << GridHash(grid)
                      << std::dec << '\n'
                      << "Elapsed seconds: " << std::fixed << std::setprecision(6) << seconds << '\n';
            if (compileTopology)
            {
                std::size_t segments = 0;
                for (const Strand& strand : compiled.strands)
                    segments += strand.samples.size() - 1;
                std::cout << "Topology: " << compiled.strands.size() << " components, " << compiled.crossings.size()
                          << " crossings, " << segments << " segments\nTopology seconds: " << topologySeconds << '\n';
            }
        }
        return 0;
    }
    catch (const std::exception& error)
    {
        std::cerr << "logosc-knot-grid: error: " << error.what() << '\n';
        return 1;
    }
}
