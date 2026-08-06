# LogoSC Large Celtic Grid Showcase

`LogoSC-Celtic-Large-Grids.scad` demonstrates the canonical `"."` blank cell with grids large
enough to expose both its design possibilities and its computational cost.

## Table of Contents

- [Included scenes](#included-scenes)
- [Output choices](#output-choices)
- [Measured OpenSCAD 2021.01 timings](#measured-openscad-202101-timings)
  - [Other development PC](#other-development-pc-original-measurements)
  - [RAINBOW](#rainbow-2026-08-05)
  - [RAINBOW Customizer-warning remeasurement](#rainbow-customizer-warning-remeasurement-2026-08-06)
  - [RAINBOW comparison](#rainbow-comparison)
- [Progress reporting](#progress-reporting)
- [Command-line timing](#command-line-timing)

## Included scenes

Select `CelticLargeExample` in OpenSCAD's Customizer:

| Scene | Purpose |
|---|---|
| `Diamond8` | Small responsive 8-by-8 irregular region |
| `Ring16 *` | Medium 16-by-16 region with an internal blank opening |
| `Diamond24 *` | Slow 24-by-24 stress example |
| `Ring32 **` | Very slow 32-by-32 stress example with exterior and interior boundaries |
| `CELTIC *` | A 37-by-9 bitmap word mask built from blank and occupied cells |
| `LOGOSC128 ***` | Batch-only 128-by-32 LogoSC word built from native 18-by-24 glyphs |

Customizer suffixes warn about approximate minimum-sampling Cord CSG time on `RAINBOW`: `(*)`
means more than 3 seconds, `(**)` more than 30 seconds, and `(***)` more than 3 minutes. The
display labels are normalized to canonical scene names before dispatch.

The word mask is ordinary grid data. Five-by-seven glyphs select occupied cells; `"."` leaves
the remaining cells empty. Occupied cells receive deterministic `X`, `>`, and `<` tiles. The
normal Celtic compiler then discovers boundary loops, traces closed components, assigns
crossings, and verifies cyclic alternation.

![CELTIC spelled with blank-cell knot grids](images/knot-celtic-word.png)

`LOGOSC128 ***` is the first deliberately three-star LogoSC example. Its six glyphs are drawn
directly at 18 by 24 cells with one-cell strokes; they are not enlarged 5-by-7 bitmaps. The
128-by-32 padded mask is both a showcase and the shared stress fixture planned for comparison
with the future C++/SVG knot compiler.

![LogoSC spelled as a 128-by-32 Celtic knot grid](images/knot-celtic-logosc-128.png)

## Output choices

- `Topology` performs calculation and validation but emits no geometry. Use it when editing a
  large mask or measuring topology cost.
- `Cord` constructs native sphere-hulled manufacturing cords.
- `Ribbon` projects the result to a plane and constructs LogoSC-backed ribbon regions. It can be
  considerably slower than `Cord` on large grids because every sampled segment becomes a region.
- `Plaque` puts the planar ribbon relief on an automatically sized rounded backing plate. Plate
  thickness, margin, corner radius, optional bevel, relief heights, and preview colors are
  available in the Customizer. This is normally the slowest output.

The first console message reports `working`, the selected scene and output, and a rough duration
estimate based on the development-machine measurements below. An 8-by-8 plaque CSG compile took
about 0.75 seconds; the displayed lower bound is rounded up to one second, and the larger plaque
ranges are cautious extrapolations rather than exhaustive benchmarks. Actual time can vary
substantially with the computer, OpenSCAD version, settings, and whether preview, render, or export
is requested. A full CGAL render or mesh export may substantially exceed the CSG compile estimate.

The shipped examples use four samples per occupied tile and two per boundary connector, which
are the minimum accepted values. Increase rendering resolution only after the topology is
settled.

## Measured OpenSCAD 2021.01 timings

These measurements were taken through `openscad.com`. They are useful scale indicators, not
universal performance guarantees. Keep results separated by computer because processor speed,
system load, and machine-specific paths can materially affect elapsed time.

### Other development PC (original measurements)

The computer name was not recorded with the original measurements.

| Grid and mask | Calculation only | Low-resolution cord CSG | Cord segments |
|---|---:|---:|---:|
| 8-by-8 diamond | about 0.7 s | about 0.6 s | 352 |
| 16-by-16 diamond | about 3.4 s | about 5.9 s | 1,216 |
| 24-by-24 diamond | about 17.8 s | about 24.5 s | 2,944 |
| 32-by-32 diamond | about 49.7 s | about 63.6 s | 4,960 |
| 16-by-16 ring | about 4.4 s | not separately measured | 1,464 |
| 24-by-24 ring | about 29.5 s | not separately measured | 3,112 |
| 32-by-32 ring | about 75.5 s | not separately measured | 5,368 |
| `CELTIC` word, 37 by 9 | about 46 s | about 37–52 s for a preview PNG | 838 |

### RAINBOW (2026-08-05)

`RAINBOW` used an AMD Ryzen 9 5950X 16-Core Processor with 32 logical processors and
OpenSCAD 2021.01. Each result below is one elapsed-time measurement from the documented
PowerShell command-line workflow; all commands exited successfully and reported the expected
scene, output mode, dimensions, and segment count.

The separate `LogoSC-Knots-Test-Runner.scad` verification passed all 88 results in 0.910 seconds.
That suite timing is not included in the comparison because the original PC has no matching
measurement yet.

| Grid and mask | Calculation only | Low-resolution cord CSG | Cord segments |
|---|---:|---:|---:|
| 8-by-8 diamond | 0.505 s | 0.543 s | 352 |
| 16-by-16 ring | 3.544 s | 3.659 s | 1,464 |
| 24-by-24 diamond | 12.132 s | 12.884 s | 2,944 |
| 32-by-32 ring | 66.763 s | 61.949 s | 5,368 |
| `CELTIC` word, 37 by 9 | 27.179 s | 24.725 s | 838 |

### RAINBOW Customizer-warning remeasurement (2026-08-06)

The complete dropdown was remeasured with the shipped minimum sampling, default `Cord` output,
and CSG compilation specifically to assign Customizer warning suffixes:

| Scene | Cord CSG | Suffix |
|---|---:|---|
| `Diamond8` | 0.570 s | |
| `Ring16` | 3.665 s | `(*)` |
| `Diamond24` | 12.557 s | `(*)` |
| `Ring32` | 44.125 s | `(**)` |
| `CELTIC` | 20.628 s | `(*)` |
| `LOGOSC128` | about 180 s | `(***)` |

These newer single-run values do not replace the earlier measurement set; they record a separate
run for the UI-warning decision. Cache and system state explain some variation, especially for
`Ring32`, without changing any threshold classification.

The final `LOGOSC128` Cord measurement was 179.803 seconds inside the benchmark stopwatch and
about 180.5 seconds for the complete command invocation. A neighboring 17-by-24 native-glyph
trial measured 181.475 seconds. Because repeated nearby measurements straddle three minutes and
the user-visible command exceeds it, the scene conservatively carries `(***)`. Attempts to make
the glyphs 25 or 26 cells high, or reduce the inter-letter gap to one cell, crossed severe
topology-performance cliffs and were stopped after roughly 7 to 10 minutes. The shipped 18-by-24
layout deliberately stays near the requested threshold.

### RAINBOW comparison

Across the seven directly comparable calculation or CSG rows, combined elapsed time fell from
about 169.5 seconds on the original development PC to 123.55 seconds on `RAINBOW`. That is about
27% less elapsed time, or 1.37 times the throughput. Individual improvements ranged from about
10% less time for the 8-by-8 cord CSG to about 47% less time for the 24-by-24 cord CSG.

The original `CELTIC` cord result was a preview PNG range, not a CSG measurement, so it is not
included in the comparison. Likewise, the newly measured 16-by-16 and 32-by-32 cord CSG rows
have no original-PC counterparts yet.

The cost is not determined by the rectangular dimensions alone. Occupied-cell count, boundary
length, number of separate boundary loops, route-component count, crossings, sampling, and
rendering resolution all matter. The word is relatively sparse but has many disconnected letter
strokes and boundary loops, so it is slower than its 37-by-9 bounds might suggest.

Practical guidance:

- 8-by-8 should remain comfortable for interactive experimentation.
- 16-by-16 is workable, but expect a pause after changes.
- 24-by-24 is a deliberate slow example.
- 32-by-32 should normally be treated as batch work.
- `LOGOSC128 ***` is an intentional multi-minute batch fixture, not an interactive editing
  scene.
- Use `Topology` while authoring large masks, then switch to `Cord`, `Ribbon`, or `Plaque` for
  final review.

## Progress reporting

OpenSCAD does not provide a model-level percentage-complete callback. A model can emit milestone
messages with `echo()`, but evaluation is demand driven and the later CGAL render/export phase is
owned by OpenSCAD, so those messages cannot provide a reliable overall percentage. OpenSCAD's
status bar and console remain the best indicators during render or export. The showcase therefore
prints an early time estimate rather than a misleading percentage.

## Command-line timing

From the repository root:

```powershell
$openScadCli = 'C:\Program Files\OpenSCAD\openscad.com'
$outputPath = Join-Path $env:TEMP 'LogoSC-large-celtic.csg'

Measure-Command {
    & $openScadCli `
        -D 'CelticLargeExample=\"Ring16\"' `
        -D 'CelticLargeOutput=\"Cord\"' `
        -o $outputPath `
        'LogoSC-Celtic-Large-Grids.scad'
}
```

Inspect OpenSCAD's console output for the exact rows, columns, occupied-cell count, components,
crossings, and cord segments generated by the selected scene.
