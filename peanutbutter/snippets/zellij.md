---
name: Zellij
tags:
  - cli
  - mux
  - zellij
variables:
  session_name:
    suggestions:
      - main
      - test
      - scratch
      - work
      - dev
  tab_name:
    suggestions:
      - main
      - test
      - scratch
      - slop
      - dev
      - longlived
  session:
    command: zellij list-sessions --short --no-formatting
---

# Zellij

## start named sessions

```bash
zellij --session <@session_name>
```

## attach to session

```bash
zellij attach <@session>
```

## rename current session

```bash
zellij action rename-session <@session_name>
```

## rename current tab

```bash
zellij action rename-tab <@tab_name>
```

## rename current tab to cwd

Rename the current zellij tab to the current directory name.

```bash
zellij action rename-tab "$(basename "$PWD")"
```

## detach current session

Detach from the current zellij session without killing it.

```bash
zellij action detach
```

## kill current session

```bash
zellij kill-session "$ZELLIJ_SESSION_NAME"
```

## delete all sessions

```bash
zellij delete-all-sessions
```

## kill all sessions

```bash
zellij kill-all-sessions
```

## kill and delete all sessions

Kill all running Zellij sessions and delete all saved sessions without confirmation.
This includes the current session and stops its running programs; deleted sessions cannot be resurrected.

```bash
zellij delete-all-sessions --force --yes
```
