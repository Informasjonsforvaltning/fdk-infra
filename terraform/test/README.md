# Performance Testing Cluster

This directory contains Terraform configuration for a dedicated performance testing GKE cluster.

## Overview

- **Purpose**: Performance and load testing
- **Network**: Separate IP ranges to avoid conflicts with other clusters

## Prerequisites

Before creating the test cluster, ensure the following network resources exist in your shared VPC:

1. Subnet for the test cluster
2. Secondary IP ranges for pods and services

Refer to your internal network documentation or infrastructure team for the specific network configuration.

## Setup

1. **Upload terraform.tfvars to Secret Manager**:

Variables should be stored in Secret Manager following the same pattern as other environments.

2. **Fetch terraform.tfvars from Secret Manager**:

```bash
# Fetch variables from Secret Manager
gcloud secrets versions access latest \
  --secret=terraform-test-sensitive-vars \
  --project=<project-id> > terraform.tfvars
```

3. **Initialize Terraform**:

```bash
cd terraform/test
terraform init
```

4. **Review and apply**:

```bash
terraform plan
terraform apply
```

## Cluster Access

After the cluster is created, configure kubectl access:

```bash
gcloud container clusters get-credentials <cluster-name> \
  --zone=<zone> \
  --project=<project-id>
```

## Configuration

The cluster configuration follows the same patterns as other environments but with:
- Separate network ranges to prevent IP conflicts
- Node pools optimized for performance testing workloads
- Shared service accounts for workload identity

Specific configuration values are stored in Secret Manager.

## Cost Management

To minimize costs when not actively testing:

```bash
# Scale down node pool
gcloud container clusters resize <cluster-name> \
  --node-pool=<pool-name> \
  --num-nodes=0

# Scale back up when needed
gcloud container clusters resize <cluster-name> \
  --node-pool=<pool-name> \
  --num-nodes=<desired-count>
```

Or destroy the cluster entirely:

```bash
terraform destroy
```

## Deploying Applications

The cluster uses the same service accounts as the dev environment, so existing workload identity bindings work.

Deploy applications by setting the namespace to `test` in your deployment manifests.

## Differences from Other Environments

- Simplified configuration focused on performance testing
- Independent lifecycle - can be destroyed and recreated without impacting other environments
- Separate network ranges
- No shared data resources by default

## Troubleshooting

**IP range conflicts**: Verify network ranges don't overlap with existing clusters

**Nodes not starting**: Ensure subnet and secondary ranges exist in the shared VPC

**Access issues**: Verify service account permissions are properly configured

For specific configuration details, refer to the values stored in Secret Manager or consult your infrastructure team.