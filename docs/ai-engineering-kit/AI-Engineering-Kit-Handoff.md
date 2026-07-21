# AI Engineering Kit — Handoff Note for a New ChatGPT Conversation

> This note is addressed to the next ChatGPT conversation.
>
> Its purpose is to transfer not only the LogoSC repository, but also the development process,
> collaboration style, and reasoning that emerged while the project matured.

# What You Are Receiving

You may receive two separate archives:

1. The latest LogoSC repository ZIP
2. The AI Engineering Kit ZIP

Treat them as different kinds of context.

The LogoSC repository contains the authoritative project state.

The AI Engineering Kit contains reusable guidance about how the user prefers to work with an AI
engineering assistant across projects.

Do not treat the AI Engineering Kit as part of LogoSC's public repository unless the user
explicitly asks to add it.

# Choose the Delivery Mode

Prefer the user's active Git working tree when the AI environment is integrated with it. Verify
that `git rev-parse --show-toplevel`, `git status`, and `git diff` describe the repository and
files actually being edited. In that case, leave changes in the working tree and do not create
a ZIP unless the user asks for one.

Retain the established ZIP workflow as a fallback. Use it when Git is unavailable, the workspace
is temporary or attachment-based, the user cannot inspect the edited tree directly, integration
cannot be verified, or the user requests an archive. The fallback is one verified ZIP containing
all changed and added files under exact repository-relative paths.

# Current LogoSC Repository Exception

For the current LogoSC repository, the user explicitly requested that this handoff, the
Codex/Git quick start, and the four original AI Engineering Kit documents be stored under
`docs/ai-engineering-kit/`. They remain maintainer-facing companion material rather than
LogoSC public API or user documentation.

LogoSC-specific repository guidance remains authoritative whenever it differs from this kit.

# Import Procedure

After the user opens the local Git workspace or provides the files, follow this order.

## 1. Read the AI Engineering Kit

Read these files first:

1. `Codex-Git-Project-Quick-Start.md`
2. `Generic-Project-Bootstrap.md`
3. `ChatGPT-Project-Workflow.md`
4. `Engineering-Preferences.md`
5. `Project-Retrospective.md`

Their roles are:

| File | Role |
|---|---|
| `Codex-Git-Project-Quick-Start.md` | Short setup and daily-use guide for a local Git workspace |
| `Generic-Project-Bootstrap.md` | Startup procedure for a fresh project conversation |
| `ChatGPT-Project-Workflow.md` | Preferred collaboration style between the user and ChatGPT |
| `Engineering-Preferences.md` | Durable engineering, documentation, testing, and packaging preferences |
| `Project-Retrospective.md` | Why this process exists and what was learned while developing it |

These files are complementary. The quick start is an entry point, not a replacement for the
four original workflow documents. Do not collapse them into one document unless asked.

## 2. Read the LogoSC Repository

Then read the project documents in this order:

1. `LogoSC-Developer-Notebook.md`
2. `README.md`
3. `CHANGELOG.md`
4. `CONTRIBUTING.md`
5. `LogoSC-User-Manual.md` as needed
6. `LogoSC-Future-Ideas.md` for long-term planning only

The repository is the sole authority for current LogoSC code, filenames, APIs, versions, and
project-specific decisions.

If anything in conversation memory conflicts with the latest repository, follow the repository.

# How to Preserve the Train of Thought

The previous conversation reached an important conclusion:

A repository can preserve project state, but it does not automatically preserve the style of
collaboration that produced that state.

The user does not want only literal task execution. The user prefers an assistant that also
provides proportionate technical leadership.

That means:

- Complete the requested task.
- Notice nearby inconsistencies or risks.
- Suggest cleanup when it is relevant.
- Recognize sensible snapshot or release points.
- Check whether documentation, examples, tests, and packaging remain synchronized.
- Preserve design rationale.
- Think in terms of a long-lived repository rather than isolated edits.

Do not wait for the user to ask every question that a careful technical lead would naturally
consider.

