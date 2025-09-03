# Terraform Infrastructure

This directory contains Terraform configurations for managing the GKE clusters and related infrastructure that supports the fdk-infra GitOps setup.

## Structure

```
terraform/
├── dev/               # Development environment
├── prod/              # Production environment
├── modules/           # Reusable Terraform modules
└── shared/            # Shared resources (projects, IAM, etc.)
```

## Prerequisites

- Google Cloud SDK installed and configured
- Terraform >= 1.0
- Appropriate GCP permissions for GKE and VPC management

## Usage

1. Initialize Terraform in the desired environment:
```bash
cd dev  # or cd prod
terraform init
```

2. Plan the deployment:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

## Google Cloud Migration Tool

If using Google's `gcloud beta resource-config bulk-export` to migrate existing resources:

1. Export existing resources:
```bash
gcloud alpha resource-config bulk-export \
  --resource-format=terraform \
  --project=YOUR_PROJECT_ID \
  --path=./migrated/
```

2. Review and refactor the generated configurations
3. Import existing state:
```bash
terraform import google_container_cluster.main projects/PROJECT_ID/locations/LOCATION/clusters/CLUSTER_NAME
```