# FDK-infra

This repository contains the infrastructure-as-code (IaC) configurations for the Data.norge.no project. <br>
The infrastructure is orchestrated using Flux CD for continuous delivery to Kubernetes clusters.

## Overview
The infrastructure leverages GitOps principles to manage Kubernetes deployments. Key components include:
- **Flux CD**: For continuous deployment and synchronization of Kubernetes manifests.
- **Prometheus & Grafana**: For monitoring and alerting.
- **Thanos**: For long-term storage of Prometheus metrics.
- **NGINX Ingress Controller**: For managing external access to services.
- **MongoDB Replica Set**: For data storage.
- **Elasticsearch (ECK)**: For search capabilities.
- **Trivy Operator**: For vulnerability scanning.
- **External Secrets Operator**: For managing secrets from external sources.

## Directory structure
```
fdk-infra/
├── apps/                          # Application-specific configurations (via HelmReleases)
│   ├── base/                      # Shared app configs across environments
│   ├── dev/                       # App configs specific to the development cluster
│   └── prod/                      # App configs specific to the production cluster
│
├── clusters/                      # Entry points for Flux per Kubernetes cluster
│   ├── dev/                       # Flux kustomization tree for development
│   └── prod/                      # Flux kustomization tree for production
│
└── infrastructure/                # Base infrastructure components and dependencies
    ├── base/                      # Base components shared across environments
    ├── dev/                       # Development-specific components
    └── prod/                      # Production-specific components
```

## Prerequisites
- Ensure the following tools are installed:
  - [Flux CLI](https://fluxcd.io/docs/installation/)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/)
  - [htpasswd](https://httpd.apache.org/docs/current/programs/htpasswd.html)
- Access to the target Kubernetes cluster
- Appropriate permissions to create secrets and deploy resources

## Setup and Deployment

### 1. Bootstrap Flux CD:
```
export GITHUB_TOKEN=<your_github_token>

flux bootstrap github \
  --owner=Informasjonsforvaltning \
  --repository=fdk-infra \
  --branch=main \
  --path=./clusters/<cluster_name>
```
### 2. Deploy applications:<br>
Flux will automatically synchronize the manifests defined in the repository to the specified cluster.

## Managing secrets
Certain secrets must be manually created in the Kubernetes cluster:
### Basic Authentication for Ingresses
For securing endpoints with basic auth:
```
htpasswd -c /dev/stdout <username> | xargs -i kubectl create secret -n monitoring generic ingress-basic-auth --from-literal=auth={}
htpasswd -c /dev/stdout <username> | xargs -i kubectl create secret -n logging generic ingress-basic-auth --from-literal=auth={}
```
### Slack API Key for Alertmanager
To enable Slack notifications:
```
kubectl create secret -n flux-system generic kube-prometheus-stack-alertmanager --from-literal=slack-apiurl=<slack_api_url>
```
### Grafana Admin Password
Set the Grafana admin password:
```
kubectl create secret -n flux-system generic kube-prometheus-stack-grafana --from-literal=password=<your_password>
```
### Thanos Object Storage Configuration
Create a `objstore.yml` file with your GCS bucket configuration:
```yaml
type: GCS
config:
  bucket: "<bucket_name>"
  service_account: |-
    {
      "type": "service_account",
      ...
    }
```
Then create the Kubernetes secret:
```
kubectl create secret -n monitoring generic thanos-objstore --from-file=objstore.yml=objstore.yml
```

## Secrets

Secrets must be created manually.

### Basic auth for ingresses

```
htpasswd -c /dev/stdout <user> | xargs -i kubectl create secret -n monitoring generic ingress-basic-auth --from-literal=auth={}
```

```
htpasswd -c /dev/stdout <user> | xargs -i kubectl create secret -n logging generic ingress-basic-auth --from-literal=auth={}
```

### Slack api key for alertmanager

```
kubectl create secret -n flux-system generic kube-prometheus-stack-alertmanager --from-literal=slack-apiurl=<slack_api_url>
```

### Grafana password

```
kubectl create secret -n flux-system generic kube-prometheus-stack-grafana --from-literal=password=<password>
```

### Storage bucket for thanos
You need to create a `objstore.yml` file, which contains the bucket name and a service account key for the GCS bucket. The file should look like this:

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
Then create the secret in the `monitoring` namespace:
```
kubectl create secret -n monitoring generic thanos-objstore --from-file=objstore.yml=objstore.yml
```
