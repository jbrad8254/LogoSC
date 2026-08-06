# LogoSC Knots & Celtic Designs

This self-contained suite creates mathematical knots and links, circular braids, adjacent and
crossing-aware bundles, Celtic tile grids, planar ribbons, bas-relief, and configurable plaques.

## Open this first

- Open `LogoSC-Knots-Examples.scad` for the main Customizer galleries and individual designs.
- Open `LogoSC-Celtic-Large-Grids.scad` for Diamond8, Ring16, Diamond24, Ring32, CELTIC,
  `LOGOSC128 ***`, the reference `GeneratedPlaque **`, and accelerated `FastSvgPlaque` scenes.
- Keep `Cord` as the large-grid default until you deliberately choose Ribbon or Plaque output.

Large scenes can take time. The large-grid showcase prints an early scene/output-specific estimate;
it does not fake a percentage-complete callback that OpenSCAD does not provide.

## Documentation

- `LogoSC-Suite-Guide.md` — illustrated overview of every knot and Celtic output family.
- `LogoSC-Celtic-Large-Grids.md` — controls, scaling measurements, output choices, and quoting.
- `tools/logosc-knot-grid/README.md` — optional C++20 grid, topology, and SVG compiler guide.
- `generated/LogoSC-Celtic-Generated.grid` — plain unquoted ASCII grid used by the generated plaque.
- `generated/LogoSC-Celtic-Generated.svg` — pre-resolved interlaced regions used by the fast plaque.
- `LogoSC-Knots-Design.md` — topology, generators, renderers, dependencies, and verification.
- `LogoSC-User-Manual.md` — complete user-facing knot chapters and Core reference.
- `LogoSC-Version.txt` — exact package source identity.

## Verification

`LogoSC-Knots-Test-Runner.scad` runs the independent deterministic knot suite. The package also
includes the passive test definitions and Foundation dependency used by that runner.

## Source and issues

Source and bug reports: <https://github.com/jbrad8254/LogoSC>.
