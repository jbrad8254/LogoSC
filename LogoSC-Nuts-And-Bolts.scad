// LogoSC customizable nuts, bolts, and screws.
//
// LogoSC defines the reusable 2D thread, head, and drive-recess profiles.
// Native OpenSCAD performs the helical extrusion, booleans, and final 3D
// composition. Thread dimensions are practical printable approximations rather
// than certified ISO, ASME, or other standards-compliant tolerance classes.

/* [Model] */

// Select the model to display or export.
Part = "Bolt"; // [Bolt,Nut,Assembly,Profile,Algorithm Figure,Gallery (Slow!)]
// Metric choices use common coarse pitches; inch choices use the shown TPI.
ScrewSize = "M8"; // [M3,M4,M5,M6,M8,M10,M12,M14,M16,M18,M20,M22,M24,M27,M30,M33,M36,#8-32,1/4-20,5/16-18,3/8-16,1/2-13,5/8-11,3/4-10,1-8,Custom]
// Major diameter used only when ScrewSize is Custom, in millimeters.
CustomDiameter = 8; // [2:0.1:80]
// Axial pitch used only when ScrewSize is Custom, in millimeters.
CustomPitch = 1.25; // [0.25:0.05:12]
// Threaded shaft length from the head bearing face to the tip, in millimeters.
Length = 20; // [5:1:300]

/* [Thread] */

// Select the conventional axial/radial thread profile.
ThreadProfile = "V60"; // [V60,Whitworth55,ACME29,Trapezoidal30,Buttress7/45,Square]
// Select the thread helix direction.
Handedness = "Right"; // [Right,Left]
// Select the number of intertwined thread starts.
ThreadStarts = 1; // [1:1:4]
// Radial clearance per side, applied to the female thread cutter.
PrintSlop = 0.25; // [0:0.05:1]
// Taper both external-thread ends and both nut entries by this amount.
TipChamfer = 0.6; // [0:0.1:3]

/* [Head and Drive] */

// Select the external head shape independently of its drive recess.
HeadType = "Hex"; // [Hex,Pan,Round,Countersunk Flat Head,Carriage,Grub (Headless)]
// Select the tool engagement feature cut into the head.
DriveType = "None"; // [None,Slotted,Phillips,Hex Socket]
// Select a type-specific drive preset; these are not shared millimeter sizes.
DriveSize = "Auto"; // [Auto,#0,#1,#2,#3,#4,#5,Custom]
// Drive dimension used for Custom: slot width, Phillips span, or hex across flats.
CustomDriveSize = 3; // [0.5:0.1:20]
// Scale the nominal head width and height.
HeadScale = 1.0; // [0.6:0.05:1.6]

/* [Nut and Assembly] */

// Scale the nominal nut across-flats width.
NutScale = 1.0; // [0.7:0.05:1.8]
// Override nut thickness in millimeters; zero selects the automatic thickness.
NutThickness = 0; // [0:0.5:60]
// Place the nut this far from the bolt bearing face in Assembly mode.
AssemblyNutPosition = 12; // [0:0.5:250]

/* [Resolution] */

// Set circular facet count for cylinders and round LogoSC profiles.
RadialSegments = 60; // [24:1:256]
// Set axial mesh slices per complete helix turn.
ThreadSlicesPerTurn = 15; // [8:1:128]
// Set the target sampling density for each wrapped profile turn.
ProfileSamplesPerTurn = 25; // [12:1:128]

/* [Hidden] */

include <LogoSC-Foundation-Core.scad>
TraceLevel = 0;

FastenerEpsilon = 0.02;
FastenerConvexity = 20;
FastenerThreadOverlap = 0.04;
// Boolean cutters overrun both coincident surfaces by this amount.
FastenerDifferenceTolerance = 0.01 + 0;

// Return the selected nominal major diameter in millimeters.
function FastenerDiameter(size) =
      (size == "M3")      ? 3
    : (size == "M4")      ? 4
    : (size == "M5")      ? 5
    : (size == "M6")      ? 6
    : (size == "M8")      ? 8
    : (size == "M10")     ? 10
    : (size == "M12")     ? 12
    : (size == "M14")     ? 14
    : (size == "M16")     ? 16
    : (size == "M18")     ? 18
    : (size == "M20")     ? 20
    : (size == "M22")     ? 22
    : (size == "M24")     ? 24
    : (size == "M27")     ? 27
    : (size == "M30")     ? 30
    : (size == "M33")     ? 33
    : (size == "M36")     ? 36
    : (size == "#8-32")   ? 4.1656
    : (size == "1/4-20")  ? 6.35
    : (size == "5/16-18") ? 7.9375
    : (size == "3/8-16")  ? 9.525
    : (size == "1/2-13")  ? 12.7
    : (size == "5/8-11")  ? 15.875
    : (size == "3/4-10")  ? 19.05
    : (size == "1-8")     ? 25.4
    : CustomDiameter;

// Return the selected thread pitch in millimeters.
function FastenerPitch(size) =
      (size == "M3")      ? 0.5
    : (size == "M4")      ? 0.7
    : (size == "M5")      ? 0.8
    : (size == "M6")      ? 1.0
    : (size == "M8")      ? 1.25
    : (size == "M10")     ? 1.5
    : (size == "M12")     ? 1.75
    : (size == "M14")     ? 2
    : (size == "M16")     ? 2
    : (size == "M18")     ? 2.5
    : (size == "M20")     ? 2.5
    : (size == "M22")     ? 2.5
    : (size == "M24")     ? 3
    : (size == "M27")     ? 3
    : (size == "M30")     ? 3.5
    : (size == "M33")     ? 3.5
    : (size == "M36")     ? 4
    : (size == "#8-32")   ? 25.4 / 32
    : (size == "1/4-20")  ? 25.4 / 20
    : (size == "5/16-18") ? 25.4 / 18
    : (size == "3/8-16")  ? 25.4 / 16
    : (size == "1/2-13")  ? 25.4 / 13
    : (size == "5/8-11")  ? 25.4 / 11
    : (size == "3/4-10")  ? 25.4 / 10
    : (size == "1-8")     ? 25.4 / 8
    : CustomPitch;

