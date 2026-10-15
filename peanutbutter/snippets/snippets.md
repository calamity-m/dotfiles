---
tags: [starter, git, files, examples]
description: A curated starter set 
variables:
  type:
    suggestions:
      - feat
      - fix
      - chore
      - docs
      - refactor
      - test
  branch:
    command: git branch --format='%(refname:short)'
  remote:
    command: git remote
  path:
    default_value: .
  appimage_path:
    command: find "$PWD" -maxdepth 1 -type f -name '*.AppImage'
---

## Conventional commit

Commits with a `type(scope): subject` prefix. The `type` placeholder is backed by a frontmatter suggestion list — open the picker and you'll see the choices. `scope` and `subject` are free-form.

```bash
git commit -m "<@type>(<@scope>): <@subject>"
```

## cd to desktop entries

```bash
cd "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
```

## cd to icon entries

```bash
cd "${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"
```

## Create an AppImage desktop entry

Add an AppImage to the application launcher (for example, `vicinae.desktop`). Use a filename without the `.desktop` suffix for `app_id`, an absolute AppImage path, and an icon theme name or absolute icon path for `icon`. Desktop entries do not expand `~` or `$HOME` in paths. Re-running this replaces the entry with the same ID.

```bash
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/applications" &&
chmod +x "<@appimage_path>" &&
cat > "${XDG_DATA_HOME:-$HOME/.local/share}/applications/<@app_id>.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=<@app_name>
Exec="<@appimage_path>"
Icon=<@icon>
Terminal=false
Categories=<@categories:?Utility;>
EOF
```

## Extract an AppImage

Select a `.AppImage` file from the current directory and extract it into `./squashfs-root`. Inspect that directory for bundled icons when `.DirIcon` is missing. Requires an AppImage that supports `--appimage-extract`.

```bash
chmod +x "<@appimage_path>" &&
  "<@appimage_path>" --appimage-extract
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

## Install an AppImage icon

Extract an AppImage selected from the current directory and install its bundled `.DirIcon` into your user icon theme. Detects PNG dimensions or SVG format automatically; requires `file`. Use `icon_name` as the desktop entry's `Icon` value, without an extension. Extraction uses a temporary directory that is removed afterwards. Re-running this replaces an icon with the same name, size, and format.

```bash
(
  appimage_path="<@appimage_path>"
  icon_name="<@icon_name>"
  icon_root="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"
  extract_dir=$(mktemp -d) || exit 1
  trap 'rm -rf -- "$extract_dir"' EXIT
  chmod +x "$appimage_path" &&
    cd "$extract_dir" &&
    "$appimage_path" --appimage-extract > /dev/null || exit 1
  icon_path="$extract_dir/squashfs-root/.DirIcon"
  case "$(file -Lb --mime-type "$icon_path")" in
    image/png)
      icon_size=$(file -Lb "$icon_path" | sed -n 's/^PNG image data, \([0-9]*\) x \([0-9]*\),.*/\1x\2/p')
      [ -n "$icon_size" ] || { echo 'Could not determine PNG dimensions' >&2; exit 1; }
      icon_extension=png
      ;;
    image/svg+xml)
      icon_size=scalable
      icon_extension=svg
      ;;
    *) echo 'Missing or unsupported .DirIcon (expected PNG or SVG)' >&2; exit 1 ;;
  esac
  icon_directory="$icon_root/$icon_size/apps"
  mkdir -p "$icon_directory" &&
    cp -L -- "$icon_path" "$icon_directory/$icon_name.$icon_extension" &&
    printf 'Installed icon: %s\nDesktop entry: Icon=%s\n' "$icon_directory/$icon_name.$icon_extension" "$icon_name"
)
```

