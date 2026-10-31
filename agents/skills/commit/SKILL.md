---
name: commit
description: "Commit staged or unstaged changes. Use this skill when committing with git, or when the user explicitly asks to commit."
---

# Commit

Create small, coherent git commits with a terse conventional-style message.

Use the exact subject format:

```text
<type>(scope): short
```

Write a body only when it adds useful context. Keep it short and direct.

## Workflow

1. Inspect `git status` and `git diff`.
2. Decide whether the staged and unstaged changes should become one commit or multiple commits.
3. Identify the smallest logical unit of change.
4. Stage only whole files that belong in that unit.
5. Write a subject in the required format.
6. Commit only after the message and staged file set both make sense.

If unrelated changes are mixed together, split them into separate commits instead of hiding them behind a vague message.

## Remote Git Operations

- When running inside a sandbox, request execution outside the sandbox for Git commands that contact a remote, including `git push`, `git pull`, and `git fetch`.
- Escalate these commands on the first attempt rather than waiting for a sandbox network or authentication failure.
- Keep local-only Git commands inside the sandbox unless they independently require escalation.

## Message Rules

- Require a subject of the form `<type>(scope): short`.
- Keep the subject short, specific, and lowercase.
- Keep the scope narrow and meaningful: `edit-helm-chart`, `mermaid-sequence-diagram`, `agents`, `repo`.
- If the change genuinely spans the repo and no narrower scope fits, use `general` as the scope.
- Prefer imperative wording such as `add validator`, `enforce render diffs`, or `document quoting rules`.
- Use a body when the change needs context, spans multiple concerns, or has notable behavior. Keep it direct and focused on why.

## Preferred Types

- `feat`: add user-facing functionality or a new capability
- `fix`: fix a bug or broken behavior
- `refactor`: improve structure without changing intended behavior
- `docs`: documentation-only changes
- `test`: add or adjust tests
- `chore`: maintenance or repo housekeeping

## Staging Rules

- Decide whether one or more commits should be created based on both staged and unstaged files, not just whatever happens to be staged already.
- **Never use partial staging (`git add -p` / `git add --patch`).** Always stage whole files. Do not split a single file across multiple commits.
- If separate files contain unrelated changes, split them into separate commits.
- If unrelated changes live in the same file, commit them together and use the body to describe each concern.
- Do not stage generated output unless the repo clearly tracks it.
- Prefer smaller focused commits when files can be cleanly separated. When they cannot, use a larger commit with a detailed body explaining the included changes.

## Reporting Back

- Tell the user what was committed.
- If the commit body exists, summarize it instead of repeating it verbatim unless asked.
- If there are leftover unstaged or uncommitted changes, say so clearly.

For naming examples and commit-splitting guidance, read [references/best-practices.md](./references/best-practices.md).

## Resources

### references/

- `references/best-practices.md`: practical guidance for choosing `type`, selecting `scope`, and deciding when to split commits.