// Return a useful across-flats dimension for the selected nominal size.
// Values are common defaults for the listed sizes; Custom uses a simple ratio.
function FastenerAcrossFlats(size, diameter) =
      (size == "M3")      ? 5.5
    : (size == "M4")      ? 7
    : (size == "M5")      ? 8
    : (size == "M6")      ? 10
    : (size == "M8")      ? 13
    : (size == "M10")     ? 17
    : (size == "M12")     ? 19
    : (size == "M14")     ? 22
    : (size == "M16")     ? 24
    : (size == "M18")     ? 27
    : (size == "M20")     ? 30
    : (size == "M22")     ? 32
    : (size == "M24")     ? 36
    : (size == "M27")     ? 41
    : (size == "M30")     ? 46
    : (size == "M33")     ? 50
    : (size == "M36")     ? 55
    : (size == "#8-32")   ? 8.7313
    : (size == "1/4-20")  ? 11.1125
    : (size == "5/16-18") ? 12.7
    : (size == "3/8-16")  ? 14.2875
    : (size == "1/2-13")  ? 19.05
    : (size == "5/8-11")  ? 23.8125
    : (size == "3/4-10")  ? 28.575
    : (size == "1-8")     ? 38.1
    : 1.6 * diameter;

function FastenerHeadHeight(headType, diameter) =
      (headType == "Pan")                   ? 0.55 * diameter
    : (headType == "Round")                 ? 0.65 * diameter
    : (headType == "Countersunk Flat Head") ? 0.6 * diameter
    : (headType == "Carriage")              ? 0.55 * diameter
    : (headType == "Grub (Headless)")        ? 0
    : 0.65 * diameter;

function FastenerAutoDriveIndex(diameter) =
      (diameter <= 2.5) ? 0
    : (diameter <= 4)   ? 1
    : (diameter <= 7)   ? 2
    : (diameter <= 10)  ? 3
    : (diameter <= 14)  ? 4
    : 5;

function FastenerDriveIndex(driveSize, diameter) =
      (driveSize == "#0") ? 0
    : (driveSize == "#1") ? 1
    : (driveSize == "#2") ? 2
    : (driveSize == "#3") ? 3
    : (driveSize == "#4") ? 4
    : (driveSize == "#5") ? 5
    : FastenerAutoDriveIndex(diameter);

function FastenerPhillipsSpan(
    driveSize,
    diameter,
    customDriveSize = CustomDriveSize) =
    (driveSize == "Custom")
        ? customDriveSize
        : [2, 3, 4.5, 6, 8, 10][FastenerDriveIndex(driveSize, diameter)];

function FastenerSlotWidth(
    driveSize,
    diameter,
    customDriveSize = CustomDriveSize) =
    (driveSize == "Custom")
        ? customDriveSize
        : [0.6, 0.8, 1, 1.2, 1.6, 2][FastenerDriveIndex(driveSize, diameter)];

function FastenerHexSocketAcrossFlats(
    driveSize,
    diameter,
    customDriveSize = CustomDriveSize) =
    (driveSize == "Custom")
        ? customDriveSize
        : [1.5, 2, 2.5, 4, 5, 6][FastenerDriveIndex(driveSize, diameter)];

function FastenerNutHeight(diameter, nutThickness = NutThickness) =
    (nutThickness > 0) ? nutThickness : 0.8 * diameter;

function FastenerTwistDirection(handedness) =
    (handedness == "Right") ? -1 : 1;

function FastenerLerp(a, b, t) =
    [
        a[0] + (b[0] - a[0]) * t,
        a[1] + (b[1] - a[1]) * t
    ];

function FastenerSamePoint(a, b) =
    a[0] == b[0] && a[1] == b[1];

// Convert conventional profile points into one explicitly closed LogoSC path.
// The points use X as axial distance and Y as radial height above the core.
function FastenerLogoPath(points) =
    concat(
        [
            [PENUP],
            [GOTO, points[0][0], points[0][1], 0],
            [PENDOWN]
        ],
        [
            for (pointIndex = [1 : len(points) - 1])
                [GOTO, points[pointIndex][0], points[pointIndex][1], 0]
        ],
        [[GOTO, points[0][0], points[0][1], 0]]
    );

// Construct a symmetric V-thread ridge while preserving the requested included
// flank angle. Crest and root truncations are printable approximations.
function FastenerVProfilePoints(
    pitch,
    includedAngle,
    depthRatio,
    crestRatio) =
    let(
        depth = depthRatio * pitch,
        flankAngle = (180 - includedAngle) / 2,
        crestWidth = crestRatio * pitch,
        baseWidth = crestWidth + 2 * depth / tan(flankAngle)
    )
    [
        [-baseWidth / 2, 0],
        [-crestWidth / 2, depth],
        [ crestWidth / 2, depth],
        [ baseWidth / 2, 0]
    ];

// Construct an ACME-style or ISO trapezoidal ridge. The included angle is
// measured between the two flanks; the nominal thread depth is half the pitch.
function FastenerTrapezoidProfilePoints(pitch, includedAngle) =
    let(
        depth = 0.5 * pitch,
        crestWidth = 0.5 * pitch,
        flankRun = depth * tan(includedAngle / 2),
        baseWidth = crestWidth + 2 * flankRun
    )
    [
        [-baseWidth / 2, 0],
        [-crestWidth / 2, depth],
        [ crestWidth / 2, depth],
        [ baseWidth / 2, 0]
    ];

