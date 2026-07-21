# Engineering Preferences

> This document is **not part of LogoSC** or any other specific repository.
> It is a reusable engineering handbook describing the user's preferred
> coding, documentation, review, and delivery practices.
>
> Provide it to a new ChatGPT conversation when starting or continuing a
> software project so the assistant can follow these preferences consistently.
>
> **Current LogoSC exception:** the user explicitly requested that this companion handbook
> be stored under `docs/ai-engineering-kit/`. LogoSC-specific repository guidance takes
> precedence whenever it differs from these generic preferences.

# Purpose

This document records durable engineering preferences that should carry across projects.

Project-specific rules belong in the repository.
Collaboration behavior belongs in `ChatGPT-Project-Workflow.md`.
This document records the user's general engineering standards.

# General Principles

- Prefer clarity over cleverness.
- Prefer explicit behavior over implicit behavior.
- Make incremental changes.
- Avoid unrelated cleanup during focused work.
- Preserve backward compatibility unless a deliberate breaking change is approved.
- Treat documentation, examples, and tests as part of the implementation.
- Explain important tradeoffs before making architectural changes.
- Preserve historical context and design rationale.

# Coding Style

## Formatting

- Use 4 spaces for indentation.
- Use Allman braces.
- Use a soft line-length limit of 100 characters.
- Use a hard line-length limit of 120 characters.
- Keep formatting consistent with the surrounding project.

## Naming

### C and C++

- Prefer clear, descriptive names.
- Declare pointers as `int* ptr`, not `int *ptr`.
- Avoid unnecessary abbreviations.
- Prefer explicit types over inference when the type is not immediately obvious.

### C#

- Use PascalCase for types and methods.
- Use camelCase for local variables and fields.
- Use `var` only when the assigned type is obvious from the right-hand side.
- Prefer explicit declarations when they improve readability.

## Functions

For any function longer than approximately five lines, include documentation covering:

- Purpose
- Preconditions
- Postconditions
- Time complexity when meaningful
- Space complexity when meaningful

Keep functions focused on one responsibility.

Avoid:

- Excessive nesting
- Hidden side effects
- Dense one-line logic
- Clever expressions that obscure intent
- Large functions that mix unrelated concerns

# Error Handling

- Validate inputs at clear API boundaries.
- Fail with useful diagnostics.
- Avoid silently ignoring invalid states.
- Preserve enough context in error messages to support debugging.
- Distinguish user errors, data errors, and internal invariants.

# API Design

- Keep public APIs small and coherent.
- Prefer orthogonal additions over changing established semantics.
- Avoid exposing implementation details.
- Use names that communicate intent without requiring source inspection.
- Document compatibility implications before changing existing behavior.
- Prefer additive deprecation paths over abrupt removal.

# Documentation

Documentation is part of the product.

Update relevant documentation whenever behavior changes.

Depending on the project, consider:

- README
- User Manual
- API reference
- Cheat Sheet
- Examples
- CHANGELOG
- Developer Notebook
- CONTRIBUTING

Documentation should explain:

- What the feature does
- Why it exists
- How to use it
- Important limitations
- Compatibility implications

Avoid repeating long design discussions across multiple files. Put detailed rationale in
the Developer Notebook or design notes, then link to it.

# Examples

Examples should be:

- Small
- Deterministic
- Easy to copy
- Representative of normal use
- Written using preferred public APIs

Examples should double as regression tests whenever practical.

Introduce simple examples before advanced ones.

# Testing

For user-visible changes:

- Add or update regression tests where practical.
- Verify unrelated tests still pass.
- Verify representative examples still work.
- Test boundary conditions and failure modes.
- Check that documentation matches actual behavior.

Prefer deterministic tests.

Avoid tests that depend unnecessarily on:

- Wall-clock time
- Network access
- Randomness without a fixed seed
- Machine-specific paths
- Unstable external services

# Review Expectations

Before considering work complete, check:

- Is the implementation understandable?
- Is the API coherent?
- Are edge cases covered?
- Is backward compatibility preserved?
- Are documentation and examples current?
- Are tests sufficient?
- Did unrelated files change?
- Is the repository cleanly packageable?

For broad changes, separate design review from implementation when practical.

# Versioning and Releases

Before a release:

- Consolidate unreleased changelog entries.
- Update version constants and metadata.
- Verify release notes.
- Verify documentation.
- Verify examples and tests.
- Verify required assets and licenses.
- Record significant design decisions.
- Confirm the release package contains the expected files.

Use release notes to explain user-visible value, not merely list internal edits.

# Packaging and File Delivery

Choose the delivery mode from the environment rather than generating a ZIP automatically.

When the AI system is integrated with the user's active Git working tree:

- Confirm the repository root with Git.
- Confirm `git status` and `git diff` show the files being edited.
- Leave the verified changes in that working tree for the user's normal review and commit.
- Do not create a ZIP unless the user requests one.
- Do not stage, commit, push, rewrite history, or move tags unless requested.

Use fallback ZIP delivery when Git is unavailable, repository integration cannot be verified,
the work occurs in a temporary or attachment-based copy, the user cannot inspect the edited
tree directly, or the user asks for an archive. In that case:

- Use exact repository filenames and paths.
- Include every changed or added file.
- Preserve the repository directory structure.
- Produce one combined ZIP rather than separate per-file downloads.
- Ensure the ZIP can be extracted directly over the repository.
- Verify expected files are physically present before delivery.
- Do not rename project files merely to create unique download names.

When adding images:

- Use project-relative paths.
- Verify the Markdown reference.
- Verify the physical image file exists in the working tree or fallback package.

# Repository Discipline

- The repository is the authoritative source.
- Start work from the current user-approved Git working tree or the latest provided
  repository snapshot.
- Do not merge older versions from memory or previous chats unless explicitly asked.
- Avoid blind global replacements.
- Preserve unrelated accepted sections.
- Check for regressions before delivery.

# Working with ChatGPT

A fresh ChatGPT conversation should:

1. Read the repository's developer guidance first.
2. Summarize the current state before making substantial changes.
3. Follow project-specific rules over generic preferences when they conflict.
4. Suggest relevant improvements without derailing the requested task.
5. Record important decisions in project documentation.
6. Deliver through the verified Git working tree or use the project's fallback ZIP workflow.

The assistant should provide technical leadership, not merely execute literal requests.

This includes identifying:

- Inconsistencies
- Missing tests
- Documentation drift
- Release opportunities
- Architectural risks
- Useful future work

Suggestions should remain proportional and should not turn every small task into a redesign.

# Final Preference

When several solutions are viable, prefer the one that is:

1. Clearer
2. Easier to maintain
3. Easier to test
4. Better documented
5. Backward compatible
6. Less surprising to users
