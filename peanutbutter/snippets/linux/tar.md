---
tags:
  - tar
  - cli
  - gzip
  - files
  - terminal
variables:
  depth:
    suggestions:
      - 1
      - 2
      - 3
  tar:
    command: rg --files -g '*.tar' -g '*.tar.gz'
---

# Tar

## create tar

```bash
tar -czvf <@out>.tar.gz <@src:rg . --files>
```

## create tar from directory using relative paths

```bash
tar czf <@out>.tar.gz -C <@directory> .
```

## view files in tar

List files inside a tar archive without extracting it.

```bash
tar -tf <@tar>
```

## extract files matching a regex

Match the regex against each file's full path inside the archive, then extract
matching files into the destination directory.

```bash
tar -tf <@tar> | rg <@regex> | tar -xvf <@tar> -C <@dest> --verbatim-files-from -T -
```

## untar into directory

```bash
tar -xzvf <@tar> -C <@dest>
```

## untar specific file

```bash
tar -xzvf <@tar> <@file>
```

## untar, strip prefix

```bash
tar -xzvf <@tar> -C <@dest> --strip-components=<@depth>
```