// Construct a simplified 7/45 buttress ridge with 0.6-pitch engagement depth.
// The profile is shifted so its full base is centered on one pitch cell.
function FastenerButtressProfilePoints(pitch) =
    let(
        depth = 0.6 * pitch,
        crestWidth = 0.1 * pitch,
        loadRun = depth * tan(7),
        trailingRun = depth / tan(45),
        left = -crestWidth / 2 - loadRun,
        right = crestWidth / 2 + trailingRun,
        centerShift = (left + right) / 2
    )
    [
        [left - centerShift, 0],
        [-crestWidth / 2 - centerShift, depth],
        [ crestWidth / 2 - centerShift, depth],
        [right - centerShift, 0]
    ];

// Construct a Whitworth-style 55-degree ridge with a sampled rounded crest.
// The standard root rounding is approximated by the cylindrical core surface.
function FastenerWhitworthProfilePoints(pitch, capSegments = 8) =
    let(
        includedAngle = 55,
        flankAngle = (180 - includedAngle) / 2,
        depth = 0.640327 * pitch,
        crestRadius = 0.137329 * pitch,
        centerY = depth - crestRadius,
        tangentOffset = 90 - flankAngle,
        leftAngle = 180 - tangentOffset,
        rightAngle = tangentOffset,
        leftTangent =
        [
            crestRadius * cos(leftAngle),
            centerY + crestRadius * sin(leftAngle)
        ],
        baseHalfWidth =
            -leftTangent[0] + leftTangent[1] / tan(flankAngle)
    )
    concat(
        [[-baseHalfWidth, 0]],
        [
            for (capIndex = [0 : capSegments])
                let(
                    angle = leftAngle
                        + (rightAngle - leftAngle) * capIndex / capSegments
                )
                [
                    crestRadius * cos(angle),
                    centerY + crestRadius * sin(angle)
                ]
        ],
        [[baseHalfWidth, 0]]
    );

// Return the selected conventional axial/radial thread-ridge profile.
function FastenerProfilePoints(profile, pitch) =
      (profile == "V60")
        ? FastenerVProfilePoints(pitch, 60, 0.61343, 0.125)
    : (profile == "Whitworth55")
        ? FastenerWhitworthProfilePoints(pitch)
    : (profile == "ACME29")
        ? FastenerTrapezoidProfilePoints(pitch, 29)
    : (profile == "Trapezoidal30")
        ? FastenerTrapezoidProfilePoints(pitch, 30)
    : (profile == "Buttress7/45")
        ? FastenerButtressProfilePoints(pitch)
    : [
        [-pitch / 4, 0],
        [-pitch / 4, pitch / 2],
        [ pitch / 4, pitch / 2],
        [ pitch / 4, 0]
    ];

function FastenerProfileDepth(profile, pitch) =
    max([for (point = FastenerProfilePoints(profile, pitch)) point[1]]);

// Return the number of samples required before nonlinearly wrapping one profile
// segment around the thread axis. More axial span needs more angular samples.
function FastenerProfileSegmentSamples(
    a,
    b,
    lead,
    samplesPerTurn = ProfileSamplesPerTurn) =
    max(
        1,
        ceil(abs(b[0] - a[0]) * samplesPerTurn / lead),
        ceil(abs(b[1] - a[1]) * samplesPerTurn / (2 * lead))
    );

// Resample a closed LogoSC contour so nonlinear polar mapping does not replace
// long arcs and helical flanks with incorrect straight chords.
function FastenerResampleContour(
    contour,
    lead,
    samplesPerTurn = ProfileSamplesPerTurn) =
    let(
        contourCount = len(contour),
        uniqueCount =
            contourCount > 1
            && FastenerSamePoint(contour[0], contour[contourCount - 1])
                ? contourCount - 1
                : contourCount
    )
    [
        for (segmentIndex = [0 : uniqueCount - 1])
            let(
                a = contour[segmentIndex],
                b = contour[(segmentIndex + 1) % uniqueCount],
                segmentSamples =
                    FastenerProfileSegmentSamples(
                        a,
                        b,
                        lead,
                        samplesPerTurn
                    )
            )
            for (sampleIndex = [0 : segmentSamples - 1])
                FastenerLerp(a, b, sampleIndex / segmentSamples)
    ];

// Map an axial/radial profile point into the XY seed consumed by OpenSCAD's
// twisted linear extrusion. The opposite phase makes an axial section of the
// final helix reproduce the original LogoSC profile.
function FastenerWrapPoint(point, coreRadius, lead, twistDirection) =
    let(
        radius = coreRadius + point[1],
        angle = twistDirection * 360 * point[0] / lead
    )
    [radius * cos(angle), radius * sin(angle)];

// Evaluate the LogoSC thread profile, resample it, and render the polar-mapped
// 2D seed used by linear_extrude(twist). Profiles currently contain no holes.
module RenderFastenerThreadSeed(
    profileCommands,
    coreRadius,
    lead,
    twistDirection)
{
    result = evalLogo(profileCommands);
    regions = ResultContours(result);

    for (region = regions)
    {
        contour = RegionOuter(region);

        if (len(contour) >= 3)
        {
            sampledContour = FastenerResampleContour(contour, lead);
            wrappedContour =
            [
                for (point = sampledContour)
                    FastenerWrapPoint(
                        point,
                        coreRadius,
                        lead,
                        twistDirection
                    )
            ];

            polygon(points = wrappedContour, convexity = FastenerConvexity);
        }
    }
}

