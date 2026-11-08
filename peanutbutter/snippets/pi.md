---
tags:
  - coding-agent
  - ai
  - pi
description: Commands for the pi coding agent
---

# Pi

## install pi plugin from GitHub

Install a pi package globally over SSH. Enter the GitHub path as `owner/repository` (not a full URL). Requires GitHub SSH access; only install packages you trust.

```sh
pi install git:git@github.com:<@owner>/<@repository>
```

## update extensions only

```sh
pi update --extensions
```

## run a headless task

Run a prompt in the current directory, print the final response, and exit. Uses your configured model and credentials; Pi can edit files and run commands. The quoted heredoc keeps shell syntax in the prompt literal.

```sh
pi --print <<'PI_PROMPT'
<@prompt>
PI_PROMPT
```

## review staged changes headlessly

Send the staged Git diff to Pi and print a bug-focused review without saving a session. Limits model tools to file reading and searching and disables built-in MCP support; this is not an OS sandbox.

```sh
git diff --cached --no-ext-diff --no-color | pi --print --no-session --no-mcp --tools read,grep,find,ls "Review this staged diff for bugs and regressions. Inspect surrounding files as needed. Report actionable findings with file paths and line numbers; do not modify files. If there are no findings, say so."
```
