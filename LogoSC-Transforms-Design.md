# LogoSC Local Transform Design Notes

## Status and purpose

This document records preliminary design direction for a future LogoSC local-transform
feature. It is not an implemented command reference or a commitment to exact syntax.

The immediate development priority remains optional inter-contour and hole validation.
Transform implementation should begin only after that work has a clean, verified checkpoint.

The purpose of recording the transform direction now is to preserve the reasoning needed for
the later design review.

## Motivation

LogoSC already carries position, heading, and uniform scale through command evaluation. That
state acts as a limited local coordinate frame. A more complete local transform would make it
possible to:

- reuse one command list at different orientations and proportions;
- construct radial and reflected patterns without transformed command variants;
- build reusable decorative motifs, including future interlaced-knot work;
- apply the same transformation rules to movement, primitives, holes, debugging, and
  validation; and
- keep transformation inside LogoSC's existing functional evaluator rather than wrapping
  each individual command in ad hoc coordinate calculations.

Native OpenSCAD remains responsible for ordinary model-level 2D and 3D transforms. This
feature would affect coordinates generated while LogoSC evaluates a command list; it would not
turn LogoSC into a general scene-graph or 3D transformation system.

## Agreed design direction

### Use the existing state stack

Local transforms should be part of ordinary Logo state. Existing `[PUSH]` and `[POP]`
operations should save and restore the complete state, including the complete local transform.

Do not introduce a separate matrix stack or separate transform-specific push and pop commands.

The intended rule is:

> `PUSH` saves the complete current drawing state, and `POP` restores it.

### Preserve sequential loop behavior

`REPEAT` and `RUN` should continue passing the result state of one evaluated command or
iteration into the next. A transform applied inside a repeated body therefore remains active
in later iterations until an explicit `POP` restores an earlier state.

Neither `REPEAT` nor `RUN` should add implicit save or restore behavior. Existing LogoSC
programs rely on movement, heading, and scale accumulating through repeated commands.

A sixfold radial pattern would use the existing stack explicitly:

```scad
[
    [PUSH],

    [REPEAT, 6,
        [
            [PUSH],
                [RUN, motif],
            [POP],

            [TURN, 60]
        ]
    ],

    [POP]
]
```

The inner pair prevents `motif` from changing the starting state of the next copy. `TURN`
appears after the inner `POP`, so its accumulated orientation is not restored away. The outer
pair is optional and restores the caller's state after the complete pattern.

Programs that deliberately want progressive movement or rotation can omit either pair.

### Keep `TURN` as the rotation operation

Do not add a separate `ROTATE` command merely to rotate the local coordinate frame. Existing
`TURN` already changes the direction inherited by subsequent relative drawing operations.
Treating the turtle state as a local coordinate frame makes turtle turning and local-frame
rotation the same operation.

Retaining `TURN` avoids an unclear distinction between "turn the turtle" and "rotate the
frame" and preserves the stable opcode.

The exact absolute semantics of `DIR` under a general local transform remain an open question.

### Apply the complete transform to relative movement

`MOVE` should continue to follow and be scaled by the current transform. Its behavior should
be defined from a local displacement rather than from selected state fields:

```text
localDisplacement = [distance, 0]
worldDisplacement = TransformVector(currentTransform, localDisplacement)
newPosition       = currentPosition + worldDisplacement
```

Equivalently:

```text
worldDisplacement =
    TransformPoint([distance, 0]) - TransformPoint([0, 0])
```

This definition makes relative movement inherit the complete linear transform, including
orientation, independent axis scaling, reflection, shear, and composed combinations of them.
A particular canonical shear convention may leave one basis direction unchanged, but movement
must still be evaluated through the complete transform rather than a shortcut such as
`distance * scaleX`.

### Generate locally, then transform

Primitives and tessellated curves should be constructed in local coordinates and have their
generated points transformed afterward. This gives the same transformation model to:

- `MOVE` destinations;
- `ARC` tessellation;
- `CIRCLE`;
- `REGPOLY`;
- `RECT`;
- `ROUNDEDRECT`;
- outer contours and holes;
- debug-renderer points and segments; and
- explicit paths consumed by optional validation.

Under a general affine transform, circles and circular arcs may become ellipses or sheared
elliptical curves. Transforming tessellated points avoids separate special-case geometry
algorithms for each transformed primitive.

Reflections may reverse contour winding. Rendering and validation must treat that as a
deliberate transform result rather than accidentally assuming the old winding direction.

## Readable canonical state

The public and diagnostic state should remain readable. Exposing an anonymous 2-by-3 affine
matrix as ordinary Logo state is not the preferred design.

A candidate canonical form is:

```text
[x, y, heading, scaleX, scaleY, shear]
```

Its intended conceptual order is:

```text
local point
    -> independent X/Y scale
    -> one canonical shear
    -> heading rotation
    -> x/y translation
```