// Render only the helical ridge. The extrusion extends one pitch beyond each
// end so callers can clip it cleanly to a shaft or cutting-tool envelope.
module RenderFastenerThreadRidge(
    diameter,
    pitch,
    length,
    profile,
    starts,
    handedness,
    radialOffset = 0)
{
    profilePoints = FastenerProfilePoints(profile, pitch);
    profileCommands = FastenerLogoPath(profilePoints);
    profileDepth = FastenerProfileDepth(profile, pitch);
    coreRadius = diameter / 2 - profileDepth + radialOffset;
    lead = pitch * starts;
    twistDirection = FastenerTwistDirection(handedness);
    overrun = pitch;
    targetHeight = length + 2 * overrun;
    slices = max(4, ceil(targetHeight * ThreadSlicesPerTurn / lead));
    extrusionHeight = slices * lead / ThreadSlicesPerTurn;
    turns = slices / ThreadSlicesPerTurn;

    assert(coreRadius > 0, "Thread profile is too deep for this diameter.");

    translate([0, 0, -overrun])
    {
        linear_extrude(
            height = extrusionHeight,
            center = false,
            convexity = FastenerConvexity,
            twist = twistDirection * 360 * turns,
            slices = slices)
        {
            for (startIndex = [0 : starts - 1])
            {
                rotate(startIndex * 360 / starts)
                {
                    RenderFastenerThreadSeed(
                        profileCommands,
                        coreRadius,
                        lead,
                        twistDirection
                    );
                }
            }
        }
    }
}

// Render a complete externally threaded rod. A positive radialOffset is used
// for the female cutter; the visible bolt normally leaves it at zero.
module RenderFastenerThreadedRod(
    diameter,
    pitch,
    length,
    profile,
    starts,
    handedness,
    radialOffset = 0,
    tipChamfer = 0,
    entryChamfer = 0,
    axialOverrun = 0)
{
    profileDepth = FastenerProfileDepth(profile, pitch);
    majorRadius = diameter / 2 + radialOffset;
    coreRadius = majorRadius - profileDepth;
    joinedCoreRadius = coreRadius + FastenerThreadOverlap;
    safeTipChamfer = min(tipChamfer, length / 2);
    safeEntryChamfer = min(entryChamfer, length / 2);
    renderStart = -axialOverrun;
    renderLength = length + 2 * axialOverrun;
    middleStart = renderStart + safeEntryChamfer;
    middleLength =
        renderLength - safeEntryChamfer - safeTipChamfer;

    assert(length > 0, "Thread length must be positive.");
    assert(coreRadius > 0, "Thread profile is too deep for this diameter.");
    assert(tipChamfer >= 0, "Thread tip chamfer must not be negative.");
    assert(entryChamfer >= 0, "Thread entry chamfer must not be negative.");
    assert(axialOverrun >= 0, "Thread axial overrun must not be negative.");

    intersection()
    {
        union()
        {
            translate([0, 0, renderStart])
            {
                cylinder(
                    h = renderLength,
                    r = joinedCoreRadius,
                    center = false,
                    $fn = RadialSegments
                );
            }

            RenderFastenerThreadRidge(
                diameter,
                pitch,
                length,
                profile,
                starts,
                handedness,
                radialOffset
            );
        }

        if (safeEntryChamfer > 0 || safeTipChamfer > 0)
        {
            union()
            {
                if (safeEntryChamfer > 0)
                {
                    translate([0, 0, renderStart])
                    {
                        cylinder(
                            h = safeEntryChamfer,
                            r1 = max(
                                coreRadius,
                                majorRadius - safeEntryChamfer
                            ),
                            r2 = majorRadius + FastenerEpsilon,
                            center = false,
                            $fn = RadialSegments
                        );
                    }
                }

                if (middleLength > 0)
                {
                    translate([0, 0, middleStart])
                    {
                        cylinder(
                            h = middleLength,
                            r = majorRadius + FastenerEpsilon,
                            center = false,
                            $fn = RadialSegments
                        );
                    }
                }

                if (safeTipChamfer > 0)
                {
                    translate(
                        [0, 0, renderStart + renderLength - safeTipChamfer])
                    {
                        cylinder(
                            h = safeTipChamfer,
                            r1 = majorRadius + FastenerEpsilon,
                            r2 = max(
                                coreRadius,
                                majorRadius - safeTipChamfer
                            ),
                            center = false,
                            $fn = RadialSegments
                        );
                    }
                }
            }
        }
        else
        {
            translate([0, 0, renderStart])
            {
                cylinder(
                    h = renderLength,
                    r = majorRadius + FastenerEpsilon,
                    center = false,
                    $fn = RadialSegments
                );
            }
        }
    }
}

module RenderFastenerHexProfile(acrossFlats)
{
    circumradius = acrossFlats / sqrt(3);
    RenderLogo2D([[REGPOLY, 6, circumradius, 30]]);
}

module RenderFastenerRoundProfile(diameter)
{
    RenderLogo2D([[CIRCLE, diameter / 2, RadialSegments]]);
}

// Render a pan-head blank with a short tapered cap. Both 2D source sections are
// LogoSC circles; native linear_extrude supplies height and taper.
module RenderFastenerPanHeadBlank(headDiameter, headHeight)
{
    capHeight = 0.35 * headHeight;
    bodyHeight = headHeight - capHeight;

    translate([0, 0, -bodyHeight])
    {
        linear_extrude(
            height = bodyHeight,
            center = false,
            convexity = FastenerConvexity)
        {
            RenderFastenerRoundProfile(headDiameter);
        }
    }

    translate([0, 0, -headHeight])
    {
        linear_extrude(
            height = capHeight + FastenerEpsilon,
            center = false,
            convexity = FastenerConvexity,
            scale = 1 / 0.82)
        {
            RenderFastenerRoundProfile(0.82 * headDiameter);
        }
    }
}

