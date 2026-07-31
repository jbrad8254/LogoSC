# LogoSC Large Celtic Grid Showcase

`LogoSC-Celtic-Large-Grids.scad` demonstrates the canonical `"."` blank cell with grids large
enough to expose both its design possibilities and its computational cost.

## Included scenes

Select `CelticLargeExample` in OpenSCAD's Customizer:

| Scene | Purpose |
|---|---|
| `Diamond8` | Small responsive 8-by-8 irregular region |
| `Ring16` | Medium 16-by-16 region with an internal blank opening |
| `Diamond24` | Slow 24-by-24 stress example |
| `Ring32` | Very slow 32-by-32 stress example with exterior and interior boundaries |
| `CELTIC` | A 37-by-9 bitmap word mask built from blank and occupied cells |

The word mask is ordinary grid data. Five-by-seven glyphs select occupied cells; `"."` leaves
the remaining cells empty. Occupied cells receive deterministic `X`, `>`, and `<` tiles. The
normal Celtic compiler then discovers boundary loops, traces closed components, assigns
crossings, and verifies cyclic alternation.

![CELTIC spelled with blank-cell knot grids](images/knot-celtic-word.png)

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

These measurements were taken on the development machine through `openscad.com`. They are useful
scale indicators, not universal performance guarantees.

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

The cost is not determined by the rectangular dimensions alone. Occupied-cell count, boundary
length, number of separate boundary loops, route-component count, crossings, sampling, and
rendering resolution all matter. The word is relatively sparse but has many disconnected letter
strokes and boundary loops, so it is slower than its 37-by-9 bounds might suggest.

Practical guidance:

- 8-by-8 should remain comfortable for interactive experimentation.
- 16-by-16 is workable, but expect a pause after changes.
- 24-by-24 is a deliberate slow example.
- 32-by-32 should normally be treated as batch work.
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
