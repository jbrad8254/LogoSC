# LogoSC Knot Grid Generator

`logosc-knot-grid` is a dependency-free C++20 command-line compiler for LogoSC Celtic tile
grids. It converts ASCII text into an exact-size mask populated with `X`, `>`, and `<` tiles and
`.` blank cells, compiles indexed knot topology, and can emit LogoSC-compatible sampled records
and finished interlaced SVG regions. It can also validate and normalize an existing grid.

The primary output is deliberately simple: one unquoted ASCII row per line, with no commas or
other framing. Use `--line-ending crlf` for Windows CRLF or `--line-ending cr` for a literal
carriage-return-only stream; `native` is the default.

## Build

```powershell
cmake -S tools/logosc-knot-grid -B build/logosc-knot-grid
cmake --build build/logosc-knot-grid --config Release
ctest --test-dir build/logosc-knot-grid -C Release --output-on-failure
```

## Generate a LogoSC grid, record, and SVG

```powershell
build/logosc-knot-grid/Release/logosc-knot-grid.exe `
    --text LogoSC `
    --width 128 `
    --height 32 `
    --scale 1 `
    --scale-mode stroke `
    --output generated/LogoSC-Celtic-Generated.grid `
    --line-ending crlf `
    --scad-output generated/LogoSC-Celtic-Generated.scad `
    --knot-scad-output generated/LogoSC-Celtic-Generated-Knot.scad `
    --svg-output generated/LogoSC-Celtic-Generated.svg `
    --cell-size 4 --samples-per-tile 4 --samples-per-boundary 2 `
    --crossing-height 2 --ribbon-width 0.9 --crossing-clearance 0.3
```

OpenSCAD 2021.01 cannot read an arbitrary text file, so `--scad-output` writes a tiny adapter
containing the identical rows as a string list. `--knot-scad-output` writes strands, crossings,
and metadata compatible with `LogoSC-Knots.scad`. `--svg-output` resolves underpass gaps and
writes the visible ribbon as overlapping closed capsule polygons. Closed polygons are used
instead of SVG strokes because OpenSCAD can import and preview stroked paths but may reject their
extrusion as a non-closed mesh during a later CGAL Boolean.

`LogoSC-Celtic-Large-Grids.scad` offers `GeneratedPlaque **` for the reference OpenSCAD path and
`FastSvgPlaque` for the accelerated import path. Run `LogoSC-Celtic-Generated-Test.scad` to make
OpenSCAD recompute the fixture and compare every C++ sample and crossing record.

Use `--font path/to/font.bdf` to replace the built-in 5-by-7 font with a byte-addressable BDF
bitmap font. `--scale-mode stroke` enlarges glyph spacing while retaining approximately
one-cell-wide connected strokes, which is substantially friendlier to the current OpenSCAD
topology tracer than filled pixel blocks. Lowercase text falls back to uppercase for the built-in
font. Run `--help` for all size, margin, spacing, scale, pattern, and output controls.

## Algorithm and limits

The compiler gives each occupied cell four indexed port states. Hash-indexed exposed edges are
traced into clockwise boundary loops and paired adjacently; interior ports connect directly to
their neighbor. Successor links are then traced into closed components while suppressing reverse
duplicates. Quadratic tile and boundary curves are sampled exactly like the OpenSCAD reference,
and checkerboard parity supplies crossing order. SVG underpass cuts use cumulative arc length and
the sine of the crossing angle before visible spans are emitted as closed capsules.

For `R` rows, `C` columns, `E` occupied port states, `S` output samples, and `K` crossings, the
topology and sampling work is `O(R*C + E + S)`; sorting each strand's cut intervals adds at most
`O(K log K)` overall. Memory use is `O(R*C + E + S + K)`. The compiler currently accepts only
the Celtic `X`, `>`, `<`, and `.` vocabulary, assumes isolated transverse crossings with enough
room for the requested ribbon and clearance, and emits uniform-width planar ribbons. General
polygon offsets, arbitrary medial graphs, and direct STL/3MF output remain future work.