// Render a more strongly domed round head from stacked LogoSC circle sections.
module RenderFastenerRoundHeadBlank(headDiameter, headHeight)
{
    lowerHeight = 0.45 * headHeight;
    upperHeight = headHeight - lowerHeight;

    translate([0, 0, -lowerHeight])
    {
        linear_extrude(
            height = lowerHeight,
            center = false,
            convexity = FastenerConvexity)
        {
            RenderFastenerRoundProfile(headDiameter);
        }
    }

    translate([0, 0, -headHeight])
    {
        linear_extrude(
            height = upperHeight + FastenerEpsilon,
            center = false,
            convexity = FastenerConvexity,
            scale = 1 / 0.55)
        {
            RenderFastenerRoundProfile(0.55 * headDiameter);
        }
    }
}

module RenderFastenerCountersunkFlatHeadBlank(
    headDiameter,
    headHeight,
    shaftDiameter)
{
    translate([0, 0, -headHeight])
    {
        linear_extrude(
            height = headHeight + FastenerEpsilon,
            center = false,
            convexity = FastenerConvexity,
            scale = shaftDiameter / headDiameter)
        {
            RenderFastenerRoundProfile(headDiameter);
        }
    }
}

module RenderFastenerCarriageHeadBlank(
    headDiameter,
    headHeight,
    shaftDiameter)
{
    neckWidth = 1.05 * shaftDiameter;
    neckHeight = 0.25 * shaftDiameter;

    RenderFastenerRoundHeadBlank(headDiameter, headHeight);

    translate([0, 0, -FastenerEpsilon])
    {
        linear_extrude(
            height = neckHeight + FastenerEpsilon,
            center = false,
            convexity = FastenerConvexity)
        {
            RenderLogo2D([[RECT, neckWidth, neckWidth]]);
        }
    }
}

// Extrude a drive cutter from either end and overrun both depth boundaries.
module RenderFastenerInwardExtrude(
    surfaceZ,
    recessDepth,
    inwardDirection,
    bottomScale = 1)
{
    cutterHeight = recessDepth + 2 * FastenerDifferenceTolerance;

    assert(
        inwardDirection == 1 || inwardDirection == -1,
        "Drive recess direction must be 1 or -1."
    );

    if (inwardDirection == 1)
    {
        translate([0, 0, surfaceZ - FastenerDifferenceTolerance])
        {
            linear_extrude(
                height = cutterHeight,
                center = false,
                convexity = FastenerConvexity,
                scale = bottomScale)
            {
                children();
            }
        }
    }
    else
    {
        translate([0, 0, surfaceZ + FastenerDifferenceTolerance])
        {
            rotate([180, 0, 0])
            {
                linear_extrude(
                    height = cutterHeight,
                    center = false,
                    convexity = FastenerConvexity,
                    scale = bottomScale)
                {
                    children();
                }
            }
        }
    }
}

// Phillips recess arms narrow toward the bottom to approximate the angled
// flanks of a real cross recess instead of subtracting a square-sided cross.
module RenderFastenerPhillipsRecess(
    outerDiameter,
    surfaceZ,
    availableDepth,
    diameter,
    driveSize,
    customDriveSize,
    inwardDirection)
{
    topSpan = min(
        FastenerPhillipsSpan(driveSize, diameter, customDriveSize),
        0.85 * outerDiameter
    );
    armWidth = 0.24 * topSpan;
    recessDepth = min(0.75 * topSpan, 0.7 * availableDepth);

    RenderFastenerInwardExtrude(
        surfaceZ,
        recessDepth,
        inwardDirection,
        bottomScale = 0.32)
    {
        RenderLogo2D(
        [
            [RECT, topSpan, armWidth],
            [TURN, 90],
            [RECT, topSpan, armWidth]
        ]);
    }
}

// The slot intentionally extends beyond both edges of the head's top section.
module RenderFastenerSlotRecess(
    outerDiameter,
    surfaceZ,
    availableDepth,
    diameter,
    driveSize,
    customDriveSize,
    inwardDirection)
{
    recessLength = outerDiameter + 2 * FastenerDifferenceTolerance;
    recessWidth = min(
        FastenerSlotWidth(driveSize, diameter, customDriveSize),
        0.3 * outerDiameter
    );
    recessDepth = min(0.8 * recessWidth, 0.65 * availableDepth);

    RenderFastenerInwardExtrude(
        surfaceZ,
        recessDepth,
        inwardDirection)
    {
        RenderLogo2D([[RECT, recessLength, recessWidth]]);
    }
}

module RenderFastenerHexSocketRecess(
    outerDiameter,
    surfaceZ,
    availableDepth,
    diameter,
    driveSize,
    customDriveSize,
    inwardDirection)
{
    acrossFlats = min(
        FastenerHexSocketAcrossFlats(
            driveSize,
            diameter,
            customDriveSize
        ),
        0.75 * outerDiameter
    );
    recessDepth = min(0.9 * acrossFlats, 0.7 * availableDepth);

    RenderFastenerInwardExtrude(
        surfaceZ,
        recessDepth,
        inwardDirection)
    {
        RenderFastenerHexProfile(acrossFlats);
    }
}

module RenderFastenerDriveRecess(
    driveType,
    driveSize,
    outerDiameter,
    surfaceZ,
    availableDepth,
    diameter,
    customDriveSize,
    inwardDirection = 1)
{
    if (driveType == "Slotted")
    {
        RenderFastenerSlotRecess(
            outerDiameter,
            surfaceZ,
            availableDepth,
            diameter,
            driveSize,
            customDriveSize,
            inwardDirection
        );
    }
    else if (driveType == "Phillips")
    {
        RenderFastenerPhillipsRecess(
            outerDiameter,
            surfaceZ,
            availableDepth,
            diameter,
            driveSize,
            customDriveSize,
            inwardDirection
        );
    }
    else if (driveType == "Hex Socket")
    {
        RenderFastenerHexSocketRecess(
            outerDiameter,
            surfaceZ,
            availableDepth,
            diameter,
            driveSize,
            customDriveSize,
            inwardDirection
        );
    }
}

