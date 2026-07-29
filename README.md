# LogoSC

![LogoSC wordmark](images/logosc-wordmark.png)

LogoSC is a small Logo-inspired turtle geometry layer for OpenSCAD. It turns compact command lists into 2D printable regions that can be extruded, subtracted, combined, and otherwise composed with ordinary OpenSCAD code.

LogoSC is not trying to be a full Logo language. It is a lightweight OpenSCAD geometry DSL for making reusable 2D shapes, holes, ornaments, plaques, cutouts, and 3D-printing-friendly parts.

## What LogoSC does

- Evaluates turtle-style command lists such as `MOVE`, `TURN`, `ARC`, `RUN`, and `REPEAT`.
- Creates filled 2D regions using commands such as `CIRCLE`, `RECT`, `ROUNDEDRECT`, and `REGPOLY`.
- Supports region holes through `HOLE`.
- Supports reusable relative command lists through `RUN`.
- Provides a preview-only debug renderer for visualizing low-level path execution.
- Provides optional path analysis and validation without changing filled-region rendering.
- Provides an optional sampled-knot companion with structural validation, debug rendering, and
  torus knots or links with correct multi-component behavior.
- Leaves 3D composition to native OpenSCAD tools such as `linear_extrude()`, `difference()`, `union()`, and `translate()`.

## Engineering guidance and restart order

`LogoSC-Developer-Notebook.md` is the project's living engineering notebook. It
records design rationale, non-goals, lessons learned, historical milestones,
workflow rules, regression risks, and future plans that do not belong in the
public API documentation.

The repository also stores an AI Engineering Kit under `docs/ai-engineering-kit/` by
explicit user request. These files are maintainer-facing companion material, not LogoSC
public API or user documentation. For a fresh development session, read:

1. `docs/ai-engineering-kit/AI-Engineering-Kit-Handoff.md`
2. `docs/ai-engineering-kit/Codex-Git-Project-Quick-Start.md`
3. `docs/ai-engineering-kit/Generic-Project-Bootstrap.md`
4. `docs/ai-engineering-kit/ChatGPT-Project-Workflow.md`
5. `docs/ai-engineering-kit/Engineering-Preferences.md`
6. `docs/ai-engineering-kit/Project-Retrospective.md`
7. `LogoSC-Developer-Notebook.md`
8. `README.md`
9. `CHANGELOG.md`
10. `CONTRIBUTING.md`
11. `LogoSC-User-Manual.md` and implementation notes as needed

Root `AGENTS.md` provides the compact repository-specific operating rules for Codex and
points back to this detailed reading order.

Project-specific LogoSC guidance and the current Git working tree remain the sole authority
for current code, filenames, APIs, versions, and design decisions. When starting from an
uploaded repository ZIP, extract that current snapshot into the working tree first.

The notebook is intentionally historical. Add dated decisions and lessons rather
than replacing older reasoning with shorter summaries.

## Quick start

Open `LogoSC-Examples.scad` in OpenSCAD to see the example gallery. The top-level Customizer selector is:

```scad
LogoSCRunMode = "Examples"; // [NoDemo, Examples, Debug, Tests]
```

Use `Examples` for the normal gallery, `Debug` for the indexed debug-visualization gallery,
and `Tests` for the regression grid. In Debug mode, set `DebugDemoLayout` to `Selected`
to inspect one `DebugDemoExample`. `NoDemo` or a blank string explicitly suppresses
automatic output in the examples file. Ordinary user models can omit `LogoSCRunMode`;
tests do not run unless explicitly selected.

The default Examples view combines basic shapes, holes, linear and rotational extrusions,
recursive L-system-inspired models, and a six-example local affine-transform row.

![LogoSC Examples gallery in OpenSCAD](images/examples-gallery.png)

The Debug view overlays the filled models with movement capsules and point markers, exposing
open endpoints, crossing paths, pen-up travel, arc tessellation, and primitive-generated edges.

![LogoSC indexed debug-renderer gallery in OpenSCAD](images/debug-renderer-gallery.png)

A complete test run ends with per-suite totals and one machine-readable result such as:

```text
LOGOSC_AUTOMATED_TEST_RESULT, PASS, suites, 2, failedSuites, 0, tests, 222, passed, 222, failed, 0
```

Set `LogoTestReportLevel = 2` to list every named automated test; the default level `1`
prints suite summaries and full details for every failure.

