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
  worktree:
    command: git worktree list --porcelain | awk '/^worktree / { sub(/^worktree /, ""); print }'
---

# Git

## conventional commit

Commits with a `type(scope): subject` prefix. The `type` placeholder is backed by a frontmatter suggestion list — open the picker and you'll see the choices. `scope` and `subject` are free-form.

```bash
git commit -m "<@type>(<@scope>): <@subject>"
```

## amend latest commit title

```bash
git commit --amend -m "<@message>"
```

## list tracked files alongside changed ones

This will print every single tracked file in the repository prefixed with a status tag:

- H / C : Cached / Tracked (Unchanged)
- M : Unstaged modification
- R : Unstaged removal/deletion
- C : Unmerged / Conflict

```bash
git ls-files -t
```

## pull main without switching

Fetches `main` from the remote into the local `main` branch while staying on your current branch.

```bash
git fetch <@remote> main:main
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

## delete local branches except main or master

```bash
git switch main || git switch master
git branch --format='%(refname:short)' | grep -Ev '^(main|master)$' | xargs -r git branch -D
```

## delete all branches except for those that exist on the remote

```bash
git fetch --prune
git branch -vv | awk '/: gone]/{print $1 == "*" ? $2 : $1}' | xargs -r git branch -D
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

## revert merge commit

Undo a merge commit while keeping the first parent, usually the branch you merged into. Be careful: reverting merges can affect future attempts to merge the same branch again.

```bash
git revert -m 1 <@merge_commit:git log --merges --format=%h --max-count=30>
```

## revert a commit range as one commit

Revert a contiguous range without committing each revert separately.

Note: `old..new` means commits after `old` up to and including `new`; it does not include `old`.

```bash
git revert --no-commit <@old_commit:git log --format=%h --max-count=30>..<@new_commit:git log --format=%h --max-count=30>
```

## show worktrees

```bash
git worktree list --verbose
```

## create worktree for branch

```bash
git worktree add "<@path:?../repo-worktree>" "<@branch>' --sort=-committerdate>"
```

## move to worktree location

```bash
cd "<@worktree>"
```

## remove a worktree

```bash
git worktree remove "<@worktree>"
```