// Render the selected blank below Z=0 so Length follows normal fastener
// convention: bearing surface to shaft tip.
module RenderFastenerHeadBlank(
    headType,
    diameter,
    acrossFlats,
    headHeight,
    headScale)
{
    roundHeadDiameter = 1.9 * diameter * headScale;

    if (headType == "Hex")
    {
        translate([0, 0, -headHeight])
        {
            linear_extrude(
                height = headHeight + FastenerEpsilon,
                center = false,
                convexity = FastenerConvexity)
            {
                RenderFastenerHexProfile(acrossFlats * headScale);
            }
        }
    }
    else if (headType == "Pan")
    {
        RenderFastenerPanHeadBlank(roundHeadDiameter, headHeight);
    }
    else if (headType == "Round")
    {
        RenderFastenerRoundHeadBlank(roundHeadDiameter, headHeight);
    }
    else if (headType == "Countersunk Flat Head")
    {
        RenderFastenerCountersunkFlatHeadBlank(
            roundHeadDiameter,
            headHeight,
            diameter
        );
    }
    else if (headType == "Carriage")
    {
        RenderFastenerCarriageHeadBlank(
            roundHeadDiameter,
            headHeight,
            diameter
        );
    }
}

module RenderLogoSCBolt(
    screwSize = ScrewSize,
    length = Length,
    threadProfile = ThreadProfile,
    handedness = Handedness,
    threadStarts = ThreadStarts,
    chamfer = TipChamfer,
    headType = HeadType,
    driveType = DriveType,
    driveSize = DriveSize,
    customDriveSize = CustomDriveSize,
    headScale = HeadScale)
{
    diameter = FastenerDiameter(screwSize);
    pitch = FastenerPitch(screwSize);
    acrossFlats = FastenerAcrossFlats(screwSize, diameter);
    headHeight = FastenerHeadHeight(headType, diameter) * headScale;
    roundHeadDiameter = 1.9 * diameter * headScale;
    isHeadless = headType == "Grub (Headless)";
    headOuterDiameter = (headType == "Hex")
        ? 2 * acrossFlats * headScale / sqrt(3)
        : isHeadless ? diameter : roundHeadDiameter;
    driveSurfaceZ = isHeadless ? length : -headHeight;
    driveDepth = isHeadless ? 0.6 * diameter : headHeight;
    driveInwardDirection = isHeadless ? -1 : 1;

    assert(diameter > 0, "Fastener diameter must be positive.");
    assert(pitch > 0, "Thread pitch must be positive.");
    assert(customDriveSize > 0, "CustomDriveSize must be positive.");
    assert(chamfer >= 0, "TipChamfer must not be negative.");

    difference()
    {
        union()
        {
            RenderFastenerThreadedRod(
                diameter,
                pitch,
                length,
                threadProfile,
                threadStarts,
                handedness,
                radialOffset = 0,
                tipChamfer = chamfer,
                entryChamfer = chamfer
            );

            if (!isHeadless)
            {
                RenderFastenerHeadBlank(
                    headType,
                    diameter,
                    acrossFlats,
                    headHeight,
                    headScale
                );
            }
        }

        if (driveType != "None")
        {
            RenderFastenerDriveRecess(
                driveType,
                driveSize,
                headOuterDiameter,
                driveSurfaceZ,
                driveDepth,
                diameter,
                customDriveSize,
                driveInwardDirection
            );
        }
    }
}

// Render a hex nut and subtract a slightly enlarged copy of the matching male
// thread. PrintSlop is radial clearance per side, not diametral clearance.
module RenderLogoSCNut(
    screwSize = ScrewSize,
    threadProfile = ThreadProfile,
    handedness = Handedness,
    threadStarts = ThreadStarts,
    printSlop = PrintSlop,
    chamferControl = TipChamfer,
    nutScale = NutScale,
    nutThickness = NutThickness)
{
    diameter = FastenerDiameter(screwSize);
    pitch = FastenerPitch(screwSize);
    acrossFlats =
        FastenerAcrossFlats(screwSize, diameter) * nutScale;
    nutHeight = FastenerNutHeight(diameter, nutThickness);
    chamfer = min(chamferControl, pitch, nutHeight / 4);
    openingRadius = diameter / 2 + printSlop + chamfer;

    assert(printSlop >= 0, "PrintSlop must not be negative.");
    assert(chamferControl >= 0, "TipChamfer must not be negative.");

    difference()
    {
        linear_extrude(
            height = nutHeight,
            center = false,
            convexity = FastenerConvexity)
        {
            RenderFastenerHexProfile(acrossFlats);
        }

        RenderFastenerThreadedRod(
            diameter,
            pitch,
            nutHeight,
            threadProfile,
            threadStarts,
            handedness,
            radialOffset = printSlop,
            tipChamfer = 0,
            entryChamfer = 0,
            axialOverrun = FastenerDifferenceTolerance
        );

        translate([0, 0, -FastenerDifferenceTolerance])
        {
            cylinder(
                h = chamfer + 2 * FastenerDifferenceTolerance,
                r1 = openingRadius,
                r2 = diameter / 2 + printSlop,
                center = false,
                $fn = RadialSegments
            );
        }

        translate(
            [0, 0, nutHeight - chamfer - FastenerDifferenceTolerance])
        {
            cylinder(
                h = chamfer + 2 * FastenerDifferenceTolerance,
                r1 = diameter / 2 + printSlop,
                r2 = openingRadius,
                center = false,
                $fn = RadialSegments
            );
        }
    }
}

