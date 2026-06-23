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
├── infrastructure/                # Base infrastructure components and dependencies
│   ├── base/                      # Base components shared across environments
│   ├── dev/                       # Development-specific components
│   └── prod/                      # Production-specific components
│
└── terraform/                     # Infrastructure as Code for cloud resources
    ├── dev/                       # Development environment Terraform configs
    └── prod/                      # Production environment Terraform configs
```

## Prerequisites
- Ensure the following tools are installed:
  - [Flux CLI](https://fluxcd.io/docs/installation/)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/)
  - [htpasswd](https://httpd.apache.org/docs/current/programs/htpasswd.html)
  - [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) (for infrastructure management)
  - [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) (for GCP authentication)
- Access to the target Kubernetes cluster
- Appropriate GCP permissions for infrastructure management
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
### 2. Infrastructure Management:
The `terraform/` directory contains Infrastructure as Code for the GCP resources (GKE, Cloud SQL, networking, etc.) behind the clusters. Changes are applied through CI, not from a laptop:
- **GitOps via CI**: pull requests run `terraform plan` (sanitized summary only); merges to `main` apply — dev automatically, prod behind a manual approval.
- **Secure by design**: all sensitive values stored in Secret Manager; Workload Identity Federation, no static keys.
- **Public-repo safe**: the full plan/apply diff is never printed to the logs.

See [terraform/README.md](terraform/README.md) for the change workflow and PR documentation convention, and [terraform/dev/README.md](terraform/dev/README.md) for environment specifics.

### 3. Deploy applications:<br>
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