This has the six degrees of freedom required by a general two-dimensional affine transform
while retaining meaningful fields. One shear value is necessary: composing rotations and
nonuniform scales in different orders can produce shear even if LogoSC initially exposes no
explicit shear command.

Negative scale values should represent reflections. A unique canonical sign convention is
still to be chosen. One candidate is:

- keep `scaleX` nonnegative;
- carry the reflection sign in `scaleY`;
- normalize `heading` to a documented range; and
- use zero shear for ordinary translation, rotation, and scale states.

Zero scale collapses an axis and makes canonical decomposition ambiguous. The first
implementation should probably reject zero scale components unless a concrete use case
justifies carefully designed degenerate-transform semantics.

## Internal representation

The implementation may temporarily operate on geometrically named values such as:

```text
origin
xBasis
yBasis
```

Applying an operation to these values and recanonicalizing the result is mathematically
equivalent to affine matrix composition, but it need not expose matrix coefficients in public
state or ordinary evaluator code.

A possible recanonicalization procedure is:

1. Derive the transformed local X and Y basis vectors.
2. Obtain `scaleX` and `heading` from the X basis.
3. Project the Y basis parallel and perpendicular to the normalized X basis.
4. Derive canonical shear from the parallel component.
5. Derive signed `scaleY` from the perpendicular component.
6. Normalize angles, signs, and near-zero values according to documented tolerances.

The design review must establish formulas, operation order, sign rules, numerical tolerances,
and behavior near singular transforms before implementation.

## Possible command surface

No new command syntax is approved yet. The smallest backward-compatible direction appears to
be:

```scad
[TURN, degrees]          // existing relative rotation
[SCALE, uniform]         // existing behavior
[SCALE, scaleX, scaleY]  // possible compatible extension
```

Negative scale components would provide reflections. The evaluator may need to retain a
generated shear value even if no public `SHEAR` command is initially added.

An explicit shear command should be added only if real examples demonstrate that users need to
request shear directly rather than merely preserve shear created by composed transforms.

## Compatibility constraints

Transform work affects stable and documented behavior across:

- the public state format and state constructors;
- `ResultState()` and `ResultStack()`;
- `PUSH` and `POP`;
- `MOVE`, `TURN`, `DIR`, `SCALE`, and `GOTO`;
- `RUN`, `REPEAT`, and `HOLE` scoping;
- primitive placement and tessellation;
- `RenderLogoDebug()`;
- `evalLogoPaths()` and optional validation; and
- tests and examples that compare exact state or point values.

The current public state is `[x, y, heading, scale]`. Replacing that shape casually would break
callers that construct or inspect state directly. The detailed design must choose a
backward-compatible migration strategy before any source change.

Existing one-argument `SCALE`, ordinary `TURN`, and uniform-scale results should retain their
current observable behavior within established numerical tolerances.

## Open design questions

The later design review must resolve at least:

1. What exact canonical field order, shear convention, and sign normalization should be used?
2. How should the public state evolve without breaking existing state construction and
   indexing?
3. Does a two-argument `SCALE` provide the clearest syntax for independent axis scaling?
4. Should an explicit `SHEAR` command exist initially, later, or not at all?
5. Should zero or near-zero scale be rejected, clamped, or represented as a degenerate state?
6. Are `GOTO` coordinates world-absolute, parent-frame absolute, or local-frame coordinates?
7. Does `DIR` set a world direction or a direction relative to a parent frame?
8. What composition side and order best preserve intuitive Logo-style `TURN` behavior?
9. How should reflected winding be reported or normalized for outer contours and holes?
10. How should tessellation density respond when nonuniform scale or shear greatly stretches a
    curve?
11. What tolerance should canonicalization use to avoid insignificant floating-point shear and
    angle noise?
12. Which state, evaluator, debug, validation, and rendered-geometry tests establish the
    compatibility boundary?

## Planned sequencing

1. Finish inter-contour and hole validation, including overlapping-hole cases.
2. Run the complete Foundation and Validation acceptance suite and establish a clean checkpoint.
3. Review this note and resolve the open transform questions.
4. Specify the canonical state and compatibility strategy before assigning any opcode or
   changing Core.
5. Implement transforms incrementally, beginning with behavior that reproduces existing
   translation, heading, and uniform-scale results.
6. Add independent scale and reflection only with evaluator, path, debug, validation, and
   visual regression coverage.
7. Defer explicit shear syntax and specialized knot generation until the underlying transform
   semantics are stable.

## Non-goals for the first implementation

- A second transform stack.
- Implicit save or restore around `RUN` or `REPEAT`.
- A separate `ROTATE` opcode duplicating `TURN`.
- Public exposure of anonymous affine-matrix coefficients.
- Three-dimensional transforms.
- Automatic repair of reflected, self-intersecting, or otherwise invalid regions.
- A knot-specific opcode in Core.

