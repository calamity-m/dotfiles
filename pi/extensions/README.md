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

## Tests

Run `node --test pi/tests/*.test.mjs` from the repository root (Node.js 24+).
The tests stub Pi's read-result type guard; no npm dependencies are required.

## Adding extensions

Pi auto-discovers:

- Single-file extensions: `my-extension.ts` or `my-extension.js`
- Directory extensions: `my-extension/index.ts` or `my-extension/index.js`
- Packages with entry points declared in `package.json` under `pi.extensions`

Each entry point exports a default function that receives Pi's `ExtensionAPI`.
TypeScript is loaded directly; no compilation step is needed.

Run `/reload` inside Pi after adding or changing an extension.
