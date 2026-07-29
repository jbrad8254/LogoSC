# LogoSC Developer Notebook

## Index

### Project and architecture

- [Bootstrap and source-of-truth rules](#chatgpt-bootstrap--read-this-first)
- [Purpose and maintenance policy](#1-purpose-and-maintenance-policy)
- [Project identity](#2-project-identity)
- [Current baseline and milestones](#3-current-baseline-and-milestones)
- [Stable public API](#4-stable-public-api)
- [Core design principles](#5-core-design-principles)
- [Non-goals and deferred ideas](#6-non-goals-and-deliberately-deferred-ideas)

### Rendering and geometry

- [Customizable nuts and bolts](#2026-07-21--customizable-nuts-bolts-and-helical-thread-profiles)
- [Fastener Customizer separation](#2026-07-21--fastener-customizer-head-drive-and-boolean-refinement)
- [Fastener gallery and chamfers](#2026-07-22--fastener-gallery-headless-drive-and-chamfer-refinement)
- [Fastener algorithm documentation](#2026-07-22--fastener-algorithm-documentation-and-mapping-figure)
- [Stroke and debug-rendering direction](#10-stroke-and-debug-rendering-direction)
- [Current conceptual model](#7-current-conceptual-model)
- [Command design conventions](#8-command-design-conventions)
- [Relative drawing style](#9-relative-drawing-style)
- [Coordinate and turn conventions](#10-coordinate-and-turn-conventions)
- [Geometry feature status](#11-geometry-feature-status)
- [Segment-count convention](#12-segment-count-convention)
- [Holes design](#13-holes-design)

### Debug rendering

- [Experimental debug-renderer design](#2026-07-11--experimental-debug-renderer-design-and-placement)
- [First visual-tuning pass](#2026-07-11--debug-renderer-first-visual-tuning-pass)
- [Naming and pen-up visibility](#2026-07-11--debug-renderer-naming-and-pen-up-visibility-tuning)
- [Overlap and example tuning](#2026-07-11--debug-renderer-overlap-and-example-tuning)
- [Crossing-line demo and endpoint tuning](#2026-07-11--debug-renderer-crossing-line-demo-and-endpoint-tuning)
- [Start-marker tuning](#2026-07-11--debug-renderer-start-marker-tuning)
- [Unified Customizer run selector](#2026-07-11--unified-customizer-run-selector)
- [Debug demo control cleanup](#2026-07-12--debug-demo-control-cleanup)
- [Debug renderer documentation pass](#2026-07-12--debug-renderer-documentation-pass)
- [Indexed debug-renderer gallery](#2026-07-20--indexed-debug-renderer-gallery)
- [Standalone Core and optional companions](#2026-07-20--standalone-core-and-optional-companion-boundary)
- [Optional path validation implementation](#2026-07-20--optional-path-analysis-and-validation)
- [Duplicate-point and tiny-edge validation](#2026-07-22--duplicate-point-and-tiny-edge-validation)
- [Proper self-intersection validation](#2026-07-22--proper-self-intersection-validation)
- [General topology and hole validation](#2026-07-27--general-topology-relations-and-strict-hole-validation)
- [Convexity query API](#2026-07-27--convexity-query-api)

### Documentation and workflow

- [Documentation architecture and conventions](#7-documentation-architecture-and-conventions)
- [Repository and packaging workflow](#8-repository-and-packaging-workflow)
- [Lessons learned](#9-lessons-learned)
- [Testing and regression risks](#11-testing-and-regression-risks)
- [Documentation status and roles](#16-documentation-status-and-doc-roles)
- [Quick Start and run-mode cleanup](#2026-07-12--quick-start-and-run-mode-guard-cleanup)
- [Quick Start snippet cleanup](#2026-07-12---quick-start-snippet-cleanup)
- [Future ideas filename cleanup](#2026-07-18--future-ideas-filename-reference-cleanup)
- [Legacy test-control reference cleanup](#2026-07-18--legacy-test-control-reference-cleanup)
- [Contributor guide integration](#2026-07-18--contributor-guide-integration)
- [AI Engineering Kit integration](#2026-07-18--ai-engineering-kit-integration)
- [AI Engineering Kit directory cleanup](#2026-07-18--ai-engineering-kit-directory-cleanup)
- [Documentation consistency cleanup](#2026-07-18--documentation-consistency-and-release-boundary-cleanup)
- [Codex Git workspace quick start](#2026-07-19--codex-git-workspace-and-agents-guidance)
- [Evaluator-invariant validation suite](#2026-07-19--evaluator-invariant-validation-suite)
- [OpenSCAD command-line verification guide](#2026-07-20--openscad-command-line-verification-guide)
- [Hierarchical automated test results](#2026-07-20--hierarchical-automated-test-results)
- [Examples and regression gallery screenshots](#2026-07-20--examples-and-regression-gallery-screenshots)
- [Direct Git delivery and conditional ZIP fallback](#2026-07-21--direct-git-delivery-and-conditional-zip-fallback)
- [Debug renderer gallery screenshot](#2026-07-21--debug-renderer-gallery-screenshot)
- [OpenSCAD examples run guide screenshot](#2026-07-21--openscad-examples-run-guide-screenshot)

### Planning, releases, and history

- [Current roadmap](#12-current-roadmap)
- [Open questions](#13-open-questions)
- [Current LogoSC preferences](#14-user-preferences-specific-to-logosc)
- [Historical handoff record](#15-historical-handoff-record-from-the-pre-notebook-file)
- [Versioning policy](#5-versioning-policy)
- [Release baseline and experiment status](#17-current-release-baseline-and-experiment-status)
- [Near-term next steps](#18-near-term-likely-next-steps)
- [Deferred feature ideas](#19-deferred-feature-ideas)
- [2026.2 release preparation](#2026-07-13--consolidated-20262-release-preparation)
- [2026.2 release identifier cleanup](#2026-07-18--20262-release-identifier-cleanup)
- [2026.3 release preparation](#2026-07-22--20263-feature-release-preparation)
- [2026.4 release preparation](#2026-07-27--20264-feature-release-preparation)
- [Journal-entry template](#yyyy-mm-dd--topic)

## Quick Links

- [Current version and milestones](#3-current-baseline-and-milestones)
- [Stable public API](#4-stable-public-api)
- [Known open issues](#13-open-questions)
- [Roadmap](#12-current-roadmap)
- [Testing and regression risks](#11-testing-and-regression-risks)
- [Documentation conventions](#7-documentation-architecture-and-conventions)
- [Packaging workflow](#8-repository-and-packaging-workflow)
- [Latest release preparation](#2026-07-13--consolidated-20262-release-preparation)

## ChatGPT bootstrap — read this first

This file is the primary long-term engineering memory for the LogoSC project.

Its main purpose is to **initialize ChatGPT after an old conversation has been
flushed and development resumes in a new chat**. It is also useful to human
maintainers because it records design rationale, historical decisions, workflow
rules, lessons learned, deferred ideas, and known regression risks that do not
belong in the public user documentation.

When starting a new LogoSC chat:

1. Read `docs/ai-engineering-kit/AI-Engineering-Kit-Handoff.md` for kit purpose,
   order, and precedence.
2. Read `docs/ai-engineering-kit/Codex-Git-Project-Quick-Start.md`.
3. Read `docs/ai-engineering-kit/Generic-Project-Bootstrap.md`.
4. Read `docs/ai-engineering-kit/ChatGPT-Project-Workflow.md`.
5. Read `docs/ai-engineering-kit/Engineering-Preferences.md`.
6. Read `docs/ai-engineering-kit/Project-Retrospective.md`.
7. Read this entire file.
8. Read `README.md` for the concise repository overview.
9. Read `CHANGELOG.md` for release and milestone history.
10. Read `CONTRIBUTING.md` for contribution and maintenance conventions.
11. Read `LogoSC-User-Manual.md` and implementation notes as needed for the task.
12. Treat the current Git working tree, or the latest uploaded repository snapshot
    extracted into it, as the sole source of truth.
13. Ignore remembered files from older chats and the File Library unless the user
   explicitly asks for comparison.
14. Make incremental changes only.
15. Preserve historical context rather than replacing it with shorter summaries.
16. Verify that previously accepted documentation and code have not regressed
    before delivering an update.
17. If Git confirms that the AI is editing the user's active working tree, leave the
    verified changes there and do not create a ZIP unless requested. Otherwise use one
    combined ZIP containing all changed and added files under exact repository paths.

This bootstrap sequence overrides any conflicting remembered context from older
LogoSC conversations.

---

## 1. Purpose and maintenance policy

This is a living engineering notebook, not a concise release summary. It should
grow as the project develops.

Preserve historical context whenever practical. When a design decision changes,
record:

- the earlier decision;
- the reason it was made;
- what new information caused it to change;
- the replacement decision; and
- the date or milestone at which the change occurred.

Do not delete older reasoning merely because a newer decision supersedes it.
Mark superseded material clearly. The history is useful when restarting a chat,
onboarding a contributor, or investigating why an apparently attractive design
was previously rejected.

---

## 2. Project identity

LogoSC is a compact Logo-inspired language embedded in OpenSCAD. It evaluates
integer-opcode command lists into closed 2D polygonal regions suitable for CAD
modeling and 3D printing.

LogoSC generates 2D region data. Native OpenSCAD remains responsible for:

- `linear_extrude()`;
- `rotate_extrude()`;
- `offset()`;
- boolean composition;
- transforms;
- colors and materials; and
- final 3D modeling.

LogoSC is not intended to become a complete Logo implementation or a replacement
for OpenSCAD.

---

## 3. Current baseline and milestones

Current stable milestone:

- LogoSC release `2026.4`.

License milestone:

- Added a root `LICENSE` file using the MIT License. This is appropriate for
  LogoSC's current goal as a small permissive OpenSCAD utility/library: users
  may copy, modify, redistribute, and use it in commercial or closed-source
  projects as long as the copyright/license notice is preserved. README files
  should link to `LICENSE` rather than embedding the full license text.
- Current source snapshot public API version `2026.4`.

Major implemented features include:

- integer opcodes;
- named state and result indices;
- `MOVE`, `TURN`, `DIR`, `SCALE`, `GOTO`, `RUN`, `REPEAT`, `PUSH`, `POP`,
  `PENUP`, and `PENDOWN`;
- tessellated `ARC`;
- `CIRCLE`, `REGPOLY`, `RECT`, and `ROUNDEDRECT`;
- region holes through `HOLE`;
- multiple regions and contours;
- separate evaluation and rendering;
- public evaluator-result and region accessors;
- regression/failure tests and example galleries;
- expanded public API documentation;
- Quick Start examples with screenshots stored under `images/`.
- LogoSC identity finalized before external use.
- LogoSC wordmark and gear icon added under `images/`.
- Root `CONTRIBUTING.md` added for contribution, maintenance, testing, documentation,
  versioning, and packaging guidance.
- AI Engineering Kit stored under `docs/ai-engineering-kit/` by explicit user request as
  maintainer-facing companion material, separate from LogoSC public API and user documentation.
- Optional path and topology validation for basic path defects, proper self-intersections,
  general segment/contour/region relationships, hole containment, and hole overlap.
- Customizable printable fasteners with metric, Unified, and custom sizes; multiple thread,
  head, drive, handedness, and start options; gallery and algorithm outputs; and safety guidance.

Append new milestones here. Do not rewrite this section as only the latest state.

---

## Restart Checkpoint — 2026.4 Topology and Convexity Stable

Current project state is suitable for a fresh chat/restart from the local Git repository or
a repository ZIP.

Verified working state:

- Project name is LogoSC.
- Public old-name references have been removed.
- MIT License has been added at repository root as `LICENSE`.
- README, User Manual, and Cheat Sheet have been updated for the current setup flow.
- README Quick Start uses a simple `MOVE` / `TURN` triangle example.
- Ordinary user files do not need to set `LogoSCRunMode`.
- `LogoSCRunMode` is the single top-level demo selector for built-in examples/debug/tests:
  - blank or undefined: no automatic preview/test geometry;
  - `"NoDemo"`: no automatic preview/test geometry;
  - `"Examples"`: normal examples gallery;
  - `"Debug"`: debug visualization demo;
  - `"Tests"`: regression test grid.
- `LogoSC-Examples.scad` runs tests only when `LogoSCRunMode == "Tests"`;
  `LogoSC-Foundation-Test-Runner.scad` is the direct suite entry point.
- `LogoSC-Foundation-Core.scad` is standalone and does not include test or optional
  feature companions.
- Optional `LogoSC-Foundation-Validation.scad` supplies explicit path records, integrity and
  topology checks, general geometry relationships, and convexity queries without changing Core
  evaluation or rendering.
- `LogoSC-Nuts-And-Bolts.scad` supplies the standalone customizable fastener application while
  keeping native OpenSCAD responsible for twisted extrusion and 3D booleans.
- `RenderLogoDebug()` is implemented and visually verified.
- Debug visualization is preview/debug-only, not intended to create manufacturable stroke geometry.
- Debug rendering uses z-centered 3D capsules and point markers.
- Debug visualization is useful for seeing:
  - path order;
  - crossing/self-intersecting contours;
  - pen-up movement;
  - primitive-vs-hand-built geometry;
  - start/end point behavior;
  - open/unclosed polygon behavior.
- Debug demos include simple closed/open triangle cases, crossed rectangle, rectangle,
  pen-up gap, arc/loop, primitive comparison, and primitive examples.
- Images are present and referenced:
  - `images/logosc-wordmark.png`;
  - `images/logosc-gear-icon.png`;
  - `images/quickstart-triangle.png`;
  - `images/quickstart-plate-hole.png`;
  - `images/readme-quickstart-triangle.png`;
  - `images/readme-quickstart-triangle-debug.png`;
  - `images/examples-gallery.png`;
  - `images/regression-test-gallery.png`;
  - `images/debug-renderer-gallery.png`;
  - `images/openscad-examples-run-guide.png`.
- README Quick Start now shows the actual filled-triangle result immediately after
  the first code block and the debug-overlay result immediately after the
  `RenderLogoDebug()` code block.
- Git tags `v2026.2`, `v2026.2.1`, and `v2026.3` preserve the earlier release baselines.
- Release `2026.3` consolidates the later fastener application, expanded validation, tests,
  documentation, and reproducible images without rewriting those earlier tags.
- Release `2026.4` consolidates general topology relationships, strict hole validation,
  convexity queries, expanded deterministic suites, and preliminary transform design notes.

Known open design issues:

- Decide whether future validation should add equality, finer touch classifications, or policies
  for relationships between independent outer regions.
- Measure topology validation on real highly tessellated models before considering a sweep-line
  or spatial index.
- README already includes a verified debug-overlay screenshot. Add another manual screenshot
  only if it teaches something the existing image does not.
- Prepare another release only after later work forms a coherent, verified milestone.

---

## 4. Stable public API

### Rendering modules

- `RenderLogo2D()`
- `RenderContours2D()`
- `RenderRegion2D()`

### Diagnostic rendering

- `RenderLogoDebug()`

`RenderLogoDebug()` is a stable public diagnostic API. Its contract is preview-only path
visualization; it does not create manufacturable stroke geometry or alter the output of
`RenderLogo2D()`.

### Evaluation

- `evalLogo()`
- `evalLogoPaths()` (optional validation companion)
- `ValidateLogoPaths()` (optional validation companion)
- `ReportLogoValidation()` (optional validation companion)

### Evaluator-result accessors

- `ResultState()`
- `ResultContours()`
- `ResultStack()`
- `ResultPen()`

### Optional path and validation accessors

- `PathResultState()`, `PathResultPaths()`, `PathResultStack()`, `PathResultPen()`
- `PathRole()`, `PathKind()`, `PathPoints()`, `PathSourceOpcode()`
- `PathIsExplicitlyClosed()`, `PathIsClosed()`, `PathStart()`, `PathEnd()`
- `PathPointCount()`, `PathSegmentCount()`, `PathVertexCount()`
- `ValidationPathResult()`, `ValidationPaths()`, `ValidationIssues()`
- `ValidationTolerance()`, `ValidationIsValid()`
- `ValidationIssuePathIndex()`, `ValidationIssueCode()`, `ValidationIssueName()`
- `LogoContourIsConvex()`, `LogoPathIsConvex()`, `LogoRegionIsConvex()`
- `LogoRegionsAreIndividuallyConvex()`

### Region helpers

- `MakeRegion()`
- `RegionOuter()`
- `RegionHoles()`

Avoid breaking these APIs without a deliberate version bump and documentation
update. `ResultContours()` retains its historical name even though it now
returns a region list.

---

## 5. Core design principles

- Keep LogoSC small and readable.
- Generate closed 2D polygonal regions.
- Keep evaluation functional and data-oriented.
- Keep rendering separate from evaluation.
- Prefer relative commands such as `MOVE`, `TURN`, and `ARC` inside reusable
  command lists.
- Use absolute commands such as `GOTO` and `DIR` primarily for layout and known
  setup.
- Use CAD primitives where they make mechanical geometry clearer.
- Let OpenSCAD perform ordinary OpenSCAD work.
- Prefer surgical edits over broad rewrites.
- Preserve exact public and repository filenames.

---

## 6. Non-goals and deliberately deferred ideas

These decisions should not be repeatedly reopened without a compelling new
reason.

- LogoSC is not a replacement for OpenSCAD.
- Do not wrap `linear_extrude()`, `rotate_extrude()`, `union()`,
  `difference()`, `intersection()`, `offset()`, `color()`, or ordinary
  transforms in LogoSC.
- Do not add public API merely to save one or two lines of normal OpenSCAD.
- Do not let stroke rendering replace or complicate the normal filled-region
  renderer.
- Full Logo language compatibility is not a current goal.
- Text/font rendering is not a first-class LogoSC feature.
- Multi-color manufacturing semantics are outside the current scope.
- `ROUNDEDREGPOLY` remains deferred until its corner-rounding semantics are
  clear.
- Open-stroke width, cap, join, and miter APIs remain experimental/future work.

---

## 7. Documentation architecture and conventions

`LogoSC-User-Manual.md` is the primary public manual.

`CONTRIBUTING.md` is the concise contributor-facing guide for project philosophy,
stable-API expectations, coding style, documentation, testing, versioning, and
packaging. It should point maintainers to this notebook for design history and to
`LogoSC-Future-Ideas.md` for longer-term concepts rather than duplicating either.

The AI Engineering Kit consists of `AI-Engineering-Kit-Handoff.md`, the short
`Codex-Git-Project-Quick-Start.md`, and four original reusable process documents:
`Generic-Project-Bootstrap.md`, `ChatGPT-Project-Workflow.md`,
`Engineering-Preferences.md`, and `Project-Retrospective.md`. These files are stored under
`docs/ai-engineering-kit/` by explicit user request and remain maintainer-facing companion
material. They describe setup, collaboration, and general preferences; `AGENTS.md`, this
notebook, and the current repository remain authoritative for LogoSC-specific guidance.

Section 7 of the manual is the canonical description of:

- public rendering APIs;
- `evalLogo()` input and output;
- `EvalResult`;
- region, contour, and point formats;
- evaluator-result accessors; and
- region constructor/accessor APIs.

Documentation should increasingly function as an engineering guide rather than
only an API reference.

Quick Start examples should show code and rendered output.

Store documentation images in:

```text
images/
```

Use relative Markdown references such as:

```markdown
![Figure 2-1](images/quickstart-triangle.png)
```

Do not rename accepted image files casually because the Markdown links are part
of the repository contract.

---

## 8. Repository and packaging workflow

The user uses Git. Preserve exact project filenames.

For each work session:

1. Start from the current user-approved Git working tree or the most recent uploaded
   repository ZIP.
2. If starting from a ZIP, extract it into one working tree.
3. Test for direct working-tree integration with `git rev-parse --show-toplevel`,
   `git status`, and `git diff`. Confirm that the root is the repository the user placed
   in scope and that the reported changes are the files being edited.
4. Apply all changes in that working tree.
5. Verify the requested changes and confirm unrelated accepted content has not regressed.
6. When direct integration is verified, leave the changes in the working tree for normal
   Git review. Do not create a ZIP unless the user requests one.
7. When Git is unavailable, the workspace is temporary or attachment-based, the user cannot
   inspect the edited tree, or integration cannot be verified, deliver one combined ZIP with
   every changed or added file under its exact repository-relative path.
8. Verify fallback ZIP entries and hashes before delivery, and keep transfer artifacts outside
   the repository. Include a checksum file when practical, but do not assume it belongs in Git.
9. Do not use `-fixed`, `-new`, `-v2`, or similar names inside the project.
10. Use LF line endings.

The active Git working tree, or the current repository snapshot extracted into it, is the
source of truth—not chat memory or similarly named sandbox files.

---

## 9. Lessons learned

### 2026-07-10 — LogoSC rename and visual identity stabilized

Verified state before the next chat restart:

- LogoSC identity finalized before external use.
- Generic programming APIs intentionally preserved:
  - `RenderLogo2D()`
  - `RenderContours2D()`
  - `RenderRegion2D()`
  - `evalLogo()`
  - result and region accessors
  - command opcodes
- Project-specific version symbols renamed to `LogoSCVersion*`.
- Public API version advanced to `2026.1`.
- Git repository rename still needs to be performed outside ChatGPT after source
  rename changes are committed.
- Wordmark in `LogoSC-Examples.scad` now spells LogoSC.
- Gear-like O in the wordmark was enlarged and verified by user-rendered output.
- `images/logosc-wordmark.png` added for README and User Manual.
- `images/logosc-gear-icon.png` added for README thumbnail and Cheat Sheet icon.
- README, User Manual, Cheat Sheet, and examples were verified after the rename.
- The user verified examples and tests still run as expected after the rename.

Lessons:

- Do not mechanically alter unrelated identifiers during project-identity cleanup.
- When adding image references to Markdown, verify both sides:
  1. the Markdown link exists; and
  2. the PNG file is physically present in the ZIP under the referenced path.
- For future ZIP generation, inspect the archive contents before claiming image
  assets were included.


### 2026-07-10 — LogoSC project identity finalized

Previous state:

- The project had a pre-release working name.
- The working name conveyed Logo/turtle ancestry but did not clearly identify
  OpenSCAD.

Reason for change:

- LogoSC communicates the OpenSCAD target directly.
- `LogoOSC` was rejected because it suggests Open Sound Control.
- `LogoS` was rejected as too ambiguous.
- The project is still pre-1.0, making this the least disruptive time to finalize
  the name.

Decision:

- Use LogoSC consistently as the repository and project identity.
- Use `LogoSC-*` project filenames.
- Use `LogoSCVersion*` for project-specific version symbols.
- Preserve generic APIs such as `RenderLogo2D()` and `evalLogo()`.

Consequences:

- Include paths use `LogoSC-*` filenames.
- Version constants use `LogoSCVersion*`.
- Public API version advances to `2026.1`.
- Because there are no external users yet, documentation should not preserve or
  advertise the discarded working name unless the user explicitly asks for a
  comparison.

### 2026-07-10 — Documentation baseline regressions

Several documentation updates accidentally started from an older
`LogoSC-User-Manual.md`, causing previously accepted Quick Start and Section 7
changes to disappear.

Permanent rule:

- Never reconstruct or patch documentation from an older copy.
- Start from the latest user-approved repository or document.
- Chain multiple changes in one chat from the latest generated working copy.
- Before packaging, explicitly verify important accepted sections and figure
  links remain present.

Useful verification checks include:

- requested heading/text exists;
- `## 2. Quick Start` still exists;
- both Quick Start image links still exist;
- Section 7 API material still exists;
- changed sections differ as intended;
- unrelated sections are byte-for-byte unchanged when practical.

### 2026-07-10 — Generated-file claims require inspection

Do not claim an archive contains a requested edit merely because the generation
script completed. Open the generated file or inspect the ZIP contents and test
for the expected material first.

### 2026-07-10 — Preserve the rich handoff record

A short generated Future Context file lost valuable architecture and workflow
details. The project benefits more from a growing engineering notebook than from
an aggressively compressed summary.

### File-handling lesson

The Windows ChatGPT app and browser layers can display numbered duplicate file
names. Do not infer authority from a UI display name. Confirm content from the
active extracted working tree.

---

## 10. Stroke and debug-rendering direction

`RenderLogoDebug()` is implemented in `LogoSC-Foundation-Core.scad`, visually verified,
documented, and part of the stable public diagnostic API as of `2026.2`.

Historical note: this section originally described a combined stroke/debug renderer as a
candidate experiment. The event-based debug portion was subsequently implemented and
promoted. Manufacturable stroke rendering remains a separate future feature and must not
change filled-region semantics.

Primary purposes:

- visualize turtle motion;
- debug generated command lists;
- inspect recursion and L-systems;
- show `PENUP`/`PENDOWN` behavior;
- distinguish path construction from filled-region output; and
- optionally show direction/state markers.

Strokes are less useful than filled regions for the project's primary CAD and
3D-printing use cases. Keep any manufacturable stroke renderer separate from both the
stable filled-region renderer and the diagnostic debug renderer.

Potential future debug annotations to evaluate only when they solve a demonstrated need:

- heading arrows;
- command-index labels;
- optional contour, region, or event filtering;
- state-stack markers; and
- optional point-index display.

Do not promote manufacturable stroke APIs into the stable core until their width, cap,
join, miter, input-data contract, and usefulness are clear.

---

## 11. Testing and regression risks

Known regression risks:

- stale documentation baselines;
- renaming files in a Git-managed project;
- changing the shape of `EvalResult`;
- confusing a flat contour list with the current region-list format;
- reintroducing 3D wrapper APIs;
- promoting experimental APIs too early;
- using absolute commands throughout examples where relative commands would be
  reusable;
- unintentionally changing test-grid layout or color conventions; and
- splitting one work session across several update ZIPs.

Run or inspect the regression tests after core changes. For documentation-only
changes, verify links, headings, code examples, and retained accepted content.

---

## 12. Current roadmap

Near-term candidates:

- implement the optional knot companion in the staged order recorded in
  `LogoSC-Knots-Design.md`, beginning with shared strand records and torus-knot cords;
- make adjacent multi-cord expansion a generator-independent post-topology stage, with shared
  over/under motion and explicit lane-closing permutations for half-twisted bundles;
- keep future AI-assisted figurative-knot import outside Core: AI supplies an inspectable vector
  blueprint, while deterministic companion code synthesizes and validates the actual routes;
- expand optional validation only when additional topology policies provide clear value;
- expand the non-rendering evaluator and validation suites alongside eventual open-path support;
- measure generalized pairwise topology costs on real highly tessellated models before
  considering optimization;
- continue manufacturable stroke experiments separately from `RenderLogoDebug()` and
  `RenderLogo2D()`;
- document recursion and generated command lists more fully;
- continue L-system documentation and examples;
- add CAD primitives only when they clearly reduce complexity; and
- prepare a later milestone only after another coherent feature set is implemented and verified.

---

## 13. Open questions

Record unresolved questions here rather than relying on chat history.

Current examples:

- What is the smallest useful public stroke API?
- Should stroke rendering consume commands, evaluated path events, or region
  contours?
- Which debug annotations are useful without overwhelming OpenSCAD preview?
- Should a future stroke implementation remain entirely experimental, or should
  a small stable diagnostic API eventually move into the core?
- Should future validation policies reject any relationships between independent outer regions,
  or should those remain report-only because overlapping regions can be intentional?

Resolved 2026-07-18: `RenderLogoDebug()` is the small stable diagnostic API in the core.
The question of a separate manufacturable stroke API remains open.

Resolved 2026-07-27: optional validation requires holes to be strictly contained and rejects
outer-boundary contact plus overlapping, touching, coincident, or nested sibling holes.
Independent outer-region relationships remain report-only.

Append conclusions with dates rather than deleting the original question.

---

## 14. User preferences specific to LogoSC

- Prefer direct Git working-tree delivery when integration is verified.
- Do not create a ZIP in a verified shared Git workspace unless the user requests one.
- Retain one combined exact-path ZIP as the fallback for non-integrated environments.
- Exact repository filenames.
- Fallback ZIPs should be suitable for extracting directly over the repository.
- Prefer `TURN` over `DIR` and `MOVE` over `GOTO` inside reusable examples.
- Use `GOTO`/`DIR` for deterministic layout where appropriate.
- Right-handed coordinates; positive turns are counterclockwise around +Z.
- Keep `TraceLevel = 0` below the include in normal user examples.
- Keep 3D operations outside the LogoSC core.
- Preserve history and design rationale in this notebook.
- Use the repository snapshot plus this notebook to restart development in a new
  chat.

---

## 15. Historical handoff record from the pre-notebook file

The following material is retained from the earlier
`LogoSC-Future-Context.md`, the former filename that was later replaced by
`LogoSC-Future-Ideas.md`. It remains useful historical context. Where this
section conflicts with a newer dated decision above, the newer decision wins.

<details>
<summary>Legacy LogoSC Future Context and Handoff Notes</summary>

# LogoSC Future Context and Handoff Notes

This note is for a future ChatGPT session continuing the LogoSC OpenSCAD project from a
clean repository snapshot. It is intentionally different from the project README, user
manual, changelog, and implementation notes. Those files describe what the library is and
how to use it. This file describes the project intent, editing workflow, design priorities,
known pitfalls, and likely next steps.

## 1. Source of truth for the next chat

Use the user-uploaded repository snapshot as the only source of truth.

Do not use older files from ChatGPT File Library, previous chats, generated sandbox files,
or similarly named historical exports unless the user explicitly asks for comparison.
Older LogoSC/Turtle versions caused confusion earlier.

Expected current project files include approximately:

```text
LogoSC-Foundation-Core.scad
LogoSC-Foundation-Tests.scad
LogoSC-Foundation-Test-Runner.scad
LogoSC-Examples.scad
LogoSC-Experiments.scad
README.md
LogoSC-README.md
LogoSC-User-Manual.md
LogoSC-CheatSheet.md
CHANGELOG.md
LogoSC-ARC-Implementation.md
LogoSC-Holes-Implementation.md
LogoSC-Validation-Implementation.md
LogoSC-Transforms-Design.md
LogoSC-LSystems-Notes.md
.gitattributes
```

There may also be checksum files or generated zip artifacts. Treat checksum files as
transfer artifacts unless the user says they are committed project files.

## 2. Naming and export rules

The user is using Git. Preserve exact project filenames.

Do not create replacement files named `-fixed`, `-v2`, `new`, `copy`, or similar. When a
project file changes, overwrite/export using the same filename. For every work session, deliver all changed or added project files in one combined update
zip containing exact repository filenames, suitable for extracting directly over the repo.
Do not split a session across several update zips unless the user explicitly asks. Preserve
this rule in future handoff notes. The zip workflow has been much more reliable than
individual file downloads in the ChatGPT/Windows app.

When exporting multiple files, include a checksum file in the artifact zip if practical,
but do not assume the checksum file belongs in Git.

Use LF line endings. The repository should include:

```text
*.scad text eol=lf
*.md   text eol=lf
*.txt  text eol=lf
```

## 3. Known ChatGPT / file-handling pitfalls

The ChatGPT Windows app and browser download layers have previously created duplicate
file names, numbered files, and temporary files. Do not infer source truth from UI display
names. The safest pattern is:

1. User uploads a clean zip snapshot.
2. Extract it into a working directory.
3. Patch files there.
4. Rebuild a zip with exact project filenames.
5. Provide the zip as the primary download.

The individual `/mnt/data/LogoSC-Foundation-Core.scad` file has sometimes appeared stale
relative to the current zip bundle. Verify content from the active working directory before
making claims.

## 4. Project identity

LogoSC is an OpenSCAD Logo-style geometry generator for creating 2D printable regions that
can be passed to native OpenSCAD operations such as `linear_extrude()`, `rotate_extrude()`,
`offset()`, `difference()`, `union()`, `translate()`, `scale()`, and `color()`.

LogoSC should remain a 2D region generator. OpenSCAD should remain responsible for 3D
composition.

The main user-facing render function is:

```scad
RenderLogo2D(cmds, convexity = 10);
```

Users can then write:

```scad
linear_extrude(height = 4)
{
    RenderLogo2D(cmds);
}
```

or:

```scad
rotate_extrude(angle = 360)
{
    RenderLogo2D(profileCmds);
}
```

Do not reintroduce `RenderLogoLinear()`, `RenderLogoRotate()`, or extrusion wrapper APIs
unless the user explicitly decides to reverse that design choice.

## 5. Versioning policy

LogoSC currently uses a manual Major.Minor style library version in core, approximately:

```scad
LogoSCVersionMajor = 2026 + 0;
LogoSCVersionMinor = 0 + 0;
LogoSCVersion = str(LogoSCVersionMajor, ".", LogoSCVersionMinor);

function LogoSCVersionAtLeast(major, minor) = ...;
```

Do not auto-update the version on every edit/export. Git tracks every commit. The LogoSC
version should be bumped only for public API/feature milestones, especially changes that
users might want to test against.

## 6. Core design goals

Primary goals:

- Generate useful 2D geometry for OpenSCAD and 3D printing.
- Preserve a Logo-like programming style where reusable shapes use relative motion.
- Keep the interpreter functional and data-oriented rather than emitting geometry directly
  during evaluation.
- Keep API names using `Logo`, not `Turtle`.
- Keep low-level state functions named around `state*` conventions already established.
- Keep documentation practical and example-driven.
- Prefer small surgical edits over broad regex refactors.

Non-goals for now:

- Full Logo language compatibility.
- Text/font rendering as a first-class LogoSC feature.
- Multi-color manufacturing semantics.
- Open stroke rendering with caps/joins.
- Boolean modeling wrappers that duplicate OpenSCAD.

## 7. Current conceptual model

LogoSC command lists evaluate into a result containing:

- final Logo state;
- region/contour geometry;
- stack state;
- pen state;
- error state.

A region is conceptually:

```text
[outerContour, holeContour0, holeContour1, ...]
```

Rendering uses OpenSCAD `polygon(points = ..., paths = ...)` so holes are represented by
polygon paths rather than by `difference()`.

The current renderer should expose:

```scad
RenderLogo2D(cmds, convexity = 10);
RenderContours2D(regions, convexity = 10);
RenderRegion2D(region, convexity = 10);
```

`RenderContours()` compatibility alias was intentionally removed to reduce future churn.

## 8. Command design conventions

Document and implement optional arguments as single command forms, not multiple overload
entries. Use notation such as:

```scad
[ARC, radius, degrees[, segments]]
[CIRCLE, radius[, segments]]
[REGPOLY, sides, radius[, rotation]]
[ROUNDEDRECT, width, height, radius[, segments]]
[RUN, cmds[, scale[, maxRec]]]
```

Commands should use soft errors by default unless `HardErrors` is enabled. OpenSCAD
`assert()` stops the whole run, so soft errors are important for test visibility.

## 9. Relative drawing style

The user prefers relative drawing commands inside reusable command lists.

Rule of thumb:

| Situation | Prefer | Reason |
|---|---|---|
| Reusable shape/path/glyph | `MOVE`, `TURN`, `ARC` | Inherits caller position/heading/scale |
| Absolute layout/anchoring | `GOTO`, sometimes `DIR` | Explicit positioning |
| Starting a deterministic example | `GOTO` with heading | Known initial state |
| Stamped CAD-style primitives | `GOTO`, then `CIRCLE`/`RECT`/etc. | Shapes are centered at current state |

Examples were updated to remove internal `DIR` usage and prefer relative `TURN` where
practical. Keep `GOTO` for layout and hole placement.

## 10. Coordinate and turn conventions

LogoSC uses OpenSCAD's right-handed coordinate system. In the standard LogoSC test/example
view, +X appears left and +Y appears upward. Positive relative turns are right-handed
rotations about the +Z axis; viewed from +Z toward the XY plane, positive turns are
counterclockwise.

This matters because left-handed screen coordinate assumptions have bitten the user before.

## 11. Geometry feature status

Implemented concepts include:

- motion/state: `MOVE`, `TURN`, `DIR`, `SCALE`, `GOTO`;
- structure: `RUN`, `REPEAT`, `PUSH`, `POP`;
- pen control: `PENUP`, `PENDOWN`;
- curves: `ARC` with OpenSCAD-like segment selection;
- closed shape stamps: `CIRCLE`, `REGPOLY`, `RECT`, `ROUNDEDRECT`;
- holes: `[HOLE, cmds]`;
- region rendering through `polygon(points, paths)`;
- test-grid coloring and row markers;
- example gallery including a LogoSC wordmark, plates, profiles, L-system-generated fractal
  outlines, a spiral tower, and 3D OpenSCAD wrappers around `RenderLogo2D()`.

The `CIRCLE` command is intentionally CAD-like, not classic Logo-like. It creates a closed
circle centered at the current state and does not move the Logo state. For classic turtle
full-loop behavior, use:

```scad
[ARC, radius, 360]
```

## 12. Segment-count convention

Curved geometry should follow this rule:

- Explicit segment arguments override `$fn`, `$fa`, and `$fs`.
- Omitted segment arguments use OpenSCAD-style automatic selection.
- `$fn > 0` gives the full-circle fragment count; otherwise `$fa` and `$fs` apply.
- `ARC` explicit segments count the arc itself.
- `CIRCLE` explicit segments count the full circle.
- `ROUNDEDRECT` explicit segments count each rounded corner.
- `REGPOLY` uses side count directly and does not consult `$fn`, `$fa`, or `$fs`.

Details belong in `LogoSC-ARC-Implementation.md`, not in the README.

## 13. Holes design

Holes are implemented by polygon paths, not OpenSCAD `difference()`.

`[HOLE, cmds]` evaluates child commands and attaches the child contours as holes to the
most recently emitted outer region. It should not move or alter the parent state. Child
commands can create multiple contours, and those can become multiple holes.

For 3D modeling, users may still wrap LogoSC output in OpenSCAD `difference()` when they
want to subtract non-LogoSC objects such as cylinders, imported meshes, or other solids.

## 14. Color design

Color should remain outside LogoSC geometry semantics.

Do not add color to:

- command lists;
- evaluated regions;
- core rendering data;
- `RenderLogo2D()`.

Color is currently useful in the test/example presentation layer through OpenSCAD
`color()` wrappers. Test colors are based on grid position. This is for visual debugging
and screenshots, not 3D-printing semantics.

## 15. Test suite conventions

Core must not include the test definitions. `LogoSC-Foundation-Tests.scad` and
`LogoSC-Foundation-Validation-Tests.scad` contain passive test definitions. The direct runner
and the Examples `Tests` mode call `RunAllLogoTestSuites()` after explicitly including Core,
Validation, and both test files.

Automated checks are immutable `[name, passed, detail]` records. They are collected into a
Foundation suite and a Validation suite, then examined as one global suite list. Default
report level `1` prints suite totals plus every failure; level `2` prints every named result.
The final `LOGOSC_AUTOMATED_TEST_RESULT` record is the authoritative automated outcome.

The expected-failure row still exercises `HardErrors = false` behavior. Core `[ERROR]` output
between its explicit `BEGIN` and `END` markers is diagnostic input, not a failed test record.
Do not infer overall success or failure by counting undifferentiated `[ERROR]` lines.

Important OpenSCAD include pattern for examples/user files:

```scad
include <LogoSC-Foundation-Core.scad>
TraceLevel = 0; // [0:4]
```

Ordinary user files do not need `LogoSCRunMode` or any test file. Basic LogoSC use requires
only `LogoSC-Foundation-Core.scad`.

The test grid uses logical grid indices, not absolute positions. Row markers and X-index
colors make the test output more readable.

## 16. Documentation status and doc roles

Current docs are split by purpose:

- `AGENTS.md`: compact repository-specific operating rules automatically available to Codex.
- `docs/ai-engineering-kit/AI-Engineering-Kit-Handoff.md`: kit orientation, reading order,
  and precedence rules.
- `docs/ai-engineering-kit/Codex-Git-Project-Quick-Start.md`: short reusable setup and
  daily-use guide for local Codex Git workspaces.
- `docs/ai-engineering-kit/Generic-Project-Bootstrap.md`: concise reusable repository-first
  startup procedure.
- `docs/ai-engineering-kit/ChatGPT-Project-Workflow.md`: preferred long-running AI
  collaboration behavior.
- `docs/ai-engineering-kit/Engineering-Preferences.md`: durable cross-project engineering
  and delivery standards.
- `docs/ai-engineering-kit/Project-Retrospective.md`: process history, lessons, and reasons
  behind the workflow kit.
- `CONTRIBUTING.md`: contributor workflow, stable-API, testing, documentation, versioning,
  and packaging expectations.
- `LogoSC-Developer-Notebook.md`: engineering history, design rationale, workflow, and
  ChatGPT restart guidance.
- `LogoSC-OpenSCAD-Command-Line.md`: tested command-line evaluation, export, diagnostic,
  and PNG-preview workflow with links to the official OpenSCAD manual.
- `LogoSC-Future-Ideas.md`: longer-term feature concepts that are not active commitments.
- `LogoSC-README.md`: overview, file list, public API quick reference, roadmap.
- `LogoSC-User-Manual.md`: full user documentation, setup, command reference, workflows.
- `LogoSC-CheatSheet.md`: compact one-page-style reference with method signatures and links.
- `CHANGELOG.md`: release history and milestone notes.
- `LogoSC-ARC-Implementation.md`: arc/segment-count design details.
- `LogoSC-Holes-Implementation.md`: region/hole rendering design details.
- `LogoSC-Validation-Implementation.md`: validation architecture, algorithms, topology policy,
  complexity boundaries, and the complete automated test matrix.
- `LogoSC-Transforms-Design.md`: preliminary local-transform direction, compatibility constraints,
  and questions that must be resolved before implementation.
- `LogoSC-LSystems-Notes.md`: design notes for L-system example helpers and future fractal examples.
- `LogoSC-Knots-Design.md`: active plan for generative topology, knot algorithms, adjacent-cord
  bundles, ribbons, bas-relief, rounded cords, verification, and optional-companion sequencing.
- `LogoSC-Examples.scad`: runnable examples and gallery.
- `LogoSC-Experiments.scad`: experimental lab bench for unproven rendering approaches.
- `README.md`: short GitHub repository landing page.

The cheat sheet should stay compact, similar in spirit to the OpenSCAD cheat sheet. It
should not become another manual.

## 17. Current release baseline and experiment status

The current public baseline is:

```text
Release: 2026.4
Status: 201 Foundation/Validation results and 48 fastener results verified
Purpose: general topology, strict hole validation, convexity queries, and test hardening
```

`LogoSC-Experiments.scad` remains a separate lab bench. Keep experimental code there
until behavior is understood and the user explicitly approves promotion into the core.

Stroke experiments completed so far:

1. A reverse-and-append helper converted each outer contour into a doubled-back,
   nominally zero-width polygon. Holes were warned about and discarded.
2. OpenSCAD did not render these degenerate zero-area polygons, even when wrapped in
   `offset()`. Keep this only as a documented negative experiment; it is not a viable
   implementation path.
3. A capsule stroke renderer using `hull()` between circles at consecutive points worked
   and produced visually good round caps, round joins, closed squares, bends, and
   crossings.
4. LogoSC's region evaluator stores `MOVE` destinations but does not include the initial
   turtle point in the first contour. For centerline strokes this initially omitted the
   first segment. Do not modify the evaluator just for strokes. The preferred experimental
   direction is for `RenderCapsuleStrokeRegions()` to optionally prepend a supplied initial
   point to the first nonempty contour. Later pen-generated contours should retain their
   normal semantics.

Current experimental renderer controls include stroke width and circle fragment count.
The exact API is not final.

## 18. Near-term likely next steps

Historical note: this sequence predates the completed debug renderer, invariant tests, optional
validation, and `2026.3` release. Preserve it as decision history; use the current roadmap in
Section 12 for active priorities.

Follow this conservative order:

1. Keep `2026.2` as the known-good baseline.
2. Continue work in `LogoSC-Experiments.scad`; do not edit core stroke APIs yet.
3. Consider a debug path renderer before promoting capsule strokes. A useful
   `DebugLogoPath2D()`-style module would draw small circles at path vertices, thin
   capsule/hull segments between consecutive points, and distinct start/end markers. It
   should help diagnose initial-point handling, `PENUP`/`PENDOWN` path breaks, `PUSH`/`POP`,
   `ARC` tessellation, L-system output, and accidental closure. The user explicitly wants
   to consider this next.
4. Add non-rendering geometry-invariant tests for path point counts, pen breaks, stack
   restoration, arc endpoints, and scaled `RUN` behavior.
5. Create `LogoSC-Strokes-Implementation.md` once the experimental data model and rendering
   behavior are clearer. Document filled regions versus open centerlines, initial-point
   policy, hole behavior, capsule rendering, and the failed zero-width approach.
6. Add additional stroke-oriented L-system examples such as a dragon curve, Hilbert curve,
   or bracketed tree after path extraction/debugging is stable.
7. Promote a public `RenderLogoStroke2D()` API only after the experimental renderer and
   path semantics have been validated. Round caps and round joins are the likely first
   supported behavior.


### 2026-07-11 — Experimental debug renderer design and placement

Previous state:

- Capsule stroke experiments lived in `LogoSC-Experiments.scad`.
- The preferred debug direction was still conceptual: show low-level path behavior before
  promoting any true stroke/open-path API.

Reason for change:

- The user clarified that the immediate goal is debugging only, not manufacturable stroke
  geometry.
- The debug renderer should be easy for downstream clients to use from a single include file,
  so it belongs in `LogoSC-Foundation-Core.scad` rather than a separate optional file.
- It should expose low-level execution behavior: movement, pen-up movement, arc tessellation,
  closed primitive tessellation, `RUN`/`REPEAT`, and stack effects.

Decision:

- Add a preview-only debug event evaluator in the core.
- Use Option B from the design discussion: record command/eval debug events directly rather
  than deriving debug paths from final filled contours.
- Render debug geometry as z-centered 3D capsules and point-marker cylinders.
- Keep the normal filled-region evaluator and `RenderLogo2D()` semantics unchanged.
- Keep Customizer-facing debug toggles in the client/example file because OpenSCAD Customizer
  reliably exposes variables from the opened file, not necessarily from included library files.

Consequences:

- Debug rendering can show pen-up moves, primitive edges, arc tessellation, and command
  endpoints that final contour output intentionally hides or transforms.
- Debug rendering is explicitly preview/diagnostic geometry. It is not a supported STL/export
  or manufacturing path.
- Full README/User Manual/Cheat Sheet documentation should wait until the user verifies the
  OpenSCAD output visually.

Files/API affected:

- `LogoSC-Foundation-Core.scad`
  - `evalLogoDebug()`
  - `ResultDebugSegments()`
  - `ResultDebugPoints()`
  - `RenderLogoDebug()`
  - helper modules for capsule segments and point markers
- `LogoSC-Examples.scad`
  - optional Customizer-controlled debug overlay demo

Follow-up:

- User should verify the debug overlay in OpenSCAD.
- After verification, add compact user-facing documentation and decide whether this remains
  experimental or becomes a versioned public diagnostic API.


### 2026-07-11 — Debug renderer first visual-tuning pass

Previous state:

- The first debug renderer demo proved that the event-based renderer ran in OpenSCAD.
- The demo used one relatively dense crossing example and separate capsule/point visibility
  checkboxes.
- Segment and point defaults were too large for comfortable low-level command inspection.

Reason for change:

- The user wants the debug renderer to be a practical command-level inspection overlay.
- Simple, non-crossing examples make it easier to validate each behavior before combining
  movement, pen-up moves, arcs, and primitives.
- Customizer controls should be grouped with `/* [Heading] */` comments so the OpenSCAD
  Customizer can collapse related parameters.

Decision:

- Keep the debug renderer in `LogoSC-Foundation-Core.scad` and retain the event-based
  Option B implementation.
- Reduce default debug segment and point marker radii to roughly 20% of the first pass.
- Use zero-capable size controls for demo line width and point radius instead of separate
  show/hide checkboxes for segments and points.
- Keep debug geometry z-centered. If radius/size is zero, draw nothing rather than asserting.
- Use a brighter magenta-centered debug palette, with dim magenta pen-up moves and darker
  green `GOTO` segments.
- Make the demo selectable from a small stepped set: triangle, right angle, pen-up gap, arc
  loop, and primitives.

Consequences:

- OpenSCAD Customizer has fewer debug checkboxes and more direct size controls.
- The debug overlay remains preview-only and undocumented in public-facing docs until the
  visual behavior is accepted.
- Existing `RenderLogo2D()` and filled-region behavior remain unchanged.

Files/API affected:

- `LogoSC-Foundation-Core.scad`
  - smaller `RenderLogoDebug()` defaults
  - zero-size tolerant capsule/point marker rendering
  - updated default debug colors
- `LogoSC-Examples.scad`
  - grouped Customizer sections
  - stepped debug demo command lists
  - line-width control mapped to segment radius internally

Follow-up:

- User should verify the smaller magenta overlay, grouped Customizer controls, and each stepped
  demo selection in OpenSCAD.


### 2026-07-11 — Debug renderer naming and pen-up visibility tuning

Previous state:

- The second debug-renderer pass worked in OpenSCAD, but the demo Customizer variable
  names were long because they followed a full `LogoSCDebugDemo*` / `ShowLogoSCDebugDemo*`
  pattern.
- Pen-up move capsules used a dim desaturated magenta that was too dark against the
  OpenSCAD background and hard to distinguish where paths overlap.

Reason for change:

- The debug demo controls live in `LogoSC-Examples.scad`, not the reusable core API, so
  they can be shorter without weakening the library naming convention.
- Pen-up motion is diagnostic information and should be visible but visually secondary.

Decision:

- Keep the public/core debug API names descriptive, especially `RenderLogoDebug()`.
- Shorten only the example/customizer-facing demo variables to compact `DebugDemo*` names.
- Use a pale pink RGBA pen-up color so pen-up movement can be semi-transparent without
  changing the opacity of normal movement, point, start, or end markers.
- Add a `penUpHeightScale` debug-renderer parameter with default `0.75`, making pen-up
  capsules 25% shorter than normal capsules.

Consequences:

- The Customizer is less cluttered and easier to scan.
- Pen-up moves should be easier to see against the OpenSCAD background and less dominant
  when overlapping other debug segments.
- Public filled-region rendering remains unchanged.

Files/API affected:

- `LogoSC-Foundation-Core.scad`
  - `RenderLogoDebugSegments(..., penUpHeightScale = 0.75)`
  - `RenderLogoDebug(..., penUpHeightScale = 0.75)`
  - pale pink semi-transparent default `penUpColor`
- `LogoSC-Examples.scad`
  - shortened debug demo Customizer variables
  - `RenderDebugDemo()` helper name for the example-only demo

Follow-up:

- User should verify whether OpenSCAD preview alpha compositing makes pen-up movement
  clearer; if transparency sorting is visually noisy, keep the pale pink color and tune
  height/radius instead.


### 2026-07-11 — Debug renderer overlap and example tuning

Previous state:

- The shortened `DebugDemo*` controls worked in OpenSCAD.
- The pale pink pen-up color was still too hard to read where it overlapped normal
  movement or primitive debug segments.
- The closed-triangle demo was useful, but it did not expose the distinction between
  turtle endpoint closure and filled polygon closure.
- Primitive and normal movement colors were too similar.

Reason for change:

- Pen-up moves should remain visible in overlaps while still reading as secondary
  diagnostic information.
- Co-located start/end points need to show both markers; otherwise closed paths hide the
  green start marker under the red end marker.
- The debug demo should include side-by-side examples that reveal how the same conceptual
  triangle can be built from turtle movement or from a centered primitive.

Decision:

- Keep pen-up color pale pink but increase its alpha to `0.75`.
- Reduce default pen-up capsule height to 50% of normal segment height.
- Change primitive debug segments to a darker purple so they are clearly separate from
  bright magenta movement segments.
- Render the final debug point 10% wider and 10% shorter than ordinary point markers so
  a closed path shows as a red end cylinder with a green start tip protruding.
- Add an open-triangle demo immediately after the closed-triangle demo. Its final move is
  deliberately short, so the debug endpoint differs from the start while the filled 2D
  polygon still closes visually.
- Add a stroke-vs-primitive triangle demo: one same-size equilateral triangle is built
  from `MOVE`/`TURN`, and another is built as a centered `REGPOLY` primitive.

Consequences:

- Debug overlays should make overlap cases and closed-path endpoints easier to inspect.
- The open-triangle demo exposes an unresolved design question: should filled 2D polygon
  creation keep implicitly closing open contours, or should LogoSC warn/fail/offer explicit
  closure policy controls? Do not fix this blindly; review it separately.

Files/API affected:

- `LogoSC-Foundation-Core.scad`
  - default `penUpColor` alpha changed to `0.75`
  - default `penUpHeightScale` changed to `0.50`
  - default `primitiveColor` changed to darker purple
  - `RenderLogoDebugPointMarkers()` now has end-point radius/height scale parameters
- `LogoSC-Examples.scad`
  - added open-triangle debug demo
  - added stroke-vs-primitive triangle debug demo

Follow-up:

- Verify the endpoint marker layering in OpenSCAD preview.
- Revisit the open-contour/implicit-filled-polygon closure issue after the debug renderer
  behavior is stable.

### 2026-07-11 — Debug renderer crossing-line demo and endpoint tuning

Previous state:

- End-point markers were 10% wider and 10% shorter than normal point markers.
- The debug demo set included closed/open triangles, right-angle movement, pen-up movement,
  an arc loop, primitive examples, and a stroke-vs-primitive triangle.

Reason for change:

- In closed paths, the red end marker could still hide too much of the lime start marker.
- Crossing/self-intersecting contour order is an important LogoSC failure mode. The debug
  overlay should make those accidental crossings obvious before users try to interpret the
  filled 2D result.

Decision:

- Make end-point markers 10% wider and 15% shorter than default point markers. A co-located
  start/end point should read as a red cylinder with a visible lime tip.
- Add a crossed-rectangle demo where the lower two rectangle corners are swapped in path
  order, producing a classic bow-tie/self-intersecting contour.
- Keep this as a debug/demo addition only; do not change contour validation or filled-region
  semantics yet.

Consequences:

- Closed-path start/end co-location should be easier to inspect visually.
- The debug demo set now includes a deliberate crossing-line case for validating that the
  debug renderer exposes unexpected path order.

Files/API affected:

- `LogoSC-Foundation-Core.scad`
  - default `endPointHeightScale` changed from `0.90` to `0.85`
- `LogoSC-Examples.scad`
  - added `ExampleDebugCrossedRectangleCommands`
  - expanded `DebugDemoExample` selections

Follow-up:

- When public docs are updated, add a User Manual section on crossing-line/self-intersecting
  contours and how `RenderLogoDebug()` helps diagnose them.
- Separately revisit whether LogoSC should warn, fail, or provide policy controls for
  self-intersecting or open contours.



### 2026-07-11 — Debug renderer start-marker tuning

Previous state:

- Co-located closed-path start/end markers were handled by making the red end marker
  wider and shorter than the normal point marker.

Reason for change:

- The lime start marker was still harder to see than desired in closed paths.
- Making the start marker taller gives it a cleaner visible tip when the red end marker
  is drawn at the same XY position.

Decision:

- Restore end-point radius and height scales to normal point-marker size.
- Make the start-point marker 15% taller and 5% narrower than ordinary point markers.
- Keep the start marker lime and the end marker red.

Consequences:

- A closed-path co-location should appear as a normal red end cylinder with a narrower
  lime start tip protruding through it.
- The endpoint defaults are simpler again; the special-case visibility rule belongs to
  the start marker.

Files/API affected:

- `LogoSC-Foundation-Core.scad`
  - added `startPointRadiusScale` and `startPointHeightScale` debug point-marker
    parameters
  - restored `endPointRadiusScale` and `endPointHeightScale` defaults to `1.00`

Follow-up:

- Verify marker layering visually in OpenSCAD preview.


## 19. Deferred feature ideas

Potential future features:

- first-class procedures or named command-list helpers;
- variables or parameters in the LogoSC language;
- better reusable shape libraries;
- automatic fillets;
- `ROUNDEDREGPOLY`, but only after defining clear corner-rounding semantics;
- stroke/open-path renderer;
- cap styles: butt, square, round;
- join styles: miter, bevel, round;
- miter limits;
- hole containment/validity checks;
- explicit examples of `offset()` for thickened paths or clearances;
- documentation for slicer/3D-printing tolerances.

Be cautious about wrapping OpenSCAD features unnecessarily. If native OpenSCAD already
composes cleanly around `RenderLogo2D()`, prefer documentation and examples over new LogoSC
opcodes.

## 20. Current user preferences for this project

The user prefers:

- concise but technically precise explanations;
- small surgical edits;
- exact filenames;
- one combined exact-filename update zip containing every changed/added file from the session;
- no unnecessary file variants;
- Git-friendly workflow;
- relative Logo-style commands inside reusable shapes;
- OpenSCAD-native 3D composition outside LogoSC;
- clear documentation and cheat sheets;
- practical 3D-printing examples.

Humor is fine, but keep project artifacts themselves professional and useful.

## 21. Suggested first message in the next chat

The user may say something like:

```text
We are continuing the LogoSC project. Use the uploaded repository zip as the source of
truth. Ignore older versions from prior chats and File Library. Read
LogoSC-Developer-Notebook.md for project handoff notes and LogoSC-Future-Ideas.md for
longer-term feature concepts before making changes.
```

Future assistant: obey that. Do not try to resurrect old sandbox files.


</details>

---

## 16. Journal template for future entries

Use this format for significant changes:

```text
### YYYY-MM-DD — Topic

Previous state:
- ...

Reason for change:
- ...

Decision:
- ...

Consequences:
- ...

Files/API affected:
- ...

Follow-up:
- ...
```


### 2026-07-11 — Unified Customizer run selector

Previous state:

- Separate test, example, and debug variables appeared as top-level Customizer controls.
  This made the examples/test/debug preview setup cumbersome and allowed conflicting
  combinations.

Reason for change:

- Only one automatic preview mode should run at a time: no automatic output, examples,
  debug overlay demo, or tests.
- A string dropdown is easier to scan than several Boolean controls.

Decision:

- Add `LogoSCRunMode` with values `NoDemo`, `Examples`, `Debug`, and `Tests`.
- In `LogoSC-Examples.scad`, default `LogoSCRunMode` to `Examples`.
- In `LogoSC-Foundation-Core.scad`, default the hidden core-only mode to `Tests` so
  opening the core file directly still runs regression tests.
- Keep a hidden compatibility gate derived from `LogoSCRunMode` so older client files
  using the prior test-control convention can still work.

Consequences:

- The Customizer top-level run controls are less cluttered.
- The selected mode is mutually exclusive, avoiding simultaneous examples plus debug
  plus tests.
- Public docs need a follow-up update soon: setup snippets and Cheat Sheet controls
  should describe `LogoSCRunMode` rather than the old separate switches.

Files/API affected:

- `LogoSC-Foundation-Core.scad`
  - hidden default `LogoSCRunMode = str("Tests")`
  - hidden compatibility assignment derived from `LogoSCRunMode`
- `LogoSC-Examples.scad`
  - visible `LogoSCRunMode = "Examples"; // [NoDemo, Examples, Debug, Tests]`
  - automatic rendering branches now test `LogoSCRunMode` directly

Follow-up:

- Verify Customizer behavior in OpenSCAD: exactly one useful top-level run selector should
  be visible, and `NoDemo`, `Examples`, `Debug`, and `Tests` should each do the expected
  thing when opening `LogoSC-Examples.scad`.
- Update README/User Manual/Cheat Sheet after verification.

### 2026-07-12 — Debug demo control cleanup

#### Context

After `LogoSCRunMode` unified the top-level Examples/Debug/Tests selection, the
debug demo still needed one simple way to turn the command-level overlay itself
on or off. The previous crossed-line demo also contained setup moves and pen
commands that made the example look like it had extra points, which obscured the
intended four-corner self-intersection case.

#### Decision

- Add `DebugDemoOverlay` above `DebugDemoFilled` in the `LogoSC Debug Demo`
  Customizer group.
- `DebugDemoOverlay` gates the whole debug overlay: capsules, point markers, and
  related debug visualization objects.
- Keep `DebugDemoFilled` as the independent filled-2D preview toggle.
- Rename the `Right` debug demo option to `Rectangle`.
- Rewrite the crossed-rectangle demo as a four-corner path with no explicit
  `PENUP`/`PENDOWN` commands, using default pen-down behavior and the implicit
  starting turtle point as one rectangle corner.

#### Follow-up

- Public docs should soon describe `LogoSCRunMode`, `DebugDemoOverlay`,
  `DebugDemoFilled`, and the use of crossed-line debug examples to diagnose
  unexpected contour ordering or self-intersections.

### 2026-07-12 — Debug renderer documentation pass

Context:

- The debug renderer, stepped demos, crossed-line demo, start/end marker tuning,
  and unified `LogoSCRunMode` selector have been verified in OpenSCAD.
- Public docs still described the older separate test/example setup and treated
  stroke/debug rendering as future work.

Decision:

- Document `LogoSCRunMode` as the preferred top-level setup selector.
- Document `RenderLogoDebug()` as preview-only diagnostic geometry, not a
  manufacturable stroke/export API.
- Add User Manual guidance for using debug capsules and point markers to diagnose
  crossing/self-intersecting contours, unclosed contours, pen-up motion, and
  primitive-vs-hand-drawn construction.
- Keep implementation internals such as `evalLogoDebug()` lightly documented;
  the main user-facing API is `RenderLogoDebug(cmds, ...)`.

Follow-up:

- Revisit whether LogoSC should warn about open or self-intersecting contours.
  For now, the debug renderer exposes these issues visually without changing
  polygon-generation behavior.

### 2026-07-12 — Quick Start and run-mode guard cleanup

Context:

- The unified `LogoSCRunMode` selector worked, but public setup text still made
  the default/no-demo behavior less clear than desired.
- The README Quick Start still led with a rectangle-with-hole primitive example,
  while the intended first example is a simple `MOVE`/`TURN` turtle path.
- The active legacy test compatibility gate complicated the mental model now that
  `LogoSCRunMode` is the primary run selector.

Decision:

- Use a `MOVE`/`TURN` triangle as the README Quick Start model.
- Add an early README debug-overlay example using `RenderLogoDebug()` on the same
  triangle command list.
- Treat `LogoSCRunMode = "Tests"` as the only active test-run condition.
- Allow `LogoSCRunMode = "NoDemo"`, a blank string, or an undefined run mode to
  suppress the foundation test grid.
- Remove the active legacy test compatibility gate from the core/test code.

Follow-up:

- If external users appear later and need compatibility shims, revisit whether to
  support old run-control variables in a separate migration section. For now,
  there are no known external users, so keeping the selector simple is preferred.


### 2026-07-12 - Quick Start snippet cleanup

Follow-up documentation correction after user verification:

- Ordinary user snippets no longer need `LogoSCRunMode = "NoDemo"`; tests only
  run when `LogoSCRunMode` is explicitly set to `"Tests"`.
- Quick Start extrusion examples should use `center = true` when shown with
  `RenderLogoDebug()`, because debug capsules are z-centered.
- Quick Start debug snippets should use a slightly taller segment height than
  the filled polygon so the overlay remains visible.

### 2026-07-13 — Consolidated 2026.2 release preparation

Context:

- The changelog had accumulated many narrowly scoped `Unreleased` sections covering
  the LogoSC identity transition, debug renderer, unified run selector, documentation,
  branding, licensing, and README screenshots.
- The source already reported development API version `2026.1`, but that version had
  not been consolidated into a formal release entry.

Decision:

- Consolidate the accumulated work into one `2026.2` release entry dated 2026-07-13.
- Advance `LogoSCVersionMinor` from `1` to `2`.
- Treat `2026.1` as an unreleased development snapshot rather than a separate release.
- Add a compact README version-history table.
- Record open-contour validation and manufacturable stroke rendering as distinct future
  work. Preserve the current implicit OpenSCAD polygon closure behavior until an opt-in
  validation policy is designed and tested.

Verification required before packaging:

- Confirm all current version references that describe the active release say `2026.2`.
- Preserve historical notebook references to `2026.1`; do not mechanically rewrite them.
- Confirm every Markdown image reference resolves to a physical file in the package.
- Package all changed files under exact repository paths for unzip-over-repository use.

### 2026-07-13 — Linked Developer Notebook index

#### Context

The Developer Notebook had grown large enough that GitHub's automatic outline was not
always a reliable or convenient navigation mechanism.

#### Decision

- Add a manually maintained index near the top of the notebook.
- Use explicit GitHub-compatible Markdown anchor links.
- Group links by architecture, rendering, debugging, documentation, and release history.
- Keep a compact Quick Links section for the most frequently referenced material.
- Preserve all existing historical content and heading text.

#### Verification

- Verified that each new index target corresponds to an existing notebook heading.
- Kept the change limited to this notebook; no source or public API behavior changed.

### 2026-07-18 — Future ideas filename reference cleanup

Context:

- `LogoSC-Future-Context.md` was renamed to `LogoSC-Future-Ideas.md` and its role is now
  to collect longer-term feature concepts rather than duplicate the Developer Notebook.
- Several current repository file lists still referenced the former filename.

Decision:

- Update live repository inventories and restart guidance to reference
  `LogoSC-Future-Ideas.md` with its current purpose.
- Preserve the former filename where it identifies the historical source of the embedded
  handoff record.

Files affected:

- `README.md`
- `LogoSC-README.md`
- `LogoSC-User-Manual.md`
- `LogoSC-Developer-Notebook.md`

### 2026-07-18 — Legacy test-control reference cleanup

Context:

- Active source and public documentation use `LogoSCRunMode` as the sole selector for
  examples, debug output, and tests.
- The Developer Notebook still contained obsolete setup guidance and literal references
  to the removed test-control variable, including some statements presented as current.

Decision:

- Remove stale setup instructions and current-state claims for the retired variable.
- Rephrase dated history in generic terms so the sequence of decisions remains intact
  without retaining obsolete identifiers or copyable setup snippets.
- Keep the current rule explicit: tests run only when `LogoSCRunMode == "Tests"`.

Files affected:

- `LogoSC-Developer-Notebook.md`
- `CHANGELOG.md`

### 2026-07-18 — Contributor guide integration

Context:

- A root `CONTRIBUTING.md` was supplied to make the project's contribution philosophy,
  API-stability expectations, coding conventions, documentation, testing, versioning,
  and packaging workflow easier to find.
- The supplied repository structure used an outdated test filename, and its versioning
  section treated the derived version string as an independently edited value.

Decision:

- Add `CONTRIBUTING.md` at repository root and reference it from the README files, User
  Manual, changelog, Developer Notebook bootstrap sequence, and documentation-role list.
- Correct the test filename to `LogoSC-Foundation-Tests.scad`.
- Document the full stable generic API set and refer to existing command opcodes without
  introducing project-name-specific replacements.
- Treat `LogoSCVersion` as derived from `LogoSCVersionMajor` and `LogoSCVersionMinor`.
- Keep significant decisions in the Developer Notebook and longer-term concepts in
  `LogoSC-Future-Ideas.md`.

Files affected:

- `CONTRIBUTING.md`
- `README.md`
- `LogoSC-README.md`
- `LogoSC-User-Manual.md`
- `LogoSC-Developer-Notebook.md`
- `CHANGELOG.md`

### 2026-07-18 — 2026.2 release identifier cleanup

Context:

- The current source, README, User Manual, and changelog identify the release as
  `2026.2`.
- Older Developer Notebook baseline text still described a pre-release GitHub tag as the
  current published baseline, creating two competing release identifiers.

Decision:

- Use `2026.2` as the sole current LogoSC release identifier.
- Remove the obsolete tag name and tag URL from current and embedded baseline guidance.
- Preserve the valid `2026.0` changelog entry as earlier LogoSC version history.

Files affected:

- `LogoSC-Developer-Notebook.md`
- `CHANGELOG.md`

### 2026-07-18 — AI Engineering Kit integration

Status:

- Superseded later the same day by the AI Engineering Kit directory cleanup. The files now
  live under `docs/ai-engineering-kit/` and are described as maintainer-facing companion
  material.

Context:

- Five reusable AI engineering-process documents were supplied after the current LogoSC
  session began: one handoff note and a four-document workflow kit.
- The documents normally recommend living outside project repositories, but explicitly
  allow repository inclusion when the user requests it.
- The user requested repository references and descriptions for these documents, providing
  the explicit exception required by their own guidance.

Decision:

- Store all five documents at repository root as companion/private process material.
- Read `AI-Engineering-Kit-Handoff.md` first, followed by
  `Generic-Project-Bootstrap.md`, `ChatGPT-Project-Workflow.md`,
  `Engineering-Preferences.md`, and `Project-Retrospective.md`.
- Keep explicit user instructions and current LogoSC project guidance authoritative over
  generic kit preferences.
- Describe the kit in README files, User Manual, CONTRIBUTING guide, changelog, and this
  notebook without presenting it as LogoSC public API or ordinary user documentation.

Files affected:

- `AI-Engineering-Kit-Handoff.md`
- `Generic-Project-Bootstrap.md`
- `ChatGPT-Project-Workflow.md`
- `Engineering-Preferences.md`
- `Project-Retrospective.md`
- `README.md`
- `LogoSC-README.md`
- `LogoSC-User-Manual.md`
- `CONTRIBUTING.md`
- `LogoSC-Developer-Notebook.md`
- `CHANGELOG.md`

### 2026-07-18 — AI Engineering Kit directory cleanup

Context:

- The five AI Engineering Kit files were initially added at repository root.
- Root placement made generic AI-process material appear alongside LogoSC's primary source,
  public documentation, and project-specific engineering files.
- Because the repository may be public, describing tracked files as private was also
  misleading.

Decision:

- Move all five files into `docs/ai-engineering-kit/` while preserving their exact filenames.
- Use `docs/ai-engineering-kit/AI-Engineering-Kit-Handoff.md` as the entry point for a fresh
  AI-assisted development conversation.
- Describe the kit as maintainer-facing companion material, not private material or LogoSC
  public API documentation.
- Update all live inventories, reading orders, links, descriptions, and changelog paths.
- Preserve the earlier root-placement decision above as superseded history.

Files affected:

- `docs/ai-engineering-kit/AI-Engineering-Kit-Handoff.md`
- `docs/ai-engineering-kit/Generic-Project-Bootstrap.md`
- `docs/ai-engineering-kit/ChatGPT-Project-Workflow.md`
- `docs/ai-engineering-kit/Engineering-Preferences.md`
- `docs/ai-engineering-kit/Project-Retrospective.md`
- `README.md`
- `LogoSC-README.md`
- `LogoSC-User-Manual.md`
- `CONTRIBUTING.md`
- `LogoSC-Developer-Notebook.md`
- `CHANGELOG.md`

### 2026-07-18 — Documentation consistency and release-boundary cleanup

Context:

- `main` contained documentation and maintainer-process additions made after the
  `v2026.2` release tag, while the changelog described them inside the tagged release.
- `RenderLogoDebug()` was documented and released as public but was absent from the
  stable-API inventories.
- Live notebook roadmap text still described the completed debug renderer as future work.
- The User Manual had duplicate section numbering, broken recursion links, and an
  incomplete tracked-file inventory.

Decision:

- Record post-tag documentation and process work under `Unreleased` without rewriting or
  moving the existing `v2026.2` tag.
- Classify `RenderLogoDebug()` as a stable public diagnostic API while keeping it strictly
  preview-only and separate from future manufacturable stroke rendering.
- Update current checkpoint and roadmap material while preserving dated historical entries.
- Repair the User Manual navigation and inventory without renaming project files or changing
  runtime APIs.

Files affected:

- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `LogoSC-Developer-Notebook.md`
- `LogoSC-User-Manual.md`

### 2026-07-19 — Codex Git workspace and AGENTS guidance

Context:

- The local Codex workspace was confirmed to edit the actual Git working tree directly.
- The existing AI Engineering Kit explained repository-first collaboration in detail but
  lacked a short, reusable setup guide for starting a new local Git project.
- LogoSC also lacked a root `AGENTS.md` containing its durable agent-facing rules.

Decision:

- Add `docs/ai-engineering-kit/Codex-Git-Project-Quick-Start.md` as the concise general
  setup and daily-use entry point.
- Add root `AGENTS.md` for LogoSC-specific authority, reading order, project boundaries,
  verification, Git safety, and delivery requirements.
- Keep detailed architecture and historical rationale in the existing project documents;
  the agent guide links to them rather than duplicating them.
- Treat direct working-tree edits as the primary local workflow while retaining the single
  repository-relative ZIP as a verified backup or transfer artifact.

Files affected:

- `AGENTS.md`
- `docs/ai-engineering-kit/Codex-Git-Project-Quick-Start.md`
- `docs/ai-engineering-kit/AI-Engineering-Kit-Handoff.md`
- `docs/ai-engineering-kit/Engineering-Preferences.md`
- `docs/ai-engineering-kit/Generic-Project-Bootstrap.md`
- `README.md`
- `LogoSC-README.md`
- `LogoSC-User-Manual.md`
- `CONTRIBUTING.md`
- `LogoSC-Developer-Notebook.md`
- `CHANGELOG.md`

### 2026-07-19 — Evaluator-invariant validation suite

Context:

- Existing regression coverage combined visual geometry tests with focused non-rendering checks
  for arcs, closed primitives, and holes.
- `PUSH`/`POP`, pen-state transitions, scaled `RUN`, and `REPEAT` behavior were exercised
  visually but did not all assert the complete public `EvalResult` contract.
- Open paths are not currently supported. They are expected future work, so current tests must
  not imply that incomplete filled-region contours are a supported open-path representation.

Decision:

- Add a non-rendering `TestEvaluatorInvariantSuiteLogo()` to
  `LogoSC-Foundation-Tests.scad`.
- Validate final state, exact raw region/ring lengths including empty mutable regions, stack
  contents, and pen state through the stable public result accessors.
- Cover `PUSH`, `POP`, `PENUP`, `PENDOWN`, scaled `RUN`, and `REPEAT` as the initial invariant
  baseline.
- Keep the helper and suite extensible so contour-validation and open-path invariants can be
  added deliberately without changing the focused existing tests.

Consequences:

- Evaluator regressions can be detected independently of OpenSCAD rendering behavior.
- The suite records current filled-region result semantics before contour validation is added.
- No public API, command behavior, or rendering behavior changes in this step.

Files affected:

- `LogoSC-Foundation-Tests.scad`
- `CHANGELOG.md`
- `LogoSC-Developer-Notebook.md`

Follow-up:

- Design optional contour validation against this baseline.
- Expand the suite when LogoSC gains an explicit open-path data model and validation contract.

### 2026-07-20 — OpenSCAD command-line verification guide

Context:

- The Windows OpenSCAD installation includes `openscad.com`, a console wrapper that can run
  `.scad` files without opening the GUI and expose diagnostics and process status to PowerShell.
- The new evaluator-invariant suite was successfully exercised through that interface.
- Command-line PNG export was also verified by rendering and inspecting the closed-triangle
  debug demo.
- The workflow was useful enough to preserve as repository documentation rather than leaving it
  as conversation-only knowledge.

Decision:

- Add `LogoSC-OpenSCAD-Command-Line.md` as a concise maintainer-facing guide.
- Include tested examples for version/help discovery, `.echo` regression diagnostics, PNG debug
  previews, and STL export.
- Explain the distinction between automated evaluation evidence and interactive or human visual
  verification.
- Link to OpenSCAD's official documentation portal, command-line manual, full User Manual PDF,
  and Customizer documentation.
- Reference the guide from the normal repository inventories, contributor/testing guidance,
  User Manual setup material, and agent verification instructions.

Consequences:

- Future maintainers and AI-assisted sessions can reproduce the command-line verification flow.
- LogoSC tests can be evaluated and their diagnostics inspected even when the OpenSCAD GUI is
  not being controlled interactively.
- PNG previews provide a practical first-pass visual check, while important Customizer and
  manufacturing decisions still require appropriate interactive or human review.

Files affected:

- `LogoSC-OpenSCAD-Command-Line.md`
- `AGENTS.md`
- `README.md`
- `LogoSC-README.md`
- `LogoSC-User-Manual.md`
- `CONTRIBUTING.md`
- `CHANGELOG.md`
- `LogoSC-Developer-Notebook.md`

### 2026-07-20 — Indexed debug-renderer gallery

Context:

- `LogoSCRunMode = "Debug"` rendered only the selected `DebugDemoExample`.
- `RenderDebugDemo()` retained a fixed `[2, 2]` default index from the earlier period when
  examples, debug output, and tests could be enabled together.
- The fixed index became misleading after run modes became mutually exclusive, and repeated
  OpenSCAD recompilations could look like multiple examples sharing one cell.

Decision:

- Add `DebugDemoLayout` with `Gallery` as the default and `Selected` as the focused view.
- Map debug examples 0 through 7 to a stable four-column by two-row logical grid.
- Pass the example number explicitly into `RenderDebugDemo()` so every gallery call reports
  its own index, offset, and example value.
- Retain `DebugDemoExample` for choosing the case rendered by the selected layout.

Consequences:

- Debug mode now provides an immediate all-cases visual overview.
- Console diagnostics map unambiguously to the displayed debug cell.
- Selected mode renders its one case at the first grid cell, avoiding the stale `[2, 2]`
  placement while preserving focused inspection.

Files affected:

- `LogoSC-Examples.scad`
- `README.md`
- `LogoSC-README.md`
- `LogoSC-User-Manual.md`
- `LogoSC-CheatSheet.md`
- `LogoSC-OpenSCAD-Command-Line.md`
- `CHANGELOG.md`
- `LogoSC-Developer-Notebook.md`

### 2026-07-20 — Standalone Core and optional companion boundary

Context:

- `LogoSC-Foundation-Core.scad` unconditionally included the regression-test definitions,
  even though test execution was guarded by `LogoSCRunMode`.
- OpenSCAD resolves `include <>` at parse time, so a model using Core still needed the test
  file to be physically present.
- Planned contour validation is useful core-adjacent functionality, but optional validation
  should not create another physical dependency for basic LogoSC models.

Decision:

- Make `LogoSC-Foundation-Core.scad` a standalone library entry point with no companion
  includes.
- Keep `LogoSC-Foundation-Tests.scad` as passive test definitions with no automatic execution.
- Add `LogoSC-Foundation-Test-Runner.scad` to assemble Core and the tests and run the complete
  suite directly.
- Preserve `LogoSC-Examples.scad` test mode by explicitly loading the passive test definitions
  and calling `RunAllLogoSCTests()` only when `LogoSCRunMode == "Tests"`.
- Implement future path analysis and contour validation in the optional
  `LogoSC-Foundation-Validation.scad` companion.
- Put its focused tests in `LogoSC-Foundation-Validation-Tests.scad` and assemble both future
  files through the test runner rather than Core.
- Do not publish validation API names until the path-record model and closure semantics have
  been designed and tested.

Consequences:

- Basic LogoSC use requires only `LogoSC-Foundation-Core.scad`.
- Opening Core directly no longer runs tests; maintainers open the test runner instead.
- Examples, Debug, and Tests modes remain available from `LogoSC-Examples.scad`.
- Optional features can be maintained in smaller files without turning them into mandatory
  dependencies or expanding the already large Core source.

Files affected:

- `LogoSC-Foundation-Core.scad`
- `LogoSC-Foundation-Tests.scad`
- `LogoSC-Foundation-Test-Runner.scad`
- `LogoSC-Examples.scad`
- setup, testing, inventory, changelog, and roadmap documentation

### 2026-07-20 — Optional path analysis and validation

Context:

- Filled-region evaluation does not retain the first turtle point in a contour and cannot
  reliably reconstruct explicit path closure, pen boundaries, or primitive boundaries.
- OpenSCAD `polygon()` still closes a path implicitly, so changing Core evaluation would risk
  altering established filled output merely to support diagnostics.
- The previous architecture decision reserved validation for an optional companion so basic
  LogoSC models continue to require only Core.

Decision:

- Add `LogoSC-Foundation-Validation.scad`, included after Core, with a dedicated recursive
  path evaluator that reuses Core's simple debug-opcode evaluation while preserving
  `PENUP`/`PENDOWN`, `RUN`, `REPEAT`, `HOLE`, and stack discontinuities as explicit paths.
- Represent each path as `[role, kind, points, sourceOpcode, explicitlyClosed]`. Retain the
  initial turtle point and the repeated closing endpoint of primitives.
- Publish `evalLogoPaths()`, `ValidateLogoPaths()`, `ReportLogoValidation()`, and accessors
  for path results, path records, validation results, and validation issues.
- Detect open paths, paths with fewer than three usable vertices, and zero-length segments.
  Use a configurable default tolerance of `0.001` for closure and segment comparison.
- Keep validation opt-in. Do not change `LogoSC-Foundation-Core.scad`, `evalLogo()`,
  `RenderLogo2D()`, or current implicit polygon closure.
- Add passive focused tests and assemble them through the existing test runner and the explicit
  Examples `Tests` mode.

Consequences:

- Users can inspect and validate the path actually drawn without confusing it with the filled
  region later consumed by `polygon()`.
- Warning-only reporting supports investigation, while `strict = true` stops OpenSCAD
  evaluation with an assertion without imposing new behavior on existing models.
- Basic LogoSC use remains a one-file include. Validation users add one optional companion.
- Self-intersection, tiny-edge, duplicate nonconsecutive point, hole-containment, and hole-overlap
  checks remain future extensions to the same validation result model.

Files affected:

- `LogoSC-Foundation-Validation.scad`
- `LogoSC-Foundation-Validation-Tests.scad`
- `LogoSC-Foundation-Test-Runner.scad`
- `LogoSC-Examples.scad`
- public, contributor, changelog, roadmap, and maintainer documentation

### 2026-07-20 — Hierarchical automated test results

Context:

- OpenSCAD modules cannot append failures to a mutable global list, and the existing
  `LogoCheck()` helper only echoed errors as each check ran.
- An unconditional success message would therefore have been unreliable, while using
  assertions would stop at the first failure and hide whether a regression was local or broad.
- The failure-condition row intentionally emits Core `[ERROR]` diagnostics, so counting all
  error lines cannot distinguish expected behavior from failed tests.

Decision:

- Represent each automated outcome as immutable `[name, passed, detail]` data.
- Represent a suite as `[suiteName, testResults]`, with accessors and pure functions for
  filtering failures and computing pass counts.
- Collect 130 Foundation results and 21 Validation results in the current suite. These counts
  are descriptive rather than contractual and should grow as coverage expands.
- Treat geometry rows as automated smoke checks for whether expected polygon data was or was
  not produced, while retaining their visual grid for manual regression inspection.
- Preserve detailed evaluator, arc, closed-shape, hole, and path-validation checks as named
  immutable results rather than immediate soft assertions.
- Bound intentional Core error diagnostics with explicit expected-error `BEGIN` and `END`
  markers. Do not count those messages as test failures.
- Use a dynamically scoped, test-only suppression flag while expected-error result records are
  examined. This avoids repeating the same diagnostic whenever OpenSCAD reevaluates an
  immutable expression; the visual failure row still emits each diagnostic once.
- Add `LogoTestReportLevel`: level `0` reports only the global result, level `1` adds suite
  totals and every failure, and level `2` lists every named test result.
- End complete runs with one machine-readable `LOGOSC_AUTOMATED_TEST_RESULT` containing suite,
  test, pass, and failure totals. Continue through every result-producing test even after a
  failure.
- Keep complete accumulation as the default, but add opt-in `LogoTestFailFast` diagnosis at the
  immutable result constructor. A failed assertion includes the test name and detail record;
  OpenSCAD supplies the assertion file/line and caller trace without manually maintained source
  metadata. Keep the passive test-file default for direct and third-party runners, and expose an
  Examples-file override in the `LogoSC Run` Customizer section for interactive testing.
- End failed aggregate reports with `*** Test Suite Failed ***` after the structured result and
  closing divider. This banner is deliberately redundant for humans; automation continues to
  use `LOGOSC_AUTOMATED_TEST_RESULT`.

Consequences:

- A single final `PASS` now proves that both automated suites ran and every recorded check
  passed, without relying on mutable state or fail-fast assertions.
- A failing run reports all recorded failures and shows whether they are concentrated in one
  suite or distributed across both suites.
- A maintainer can temporarily enable fail-fast mode to isolate the first evaluated regression,
  then disable it to confirm the full two-suite outcome. Helper-generated cases may trace through
  common functions, so the assertion message always carries the stable test name.
- Fail-fast evaluation can abort before the aggregate banner, so the assertion itself remains
  the diagnostic signal in that mode.
- The automated result does not replace manual inspection of visual geometry; it reports the
  encoded smoke tests and invariants precisely.
- Normal Core behavior is unchanged because diagnostic suppression defaults to false and is
  enabled only inside expected-error result evaluation.

Files affected:

- `LogoSC-Foundation-Tests.scad`
- `LogoSC-Foundation-Validation-Tests.scad`
- `LogoSC-Foundation-Test-Runner.scad`
- `LogoSC-Examples.scad`
- testing, command-line, changelog, contributor, and maintainer documentation

### 2026-07-20 — Examples and regression gallery screenshots

Context:

- The repository documented the Examples and Tests run modes but did not show their complete
  gallery output.
- Two manually captured OpenSCAD previews now show the current Examples run and the visual
  regression grid associated with the 151 named automated results.

Decision:

- Store the captures as `images/examples-gallery.png` and
  `images/regression-test-gallery.png` using stable, descriptive names.
- Show the Examples image where the public docs describe basic geometry, holes, native linear
  and rotational extrusions, and recursive L-system-inspired models.
- Show the regression image where maintainer and submission docs describe the visual suite.
- Keep the automated-result distinction explicit: the gallery supports visual inspection,
  while `LOGOSC_AUTOMATED_TEST_RESULT` remains the machine-readable pass/fail authority.

Files affected:

- `images/examples-gallery.png`
- `images/regression-test-gallery.png`
- `README.md`
- `LogoSC-README.md`
- `LogoSC-User-Manual.md`
- `LogoSC-OpenSCAD-Command-Line.md`
- `README_BUILDWEEK.md`
- `CHANGELOG.md`
- `LogoSC-Developer-Notebook.md`

### 2026-07-21 — Direct Git delivery and conditional ZIP fallback

Context:

- The original ChatGPT workflow exchanged changed files through downloads and ZIP archives.
  One exact-path ZIP per session was safer than multiple individual downloads in that
  environment.
- Codex now edits the user's actual LogoSC Git working tree. The same changes are immediately
  visible through ordinary Git status and diff tools, so routine transfer ZIPs duplicate the
  working tree without improving delivery.
- Future AI sessions may still run without Git, receive only uploaded files, or work in a
  temporary copy that the user cannot inspect directly.

Decision:

- Detect direct integration from evidence: `git rev-parse --show-toplevel` succeeds, the root
  matches the repository in scope, `git status` and `git diff` show the edited files, and the
  user can review the persistent working tree.
- In that environment, use the working tree as delivery and do not create a ZIP unless the user
  asks for one.
- Preserve the existing one-combined-ZIP procedure as a fallback when Git is unavailable,
  integration cannot be verified, work occurs in a temporary or attachment-based copy, or the
  user explicitly requests an archive.
- Direct Git access does not authorize staging, committing, pushing, rewriting history, or
  moving tags. Those actions still require an explicit request.
- Verification remains mandatory in either delivery mode: review tests or documentation checks,
  `git diff`, `git status`, links, assets, and expected files as appropriate.

Consequences:

- Codex sessions avoid redundant archive generation and use the user's normal Git workflow.
- The bootstrap and AI Engineering Kit retain portable transfer instructions for environments
  without direct repository integration.
- Historical ZIP rules remain in older notebook entries as context; this dated decision and the
  live workflow sections supersede them as the current default.

Files affected:

- `AGENTS.md`
- `CONTRIBUTING.md`
- `README.md`
- `LogoSC-README.md`
- `LogoSC-Developer-Notebook.md`
- `CHANGELOG.md`
- AI Engineering Kit handoff, quick-start, bootstrap, workflow, preferences, and retrospective
  documents

### 2026-07-21 — Debug renderer gallery screenshot

Context:

- The indexed Debug run was documented, but the repository showed only the focused Quick Start
  triangle overlay rather than the complete eight-case gallery.
- A manually captured OpenSCAD preview now shows the current two-row Debug gallery with filled
  output, movement capsules, point markers, pen-up travel, crossings, arcs, and primitive paths.

Decision:

- Store the capture as `images/debug-renderer-gallery.png` using the same stable naming pattern
  as the Examples and regression gallery images.
- Reference it where public, testing, and submission documentation explains the full Debug run.
- Continue to describe `RenderLogoDebug()` as preview-only diagnostic geometry, not a
  manufacturable stroke API.

Files affected:

- `images/debug-renderer-gallery.png`
- `README.md`
- `LogoSC-README.md`
- `LogoSC-User-Manual.md`
- `LogoSC-OpenSCAD-Command-Line.md`
- `README_BUILDWEEK.md`
- `CHANGELOG.md`
- `LogoSC-Developer-Notebook.md`

### 2026-07-21 — OpenSCAD examples run guide screenshot

Context:

- The Build Week two-minute instructions named the required file, run mode, and preview action,
  but a first-time OpenSCAD user still had to locate those controls in the complete window.
- A manually annotated screenshot identifies the selected `LogoSC-Examples.scad` tab, the
  `LogoSCRunMode = Examples` Customizer value, and the Preview button.

Decision:

- Store the screenshot as `images/openscad-examples-run-guide.png`.
- Place it directly after the visual-example steps in `README_BUILDWEEK.md` and explain annotations
  1, 2, and 3 in adjacent text so the instructions do not depend on handwriting alone.

Files affected:

- `images/openscad-examples-run-guide.png`
- `README_BUILDWEEK.md`
- `CHANGELOG.md`
- `LogoSC-Developer-Notebook.md`

### 2026-07-21 — Customizable nuts, bolts, and helical thread profiles

Context:

- The original practical motivation for LogoSC was reusable manufacturing profiles, and the
  Build Week follow-up identified a small family of nuts and bolts as the next demonstration.
- Common fastener threads begin as recognizable axial/radial profiles, but OpenSCAD's twisted
  `linear_extrude()` consumes a profile in the XY plane rather than that conventional section.
- A directly translated tooth gives only a tangential approximation and can distort the
  intended axial profile, especially at small diameters or coarse pitches.

Decision:

- Add `LogoSC-Nuts-And-Bolts.scad` as a standalone Customizer-driven model rather than expanding
  the stable Core API.
- Define conventional V, rounded Whitworth, ACME, ISO trapezoidal, buttress, and square ridge
  profiles as LogoSC command lists.
- Evaluate and resample the LogoSC contour, then map each axial/radial point into a polar XY seed
  whose phase is the inverse of the later helical twist. This makes an axial section of the
  finished helix reproduce the source profile more faithfully.
- Use native OpenSCAD twisted extrusion for right- or left-hand and multi-start threads, union a
  helical ridge with a cylindrical core for external threads, and subtract a radially enlarged
  matching threaded solid for internal nut threads.
- Use LogoSC regular polygons, circles, and rectangles for hex heads, nut bodies, pan and flat
  heads, Phillips recesses, and slots. Keep head extrusion and all 3D booleans in OpenSCAD.
- Define `PrintSlop` as radial clearance per side on the female thread cutter. Treat all supplied
  thread forms and head proportions as printable approximations, not certified standard fits.

Verification:

- Exported all six selected 2D profile families successfully as STL.
- Fully rendered default, short bolt, nut, Phillips, slotted, and slotted-flat configurations.
- Verified representative bolt and nut STL meshes were connected and had no nonmanifold edges.
- Previewed a matching bolt/nut assembly and confirmed the nut phase tracks its axial position.
- Ran the complete Foundation and Validation suites: 151 of 151 automated results passed.

### 2026-07-21 — Fastener Customizer head, drive, and boolean refinement

Context:

- The first fastener UI combined external head shapes with internal drive features, preventing
  combinations such as a pan head with either a slot, Phillips recess, or hex socket.
- Slotted and Phillips recesses also needed more recognizable geometry, and coincident cutter
  endpoints could produce unstable OpenSCAD preview surfaces.

Decision:

- Separate `HeadType`, `DriveType`, and `DriveSize`. Treat `#0` through `#5` as explicitly
  type-specific printable presets because slot width, Phillips span, and hex across-flats are
  different dimensions, not one universal millimeter recess size.
- Provide hex, pan, round, countersunk flat, carriage, and grub/headless shapes; provide none,
  slotted, Phillips, and hex-socket drives. Make slots span the full top and taper Phillips arms
  inward through their depth.
- Add `FastenerDifferenceTolerance = 0.01 + 0` and overrun every subtractive feature at both
  exposed ends, including nut thread and entry-chamfer cutters.
- Expand practical large-print presets through M36 and 1-8, increase the three default mesh
  resolutions by exactly 25 percent and double their upper ranges, and add a flat full-pitch pad
  behind the selected thread bump.
- Add `LogoSC-Nuts-And-Bolts-Customizer.md` as the detailed source for parameter semantics,
  type-specific drive mappings, standards context, and print calibration.

### 2026-07-22 — Fastener gallery, headless drive, and chamfer refinement

Context:

- The headless drive was cut at Z=0, which placed it on the normally hidden end of the displayed
  model even though the cutter itself rendered correctly.
- Abruptly clipping an external helix at the bearing plane could leave thin thread fragments.
  Nut entry chamfers were automatic, larger than necessary, and disconnected from Customizer
  control.
- Individual Customizer outputs made the supported fastener family harder to survey quickly.

Decision:

- Put grub/headless recesses at the free shaft end and reverse the recess extrusion inward.
- Apply `TipChamfer` to both ends of external threads and to both nut entries. Limit the nut
  chamfer by pitch and nut thickness; the default M8 nut consequently drops from 1.25 to 0.6 mm.
- Add `Gallery (Slow!)` output with six representative bolt/screw styles and two nuts in a
  four-by-two grid, using parameterized bolt and nut modules so gallery choices do not mutate
  user settings.
- End the Customizer guide with a prominent warning that printed fastener strength is unknown
  and real-world use requires engineering review and representative destructive load testing.
- Document exactly how every profile is simplified, including the implemented pitch-relative
  depth, crest, radius, and flank values and the standard fit/tolerance features intentionally
  omitted.
- Generate six profile and six head images from the actual OpenSCAD model. Add a 1600-by-1000
  M20 assembly preview using four times the default geometry settings: 240 radial segments,
  60 slices per turn, and 100 profile samples per turn.
- Record the measured performance distinction: the gallery preview PNG took about 1 second,
  while a full default-resolution gallery STL took about 3 minutes 22 seconds on the maintainer
  workstation. Label the gallery as slow in the Customizer.
- Add the exact high-resolution assembly PNG command to `LogoSC-OpenSCAD-Command-Line.md`, using
  `-D` Customizer overrides, explicit camera and pixel options, a preview-versus-CGAL explanation,
  exit-code handling, and stopwatch timing.

### 2026-07-22 — Printed-fastener strength comparison

Context:

- A warning that strength is unknown states the correct conclusion, but it does not give readers
  an intuitive sense of the gap between an upright FFF print and an ordinary steel fastener.
- Quoting a single load as though it were a bolt rating would be misleading because the available
  manufacturer data describe printed material coupons rather than LogoSC threads, heads, nuts,
  or complete joints.

Decision:

- Add an explicitly non-rated, order-of-magnitude comparison for coarse M8×1.25 and M12×1.75
  threads under idealized pure tension and pure single shear.
- Compute the threaded tensile-stress area as `pi/4 * (d - 0.9382P)^2`, giving 36.61 and
  84.27 square millimeters respectively.
- Use one manufacturer's published Z-axis tensile-at-break values for printed PLA, PETG, and ABS
  so the polymer rows share a consistent source and represent the across-layer direction of a
  bolt printed upright.
- Compare those coupon-based values with nominal property-class 8.8 steel at 800 MPa. Estimate
  shear at 0.6 times tensile, clearly identifying the polymer use of that ratio as an
  extrapolation rather than measured shear data or an ISO requirement.
- Put the comparison under the final strength warning and state that its predicted break loads
  omit preload, thread and nut stripping, head failure, infill, defects, creep, fatigue,
  environment, combined loads, and safety factors. Direct readers to destructive testing of the
  exact production process or to a specified manufactured fastener, not to a reduced table value.

Consequences:

- The guide now quantifies why printed fasteners must not be selected for critical service from
  material datasheets alone while preserving the stronger conclusion that their actual strength
  remains unknown until representative testing.
- This is documentation-only; it does not change the OpenSCAD model or LogoSC public API.

### 2026-07-22 â€” Fastener algorithm documentation and mapping figure

Context:

- The fastener guide documented controls, simplified profiles, calibration, performance, and
  safety, but it did not trace how the axial/radial LogoSC contour becomes the polar seed for
  OpenSCAD's twisted extrusion.
- The multi-start behavior was described at the parameter level without identifying the phase
  copies, the `nStarts` role in lead, or the main implementation routine and variables.
- A profile export command was mentioned in the general command-line guide but was not given as
  a complete tested recipe.

Decision:

- Make `RenderFastenerThreadRidge()` the documented main subroutine and trace its calls through
  `FastenerProfilePoints()`, `FastenerLogoPath()`, `RenderFastenerThreadSeed()`,
  `FastenerResampleContour()`, and `FastenerWrapPoint()`.
- Use `nStarts` as the algorithmic name for the Customizer's `ThreadStarts` and the ridge
  module's `starts` argument. Record `lead = pitch * nStarts` and the
  `i * 360 / nStarts` phase rotation explicitly.
- Document the point mapping, slice equations, overrun and clipping behavior, and the nominal
  `O(s * n * k)` ridge-mesh cost for `s = nStarts`, `n` sampled seed points, and `k` slices.
  Keep CGAL boolean complexity separate because it depends on geometry and implementation.
- State the implementation boundary directly: native OpenSCAD calculates the profile points;
  LogoSC expands and evaluates the closed 2D contour; native OpenSCAD then resamples, wraps,
  extrudes, and performs booleans. Show the actual symbolic LogoSC command list rather than only
  naming `FastenerLogoPath()` and `evalLogo()`.
- Add `Algorithm Figure` output to the standalone fastener model, plus the space-free
  command-line alias `Algorithm` for OpenSCAD 2021.01 on Windows.
- Generate `images/fastener-thread-wrapping-three-start.png` from the actual LogoSC evaluation
  and polar-mapping routines. The left panel shows three pitch-spaced axial profiles; the right
  panel shows their three 120-degree-spaced polar seeds, equivalent to the unextruded input
  slice. Mark the exact resampled contour points and label the 28-samples-per-start result.
- Echo the generated point and LogoSC command arrays from `Profile` mode, report contour and
  sample totals from `Algorithm Figure`, and add exact tested PowerShell commands for the echo,
  normal profile PNG, and mapping figure.

Consequences:

- Readers can connect the visual geometry, equations, implementation names, and Customizer
  controls without reverse-engineering the OpenSCAD source.
- The figure remains reproducible from the model and changes with the selected profile, size,
  handedness, and number of starts rather than becoming a detached hand-drawn diagram.
- LogoSC Core and its stable public API remain unchanged; the new output belongs only to the
  standalone fastener demonstration.

### 2026-07-22 — Duplicate-point and tiny-edge validation

Context:

- The optional validator detected open paths, too-few-points paths, and zero-length segments,
  but it did not distinguish small nonzero edges or repeated nonadjacent vertices.
- Advanced validation is useful for complicated contours, but ordinary LogoSC models should
  continue to require only the standalone Core file.
- Self-intersection/crossing analysis is planned next and may be substantially more expensive
  than the basic per-path checks.

Decision:

- Keep all validation outside Core in `LogoSC-Foundation-Validation.scad`; users opt in with an
  explicit second include rather than relying on a missing-file probe.
- Add duplicate nonconsecutive-point detection using the validation tolerance. Exclude the
  legitimate repeated first/last point of a closed contour and expose matching index pairs for
  diagnosis.
- Add tiny-edge detection for segments not classified as zero-length under the tolerance and no
  longer than `tinyEdgeThreshold`, defaulting to `0.01`. Allow zero to disable the check.
- Append the new threshold to existing validation result and call signatures so older positional
  arguments retain their meaning. Reserve self-intersection as a later optional validator built
  on the same explicit paths rather than adding it to Core.

Consequences:

- Basic users still include only `LogoSC-Foundation-Core.scad`; validation users explicitly add
  the companion file.
- The complete automated suite now contains 157 immutable results, all passing after this change.

### 2026-07-22 — Proper self-intersection validation

Context:

- Debug rendering made crossings visible but did not provide a machine-readable validation
  result.
- The explicit path representation already preserves the real consecutive segments, including
  pen boundaries and primitive closure, without inventing OpenSCAD's implicit closing edge.
- A sweep-line algorithm offers a better asymptotic bound but requires event queues, active-set
  ordering, and difficult degeneracy handling that are disproportionate in OpenSCAD.

Decision:

- Add `LOGO_VALIDATION_SELF_INTERSECTION` and enable proper within-path crossing checks by
  default whenever users explicitly call the optional validator.
- Return diagnostic segment-index pairs from `LogoPathSelfIntersectionPairs()` and use
  bounding-box rejection followed by tolerance-aware orientation tests.
- Exclude adjacent joins, the first/last join of a closed path, endpoint touches, collinear
  overlaps, separate-contour intersections, and hypothetical implicit closing edges. Treat those
  as valid joins or separately specified future validation problems rather than conflating them.
- Append `checkSelfIntersections` to the validation APIs and result record. Allow users to set it
  to `false` for highly tessellated paths.
- Accept `O(S^2)` worst-case time for `S` segments, with `O(K)` result storage for `K` crossings.
  Do not implement a sweep-line or spatial index unless measurements on real models demonstrate
  a material bottleneck.

Consequences:

- Crossing detection remains isolated in `LogoSC-Foundation-Validation.scad`; Core evaluation
  and rendering remain unchanged.
- Nine focused tests cover a bow-tie crossing, reported pair indexes, default and disabled
  behavior, normal closure, endpoint contact, tolerance-level contact, collinear overlap, and
  the absence of a synthetic closing edge.
- The complete Foundation and Validation suites now contain 166 immutable results.

### 2026-07-22 — 2026.3 feature-release preparation

Context:

- Work after `2026.2.1` produced two substantial feature groups: the customizable printable
  fastener application and expanded optional validation through proper self-intersections.
- Treating that scope as another `2026.2` patch would understate the new application, public
  validation behavior, documentation, tests, and reproducible visual assets.
- An earlier tentative `2026.3` theme also mentioned stroke rendering and SVG export, but release
  themes are planning aids rather than requirements to ship unrelated features together.

Decision:

- Advance the Core public API version from `2026.2` to `2026.3` while preserving all established
  renderers, evaluators, accessors, region helpers, and command opcodes.
- Consolidate the changelog's accumulated fastener and validation work into release `2026.3`,
  dated 2026-07-22, and restore an empty `Unreleased` section for subsequent development.
- Define `2026.3` by the coherent features actually implemented and verified. Keep manufacturable
  stroke rendering and SVG export as later candidates.
- Update active version references, release history, roadmap text, and the restart checkpoint
  without rewriting historical records about `2026.2` or `2026.2.1`.

Verification boundary:

- Require the complete Foundation and Validation result to remain 166 of 166 passing.
- Require warning-free CSG exports for Bolt, Nut, Assembly, Profile, and Algorithm modes and full
  CGAL STL exports for the default bolt and nut.
- Create and publish tag `v2026.3` only after the release-preparation diff is reviewed and
  committed; do not move either earlier release tag.

### 2026-07-24 — Deferred fastener test strategy

Context:

- `LogoSC-Nuts-And-Bolts.scad` has input assertions and has passed documented command-line CSG,
  CGAL/STL, and mesh-verification checks, but it has no dedicated automated test suite.
- The Foundation and Validation suites verify the underlying LogoSC behavior. They should not
  acquire a dependency on the standalone fastener application.
- Full threaded CGAL renders and the gallery are too slow for the normal LogoSC acceptance run.

Decision:

- When dedicated fastener tests are added, put them in a separate passive test companion and
  invoke them through a separate fastener test runner.
- Make the routine suite fast and deterministic by checking preset resolution, profile
  dimensions, generated LogoSC command lists, contour and resampling counts, thread lead,
  handedness, multi-start phase offsets, and polar wrapping calculations.
- Add lightweight command-line CSG smoke exports for representative Bolt, Nut, Profile, and
  Algorithm modes.
- Keep default bolt and nut CGAL/STL exports, mesh inspection, the slow gallery, and the
  high-resolution assembly in a smaller release-only verification matrix.
- Do not add these tests now. Design their exact result-record format and fixtures when fastener
  development resumes.

Consequences:

- Future fastener regressions can be detected without changing the Core dependency boundary or
  slowing every Foundation and Validation acceptance run.
- Expensive geometric verification remains available at release boundaries without being
  mistaken for a fast unit-test suite.

### 2026-07-24 — Non-rendering fastener test suite

Context:

- Fastener development resumed after the dedicated test strategy was intentionally deferred.
- The gallery and full threaded CGAL renders remain too slow for routine regression checks, and
  rendered output does not provide a precise automated assertion by itself.

Decision:

- Add passive `LogoSC-Nuts-And-Bolts-Tests.scad` definitions and a separate
  `LogoSC-Nuts-And-Bolts-Test-Runner.scad`.
- Import the standalone fastener application with OpenSCAD `use` semantics. Unlike `include`,
  which behaves like inserting and evaluating the complete file, `use` makes its function and
  module definitions callable without executing the top-level Bolt/Nut/Gallery dispatch. The
  routine suite can therefore test the real calculation functions while creating no geometry.
- Verify deterministic computed behavior: every named size preset, derived dimensions, drive
  selection, all six profile families, LogoSC profile commands and contours, documented
  resampling counts, handed polar wrapping, and multi-start phase offsets.
- Continue to keep CSG smoke exports and slower CGAL/STL and mesh checks outside this routine
  suite and outside the Foundation/Validation runner.

Consequences:

- Fastener calculation regressions now have a quick automated gate without slowing the normal
  LogoSC acceptance run or changing Core's dependency boundary.
- Visual and mesh verification remain necessary at release boundaries because parameter tests
  cannot prove boolean robustness or printable mesh quality.

### 2026-07-27 — Preliminary local-transform design direction

Context:

- Future reusable radial and reflected patterns, including possible interlaced-knot work, need
  richer local transforms than the current position, heading, and uniform scale.
- The transform discussion should be preserved now, but implementation should not interrupt the
  active inter-contour and overlapping-hole validation work.

Decision:

- Record the preliminary direction and unresolved compatibility questions in
  `LogoSC-Transforms-Design.md`.
- Reuse the existing `PUSH`/`POP` state stack for the complete local transform; do not create a
  separate matrix stack or add implicit loop save/restore behavior.
- Preserve sequential transform accumulation through `REPEAT` and `RUN`.
- Keep `TURN` as the relative rotation operation rather than adding a competing `ROTATE`
  command.
- Define relative movement and locally generated primitive points through the complete affine
  transform.
- Prefer a readable canonical state over exposing anonymous affine-matrix coefficients, while
  leaving its exact representation and backward-compatible public-state migration for the
  detailed design review.

Consequences:

- The upcoming hole-validation work retains a bounded scope and clean verification boundary.
- Transform implementation remains deferred until canonicalization, `GOTO`/`DIR`, zero-scale,
  winding, tessellation, and public-state compatibility decisions are resolved.

### 2026-07-27 — General topology relations and strict hole validation

Context:

- Proper self-intersection validation handled crossings within one path but deliberately
  excluded relationships between separate contours.
- Hole correctness requires both boundary-intersection classification and containment; boundary
  scans alone cannot detect one contour wholly inside another.
- General relationship queries are useful beyond hole policy, but quadratic analysis should not
  become a dependency of the standalone Core evaluator and renderer.

Decision:

- Generalize the optional Validation companion with tolerance-aware segment relationships,
  contour intersection records, point-in-contour and point-in-region classification, and
  filled-region relationship queries.
- Use bounding-box rejection, orientation tests, explicit collinear interval classification,
  and odd-even ray containment. Retain direct pairwise scans rather than adding a sweep-line or
  spatial index without measured need.
- Queue child holes while an active turtle outer is still being built, then emit that outer
  before its pending holes. This makes ownership deterministic without splitting the parent
  contour or changing existing public path fields.
- Require holes to be strictly inside their owning outer contour. Reject outer-boundary contact
  and sibling holes that overlap, touch, coincide, or nest.
- Append an optional related-path index to validation issues and append
  `checkHoleTopology = true` to validation APIs and results, preserving older positional fields.
- Permit overlap between independent outer regions. Expose their relationship without
  automatically treating it as invalid LogoSC geometry.

Consequences:

- Core remains standalone and unchanged; topology users continue to opt into
  `LogoSC-Foundation-Validation.scad`.
- The complete Foundation and Validation acceptance run contains 201 immutable results after
  adding focused predicate, containment, region, ownership, hole-policy, and opt-out tests.
- Pairwise contour work remains worst-case quadratic and can be disabled for trusted,
  highly tessellated models.

### 2026-07-27 — Convexity query API

Context:

- Advanced geometry algorithms often require a convex contour, path, or filled region, but
  concavity is valid LogoSC geometry and should not become a validation error.
- A local-turn-only test can incorrectly classify self-intersecting or retraced boundaries.
- Multiple polygons introduce two different questions: whether every member is convex and
  whether their geometric union is convex.

Decision:

- Add public `LogoContourIsConvex()`, `LogoPathIsConvex()`, and `LogoRegionIsConvex()` queries
  to the optional Validation/geometry companion rather than mandatory Core.
- Require a simple boundary before checking turn signs: reject insufficient vertices,
  zero-length edges, collinear backtracking, and all nonadjacent segment relationships.
- Accept clockwise and counterclockwise winding. Allow forward collinear vertices by default
  and provide `strict = true` when every turn must be nonzero.
- Define a filled region with any hole as nonconvex.
- Add `LogoRegionsAreIndividuallyConvex()` for lists of regions. Make its member-wise behavior
  explicit; do not claim to compute convexity of the polygons' geometric union.

Consequences:

- Convexity is now a reusable Boolean query without altering `ValidateLogoPaths()` validity
  policy.
- The correctness-first contour query has a worst-case quadratic simplicity scan followed by
  linear turn analysis.
- Twelve focused Validation results cover winding, concavity, collinearity modes, malformed
  boundaries, path closure, holes, and multiple-region behavior.
- The complete Foundation and Validation acceptance run now contains 201 immutable results.

### 2026-07-27 — 2026.4 feature-release preparation

Context:

- Work after `2026.3` added public optional topology and convexity APIs, strict hole validation,
  expanded Foundation/Validation and fastener tests, detailed algorithm documentation, and a
  preliminary transform design note.
- The transform implementation will change evaluator state and deserves a later independent
  milestone rather than being coupled to this completed validation feature set.

Decision:

- Advance `LogoSCVersionMinor` from `3` to `4`.
- Consolidate the current Unreleased work into release `2026.4`, dated 2026-07-27, and restore
  an empty Unreleased section.
- Update active current-version references while preserving historical `2026.3` release
  rationale and records.
- Leave commit, tag creation, and external release publication to the maintainer after review.

Verification boundary:

- Require the complete Foundation and Validation result to remain 201 of 201 passing.
- Require the separate fastener result to remain 48 of 48 passing.
- Verify `LogoSCVersion == "2026.4"`, documentation consistency, `git diff --check`, and the
  final working-tree status before handoff.

### 2026-07-27 — Canonical local affine transforms

Context:

- The validation and convexity checkpoint was complete, allowing the deferred local-transform
  review to proceed.
- Planned knot and repeated-motif work needs transforms to persist through `REPEAT` and `RUN`
  while remaining restorable through the existing state stack.

Decision:

- Extend public state to `[x, y, heading, scaleX, scaleY, shear]`.
- Preserve the historical `SX`, `SY`, `SH`, and `SS` indices; retain `SS` as the compatibility
  alias for `scaleX` and add `SSX`, `SSY`, and `SSH`.
- Canonicalize as rotation, X shear, then XY scale. Keep `scaleX` nonnegative and carry
  reflection orientation in signed `scaleY`.
- Compose `TURN` and `SCALE` on the right in local turtle coordinates. A turn following
  nonuniform scaling may generate explicit shear.
- Keep the existing `DIR` and `GOTO` names. They remain world-absolute operations and preserve
  the current canonical scale and shear fields.
- Extend `SCALE` to accept independent X/Y factors; negative values reflect and zero values are
  rejected as singular.
- Transform `MOVE`, locally tessellated arcs, and primitive points through the complete state.
  Use maximum affine stretch for automatic curve tessellation.
- Preserve generated point order under reflection.
- Keep transforms persistent through loops and calls. Existing `PUSH`/`POP` stores the complete
  state; no second stack or implicit loop/call scope is introduced.
- Keep `HOLE` child evaluation scoped while inheriting the parent's complete transform.
- Use temporary 2x2 coefficients only for internal composition and immediate
  recanonicalization; do not expose matrices as state.
- Expose `LogoStateToAffine()` and `LogoAffineToState()` in Core as interoperability helpers,
  using the standard 2x3 column-vector layout `[[a,c,tx], [b,d,ty]]`.
- Document that local operations postmultiply the current transform. Accept an optional heading
  reference during matrix-to-state conversion because matrices cannot retain complete turns.
- Reject malformed and singular external affine matrices rather than creating degenerate state.

Verification boundary:

- The pre-transform Foundation and Validation wall remained 201/201 passing.
- Focused affine results cover decomposition, transformed points, persistent loops, reflections,
  world-absolute commands, restoration, arcs, primitives, `RUN`, holes, debug parity, and
  singular-scale errors.

Follow-up:

- Added a six-cell gallery row using ordinary LogoSC command data: ellipse, generated shear,
  persistent sixfold turning, reflection, transformed arcs, and a recursive scaled/turned tree.
- Kept the tree within LogoSC's filled-region model by generating explicitly closed branch
  contours and using pen-up motion only to reposition between recursive branch bases.
- Move the wordmark from an isolated middle cell to a centered masthead above the gallery.
  Apply a visible right-leaning generated shear to both O glyphs using nonuniform `SCALE`,
  `TURN`, and `DIR` so the branding demonstrates the transform model without a `SHEAR` opcode.
- Remove the resulting empty row by compacting the L-system and transform rows downward. Increase
  the wordmark gallery scale from `0.46` to `0.69` so the masthead is 50 percent larger.
- Continue exercising the model before exposing an explicit `SHEAR` opcode.
- Use the transform behavior as the foundation for the proposed Gordian-knot feature design.

### 2026-07-27 — Optional knot companion first vertical slice

Context:

- `LogoSC-Knots-Design.md` established a broad roadmap, but implementation needed a narrow first
  boundary that proved the shared representation without pulling ribbons, cords, bundles, or
  image import into LogoSC Core.
- Torus links require special component handling when `p` and `q` are not coprime; naively
  sampling the unreduced curve once per component retraces geometry.

Decision:

- Add standalone `LogoSC-Knots.scad` with knot, strand, crossing, validation-result, and
  validation-issue records plus documented constructors and accessors.
- Make multiple components first-class. Closed strands repeat their first 3D sample, crossing
  encounters index the shared crossing list, and a reserved lane-closure permutation supports
  later bundles without changing the leading record fields.
- Validate record structure, sample shape, closure tolerance, crossing references and
  parameters, over-strand ownership, encounter indexes, and lane permutations. Keep reporting
  and debug rendering preview-only.
- Implement torus knots and links by reducing `p` and `q` by `gcd(p,q)` and phase-shifting each
  independently closed component around the minor circle.
- Keep ribbons, crossing lifts, adjacent cord bundles, capsule-cord manufacturing geometry, and
  AI image import deferred even though metadata and lane-closure fields can accommodate them.

Consequences:

- Core and the optional Foundation Validation companion remain unchanged and unaware of knots.
- Add Planar and Spatial debug-view modes. Planar projection changes only diagnostic display,
  retains the original 3D samples, and deliberately does not invent underpass gaps before
  crossing discovery exists.
- A dedicated 24-result suite covers records, invalid structures, closure, crossings, torus
  sample counts, exact component closure, distinct components, and validation.
- `LogoSC-Knots-Examples.scad` provides a small unknot, trefoil, Hopf-link, and explicit-crossing
  diagnostic gallery. The next coherent milestone can add braid generation or manufacturable
  capsule cords without redesigning the common result.

### 2026-07-28 — Manufacturable single-cord knot geometry

Context:

- The first knot-companion slice produced validated sampled 3D routes but only diagnostic
  centerlines and markers.
- The existing strand representation already repeats the first sample at the end of a closed
  route, so it can drive capsule construction without changing record layouts or Core.

Decision:

- Add `RenderKnotCords()` as an optional-companion manufacturing module that validates the knot
  and hulls equal-radius spheres at every adjacent sample pair.
- Keep cord radius and sphere fragment count explicit. Route sampling remains a generator input,
  and callers remain responsible for selecting dimensions that preserve printable clearance.
- Add deterministic strand and complete-knot segment-count helpers. These verify that every
  route segment reaches the manufacturing compiler without treating non-rendering tests as mesh
  proof.
- Keep `RenderKnotDebug()` preview-only and unchanged. The new cord module is not a general
  LogoSC Core stroke API.
- Defer adjacent bundle expansion, automatic clearance analysis, crossing lifts, ribbons, and
  bas-relief. Those require additional topology and manufacturing policies.

Verification boundary:

- Expand the independent knot suite from 24 to 28 passing results.
- Require a CSG smoke export of the trefoil cord example in addition to deterministic tests.
- Continue to require the complete Foundation/Validation suite because documentation and shared
  repository acceptance remain synchronized even though the knot companion has no Core
  dependency.

Documentation follow-up:

- Make the absence of hidden Core evaluation explicit. The implemented torus path uses pure
  OpenSCAD functions for sampling and validation and native OpenSCAD modules for 3D geometry.
- Record that the knot test runner includes Core only for the shared automated-test result and
  reporting framework.
- Reserve actual LogoSC evaluator integration for planar Celtic motifs, transform-driven
  repetition, ribbon regions, and crossing masks, with native OpenSCAD retaining 3D operations.

Presentation follow-up:

- Add a `CordGallery` scene that uses the real generator and renderer rather than illustrative
  substitute geometry.
- Use a top-down orthographic camera, three distinct cord palettes, separate Hopf-component
  colors, and extruded labels to make the manufacturing output immediately legible.
- Use presentation-specific route sampling so command-line PNG generation remains practical;
  retain the standalone examples' higher sampling for closer inspection and mesh export.

### 2026-07-28 — Untwisted adjacent knot-cord bundles

Context:

- The single-cord renderer proved sampled-route manufacturing, while the knot roadmap required
  generators to remain independent of requested bundle count.
- Bundle twist, Möbius closure, and crossing lifts combine geometry with additional topology.
  Coupling them to the first lane-expansion slice would make closure and failures ambiguous.

Decision:

- Implement `MakeKnotBundle()` as a deterministic expansion from each master strand to
  individually exposed lane strands.
- Implement the documented equal-radius width equation and symmetric lane-center equation.
  Accept either explicit radius or automatic fitting within `bundleWidth`.
- Derive tangents from adjacent unique samples and parallel-transport a perpendicular lateral.
  Distribute the signed frame mismatch around closed routes, then repeat the first expanded
  sample exactly to preserve validation and manufacturing closure.
- Preserve an odd bundle's center lane exactly on the master route. Record master index, lane
  index, and signed offset in each expanded strand's metadata.
- Reject input knots with recorded crossings for now. Silent crossing deletion or guessed
  over/under remapping would create plausible-looking but topologically false results.
- Render expanded lanes through the existing `RenderKnotCords()` capsule path. Keep native
  OpenSCAD responsible for 3D geometry and keep Core independent.
- Defer explicit frame twist, Möbius closure permutations, synchronized crossing lifts,
  bundle-envelope clearance, and tight-curve rejection to later focused milestones.

Verification boundary:

- Add ten deterministic results for vector math, width fitting, symmetric offsets, straight and
  curved frames, expansion counts, center-route preservation, lane spacing, closure, validation,
  and multi-component links, bringing the knot suite to 38 results.
- Add direct Customizer bundle output and a presentation gallery using two, three, and four
  lanes on the same trefoil master route.
- Require CSG/PNG gallery exports, a representative bundle STL mesh export, the complete knot
  suite, and the repository's Foundation/Validation and fastener acceptance suites.

View-mode correction:

- The initial presentation galleries and manufacturing branches exposed `KnotView` in the
  Customizer but ignored it; only `RenderKnotDebug()` consumed the selector.
- Add `KnotForView()` as a non-mutating record projection. Apply it before cord rendering and,
  critically, before bundle expansion so Planar lanes are derived from the planar master.
- Remove the fixed X presentation tilt in Planar galleries and retain it only for Spatial.
- Document that Planar capsules can merge at projected crossings and are not a substitute for
  later crossing-aware ribbon or lift geometry.

### 2026-07-28 — Signed circular braid closures

Context:

- Torus routes proved implicit 3D knot geometry, but the next generator needed explicit,
  deterministic crossing topology.
- Standard braid closure can turn one signed word into either a knot or a multi-component link,
  depending on the final lane permutation.
- Existing crossing records identified only the over strand. That is insufficient when both
  branches of a self-crossing belong to the same closed strand.

Decision:

- Preserve the established first six crossing fields and add optional `overBranch` at index 6.
  Infer it for distinct strands and require `"A"` or `"B"` for self-crossings.
- Implement `MakeCircularBraidKnot()` with signed one-based adjacent generators. Positive
  generators lift the branch entering the lower-numbered lane; negative generators reverse the
  relationship.
- Exchange radial lane positions with a cosine blend and use equal opposite Z bumps with total
  separation `crossingHeight`.
- Compute the final label-to-lane permutation and trace each disjoint cycle into one exact closed
  strand. This produces a two-component Hopf link from `[1,1]` and a one-component trefoil from
  `[1,1,1]`.
- Record one crossing per word instruction, normalized parameters for both branches, explicit
  branch ownership, and both encounter appearances for self-crossings.
- Choose circular closure for the first braid boundary. Defer rectangular exterior return paths
  because they add geometric routing rather than new braid topology.
- Continue rejecting braid results in `MakeKnotBundle()` until crossing events and collective
  height can be remapped to complete bundle envelopes.

Verification boundary:

- Add 13 crossing and braid results, bringing the independent knot suite from 38 to 51.
- Cover signed-word validity, lane swaps and states, closure permutations and cycles, blend
  endpoints, exact trefoil and Hopf closure, self-crossing branches, signed height, encounter
  indexes, three-lane closure, and complete validation.
- Add a spatial/planar `BraidGallery` generated from the real braid records and normal cord
  renderer, plus a reproducible documentation PNG.

### 2026-07-29 — Crossing-aware braided cord bundles

Context:

- Circular braids now provide explicit normalized crossings and branch-level over/under
  ownership, while untwisted bundles already expand sampled 3D routes through stable transported
  frames.
- Silently discarding braid crossings was never acceptable, but retaining only one master
  crossing would also miss collisions between offset cords.

Decision:

- Expand every master crossing to the Cartesian product of its branch-A and branch-B bundle
  lanes. An `N`-cord bundle therefore records `N*N` crossings per master event.
- Map master strand indexes to `masterIndex*N + laneIndex`, preserve both normalized parameters
  and the over-branch field, and rebuild encounter indexes from the expanded crossing list.
- Let every lane inherit the master's equal/opposite braid Z profile. This produces a
  synchronized collective crossing lift without introducing an independent per-lane topology.
- Interpolate each remapped branch at its crossing parameter and require center distance
  `2*cordRadius + minimumClearance`. Checking all remapped pairs evaluates the complete recorded
  bundle envelope.
- Enforce clearance by default in `MakeKnotBundle()` and `RenderKnotCordBundle()`. Retain an
  explicit opt-out only for diagnostic construction of known failing cases.
- Keep the restriction precise: this is recorded-crossing clearance, not automatic collision
  discovery for unrecorded near approaches or tight offset curves.

Verification boundary:

- Add four deterministic results for lane-pair remapping, parameters and encounters, normalized
  interpolation, and passing/failing collective clearance, bringing the knot suite from 51 to
  55.
- Add `BraidBundleGallery` using actual Hopf, trefoil, and three-lane braid records expanded to
  two manufacturing cords per master strand.
- Require the complete knot, Foundation/Validation, and fastener suites, Planar and Spatial
  gallery exports, a documentation PNG, and a representative braided-bundle STL.

### 2026-07-29 — Explicit Celtic tile-grid topology

Context:

- Torus and braid generators established sampled routes and explicit crossings, but neither
  produced traditional rectilinear Celtic interlace from user-authored local motifs.
- The roadmap's smallest useful vocabulary contains three four-port cells: one straight
  crossing and the two complementary corner pairings.
- A finite rectangle made entirely from four-port cells necessarily exposes perimeter ports.
  Treating those ports as implicitly closed would hide a material topology decision.

Decision:

- Implement literal `"X"`, `"NE_SW"`, and `"NW_ES"` tile names and reject ragged grids or
  unknown cells before route construction.
- Connect every interior exit to the opposite port of its neighbor. Enumerate perimeter ports
  clockwise and pair consecutive ports with sampled exterior curves. Record this first closure
  policy as `"clockwisePairs"` in knot metadata.
- Model tracing as a permutation of directed `[row, column, port]` states. Follow each cycle to
  exact closure and mark its internally paired reverse states visited so one physical route is
  not emitted twice.
- Sample `"X"` branches as straight paths and corner pairings as quadratic curves. Assign
  equal/opposite Z bumps at crossings by checkerboard parity.
- Build ordinary crossing records with normalized branch parameters and normal strand encounter
  indexes. Sort encounters by parameter and reject a grid unless over/under states alternate
  cyclically on every component.
- Keep this slice independent of LogoSC Core. Core becomes relevant in the next stage, where
  sampled planar centerlines compile into closed ribbon and crossing-mask regions.
- Defer random grids, substitution systems, user-authored boundary pairing maps, ribbons, and
  relief so topology failures remain isolated.

Verification boundary:

- Add ten deterministic results for tile vocabulary, grid validation, boundary pairing, cycle
  tracing, reverse de-duplication, component and sample counts, exact closure, crossing records
  and height, encounters, alternation, and metadata. The knot suite grows from 55 to 65.
- Add `CelticGallery` with one-component, two-component, and 4-by-4 examples generated through
  the normal knot records and capsule renderer.
- Require the complete knot, Foundation/Validation, and fastener suites, Planar and Spatial
  gallery exports, a documentation PNG, and a representative Celtic-grid STL.
