# LogoSC Nuts and Bolts Customizer Guide

`LogoSC-Nuts-And-Bolts.scad` creates printable fastener demonstrations from LogoSC-defined
2D profiles and native OpenSCAD 3D operations. The dimensions are useful modeling defaults,
not certified fastener dimensions or tolerance classes. Calibrate clearance and strength for
the printer, material, orientation, and load before relying on a printed part.

## Quick start

1. Open `LogoSC-Nuts-And-Bolts.scad` in OpenSCAD and show the Customizer.
2. Select `Bolt`, `Nut`, `Assembly`, `Profile`, or `Gallery` with `Part`.
3. Choose a `ScrewSize` and `ThreadProfile`.
4. For a bolt, choose `HeadType`, `DriveType`, and `DriveSize` independently.
5. Set `PrintSlop` for the printer, preview with F5, and render with F6 before export.

`Assembly` is useful for a visual fit check. It does not perform collision analysis and cannot
replace a short printed calibration pair.

## Why head, drive, and drive size are separate

A head is the external shape, such as hex, pan, round, countersunk, carriage, or headless. A
drive is the tool-engagement feature, such as a slot, Phillips cross, or hex socket. The recess
or slot dimensions are a third choice. Standards likewise publish head dimensions and recess
dimensions separately; the contents of [ASME B18.6.3][asme-b18-6-3] show that separation for
inch machine screws.

There is no common hole size in millimeters shared by slotted, Phillips, and hex socket drives.
Phillips numbers designate cross-recess and driver families. Slots are characterized by width
and depth, while hex sockets use an across-flats dimension. [ISO 4757][iso-4757] defines H and
Z cross recesses and gauge numbers No. 0 through No. 4; it does not turn those
numbers into universal slot or hex dimensions. This model therefore treats `#0` through `#5`
as convenient, type-specific printable presets. `#5` extends the model's large-print range and
is not an ISO 4757 gauge size.

## Model parameters

- **`Part`** selects the output. `Bolt` creates an external thread and selected head/drive. `Nut`
  subtracts a matching enlarged thread from a hex blank. `Assembly` places both together.
  `Profile` shows one axial/radial bump and a flat, full-pitch reference pad behind it. `Gallery`
  displays eight representative bolts, screws, and nuts in a four-by-two grid.
- **`ScrewSize`** selects a nominal major diameter, pitch, and useful hex across-flats default.
  Metric entries use common coarse pitches. Inch entries use the threads per inch shown after
  the dash. `Custom` enables `CustomDiameter` and `CustomPitch`.
- **`CustomDiameter`** is the nominal major diameter in millimeters when `ScrewSize` is
  `Custom`. It also drives automatic head, nut, and drive proportions.
- **`CustomPitch`** is the axial distance in millimeters between adjacent turns of a
  single-start custom thread.
- **`Length`** is the threaded shaft length in millimeters, measured from the head bearing plane
  at Z=0 to the tip. A countersunk head is still modeled below that plane.

The built-in size list covers M3, M4, M5, M6, M8, then every even common size through M24,
followed by M27, M30, M33, and M36. Inch choices are #8-32, 1/4-20, 5/16-18, 3/8-16,
1/2-13, 5/8-11, 3/4-10, and 1-8. Metric selections follow the family described by
[ISO 261][iso-261]; inch selections follow familiar UNC diameter/TPI designations described by
[ASME B1.1][asme-b1-1].

## Thread parameters

- **`ThreadProfile`** selects the LogoSC axial/radial bump that is wrapped into a helix. See the
  profile notes below.
- **`Handedness`** selects the helix direction. `Right` advances conventionally; `Left` reverses
  the helix.
- **`ThreadStarts`** is the number of intertwined helices. Pitch remains the space between
  neighboring profile bumps; lead becomes `pitch * starts`.
- **`PrintSlop`** is radial clearance per side in millimeters. It enlarges the female thread
  cutter, so the approximate diametral clearance added to the nut is twice this value. Start
  around 0.20-0.30 mm per side for a trial print, then calibrate.
- **`TipChamfer`** controls the taper at both ends of an external thread, reducing thin fragments
  where the helix is clipped. The same value controls both entry chamfers in the nut. Nut
  chamfers are additionally limited by pitch and nut thickness.

The profiles are deliberately printable approximations:

- `V60` represents the 60-degree family used by ISO metric and Unified threads, with clipped
  crest and root rather than a tolerance-class implementation.
- `Whitworth55` uses a symmetric 55-degree form with sampled rounded crest and root.
- `ACME29` uses a symmetric 29-degree trapezoidal power-screw form.
- `Trapezoidal30` uses a symmetric 30-degree metric trapezoidal form.
- `Buttress7/45` uses unequal 7-degree and 45-degree flanks for directional loading.
- `Square` uses vertical flanks and broad flats as a printable idealization.

## Head and drive parameters

- **`HeadType`** selects the positive external shape: `Hex`, `Pan`, `Round`,
  `Countersunk Flat Head`, `Carriage`, or `Grub (Headless)`. Carriage adds a square neck.
  Headless cuts the selected drive inward from the free end of the shaft.
