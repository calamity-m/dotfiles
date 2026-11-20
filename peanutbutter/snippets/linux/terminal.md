---
name: terminal
tags:
  - cli
  - io
  - linux
---

# Terminal

## run command and discard/mute output

```bash
<@command> &>/dev/null
```

## mute return code

regardless of the command's exit code, we'll always have a `1`

```bash
<@command> 2>/dev/null || true
```

## pipe output of command to file while tailing it

```bash
<@command> 2>&1 | tee <@file>
```

## append to existing file

```bash
<@command> >> <@file>
```

## overwrite an existing file (or create a new one)

```bash
<@command> > <@file>
```
