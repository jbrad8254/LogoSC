# Project Retrospective

> This document is **not part of LogoSC's public user documentation**.
>
> It is a process record for the user and future ChatGPT conversations. Its purpose is to
> capture lessons about how the project was developed, how the collaboration evolved, and
> why a reusable set of workflow documents was created at this point.
>
> It may live outside the repository with the other reusable workflow documents, or be
> copied into a project's private development records when a project-specific retrospective
> is useful.
>
> **Current LogoSC exception:** the user explicitly requested that this retrospective and
> the other AI Engineering Kit documents be stored at the LogoSC repository root as private
> development-process records. They are not LogoSC public API or user documentation.

# Why This Document Exists

During development of LogoSC, the repository gradually became capable of preserving its own
technical history:

- The README explains the project to new users.
- The User Manual teaches the library.
- The Cheat Sheet provides quick reference.
- The CHANGELOG records user-visible changes.
- CONTRIBUTING describes repository-specific development conventions.
- The Developer Notebook preserves architecture, rationale, and historical decisions.

That solved the problem of transferring the **project** to a new conversation.

It did not fully solve the problem of transferring the **working relationship**.

A fresh ChatGPT conversation could read the repository and understand LogoSC, yet still behave
more passively than the conversation in which the project matured. The missing information was
not source code or architecture. It was the accumulated development process:

- when to suggest cleanup
- when to recommend a snapshot
- when to consolidate a changelog
- when to notice documentation drift
- when to protect an API from accidental redesign
- when to record design rationale
- when to think in terms of releases rather than isolated edits

This retrospective exists to preserve those lessons.

# Why the Supporting Documents Were Added Now

The reusable process documents were created because the project reached a transition point.

Earlier in development, most effort belonged in the implementation itself. Later, LogoSC had
become substantially more mature:

- the public API was stabilizing
- the debug visualization system existed
- examples were serving as practical regression coverage
- documentation had expanded into multiple coordinated documents
- licensing and release structure were established
- packaging rules had become consistent
- the Developer Notebook had become a reliable source of architectural memory

At that stage, the main risk was no longer merely losing code. The larger risk was losing the
reasoning and habits that had produced a coherent repository.

The workflow documents were therefore created as a separate layer of continuity.

# The Four-Document Model

The documents are intentionally separated by scope.

| Scope | Document | Purpose |
|---|---|---|
| The user | `Engineering-Preferences.md` | General engineering standards that carry across projects |
| User and ChatGPT | `ChatGPT-Project-Workflow.md` | Preferred collaboration behavior across conversations |
| New conversation startup | `Generic-Project-Bootstrap.md` | Concise repository-first startup instructions |
| Development process over time | `Project-Retrospective.md` | Process lessons and reasons for changes |

Project-specific knowledge remains inside each repository, usually in a Developer Notebook,
CONTRIBUTING file, README, CHANGELOG, and related design notes.

This separation avoids turning project documentation into a mixture of architecture, personal
preferences, AI instructions, and historical process commentary.

# Why These Documents Should Usually Remain Outside LogoSC

These documents were not created because LogoSC requires special treatment.

They were created because the same workflow is useful for:

- C++ projects
- C# applications
- OpenSCAD libraries
- simulation tools
- documentation-heavy repositories
- future projects that do not yet exist

Putting them inside LogoSC as ordinary project files would incorrectly imply that they are part
of LogoSC's design or public contribution requirements.

The better model is:

1. Keep reusable workflow documents in a personal project-startup bundle.
2. Keep project-specific engineering guidance inside the repository.
3. Give both to a new conversation when continuity matters.

# What Worked Well

## Repository-First Development

Treating the latest repository ZIP as authoritative reduced accidental regressions caused by
older chat context, stale files, or remembered versions.

This became especially important as documentation, examples, screenshots, and implementation
all changed together.

## Combined Update Packages

Delivering one ZIP with exact repository-relative paths made it practical to apply a session's
changes directly over the existing repository.

This reduced ambiguity about:

- renamed files
- omitted assets
- which version was current
- whether multiple downloads belonged together

