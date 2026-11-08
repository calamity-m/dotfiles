---
tags:
  - ripgrep
  - cli
  - grep
  - files
  - directories
---

# rg

## find files with a specific file type

```bash
rg --files -g '*.<@extension>'
```

## find files matching multiple globs

Each `-g` includes files matching that path glob.

```bash
rg --files -g '<@glob>' -g '<@glob_two>'
```

## list files in a directory that match a pattern

```bash
rg --files <@directory> | rg <@pattern>
```

## list files in a directory that do not match a pattern

```bash
rg --files <@directory> | rg -v <@pattern>
```

## list filenames whose contents match a pattern

Searches file contents from the current directory down and prints only the
matching file paths, one per line.

- `-i` makes the match case insensitive
- `--files-without-match` performs the inverse

```bash
rg -l <@pattern>
```

## list filenames whose contents match a pattern, limited to a file type

`rg --type-list` shows the available type names.

```bash
rg -l -t <@type:rg --type-list | cut -d: -f1> <@pattern>
```

## list filenames whose contents match a pattern, limited to a glob

The glob and the pattern match different things:

- `<@glob>` is shell-style wildcards matched against the file path, and decides
  which files get searched at all. `.` is a literal dot; prefix with `!` to
  exclude, as in `!**/vendor/**`
- `<@pattern>` is a regex matched against the contents of those files

So `-g "*.go" "func main"` means "of the `.go` files, which contain `func main`".

```bash
rg -l -g "<@glob>" <@pattern>
```

## count matches per file

Prints `path:count` for each file containing the pattern, skipping files with
zero matches.

```bash
rg -c <@pattern>
```

## count unique matches across files

Print only the text matched by the regex, combine matches from all files, and
show each unique value with its total count, most frequent first. Make the
regex match only the value to count, such as `systemStatus:\s*\K\w+`.
PCRE2 mode (`-P`) allows `\K` to exclude the field name from each match.

```bash
rg -P --no-filename -o '<@pattern>' '<@directory:.>' | sort | uniq -c | sort -nr
```

## count unique bucket matches across files

Group non-empty text between start and end regexes on the same line, then
show each bucket with its total count, most frequent first. Delimiters are
excluded; escape regex metacharacters when matching literal delimiters.
For start `A` and end `B`, `A1B A2B A1B A1B` produces `3 1` and `1 2`.

```bash
rg -P --no-filename -o '(?:<@start>)\K.+?(?=(?:<@end>))' '<@directory:?.>' | sort | uniq -c | sort -nr
```
