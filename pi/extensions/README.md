# Pi user extensions

Keep custom Pi extensions here. `mise dot apply` symlinks this directory to
`~/.pi/agent/extensions/`, making the extensions available in every project.

## Extensions

- `session-resets.ts`: `/clear` and `/clean` start a new session, like `/new`.
- `claude-skill-compatibility.ts`: loads skills from `.claude/skills/` relative to
  Pi's working directory in trusted projects. Missing directories are skipped.
  Skills are discovered at startup and on `/reload`.

- `nested-context.ts`: ports [pi-nesting-context](https://github.com/calamity-m/pi-nesting-context)'s
  nested instruction loading. After a successful `read`, appends context files
  from directories between Pi's working directory (exclusive) and the file's
  directory (inclusive), ordered outermost first. In each directory, the first
  readable file wins: `AGENTS.md`, `AGENTS.MD`, `CLAUDE.md`, then `CLAUDE.MD`.
  Files already in Pi's system context or injected by this extension are skipped,
  including concurrent reads. State resets on session start/reload or a change
  of working directory. Only `read` results trigger loading; reads outside the
  working directory are ignored. This port does not add nested prompt discovery
  or `AGENTS.override.md` support. Context files load regardless of project trust,
  like Pi's native context files; only use instruction files you trust.

## Autoformatter

`autoformatter/` adapts [pi-autoformatter](https://github.com/calamity-m/pi-autoformatter)
(upstream revision `ff01574f58d8fc66786b3653f1193a9cb7dfac22`, MIT; license
included). It runs a formatter after successful `write` and `edit` tool calls,
using Pi's per-file mutation queue and coalescing overlapping same-file runs.
Formatter failures are reported in tool results without turning a successful
write/edit into an error. Bash and other tool mutations do not trigger it.

No formatters are enabled by default. Add rules to `formatters` in
`~/.pi/agent/autoformatter.json` (or the agent directory selected by `PI_CODING_AGENT_DIR`),
or in a trusted project's `.pi/autoformatter.json`:

```json
{
  "formatters": [
    {
      "id": "ruff-format",
      "languages": ["python"],
      "extensions": [".py", ".pyi"],
      "command": "ruff",
      "args": ["format", "{file}"],
      "cwd": "project",
      "timeoutMs": 10000
    }
  ]
}
```

The executable must be installed and on Pi's `PATH`. Commands run without a
shell; an argument exactly equal to `{file}` becomes the absolute file path.
`cwd` defaults to `"project"` (Pi's working directory), or can be an absolute
path; `timeoutMs` defaults to `10000`. `languages` is optional.

The first matching extension rule runs. Trusted project rules take priority and
override global rules by language; project rules without languages override
global language-less rules with the same `id`. Project rules never apply to
files outside Pi's working directory, and are ignored if Pi cannot confirm trust.
Only configure commands you trust: they run with Pi's permissions.

Existing `autoformatter` entries in Pi\'s `settings.json` are no longer read;
move the contents of that object into `autoformatter.json`.

If the agent edits an `autoformatter.json` file with `write` or `edit`, that configuration
source is disabled for the remainder of the extension instance; restart Pi or
reload extensions to enable it again. Other configuration changes
are read on the next successful file mutation.

## Tests

Run `node --test pi/tests/*.test.mjs` from the repository root (Node.js 24+).
The tests stub Pi's runtime helpers; no npm dependencies are required.
Autoformatter tests run real child processes, but stub Pi's mutation queue;
serialization against Pi's native tools is provided by Pi itself.

## Adding extensions

Pi auto-discovers:

- Single-file extensions: `my-extension.ts` or `my-extension.js`
- Directory extensions: `my-extension/index.ts` or `my-extension/index.js`
- Packages with entry points declared in `package.json` under `pi.extensions`

Each entry point exports a default function that receives Pi's `ExtensionAPI`.
TypeScript is loaded directly; no compilation step is needed.

Run `/reload` inside Pi after adding or changing an extension.
