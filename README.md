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
htpasswd -c /dev/stdout <user> | xargs -i kubectl create secret -n monitoring generic basic-auth --from-literal=auth={}
```

### Slack api key for alertmanager

```
kubectl create secret -n monitoring generic alertmanager-slack --from-literal=apiurl=<slack api url>
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
