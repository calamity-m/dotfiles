---
name: docker
tags:
  - docker
  - containers
  - devops
description: Docker commands and snippets
variables:
  container:
    command: docker ps --format '{{.Names}}'
  any_container:
    command: docker ps -a --format '{{.Names}}'
  shell:
    suggestions:
      - bash
      - sh
---

# Docker

## exec into a running container

Pick a running container and open an interactive shell in it. Use `sh` for minimal images (alpine, distroless-ish) that don't ship bash.

```bash
docker exec -it "<@container>" <@shell>
```

## follow container logs

Stream logs from a running container, starting from the last N lines.

```bash
docker logs -f --tail <@lines:?100> "<@container>"
```

## show container logs since a time

Works on stopped containers too, handy for seeing why something crashed. Accepts relative times like `10m` or `2h`, or a timestamp like `2026-01-01T12:00:00`.

```bash
docker logs --timestamps --since <@since:?10m> "<@any_container>"
```

## save container logs to a file

Includes stderr, which `docker logs` otherwise keeps separate.

```bash
docker logs "<@any_container>" > <@file:?container.log> 2>&1
```
