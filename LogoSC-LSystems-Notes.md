# LogoSC L-System Notes

## Purpose

This note describes how L-systems fit into LogoSC examples and future planning.
It is not a new public API specification. LogoSC remains a small OpenSCAD
geometry DSL that evaluates command lists into closed 2D regions.

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

`LogoSC-Examples.scad` now contains a small generic L-system helper used only by
the examples. It demonstrates the technique without making L-systems part of the
public LogoSC command language.

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
branches. A clean printable version probably wants future stroke/open-path
rendering, or an explicit branch-thickening helper that converts centerlines into
closed polygons.

### Dragon, Hilbert, Peano, and Gosper curves

These curves are visually strong and good stress tests for recursion and command
length. Most are naturally open centerline curves, so they are better future
examples after LogoSC has a stroke renderer or a documented `offset()` workflow
for thickened paths.

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

For now:

- keep L-system helpers in `LogoSC-Examples.scad` or example-specific files;
- do not add new core LogoSC opcodes for L-systems;
- do not make L-system rewriting part of `RenderLogo2D()`;
- prefer closed-boundary examples that work with LogoSC's current region model;
- defer open centerline examples until stroke/open-path rendering is designed.

That keeps LogoSC focused: the core remains a 2D region generator, while L-systems
serve as a compact way to generate interesting command lists.
