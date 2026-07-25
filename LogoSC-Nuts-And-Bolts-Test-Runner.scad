// ============================================================================
// LogoSC-Nuts-And-Bolts-Test-Runner.scad
//
// Direct entry point for deterministic, non-rendering fastener tests.
// The fastener application is imported with use so its top-level model
// selection and rendering dispatch do not execute.
// ============================================================================

include <LogoSC-Foundation-Core.scad>
include <LogoSC-Foundation-Tests.scad>

// OpenSCAD include behaves like inserting the complete target file here, so
// including the fastener application would also execute its bottom-level
// Bolt/Nut/Gallery selection and create slow 3D geometry. use imports its
// function and module definitions without executing those top-level statements.
// The tests can therefore call the real Fastener* calculation functions while
// this runner remains deterministic and produces no rendered model. The passive
// test-definition file below is safe to include because it contains definitions
// only and has no automatic test or geometry entry point.
use <LogoSC-Nuts-And-Bolts.scad>
include <LogoSC-Nuts-And-Bolts-Tests.scad>

TraceLevel = 0;

RunAllLogoFastenerTests();
