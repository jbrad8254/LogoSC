# LogoSC Changelog

## Table of Contents

- [[Unreleased]](#unreleased)
- [[2026.7] - 2026-07-31](#20267---2026-07-31)
- [[2026.6] - 2026-07-31](#20266---2026-07-31)
- [[2026.5] - 2026-07-29](#20265---2026-07-29)
- [[2026.4] - 2026-07-27](#20264---2026-07-27)
- [[2026.3] - 2026-07-22](#20263---2026-07-22)
- [[2026.2.1] - 2026-07-21](#202621---2026-07-21)
- [[2026.2] - 2026-07-13](#20262---2026-07-13)
- [[2026.0] - Initial public foundation](#20260---initial-public-foundation)
- [Index](#index)

## [Unreleased]

### Documentation

- Added a planned C++20/CMake knot-compiler milestone with compatible generated `.scad` records,
  pre-resolved SVG ribbons for accelerated OpenSCAD import and extrusion, optional later STL/3MF
  output, fixture parity checks, and a 128-by-32 `LogoSC` benchmark target.
- Added a persistent OpenSCAD community-submission guide with researched official venues, staged
  outreach, release prerequisites, AI provenance language, ready-to-adapt announcements, and a
  possible official Libraries-page request.
- Added linked tables of contents to Markdown documents over two estimated pages and
  alphabetical subject indexes to documents over ten estimated pages. Repository guidance now
  defines one estimated Markdown page as 500 words and requires this navigation to remain current.
- Cleaned up the live roadmap after Mini packaging and affine commands were completed. The active
  sequence is now the optional L-system companion, completion or explicit deferral of the
  remaining knot roadmap, and then synchronized release preparation.

### Added

- Extended `logosc-knot-grid` into an indexed Celtic topology compiler that emits compatible
  sampled `.scad` knot records and pre-resolved closed-polygon SVG ribbons. Added the printable
  `FastSvgPlaque` scene, permanent C++/OpenSCAD parity test, manufacturing export check, and
  separated compiler, preview, CSG, and STL benchmarks.
- Added the dependency-free C++20 `logosc-knot-grid` command-line preprocessor with exact output
  sizing, a built-in 5-by-7 font, optional BDF fonts, pixel or connected-stroke scaling,
  configurable spacing, margins, and tile patterns, plain ASCII grid validation and
  normalization, CRLF/CR/LF selection, deterministic
  hashes and statistics, delayed progress dots, CMake tests, and generated OpenSCAD adapters.
- Added a committed 128-by-32 `LogoSC` ASCII grid and adapter plus the large-Celtic
  `GeneratedPlaque **` scene, which compiles the generated input into a printable plaque.
- Added measured performance-warning suffixes to the knot and large-Celtic Customizers, with
  documented RAINBOW timing results and thresholds.
- Added `LOGOSC128 ***`, a batch-only 128-by-32 Celtic LogoSC word using native 18-by-24 glyphs,
  with 4,118 cord segments, a generated preview, and an approximately three-minute RAINBOW Cord
  benchmark for later C++/SVG acceleration comparisons.
- Restored the 16-crossing RosetteGallery route from an obsolete experimental 480 samples to 160,
  preserving the corrected crossings while reducing recursive stack and GUI geometry pressure;
  verified CSG, preview PNG, and full CGAL rendering.
- Fixed zero-crossing ribbon and bas-relief rendering on OpenSCAD 2021.01 by replacing deprecated
  `[0 : -1]` crossing loops with an explicit empty-index helper, as identified by the supplied
  source-level assertion trace.
- Made RosetteGallery sampling and ribbon fragments truly presentation-fixed, preventing saved
  low-quality individual settings from reducing it to partial, crossing-free, or stale geometry.
- Clarified the knot Customizer by placing `PolarRosette Individual` next to
  `RosetteGallery *` and echoing displayed and canonical scene selections during compilation;
  canonicalization accepts OpenSCAD's parenthesis-stripped Customizer values.
- Removed the hidden benchmark scene override that could retain a stale index and make every
  visible knot-scene choice render the same individual plaque; benchmarks now override the
  visible `KnotExample` selector directly.
- Replaced the default planar-knot crossing composition with an event-local traversal renderer:
  only under-branch sample capsules are clipped, cut length follows the crossing angle and ribbon
  widths, and the original over curve remains untouched. The prior renderer remains available as
  `crossingMethod = "legacy-mask"`; polar rosette symmetry is recorded as a future one-sector
  rotation optimization.
- Added `MakePolarRosetteKnot()` with two phase-controlled radial harmonics, integer angular
  winding, proper crossing discovery, alternating assignment, focused tests, an individual
  example, and a generated three-medallion ribbon gallery. A restrained secondary harmonic and
  event-local underpass traversal keep the medallion ribbons smooth through crossings.
- Added `SolveKnotAlternatingParity()` and `AssignKnotAlternatingCrossings()` with deterministic
  multi-strand parity coloring, closed-traversal constraints, and contradiction detection.
- Added `MakeHarmonicKnot()` for closed multi-term planar harmonic curves with automatic proper
  crossing discovery and alternating assignment, plus focused tests and a selectable example.
- Added `MakeLissajousKnot()` with closed three-axis harmonic sampling, proper projected
  self-crossing discovery, interpolated route parameters, Z-derived over/under branches,
  focused tests, a selectable example supporting every existing knot output mode, and a
  three-route Lissajous gallery with a generated documentation image.
- Added focused contracts for seeded angle-jitter reproducibility and path-distance restoration
  across `POP`, bringing the L-system suite to 25 passing tests.
- Exported all nine L-system presets at their gallery defaults and verified that every STL has one
  connected component with no boundary edges, non-manifold edges, or repeated-vertex facets.
- Added seeded per-turn angle variation to the L-system examples, defaulting to plus-or-minus 10
  degrees for Plant and Canopy, with Customizer scopes for Off, Branching Only, or All Open Curves.
- Documented reproducible angle jitter, why closed examples remain exact, and how future seeded
  length variation would affect geometry and printability.
- Added an OpenSCAD-rendered image of the nine-model L-system gallery and embedded it in the
  public L-systems guide.
- Expanded the L-systems guide with an annotated Quick Start constructor, explicit preset-name
  versus constructor selection, and a worked depth-zero/depth-one Koch rewrite and interpretation.
- Simplified the built-in-system table by moving direct constructors into a documented naming
  convention and showing the exact ASCII `Levy C` preset string with `MakeLevyCLSystem()`.
- Added a compact L-system symbol legend and labeled every preset angle explicitly as the relative
  turn used by `+` and `-`, including accumulated turns, drawing, movement, branching, and variables.
- Added historical context on formal languages, turtle graphics, fractals, and plant modeling,
  plus a modern-AI note explaining hybrid uses in grammar inference and neurally guided generation.
- Added deterministic Lévy C, Gosper, and symmetric canopy presets and expanded the L-system
  example gallery from six models to a centered 3-by-3 grid of nine.
- Changed the Lévy C preset's axiom from one segment to a four-sided square frame, applying the
  folding rule along every side for a denser, space-filling gallery silhouette.

- Added the optional `LogoSC-LSystems.scad` companion with generic integer-symbol rewriting,
  action-based LogoSC interpretation, six named presets, a Customizer gallery, an independent
  deterministic test runner, and focused design and user documentation. Distribution packaging
  remains deliberately deferred.
- Added `[SHEAR, xFactor]` as a backward-compatible opcode for composing a local X shear. The
  normal evaluator, debug evaluator, tracing, state stack, affine conversion, tests, cheat sheet,
  and user manual share the same transform semantics.
- Added `LogoSC-Mini-Cover-Models.scad`, providing printable, Customizer-selectable LogoSC
  interpretations of all eight figures in the AI-generated Mini Thingiverse cover, including an
  `All` option that arranges the complete set on one build plate.
- Added `LogoSC-Core-Cover-Models.scad`, providing printable interpretations of all eight figures
  in the AI-generated Core cover, with individual and complete-set Customizer output.
  The set includes a scalloped-cutout feature panel, connected radial fan, Koch-cutout plate,
  thickened Peano curve, tapered astroid sculpture with a centered through-opening, slotted link,
  perforated ring, and curvy `rotate_extrude()` wire spool. Every model rests at `Z=0`.

### Changed

- Changed the LogoSC wordmark to keep `Logo` upright and apply an explicit `[SHEAR, 0.25]` to the
  complete multi-region `SC` suffix. Regenerated `images/logosc-wordmark.png` from the selected
  OpenSCAD geometry with the established oblique 3D presentation, and refreshed
  `images/examples-gallery.png` so its masthead and expanded gallery match the current source.

### Fixed

- Increased the printable L-system plant trunk from two to four times the base stroke width and
  changed its stroke to a continuous taper, preventing
  upper continuation and terminal segments from returning to trunk-like thickness.
- Revised the Plant preset into three recursive asymmetric Y-shaped levels, with a slightly
  longer 40-degree right branch and a shorter 30-degree left branch at every fork.
- Halved the Plant preset's recursive trunk-section length so the completed model remains close
  in scale to the other L-system examples.
- Made the Plant crown fuller by changing its net successive branch-length ratio from one half to
  three quarters and displaying four recursive levels (16 terminal tips), while retaining the
  tighter 20- and 30-degree fork angles.
- Halved the straight trunk section preceding every recursive Plant fork from two base steps to
  one, making the crown more compact without changing its branch proportions.
- Halved both Plant Y-arm lead-ins to one and one-and-a-half base steps, preserving their slight
  asymmetry while making the recursive crown less spindly.
- Increased the Plant's starting trunk width from four to ten times the base stroke width, with
  the continuous taper still reaching the original width at the highest tips.
- Halved the Plant's original trunk and first-level branch lengths to reduce its gallery footprint
  without reducing any of its printable stroke widths.
- Increased the L-system gallery's Hilbert curve from depth two to depth four so its space-filling
  structure is more apparent.
- Increased the gallery Dragon curve by two requested levels, raising its effective rendered
  depth from six to eight.
- Corrected open-curve gallery centering to use the actual rendered stroke bounds and removed a
  duplicate Dragon depth adjustment that centered depth-eight geometry using depth-ten bounds.
- Reduced the Plant's movement geometry by 30 percent in both planar dimensions while preserving
  its absolute printable stroke widths.
- Corrected the Plant taper to use accumulated root-to-segment path distance rather than absolute
  Y position, so sideways and downward terminal branches no longer remain artificially thick.

- Enlarged the filled Sierpiński example's smallest triangles by approximately 10% so adjacent
  regions overlap instead of meeting only at non-printable point contacts.
- Increased the printable Hilbert and Dragon example strokes by 50%. Gave the plant a double-width
  trunk and reduced each of its three displayed growth levels by `pow(1/2, 1/3)`, returning its
  terminal branches to the original base width.

## [2026.7] - 2026-07-31

This feature and publishing release adds irregular Celtic regions, large scalable Celtic
showcases and plaques, and the first synchronized Mini, Core, Developer, Knots & Celtic, and
Nuts & Bolts publication system. The Core public API version advances to `2026.7`; established
command syntax, opcode values, geometry behavior, and public APIs remain backward compatible.

### Added

- Added the first complete multi-suite publishing system under `publishing/`: exact Mini, Core,
  Developer, Knots & Celtic, and Nuts & Bolts manifests; tailored package documentation; five
  Thingiverse descriptions and generated covers; portable ZIP creation; source/version records;
  inventories; dependency and image checks; staged OpenSCAD verification; hashes; and JSON reports.
- Added standalone `LogoSC-Mini-Examples.scad` and `LogoSC-Core-Examples.scad` so the smaller
  publications have focused Customizer entry points without accidentally depending on validation
  or passive test files.
- Added a concise development-provenance disclosure to the shared Suite Guide and the detailed
  `LogoSC-Development-Provenance.md` for Developer and repository readers. The documents credit
  substantial AI contributions while recording human direction, evidence-based verification,
  limitations, contribution expectations, and the repository as the complete historical record.
- Added `LogoSC-Release-Manual.md` to define one authoritative development and bug-fix
  repository, synchronized Mini/Core/Developer/Knots/Fasteners publications, a shared illustrated
  Suite Guide, package-specific documentation boundaries, independent staged verification, and
  GitHub/Thingiverse release workflow. AI workflow material remains exclusive to the complete
  repository rather than the Developer package.
- Added `LogoSC-Suite-Guide.md` as the shared public introduction packaged with every suite. It
  compares all five publications, explains their compatibility and common repository, and uses
  every current LogoSC-produced PNG to illustrate Mini, Core, Developer, knot/Celtic, and fastener
  capabilities.
- Added `"."` as the canonical blank Celtic grid cell. Rectangular string storage can now
  describe irregular occupied regions, internal holes, diagonal contacts, and disconnected
  islands. Exposed occupied edges are traced into independent deterministic boundary loops,
  paired without creating open strands, and covered by three focused results bringing the knot
  suite to 88.
- Added `LogoSC-Celtic-Large-Grids.scad` and its guide with selectable 8-, 16-, 24-, and
  32-cell diamond/ring masks, Topology/Cord/Ribbon/Plaque output, measured scaling data, and a 37-by-9
  blank-cell mask spelling CELTIC. Advanced cycle scanning now resumes after the prior visited
  state, reducing the 24-by-24 diamond calculation from about 94 seconds to about 18 seconds on
  the development machine. The showcase prints an early scene/output-specific duration estimate;
  plaque geometry and colors are configurable through the Customizer.

## [2026.6] - 2026-07-31

This focused feature release completes controlled knot-bundle twisting and clarifies the knot
Customizer's control scopes. The Core public API version advances to `2026.6`; Core geometry
and all established public APIs remain backward compatible.

### Added

- Added controlled integer half-turns to `MakeKnotBundle()` and
  `RenderKnotCordBundle()`. Even half-turn counts return every lane to itself; odd counts reverse
  lane order and trace the resulting closure-permutation cycles into genuinely closed cord
  components, including the self-closing center lane of odd bundles.
- Remapped recorded braid crossings and normalized parameters through twisted bundle components,
  added four deterministic twist and Möbius-like closure results bringing the knot suite to 85,
  and added a Customizer control plus an untwisted/half-twist/full-twist gallery.

### Changed

- Reorganized the knot Customizer's opening controls into Scene Selection, Individual Output,
  Route View, and Gallery Presentation sections. Gallery scenes now visibly identify
  `KnotOutput` as irrelevant, while the route-view heading names the outputs and galleries it
  controls.
- Individual Ribbon, Relief, and Plaque output now always projects its source route to Planar,
  because those renderers require 2D regions. This prevents an irrelevant Spatial selection from
  producing a planarity assertion.

## [2026.5] - 2026-07-29

This feature release adds complete backward-compatible affine turtle transforms and the first
full optional knot companion. LogoSC Core now carries readable six-field affine state through
movement, curves, primitives, repetition, holes, stacks, validation, and debug rendering. The
knot companion adds torus knots, circular braids, Celtic tile grids, round cords, multi-cord
bundles, LogoSC-backed planar ribbons, printable bas-relief plaques, beveled backing plates, and
coordinated export-quality presets. The Core public API version advances to `2026.5`; specialized
knot topology and native 3D manufacturing geometry remain outside Core.

### Added

- Added the first optional knot-companion vertical slice in `LogoSC-Knots.scad`: extensible knot,
  strand, crossing, validation-result, and issue records; structural validation and diagnostic
  reporting; preview centerline, sample, and crossing rendering; and a torus-knot/link generator
  with `gcd(p,q)` independently closed components.
- Added selectable Planar and Spatial knot debug views. Planar mode projects centerline and
  sample diagnostics to `z = 0` without changing the stored 3D knot route.
- Added a separate 81-result knot test suite and runner covering record accessors, valid and
  invalid structures, closure, crossings, encounter indexes, lane permutations, torus sample
  counts, exact closure, distinct link components, generated-result validation, and cord-segment
  and bundle accounting, plus signed braid topology, ribbons, relief plaques, bevels, and
  print-quality presets.
- Added `LogoSC-Knots-Examples.scad`, documented topology, cord, bundle, braid, and braided-bundle
  presentation galleries, plus focused individual examples. Explicit twist and AI image import
  remain deferred.
- Added validated `RenderKnotCords()` manufacturing geometry, converting every adjacent sampled
  pair into a sphere-hulled capsule with explicit radius and fragment controls. Added segment
  accounting helpers and four focused tests.
- Added a labeled `CordGallery` presentation scene generated from actual unknot, trefoil, and
  Hopf-link cord geometry, including per-component link colors and a reproducible documentation
  PNG command.
- Added adjacent multi-cord bundle expansion and `RenderKnotCordBundle()`, with explicit or
  width-fitted cord radius, symmetric lane offsets, stable transported 3D frames, exact closed
  seams, and per-master link expansion. Later crossing-aware expansion preserves recorded
  crossing ownership and clearance.
- Added ten focused bundle results covering vector math, width fitting, lane symmetry, straight
  and curved frames, strand/sample expansion, preserved center routes, lane separation, closure,
  validation, and multi-component links, bringing the independent knot suite to 38 results.
- Added a labeled two-, three-, and four-cord `BundleGallery` generated from real expanded
  trefoil routes, plus a reproducible documentation image.
- Fixed `KnotView` so Planar and Spatial apply to cord output, bundle output, and presentation
  galleries rather than only diagnostic rendering. Planar projection now occurs
  before bundle expansion, and Planar galleries no longer retain the fixed spatial tilt.
- Added `MakeCircularBraidKnot()` with signed adjacent generators, deterministic lane-state
  evolution, cosine exchanges, signed Z bumps, standard circular closure, permutation-cycle
  component tracing, normalized crossings, and encounter indexes.
- Extended crossing records additively with branch-level over/under ownership so self-crossings
  can identify branch A or B without changing the established first six fields.
- Added 13 crossing/braid results covering branch validation, word validation, swaps, states,
  closure permutations and cycles, blends, trefoil and Hopf closure, sample counts, self-crossing
  parameters, signed height, encounters, three-lane closure, and generated validation.
- Added a labeled `BraidGallery` with Hopf, trefoil, and three-lane circular closures plus a
  reproducible documentation image.
- Added crossing-aware bundle expansion. Every recorded master crossing now expands to all
  `N*N` cord-lane pairs with preserved parameters and over-branch ownership, rebuilt encounter
  indexes, inherited collective Z lift, and enforced minimum surface-clearance analysis.
- Added four focused results for crossing remapping, encounter reconstruction, interpolation,
  and passing/failing clearance configurations, bringing the independent knot suite to 55.
- Added `BraidBundleGallery` with two-cord Hopf, trefoil, and three-lane braid compositions plus
  a reproducible documentation image.
- Added `MakeCelticTileGridKnot()` with the three explicit four-port tiles `"X"`, `">"`, and
  `"<"`; rectangular validation; matching interior ports; deterministic clockwise
  perimeter pairing; cycle tracing; reverse-route elimination; exact closure; quadratic corner
  sampling; checkerboard crossing lifts; normalized crossing records; and cyclic alternation
  enforcement.
- Added ten Celtic-grid results covering tile pairings, malformed grids, boundary enumeration,
  trace de-duplication, components, samples, closure, crossing height, encounters, alternation,
  and metadata, bringing the knot suite to 65.
- Added a Spatial/Planar `CelticGallery` generated from real one-, two-, and larger-grid knot
  records, plus a reproducible documentation image.
- Added the first LogoSC-backed knot renderer: `KnotRibbonRegions()` compiles every planar
  sampled segment into a rounded Core `MakeRegion()` capsule, while crossing helpers create
  expanded underpass masks and normal-width overpass footprints.
- Added `RenderKnotRibbons2D()`, which renders every footprint through Core's
  `RenderRegion2D()`, subtracts crossing masks from the continuous ribbon union, and restores
  the recorded over branches with native OpenSCAD Boolean composition.
- Added seven ribbon results covering planar enforcement, capsule contours, Core region records,
  segment accounting, crossing masks, branch accessors, normalized tangents, and no-crossing
  behavior, bringing the knot suite to 72.
- Changed the canonical Celtic corner-tile vocabulary from `"NE_SW"` and `"NW_ES"` to the
  one-character ASCII symbols `">"` and `"<"`. Grids can now use compact string rows such as
  `">X<"`. Original and intermediate spellings remain compatibility aliases, while generated
  metadata is canonicalized.
- Extended restored ribbon overpasses beyond their expanded crossing masks so they overlap the
  source ribbon seamlessly, removing isolated capsule-shaped end halos while preserving side
  clearance.
- Added `RenderKnotBasRelief()` with independently controlled base and overpass heights, plus
  `KnotBasReliefTotalHeight()`, `Relief` Customizer output, and a low/raised/4-by-4
  `ReliefGallery`. Raised layers include a tiny internal base overlap while preserving external
  height, avoiding reliance on exactly coplanar shell contact.
- Added two focused results for overpass-to-mask span overlap and bas-relief height accounting,
  bringing the knot suite to 74.
- Added `RenderKnotBasReliefPlaque()` with automatic sample-derived bounds, ribbon-edge margin,
  rounded corners, exact height accounting, and a hidden plate-to-relief overlap that joins
  multi-component knots into one printable object.
- Added `KnotPlanarBounds()`, `KnotReliefPlaqueBounds()`, and
  `KnotReliefPlaqueTotalHeight()`, plus two focused plaque results bringing the knot suite to 76.
- Added `Plaque` Customizer output and a `PlaqueGallery` showing compact, rounded, and 4-by-4
  printable relief plaques.
- Added optional independent plaque and raised-knot preview colors, with contrasting Customizer
  defaults. Color remains presentation metadata and does not affect printable STL geometry.
- Replaced crossing-local capsule masks and restored capsule overpasses with flat-ended oriented
  bands. The shorter mask remains inside the crossing segment, while the longer restored band
  overlaps the source ribbon, removing curved-junction gaps and visible rounded top caps.
- Added a focused flat-end contour result, bringing the knot suite to 77, and regenerated the
  ribbon, bas-relief, and relief-plaque galleries.
- Added optional `"None"` and `"Bevel"` backing-plate edge styles with independently controlled
  bevel width and height. The top-edge bevel preserves the automatic outer footprint, exact
  plate thickness, rounded-corner progression, and sufficient top margin around the ribbon.
- Added two deterministic bevel-bound and corner-radius results, bringing the knot suite to 79,
  plus Customizer controls and a straight-versus-beveled plaque-gallery comparison.
- Added `Draft`, `Standard`, `Fine`, and `Custom` knot print-quality presets coordinating route
  sampling, cord fragments, and ribbon arc fragments across individual examples and galleries.
  Standard preserves established values, while Custom retains explicit control.
- Added two deterministic preset-resolution results, bringing the knot suite to 81, and
  documented expected preview-speed, curve-smoothness, and export-size tradeoffs.
- Added `Ribbon` Customizer output and a `RibbonGallery` comparing continuous regions,
  underpass-mask interlace, and a 4-by-4 Celtic ribbon grid.
- Added a side-by-side User Manual comparison clarifying that braids generate crossing topology
  by exchanging strand ownership across logical lanes, while bundles generate parallel
  manufacturing geometry around an existing master route.
- Documented the knot companion's dependency flow: generators, validation, diagnostics, and
  cords do not invoke LogoSC evaluation; planar ribbons use Core region records and
  `RenderRegion2D()`; and native OpenSCAD performs final Booleans and 3D geometry.
- Added `LogoSC-Knots-Design.md`, an implementation roadmap covering a shared strand/crossing
  representation; torus, braid-word, Celtic-grid, harmonic/Lissajous, polar, and medial-graph
  generators; alternating crossing constraints; 2D ribbons; bas-relief; rounded capsule cords;
  verification; and staged companion-library delivery.
- Documented adjacent multi-cord bundles as a required knot feature, including width/gap fitting,
  symmetric lane expansion, synchronized crossing lifts, bundle-envelope clearance, and stable
  3D frames. Explicit twist and Möbius-like lane-closure permutations remain deferred.

- Added an AI-assisted figurative-knot import concept to the knot roadmap, using semantic
  regions and vector guide data as a validated interchange rather than unchecked generated
  LogoSC commands. Added reusable knot and zoomorphic-interlace references, their licensing
  records, an overview of traditional grid, break, route, ribbon, and crossing construction,
  and a reading list covering hand construction, algorithmic generation, example archives,
  contemporary generators, practical tutorials, and artist galleries.

- Added persistent canonical affine state
  `[x, y, heading, scaleX, scaleY, shear]`, preserving the historical first
  four indices and `SS` compatibility alias while adding `SSX`, `SSY`, and
  `SSH`.
- Extended `SCALE` with `[SCALE, scaleX, scaleY]`; negative factors provide
  reflection, while singular zero factors are rejected.
- Applied the complete local transform to `MOVE`, `ARC`, closed primitives,
  `RUN`, `REPEAT`, `HOLE`, `PUSH`/`POP`, and preview debug geometry. Automatic
  curve tessellation now accounts for maximum affine stretch.
- Added affine contract tests for generated shear, transformed coordinates,
  loop persistence, reflections, world-absolute `DIR`/`GOTO`, stack restoration,
  arcs, primitives, `RUN`, holes, and debug-evaluator parity.
- Added Core `LogoStateToAffine()` and `LogoAffineToState()` interoperability
  helpers using a documented standard 2x3 column-vector matrix convention,
  deterministic reflection canonicalization, optional heading-reference
  recovery, and malformed/singular input rejection.
- Added a six-cell affine-transform gallery row with documented ellipse, sheared
  rectangle, persistent-turn snowflake, reflected butterfly, transformed arc
  capsule, and recursively scaled/turned tree examples.
- Moved the LogoSC feature wordmark to a centered gallery masthead and gave both
  O glyphs a right-leaning generated-shear italic treatment using `SCALE`,
  `TURN`, and world-absolute `DIR`.
- Compacted the gallery after moving the wordmark by shifting the L-system and
  transform rows downward, and enlarged the masthead by 50 percent.

## [2026.4] - 2026-07-27

This feature release adds general optional topology relationships, strict hole validation,
convexity queries, expanded deterministic tests, and the preliminary local-transform design
direction. The Core public API version advances to `2026.4`; Core evaluation and rendering
remain backward compatible and independent of the optional Validation companion.

### Added

- Added reusable optional-validation helpers for segment relationships, contour intersection
  pairs, point containment, region boundary intersections, and filled-region relationships.
- Added documented `LogoContourIsConvex()`, `LogoPathIsConvex()`, and
  `LogoRegionIsConvex()` public queries with winding-independent turn analysis, strict and
  non-strict collinearity modes, simplicity checks, and defined hole semantics. Added
  `LogoRegionsAreIndividuallyConvex()` for explicit all-members checks without misrepresenting
  that result as convexity of the polygons' union.
- Added default-on hole topology validation for holes outside or touching their outer contour
  and for overlapping, touching, coincident, or nested holes, with related-path diagnostics and
  a `checkHoleTopology` opt-out for trusted highly tessellated models.
- Added focused topology tests covering predicate classifications, containment, independent
  region relationships, hole ownership, invalid outer relationships, overlapping and nested
  holes, valid separated holes, and disabled behavior.
- Added nine focused convexity results covering winding, concavity, collinearity modes,
  self-intersection, backtracking, insufficient points, explicit-path closure, and regions with
  and without holes, plus three multiple-region results for all-convex, mixed-concavity, and
  hole-containing lists.
- Added `LogoSC-Validation-Implementation.md`, documenting explicit-path extraction, every
  integrity and topology algorithm, complexity boundaries, hole-ownership ordering, all 71
  Validation results by test group, fixture rationale, verification, and known limits.
- Added preliminary local-transform design notes covering persistent transforms through
  `REPEAT` and `RUN`, reuse of the existing `PUSH`/`POP` stack, `TURN` as the sole relative
  rotation operation, full-transform relative movement, a readable canonical affine-state
  candidate, compatibility constraints, and questions deferred to the implementation design
  review.
- Added a separate deterministic, non-rendering fastener test suite and runner covering all
  size presets, basic head/nut/drive dimensions, thread-profile construction, LogoSC command
  generation, contour resampling, handed wrapping, and multi-start phase offsets without adding
  the standalone fastener application to the Foundation/Validation acceptance dependency graph.
- Made the profile-segment and contour-resampling helpers accept an optional sampling-density
  argument, preserving the Customizer default while allowing deterministic checks of both the
  default and documented high-resolution algorithm-figure counts.
- Added a quick non-rendering parameter-test invocation to the fastener Customizer guide, with
  explicit scope limits and a link to the detailed command-line verification workflow.

### Fixed

- Corrected the complete internal test-helper naming family from `LogoSCest` to `LogoSCTest`,
  including the `RunAllLogoSCTests()` Foundation-suite runner.

## [2026.3] - 2026-07-22

This feature release adds a customizable printable-fastener application and substantially
expands optional contour validation. The Core public API version advances to `2026.3` while
retaining the established renderers, evaluator APIs, region helpers, and command opcodes.

### Fasteners and documentation

- Added `LogoSC-Nuts-And-Bolts.scad`, a Customizer-driven printable fastener model with metric,
  Unified, and custom sizes; six basic thread-profile families; right- and left-hand or
  multi-start helices; adjustable length and print slop; independent external head, drive type,
  and drive-size controls; nuts; assembled previews; and selected-profile output.
- Added `LogoSC-Nuts-And-Bolts-Customizer.md` with detailed parameter behavior, drive-preset
  dimensions, standards context, resolution guidance, and print-clearance calibration notes.
- Expanded the fastener presets through M36 and 1-8, increased preview resolution defaults and
  limits, added full-pitch profile reference geometry, tapered Phillips recesses, full-width
  slots, and two-sided boolean-cutter overrun tolerance.
- Added a four-by-two fastener gallery and `images/fastener-gallery.png`, moved headless drive
  recesses to the visible free end, tapered both ends of external threads, and made `TipChamfer`
  control the smaller nut entry chamfers as well as bolt chamfers.
- Added a prominent warning that printed fastener strength is unknown and that real-world use
  requires engineering review and representative destructive load testing.
- Expanded the warning with explicitly non-rated M8 and M12 tensile and single-shear estimates
  for printed PLA, PETG, and ABS versus property-class 8.8 steel, including the calculation
  assumptions, published material-data sources, and unmodeled failure modes.
- Expanded the fastener guide with exact explanations of each simplified thread profile, six
  profile images, six head-type images, and a 1600-by-1000 assembly image generated with four
  times the default geometry resolutions.
- Relabeled fastener gallery output as `Gallery (Slow!)` and documented measured preview versus
  full-CGAL timing so users can anticipate the cost of rendering eight threaded models.
- Added a tested PowerShell recipe to `LogoSC-OpenSCAD-Command-Line.md` showing how the
  four-times-resolution fastener assembly PNG is generated with Customizer overrides, camera
  framing, explicit pixel dimensions, and elapsed-time reporting.
- Documented the fastener thread algorithm, its main routines and variables, `nStarts`
  multi-start phase construction, the actual generated LogoSC command list, contour expansion,
  exact resampling counts, and profile/slice complexity. Added profile-command console
  diagnostics, a reproducible sampled `Algorithm Figure` output, exact echo/profile/figure
  commands, and `images/fastener-thread-wrapping-three-start.png` generated from the real polar
  seed and sample arrays.
- Kept the Core API surface unchanged: LogoSC supplies evaluated 2D profiles, while the new model
  uses native OpenSCAD twisted extrusion, cylinders, clipping, and boolean subtraction for 3D
  output.

### Validation

- Expanded the optional validation companion with duplicate-nonconsecutive-point and configurable
  tiny-edge detection, keeping the repeated closing point valid and allowing the tiny-edge check
  to be disabled. Added focused automated coverage and Quick Start setup documentation while
  retaining the companion boundary outside Core.
- Added optional proper self-intersection detection within each explicit path, diagnostic
  segment-index pairs, tolerance-aware orientation tests, bounding-box rejection, and a switch
  for disabling the quadratic scan on highly tessellated paths. Endpoint touches, collinear
  overlaps, separate-contour intersections, and implicit closing edges remain excluded.

### Testing

- Expanded the complete immutable Foundation and Validation suites to 166 passing results.
- Verified warning-free command-line CSG exports for Bolt, Nut, Assembly, Profile, and Algorithm
  modes, plus full CGAL STL exports for the default bolt and nut.

## [2026.2.1] - 2026-07-21

This documentation and verification release makes LogoSC easier to learn, test, and continue
developing. Start with the [repository overview](README.md) and
[User Manual](LogoSC-User-Manual.md); maintainers should also see the
[command-line verification guide](LogoSC-OpenSCAD-Command-Line.md),
[contributor guide](CONTRIBUTING.md), and [Developer Notebook](LogoSC-Developer-Notebook.md).

It also includes the optional validation companion and expanded automated-test infrastructure
described below. The LogoSC Core public API version remains `2026.2`.

### Added

- Added a four-column by two-row debug-renderer gallery that gives all eight debug
  examples distinct logical indexes and offsets.
- Added `DebugDemoLayout` with `Gallery` and `Selected` choices, retaining focused
  inspection through `DebugDemoExample`.
- Added `LogoSC-Foundation-Test-Runner.scad` as the direct regression-suite entry point.
- Added optional `LogoSC-Foundation-Validation.scad` path analysis without adding a Core
  dependency or changing filled-region rendering.
- Added `evalLogoPaths()`, `ValidateLogoPaths()`, `ReportLogoValidation()`, explicit path
  records, and public path/validation accessors.
- Added open-path, too-few-points, and zero-length-segment issue detection with configurable
  endpoint tolerance and warning or strict reporting.

### Changed

- Made `LogoSC-Foundation-Core.scad` a standalone one-file library with no test-file
  dependency.
- Changed `LogoSC-Foundation-Tests.scad` to provide passive test definitions invoked by
  the runner or the explicit `Tests` branch in `LogoSC-Examples.scad`.
- Changed automated checks from independent soft-error echoes to immutable named result
  records aggregated into Foundation and Validation suite results.

### Documentation and maintenance

- Added root `AGENTS.md` with compact repository-specific guidance for Codex.
- Added `docs/ai-engineering-kit/Codex-Git-Project-Quick-Start.md` as a short reusable guide
  to setting up and using a local Git repository as a Codex workspace.
- Added `CONTRIBUTING.md` and `LogoSC-Future-Ideas.md` after the `v2026.2` tag.
- Added `LogoSC-OpenSCAD-Command-Line.md` with tested PowerShell examples for regression
  diagnostics, geometry export, and PNG preview generation, plus official OpenSCAD references.
- Added the maintainer-facing AI Engineering Kit under `docs/ai-engineering-kit/` by
  explicit user request.
- Clarified that `RenderLogoDebug()` is a stable public diagnostic API while remaining
  preview-only and unsuitable for manufacturable stroke output.
- Updated the Developer Notebook's live checkpoint and roadmap to distinguish completed
  debug-renderer work from future contour-validation and stroke-rendering work.
- Corrected User Manual section numbering, recursion links, and repository inventory.
- Kept post-release documentation work separate from the contents of the `v2026.2` tag.
- Recorded that future contour validation belongs in an optional implementation companion
  with separate tests, assembled by the test runner rather than included from Core.
- Added `images/examples-gallery.png` showing basic shapes, holes, native linear and rotational
  extrusions, and recursive L-system-inspired examples.
- Added `images/regression-test-gallery.png` showing the color-coded visual regression suite,
  and referenced both galleries from the relevant public, testing, and submission docs.
- Added `images/debug-renderer-gallery.png` showing all eight indexed Debug cases and referenced
  it from the public overview, User Manual, command-line guide, and Build Week submission.
- Added `images/openscad-examples-run-guide.png` as an annotated OpenSCAD-window guide for the
  Build Week installation and visual-example instructions.
- Renamed the Build Week submission document from `BUILDWEEK.md` to
  `README_BUILDWEEK.md`.
- Changed routine AI delivery to use the active Git working tree when direct integration is
  verified, while preserving one exact-path ZIP as the fallback for Git-unavailable,
  attachment-based, temporary-copy, unverifiable, or explicitly requested delivery.

### Testing

- Added a non-rendering evaluator-invariant suite covering complete `EvalResult` state,
  raw region/ring structure, stack contents, pen state, scaled `RUN`, and `REPEAT` behavior.
- Kept the suite focused on current filled-region semantics while making it straightforward
  to extend as validation grows and open-path rendering is deliberately introduced.
- Added focused path-validation tests covering closure, tolerance, pen boundaries, primitives,
  holes, `RUN`, `REPEAT`, arcs, stack discontinuities, zero-length moves, and empty programs.
- Added per-suite and global pass/fail summaries that retain all failures, distinguish expected
  Core error diagnostics, and end with `LOGOSC_AUTOMATED_TEST_RESULT`.
- Added optional `LogoTestFailFast` diagnosis that asserts at the first failed immutable result
  with its test name and details while preserving aggregate reporting as the default; the
  Examples file exposes it in the `LogoSC Run` Customizer section.
- Added a final `*** Test Suite Failed ***` banner to failed aggregate reports for immediate
  human recognition without changing the structured automated-result record.
- Restored the empty-program validation expectation to zero paths while converting the check
  to an immutable test-result record.
- Suppressed duplicate expected-error echoes during repeated functional result-list traversal;
  the visual failure row still executes and displays each intended diagnostic once.

## [2026.2] - 2026-07-13

This release consolidates the accumulated LogoSC development work that had
previously been recorded as multiple `Unreleased` entries. Version `2026.1` was
an internal development snapshot and was not published as a separate release.

### Added

- Final LogoSC project identity, repository naming, and `LogoSCVersion*` public
  version symbols.
- `LogoSC-Developer-Notebook.md` as the living engineering history, design
  rationale, workflow, regression-risk, and restart document.
- Preview-only `RenderLogoDebug()` rendering with z-centered movement capsules
  and point markers.
- Debug event extraction for normal movement, pen-up movement, `GOTO`, primitive
  geometry, and start/end points.
- Debug examples for open and closed triangles, crossed/self-intersecting paths,
  rectangles, and stroke-versus-primitive construction.
- Unified `LogoSCRunMode` selector with `NoDemo`, `Examples`, `Debug`, and `Tests`.
- LogoSC wordmark and gear-icon images.
- README Quick Start screenshots for normal and debug triangle rendering.
- Root MIT `LICENSE` file.
- Public API version and compatibility helper:
  - `LogoSCVersionMajor`
  - `LogoSCVersionMinor`
  - `LogoSCVersion`
  - `LogoSCVersionAtLeast()`

### Changed

- Advanced the public API version from the unreleased `2026.1` development
  snapshot to `2026.2`.
- Preserved generic public APIs, including `RenderLogo2D()`, `evalLogo()`,
  `ResultContours()`, `MakeRegion()`, and the existing command opcodes.
- Replaced separate example, debug, and test controls with `LogoSCRunMode`.
- Changed test execution so tests run only when `LogoSCRunMode` is explicitly
  set to `"Tests"`.
- Removed the active legacy test compatibility gate from normal execution.
- Reworked the README Quick Start around a simple `MOVE`/`TURN` triangle and an
  immediate debug-overlay example.
- Updated README, User Manual, Cheat Sheet, detailed project overview, and
  developer documentation for LogoSC naming, versioning, run modes, debug
  rendering, licensing, and images.
- Tuned debug marker geometry, heights, transparency, and palette so overlapping
  start/end markers and pen-up segments remain visible.
- Renamed the debug demo `Right` option to `Rectangle` and simplified the crossed
  rectangle example to expose point-order errors directly.
- Added one `DebugDemoOverlay` control for all debug capsules, point markers, and
  related overlay objects while keeping filled-preview control separate.

### Fixed

- Corrected stale or mechanically renamed test-control references in public
  documentation.
- Corrected the Cheat Sheet setup variable after the project-name transition.
- Removed obsolete working-name references without renaming generic APIs.
- Corrected README version references to match the source version constants.
- Centered Quick Start extrusion examples and increased debug segment height so
  z-centered overlays remain visible against the filled model.
- Verified README image references use repository-relative paths and that the
  corresponding PNG files are present under `images/`.

### Documentation

- Documented `RenderLogoDebug()` as diagnostic preview geometry rather than a
  manufacturable stroke API.
- Added guidance for diagnosing crossing paths, unexpected point order, pen-up
  motion, primitive-generated edges, and contours that rely on implicit polygon
  closure.
- Added a compact README version-history table.
- Recorded optional open-contour validation and separate manufacturable stroke
  rendering as future design work.

### Known limitations

- Final geometry is filled-region output; manufacturable open-stroke rendering
  with width, caps, joins, and miter limits is not implemented.
- OpenSCAD `polygon()` implicitly closes each contour. LogoSC currently preserves
  that behavior even when the turtle endpoint differs from the starting point.
  Optional warning or strict validation remains a future design decision.

## [2026.0] - Initial public foundation

### Added

- OpenSCAD Logo-style interpreter with integer opcodes and named state, command,
  and result indices.
- Core commands: `MOVE`, `TURN`, `DIR`, `SCALE`, `GOTO`, `RUN`, `REPEAT`, `PUSH`,
  `POP`, `PENUP`, and `PENDOWN`.
- Geometry commands: `ARC`, `CIRCLE`, `REGPOLY`, `RECT`, `ROUNDEDRECT`, and `HOLE`.
- Region-based rendering with outer paths and holes.
- `RenderLogo2D()`, `RenderContours2D()`, and `RenderRegion2D()`.
- Recursive command evaluation, state stack, tracing, hard/soft error handling,
  regression tests, examples, Cheat Sheet, User Manual, and geometry design notes.

### Notes

- `CIRCLE` creates a centered closed contour. Use `[ARC, radius, 360]` for
  cursor-style full-loop motion.
- 3D composition remains the responsibility of native OpenSCAD operations such
  as `linear_extrude()` and `rotate_extrude()`.

## Index

- **Affine transforms and SHEAR:** [Unreleased](#unreleased), [2026.7](#20267---2026-07-31)
- **AI engineering and documentation:** [Unreleased](#unreleased), [2026.3](#20263---2026-07-22)
- **Celtic grids and knot compiler:** [Unreleased](#unreleased), [2026.5](#20265---2026-07-29)
- **Core commands and geometry:** [2026.0](#20260---initial-public-foundation), [2026.2](#20262---2026-07-13)
- **Fasteners:** [2026.3](#20263---2026-07-22)
- **L-systems:** [Unreleased](#unreleased)
- **Mini library and publishing:** [Unreleased](#unreleased), [2026.6](#20266---2026-07-31)
- **Testing and validation:** [Unreleased](#unreleased), [2026.2.1](#202621---2026-07-21), [2026.3](#20263---2026-07-22)
