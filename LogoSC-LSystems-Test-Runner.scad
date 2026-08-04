// Direct entry point for the optional LogoSC L-system companion suite.

include <LogoSC-Foundation-Core.scad>
include <LogoSC-Foundation-Tests.scad>
include <LogoSC-LSystems.scad>
include <LogoSC-LSystems-Tests.scad>

TraceLevel = 0;
LogoTestFailFast = false;

RunAllLSystemTests();

