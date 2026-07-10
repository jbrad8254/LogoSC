# LogoT Cheat Sheet

Compact LogoT `2026.0` reference. Full docs: [`LogoT-User-Manual.md`](LogoT-User-Manual.md). Inspired by the compact section style of the [OpenSCAD cheat sheet](https://openscad.org/cheatsheet/index.html?version=2021.01).

## Setup

[`include <LogoT-Foundation-Core.scad>`](LogoT-User-Manual.md#setup)  [`RunLogoTests = false;`](LogoT-User-Manual.md#setup)  [`TraceLevel = 0;`](LogoT-User-Manual.md#setup)

## Version

[`LogoTVersionMajor`](LogoT-User-Manual.md#library-version)  [`LogoTVersionMinor`](LogoT-User-Manual.md#library-version)  [`LogoTVersion`](LogoT-User-Manual.md#library-version)  [`LogoTVersionAtLeast(major, minor)`](LogoT-User-Manual.md#library-version)

## Command vector syntax

[`cmds = [[OP, arg...], ...];`](LogoT-User-Manual.md#10-command-reference)  optional trailing fields: `[OP, required[, optional]]`

## Motion / state

[`[MOVE, len]`](LogoT-User-Manual.md#move)  [`[TURN, deltaHeading]`](LogoT-User-Manual.md#turn)  [`[DIR, absoluteHeading]`](LogoT-User-Manual.md#dir)  [`[SCALE, scaleMultiplier]`](LogoT-User-Manual.md#scale)  [`[GOTO, x, y, heading]`](LogoT-User-Manual.md#goto)

## Closed geometry

[`[ARC, radius, degrees[, segments]]`](LogoT-User-Manual.md#arc)  [`[CIRCLE, radius[, segments]]`](LogoT-User-Manual.md#circle)  [`[REGPOLY, sides, radius[, rotation]]`](LogoT-User-Manual.md#regpoly)  [`[RECT, width, height]`](LogoT-User-Manual.md#rect)  [`[ROUNDEDRECT, width, height, radius[, segments]]`](LogoT-User-Manual.md#roundedrect)  [`[HOLE, cmds]`](LogoT-User-Manual.md#hole)

## Control / structure

[`[RUN, cmds[, scale[, maxRec]]]`](LogoT-User-Manual.md#run)  [`[REPEAT, count, cmds]`](LogoT-User-Manual.md#repeat)  [`[PUSH]`](LogoT-User-Manual.md#push-and-pop)  [`[POP]`](LogoT-User-Manual.md#push-and-pop)  [`[PENUP]`](LogoT-User-Manual.md#penup-and-pendown)  [`[PENDOWN]`](LogoT-User-Manual.md#penup-and-pendown)

## Rendering / evaluation API

[`RenderLogo2D(cmds, convexity = 10)`](LogoT-User-Manual.md#73-renderlogo2d)  [`evalLogo(cmds)`](LogoT-User-Manual.md#74-evallogo)  [`ResultState(result)`](LogoT-User-Manual.md#75-evaluator-result-accessors)  [`ResultContours(result)`](LogoT-User-Manual.md#75-evaluator-result-accessors)  [`ResultStack(result)`](LogoT-User-Manual.md#75-evaluator-result-accessors)  [`ResultPen(result)`](LogoT-User-Manual.md#75-evaluator-result-accessors)  [`MakeRegion(...)`](LogoT-User-Manual.md#76-region-constructor-and-accessors)  [`RegionOuter(region)`](LogoT-User-Manual.md#76-region-constructor-and-accessors)  [`RegionHoles(region)`](LogoT-User-Manual.md#76-region-constructor-and-accessors)  [`RenderContours2D(regions, convexity = 10)`](LogoT-User-Manual.md#77-rendercontours2d)  [`RenderRegion2D(region, convexity = 10)`](LogoT-User-Manual.md#78-renderregion2d)

## Region data

[`region = [outerContour, holeContour0, ...]`](LogoT-User-Manual.md#6-rendering-model)  [`regions = [region0, region1, ...]`](LogoT-User-Manual.md#6-rendering-model)

## Segment controls

[`$fn`](LogoT-User-Manual.md#9-segment-count-controls)  [`$fa`](LogoT-User-Manual.md#9-segment-count-controls)  [`$fs`](LogoT-User-Manual.md#9-segment-count-controls)  [`segments`](LogoT-User-Manual.md#9-segment-count-controls)

## Core controls

[`RunLogoTests`](LogoT-User-Manual.md#13-error-handling-and-tracing)  [`HardErrors`](LogoT-User-Manual.md#13-error-handling-and-tracing)  [`TraceLevel`](LogoT-User-Manual.md#13-error-handling-and-tracing)  [`maxRunRecursions`](LogoT-User-Manual.md#run)

## Test helpers

[`LogoTest(testName, vtCmds, testIndex, height, testColor)`](LogoT-User-Manual.md#13-error-handling-and-tracing)

## Common OpenSCAD wrappers

[`linear_extrude(height, center, convexity, twist, slices)`](LogoT-User-Manual.md#linear-extrusion)  [`rotate_extrude(angle, convexity)`](LogoT-User-Manual.md#rotate-extrusion)  [`offset(r)`](LogoT-User-Manual.md#8-3d-printing-workflow)  [`offset(delta, chamfer)`](LogoT-User-Manual.md#8-3d-printing-workflow)  [`translate([x, y, z])`](LogoT-User-Manual.md#8-3d-printing-workflow)  [`rotate([x, y, z])`](LogoT-User-Manual.md#8-3d-printing-workflow)  [`scale([x, y, z])`](LogoT-User-Manual.md#8-3d-printing-workflow)  [`color(name)`](LogoT-User-Manual.md#13-error-handling-and-tracing)  [`union()`](LogoT-User-Manual.md#8-3d-printing-workflow)  [`difference()`](LogoT-User-Manual.md#8-3d-printing-workflow)  [`intersection()`](LogoT-User-Manual.md#8-3d-printing-workflow)

## More

[`README`](LogoT-README.md)  [`User Manual`](LogoT-User-Manual.md)  [`Examples`](LogoT-Examples.scad)  [`ARC note`](LogoT-ARC-Implementation.md)  [`Holes note`](LogoT-Holes-Implementation.md)  [`Changelog`](CHANGELOG.md)
