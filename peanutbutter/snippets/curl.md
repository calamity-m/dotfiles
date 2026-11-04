---
tags:
  - curl
  - http
variables:
  cert:
    command: rg --files -g '*.crt' -g '*.pem'
  key:
    command: rg --files -g '*.pem' -g '*.key'
  p12:
    command: rg --files -g '*.p12' -g '*.pfx'
  json_file:
    command:
  method:
    suggestions:
      - POST
      - PUT
      - PATCH
---

# Curl

## curl with client certificate and key

```bash
curl --cert '<@cert>' --key <@key> '<@url>'
```

## curl with p12 client certificate

You'll be prompted for the password.

If you want to provide it in the call, e.g. from an env var - add it after the empty `:`.

e.g. --cert my-p12.p12:${ENV_VAR}

```bash
curl --cert-type P12 --cert '<@p12>: '<@url>'
```

## send authorization header in curl request

```bash
curl -H "Authorization: Bearer <@authorization_header>" <@url>
```

## send url form encoded data

```bash
curl -X <@method> \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d '<@field>=<@value>' \
  '<@url>'
```

## send json data

```bash
curl -X <@method> \
  -H "Content-Type: application/json" \
  -d '{"<@field>": "<@value>"}' \
  '<@url>'
```

## send json file

```bash
curl -X <@method> \
  -H 'Content-Type: application/json' \
  --data-binary @<@json_file:rg --files -g '*.json'> \
  '<@url>'
```

## save curl output as file

Saves the output of the curl to given url to the provided file.

Swap for -O ..., e.g. curl -O https://.. to save it with the original/default filename.

```bash
curl --create-dirs -o <@output_file> <@url>
```

## test sse endpoint

An example sse endpoint is https://stream.wikimedia.org/v2/stream/recentchange

```bash
curl -N -H "Accept: text/event-stream" <@sse_endpoint>
```

## test http version

Output will be the http version used, i.e. 2 or 1.1.

```bash
curl -sI <@url>
```
