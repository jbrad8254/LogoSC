# LogoSC Mini Guide

LogoSC Mini is the quickest path from readable turtle commands to a printable OpenSCAD model.
It uses the same `LogoSC-Foundation-Core.scad` runtime as every larger LogoSC suite, but teaches a
small, deliberately chosen command surface.

## Start in five minutes

1. Install OpenSCAD.
2. Extract the complete Mini ZIP into one directory.
3. Open `LogoSC-Mini-Examples.scad`.
4. Choose `Triangle`, `Flower`, `Badge`, `PlateWithHole`, or `PrintableToken` in the Customizer.
5. Press **F5** to preview or **F6** to render, then export through OpenSCAD.

The example file uses native `linear_extrude()` around LogoSC's 2D output. Change `MiniHeight` to
change the thickness without changing the command list.

## The Mini idea

A LogoSC model is a list of commands:

```scad
triangle =
[
    [MOVE, 40],
    [TURN, 120],
    [MOVE, 40],
    [TURN, 120],
    [MOVE, 40]
];

linear_extrude(height = 3)
{
    RenderLogo2D(triangle);
}
```

The turtle starts at the origin facing along positive X. `MOVE` advances it and `TURN` changes its
heading in degrees. The resulting closed contour becomes a filled region.

## Learn next

- Use `ARC` to add curved motion.
- Put a reusable list inside `RUN`.
- Use `REPEAT` to build motifs.
- Start with `CIRCLE`, `REGPOLY`, `RECT`, or `ROUNDEDRECT` for common shapes.
- Wrap a contour in `HOLE` to subtract it from its containing outer region.

See `LogoSC-Mini-CheatSheet.md` for signatures and `LogoSC-Suite-Guide.md` for the larger LogoSC
family. LogoSC Core is the next package when you want the complete language and user guide.

## Scope

Mini documents a compatible subset, not a different interpreter. The included Core runtime has
additional capabilities so Mini projects can grow without being rewritten. Validation, automated
tests, knots, and fasteners are intentionally presented in other suites.

## Source and bugs

The package version record identifies the exact source state. LogoSC has one authoritative GitHub
repository and issue tracker: <https://github.com/jbrad8254/LogoSC>.
