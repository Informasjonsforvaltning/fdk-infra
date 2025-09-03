# Terraform backend configuration
# State stored in Google Cloud Storage for collaboration and locking

terraform {
  backend "gcs" {
    # Backend configuration injected by GitHub Actions
    # See .github/workflows/terraform-dev.yml for dynamic configuration
    prefix = "terraform/dev"

    # Optional: Enable state locking (requires Cloud Storage API)
    # State locking prevents concurrent modifications
  }

  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}