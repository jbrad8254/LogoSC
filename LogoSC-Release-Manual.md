# LogoSC Release Manual

This manual defines how the authoritative LogoSC Git repository becomes the public LogoSC
suite. It is the persistent policy for package scope, shared documentation, verification,
versioning, ZIP creation, and publication. Release-specific facts remain in `CHANGELOG.md` and
the Git tag; architectural rationale remains in `LogoSC-Developer-Notebook.md`.

## 1. Publishing model

LogoSC has one source repository, one development history, and one bug-fix location. Mini,
Core, Developer, Knots & Celtic Designs, and Nuts & Bolts are generated publications from that
repository, not independent projects or branches.

All fixes must first be made and verified in the repository. Never patch a released ZIP as a
separate source. At a formal release, build and publish every suite from the same tagged commit,
even when a particular suite's functional code did not change. Lockstep versions give users a
simple compatibility rule: packages with the same LogoSC version were built and tested together.

The public catalog is:

| Publication | Purpose | Normal home |
|---|---|---|
| LogoSC Mini | First models and a deliberately small teaching surface | Thingiverse and GitHub release |
| LogoSC Core | Complete stable LogoSC language for model authors | Thingiverse and GitHub release |
| LogoSC Developer | Validation, tests, diagnostics, and engineering material | GitHub; optional Thingiverse listing |
| Knots & Celtic | Knots, braids, grids, ribbons, reliefs, and plaques | Thingiverse and GitHub |
| Nuts & Bolts | Customizable fasteners and thread profiles | Thingiverse and GitHub |
| Complete repository | All maintained project and workflow files | GitHub repository |

There is no separate Thingiverse Full edition. Every Thingiverse project points to the Git
repository for the complete source, issue reporting, history, and current development state.
The repository is effectively the complete edition without creating another product to publish.

## 2. Compatibility and ownership rules

- A program documented for Mini must run unchanged with Core and every larger applicable package.
- All packages preserve the same opcode values, syntax, coordinate conventions, scaling, and
  `RenderLogo2D()` behavior.
- `LogoSC-Foundation-Core.scad` must be byte-identical everywhere it appears in one release.
- Core remains a standalone one-file runtime. Validation and domain libraries remain optional.
- Knots and fasteners are specialized suites, not Core language levels.
- A self-contained specialized ZIP may duplicate Core; that duplication exists only in generated
  artifacts and prevents users from having to locate a matching second download.
- Do not create package branches or separately evolving copies of canonical source files.
- GitHub is the authoritative source and issue location. Storefront comments can identify a
  problem, but the durable report and fix belong in the repository.

## 3. Package scopes

Package manifests are the final authority for exact inventories. The following sections define
the intended boundaries that those manifests must implement.

### 3.1 LogoSC Mini

Mini is a teaching package, not a reduced dialect. Initially package the unchanged
`LogoSC-Foundation-Core.scad`; do not maintain a second interpreter merely to reduce file size.

The documented surface emphasizes:

- `MOVE`, `TURN`, and `ARC`;
- `REPEAT` and `RUN`;
- `CIRCLE`, `REGPOLY`, `RECT`, and `ROUNDEDRECT`;
- basic `HOLE` use;
- `RenderLogo2D()`; and
- one native `linear_extrude()` example.

Include the Core file, a small Customizer-friendly demonstration, several short progressive
examples, a Mini quick start, a compact Mini command card, the shared Suite Guide, representative
images, version metadata, and the license. Omit validation, test infrastructure, advanced
engineering documentation, domain companions, project history, and AI workflow material.

Prefer intentionally written teaching examples over mechanically deleting lines from advanced
ones. A physically smaller `LogoSC-Mini.scad` is justified only if demand establishes a real need;
it must then be generated from shared source or pass differential conformance tests against Core.

### 3.2 LogoSC Core

Core is the normal library distribution for people creating their own LogoSC models. Include:

- `LogoSC-Foundation-Core.scad`;
- maintained user examples that require only Core;
- the Core quick start and command cheat sheet;
- user-facing Core documentation and selected implementation guides;
- the shared Suite Guide, representative images, version metadata, changelog, and license.

Do not require validation, tests, knots, or fasteners. Documentation may link to those packages
as deliberate external destinations but must not imply that absent files are locally installed.

### 3.3 LogoSC Developer

Developer is for contributors and users who validate, test, diagnose, or extend LogoSC. Include
Core plus Foundation Validation, passive Foundation and Validation tests, the test runner,
diagnostic examples, the command-line verification guide, public implementation documents,
`CONTRIBUTING.md`, the shared Suite Guide, version metadata, changelog, and license.

Developer is public engineering material, not an AI-session archive. Exclude:

