# Codex Git Project Quick Start

This short guide explains how to use a local Git repository as the shared working project
for Codex. See the other AI Engineering Kit documents for the detailed workflow and reasons
behind it.

## The Basic Idea

Open the real repository as the Codex workspace and give Codex normal write access to that
workspace. Codex can then inspect and edit the actual working tree. Git continues to provide
history, diffs, branches, commits, and recovery exactly as it does for human edits.

There is no separate copy to download and apply, and a routine update ZIP is unnecessary.
A ZIP remains the fallback when the user requests one or the AI environment cannot work in
the user's actual Git working tree.

## Decide whether a ZIP is needed

At the beginning of a task, determine which delivery mode applies.

Use direct Git working-tree delivery when all of these are true:

1. `git rev-parse --show-toplevel` succeeds.
2. The reported root is the repository the user placed in scope.
3. `git status` and `git diff` expose the same files the agent is editing.
4. The user can review those persistent working-tree changes directly.

In that environment, do not generate a ZIP unless the user explicitly requests one. Verify the
diff and status, then report the changed files. Direct access does not authorize staging,
committing, pushing, rewriting history, or moving tags.

Use fallback ZIP delivery when Git is unavailable, the work happens in a temporary or
attachment-only copy, the user cannot see the edited tree, direct integration cannot be
verified, or the user asks for an archive. Create one ZIP containing every changed or added
file under its exact repository-relative path, verify its entries, and keep it outside Git.

## Set Up a New Project

1. Create or clone a Git repository on your computer.
2. Add a `README.md` describing the project and how to build or run it.
3. Add a root `AGENTS.md` for durable repository-specific instructions such as layout,
   commands, conventions, constraints, verification, and review expectations.
4. Optionally copy this AI Engineering Kit into `docs/ai-engineering-kit/` when you want the
   same collaboration and handoff workflow in the new project.
5. Open or select the repository folder as the local workspace in the Codex app, CLI, or IDE
   extension. Start with the default sandbox and approval settings; expand access only when
   the work actually requires it.
6. Begin with a repository-first prompt such as:

```text
Use this Git repository as the sole source of project truth.

Before changing anything, confirm the repository root, branch, and working-tree status.
Read AGENTS.md and the project documentation it references. Summarize the current state and
any inconsistencies before making changes.

Preserve stable APIs, exact filenames, documentation assets, and historical rationale.
Keep implementation, tests, examples, and documentation synchronized.
```

## Normal Working Loop

1. Ask Codex to inspect the repository and explain its understanding.
2. Describe the goal, relevant context, constraints, and what “done” means.
3. Let Codex edit the working tree, run appropriate checks, and review its own diff.
4. Review the changes with your normal Git tools or the Codex diff view.
5. Ask Codex to revise anything that is not right.
6. Commit and push with your normal Git workflow, or explicitly ask Codex to do those steps.

Because the repository is shared, `git status` and `git diff` immediately show Codex's edits.
Codex should not stage, commit, push, rewrite history, or change tags unless that action is
part of the request.

## Where Instructions Belong

- Prompt or task: one-time requirements for the current work.
- `AGENTS.md`: durable rules for this repository.
- Project documentation: architecture, APIs, build instructions, and design rationale.
- AI Engineering Kit: reusable collaboration preferences across projects.

Keep `AGENTS.md` concise and practical. Link to detailed documents rather than copying large
manuals into it. More-specific `AGENTS.md` files can be placed in subdirectories when a
subtree needs different rules.

## Detailed References

- `AI-Engineering-Kit-Handoff.md` — reading order and precedence.
- `Generic-Project-Bootstrap.md` — concise startup procedure.
- `ChatGPT-Project-Workflow.md` — collaboration style and session workflow.
- `Engineering-Preferences.md` — coding, testing, documentation, and packaging standards.
- `Project-Retrospective.md` — why the workflow exists and what it preserves.
- [Official Codex best practices](https://learn.chatgpt.com/guides/best-practices)
- [Official `AGENTS.md` guidance](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
