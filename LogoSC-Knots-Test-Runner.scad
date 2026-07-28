// Direct entry point for the optional LogoSC knot companion suite.

include <LogoSC-Foundation-Core.scad>
include <LogoSC-Foundation-Tests.scad>
include <LogoSC-Knots.scad>
include <LogoSC-Knots-Tests.scad>

TraceLevel = 0;
LogoTestFailFast = false;

RunAllKnotTests();
