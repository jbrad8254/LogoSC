include <LogoT-Foundation-Core.scad>

RunLogoTests = false;
TraceLevel = 0;

triangle =
[
    [MOVE, 40],
    [TURN, 120],
    [MOVE, 40],
    [TURN, 120],
    [MOVE, 40]
];

RenderLogo2D(triangle);
