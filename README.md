# fdk-infra

Repo for FDK-infrastructure

## Setup

```
export GITHUB_TOKEN=<github token>

flux bootstrap github \
  --owner=Informasjonsforvaltning \
  --repository=fdk-infra \
  --branch=main \
  --path=./clusters/<cluster>
```

## Secrets

Secrets must be created manually.

### Basic auth for ingresses

```
htpasswd -c /dev/stdout <user> | xargs -i kubectl create secret -n monitoring generic ingress-basic-auth --from-literal=auth={}
```

### Slack api key for alertmanager

```
kubectl create secret -n flux-system generic kube-prometheus-stack-alertmanager --from-literal=slack-apiurl=<slack api url>
```

### Grafana password

```
kubectl create secret -n flux-system generic kube-prometheus-stack-grafana --from-literal=password=<password>
```

### Storage bucket for thanos

`objstore.yml`

```
type: GCS
config:
  bucket: "<bucket name>"
  service_account: |-
    {
    "type": "service_account",
    ...
    }
```

```
kubectl create secret -n monitoring generic thanos-objstore --from-file=objstore.yml=objstore.yml
```
