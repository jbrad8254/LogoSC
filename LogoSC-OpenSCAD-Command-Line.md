# Running LogoSC from the OpenSCAD Command Line

OpenSCAD can run as a command-line compiler as well as an interactive GUI. This makes it
possible to evaluate LogoSC programs, run the regression suite, capture `echo()` diagnostics,
export geometry, and render PNG previews from PowerShell or an automated build.

This guide is a concise LogoSC-oriented introduction. The official OpenSCAD references at the
end describe every supported option in detail.

## Why this works

An OpenSCAD file is a program that evaluates to geometry. The GUI normally performs that
evaluation when you preview or render, but the command-line interface can perform the same work
when given an input `.scad` file and an output selected with `-o`.

On Windows, a normal installation provides two launchers:

- `openscad.exe` starts the graphical application.
- `openscad.com` is the console wrapper that exposes messages and exit status to a shell.

LogoSC's tested Windows installation is currently OpenSCAD `2021.01` at:

```text
C:\Program Files\OpenSCAD\openscad.com
```

The installed program's `--help` output is the authority for that exact version. Newer
OpenSCAD releases may provide additional formats and options.

## Basic PowerShell setup

Run these commands from the LogoSC repository root:

```powershell
$openScadCli = 'C:\Program Files\OpenSCAD\openscad.com'

& $openScadCli --version
& $openScadCli --help
```

PowerShell's call operator, `&`, runs the quoted executable path. After OpenSCAD exits,
`$LASTEXITCODE` contains its process exit code.

The general command shape is:

```powershell
& $openScadCli [options] -o output-file input-file.scad
```

The output extension selects the export type. Useful examples include:

| Extension | Typical use |
|---|---|
| `.echo` | Capture `echo()`, warnings, and errors as text without exporting geometry. |
| `.csg` | Export OpenSCAD's evaluated CSG representation. |
| `.stl` | Fully render and export a 3D mesh. |
| `.svg` or `.dxf` | Export supported 2D geometry. |
| `.png` | Render a preview or full-render image for visual inspection. |

## Example 1: run the LogoSC regression suite

`LogoSC-Foundation-Test-Runner.scad` loads Core, optional Validation, and both passive test
definition files, then executes the complete suite. Core itself has no companion dependency.

The Tests run also renders a color-coded visual regression gallery. It provides a quick view
across the geometry cases, while the immutable result records provide the automated verdict.

![LogoSC visual regression-test gallery in OpenSCAD](images/regression-test-gallery.png)

This tested PowerShell example evaluates the suite and captures its messages in an `.echo`
file:

```powershell
$openScadCli = 'C:\Program Files\OpenSCAD\openscad.com'
$testLogPath = Join-Path $env:TEMP 'LogoSC-tests.echo'

& $openScadCli `
    -D 'TraceLevel=0' `
    -o $testLogPath `
    'LogoSC-Foundation-Test-Runner.scad'

if ($LASTEXITCODE -ne 0)
{
    throw "OpenSCAD failed with exit code $LASTEXITCODE."
}

$globalPass = @(
    Select-String `
        -LiteralPath $testLogPath `
        -SimpleMatch '"LOGOSC_AUTOMATED_TEST_RESULT", "PASS"'
)

$globalFail = @(
    Select-String `
        -LiteralPath $testLogPath `
        -SimpleMatch '"LOGOSC_AUTOMATED_TEST_RESULT", "FAIL"'
)

$failedTests = @(
    Select-String `
        -LiteralPath $testLogPath `
        -Pattern '"LogoSC test result".*"FAIL"'
)

if ($globalPass.Count -ne 1 -or $globalFail.Count -ne 0)
{
    $failedTests
    throw 'LogoSC did not report exactly one successful complete test run.'
}

Write-Output 'LogoSC automated tests passed.'
```

The last summary includes per-suite and global test, pass, and failure totals. Set
`LogoTestReportLevel=2` with another `-D` option to include every named passing test; the
default level `1` prints all failures and their details.

When a complete run finds several failures, rerun in optional fail-fast mode to isolate the
first evaluated failed result:

```powershell
& $openScadCli `
    -D 'TraceLevel=0' `
    -D 'LogoTestFailFast=true' `
    -o $testLogPath `
    'LogoSC-Foundation-Test-Runner.scad'
