# Terraform Environment Setup

This directory contains generic Terraform configuration for Google Cloud infrastructure. All sensitive values have been abstracted to variables and stored securely in Google Secret Manager, making the configuration reusable across any environment.

## 🏗️ Architecture

- **State Storage**: Google Cloud Storage (bucket name from GitHub secret)
- **Secrets Management**: Google Secret Manager for all sensitive variables
- **CI/CD**: GitHub Actions with Workload Identity Federation
- **Configuration**: Completely environment-agnostic and reusable

## 🚀 Setup Instructions

This Terraform configuration was built by abstracting an existing environment and is designed to be completely generic and reusable.

### 1. Prerequisites
- Existing GCP project with appropriate APIs enabled
- Terraform state bucket already created
- Service accounts and workload identity federation configured
- All sensitive values stored in Secret Manager

### 2. GitHub Repository Secrets

Configure these GitHub repository secrets for CI/CD:

```
WORKLOAD_IDENTITY_PROVIDER_<ENV> - The workload identity provider ID
TERRAFORM_SA_<ENV> - The terraform service account email  
TERRAFORM_BACKEND_BUCKET_<ENV> - The terraform state bucket name
```

Replace `<ENV>` with your environment name (e.g., DEV, PROD).

### 3. Secret Manager Configuration

The `terraform.tfvars.secret-manager` file contains all environment-specific values and should be uploaded to Secret Manager:

```bash
# Upload complete configuration to Secret Manager
gcloud secrets versions add terraform-<env>-sensitive-vars --data-file=terraform.tfvars.secret-manager
```

Replace `<env>` with your environment name (e.g., dev, prod).

### 4. Configuration Structure

All sensitive values are stored in `terraform.tfvars.secret-manager` including:

- **Core Infrastructure**: project_id, region, zone, GitHub repositories
- **Service Accounts**: All service account names and configurations  
- **Cloud Armor**: WAF sensitivity levels and opt-out rules for all policies
- **Database**: PostgreSQL instance configuration
- **Networking**: CIDR blocks and IP addresses
- **Storage**: Bucket names and project numbers
- **Snapshots**: MongoDB snapshot references for disk restoration

> **Note**: This configuration was abstracted from an existing environment. All resources are already deployed and managed through Terraform state.

## 🔐 Security Features

- **No hardcoded values**: All environment-specific values abstracted to variables
- **No secrets in repository**: All sensitive configs in Secret Manager
- **Workload Identity**: No service account keys in GitHub
- **Dynamic backend**: State bucket configured via GitHub secrets
- **Sanitized PR comments**: Plan details only in secure workflow logs
- **State locking**: Prevents concurrent modifications
- **Minimal permissions**: Service accounts follow principle of least privilege

## 📋 Local Development

For local development, create backend configuration:

```bash
# Create backend configuration
cat > backend.hcl <<EOF
bucket = "your-terraform-state-bucket"
EOF

# Download sensitive variables (requires appropriate GCP permissions)
gcloud secrets versions access latest --secret="terraform-<env>-sensitive-vars" > terraform.tfvars

# Initialize and plan
terraform init -backend-config=backend.hcl
terraform plan -var-file="terraform.tfvars"

# Cleanup
rm terraform.tfvars backend.hcl
```

**Important**: Never commit `terraform.tfvars` or `backend.hcl` files.

## 🔄 CI/CD Workflow

### Triggers
- **Pull Requests**: Plan only, posts summary comment
- **Main branch push**: Plan and apply automatically  
- **Path filtering**: Only runs when `terraform/<env>/**` files change

### Workflow Features
- Dynamic backend configuration from GitHub secrets
- Sensitive variables fetched from Secret Manager
- Plan output sanitized in PR comments (details in workflow logs)
- Automatic cleanup of sensitive files
- Concurrency control to prevent parallel runs

## 🧹 Maintenance

### Update configurations:
```bash
# Update sensitive variables
gcloud secrets versions add terraform-<env>-sensitive-vars --data-file=terraform.tfvars.secret-manager
```

### View terraform state:
```bash
terraform init -backend-config=backend.hcl
terraform state list
terraform state show <resource_name>
```

### Import existing resources:
```bash
terraform import <resource_type>.<resource_name> <resource_id>
```

## 📊 Managed Resources

This configuration manages:
- **15 Compute Disks** for Kafka, MongoDB, RabbitMQ, Zookeeper services
- **11 Cloud Armor Policies** with dynamic WAF rules and opt-outs
- **9 Service Accounts** for various services and CI/CD
- **6 Global IP Addresses** for load balancers
- **4 Storage Buckets** for Cloud Functions and metrics
- **1 GKE Cluster** with 2 node pools
- **1 PostgreSQL Database** instance
- **1 Artifact Registry** for Cloud Functions
- **Various IAM bindings** and Workload Identity Federation setup

All resources use abstracted naming and configuration for environment portability.
