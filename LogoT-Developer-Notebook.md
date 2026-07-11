
# LogoT Developer Notebook
### Long-Term Project Context and Chat Restart Guide

## Purpose

This document is the long-term engineering notebook for the LogoT project.

Its primary purpose is **to reinitialize ChatGPT after an old chat has been
retired and a new chat has been started**. Read this document before making any
changes. It captures the project's architecture, design rationale, conventions,
workflow, lessons learned, and deferred ideas so that work resumes from the
same mental model rather than reconstructing it from memory.

Treat this notebook as a **living document**. Add to it over time; do not trim
it unless obsolete information is being replaced.

---

# 1. Project Summary

LogoT is a compact Logo-inspired language embedded in OpenSCAD for generating
closed **2D polygonal regions** suitable for CAD modeling and 3D printing.

LogoT evaluates command lists into region data. OpenSCAD performs all 3D
operations such as extrusion, booleans, transforms, colors, and offsets.

Core philosophy:

- Small API.
- Readable command lists.
- Reusable geometry.
- OpenSCAD remains responsible for modeling.

---

# 2. Stable Public API

Rendering:
- RenderLogo2D()
- RenderContours2D()
- RenderRegion2D()

Evaluation:
- evalLogo()

Accessors:
- ResultState()
- ResultContours()
- ResultStack()
- ResultPen()

Region helpers:
- MakeRegion()
- RegionOuter()
- RegionHoles()

Avoid breaking these without a version bump.

---

# 3. Design Philosophy

- Generate regions, not meshes.
- Favor clarity over cleverness.
- CAD usefulness takes priority over perfect historical Logo compatibility.
- Keep OpenSCAD wrappers outside LogoT.

---

# 4. Non-Goals

- Do not replace OpenSCAD.
- Do not wrap linear_extrude(), rotate_extrude(), union(), difference(),
  offset(), color(), transforms, etc.
- Do not let the stroke renderer replace the region renderer.
- Avoid API bloat.

---

# 5. Documentation Conventions

The User Manual is the primary document.

Structure:

1. Setup
2. Quick Start
3. Concepts
4. Cheat Sheet
5. Examples
6. API
7. Advanced Topics

Section 7 is the canonical API reference.

Store screenshots in:

    images/

using relative Markdown links.

---

# 6. Packaging Rules

- Exact repository filenames.
- One combined ZIP per work session.
- Only changed files in update ZIP.
- Repository ZIP is authoritative.

---

# 7. Workflow

Preferred workflow:

1. User commits changes.
2. Repository ZIP uploaded.
3. Read this notebook.
4. Use uploaded repository as source of truth.
5. Produce incremental updates.

---

# 8. Lessons Learned

## Documentation regressions

Always edit the latest user-approved repository or document.

Never regenerate documentation from an older copy.

Verify previously accepted sections remain present before packaging.

## Verification

Before delivering documentation:

- Verify requested changes exist.
- Verify unrelated sections remain unchanged.
- Verify screenshots and links still exist.

## Repository synchronization

If uncertainty exists about the current baseline, stop and ask for the latest
repository ZIP or latest working document.

---

# 9. Current Architecture

- Integer opcodes.
- Region-based evaluator.
- Separate evaluation and rendering.
- Multiple contours and holes.
- Public accessor APIs.
- Rendering modules separate from evaluation.

---

# 10. Current Roadmap

- Stroke/debug renderer.
- More examples.
- More screenshots.
- Continue documentation polish.
- L-system improvements.
- Additional CAD primitives when justified.

---

# 11. Stroke Rendering

Keep stroke rendering as a separate API.

Purpose:

- Debugging.
- Educational visualization.
- Turtle-path inspection.
- PENUP/PENDOWN visualization.

Never complicate the primary region renderer.

---

# 12. Milestones

- v0.2.0-alpha released.
- Expanded API documentation.
- Added Quick Start.
- Added screenshot-based documentation.

Update this section after each release.

---

# 13. Open Questions

Track unresolved design questions here instead of relying on chat history.

---

# 14. Common Regression Risks

- Editing stale documentation.
- Renaming repository files.
- Accidentally changing public API.
- Mixing experimental features into stable interfaces.

---

# 15. User Preferences (LogoT Project)

- Exact filenames only.
- Git-friendly updates.
- Combined ZIP per session.
- Favor MOVE/TURN in examples where appropriate.
- Use rounded engineering documentation style.

---

# 16. Next Suggested Tasks

Maintain this list as priorities evolve.

