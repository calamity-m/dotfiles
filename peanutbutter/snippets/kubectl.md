---
tags:
  - kubernetes
  - kubectl
  - cli
  - containers
  - devops
variables:
  resource:
    suggestions:
      - deployment
      - service
      - configmap
      - ingress
      - httproutes.gateway.networking.k8s.io
  pod:
    command: "kubectl get pod --no-headers -o custom-columns=NAME:.metadata.name"
  pod-command:
    default: "sh"
---

# Kubectl

## explain a Kubernetes resource

The suggestions are starting points, not fixed choices: pick one, then keep
typing to drill into a field, e.g. `deployment.spec.template`. `httproute`
uses its fully qualified `<group>.<resource>` name
(`httproutes.gateway.networking.k8s.io`) since it is a Gateway API CRD, not a
built-in resource kubectl otherwise resolves unambiguously.

```bash
kubectl explain <@resource>
```

## decode a Kubernetes secret value and save it

```bash
kubectl get secret \
  <@secret:kubectl get secret --no-headers -o custom-columns=NAME:.metadata.name> \
  -o jsonpath='{.data.<@key:kubectl get secret <#secret> -o go-template='{{range $k, $_ := .data}}{{$k}}{{"\n"}}{{end}}'>}' \
  | base64 -d \
  | tee <@output:?<#secret:raw>.<#key:raw>.out>
echo
```

## run a command in a pod's default container

```bash
kubectl exec -it <@pod> -- <@pod-command>
```