module RenderLogoSCAssembly()
{
    diameter = FastenerDiameter(ScrewSize);
    pitch = FastenerPitch(ScrewSize);
    lead = pitch * ThreadStarts;
    twistDirection = FastenerTwistDirection(Handedness);
    nutHeight = FastenerNutHeight(diameter);
    sliceHeight = lead / ThreadSlicesPerTurn;
    requestedPosition =
        min(max(AssemblyNutPosition, 0), max(0, Length - nutHeight));
    safePosition = round(requestedPosition / sliceHeight) * sliceHeight;
    nutRotation = -twistDirection * 360 * safePosition / lead;

    color("lightsteelblue")
    {
        RenderLogoSCBolt();
    }

    color("gold")
    {
        translate([0, 0, safePosition])
        {
            rotate([0, 0, nutRotation])
            {
                RenderLogoSCNut();
            }
        }
    }
}

module RenderFastenerGalleryBolt(
    label,
    position,
    screwSize,
    headType,
    driveType,
    driveSize = "Auto",
    length = 10,
    threadProfile = "V60",
    modelColor = "lightsteelblue")
{
    diameter = FastenerDiameter(screwSize);
    galleryHeadScale = 0.9;
    headHeight =
        FastenerHeadHeight(headType, diameter) * galleryHeadScale;

    echo("LogoSC fastener gallery", label, position);

    color(modelColor)
    {
        translate([position[0], position[1], headHeight])
        {
            RenderLogoSCBolt(
                screwSize = screwSize,
                length = length,
                threadProfile = threadProfile,
                chamfer = TipChamfer,
                headType = headType,
                driveType = driveType,
                driveSize = driveSize,
                headScale = galleryHeadScale
            );
        }
    }
}

module RenderFastenerGalleryNut(
    label,
    position,
    screwSize,
    threadProfile = "V60",
    modelColor = "gold")
{
    echo("LogoSC fastener gallery", label, position);

    color(modelColor)
    {
        translate([position[0], position[1], 0])
        {
            RenderLogoSCNut(
                screwSize = screwSize,
                threadProfile = threadProfile,
                chamferControl = TipChamfer
            );
        }
    }
}

// Render a stable four-column by two-row overview of the supported head,
// drive, and fastener families. Models share the current clearance and
// resolution controls so the gallery is also a useful preview-quality check.
module RenderLogoSCFastenerGallery()
{
    spacing = 30;

    RenderFastenerGalleryBolt(
        "M10 hex bolt",
        [0 * spacing, 0 * spacing],
        "M10",
        "Hex",
        "None",
        modelColor = "lightsteelblue"
    );
    RenderFastenerGalleryBolt(
        "M8 slotted pan screw",
        [1 * spacing, 0 * spacing],
        "M8",
        "Pan",
        "Slotted",
        modelColor = "palegreen"
    );
    RenderFastenerGalleryBolt(
        "M8 Phillips round screw",
        [2 * spacing, 0 * spacing],
        "M8",
        "Round",
        "Phillips",
        modelColor = "plum"
    );
    RenderFastenerGalleryBolt(
        "M8 countersunk hex-socket screw",
        [3 * spacing, 0 * spacing],
        "M8",
        "Countersunk Flat Head",
        "Hex Socket",
        modelColor = "lightsalmon"
    );

    RenderFastenerGalleryBolt(
        "M8 carriage bolt",
        [0 * spacing, 1 * spacing],
        "M8",
        "Carriage",
        "None",
        modelColor = "khaki"
    );
    RenderFastenerGalleryBolt(
        "M10 headless hex-socket screw",
        [1 * spacing, 1 * spacing],
        "M10",
        "Grub (Headless)",
        "Hex Socket",
        modelColor = "turquoise"
    );
    RenderFastenerGalleryNut(
        "M10 V-thread nut",
        [2 * spacing, 1 * spacing],
        "M10",
        modelColor = "gold"
    );
    RenderFastenerGalleryNut(
        "M12 trapezoidal-thread nut",
        [3 * spacing, 1 * spacing],
        "M12",
        threadProfile = "Trapezoidal30",
        modelColor = "orchid"
    );
}

module RenderSelectedThreadProfile()
{
    pitch = FastenerPitch(ScrewSize);
    baseDepth = 0.2 * pitch;
    profilePoints = FastenerProfilePoints(ThreadProfile, pitch);
    profileCommands = FastenerLogoPath(profilePoints);
    baseCommands = [[RECT, pitch, baseDepth]];

    echo("LogoSC fastener profile points", profilePoints);
    echo("LogoSC fastener profile commands", profileCommands);

    linear_extrude(
        height = max(0.5, 0.3 * pitch),
        center = true,
        convexity = FastenerConvexity)
    {
        translate([0, -baseDepth / 2])
        {
            RenderLogo2D(baseCommands, convexity = FastenerConvexity);
        }
        RenderLogo2D(profileCommands, convexity = FastenerConvexity);
    }
}

