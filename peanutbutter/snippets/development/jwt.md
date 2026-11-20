---
name: JWT helpers
description: Decode JWT headers and claims without verifying tokens
tags: [jwt, oauth, oidc]
---

## decode an OAuth/OIDC response's JWT ID token

Accept the default to read `$TOKEN_RESPONSE`, or enter a shell-quoted JSON response
(e.g. `'{"id_token":"eyJ…"}'`). Requires jq. Decodes claims only; does not verify
the signature or validate claims.

```bash
printf '%s\n' <@token_response:?"$TOKEN_RESPONSE"> | jq '
  .id_token | split(".") | .[1]
  | gsub("-"; "+") | gsub("_"; "/") | @base64d | fromjson
'
```

## decode a JWT and view its claims

Accept the default to read `$JWT`, or paste a compact JWT. Requires jq.
Decodes claims only; does not verify the signature or validate claims.

```bash
printf '%s\n' <@jwt:?"$JWT"> | jq -R '
  split(".") | .[1]
  | gsub("-"; "+") | gsub("_"; "/") | @base64d | fromjson
'
```

## view a JWT's header

Accept the default to read `$JWT`, or paste a compact JWT. Requires jq.
Decodes the header only; does not verify the signature or validate claims.

```bash
printf '%s\n' <@jwt:?"$JWT"> | jq -R '
  split(".") | .[0]
  | gsub("-"; "+") | gsub("_"; "/") | @base64d | fromjson
'
```
