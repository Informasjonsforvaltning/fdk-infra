# Terraform backend configuration
# State stored in Google Cloud Storage for collaboration and locking

terraform {
  backend "gcs" {
    # Backend configuration injected at init time
    prefix = "terraform/test"
  }

  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}