Tests normally continue so the final summary exposes the full regression pattern. Set
the `LogoTestFailFast` checkbox in the Examples file's `LogoSC Run` Customizer section only
while isolating a failure; OpenSCAD then stops at the first failed result and reports the shared
assertion location, caller trace, test name, and details.
An aggregate failing run also ends with `*** Test Suite Failed ***` as a prominent human cue;
the preceding `LOGOSC_AUTOMATED_TEST_RESULT` record remains the machine-readable authority.

The Tests view also renders a color-coded regression gallery for visual inspection. The image
complements the automated result records; it does not replace the final pass/fail summary.

![LogoSC visual regression-test gallery in OpenSCAD](images/regression-test-gallery.png)

For your own model, include the core file and call `RenderLogo2D()`. This first example intentionally uses only `MOVE` and `TURN`:

```scad
include <LogoSC-Foundation-Core.scad>
TraceLevel = 0;

triangle =
[
    [MOVE, 40],
    [TURN, 120],
    [MOVE, 40],
    [TURN, 120],
    [MOVE, 40]
];

linear_extrude(height = 4, center = true, convexity = 10)
{
    RenderLogo2D(triangle);
}
```

When run in OpenSCAD, the code above generates the following simple triangle.

![Simple triangle generated by the Quick Start example](images/readme-quickstart-triangle.png)

### Debug the same path

When filled output looks wrong, render the same command list with `RenderLogoDebug()`. It draws preview-only capsules and point markers that show the actual turtle path, including command order, start/end markers, pen-up moves, crossing lines, and unclosed polygons.

```scad
linear_extrude(height = 4, center = true, convexity = 10)
{
    RenderLogo2D(triangle);
}

RenderLogoDebug(
    triangle,
    segmentRadius = 0.15,
    pointRadius = 0.30,
    segmentHeight = 5,
    pointHeight = 7
);
```

`RenderLogoDebug()` adds lines for the moves and cylinders for the points to the triangle from the first part of this example.

![Triangle with RenderLogoDebug movement lines and point markers](images/readme-quickstart-triangle-debug.png)

Use the debug view before assuming the filled polygon is broken. It is often showing you that the path crossed itself, the corners arrived in the wrong order, or the turtle endpoint did not return to the start point.

### Validate the same path

Validation is optional and remains outside the standalone Core file. To enable it, keep
`LogoSC-Foundation-Validation.scad` beside Core and add a second include near the top of your
model:

```scad
include <LogoSC-Foundation-Core.scad>
include <LogoSC-Foundation-Validation.scad>

validation = ValidateLogoPaths(triangle);
echo("LogoSC path is valid", ValidationIsValid(validation));
ReportLogoValidation(triangle); // Echo warnings and continue.

RenderLogo2D(triangle);
```

Basic models need only Core. Enable the optional validator while developing parts whose bad
topology could otherwise reach `polygon()` or CGAL: it detects basic path defects, proper
self-intersections, holes outside or touching their outer contour, and overlapping or nested
holes. Use `ReportLogoValidation(triangle, strict = true)` when any issue should stop
evaluation. Set `checkSelfIntersections = false` or `checkHoleTopology = false` for highly
tessellated, already-trusted command lists when the corresponding quadratic scan is not wanted.
See `LogoSC-Validation-Implementation.md` for the algorithms, complexity, policy rationale, and
complete Validation test matrix.

### Generate a torus knot or link

Knot work remains outside LogoSC Core. Include the optional companion directly:

```scad
include <LogoSC-Knots.scad>

trefoil = MakeTorusKnot(2, 3, majorRadius = 20, minorRadius = 6);
ReportKnotValidation(trefoil, strict = true);
RenderKnotCords(trefoil, cordRadius = 1.2, fragments = 24);

RenderKnotCordBundle(
    trefoil,
    cordCount = 3,
    cordRadius = 0.8,
    cordGap = 0.35
);
```

`MakeTorusKnot(p, q, ...)` returns one closed sampled strand when `p` and `q` are coprime.
Otherwise it returns `gcd(p,q)` independently closed components. Open
`LogoSC-Knots-Examples.scad` for the unknot, trefoil, Hopf-link, and explicit-crossing gallery.
`RenderKnotCords()` converts every sampled strand into printable sphere-hulled capsules.
The caller chooses cord radius, sphere resolution, and sampling density.
`RenderKnotDebug()` remains the preview-only diagnostic view. The implemented bundle stage uses
stable transported lateral frames to create symmetric untwisted lanes. Supply either
`cordRadius` or `bundleWidth`; a supplied width fits the largest equal radius that preserves
`cordGap`. Recorded braid crossings expand to every bundle lane pair, inherit the master
over/under lift, and are checked against `2*cordRadius + minimumClearance`. Explicit bundle
twist and image import remain deferred. Planar debug mode projects the original 3D samples onto
`z = 0`; Spatial mode preserves their torus height.