// Show the conventional axial/radial profiles beside the polar thread seed.
// This is documentation geometry: the right panel is the actual 2D input to
// linear_extrude(twist), equivalent to inspecting one unextruded mesh slice.
module RenderFastenerAlgorithmFigure()
{
    diameter = FastenerDiameter(ScrewSize);
    pitch = FastenerPitch(ScrewSize);
    nStarts = ThreadStarts;
    lead = pitch * nStarts;
    profilePoints = FastenerProfilePoints(ThreadProfile, pitch);
    profileCommands = FastenerLogoPath(profilePoints);
    profileDepth = FastenerProfileDepth(ThreadProfile, pitch);
    coreRadius = diameter / 2 - profileDepth;
    profileResult = evalLogo(profileCommands);
    profileRegions = ResultContours(profileResult);
    profileContours =
    [
        for (region = profileRegions)
            if (len(RegionOuter(region)) >= 3)
                RegionOuter(region)
    ];
    profileContour = profileContours[0];
    sampledContour = FastenerResampleContour(profileContour, lead);
    wrappedSampledContour =
    [
        for (point = sampledContour)
            FastenerWrapPoint(
                point,
                coreRadius,
                lead,
                FastenerTwistDirection(Handedness)
            )
    ];
    baseDepth = max(0.12 * pitch, 0.08);
    panelSpan = max(lead, diameter);
    panelOffset = 0.78 * panelSpan;
    labelSize = max(0.35 * pitch, 0.6);
    figureHeight = max(0.3, 0.18 * pitch);
    markerRadius = max(0.025 * pitch, 0.04);

    assert(nStarts >= 1, "ThreadStarts must be at least one.");
    assert(len(profileContours) == 1, "Algorithm figure expects one profile contour.");
    assert(coreRadius > 0, "Thread profile is too deep for this diameter.");

    echo(
        "LogoSC fastener algorithm figure",
        "profileCommands", profileCommands,
        "evaluatedContourPoints", len(profileContour),
        "samplesPerStart", len(sampledContour),
        "nStarts", nStarts,
        "totalSeedSamples", nStarts * len(sampledContour)
    );

    color("lightsteelblue")
    {
        translate([-panelOffset, -baseDepth / 2, 0])
        {
            linear_extrude(height = figureHeight, center = false)
            {
                square([lead, baseDepth], center = true);
            }
        }

        translate([panelOffset, 0, 0])
        {
            linear_extrude(height = figureHeight, center = false)
            {
                RenderFastenerRoundProfile(2 * coreRadius);
            }
        }
    }

    color("gold")
    {
        for (startIndex = [0 : nStarts - 1])
        {
            translate(
                [
                    -panelOffset
                        + (startIndex - (nStarts - 1) / 2) * pitch,
                    0,
                    0
                ])
            {
                linear_extrude(height = figureHeight, center = false)
                {
                    RenderLogo2D(
                        profileCommands,
                        convexity = FastenerConvexity
                    );
                }
            }

            translate([panelOffset, 0, 0])
            {
                rotate([0, 0, startIndex * 360 / nStarts])
                {
                    linear_extrude(height = figureHeight, center = false)
                    {
                        RenderFastenerThreadSeed(
                            profileCommands,
                            coreRadius,
                            lead,
                            FastenerTwistDirection(Handedness)
                        );
                    }
                }
            }
        }
    }

    color("slategray")
    {
        linear_extrude(height = figureHeight, center = false)
        {
            polygon(
                points =
                [
                    [-0.35 * panelSpan, -0.08 * panelSpan],
                    [ 0.18 * panelSpan, -0.08 * panelSpan],
                    [ 0.18 * panelSpan, -0.16 * panelSpan],
                    [ 0.35 * panelSpan,  0],
                    [ 0.18 * panelSpan,  0.16 * panelSpan],
                    [ 0.18 * panelSpan,  0.08 * panelSpan],
                    [-0.35 * panelSpan,  0.08 * panelSpan]
                ]
            );
        }
    }

    labelY = -diameter / 2 - 1.5 * labelSize;

    color("black")
    {
        for (startIndex = [0 : nStarts - 1])
        {
            translate(
                [
                    -panelOffset
                        + (startIndex - (nStarts - 1) / 2) * pitch,
                    0,
                    figureHeight
                ])
            {
                for (point = sampledContour)
                {
                    translate([point[0], point[1], 0])
                    {
                        linear_extrude(height = FastenerEpsilon, center = false)
                        {
                            circle(r = markerRadius, $fn = 12);
                        }
                    }
                }
            }

            translate([panelOffset, 0, figureHeight])
            {
                rotate([0, 0, startIndex * 360 / nStarts])
                {
                    for (point = wrappedSampledContour)
                    {
                        translate([point[0], point[1], 0])
                        {
                            linear_extrude(
                                height = FastenerEpsilon,
                                center = false)
                            {
                                circle(r = markerRadius, $fn = 12);
                            }
                        }
                    }
                }
            }
        }

        for (label =
            [
                [
                    -panelOffset,
                    str(len(sampledContour), " samples/start")
                ],
                [ panelOffset, str("nStarts = ", nStarts, " polar seed")]
            ])
        {
            translate([label[0], labelY, 0])
            {
                linear_extrude(height = figureHeight, center = false)
                {
                    text(
                        label[1],
                        size = labelSize,
                        halign = "center",
                        valign = "center"
                    );
                }
            }
        }
    }
}

echo(
    "LogoSC fastener",
    "part", Part,
    "size", ScrewSize,
    "diameter", FastenerDiameter(ScrewSize),
    "pitch", FastenerPitch(ScrewSize),
    "profile", ThreadProfile,
    "handedness", Handedness,
    "starts", ThreadStarts,
    "head", HeadType,
    "drive", DriveType,
    "driveSize", DriveSize,
    "printSlopPerSide", PrintSlop
);

if (Part == "Bolt")
{
    RenderLogoSCBolt();
}
else if (Part == "Nut")
{
    RenderLogoSCNut();
}
else if (Part == "Assembly")
{
    RenderLogoSCAssembly();
}
else if (Part == "Gallery (Slow!)" || Part == "Gallery")
{
    RenderLogoSCFastenerGallery();
}
else if (Part == "Algorithm Figure" || Part == "Algorithm")
{
    RenderFastenerAlgorithmFigure();
}
else
{
    RenderSelectedThreadProfile();
}
