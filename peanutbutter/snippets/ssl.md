---
tags:
  - ssl
  - openssl
  - certificates
variables:
  cert:
    command: rg --files -g '*.crt' -g '*.pem'
  p12:
    command: rg --files -g '*.p12' -g '*.pfx'
  jks:
    command: rg --files -g '*.jks'
  key:
    command: rg --files -g '*.key' -g '*.pem'
  out_crt:
    default_value: client.crt
  out_key:
    default_value: client.key
  out_csr:
    default_value: client.csr
  bits:
    suggestions:
      - 4096
      - 2048
---

# SSL

## Inspect cert

```bash
openssl x509 -in <@cert> -noout -text
```

## Inspect p12 cert

```bash
openssl pkcs12 -in <@p12> -nokeys -info
```

## Inspect JKS keystore

```bash
keytool -list -v -keystore <@jks>
```

## Inspect JKS single alias

```bash
keytool -list -v -keystore <@jks> -alias <@alias>
```

## Extract cert from p12

```bash
openssl pkcs12 -in <@p12> -clcerts -nokeys -out <@out_crt>
```

## Extract key from p12

```bash
openssl pkcs12 -in <@p12> -nocerts -nodes -out <@out_key>
```

## Extract cert from p12 (legacy)

```bash
openssl pkcs12 -legacy -in <@p12> -clcerts -nokeys -out <@out_crt>
```

## Extract key from p12 (legacy)

```bash
openssl pkcs12 -legacy -in <@p12> -nocerts -nodes -out <@out_key>
```

## Validate cert

```bash
openssl x509 -in <@cert> -text -noout
```

## Validate p12

```bash
openssl pkcs12 -in <@p12> -info -noout
```

## Validate p12 (legacy)

```bash
openssl pkcs12 -legacy -in <@p12> -info -noout
```

## Change passphrase on p12

Goes via a temp PEM because `-export` can't read both key and cert from a pipe.

```bash
pem=$(mktemp) && openssl pkcs12 -in <@p12> -nodes -out "$pem" && openssl pkcs12 -export -in "$pem" -out <@out_p12>; rm -f "$pem"
```

## Strip passphrase from p12

Re-export with no encryption and an empty password.

```bash
pem=$(mktemp) && openssl pkcs12 -in <@p12> -nodes -out "$pem" && openssl pkcs12 -export -in "$pem" -keypbe NONE -certpbe NONE -passout pass: -out <@out_p12>; rm -f "$pem"
```

## Strip passphrase from p12 (legacy)

```bash
pem=$(mktemp) && openssl pkcs12 -legacy -in <@p12> -nodes -out "$pem" && openssl pkcs12 -export -in "$pem" -keypbe NONE -certpbe NONE -passout pass: -out <@out_p12>; rm -f "$pem"
```

## Create CSR with new key

Generates an unencrypted RSA key alongside the CSR.

```bash
openssl req -new -newkey rsa:<@bits> -nodes -keyout <@out_key> -out <@out_csr> -subj "/CN=<@cn>"
```

## Create CSR from existing key

```bash
openssl req -new -key <@key> -out <@out_csr> -subj "/CN=<@cn>"
```

## Create RSA private key

```bash
openssl genrsa -out <@out_key> <@bits>
```

## Import cert into JKS keystore

```bash
keytool -importcert -file <@cert> -keystore <@jks> -alias <@alias>
```

## Convert p12 to jks

```bash
keytool -importkeystore -srckeystore <@p12> -srcstoretype PKCS12 -destkeystore <@out_jks> -deststoretype JKS
```

## Convert jks to p12

```bash
keytool -importkeystore -srckeystore <@jks> -srcstoretype JKS -destkeystore <@out_p12> -deststoretype PKCS12
```

## Convert cert and key to p12

```bash
openssl pkcs12 -export -in <@cert> -inkey <@key> -out <@out_p12>
```

## Delete alias from JKS keystore

```bash
keytool -delete -alias <@alias> -keystore <@jks>
```
