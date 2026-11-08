---
tags:
  - sed
  - cli
---

# Sed Snippets

## Replace pattern in file

```bash
sed -i 's/<@old>/<@new>/g' <@file>
```

## Delete lines matching pattern

```bash
sed -i '/<@pattern>/d' <@file>
```
