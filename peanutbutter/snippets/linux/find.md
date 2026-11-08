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
  size:
    suggestions: [1k, 10k, 100k, 1M, 10M, 100M, 1G, 10G]
---

# Find

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

## find directories and files with a maxdepth

```bash
find <@path> -maxdepth <@depth:?1>
```

## find files with a size greater than

Pick a size or type your own: `k` = KiB, `M` = MiB, `G` = GiB, `c` = bytes.
GNU `find` rounds file sizes up to the selected unit before comparing.

```bash
find <@path> -type f -size +<@size>
```

## find files with a size less than

Pick a size or type your own: `k` = KiB, `M` = MiB, `G` = GiB, `c` = bytes.
GNU `find` rounds file sizes up to the selected unit before comparing.

```bash
find <@path> -type f -size -<@size>
```
