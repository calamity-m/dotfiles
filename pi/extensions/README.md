# Pi user extensions

Keep custom Pi extensions here. `mise dot apply` symlinks this directory to
`~/.pi/agent/extensions/`, making the extensions available in every project.

## Extensions

- `session-resets.ts`: `/clear` and `/clean` start a new session, like `/new`.
- `claude-skill-compatibility.ts`: loads skills from `.claude/skills/` relative to
  Pi's working directory in trusted projects. Missing directories are skipped.
  Skills are discovered at startup and on `/reload`.

## Adding extensions

Pi auto-discovers:

- Single-file extensions: `my-extension.ts` or `my-extension.js`
- Directory extensions: `my-extension/index.ts` or `my-extension/index.js`
- Packages with entry points declared in `package.json` under `pi.extensions`

Each entry point exports a default function that receives Pi's `ExtensionAPI`.
TypeScript is loaded directly; no compilation step is needed.

Run `/reload` inside Pi after adding or changing an extension.
