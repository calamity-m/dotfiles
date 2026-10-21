---
tags: 
  - git
  - development
description: A curated set of git commands and snippets
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

## conventional commit

Commits with a `type(scope): subject` prefix. The `type` placeholder is backed by a frontmatter suggestion list — open the picker and you'll see the choices. `scope` and `subject` are free-form.

```bash
git commit -m "<@type>(<@scope>): <@subject>"
```

## amend latest commit title

```bash
git commit --amend -m "<@message>"
```

## rebase onto branch's own first commit

Interactive rebase starting only from where this branch diverged from `<@base:?main>`, instead of onto `<@base:?main>`'s current tip. Lets you squash and reword your branch's commits without pulling in upstream changes that would cause conflicts.

```bash
git rebase -i "$(git merge-base <@base:?main> HEAD)"
```

## delete branch on remote and local

```bash
branch="<@branch:git branch --format='%(refname:short)'>"

git push "<@remote>" --delete "$branch"
git branch -D "$branch"
```

## enable git lfs

```bash
git lfs install
```

## track file type with git lfs

```bash
git lfs track "<@pattern>"
git add .gitattributes
```

## migrate existing history to git lfs by file type

Rewrites every local ref so matching files in old commits use Git LFS. Run from a clean working tree with a backup; publishing the result requires force-pushing rewritten refs and coordinating with collaborators.

```bash
git lfs migrate import --everything --include="<@pattern>"
```
