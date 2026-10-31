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
  out_crt:
    default: client.crt
  out_key:
    default: client.key
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

```bash
openssl pkcs12 -in <@p12> -nodes | openssl pkcs12 -export -out <@out_p12>
```

## Create RSA key

```bash
openssl genrsa -out <@out_key> <@bits>
```

## Inspect JKS keystore

```bash
keytool -list -v -keystore <@jks>
```

## Inspect JKS single alias

```bash
keytool -list -v -keystore <@jks> -alias <@alias>
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

## Delete alias from JKS keystore

```bash
keytool -delete -alias <@alias> -keystore <@jks>
```
