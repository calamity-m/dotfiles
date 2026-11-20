---
tags:
  - jq
  - json
  - data
  - cli
variables:
  json_file:
    command: fd -e json .
---

# jq snippets

## select first array item from command output

```bash
<@command> | jq '.[0]'
```

## select first array item keys

```bash
jq '.[0] | keys'
```

## list object keys from command output

```bash
<@command> | jq 'keys'
```

## count object keys from command output

```bash
<@command> | jq 'keys | length'
```

## Tail a file and run JQ on each line

```bash
tail -f <@json_file> | jq .
```

## convert json to single line

```bash
<@command> | jq -c
```

## JSON URL escape/quoted

```bash
<@command> | jq -R
```

## run jq on a live-tailed file

```bash
tail -f <@json_file> | jq .
```