## Documentation as Part of the Implementation

Considering README, User Manual, Cheat Sheet, CHANGELOG, examples, and screenshots during each
feature change helped prevent documentation drift.

The process worked best when documentation updates were treated as completion criteria rather
than optional follow-up work.

## Preserving Design Rationale

The Developer Notebook became valuable because it recorded why decisions were made, not merely
what changed.

This protected the project from later "cleanup" that might otherwise undo intentional behavior.

## Proactive Review

Some of the strongest improvements came from pausing after the requested task and asking:

- Is anything inconsistent?
- Is this a logical release boundary?
- Does the documentation still match?
- Is there a missing file or image?
- Should this decision be recorded?
- Is the repository ready for a snapshot?

This is the main behavior that a fresh conversation is least likely to infer automatically.

# What Did Not Transfer Automatically

A repository can transfer technical state well, but it does not automatically transfer
conversational style.

A fresh assistant may:

- answer only the literal question
- avoid suggesting adjacent improvements
- fail to recognize release readiness
- neglect process cleanup unless asked
- treat each edit as isolated rather than part of a long-lived project

The workflow documents were created to make those expectations explicit without overloading the
project's own documentation.

# Important Balance

Proactivity is useful only when it remains proportional.

The assistant should suggest relevant improvements, but should not turn every minor request into
a redesign or create unnecessary process overhead.

The intended balance is:

- complete the requested task first
- identify nearby risks or opportunities
- explain why they matter
- avoid unrelated churn
- let the repository's existing conventions take precedence

# Retrospective Practice

This file should be updated at meaningful milestones, not after every small edit.

Useful times to add an entry include:

- after a release
- after a major architecture decision
- after a difficult regression
- after changing the development workflow
- before pausing a project for a long period
- when a recurring problem reveals a missing convention

Each entry should cover:

1. What happened
2. What worked
3. What failed or caused friction
4. What was learned
5. What should change next time

# Initial Retrospective: LogoSC Process Maturity

## What Happened

LogoSC evolved from an OpenSCAD turtle interpreter into a documented, versioned geometry library
with a stable public API, examples, tests, debug rendering, licensing, release notes, and an
engineering notebook.

At the same time, the collaboration evolved from answering implementation questions into a more
active technical-lead workflow.

## What Worked

- Using the latest repository archive as the source of truth
- Keeping exact filenames and repository paths
- Packaging all session changes together
- Recording design rationale
- Updating documentation alongside code
- Reviewing the repository for omissions before snapshots
- Treating examples as both teaching material and practical regression checks

## Friction Observed

- New chats did not automatically inherit the same level of initiative.
- Large bootstrap prompts became repetitive and difficult to maintain.
- Some workflow knowledge was mixed into project-specific notes.
- Conversation memory was useful but not sufficiently reliable as the sole handoff mechanism.

## Lessons

- Project knowledge and collaboration preferences are separate forms of context.
- Both need explicit, portable documentation.
- The repository should remain authoritative for project facts.
- Reusable engineering preferences should live outside any one repository.
- A short bootstrap prompt works best when it points to better documents rather than trying to
  contain everything itself.

## Resulting Changes

The following reusable documents were created:

- `Engineering-Preferences.md`
- `ChatGPT-Project-Workflow.md`
- `Generic-Project-Bootstrap.md`
- `Project-Retrospective.md`

Together they preserve the engineering standards, collaboration style, startup procedure, and
lessons learned that are not properly part of LogoSC itself.

# Template for Future Entries

## Retrospective: [Milestone or Date]

### What Happened

[Brief description of the development period or milestone.]

### What Worked

- [Practice or decision that helped]
- [Practice or decision that helped]

### What Caused Friction

- [Problem, delay, misunderstanding, or regression]
- [Problem, delay, misunderstanding, or regression]

### Lessons

- [General lesson]
- [General lesson]

### Process Changes

- [New rule, document, checklist, or workflow]
- [New rule, document, checklist, or workflow]

### Follow-Up

- [Specific future action]
- [Specific future action]
