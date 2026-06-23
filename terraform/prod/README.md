# Production Environment

Terraform configuration for the production environment.

- **State**: GCS backend, bucket from the `TERRAFORM_BACKEND_BUCKET_PROD` secret
  (prefix `terraform/prod`).
- **Secrets**: `terraform-prod-sensitive-vars` in Secret Manager.
- **Apply**: on merge to `main`, gated by the protected `production` GitHub
  environment — a manual approval from the required reviewer team is needed
  before any cloud credentials are minted.

For the change workflow, the PR documentation convention, and local-plan
instructions, see [`../README.md`](../README.md).

> Production applies are irreversible against live infrastructure. Always
> confirm the CI plan summary matches the PR's expected plan before approving.
