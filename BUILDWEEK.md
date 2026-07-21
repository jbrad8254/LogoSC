# LogoSC

## Short description

LogoSC gives OpenSCAD a Logo-inspired turtle-geometry language for creating reusable 2D
profiles, then demonstrates how Codex, Git, extensive tests, and persistent engineering
documentation can turn an experimental interpreter into a maintainable project.

## The problem

OpenSCAD is a programmatic 3D-modeling system commonly used to design parts for 3D printing.
One of its strengths is taking a 2D profile and extruding it into three dimensions. A profile
can be extruded linearly to create plates, enclosures, nuts, and other prismatic parts, or
rotated around an axis to create objects such as knobs, lamp bodies, and screw-like components.

The difficult part is often creating the original 2D profile.

At its lowest level, OpenSCAD represents a custom 2D polygon as an ordered list of coordinate
points. Writing one point list by hand is manageable. Creating and maintaining many related
profiles—with different dimensions, angles, repeated features, holes, and variations—quickly
becomes tedious and error-prone. A coordinate list also describes where the points are, but not
the geometric intent behind them.

Logo and other turtle-graphics languages offer a simpler model:

```text
move
turn
move
turn
repeat
```

Instead of calculating every coordinate manually, the designer describes how a virtual turtle
travels around the shape. Distances, angles, repetitions, and nested shapes can be adjusted
parametrically.

OpenSCAD does not natively provide this kind of turtle-geometry input. LogoSC was created to
fill that gap.

## What LogoSC does

LogoSC is a Logo-inspired geometry interpreter written entirely in OpenSCAD.

A model is expressed as a compact command list using operations such as:

- `MOVE`
- `TURN`
- `ARC`
- `RUN`
- `REPEAT`
- `PENUP` and `PENDOWN`
- `PUSH` and `POP`
- `CIRCLE`, `RECT`, `ROUNDEDRECT`, and `REGPOLY`
- `HOLE`

LogoSC evaluates those commands into structured 2D polygonal regions. Native OpenSCAD
operations can then extrude, rotate, subtract, combine, or transform those regions into
ordinary 3D models.

The original motivation was practical: I wanted a faster way to construct reusable profiles
for families of screws, nuts, and related printed parts without manually recalculating large
point lists for every variation.

The project now also includes:

- Reusable relative command lists.
- Recursive and repeated patterns.
- Filled regions with holes.
- A visual debug renderer that displays turtle movement, points, pen-up travel, and command
  order.
- Optional path validation.
- Example and diagnostic galleries.
- A command-line verification workflow.
- 151 named automated test results across Foundation and Validation suites.
- Aggregate failure reporting and optional fail-fast diagnosis.
- Extensive user, contributor, architectural, and historical documentation.

## Target audience

LogoSC has two primary audiences.

The first is OpenSCAD users who want to create reusable 2D profiles for extrusion without
hand-authoring coordinate lists. This includes makers, parametric-model designers, and
3D-printing enthusiasts who find relative turtle commands easier to understand and maintain
than raw polygon points.

The second—and equally important for this submission—is developers interested in how Codex
can participate in a sustained engineering project.

The repository records not only the resulting code, but also:

- Design decisions and their rationale.
- Coding and documentation conventions.
- Regression risks.
- Test architecture.
- Handoff procedures.
- Project boundaries and deferred ideas.
- Instructions that allow a fresh Codex task to reconstruct the project state from Git.

LogoSC is therefore both a usable geometry library and a case study in repository-centered
development with Codex. I am using it to learn and refine a process that I expect to apply to
a larger graphics project later.

A third audience is educators and learners interested in connecting turtle geometry,
functional programming, parametric design, and physical fabrication.

## How the project evolved

I began LogoSC before I knew about Codex. My early workflow used ordinary ChatGPT
conversations to discuss designs, write code, revise documentation, and explore ideas.

That worked surprisingly well, but long development conversations eventually accumulated too
much obsolete context. To continue reliably, I began asking ChatGPT to write detailed handoff
notes describing:

