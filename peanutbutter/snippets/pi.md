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
