# LogoSC L-Systems Guide

`LogoSC-LSystems.scad` is an optional companion that expands deterministic L-system grammars and
translates their symbols into ordinary LogoSC command lists. It does not add opcodes to Core and
does not change `RenderLogo2D()`.

L-systems are more than recursion demonstrations. They are useful for designs whose structure
repeats at several scales: branching trees, roots, coral, leaf veins, lightning-like traces,
space-filling paths, decorative borders, fractal cutouts, ornaments, and texture or infill paths.
Changing a rule or expansion depth creates a coherent family of related parts without drawing
each branch or edge separately. For regular grids, fixed hole patterns, and other simple
repetition, an OpenSCAD loop or ordinary LogoSC command list is usually clearer.

## Table of contents

- [Quick start](#quick-start)
- [Built-in systems](#built-in-systems)
- [Data model](#data-model)
- [Expansion and interpretation](#expansion-and-interpretation)
- [Worked expansion: one Koch level](#worked-expansion-one-koch-level)
- [Closed and open output](#closed-and-open-output)
- [Performance](#performance)
- [Scope boundary](#scope-boundary)

## Quick start

Keep `LogoSC-Foundation-Core.scad` and `LogoSC-LSystems.scad` together:

```scad
include <LogoSC-Foundation-Core.scad>
include <LogoSC-LSystems.scad>

// Construct the Koch preset record: triangular axiom, F rewrite rule,
// 60-degree turns, and the per-depth step divisor.
koch = MakeKochLSystem();
commands = LSystemCommands(koch, depth = 2, size = 45);

linear_extrude(height = 3)
{
    RenderLogo2D(commands);
}
```

Open `LogoSC-LSystems-Examples.scad` for the nine-model, 3-by-3 Customizer gallery. Its Koch,
quadratic Koch, and Sierpiński scenes render as filled boundaries. Hilbert, Dragon, Lévy C,
Gosper, plant, and canopy scenes are naturally open paths, so the examples convert their segments
into explicit round-ended printable outlines and extrude those outlines. This renderer belongs
to the example file rather than Core.

![Nine-model LogoSC L-system gallery rendered in OpenSCAD](images/l-system-gallery.png)

*The centered 3-by-3 gallery: Koch, Quadratic Koch, Sierpiński; Hilbert, Dragon, Lévy C; Gosper,
Plant, and Canopy.*

## Built-in systems

There are two equivalent ways to select a built-in system:

```scad
kochByName = LSystemPreset("Koch");
kochByConstructor = MakeKochLSystem();

levyByName = LSystemPreset("Levy C");
levyByConstructor = MakeLevyCLSystem();
```

`LSystemPreset(name)` expects one of the exact strings in the **Preset name** column below. The
direct constructor follows the convention `Make` + preset name with spaces removed + `LSystem`.
Thus `Quadratic Koch` becomes `MakeQuadraticKochLSystem()`, and the deliberately ASCII-only
`Levy C` becomes `MakeLevyCLSystem()`. These are named OpenSCAD functions, not constructor names
assembled dynamically at runtime.

In the compact notation, `F` and `G` draw, `+` and `-` turn by the listed angle, brackets save and
restore turtle state, and other letters are non-drawing grammar variables. Repeated signs mean
repeated turns.

| Preset name | Compact axiom and transforms | What it illustrates |
|---|---|---|
| `Koch` | `F--F--F`; `F -> F+F--F+F`; 60° | A triangular rule producing a closed snowflake boundary; the clearest introduction to substitution. |
| `Quadratic Koch` | `F+F+F+F`; `F -> F-F+F+FF-F-F+F`; 90° | A closed, square-grid island contrasting with Koch's triangular geometry. |
| `Sierpinski` | `F-G-G`; `F -> F-G+F+G-F`; `G -> GG`; 120° | Two drawing symbols cooperate to form a triangular recursive region; the printable example adds 10% overlap. |
| `Hilbert` | `A`; `A -> +BF-AFA-FB+`; `B -> -AF+BFB+FA-`; 90° | A grid-aligned space-filling path whose variables organize motion without drawing. |
| `Dragon` | `FX`; `X -> X+YF+`; `Y -> -FX-Y`; 90° | A folding curve generated mainly by non-drawing variables; orientation changes emerge from substitution. |
| `Levy C` | `F++F++F++F`; `F -> +F--F+`; 45° | The C-fold applied to all four sides of a square, creating a dense framed pattern rather than one wandering strand. |
| `Gosper` | `F`; `F -> F-G--G+F++FF+G-`; `G -> +F-GG--G-F++F+G`; 60° | A hexagonal space-filling curve with two mutually recursive drawing symbols and strong planar coverage. |
| `Plant` | `X`; `X -> F[++FX][---FGX]`; `F -> FF`; 10° | An asymmetric recursive Y tree demonstrating saved turtle states, deterministic taper, and print-oriented length compensation. |
| `Canopy` | `X`; `X -> F[+X][-X]`; `F -> FF`; 28° | A symmetric binary tree that isolates classic branching behavior and contrasts with the asymmetric Plant. |

The gallery orders these rows as closed regions, space-filling and folding curves, then branching
systems. Every open example is centered from its actual generated stroke bounds rather than from
an assumed formula.

`LSystemPresetNames()` returns the stable list used by the examples.

The Sierpiński curve's filled triangles normally meet only at points, which is unsuitable for a
single printed part. `LogoSC-LSystems-Examples.scad` therefore defaults
`SierpinskiOverlapPercent` to `10`. It offsets the filled regions by the amount that increases the
smallest triangle side by approximately 10%, producing deliberate overlap. The grammar and the
commands returned by `LSystemCommands()` remain mathematically unchanged.

## Data model

A rule is `[symbol, replacementSymbols]` and is constructed with:

```scad
rule = MakeLSystemRule(LSYS_F, [LSYS_F, LSYS_PLUS, LSYS_F]);
```

An interpretation is `[symbol, action, multiplier]`:

```scad
draw = MakeLSystemInterpretation(LSYS_F, LSYS_ACTION_DRAW);
turn = MakeLSystemInterpretation(LSYS_PLUS, LSYS_ACTION_TURN, 1);
```

The standard interpretations map `F` and `G` to drawing movement, lowercase `f` to pen-up
movement, `+` and `-` to turns, and bracket symbols to `PUSH` and `POP`. Grammar variables such as
`A`, `B`, `X`, and `Y` have no geometry unless an interpretation explicitly gives them an action.

A system record contains its name, axiom, rules, turn angle, per-depth step divisor, and
interpretations. Construct custom systems with `MakeLSystem()` and inspect them with
`LSystemName()`, `LSystemAxiom()`, `LSystemRules()`, `LSystemAngle()`,
`LSystemStepDivisor()`, and `LSystemInterpretations()`.

## Expansion and interpretation

`LSystemExpand(system, depth)` returns the rewritten symbols. Depth zero returns the axiom.
Symbols without a matching rule reproduce themselves, which is the conventional deterministic
L-system behavior.

`LSystemInterpret(symbols, step, angle, interpretations)` converts symbols into a LogoSC command
list. `LSystemCommands(system, depth, size)` performs both stages and calculates:

```text
step = size / stepDivisor^depth
```

The divisor is grammar-specific. It keeps the examples near a consistent physical scale while
their segment counts grow.

For a custom grammar:

```scad
custom = MakeLSystem(
    "Right Angle Walk",
    [LSYS_F],
    [MakeLSystemRule(LSYS_F, [LSYS_F, LSYS_PLUS, LSYS_F])],
    angle = 90,
    stepDivisor = 2
);

commands = LSystemCommands(custom, 3, 40);
```

## Worked expansion: one Koch level

The Koch preset is a useful small example because it has one drawing symbol and one rewrite rule.
In compact notation its starting axiom and rule are:

```text
axiom: F--F--F
rule:  F -> F+F--F+F
angle: 60 degrees
```

At depth zero, nothing has been rewritten, so the symbol sequence is simply the triangular axiom:

```text
F--F--F
```

For depth one, the expander examines every symbol in that sequence at the same time. Each `F` is
replaced by `F+F--F+F`. The `+` and `-` symbols have no rewrite rules, so they copy themselves.
Writing `K = F+F--F+F` temporarily makes the result easier to see:

```text
K--K--K
```

Expanding that abbreviation gives:

```text
F+F--F+F--F+F--F+F--F+F--F+F
```

The axiom contained three drawing symbols; depth one contains 12 because the rule replaces every
`F` with four new `F` symbols. Depth two repeats the same parallel operation on all 12 and
contains 48 drawing symbols. In general, this preset has `3 * 4^depth` drawing segments.

Expansion still produces symbols, not geometry. Interpretation is the separate next stage:

- `F` becomes a forward LogoSC `MOVE` that draws one segment;
- `+` becomes `TURN 60`; and
- `-` becomes `TURN -60`.

For `size = 45` at depth one, Koch's step divisor of `3` makes every forward step
`45 / 3^1 = 15` units. The turn sequence walks all three rewritten sides and returns to the
starting point, producing a closed region suitable for `RenderLogo2D()`.

The corresponding calls are:

```scad
koch = MakeKochLSystem();
depth0Symbols = LSystemExpand(koch, 0);
depth1Symbols = LSystemExpand(koch, 1);
depth1Commands = LSystemCommands(koch, depth = 1, size = 45);

echo("depth 0 symbols", depth0Symbols);
echo("depth 1 symbols", depth1Symbols);
echo("depth 1 LogoSC commands", depth1Commands);
```

OpenSCAD prints the integer symbol constants used internally rather than the compact letters shown
above, but the rewriting order and resulting command sequence are the same.

## Closed and open output

LogoSC Core produces filled regions. A closed L-system boundary is therefore a normal LogoSC
model and can use `evalLogo()`, `RenderLogo2D()`, extrusion, holes, and native OpenSCAD booleans.

Open curves are different: OpenSCAD will implicitly close a polygon if they are sent through the
filled-region renderer. The examples therefore hull circles along each generated segment to make
an explicit round-ended outline, then extrude it. `LSystemStrokeWidth` controls the base width.
Hilbert and Dragon default to `1.5` times that width.

The plant defaults to ten times the base width at its trunk and tapers continuously with height
to the original base width at the uppermost tips. Each segment is a hull between independently
sized endpoint circles, avoiding thick terminal segments when a branch returns from `POP`. The
grammar uses fixed step lengths and fixed turn angles; there is no random variation in its shape.
The starting thickness is controlled by `PlantTrunkWidthScale`.

This is intentionally example-owned printable geometry for these known systems, not a stable
general-purpose stroke-width, cap, or join API in Core.

The Plant preset recursively grows a trunk into asymmetric Y-shaped forks. At every level, the
left branch turns 20 degrees and advances one base step before repeating, while the slightly
longer right branch turns 30 degrees and advances one and a half. The printable stroke evaluator
uses `G` for the final half-step on that arm. The grammar's `F -> FF` expansion would
make each successive level one half the preceding length, so the printable example applies a
`1.5` branch-step compensation for an exact net scale of three quarters. The example adds one
level to the requested depth, up to four levels, producing 16 terminal tips at its default depth.
`PUSH` and `POP` return both branches to the same fork point. The lengths and angles are fixed.
Each recursive trunk section uses one base step, keeping the crown compact relative to its
branches.

To keep the Plant close in size to the other gallery models, the printable example halves the
lengths at branch depths zero and one—the original trunk and first Y arms. This changes only
their geometry; the 10-times trunk width and the rest of the continuous width taper are not
scaled down. It also applies a `0.7` overall movement-length factor, reducing both planar
dimensions by 30 percent without scaling any stroke widths.

## Performance

L-system growth is usually exponential. Keep interactive depths modest and inspect symbol or
command counts before attempting a dense render. The Customizer caps its plant and general depth
choices, but custom callers remain responsible for practical limits.

Useful checks include:

```scad
symbols = LSystemExpand(system, depth);
commands = LSystemCommands(system, depth, size);
echo("symbols", len(symbols), "commands", len(commands));
```

Run `LogoSC-LSystems-Test-Runner.scad` after companion changes. Its independent deterministic
suite covers record validity, rewriting, interpretation, scaling, closed endpoints, and balanced
branch stacks.

## Scope boundary

The companion owns grammar symbols, rules, expansion, and interpretation. Core continues to own
LogoSC command evaluation and filled regions. Native OpenSCAD continues to own 3D composition.
Distribution packaging is intentionally deferred until the companion API, examples, tests, and
documentation are accepted.