- `AGENTS.md`;
- `docs/ai-engineering-kit/`;
- Codex-specific workspace or handoff instructions; and
- `LogoSC-Developer-Notebook.md`, whose historical and AI-bootstrap roles make the complete Git
  repository its appropriate home.

The package README links to the repository when a developer needs complete design history.
Include `LogoSC-Development-Provenance.md` so Developer users receive a clear account of the
substantial AI contribution, human direction, verification basis, limitations, and contribution
expectations without packaging the internal AI workflow kit.

### 3.4 LogoSC Knots & Celtic Designs

The knot suite is a self-contained, visual maker project. Include Core, `LogoSC-Knots.scad`,
knot examples, the large Celtic-grid showcase, focused knot and large-grid documentation,
representative galleries, version metadata, the shared Suite Guide, and the license. Include its
test definitions and runner when the package manifest favors transparent verification over the
smallest download; do not create separate user and developer knot products until demand warrants
the additional publication burden.

The storefront presentation should lead with useful finished designs: mathematical knots and
links, braids and bundles, Celtic masks, ribbons, reliefs, and customizable plaques. It should
then explain that LogoSC produced them and link to Core for general LogoSC modeling.

### 3.5 LogoSC Nuts & Bolts

The fastener suite is a self-contained Customizer application. Include Core, the fastener model,
its detailed Customizer guide, representative images and models, version metadata, the shared
Suite Guide, and the license. Include fastener tests and the runner under the same single-package
policy used by Knots.

The storefront and packaged documentation must preserve the safety warning: printed fasteners
and material estimates are not structural ratings. Lead with sizes, thread profiles, heads,
drives, nuts, bolts, assemblies, resolution controls, and printable examples.

## 4. Documentation model

Do not maintain five independent general READMEs or manually trim the full manual for every
release. Package documentation has three levels:

1. A short package-specific README tells the user what the package is, which file to open, how
   to run the first example, what is included, and where to get help.
2. `LogoSC-Suite-Guide.md` is a shared illustrated guide included in every suite.
3. Detailed canonical documents are included only where their subject belongs.

The canonical shared guide is `LogoSC-Suite-Guide.md`. Its current image set includes every
LogoSC-produced PNG under `images/`; the third-party SVG knot references remain research inputs
rather than shared suite artwork.

### 4.1 Shared Suite Guide

The shared Suite Guide is a polished public catalog rather than a developer inventory. It must
describe:

- what LogoSC is and how it works with OpenSCAD;
- the five published suites and which one to choose;
- installation and version compatibility;
- illustrated Mini, Core, validation/developer, knot/Celtic, and fastener capabilities;
- the relationship between the independent suites and the complete repository;
- the canonical Git repository and issue-reporting location;
- a concise disclosure of the project's human-directed AI-assisted development; and
- license and release identification.

Every package includes the same generated guide and the same small, curated set of compressed
suite images. It must not reference a local image that the package omits. Storefront descriptions
may be shorter and more promotional, but should derive shared facts and links from the same
publishing metadata.

Use proportionate disclosure rather than hiding AI involvement or turning it into the main product
description. Every suite and storefront receives the concise Suite Guide statement. Developer
also receives `LogoSC-Development-Provenance.md`. The complete repository alone retains the AI
Engineering Kit, agent instructions, handoffs, and complete workflow history.

### 4.2 Canonical and generated documents

Canonical documentation is edited in the repository. Generated package READMEs, Suite Guides,
inventories, and storefront-description outputs are build artifacts and should identify their
source version. Do not edit an artifact and then treat it as authoritative.

Reusable facts such as installation steps, version, license, repository URL, issue URL, and suite
links should have one source. Package-specific introductions and first-run instructions may be
separate canonical fragments because each publication has a genuinely different audience.

Use explicit inclusion metadata or markers when extracting material from a larger document.
Do not make release correctness depend on an AI inferring where to cut prose on each run.

## 5. Examples and downloadable models

Classify canonical examples by role:

- teaching examples: short, progressive, and eligible for Mini onward;
- Core user examples: stable language and region workflows;
- engineering examples: validation, diagnostics, stress cases, and regression scenes;
- extension examples: knots, Celtic grids, and fasteners.

Package manifests select complete canonical files. Avoid maintaining edited package-only copies
of the same example. Thingiverse projects may additionally publish representative STL or 3MF
models, but their generating `.scad` source and parameters must be identifiable.

## 6. Publishing implementation

Maintain publishing inputs in a dedicated repository area, for example:

```text
publishing/
  packages/
    mini.json
    core.json
    developer.json
    knots.json
    fasteners.json
  descriptions/
    thingiverse-mini.md
    thingiverse-core.md
    thingiverse-developer.md
    thingiverse-knots.md
    thingiverse-fasteners.md
  shared/
    suite-guide sections and curated images
  build-packages.ps1
```