- The current implementation.
- Important design decisions.
- What had already been tried.
- Known risks.
- Future plans.
- The likely next task.

I would then start a fresh conversation and load those materials back in. This became a
primitive form of persistent engineering memory.

The workflow improved dramatically when I began using Git and then discovered Codex. Instead
of repeatedly copying files into and out of conversations, Codex could work directly in the
repository, inspect the current working tree, run tools, evaluate changes, and leave the
project in a state that Git could precisely describe.

The repository became our shared memory.

The project's `AGENTS.md`, Developer Notebook, contributor guide, changelog, and AI Engineering
Kit formalize that process. A fresh Codex task can read the repository, understand the current
architecture and working conventions, and resume without relying on an increasingly confused
conversational history.

## How Codex and GPT-5.6 contributed

Codex was not used merely to generate isolated snippets. It participated throughout the
engineering process.

It helped:

- Interpret OpenSCAD's unusual functional evaluation model.
- Design and implement new features.
- Run OpenSCAD from PowerShell.
- Capture and analyze diagnostic output.
- Render visual galleries and inspect the results.
- Identify regressions that were difficult to notice from console output alone.
- Maintain documentation alongside implementation changes.
- Preserve compatibility while separating Core functionality from optional companions.
- Design a test system appropriate for a language without conventional mutable test state.

One particularly interesting example was the automated test architecture.

A traditional assertion stops on the first failure. That is useful for isolating one defect,
but it makes it difficult to see whether a regression is local or affects the entire system.
OpenSCAD also does not make it practical to append failures to a mutable global list.

Codex helped redesign the tests around immutable result values:

```text
Test result:  [name, passed, detail]
Suite result: [suite name, test results]
Global run:   [Foundation suite, Validation suite]
```

This allows the normal test run to report every failure, suite totals, and a final
machine-readable result. An optional fail-fast mode uses OpenSCAD assertions when a maintainer
wants the first failure's file, line, test name, details, and caller trace.

The process was collaborative. I supplied the goals, constraints, preferences, and final
decisions. Codex contributed implementation ideas, noticed inconsistencies, suggested missing
tests and documentation, and frequently proposed useful follow-up work that I had not
explicitly requested.

At times it felt less like operating a code generator and more like working with an energetic
junior programmer who was unusually eager to add one more useful test before declaring the
task finished.

## What was added during Build Week

LogoSC existed before the Build Week submission period, so the repository provides a clear
baseline.

The `v2026.2` tag points to commit `3f883f4`, created on July 13 at 2:18 AM PDT, before the
official submission period began at 9:00 AM PDT.

Git history after that baseline documents thousands of lines of Build Week work across more
than 20 files.

The Build Week work includes:

- A standalone Core library that does not require test or validation companions.
- A dedicated test runner.
- Optional path evaluation and validation.
- A 151-result automated test hierarchy.
- Foundation and Validation suite summaries.
- Complete aggregate failure reporting.
- Optional assertion-based fail-fast diagnosis.
- Human-readable final failure banners.
- Command-line OpenSCAD execution and `.echo` analysis.
- An indexed visual debug gallery.
- Regression fixes discovered through command-line rendering.
- Repository-specific Codex instructions in `AGENTS.md`.
- A Git and Codex quick-start workflow.
- Expanded contributor, user, maintenance, and architectural documentation.

The original turtle evaluator supplied the seed of the project. Most of the infrastructure
that makes LogoSC testable, understandable, maintainable, and suitable for continued
development was created during Build Week with Codex.

## Challenges

OpenSCAD is unlike most languages commonly used for application development.

It is declarative and functional, variables are not conventionally mutable, expressions may
be reevaluated, and modules do not behave like imperative procedures. Error reporting,
recursion, list processing, polygon construction, and test aggregation therefore require
different design patterns.

Visual output also creates a second testing problem. A command can run successfully and still
generate an incorrect or confusing shape. LogoSC addresses this with both automated invariant
checks and visual galleries for examples, debug output, and regression cases.