`KnotView` applies consistently to Debug, Cord, Bundle, `CordGallery`, and `BundleGallery`
output. Planar projects a copy of the master samples before cord rendering or bundle expansion;
Spatial retains the original 3D route. A flattened cord view can fuse where the projection
crosses itself, so Planar manufacturing geometry is a comparison/design view rather than an
automatic printable-knot guarantee.

The torus, braid, Celtic-grid, and cord paths do not invoke LogoSC evaluation: sampling and
validation are pure OpenSCAD functions, and native OpenSCAD constructs the 3D capsules. The
planar ribbon compiler now uses Core region records and `RenderRegion2D()` for footprints and
crossing masks. See
`LogoSC-Knots-Design.md#how-logosc-is-used` for the complete dependency and call-flow boundary.

![LogoSC manufacturable knot-cord gallery](images/knot-cord-gallery.png)

Choose `CordGallery` in `LogoSC-Knots-Examples.scad` for the presentation scene. It uses the
actual torus generator and cord renderer; per-strand colors distinguish the two Hopf-link
components without changing their geometry.

![LogoSC adjacent knot-cord bundle gallery](images/knot-bundle-gallery.png)

Choose `BundleGallery` to compare two-, three-, and four-cord trefoil bundles. Colors identify
lanes for presentation only; the manufacturing renderer emits ordinary geometry.

### Generate a circular braid closure

Signed braid words explicitly control adjacent crossings:

```scad
braidTrefoil = MakeCircularBraidKnot(
    2,
    [1, 1, 1],
    majorRadius = 20,
    laneSpacing = 4,
    crossingHeight = 5
);

ReportKnotValidation(braidTrefoil, strict = true);
RenderKnotCordBundle(
    braidTrefoil,
    cordCount = 2,
    cordRadius = 0.7,
    cordGap = 0.3,
    minimumClearance = 0.2
);
```

Generator `+i` makes the strand entering lane `i` cross over lane `i+1`; `-i` reverses the
height relationship. The standard circular closure traces the final lane permutation into one
or more independently closed components. A two-lane word `[1,1]` produces a Hopf link, while
`[1,1,1]` produces a trefoil. Self-crossings use an additive branch field without changing the
established leading crossing-record fields.

![LogoSC circular braid closures](images/knot-braid-gallery.png)

Choose `BraidGallery` for the Hopf, trefoil, and three-lane presentation scene. Choose
`BraidBundleGallery` to see those crossing-aware routes expanded into multiple manufacturing
cords.

![LogoSC crossing-aware braided cord bundles](images/knot-braided-bundle-gallery.png)

A braid and a bundle are different layers: braids exchange physical strands through logical
lanes and determine topology, while bundles place parallel manufacturing cords around an
already-defined master route. The new gallery demonstrates their composition. See the User
Manual's **Braid versus bundle** comparison for the details.

### Generate a Celtic tile grid

The first traditional interlace generator compiles an explicit rectangular grid from three
four-port tiles:

```scad
celtic = MakeCelticTileGridKnot([
    ">X<",
    "X>X",
    "<X>"
]);

ReportKnotValidation(celtic, strict = true);
RenderKnotCords(celtic, cordRadius = 0.7);
```

`"X"` connects north-to-south and east-to-west with a crossing. `">"` and `"<"` provide the
two complementary corner pairings. Interior ports connect to the matching neighbor;
the finite grid closes its perimeter ports in deterministic clockwise pairs. Routes are traced
into independently closed components, duplicate reverse traces are removed, crossing height is
assigned by checkerboard parity, and non-alternating results are rejected.

![LogoSC Celtic tile-grid knots](images/knot-celtic-grid-gallery.png)

Choose `CelticGallery` for one-, two-, and larger-grid examples. This stage emits sampled knot
records and rounded cords.

### Render planar knot ribbons

Project a knot before compiling its sampled segments into LogoSC regions:

```scad
planarCeltic = KnotForView(celtic, "Planar");

RenderKnotRibbons2D(
    planarCeltic,
    ribbonWidth = 2.4,
    crossingClearance = 0.7,
    arcFragments = 10
);
```

`KnotRibbonRegions()` converts every sampled segment into a closed rounded capsule
`MakeRegion()`. Crossing masks are expanded capsules aligned with the recorded over branch.
The renderer subtracts those masks from the continuous ribbon union, then restores normal-width
overpass regions. Every region reaches OpenSCAD through LogoSC Core's `RenderRegion2D()`; native
OpenSCAD performs only the final union and difference.

