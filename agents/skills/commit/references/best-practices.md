# Commit Best Practices

Use this file when deciding how to split a change or how to name a commit.

## Pick the Smallest Real Change

- One commit should capture one idea.
- Decide whether the current staged and unstaged changes should become one commit or multiple commits before committing anything.
- **Never use partial staging (`git add -p`).** Always stage whole files. Do not split a single file across multiple commits.
- If separate files contain unrelated changes, split them into separate commits.
- If unrelated changes live in the same file, commit them together and use the body to describe each concern.
- Prefer smaller focused commits when files can be cleanly separated. When they cannot, use a larger commit with a detailed body.

## Choose a Good Type

- Use `feat` for new capabilities.
- Use `fix` for broken behavior.
- Use `refactor` when the structure changes but the intended behavior does not.
- Use `docs` for documentation-only changes.
- Use `test` for test-only changes.
- Use `chore` for maintenance work that is not a feature or fix.

## Choose a Tight Scope

- The scope should tell the reader where the change lives.
- Good scopes are usually module, feature, skill, or repo areas such as `edit-helm-chart`, `commit`, `agents`, or `repo`.
- Do not use a huge vague scope like `everything`.
- If the change really touches many areas and no tighter scope is honest, use `general`.

## Keep the Subject Short

- Use the format `<type>(scope): short`.
- Make the last part a compact description, not a sentence.
- Keep the subject short, specific, and lowercase.
- Good: `feat(commit): add message validator`
- Good: `docs(edit-helm-chart): require render diffs`
- Bad: `updated lots of stuff`

## Write a Useful Body

- Add a body when the change needs context, spans multiple concerns, or has notable behavior.
- Keep it focused on why or notable behavior.