```

`LogoTestFailFast` defaults to `false`; leave it there for acceptance runs so every failure and
the final totals are reported. With `true`, the assertion message identifies the test and its
detail record. OpenSCAD 2021.01 also prints the file and line containing the shared assertion
and a `TRACE` of caller locations. Cases constructed through common geometry helpers may not
trace directly to their data declaration, which is why the stable test name is included.
With `.echo` output, tested OpenSCAD 2021.01 can still return process exit code `0` after an
assertion failure. Inspect the `ERROR: Assertion` and `TRACE` lines; for complete acceptance
runs, continue to require the exact final `LOGOSC_AUTOMATED_TEST_RESULT`, `PASS` record rather
than treating exit status alone as success.

The failure-condition row deliberately emits `[ERROR]` messages while testing Core soft-error
behavior. These expected diagnostics appear between `LogoSC expected-error tests: BEGIN` and
`END`; do not count them as test-result failures. The exact final
`LOGOSC_AUTOMATED_TEST_RESULT` record is the authority for the automated suite.
When that record is `FAIL`, the aggregate reporter adds `*** Test Suite Failed ***` as its final
line for quick human recognition. Fail-fast assertions can stop before this banner is reached.

## Example 2: export and inspect a debug PNG

The command line can render the same debug demo that is available through the OpenSCAD
Customizer. Debug mode defaults to the full gallery, so this focused example explicitly
selects the single-example layout:

![LogoSC indexed debug-renderer gallery in OpenSCAD](images/debug-renderer-gallery.png)

```powershell
$openScadCli = 'C:\Program Files\OpenSCAD\openscad.com'
$debugPngPath = Join-Path $env:TEMP 'LogoSC-debug.png'

& $openScadCli `
    -D 'LogoSCRunMode=\"Debug\"' `
    -D 'DebugDemoLayout=\"Selected\"' `
    -D 'DebugDemoExample=0' `
    -D 'TraceLevel=0' `
    --imgsize '800,600' `
    --autocenter `
    --viewall `
    --projection o `
    -o $debugPngPath `
    'LogoSC-Examples.scad'

if ($LASTEXITCODE -ne 0)
{
    throw "OpenSCAD PNG export failed with exit code $LASTEXITCODE."
}
```

This exact command was verified against OpenSCAD `2021.01`. It produced an `800` by `600`
orthographic preview of the filled closed triangle with its debug capsules and point markers.

PNG output uses preview rendering by default. Add `--render` when an exact full render is
required, accepting that it may be substantially slower. A generated PNG can be inspected by a
person, attached to a continuous-integration run, or loaded by an AI coding tool that supports
local image inspection.

## Example 3: export a normal model

For a normal 3D OpenSCAD model that includes LogoSC, export an STL with:

```powershell
$openScadCli = 'C:\Program Files\OpenSCAD\openscad.com'

& $openScadCli `
    -D 'TraceLevel=0' `
    --export-format asciistl `
    -o 'MyLogoSCPart.stl' `
    'MyLogoSCPart.scad'

if ($LASTEXITCODE -ne 0)
{
    throw "OpenSCAD STL export failed with exit code $LASTEXITCODE."
}
```

The explicit `asciistl` format avoids depending on a version's default STL encoding. A 2D-only
model can instead be exported to a supported 2D format such as `.svg`.

## What command-line verification proves

Command-line execution can verify that:

- OpenSCAD parses and evaluates the files;
- LogoSC assertions and invariant checks execute;
- expected `echo()` diagnostics are produced;
- an export completes with a known process exit code;
- geometry or an image artifact is physically generated; and
- PNG output looks plausible during a first-pass visual review.

It does not by itself prove that:

- every warning is harmless;
- a mathematically valid mesh matches the intended design;
- interactive Customizer controls behave well in the GUI; or
- a PNG preview has the same guarantees as a full geometry render.

Use command-line checks as strong automated evidence, then retain interactive OpenSCAD review
for Customizer behavior and important visual or manufacturing decisions.

## Other platforms

Linux and similar systems normally invoke `openscad`. A standard macOS application install can
be invoked through `OpenSCAD.app/Contents/MacOS/OpenSCAD`. See the platform notes in the official
command-line manual for exact paths and setup.

## Official OpenSCAD documentation

- [OpenSCAD documentation portal][docs] — official entry
  point for the tutorial, User Manual, language reference, and cheat sheet.
- [Using OpenSCAD in a command-line environment][cli]
  — command syntax, `-o`, `-D`, quoting, PNG camera controls, dependency generation, and
  Windows/macOS notes. OpenSCAD's official documentation portal links to this manual.
- [OpenSCAD User Manual PDF][pdf]
  — downloadable full manual, including the command-line chapter.
- [OpenSCAD Customizer manual][customizer]
  — parameter files and sets used with command-line `-p` and `-P` options.
- [OpenSCAD `assert()` language reference][assert]
  — assertion messages, failed-render behavior, and file/line diagnostics.

For the installed executable's exact capabilities, always also run:

```powershell
& $openScadCli --version
& $openScadCli --help
```

[docs]: https://openscad.org/documentation.html
[cli]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment
[pdf]: https://files.openscad.org/documentation/manual/OpenSCAD_User_Manual.pdf
[customizer]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer
[assert]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#assert