![LogoSC planar knot ribbons and underpass masks](images/knot-ribbon-gallery.png)

Choose `RibbonGallery` to compare an unmasked continuous ribbon, the same grid with visible
underpass gaps, and a larger 4-by-4 interlace. Ribbon compilation deliberately requires a planar
knot copy and remains a specialized knot API rather than a general Core stroke renderer.

### Render printable knot bas-relief

The corrected ribbon footprint can be extruded directly:

```scad
RenderKnotBasRelief(
    planarCeltic,
    ribbonWidth = 2.4,
    crossingClearance = 0.7,
    baseHeight = 1.2,
    overpassHeight = 1,
    arcFragments = 10
);
```

The masked ribbon forms the continuous base layer. Every recorded overpass is then extruded from
`baseHeight` to `baseHeight + overpassHeight`. Restored overpass footprints extend beyond their
subtraction masks and overlap the source ribbon, eliminating the isolated oval-tab appearance
while retaining side clearance above the underpassing ribbon.

![LogoSC printable knot bas-relief](images/knot-bas-relief-gallery.png)

Choose `ReliefGallery` to compare low relief, normally raised crossings, and a 4-by-4 example.

## Current public API

The main user-facing renderer is:

```scad
RenderLogo2D(cmds, convexity = 10);
```

Advanced helpers include:

```scad
RenderLogoDebug(cmds, ...);
evalLogo(cmds);
ResultContours(result);
ResultState(result);
LogoStateToAffine(state);
LogoAffineToState(matrix, headingReference = undef);
RenderContours2D(regions, convexity = 10);
RenderRegion2D(region, convexity = 10);
```

Optional path-analysis helpers in `LogoSC-Foundation-Validation.scad` include:

```scad
evalLogoPaths(cmds);
ValidateLogoPaths(cmds, ..., checkSelfIntersections = true, checkHoleTopology = true);
ReportLogoValidation(cmds, ..., checkSelfIntersections = true, checkHoleTopology = true);
ValidationPaths(result);
ValidationIssues(result);
ValidationTinyEdgeThreshold(result);
ValidationChecksSelfIntersections(result);
ValidationChecksHoleTopology(result);
ValidationIsValid(result);
LogoContourIsConvex(points, tolerance = 0.001, strict = false);
LogoPathIsConvex(path, tolerance = 0.001, strict = false);
LogoRegionIsConvex(region, tolerance = 0.001, strict = false);
LogoRegionsAreIndividuallyConvex(regions, tolerance = 0.001, strict = false);
```

The current public API version is `2026.4`.

## Command examples

```scad
[MOVE,        len]
[TURN,        deltaHeading]
[DIR,         absoluteHeading]
[SCALE,       uniform]
[SCALE,       scaleX, scaleY]
[GOTO,        x, y, heading]
[ARC,         radius, degrees]
[CIRCLE,      radius]
[RECT,        width, height]
[ROUNDEDRECT, width, height, radius]
[REGPOLY,     sides, radius]
[HOLE,        cmds]
[RUN,         cmds]
[REPEAT,      count, cmds]
[PUSH]
[POP]
[PENUP]
[PENDOWN]
```

See `LogoSC-CheatSheet.md` and `LogoSC-User-Manual.md` for the complete command reference.

## Repository files

