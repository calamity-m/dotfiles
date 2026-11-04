---
tags:
  - diff
variables:
  folder_a:
    command: fd -t d
  folder_b:
    command: fd -t d
---

# Diff

## diff two command literals per character

Useful when two pasted commands look identical but one fails (smart quotes, non-breaking spaces, etc).

```bash
git diff --no-index --word-diff-regex=. <(echo '<@command_a>') <(echo '<@command_b>')
```

## diff the contents of two folders

Recursive, with highlighting. Add `--stat` for just a summary of which files changed.

```bash
git diff --no-index '<@folder_a>' '<@folder_b>'
```
