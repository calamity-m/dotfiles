# Noctalia

This directory holds user config for the Noctalia shell (installed version 5.4.1).
`mise.toml` links these into `~/.config/noctalia/`:

- `templates.toml` and `templates/`: user templates (e.g. the Zellij theme).
- `palettes/`: custom colour palettes (e.g. `Umber.json`).

The shell's own settings live in `~/.local/state/noctalia/settings.toml`, which the
GUI writes. That file isn't tracked here.

## Custom palettes

### Location and selection

- A palette is a JSON file at `~/.config/noctalia/palettes/<Name>.json`. Here, that
  means `noctalia/palettes/<Name>.json`, reached through the linked folder.
- The palette shows up under a **Custom** tab in the wallpaper/colour picker, and in
  Settings → Appearance → Custom Palette.
- Selecting it writes this to `settings.toml`:
  ```toml
  [theme]
  source = "custom"
  custom_palette = "Umber"   # filename without .json
  ```
- If the file is missing or invalid, Noctalia falls back to the built-in `Noctalia`
  palette.

### Use the old key format (format 1)

The online docs (docs.noctalia.dev) are rolling. They describe a `"version": 2`
format with snake_case keys (`primary`, `on_surface`, `surface_container`, ...).
**5.4.1 doesn't fully read that format.** A version-2 file loaded only the accents
and `surface`. Everything else came out as `#000000`, which left the text black on
black.

Use the format the downloaded community palettes use (see
`~/.local/state/noctalia/community-palettes/*.json`). It has no `version` key and
uses `m`-prefixed camelCase keys:

```json
{
  "dark": {
    "mPrimary": "#...",        "mOnPrimary": "#...",
    "mSecondary": "#...",      "mOnSecondary": "#...",
    "mTertiary": "#...",       "mOnTertiary": "#...",
    "mError": "#...",          "mOnError": "#...",
    "mSurface": "#...",        "mOnSurface": "#...",
    "mSurfaceVariant": "#...", "mOnSurfaceVariant": "#...",
    "mOutline": "#...",
    "mShadow": "#...",
    "mHover": "#...",          "mOnHover": "#...",
    "terminal": {
      "normal": { "black": "", "red": "", "green": "", "yellow": "", "blue": "", "magenta": "", "cyan": "", "white": "" },
      "bright": { "...": "same keys" },
      "foreground": "#...", "background": "#...",
      "selectionFg": "#...", "selectionBg": "#...",
      "cursorText": "#...", "cursor": "#..."
    }
  },
  "light": { "...": "same shape; optional, dark is used for both when omitted" }
}
```

After a Noctalia upgrade, check which key names the binary knows before switching
formats:

```sh
strings /usr/bin/noctalia | grep -E '^(m[A-Z][A-Za-z]+|on_[a-z_]+|surface_container|outline_variant)$' | sort -u
```

### Reloading after edits

Noctalia reloads live when `~/.config/noctalia/*.toml` or `settings.toml` changes,
but it does **not** notice edits to a palette JSON. After editing a palette,
re-select it in the picker or run `touch ~/.local/state/noctalia/settings.toml`.

### Derived colours

A palette sets about 16 roles. Noctalia derives the rest itself (`outline`,
`surface_container_high`, `*_container`, `*_fixed`, `*_fixed_dim`, ...), and the
format-1 keys can't set those. Templates that use derived roles get Noctalia's
values, not yours:

- The community Neovim template
  (`~/.local/state/noctalia/community-templates/neovim/matugen-template.lua`) maps
  base16 `base0C` to `base0F` to `tertiary_fixed_dim`, `primary_fixed_dim`,
  `secondary_fixed_dim` and `secondary_fixed`. With Umber these come out as bright
  pastels (e.g. `#e996c0`), not Umber accents. To fix that, copy the template into
  a user template in `templates.toml` and map those slots to the palette's
  accents, as the Zellij template does.
- Dark, low-contrast palettes produce near-black derived roles. Check the output
  before deciding a palette needs brightening.

### Checking the generated colours

With the palette active, read the rendered outputs:

- `~/.config/nvim/lua/matugen.lua`: base16 slots, the quickest way to see every
  role, including derived ones.
- `~/.config/niri/noctalia.kdl`: niri focus ring and border colours. The built-in
  niri template is enabled, and `~/.config/niri/config.kdl` includes this file.
- `~/.cache/noctalia/noctalia.log`: template and hook errors.

`noctalia theme --theme-json <palette>.json` does **not** run the derivation (the
derived roles come back `null`) and doesn't read the palette's terminal block, so
it can't preview a palette.

## User templates

Declared in `templates.toml` (Noctalia loads every `~/.config/noctalia/*.toml`):

```toml
[theme.templates.user.<id>]
input_path  = "$XDG_CONFIG_HOME/noctalia/templates/<file>"
output_path = "<destination>"
post_hook   = "<optional reload command>"
```

Template syntax is Noctalia's own, not matugen/Tera: `{{ colors.<role>.default.hex }}`,
with blocks in `<* for/if ... *>`. Terminal roles are named like
`colors.terminal_normal_red`. Run `noctalia theme --list-templates` to list the
built-in, community and user templates.