- `AGENTS.md` — compact repository-specific guidance for Codex and other coding agents.
- `LogoSC-Foundation-Core.scad` — standalone core interpreter, 2D renderer, and debug renderer.
- `LogoSC-Foundation-Validation.scad` — optional explicit-path evaluator and validator.
- `LogoSC-Foundation-Tests.scad` — passive regression and failure-test definitions.
- `LogoSC-Foundation-Validation-Tests.scad` — passive focused validation tests.
- `LogoSC-Foundation-Test-Runner.scad` — direct entry point for the complete test suite.
- `LogoSC-OpenSCAD-Command-Line.md` — command-line testing, export, and PNG-preview guide.
- `LogoSC-Examples.scad` — runnable gallery and example models.
- `LogoSC-Nuts-And-Bolts.scad` — customizable printable fastener and thread-profile model.
- `LogoSC-Nuts-And-Bolts-Tests.scad` — passive non-rendering fastener calculation tests.
- `LogoSC-Nuts-And-Bolts-Test-Runner.scad` — direct entry point for the fastener test suite.
- `LogoSC-Knots.scad` — optional knot records, torus/braid generators, cords, and bundles.
- `LogoSC-Knots-Examples.scad` — knot diagnostics plus cord, bundle, and braid galleries.
- `LogoSC-Knots-Tests.scad` — passive knot record, generator, cord, bundle, and braid tests.
- `LogoSC-Knots-Test-Runner.scad` — direct entry point for the knot companion suite.
- `LogoSC-Nuts-And-Bolts-Customizer.md` — detailed fastener parameter and calibration guide.
- `LogoSC-User-Manual.md` — practical user documentation.
- `CONTRIBUTING.md` — contribution philosophy, coding, testing, documentation, versioning, and packaging guidance.
- `LogoSC-Developer-Notebook.md` — engineering history, design rationale, workflow, and ChatGPT restart guide.
- `LogoSC-Future-Ideas.md` — longer-term feature concepts and possible future directions.
- `LogoSC-CheatSheet.md` — compact command/API reference.
- `LogoSC-README.md` — detailed project overview and roadmap.
- `LogoSC-ARC-Implementation.md` — arc tessellation design notes.
- `LogoSC-Holes-Implementation.md` — region and hole design notes.
- `LogoSC-Validation-Implementation.md` — validation algorithms, policies, complexity, and test matrix.
- `LogoSC-Transforms-Design.md` — preliminary local-transform design direction and open questions.
- `LogoSC-LSystems-Notes.md` — L-system design/example notes.
- `LogoSC-Knots-Design.md` — generative-knot algorithms, topology, rendering, verification,
  and implementation roadmap.
- `CHANGELOG.md` — release history.
- `docs/ai-engineering-kit/` — maintainer-facing Codex/Git quick start plus AI handoff,
  bootstrap, collaboration, engineering-preference, and retrospective documents.

## Design philosophy

LogoSC keeps the core narrow:

- LogoSC generates 2D regions.
- OpenSCAD handles 3D composition.
- Command lists should stay readable and reusable.
- Relative movement is preferred inside reusable shapes.
- Color and material choices stay outside the LogoSC geometry core.

## Current status

LogoSC currently focuses on filled 2D region rendering for final geometry. It also includes
a preview-only debug renderer and an optional validator that detects basic path defects, proper
self-intersections, invalid hole containment, and overlapping holes. The companion exposes
reusable segment, contour, containment, and region-relation helpers without adding them to Core.
Manufacturable stroke/open-path rendering remains future work. The optional knot companion
separately provides manufacturable rounded 3D cords for sampled knot routes; it does not change
LogoSC Core's filled-region contract.

## Version history

| Version | Highlights |
| --- | --- |
| 2026.4 | Topology/hole validation, convexity queries, expanded tests, and transform design notes |
| 2026.3 | Printable fastener application plus duplicate-point, tiny-edge, and proper self-intersection validation |
| 2026.2.1 | Optional path validation, automated suite aggregation, galleries, and command-line verification |
| 2026.2 | LogoSC identity, `RenderLogoDebug()`, unified run mode, licensing, branding, and documentation refresh |
| 2026.0 | Initial public foundation and filled-region geometry API |

## Near-term roadmap

- Expand optional validation only when additional topology policies provide clear value.
- Continue the optional knot companion with relief backing plates and export-oriented presets.
- Keep manufacturable stroke rendering as a separate API with explicit width, cap, and join semantics.

## Requirements

- OpenSCAD
- No external OpenSCAD library dependency; basic LogoSC use requires only
  `LogoSC-Foundation-Core.scad`.
- Optional validation additionally requires `LogoSC-Foundation-Validation.scad`.
- Optional knot generation additionally requires `LogoSC-Knots.scad`; its ribbon renderer uses
  the stable Core region API without changing Core.

Maintainers can use [LogoSC-OpenSCAD-Command-Line.md](LogoSC-OpenSCAD-Command-Line.md)
to run tests, capture diagnostics, and export geometry or PNG previews without opening the GUI.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) before preparing a contribution. It summarizes
the project's API-stability expectations, coding style, documentation and testing
responsibilities, versioning policy, direct-Git delivery, and fallback ZIP workflow.

Significant design decisions and historical rationale belong in
`LogoSC-Developer-Notebook.md`; longer-term concepts belong in
`LogoSC-Future-Ideas.md`.

The companion AI Engineering Kit begins with
[AI-Engineering-Kit-Handoff.md](docs/ai-engineering-kit/AI-Engineering-Kit-Handoff.md).
It guides collaboration but does not override LogoSC-specific repository decisions.

## License

LogoSC is licensed under the MIT License. See [LICENSE](LICENSE).
