# LogoSC Core Guide

LogoSC Core is the complete stable drawing library for ordinary model authors. Basic use requires
only `LogoSC-Foundation-Core.scad`.

## Quick start

```scad
include <LogoSC-Foundation-Core.scad>

shape =
[
    [ROUNDEDRECT, 70, 40, 6],
    [HOLE, [[CIRCLE, 8]]]
];

linear_extrude(height = 3, convexity = 10)
{
    RenderLogo2D(shape);
}
```

Open `LogoSC-Core-Examples.scad` for Core-only Customizer examples. It deliberately avoids the
validation and passive test dependencies used by the engineering gallery.

## What Core adds beyond Mini

- complete movement, heading, pen, stack, repetition, and command-list behavior;
- multi-contour regions and holes;
- affine command transforms;
- evaluator result, contour, and region accessors;
- `RenderLogo2D()`, `RenderContours2D()`, and `RenderRegion2D()`; and
- preview-only `RenderLogoDebug()` diagnostics.

Use `LogoSC-CheatSheet.md` for signatures. The complete `LogoSC-User-Manual.md` provides the full
language tutorial and reference; links to specialized packages are deliberate even when those
optional files are not installed locally.

## Optional companions

Path validation belongs to LogoSC Developer. Knots & Celtic Designs and Nuts & Bolts are
self-contained specialized suites. None is required by Core.

## Source and bugs

The authoritative repository and issue tracker are at <https://github.com/jbrad8254/LogoSC>.
