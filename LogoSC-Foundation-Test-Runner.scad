// ============================================================================
// LogoSC-Foundation-Test-Runner.scad
//
// Direct entry point for the complete LogoSC regression suite.
//
// Core intentionally has no dependency on this runner or the test definitions.
// Future optional validation implementation and test files should be assembled
// here rather than included by LogoSC-Foundation-Core.scad.
// ============================================================================

include <LogoSC-Foundation-Core.scad>
include <LogoSC-Foundation-Tests.scad>

// Keep direct test runs concise unless a maintainer raises tracing explicitly.
TraceLevel = 0; // [0:4]

RunAllLogoSCests();
