# Production Environment

This directory contains Terraform configurations for the production environment.

## Usage

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply changes
terraform apply
```

## TODO

- Configure production project ID in variables.tf
- Add production-specific resources
- Configure remote state backend
- Set up proper RBAC and security policies