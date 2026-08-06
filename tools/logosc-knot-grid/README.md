# LogoSC Knot Grid Generator

`logosc-knot-grid` is a dependency-free C++20 command-line preprocessor for LogoSC Celtic tile
grids. It converts ASCII text into an exact-size mask populated with `X`, `>`, and `<` tiles and
`.` blank cells. It can also validate and normalize an existing grid.

The primary output is deliberately simple: one unquoted ASCII row per line, with no commas or
other framing. Use `--line-ending crlf` for Windows CRLF or `--line-ending cr` for a literal
carriage-return-only stream; `native` is the default.

## Build

```powershell
cmake -S tools/logosc-knot-grid -B build/logosc-knot-grid
cmake --build build/logosc-knot-grid --config Release
ctest --test-dir build/logosc-knot-grid -C Release --output-on-failure
```

## Generate a LogoSC grid and OpenSCAD adapter

```powershell
build/logosc-knot-grid/Release/logosc-knot-grid.exe `
    --text LogoSC `
    --width 128 `
    --height 32 `
    --scale 1 `
    --scale-mode stroke `
    --output generated/LogoSC-Celtic-Generated.grid `
    --line-ending crlf `
    --scad-output generated/LogoSC-Celtic-Generated.scad
```

OpenSCAD 2021.01 cannot read an arbitrary text file, so `--scad-output` writes a tiny adapter
containing the identical rows as a string list. `LogoSC-Celtic-Large-Grids.scad` includes the
committed adapter and offers `GeneratedPlaque` as a scene.

Use `--font path/to/font.bdf` to replace the built-in 5-by-7 font with a byte-addressable BDF
bitmap font. `--scale-mode stroke` enlarges glyph spacing while retaining approximately
one-cell-wide connected strokes, which is substantially friendlier to the current OpenSCAD
topology tracer than filled pixel blocks. Lowercase text falls back to uppercase for the built-in
font. Run `--help` for all size, margin, spacing, scale, pattern, and output controls.
