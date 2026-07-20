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

LogoSC's test grid is enabled by setting `LogoSCRunMode` to `"Tests"`. The `-D` option
overrides an OpenSCAD variable for that invocation. It can be repeated for additional values.

This tested PowerShell example evaluates the suite and captures its messages in an `.echo`
file:

```powershell
$openScadCli = 'C:\Program Files\OpenSCAD\openscad.com'
$testLogPath = Join-Path $env:TEMP 'LogoSC-tests.echo'

& $openScadCli `
    -D 'LogoSCRunMode=\"Tests\"' `
    -D 'TraceLevel=0' `
    -o $testLogPath `
    'LogoSC-Foundation-Core.scad'

if ($LASTEXITCODE -ne 0)
{
    throw "OpenSCAD failed with exit code $LASTEXITCODE."
}

$invariantRuns = @(
    Select-String -LiteralPath $testLogPath -SimpleMatch 'Logo evaluator invariant:'
)

$invariantFailures = @(
    Select-String -LiteralPath $testLogPath -SimpleMatch 'evaluator invariant failed:'
)

Write-Output "Invariant checks: $($invariantRuns.Count)"
Write-Output "Invariant failures: $($invariantFailures.Count)"

if ($invariantFailures.Count -ne 0)
{
    $invariantFailures
    throw 'LogoSC evaluator invariants failed.'
}
```

The embedded quotation marks in `LogoSCRunMode=\"Tests\"` must reach OpenSCAD because the
value is an OpenSCAD string. Shell quoting varies; this form is verified for PowerShell with
the installed Windows console wrapper.

The current failure-condition suite deliberately emits some `[ERROR]` messages while testing
soft-error behavior. Therefore, do not treat every `[ERROR]` line as an unexpected regression.
Check the process exit code and the diagnostics specific to the test being validated.

## Example 2: export and inspect a debug PNG

The command line can render the same debug demo that is available through the OpenSCAD
Customizer:

```powershell
$openScadCli = 'C:\Program Files\OpenSCAD\openscad.com'
$debugPngPath = Join-Path $env:TEMP 'LogoSC-debug.png'

& $openScadCli `
    -D 'LogoSCRunMode=\"Debug\"' `
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

For the installed executable's exact capabilities, always also run:

```powershell
& $openScadCli --version
& $openScadCli --help
```

[docs]: https://openscad.org/documentation.html
[cli]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment
[pdf]: https://files.openscad.org/documentation/manual/OpenSCAD_User_Manual.pdf
[customizer]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer
