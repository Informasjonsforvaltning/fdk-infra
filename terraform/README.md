# Terraform Infrastructure

This directory contains the Terraform configurations for the GKE clusters and
supporting GCP resources behind the fdk-infra GitOps setup. Changes are applied
through CI (GitHub Actions), not from a laptop — see the workflow below.

## Structure

```
terraform/
├── dev/    # Development environment
└── prod/   # Production environment
```

Each environment is self-contained: its own `.tf` files, its own GCS state
backend, and its own `terraform-<env>-sensitive-vars` secret in Secret Manager.
See `dev/README.md` and `prod/README.md` for environment specifics.

## How changes get applied (CI/GitOps)

This is a **public repository**, so the CI is deliberately quiet about details:

- **Trigger**: a change under `terraform/<env>/**` on a pull request or on a
  push to `main`.
- **Pull request** → `terraform plan` only. CI posts a sanitized summary comment
  (counts of add/change/destroy/replace). The full plan diff is **never** printed
  to the public log — stdout (which carries variable values) is redirected away
  and only error diagnostics on stderr are surfaced on failure.
- **Push to `main`** → `terraform apply`.
  - **dev** applies automatically.
  - **prod** is gated by the protected `production` GitHub environment and
    requires a manual approval from the required reviewer team before the cloud
    credentials are even minted.
- **Auth**: Workload Identity Federation — no service-account keys in GitHub.
- **Secrets**: sensitive variables are fetched at runtime from Secret Manager
  (`terraform-<env>-sensitive-vars`) and cleaned up after every run.

The plan diff is deliberately kept out of the logs entirely — there is no
secured log to fall back on. So **reviewers verify the actual plan by running it
locally** (see below); the PR text is the human-readable statement of intent, not
a substitute for the plan.

## Making a change

1. Edit the `.tf` files under `terraform/dev/` or `terraform/prod/`.
2. Preview a **refreshed** plan locally (see *Local development*). Refresh
   matters: it reconciles config against live GCP and is what CI does.
3. If you changed any sensitive value, publish a new Secret Manager version
   **before** opening the PR (otherwise CI plans against stale values):
   ```bash
   gcloud secrets versions add terraform-<env>-sensitive-vars \
     --data-file=terraform.tfvars.secret-manager \
     --project=<project-id>
   ```
4. Open a PR and document it using the convention below.
5. CI posts the plan summary. Confirm it matches your expectation, get a review,
   then merge — dev applies on merge, prod waits for approval.

## PR description convention

Every Terraform PR should make it possible to review intent **without** the full
diff. Include two things:

### 1. What changed
A plain-language list of the resources/files touched and why — no values.

```
## What changed
- gke-cluster.tf: ignore out-of-band node_config drift so it stops forcing replacement
- disks-*.tf: track the retained MongoDB primary disks (prevent_destroy)
- postgresql-database.tf: re-tune memory flags for the upgraded instance
```

### 2. Expected plan
State the summary counts and a one-line reason for every **destroy** and
**replace** (those are the dangerous actions). Adds/changes can be summarized.

```
## Expected plan
`terraform plan` → **0 to add, 1 to change, 2 to destroy**

- Change: SQL instance — performance flag re-tune (in-place).
- Destroy: an unused service account — orphaned, superseded by the deploy SA.
- Destroy: a leftover persistent disk from a removed service.
```

After CI runs, a one-line note that the posted summary matches (e.g. *"CI
confirms 0/1/2"*) closes the loop.

### Do **not** put in the PR (or any public log)
IP addresses or CIDR blocks, WAF expressions, DB flag values, credentials,
service-account names/emails, bucket/project numbers, secret-file contents, or
the raw `terraform plan` / `apply` output. Refer to resources by role or purpose
instead. If a reviewer needs the exact diff, they run it locally.

## Local development

```bash
cd dev   # or prod

# Backend bucket (kept out of git; same value as the TERRAFORM_BACKEND_BUCKET_<ENV> secret)
cat > backend.hcl <<EOF
bucket = "<state-bucket>"
EOF

# Sensitive variables (requires GCP access; never commit the result)
gcloud secrets versions access latest \
  --secret="terraform-<env>-sensitive-vars" \
  --project=<project-id> > terraform.tfvars

terraform init -backend-config=backend.hcl
terraform plan -var-file="terraform.tfvars"      # refreshed plan, as CI runs it

# Always clean up
rm -f terraform.tfvars backend.hcl
```

> **Never commit** `terraform.tfvars`, `terraform.tfvars.secret-manager`, or
> `backend.hcl`. They hold real secrets and are git-ignored — keep it that way.

## Migrating existing resources

To bring already-deployed resources under Terraform:

```bash
# Export existing resources to HCL (review/refactor before use)
gcloud alpha resource-config bulk-export \
  --resource-format=terraform \
  --project=YOUR_PROJECT_ID \
  --path=./migrated/

# Import an existing resource into state
terraform import <resource_type>.<resource_name> <resource_id>
```