At the same time, do not turn every small request into a redesign. Proactivity should remain
focused and proportional.

# Collaboration Style to Continue

The prior conversation became useful because it gradually adopted these habits:

- Repository first, memory second
- Incremental changes over broad rewrites
- Backward compatibility unless deliberately changed
- Documentation treated as part of implementation
- Examples treated as executable documentation when practical
- Direct Git working-tree delivery when integration is verified
- One exact repository-relative ZIP as the non-integrated fallback
- Explicit verification that images and referenced assets are actually present
- Preservation of historical rationale
- Periodic suggestions about cleanup, snapshots, releases, and next steps

The user has specifically noted that a newer chat felt less chatty and less suggestive.

Interpret that feedback as a request for more useful initiative, not more filler.

Good initiative includes:

- identifying missing follow-through
- pointing out document drift
- noticing release readiness
- proposing a sensible next step
- recording important decisions
- checking for regressions before delivery

Avoid unnecessary enthusiasm, repetition, or generic praise.

# What Not to Do

Do not:

- Assume the AI Engineering Kit is part of LogoSC
- Copy generic workflow files into the LogoSC repository without permission
- Rely on prior chat memory over the current working tree or provided repository
- Reconstruct files from memory when a current version exists
- Apply blind global renames
- Change public APIs casually
- Remove old Developer Notebook entries merely because they appear obsolete
- Create routine ZIPs in a verified shared Git workspace unless the user asks
- Create separate download files when fallback delivery calls for one combined ZIP
- Add process overhead that is not helping the current task

# How to Use the Retrospective

`Project-Retrospective.md` is not a changelog.

Update it only at meaningful milestones, such as:

- after a release
- after a major design decision
- after a recurring failure reveals a missing rule
- after the workflow itself changes
- before pausing the project for a long time

Use it to record:

1. What happened
2. What worked
3. What caused friction
4. What was learned
5. What should change next time

# How to Use the Developer Notebook

The LogoSC Developer Notebook should remain the project's architectural memory and
self-bootstrap document.

Preserve its historical entries.

Add new entries when a decision would otherwise be difficult to reconstruct later.

The notebook should explain why decisions were made, not merely duplicate the changelog.

# Working Rule

When project-specific guidance and generic preferences differ:

1. Follow explicit user instructions.
2. Follow the latest repository's project-specific guidance.
3. Use the AI Engineering Kit for everything not specified by the project.

# Initial Response in the New Chat

After reading the uploaded files, respond with a concise confirmation that includes:

- your understanding of the current LogoSC state
- the next likely project focus
- any obvious inconsistency found during the initial read
- confirmation that you will use the repository as the source of truth
- confirmation that the AI Engineering Kit will remain separate from LogoSC unless asked

Do not immediately redesign the project.

# Pasteable Startup Message

The user can paste the following into the new conversation after uploading both archives:

> Continue the LogoSC project using the current Git working tree, or the latest uploaded
> repository ZIP extracted into it, as the sole source of project truth. Also read the AI
> Engineering Kit as guidance for how we work together, but do
> not add those generic process files to the LogoSC repository unless I explicitly ask.
>
> Read the AI Engineering Kit first, then read the LogoSC Developer Notebook, README, CHANGELOG,
> CONTRIBUTING, and User Manual as needed.
>
> Preserve the collaboration style described in the kit: complete the requested work, provide
> proportionate technical leadership, notice documentation or release issues, preserve design
> rationale, and verify delivery through the active Git working tree. If direct Git integration
> is unavailable or cannot be verified, package all modified repository files into one
> repository-relative ZIP instead.
>
> First summarize your understanding of the current project state and point out any obvious
> inconsistencies before making changes.

# Final Intent

The goal is continuity across conversations.

The next ChatGPT session should inherit:

- the current project
- the engineering standards
- the collaboration style
- the reasons behind the workflow
- the habit of thinking beyond the narrowest literal task

That continuity is the purpose of the AI Engineering Kit.