- **`DriveType`** independently selects `None`, `Slotted`, `Phillips`, or `Hex Socket`. The slot
  crosses the entire top. The Phillips cross tapers inward to model angled flanks.
- **`DriveSize`** selects `Auto`, a type-specific `#0`-`#5` preset, or `Custom`. The same label
  maps to different physical dimensions for each drive type; it is a convenience scale, not a
  shared standard.
- **`CustomDriveSize`** applies when `DriveSize` is `Custom`. It means slot width for `Slotted`,
  top cross span for `Phillips`, and across-flats width for `Hex Socket`, all in millimeters.
- **`HeadScale`** multiplies nominal head width and height without changing shaft diameter or
  pitch. Very small values may leave insufficient material around a large drive.

### Drive preset dimensions

| Preset | Phillips top span | Slot width | Hex socket across flats |
| --- | ---: | ---: | ---: |
| `#0` | 2.0 mm | 0.6 mm | 1.5 mm |
| `#1` | 3.0 mm | 0.8 mm | 2.0 mm |
| `#2` | 4.5 mm | 1.0 mm | 2.5 mm |
| `#3` | 6.0 mm | 1.2 mm | 4.0 mm |
| `#4` | 8.0 mm | 1.6 mm | 5.0 mm |
| `#5` | 10.0 mm | 2.0 mm | 6.0 mm |

`Auto` chooses `#0` through `#5` at nominal diameters up to 2.5, 4, 7, 10, 14, and
greater than 14 mm respectively. Recesses are clamped to the available head diameter and
depth, so an oversized selection does not remove the whole head. These values favor visible,
printable geometry; use `Custom` when matching a particular tool or specification.

## Gallery output

`Part = Gallery` renders a stable four-column by two-row overview containing a hex bolt,
slotted pan screw, Phillips round screw, countersunk hex-socket screw, carriage bolt, headless
hex-socket screw, V-thread nut, and trapezoidal-thread nut. Gallery models use the current
`TipChamfer`, `PrintSlop`, and resolution controls while fixing their identifying head, drive,
size, and profile selections. Console `ECHO` records identify each grid position.

![LogoSC fastener gallery](images/fastener-gallery.png)

## Nut and assembly parameters

- **`NutScale`** multiplies the nominal nut across-flats width without changing its threaded
  bore. Increase it for more wall material around large-clearance or coarse printed threads.
- **`NutThickness`** is nut height in millimeters. Zero uses the automatic value of
  approximately 0.8 times nominal diameter.
- **`AssemblyNutPosition`** requests the Z position of the nut's lower face along the bolt. The
  model clamps it to the shaft and snaps it to the slice grid so the visualized male and female
  meshes retain the same helical phase.

## Resolution parameters

- **`RadialSegments`** controls facets around cylinders and LogoSC circle profiles. Default 60;
  Customizer range 24-256.
- **`ThreadSlicesPerTurn`** controls axial layers in every complete helical turn. Default 15;
  range 8-128. It strongly affects diagonal thread smoothness.
- **`ProfileSamplesPerTurn`** controls target sampling density while converting the evaluated
  LogoSC contour into the polar thread seed. Default 25; range 12-128. It affects curved and
  sloped profile fidelity.

The defaults are intended for interactive modeling. Raise resolution for a final large print in
small steps: mesh size and CGAL render time can grow rapidly when all three controls increase.

## Boolean and printing details

OpenSCAD can show missing faces or unstable previews when a cutter ends exactly on the top or
bottom of a positive solid. Every difference cutter in this model overruns both faces by the
hidden `FastenerDifferenceTolerance = 0.01 + 0` value. This applies to drive recesses, the nut's
thread cutter, and both nut entry chamfers. The separate `FastenerEpsilon` and
`FastenerThreadOverlap` values join positive geometry; they are not print-clearance controls.

For a new printer/material combination, render a short coarse bolt and nut first. Print them in
the intended orientation, test several `PrintSlop` values, and save the successful value with
the slicer and material profile. Printed fasteners are demonstrations unless their load capacity
has been established independently.

[asme-b18-6-3]: https://www.asme.org/getmedia/c0cd5b72-b6a7-4cf2-871f-08f3ec78cbe3/35224.pdf
[iso-4757]: https://www.iso.org/standard/10742.html
[iso-261]: https://www.iso.org/standard/4165.html
[asme-b1-1]: https://www.asme.org/codes-standards/find-codes-standards/b1-1-unified-inch-screw-threads-un-unr-thread-form

## ⚠ WARNING: PRINTED FASTENER STRENGTH IS UNKNOWN

> [!WARNING]
> Nuts, bolts, and screws generated by this model have unknown strength. Print orientation,
> layer adhesion, material, moisture, temperature, aging, slicer settings, dimensions, and
> defects can all cause sudden failure. Do **not** use these printed fasteners for structural,
> load-bearing, safety-critical, pressure-containing, vehicle, lifting, climbing, electrical,
> or other real-world applications unless the exact printed design and production process have
> undergone serious engineering review and representative destructive load testing with an
> appropriate safety factor. When failure could injure someone or damage property, use a
> properly specified and certified manufactured fastener instead.
