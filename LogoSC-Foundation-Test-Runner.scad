// ============================================================================
// LogoSC-Foundation-Test-Runner.scad
//
// Direct entry point for the complete LogoSC regression suite.
//
// Core intentionally has no dependency on this runner or the test definitions.
// Optional validation and both passive test suites are assembled here rather
// than included by LogoSC-Foundation-Core.scad.
// ============================================================================

include <LogoSC-Foundation-Core.scad>
include <LogoSC-Foundation-Validation.scad>
include <LogoSC-Foundation-Tests.scad>
include <LogoSC-Foundation-Validation-Tests.scad>

// Keep direct test runs concise unless a maintainer raises tracing explicitly.
TraceLevel = 0; // [0:4]

RunAllLogoTestSuites();
