#include <algorithm>
#include <chrono>
#include <cctype>
#include <condition_variable>
#include <cstdint>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <map>
#include <mutex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <thread>
#include <utility>
#include <vector>

namespace
{
using Grid = std::vector<std::string>;

struct Glyph { Grid pixels; int advance = 0; };
struct Font { std::map<unsigned char, Glyph> glyphs; };
struct Options
{
    std::string text;
    std::filesystem::path inputPath;
    std::filesystem::path outputPath = "logosc-knot.grid";
    std::filesystem::path scadOutputPath;
    std::string scadVariable = "GeneratedCelticGrid";
    std::string font = "builtin-5x7";
    std::string pattern = "cycle";
    std::string scaleMode = "pixels";
    std::string lineEnding = "native";
    int width = 128, height = 32, marginX = 2, marginY = 2, glyphGap = 1, scale = 0;
    bool quiet = false, selfTest = false, help = false;
};

class ProgressReporter
{
public:
    explicit ProgressReporter(bool enabled) : enabled_(enabled)
    {
        if (enabled_) worker_ = std::thread([this]
        {
            std::unique_lock lock(mutex_);
            if (condition_.wait_for(lock, std::chrono::seconds(2), [this] { return done_; })) return;
            started_ = true;
            std::cerr << "Working" << std::flush;
            while (!condition_.wait_for(lock, std::chrono::seconds(1), [this] { return done_; }))
                std::cerr << '.' << std::flush;
        });
    }
    ProgressReporter(const ProgressReporter&) = delete;
    ~ProgressReporter()
    {
        { std::lock_guard lock(mutex_); done_ = true; }
        condition_.notify_all();
        if (worker_.joinable()) worker_.join();
        if (started_) std::cerr << '\n';
    }
private:
    bool enabled_ = false, done_ = false, started_ = false;
    std::mutex mutex_;
    std::condition_variable condition_;
    std::thread worker_;
};

[[noreturn]] void Fail(const std::string& message) { throw std::runtime_error(message); }

int ParseInt(const std::string& value, const std::string& option, bool allowZero = false)
{
    std::size_t consumed = 0;
    int result = 0;
    try { result = std::stoi(value, &consumed); }
    catch (...) { Fail(option + " requires an integer, received: " + value); }
    if (consumed != value.size() || result < (allowZero ? 0 : 1))
        Fail(option + " requires a " + std::string(allowZero ? "non-negative" : "positive") + " integer.");
    return result;
}

Options ParseOptions(int argc, char** argv)
{
    Options options;
    auto value = [&](int& index, const std::string& option)
    {
        if (++index >= argc) Fail(option + " requires a value.");
        return std::string(argv[index]);
    };
    for (int index = 1; index < argc; ++index)
    {
        const std::string argument = argv[index];
        if (argument == "--text") options.text = value(index, argument);
        else if (argument == "--input") options.inputPath = value(index, argument);
        else if (argument == "--output" || argument == "-o") options.outputPath = value(index, argument);
        else if (argument == "--scad-output") options.scadOutputPath = value(index, argument);
        else if (argument == "--scad-variable") options.scadVariable = value(index, argument);
        else if (argument == "--font") options.font = value(index, argument);
        else if (argument == "--pattern") options.pattern = value(index, argument);
        else if (argument == "--scale-mode") options.scaleMode = value(index, argument);
        else if (argument == "--line-ending") options.lineEnding = value(index, argument);
        else if (argument == "--width") options.width = ParseInt(value(index, argument), argument);
        else if (argument == "--height") options.height = ParseInt(value(index, argument), argument);
        else if (argument == "--margin-x") options.marginX = ParseInt(value(index, argument), argument, true);
        else if (argument == "--margin-y") options.marginY = ParseInt(value(index, argument), argument, true);
        else if (argument == "--glyph-gap") options.glyphGap = ParseInt(value(index, argument), argument, true);
        else if (argument == "--scale") options.scale = ParseInt(value(index, argument), argument, true);
        else if (argument == "--quiet") options.quiet = true;
        else if (argument == "--self-test") options.selfTest = true;
        else if (argument == "--help" || argument == "-h") options.help = true;
        else Fail("Unknown option: " + argument);
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
    for (const char* row : rows) glyph.pixels.emplace_back(row);
    glyph.advance = glyph.pixels.empty() ? 0 : static_cast<int>(glyph.pixels.front().size());
    return glyph;
}

Font BuiltinFont()
{
    Font font;
    auto add = [&](char c, std::initializer_list<const char*> rows) { font.glyphs[static_cast<unsigned char>(c)] = MakeGlyph(rows); };
    add('A',{".XXX.","X...X","X...X","XXXXX","X...X","X...X","X...X"});
    add('B',{"XXXX.","X...X","X...X","XXXX.","X...X","X...X","XXXX."});
    add('C',{".XXX.","X...X","X....","X....","X....","X...X",".XXX."});
    add('D',{"XXXX.","X...X","X...X","X...X","X...X","X...X","XXXX."});
    add('E',{ "XXXXX","X....","X....","XXXX.","X....","X....","XXXXX"});
    add('F',{ "XXXXX","X....","X....","XXXX.","X....","X....","X...."});
    add('G',{ ".XXX.","X...X","X....","X.XXX","X...X","X...X",".XXX."});
    add('H',{ "X...X","X...X","X...X","XXXXX","X...X","X...X","X...X"});
    add('I',{ "XXXXX","..X..","..X..","..X..","..X..","..X..","XXXXX"});
    add('J',{ "..XXX","...X.","...X.","...X.","X..X.","X..X.",".XX.."});
    add('K',{ "X...X","X..X.","X.X..","XX...","X.X..","X..X.","X...X"});
    add('L',{ "X....","X....","X....","X....","X....","X....","XXXXX"});
    add('M',{ "X...X","XX.XX","X.X.X","X.X.X","X...X","X...X","X...X"});
    add('N',{ "X...X","XX..X","XX..X","X.X.X","X..XX","X..XX","X...X"});
    add('O',{ ".XXX.","X...X","X...X","X...X","X...X","X...X",".XXX."});
    add('P',{ "XXXX.","X...X","X...X","XXXX.","X....","X....","X...."});
    add('Q',{ ".XXX.","X...X","X...X","X...X","X.X.X","X..X.",".XX.X"});
    add('R',{ "XXXX.","X...X","X...X","XXXX.","X.X..","X..X.","X...X"});
    add('S',{ ".XXXX","X....","X....",".XXX.","....X","....X","XXXX."});
    add('T',{ "XXXXX","..X..","..X..","..X..","..X..","..X..","..X.."});
    add('U',{ "X...X","X...X","X...X","X...X","X...X","X...X",".XXX."});
    add('V',{ "X...X","X...X","X...X","X...X","X...X",".X.X.","..X.."});
    add('W',{ "X...X","X...X","X...X","X.X.X","X.X.X","XX.XX","X...X"});
    add('X',{ "X...X","X...X",".X.X.","..X..",".X.X.","X...X","X...X"});
    add('Y',{ "X...X","X...X",".X.X.","..X..","..X..","..X..","..X.."});
    add('Z',{ "XXXXX","....X","...X.","..X..",".X...","X....","XXXXX"});
    add('0',{ ".XXX.","X...X","X..XX","X.X.X","XX..X","X...X",".XXX."});
    add('1',{ "..X..",".XX..","..X..","..X..","..X..","..X..",".XXX."});
    add('2',{ ".XXX.","X...X","....X","...X.","..X..",".X...","XXXXX"});
    add('3',{ "XXXX.","....X","....X",".XXX.","....X","....X","XXXX."});
    add('4',{ "...X.","..XX.",".X.X.","X..X.","XXXXX","...X.","...X."});
    add('5',{ "XXXXX","X....","X....","XXXX.","....X","....X","XXXX."});
    add('6',{ ".XXX.","X....","X....","XXXX.","X...X","X...X",".XXX."});
    add('7',{ "XXXXX","....X","...X.","..X..",".X...",".X...",".X..."});
    add('8',{ ".XXX.","X...X","X...X",".XXX.","X...X","X...X",".XXX."});
    add('9',{ ".XXX.","X...X","X...X",".XXXX","....X","....X",".XXX."});
    add('-',{ ".....",".....",".....","XXXXX",".....",".....","....."});
    add('_',{ ".....",".....",".....",".....",".....",".....","XXXXX"});
    add('?',{ ".XXX.","X...X","....X","...X.","..X..",".....","..X.."});
    add(' ',{ "...","...","...","...","...","...","..."});
    return font;
}

int HexValue(char c)
{
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    Fail(std::string("Invalid hexadecimal digit in BDF bitmap: ") + c);
}

Font LoadBdfFont(const std::filesystem::path& path)
{
    std::ifstream input(path);
    if (!input) Fail("Cannot open BDF font: " + path.string());
    Font font;
    std::string line;
    int encoding = -1, width = 0, height = 0, advance = 0;
    bool inBitmap = false;
    Grid bitmap;
    auto finish = [&]
    {
        if (encoding >= 0 && encoding <= 255 && !bitmap.empty())
            font.glyphs[static_cast<unsigned char>(encoding)] = Glyph{bitmap, advance > 0 ? advance : width};
        encoding = -1; width = height = advance = 0; inBitmap = false; bitmap.clear();
    };
    while (std::getline(input, line))
    {
        if (!line.empty() && line.back() == '\r') line.pop_back();
        if (line.rfind("STARTCHAR ", 0) == 0) finish();
        else if (line.rfind("ENCODING ", 0) == 0) encoding = std::stoi(line.substr(9));
        else if (line.rfind("DWIDTH ", 0) == 0) { std::istringstream values(line.substr(7)); values >> advance; }
        else if (line.rfind("BBX ", 0) == 0) { std::istringstream values(line.substr(4)); int ignored; values >> width >> height >> ignored >> ignored; }
        else if (line == "BITMAP") inBitmap = true;
        else if (line == "ENDCHAR") finish();
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
    if (font.glyphs.empty()) Fail("BDF font contains no byte-addressable glyphs: " + path.string());
    return font;
}

Font LoadFont(const std::string& name) { return name == "builtin-5x7" ? BuiltinFont() : LoadBdfFont(name); }

const Glyph& FindGlyph(const Font& font, unsigned char character)
{
    auto found = font.glyphs.find(character);
    if (found == font.glyphs.end() && character >= 'a' && character <= 'z')
        found = font.glyphs.find(static_cast<unsigned char>(character - 'a' + 'A'));
    if (found == font.glyphs.end()) found = font.glyphs.find('?');
    if (found == font.glyphs.end()) Fail("Font does not contain glyph code " + std::to_string(character) + '.');
    return found->second;
}

int GlyphLayoutWidth(const Glyph& glyph)
{
    std::size_t bitmapWidth = 0;
    for (const auto& row : glyph.pixels) bitmapWidth = std::max(bitmapWidth, row.size());
    return std::max(glyph.advance, static_cast<int>(bitmapWidth));
}

Grid RenderTextMask(const Options& options, const Font& font)
{
    if (options.text.empty()) Fail("--text must not be empty.");
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
                    for (int dy = 0; dy < scale; ++dy) for (int dx = 0; dx < scale; ++dx)
                        mask[static_cast<std::size_t>(originY + row * scale + dy)]
                            [static_cast<std::size_t>(originX + column * scale + dx)] = 'X';
    }
    else
    {
        auto occupied = [&](int row, int column)
        {
            return row >= 0 && row < contentHeight && column >= 0 && column < contentWidth
                && source[static_cast<std::size_t>(row)][static_cast<std::size_t>(column)] != '.';
        };
        auto point = [&](int row, int column)
        {
            return std::pair<int, int>{originX + column * scale + scale / 2, originY + row * scale + scale / 2};
        };
        auto drawLine = [&](std::pair<int, int> start, std::pair<int, int> end)
        {
            int x = start.first, y = start.second;
            const int dx = std::abs(end.first - x), sx = x < end.first ? 1 : -1;
            const int dy = -std::abs(end.second - y), sy = y < end.second ? 1 : -1;
            int error = dx + dy;
            while (true)
            {
                mask[static_cast<std::size_t>(y)][static_cast<std::size_t>(x)] = 'X';
                if (x == end.first && y == end.second) break;
                const int twiceError = 2 * error;
                if (twiceError >= dy) { error += dy; x += sx; }
                if (twiceError <= dx) { error += dx; y += sy; }
            }
        };
        for (int row = 0; row < contentHeight; ++row)
            for (int column = 0; column < contentWidth; ++column)
                if (occupied(row, column))
                {
                    const auto start = point(row, column);
                    drawLine(start, start);
                    if (occupied(row, column + 1)) drawLine(start, point(row, column + 1));
                    if (occupied(row + 1, column)) drawLine(start, point(row + 1, column));
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
    if (pattern == "cross") return 'X';
    if (pattern == "checker") return (row + column) % 2 == 0 ? '>' : '<';
    if (pattern == "cycle") return (row + column) % 3 == 0 ? 'X' : ((row + column) % 2 == 0 ? '>' : '<');
    Fail("Unknown tile pattern: " + pattern + ". Expected cycle, checker, or cross.");
}

Grid ApplyPattern(Grid grid, const std::string& pattern)
{
    for (std::size_t row = 0; row < grid.size(); ++row)
        for (std::size_t column = 0; column < grid[row].size(); ++column)
            if (grid[row][column] != '.') grid[row][column] = TileFor(pattern, static_cast<int>(row), static_cast<int>(column));
    return grid;
}

void ValidateGrid(const Grid& grid)
{
    if (grid.empty() || grid.front().empty()) Fail("Grid must contain at least one non-empty row.");
    const std::size_t width = grid.front().size();
    for (std::size_t row = 0; row < grid.size(); ++row)
    {
        if (grid[row].size() != width) Fail("Grid row " + std::to_string(row + 1) + " is not rectangular.");
        for (char tile : grid[row]) if (tile != 'X' && tile != '>' && tile != '<' && tile != '.')
            Fail("Grid row " + std::to_string(row + 1) + " contains invalid tile character: " + tile);
    }
}

Grid ReadGrid(const std::filesystem::path& path)
{
    std::ifstream input(path, std::ios::binary);
    if (!input) Fail("Cannot open grid input: " + path.string());
    const std::string contents{
        std::istreambuf_iterator<char>(input),
        std::istreambuf_iterator<char>()
    };
    Grid grid;
    std::string row;
    for (std::size_t index = 0; index < contents.size(); ++index)
    {
        const char character = contents[index];
        if (character == '\r' || character == '\n')
        {
            if (row.empty()) Fail("Grid contains an empty row.");
            grid.push_back(row);
            row.clear();
            if (character == '\r' && index + 1 < contents.size() && contents[index + 1] == '\n') ++index;
        }
        else row.push_back(character);
    }
    if (!row.empty()) grid.push_back(row);
    ValidateGrid(grid);
    return grid;
}

std::string LineEnding(const std::string& requested)
{
    if (requested == "crlf") return "\r\n";
    if (requested == "cr") return "\r";
    if (requested == "lf") return "\n";
    if (requested != "native") Fail("--line-ending must be native, crlf, cr, or lf.");
#ifdef _WIN32
    return "\r\n";
#else
    return "\n";
#endif
}

void WriteGrid(const Grid& grid, const std::filesystem::path& path, const std::string& ending)
{
    std::ofstream output(path, std::ios::binary);
    if (!output) Fail("Cannot open grid output: " + path.string());
    for (const std::string& row : grid) output << row << ending;
    if (!output) Fail("Failed while writing grid output: " + path.string());
}

bool IsIdentifier(const std::string& value)
{
    if (value.empty() || !(std::isalpha(static_cast<unsigned char>(value[0])) || value[0] == '_')) return false;
    return std::all_of(value.begin() + 1, value.end(), [](unsigned char c) { return std::isalnum(c) || c == '_'; });
}

void WriteScad(const Grid& grid, const Options& options)
{
    if (options.scadOutputPath.empty()) return;
    if (!IsIdentifier(options.scadVariable)) Fail("--scad-variable must be a valid OpenSCAD identifier.");
    std::ofstream output(options.scadOutputPath, std::ios::binary);
    if (!output) Fail("Cannot open OpenSCAD output: " + options.scadOutputPath.string());
    output << "// Generated by logosc-knot-grid. Do not edit by hand.\n" << options.scadVariable << " = [\n";
    for (std::size_t row = 0; row < grid.size(); ++row)
        output << "    \"" << grid[row] << "\"" << (row + 1 == grid.size() ? "\n" : ",\n");
    output << "];\n" << options.scadVariable << "Rows = " << grid.size() << ";\n"
           << options.scadVariable << "Columns = " << grid.front().size() << ";\n";
}

std::uint64_t GridHash(const Grid& grid)
{
    std::uint64_t hash = 14695981039346656037ull;
    for (const auto& row : grid) { for (unsigned char c : row) { hash ^= c; hash *= 1099511628211ull; } hash ^= '\n'; hash *= 1099511628211ull; }
    return hash;
}

int SelfTest()
{
    Options options; options.text = "LogoSC";
    Grid grid = ApplyPattern(RenderTextMask(options, BuiltinFont()), "cycle");
    ValidateGrid(grid);
    if (grid.size() != 32 || grid.front().size() != 128) Fail("Self-test dimensions failed.");
    if (std::none_of(grid.begin(), grid.end(), [](const auto& row) { return row.find_first_not_of('.') != std::string::npos; })) Fail("Self-test empty mask.");
    if (TileFor("cycle", 0, 0) != 'X' || TileFor("checker", 0, 1) != '<') Fail("Self-test pattern failed.");
    if (GridHash(grid) != 0x1c57984c6671a6b5ull) Fail("Self-test deterministic hash failed.");

    const auto stamp = std::chrono::high_resolution_clock::now().time_since_epoch().count();
    const auto roundTripPath = std::filesystem::temp_directory_path() /
        ("logosc-knot-grid-self-test-" + std::to_string(stamp) + ".grid");
    WriteGrid(grid, roundTripPath, "\r\n");
    const Grid loaded = ReadGrid(roundTripPath);
    WriteGrid(grid, roundTripPath, "\r");
    const Grid carriageReturnLoaded = ReadGrid(roundTripPath);
    std::filesystem::remove(roundTripPath);
    if (loaded != grid || carriageReturnLoaded != grid) Fail("Self-test line-ending round trip failed.");

    const auto bdfPath = std::filesystem::temp_directory_path() /
        ("logosc-knot-grid-self-test-" + std::to_string(stamp) + ".bdf");
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
    std::cout << "logosc-knot-grid self-test: PASS\n";
    return 0;
}
}

int main(int argc, char** argv)
{
    try
    {
        const Options options = ParseOptions(argc, argv);
        if (options.help) { PrintHelp(); return 0; }
        if (options.selfTest) return SelfTest();
        if (options.text.empty() == options.inputPath.empty()) Fail("Specify exactly one of --text or --input.");
        const auto started = std::chrono::steady_clock::now();
        Grid grid;
        {
            ProgressReporter progress(!options.quiet);
            grid = options.inputPath.empty() ? ApplyPattern(RenderTextMask(options, LoadFont(options.font)), options.pattern) : ReadGrid(options.inputPath);
            ValidateGrid(grid);
            WriteGrid(grid, options.outputPath, LineEnding(options.lineEnding));
            WriteScad(grid, options);
        }
        if (!options.quiet)
        {
            std::size_t occupied = 0;
            for (const auto& row : grid) occupied += static_cast<std::size_t>(std::count_if(row.begin(), row.end(), [](char c) { return c != '.'; }));
            const double seconds = std::chrono::duration<double>(std::chrono::steady_clock::now() - started).count();
            std::cout << "Wrote " << grid.front().size() << 'x' << grid.size() << " grid to " << options.outputPath.string() << '\n';
            if (!options.scadOutputPath.empty()) std::cout << "Wrote OpenSCAD adapter to " << options.scadOutputPath.string() << '\n';
            std::cout << "Occupied cells: " << occupied << '\n'
                      << "FNV-1a grid hash: " << std::hex << std::setw(16) << std::setfill('0') << GridHash(grid) << std::dec << '\n'
                      << "Elapsed seconds: " << std::fixed << std::setprecision(3) << seconds << '\n';
        }
        return 0;
    }
    catch (const std::exception& error)
    {
        std::cerr << "logosc-knot-grid: error: " << error.what() << '\n';
        return 1;
    }
}
