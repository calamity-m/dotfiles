---
tags: [desktop, icons]
description: Desktop entry and icon helpers
---

## cd to desktop entries

```bash
cd "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
```

## cd to icon entries

```bash
cd "${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"
```

## Copy icon to icons folder

Recursively find PNG files in the current directory, select one, and copy it into your user icon theme at its detected dimensions. Requires `file`. Use `icon_name` as the desktop entry's `Icon` value, without an extension. Re-running this replaces an icon with the same name and dimensions.

```bash
(
  icon_path="<@icon_path:find "$PWD" -type f -iname '*.png'>"
  icon_name="<@icon_name>"
  icon_size=$(file -Lb "$icon_path" | sed -n 's/^PNG image data, \([0-9]*\) x \([0-9]*\),.*/\1x\2/p')
  [ -n "$icon_size" ] || { echo 'Could not determine PNG dimensions' >&2; exit 1; }
  icon_directory="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/$icon_size/apps"
  mkdir -p "$icon_directory" &&
    cp -L -- "$icon_path" "$icon_directory/$icon_name.png" &&
    printf 'Installed icon: %s\nDesktop entry: Icon=%s\n' "$icon_directory/$icon_name.png" "$icon_name"
)
```

