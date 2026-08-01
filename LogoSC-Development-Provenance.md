# LogoSC Development Provenance

LogoSC was developed primarily through a long-running, human-directed collaboration between its
maintainer and OpenAI AI coding assistants. AI assistance contributed substantially to design
exploration, implementation, documentation, testing, review, and the preservation of engineering
history.

Project direction, design acceptance, release decisions, publication, and ongoing stewardship
remain under human control. The maintainer selected goals, evaluated proposals, supplied domain
judgment, approved public behavior, and decided when work was ready to publish.

## What AI assistance contributed

AI coding assistants participated in work including:

- exploring algorithms and API designs;
- implementing and revising OpenSCAD code;
- creating deterministic tests and visual examples;
- diagnosing failures and compatibility risks;
- writing and synchronizing user and developer documentation;
- reviewing repository consistency, links, assets, and release readiness; and
- recording design rationale for future maintainers.

The amount and kind of assistance varied by feature. This document therefore describes the
project-level development method rather than attempting to assign authorship percentages to
individual lines or files.

## Human direction and accountability

AI assistants did not independently own or publish LogoSC. The maintainer remained responsible
for choosing the project's purpose and boundaries, accepting or rejecting changes, authorizing
Git operations and releases, and stewarding the resulting public project.

Human direction is more than supplying an initial prompt. LogoSC developed through repeated
review, correction, testing, design decisions, and decisions about what not to build. The current
repository reflects that collaboration rather than an unattended one-pass code generation event.

## Evidence and quality

AI involvement is neither evidence that a feature is correct nor evidence that it is defective.
LogoSC's engineering claims should be evaluated through the same inspectable evidence expected of
other software:

- stable documented public APIs;
- deterministic automated tests;
- representative OpenSCAD smoke exports;
- visual galleries and regression scenes;
- command-line verification records;
- reviewed documentation and design rationale; and
- Git history connecting releases to exact source states.

Published packages are generated from the authoritative Git repository and identified by release
and source commit. Bugs are corrected in that repository, covered by proportional regression
checks, and distributed through the next synchronized release.

## Limits of AI-generated analysis

AI assistants can misunderstand requirements, propose unsuitable abstractions, produce plausible
but incorrect code, or overstate what a test proves. LogoSC's workflow reduces those risks through
repository-first inspection, small compatible changes, explicit acceptance suites, documentation
synchronization, diff review, and human release approval. These practices reduce risk but do not
guarantee defect-free software.

Users must still evaluate LogoSC output for their own application. This is especially important
for manufacturing decisions and for printed fasteners, whose performance depends on material,
printer, slicer, orientation, wear, geometry, and loading. Neither AI involvement nor a passing
software test constitutes a structural rating.

## Contributions and review

Contributions should be evaluated by behavior, compatibility, evidence, documentation, and
maintainability rather than accepted or rejected solely because an AI tool was or was not used.
Contributors remain responsible for understanding and reviewing what they submit, respecting
applicable licenses, disclosing important limitations, and providing the tests and explanation
needed to maintain the change.

When AI assistance materially affects a contribution, concise disclosure is encouraged where it
helps reviewers understand the development or verification process. Generated text should not be
used to fabricate test results, provenance, measurements, citations, or human review that did not
occur.

## Where the complete record lives

Every published LogoSC suite contains a concise provenance statement in
`LogoSC-Suite-Guide.md`. The Developer publication includes this fuller explanation. The complete
Git repository additionally preserves the Developer Notebook, agent guidance, AI Engineering Kit,
retrospectives, commit history, tests, and release records that document how the collaboration
operated over time.

The complete repository is the authoritative source for development history, current code, bug
reports, and corrections. Packaged or storefront copies of this statement are release artifacts,
not independently maintained histories.
