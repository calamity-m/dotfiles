---
name: processes
tags:
  - cli
  - linux
  - terminal
variables:
  pid:
    command: ps -eo pid,comm --sort=comm --no-headers
---

# Processes

## find process listening on a port

Show which process (PID, command, user) is bound to a TCP port, e.g. checking what's holding `localhost:8080`.

```bash
lsof -i :<@port>
```

## kill process listening on a port

Force-kill whatever process is bound to a TCP port. Destructive: sends `SIGKILL` immediately with no confirmation prompt.

```bash
kill -9 $(lsof -t -i:<@port>)
```

## top CPU processes

Show the processes using the most CPU. `count` includes the header row, so the default of 11 shows the top 10 processes.

```bash
ps aux --sort=-%cpu | head -n <@count>
```

## top memory/ram processes

Show the processes using the most memory.

```bash
ps aux --sort=-%mem | head -n <@count>
```

## print process tree for a PID

Show a process and its descendants, so you can see what spawned what.

```bash
pstree -p $(awk '{print $1}' <<< '<@pid>')
```
