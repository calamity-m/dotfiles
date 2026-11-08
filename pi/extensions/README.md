# Pi user extensions

`mise dot apply` symlinks this directory to `~/.pi/agent/extensions/`, making
these extensions available in every project. Run `/reload` after changes.

## Extensions

- `session-resets.ts`: `/clear` and `/clean` start a new session, like `/new`.
- `claude-skill-compatibility.ts`: loads `.claude/skills/` from Pi's working
  directory in trusted projects, at startup and on `/reload`.
- `nested-context.ts`: loads nested instruction files when Pi reads a file
  within its working directory. In each directory, the first readable file wins:
  `AGENTS.md`, `AGENTS.MD`, `CLAUDE.md`, then `CLAUDE.MD`. Files load outermost
  first, without duplicates. Like Pi's native context, this is not gated by
  project trust—only use instruction files you trust.
- `autoformatter/`: runs a formatter after successful `write` and `edit` calls.
  Formatter failures are reported without failing the edit. Bash changes do not
  trigger formatting.

## Autoformatter configuration

No formatters are enabled by default. Add rules to
`~/.pi/agent/autoformatter.json` (or your custom agent directory), or to a trusted
project's `.pi/autoformatter.json`:

```json
{
  "formatters": [
    {
      "id": "ruff-format",
      "languages": ["python"],
      "extensions": [".py", ".pyi"],
      "command": "ruff",
      "args": ["format", "{file}"]
    }
  ]
}
```

- Install the formatter on Pi's `PATH`. Commands run without a shell;
  `{file}` as a standalone argument becomes the absolute file path.
- The first matching rule runs. Trusted project rules take priority over global
  rules and only apply within the project. Only configure commands you trust.
- `languages` is optional. `cwd` defaults to `"project"` (Pi's working directory)
  and can also be an absolute path. `timeoutMs` defaults to `10000`.
- Configuration belongs in `autoformatter.json`, not `settings.json`.
- If Pi edits a formatter configuration with `write` or `edit`, that source is
  disabled until `/reload` or restart. Other configuration changes apply on the
  next successful file mutation.

## Tests

From the repository root, run `node --test pi/tests/*.test.mjs` (Node.js 24+).
No npm dependencies are required.