The exact layout may evolve, but retain these responsibilities:

- package manifests list exact files, document sections, images, entry points, and required tests;
- shared metadata supplies version, repository URL, issue URL, license, and publication links;
- the build script stages packages in a clean ignored or temporary directory;
- generated output never becomes a second development source; and
- ZIPs are created only after staged-package verification succeeds.

Each package must contain a generated version record with at least:

```text
LogoSC release: <tag>
Package: <suite name>
Source commit: <full commit id>
Repository: <canonical URL>
Bug reports: <canonical issue URL>
```

Use release ZIP names of the form:

```text
LogoSC-Mini-vYYYY.N.zip
LogoSC-Core-vYYYY.N.zip
LogoSC-Developer-vYYYY.N.zip
LogoSC-Knots-Celtic-vYYYY.N.zip
LogoSC-Nuts-Bolts-vYYYY.N.zip
```

## 7. Verification matrix

The build must fail rather than publish an incomplete package. Verify at least:

| Check | Mini | Core | Developer | Knots | Fasteners |
|---|---:|---:|---:|---:|---:|
| Manifest files and entry point exist | Yes | Yes | Yes | Yes | Yes |
| Package parses from its staging directory | Yes | Yes | Yes | Yes | Yes |
| Document links, anchors, and images resolve | Yes | Yes | Yes | Yes | Yes |
| Core is byte-identical to the tagged source | Yes | Yes | Yes | Yes | Yes |
| Foundation/Validation suite | Subset | Core | Complete | Dependency | Dependency |
| Knot suite and representative smoke export | No | No | No | Yes | No |
| Fastener suite and representative smoke export | No | No | No | No | Yes |

Also verify:

- Mini examples produce the same LogoSC results in every containing edition;
- package documentation does not present omitted files as local files;
- referenced images are physically included;
- generated models correspond to recorded source parameters;
- LF endings are preserved in repository sources;
- `git diff --check` is clean before release;
- no Git metadata, temporary exports, secrets, or AI workflow files enter public ZIPs; and
- ZIP contents and checksums are recorded in a release report.

Follow `LogoSC-OpenSCAD-Command-Line.md` for tested PowerShell quoting and OpenSCAD verification.
Do not treat measurements from incorrectly quoted `-D` string overrides as benchmark evidence.

## 8. Release and publication procedure

### 8.1 Prepare the repository

1. Confirm the repository root, branch, status, and intended release scope.
2. Synchronize code, tests, examples, public documentation, changelog, and rationale.
3. Run the complete Foundation/Validation, knot, and fastener acceptance suites as applicable.
4. Run documented smoke exports and documentation checks.
5. Review `git diff`, `git diff --check`, line endings, and `git status`.
6. Commit only when explicitly authorized and follow the repository's normal release-tag policy.

### 8.2 Build the publications

1. Build every suite from the same clean release candidate.
2. Stage each suite independently; never test only against files available elsewhere in the
   repository.
3. Generate its README, common Suite Guide, version record, inventory, and ZIP.
4. Run the verification matrix against the staged package.
5. Record archive size and checksum.
6. After the release tag exists, rebuild final artifacts from that exact tag and confirm their
   recorded commit.

### 8.3 Publish

1. Publish the GitHub release and its suite ZIPs.
2. Update each Thingiverse project with the matching release, even if only shared documentation
   or metadata changed.
3. Keep each Thingiverse description focused on its product while linking to the Suite Guide,
   repository, and canonical issue location.
4. Verify every uploaded archive and public link after publication.
5. Record the published URLs, tag, checksums, and any storefront-specific version identifiers.
6. Complete the repository's post-release changelog, notebook, and retrospective process.

If a storefront cannot practically accept an unchanged archive again, update its displayed
version and shared documentation as far as the platform permits, record the exception, and keep
the GitHub release as the authoritative artifact set.

## 9. Bug and support flow

Every package README and storefront page should direct durable bug reports to the Git repository.
Ask reporters for:

- LogoSC release and package name;
- OpenSCAD version and operating system;
- relevant `.scad` file and Customizer overrides;
- minimal reproduction;
- console output; and
- a screenshot or generated artifact when geometry is involved.

Fix the canonical repository, add proportional regression coverage, and deliver the correction in
the next synchronized release. Never designate a Thingiverse attachment or private corrected ZIP
as the maintained version.

## 10. Policy changes

Update this manual when package boundaries, publication destinations, shared-document strategy,
or release mechanics change. Record the reason for substantial policy changes in
`LogoSC-Developer-Notebook.md`. Do not duplicate release-specific histories here.
