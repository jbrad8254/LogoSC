# LogoSC L-System Notes

## Purpose

This note records the design rationale behind the implemented optional
`LogoSC-LSystems.scad` companion. The public usage guide is
`LogoSC-LSystems-Guide.md`. LogoSC remains a small OpenSCAD geometry DSL that
evaluates command lists into closed 2D regions.

L-systems are useful in LogoSC because they generate long turtle-style command
sequences from compact recursive rules. They are especially good for fractal
boundaries, decorative outlines, branching patterns, and examples that stress
recursive command-list construction.

## Basic model

An L-system has three parts:

- an **axiom**, or starting symbol sequence;
- one or more **rewrite rules** that replace symbols with longer symbol
  sequences;
- an **interpretation step** that maps final symbols to turtle commands.

A classic Koch rule can be written conceptually as:

```text
Axiom: F--F--F
Rule:  F -> F+F--F+F
```

After a fixed number of expansion passes, the final symbols are interpreted as
LogoSC commands:

| Symbol | LogoSC command meaning |
|---|---|
| `F` | `[MOVE, step]` |
| `+` | `[TURN, angle]` |
| `-` | `[TURN, -angle]` |
| `[` | `[PUSH]` |
| `]` | `[POP]` |

The examples use integer symbols rather than string characters because that
keeps the OpenSCAD code simple and avoids depending on string-processing quirks.
The idea is the same.

## Why this fits LogoSC

LogoSC already has the main turtle operations needed by common L-systems:

- relative movement through `MOVE`;
- relative heading changes through `TURN`;
- stack-based branching through `PUSH` and `POP`;
- command-list reuse through ordinary OpenSCAD functions and LogoSC `RUN`;
- closed-region rendering through `RenderLogo2D()`.

The main missing piece is symbol rewriting. For now, that belongs in examples or
helper functions, not in the core interpreter.

## Direct recursion vs. a generic L-system helper

There are two useful patterns.

- **Direct recursive command generators** are clear for one named fractal and
  easy to debug. Their weakness is that each example repeats its own recursion
  logic.
- **Generic symbol rewrite helpers** separate grammar expansion from turtle
  interpretation. Their weakness is that they add a second mini-language beside
  LogoSC.

`LogoSC-LSystems.scad` now provides generic integer-symbol rules, deterministic
expansion, action-based interpretation, and named preset constructors. It emits
ordinary LogoSC commands without making L-systems part of the Core command
language. The earlier helpers remain temporarily embedded in
`LogoSC-Examples.scad` so existing generated suites do not acquire a new file
dependency before the authorized distribution phase.

## Examples that fit well

### Koch snowflake / Koch medallion

This is the best starter L-system for LogoSC. It produces a closed boundary and
therefore works naturally with LogoSC's current filled-region renderer. It can be
used as a solid ornament, a medallion with a central hole, or a decorative hole
inside a plate.

### Quadratic Koch island

This square-grid fractal uses 90-degree turns and creates a jagged closed island.
It is useful because it looks different from the triangular Koch snowflake while
still producing a printable closed region. It also demonstrates why the step
length must shrink as rewrite depth grows.

### Fractal edge plate

A practical CAD-style use is to use an L-system boundary as the edge of a plate,
tag, washer, coaster, or ornament. This keeps the example printable and avoids
needing open-stroke rendering.

### Branching tree or plant

Branching systems map naturally to `PUSH` and `POP`:

```text
F -> F[+F]F[-F]F
```

They are excellent teaching examples, but their natural output is an open set of
branches. The companion examples now turn those centerlines into printable
round-ended outlines. Plant demonstrates asymmetric, tapered fabrication geometry;
Canopy keeps the classic binary tree symmetric for comparison.

### Dragon, Hilbert, Lévy, and Gosper curves

These curves are visually strong and good stress tests for recursion and command
length. The gallery thickens them with its example-owned stroke renderer. Hilbert
shows orthogonal space filling, Dragon shows folding through non-drawing variables,
Gosper fills a hexagonal region with two drawing symbols, and the four-sided Lévy
frame shows how changing only the axiom can make one rewrite rule occupy space much
more effectively.

## Examples that should not use L-systems

Use simple LogoSC or OpenSCAD loops for ordinary repetition. L-systems are usually
not worth the extra machinery for:

- regular polygons;
- radial screw-hole patterns;
- simple rounded rectangles;
- normal gear-like repetition;
- fixed arrays of mounting holes;
- straightforward layout.

The rule of thumb is: use an L-system when recursive substitution is the point.
Use `REPEAT`, OpenSCAD `for`, or plain command lists when the shape is merely
repetitive.

## Performance and geometry cautions

L-system output usually grows exponentially. A visually innocent depth change can
turn a small command list into thousands of segments.

Practical guidelines:

- keep example depths small;
- prefer depth `1` or `2` for gallery examples;
- use depth `3` cautiously;
- avoid making dense fractals the default preview model;
- remember that OpenSCAD preview, render, export, slicing, and printing all pay
  for polygon complexity.

Closed L-system boundaries must also remain valid polygons. Self-intersections,
near-zero edges, and overly dense outlines can produce confusing polygon output.
When in doubt, reduce depth first.

## Current implementation stance

- Keep grammar rewriting in the optional companion and add no Core opcodes.
- Translate final symbols into ordinary LogoSC command lists.
- Provide Koch, quadratic Koch, Hilbert, Dragon, Sierpiński, plant, Lévy C, Gosper, and canopy
  presets in a centered 3-by-3 example gallery.
- Render closed boundaries through normal Core APIs.
- Give the known open examples explicit round-ended printable outlines in the
  examples file, without presenting that example-owned renderer as a stable
  general manufacturable stroke API in Core.
- Keep tests and examples independent from the complete Foundation runner.
- Defer all distribution manifests, storefront descriptions, package guides,
  and archives until explicitly authorized.

That keeps LogoSC focused: the core remains a 2D region generator, while L-systems
serve as a compact way to generate interesting command lists.
