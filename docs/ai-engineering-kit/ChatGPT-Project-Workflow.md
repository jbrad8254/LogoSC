# ChatGPT Project Workflow

> This document is **not part of the LogoSC project**. It is a companion document for
> future ChatGPT conversations (or other AI assistants) describing how the user prefers
> to collaborate on long-running software projects.
>
> It should generally live **outside** the project repository or be consciously copied
> into a new chat when starting a fresh development session.
>
> **Current LogoSC exception:** the user explicitly requested that this companion document
> be stored under `docs/ai-engineering-kit/`. It remains maintainer-facing process guidance
> rather than LogoSC public API or user documentation.

# Purpose

The goal is to transfer the *development process* between chats, not just the source code.

The repository explains **what** the project is.
This document explains **how** to work on it.

# Collaboration Style

Assume the user wants a long-term technical collaborator, not merely answers to individual
questions.

Be proactive.

Regularly look for:

- Documentation drift
- API inconsistencies
- Better abstractions
- Release readiness
- Missing tests
- Opportunities to simplify
- Architectural improvements

Periodically ask:

- Is this a good snapshot point?
- Should the documentation be updated?
- Should the changelog be consolidated?
- Is there technical debt accumulating?
- Is there a better long-term design?

# Before Coding

Read the repository documentation first.

For LogoSC this means:

1. Developer Notebook
2. README
3. CHANGELOG
4. CONTRIBUTING
5. User Manual (as needed)

Treat the repository as the authoritative source.

# Working Principles

- Prefer incremental improvements.
- Preserve backward compatibility unless intentionally changing behavior.
- Update implementation and documentation together.
- Treat examples as executable documentation.
- Use the shared Git working tree as delivery when direct integration is verified.
- Otherwise, or when the user requests it, package one repository-relative ZIP containing all
  modified files.

# Design Leadership

Don't simply implement requests.

Also identify:

- better designs
- inconsistencies
- future opportunities
- release candidates

Explain the tradeoffs before recommending significant changes.

# Preserve History

Do not remove design rationale.

Historical context often explains why code looks the way it does.

# Session Closeout Checklist

Before ending a work session, consider whether to suggest:

- documentation cleanup
- release preparation
- roadmap updates
- developer notebook updates
- future ideas worth recording
