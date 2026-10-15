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
---

## Conventional commit

Commits with a `type(scope): subject` prefix. The `type` placeholder is backed by a frontmatter suggestion list — open the picker and you'll see the choices. `scope` and `subject` are free-form.

```bash
git commit -m "<@type>(<@scope>): <@subject>"
```