Another challenge was controlling scope. LogoSC currently produces closed polygonal regions
suitable for extrusion. General open-path and stroke rendering remain future work. Codex
helped keep those future capabilities from destabilizing the current filled-region API.

## What I am proud of

I am proud that the project has become more than a working interpreter.

It is:

- Documented well enough for a new user to begin.
- Structured well enough for a new Codex task to resume development.
- Tested well enough to make substantial refactoring practical.
- Small enough to study as a complete example.
- Honest about its limitations and deferred work.
- Built around a real modeling problem rather than an artificial demonstration.

The most valuable result may be the development process itself: a practical example of using
Git as persistent project memory and Codex as a collaborator that can repeatedly reconstruct
context from the repository.

## What I learned

The most important lesson was that durable AI-assisted development depends on durable project
state.

Conversation history is useful, but it is not a substitute for:

- Source control.
- Tests.
- Architectural notes.
- Explicit conventions.
- Clear public interfaces.
- Written rationale.
- Reproducible commands.

When those elements are present, Codex can enter a project with a relatively clean context,
understand what already exists, make focused changes, run verification, and leave behind both
working code and the reasoning needed by the next task.

That process should scale better than relying on one indefinitely growing conversation.

## What comes next

The next major LogoSC feature is support for open paths and manufacturable strokes, including
width, joins, caps, and related validation.

Other future directions include:

- Additional path-quality checks.
- More reusable parametric shapes.
- Expanded extrusion examples.
- A Codex-native design workflow that turns natural-language shape descriptions into validated
  LogoSC programs and rendered previews.
- Applying the documented Codex workflow to a larger graphics project.

## Two-minute installation and test

### Requirements

For this submission, LogoSC has been developed and verified on Windows using OpenSCAD 2021.01.

Download OpenSCAD from the [official OpenSCAD download page](https://openscad.org/downloads.html).
On Windows it can also be installed with:

```powershell
winget install --id=OpenSCAD.OpenSCAD -e
```

The standard Windows installation normally places the command-line wrapper at:

```text
C:\Program Files\OpenSCAD\openscad.com
```

The OpenSCAD documentation recommends using `openscad.com` for Windows command-line execution.
See the [official command-line documentation][openscad-cli].

### Run the visual examples

1. Clone or download the [LogoSC repository](https://github.com/jbrad8254/LogoSC).
2. Open `LogoSC-Examples.scad` in OpenSCAD.
3. Leave `LogoSCRunMode` set to `Examples`.
4. Press F5 to preview the example gallery.
5. Change `LogoSCRunMode` to `Debug` to inspect turtle paths.
6. Change it to `Tests` to render the regression gallery and run the complete test suite.

A successful run ends with:

```text
LOGOSC_AUTOMATED_TEST_RESULT, PASS,
suites, 2, failedSuites, 0,
tests, 151, passed, 151, failed, 0
```

### Run the automated suite from PowerShell

From the repository directory:

```powershell
$openScad = 'C:\Program Files\OpenSCAD\openscad.com'
$results = Join-Path $env:TEMP 'LogoSC-tests.echo'

& $openScad `
    -D 'TraceLevel=0' `
    -o $results `
    'LogoSC-Foundation-Test-Runner.scad'

Get-Content $results |
    Select-String 'LOGOSC_AUTOMATED_TEST_RESULT|Test Suite Failed'
```

The complete tested command-line workflow is documented in
`LogoSC-OpenSCAD-Command-Line.md`.

## Supported platforms

The contest build is tested and supported on:

- Windows.
- OpenSCAD 2021.01.
- Both the OpenSCAD GUI and its `openscad.com` command-line wrapper.

LogoSC itself is pure OpenSCAD code, and OpenSCAD is also available for macOS and Linux. Those
platforms are expected to be compatible but have not been fully verified for this submission.
See the [OpenSCAD platform information](https://openscad.org/).

No compilation or package installation is required beyond installing OpenSCAD and downloading
the repository.

[openscad-cli]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment
