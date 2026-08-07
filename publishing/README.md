# LogoSC Publishing Sources

This directory contains the canonical inputs and reproducible builder for the generated LogoSC
Mini, Core, Developer, Knots & Celtic Designs, and Nuts & Bolts publications. The complete policy
is in `../LogoSC-Release-Manual.md`.

## Directory map

```text
publishing/
  packages/       Exact package manifests and staged verification definitions.
  docs/           Package-specific README, guide, and cheat-sheet sources.
  descriptions/   Short Thingiverse listing descriptions.
  images/         Generated Thingiverse cover images.
  releases/       Prepared GitHub release-note bodies.
  build-packages.ps1
```

Generated ZIPs and verification artifacts go to the ignored `dist/` directory. Do not edit a
staged file or ZIP and treat it as a new source; change the canonical repository file or
publishing input and rebuild every affected package.

## Build every package

Windows may block direct script execution under its normal policy. The following command applies a
one-process bypass without changing the machine's persistent execution policy:

```powershell
& powershell.exe `
    -NoProfile `
    -ExecutionPolicy Bypass `
    -File '.\publishing\build-packages.ps1'
```

The default build:

- validates every manifest input;
- stages each package independently;
- copies the shared Suite Guide and all LogoSC-produced PNGs;
- adds the package README, Thingiverse description and cover, license, version record, and
  inventory;
- rejects missing OpenSCAD dependencies and Markdown image assets;
- runs package-specific OpenSCAD acceptance checks;
- creates portable ZIP entries with forward-slash paths;
- calculates SHA-256 archive hashes; and
- writes package and verification JSON reports.

Use `-KeepStaging` when inspecting or running additional checks against the exact staged files.
Use `-Package mini,core` to select package keys. `-SkipOpenScadVerification` exists for an
environment without OpenSCAD, but output from that mode is not ready for publication.

## Version identity

From a clean tag matching the Core version, such as `v2026.8`, the archives use that release
identity. A mismatched clean tag is rejected. From an untagged or dirty working tree, the builder
uses an explicit unreleased identity containing the Core version and base commit; dirty output is
a review artifact, not a final public release.

After committing publishing-source changes, rebuild so the package version record points to the
commit that actually contains them. For a formal publication, complete normal release preparation,
create the authorized matching tag, then rebuild all five packages from that clean tag.

## Cover-image provenance

The five current Thingiverse covers were generated with OpenAI's built-in image-generation tool
using existing LogoSC render images as factual visual references. They are promotional
illustrations, not test evidence or exact manufacturing previews. Actual LogoSC renders in
`../images/` remain the engineering and documentation evidence.

The final prompt sets deliberately omit embedded titles, logos, and watermarks because storefront
text supplies the project name. When replacing a cover, inspect it for plausible printable
geometry and avoid unsupported performance or structural implications.
