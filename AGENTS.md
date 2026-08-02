# LogoSC Agent Guidance

This repository is the authoritative source for LogoSC. Do not reconstruct project facts
from conversation memory when the current working tree provides them.

## Start Here

Before changing files:

1. Confirm the Git repository root, current branch, and working-tree status.
2. Read `docs/ai-engineering-kit/AI-Engineering-Kit-Handoff.md` and follow its order.
3. Read `LogoSC-Developer-Notebook.md`, `README.md`, `CHANGELOG.md`,
   `CONTRIBUTING.md`, and task-relevant public or implementation documentation.
4. Summarize the current state and any inconsistencies before substantial changes.

The short reusable setup explanation is
`docs/ai-engineering-kit/Codex-Git-Project-Quick-Start.md`.

The LogoSC-specific command-line verification guide is
`LogoSC-OpenSCAD-Command-Line.md`.

## Project Boundaries

- LogoSC evaluates command lists into 2D polygonal regions.
- Native OpenSCAD remains responsible for 3D operations and ordinary composition.
- Preserve stable public APIs, including `RenderLogo2D()`, `RenderContours2D()`,
  `RenderRegion2D()`, `RenderLogoDebug()`, `evalLogo()`, `evalLogoPaths()`,
  `ValidateLogoPaths()`, `ReportLogoValidation()`, their accessors, region helpers, and
  existing command opcodes.
- `RenderLogoDebug()` is preview-only diagnostic geometry, not a manufacturable stroke API.
- Preserve exact filenames, documentation assets, historical rationale, and LF line endings.

## Working Style

- Prefer small, focused, backward-compatible changes.
- Keep implementation, tests, examples, public documentation, changelog, and notebook
  rationale synchronized when applicable.
- Favor relative `MOVE`, `TURN`, and `ARC` commands inside reusable LogoSC shapes.
- Do not perform broad renames, redesign stable APIs, or remove historical notebook entries
  without an explicit decision.
- Treat the AI Engineering Kit as maintainer-facing companion material, not LogoSC public API.

## Verification and Delivery

- Run or inspect `LogoSC-Foundation-Test-Runner.scad` after source changes when the tooling
  is available; require its final `LOGOSC_AUTOMATED_TEST_RESULT` to be `PASS`, and follow
  `LogoSC-OpenSCAD-Command-Line.md` for the tested console workflow.
- For Markdown navigation, estimate one page as 500 words. Add a linked table of contents to
  every Markdown document over 1,000 words and an alphabetical subject index to every Markdown
  document over 5,000 words. Keep both synchronized when headings or indexed topics change.
- Keep `LogoTestFailFast` false for complete acceptance runs; enable it only to isolate the
  first failed immutable result with OpenSCAD's assertion trace.
- For documentation changes, verify local links, anchors, code fences, and referenced assets.
- Review `git diff` and `git status` before declaring completion.
- Local Codex edits change the actual Git working tree. Do not stage, commit, push, rewrite
  history, or move tags unless the user asks.
- When the agent can verify that it is editing the user's active Git working tree, do not
  create a ZIP unless the user asks for one. Deliver through the working tree and report
  `git status` instead.
- If Git is unavailable, the workspace is only a temporary or attachment-based copy, or direct
  working-tree integration cannot be verified, create one combined ZIP containing every changed
  or added project file under its exact repository-relative path. Keep transfer artifacts
  outside Git.
