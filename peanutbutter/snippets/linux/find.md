---
tags:
  - find
  - cli
  - terminal
  - files
  - directories
variables:
  path:
    default: .
---

# Find Snippets

## find files and directories with total sizes

Uses `du` to calculate the full size of directories recursively, then sorts the results by size. `-mindepth` and `-maxdepth` are GNU `find` options.

```bash
find <@path> -mindepth 1 -maxdepth 1 -exec du -sh -- {} + | sort -h
```

## list directories by size

Calculate the recursive size of each immediate subdirectory and sort from
smallest to largest.

```bash
find <@path> -mindepth 1 -maxdepth 1 -type d -exec du -sh -- {} + | sort -h
```
