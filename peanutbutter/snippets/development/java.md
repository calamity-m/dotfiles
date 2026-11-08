---
name: Java helpers
description: Java project setup and development commands
tags: [java, jdtls, eclipse, formatting]
---

## Create Eclipse Java formatter preferences

Run from the Java project or module root to create `.settings/org.eclipse.jdt.core.prefs`
with four-space indentation, spaces instead of tabs, and a 120-column wrapping target.
JDTLS (including VS Code Java) reads these project preferences. Existing files are
left untouched; this does not configure build-tool formatters such as Spotless.

```sh
prefs=.settings/org.eclipse.jdt.core.prefs
if [ -e "$prefs" ] || [ -L "$prefs" ]; then
    printf 'Leaving existing %s unchanged.\n' "$prefs"
else
    mkdir -p .settings && (
        # Refuse to overwrite a file even if it appeared after the check above.
        set -C
        cat > "$prefs" <<'EOF'
eclipse.preferences.version=1
org.eclipse.jdt.core.formatter.tabulation.char=space
org.eclipse.jdt.core.formatter.tabulation.size=4
org.eclipse.jdt.core.formatter.indentation.size=4
org.eclipse.jdt.core.formatter.continuation_indentation=2
org.eclipse.jdt.core.formatter.lineSplit=120
EOF
    ) && printf 'Created %s.\n' "$prefs"
fi
```
