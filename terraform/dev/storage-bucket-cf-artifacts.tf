resource "google_artifact_registry_repository" "gcf_artifacts" {
  description = "This repository is created and used by Cloud Functions for storing function docker images."
  format      = "DOCKER"

  labels = {
    goog-managed-by = "cloudfunctions"
    managed-by-cnrm = "true"
  }

  location      = var.region
  mode          = "STANDARD_REPOSITORY"
  project       = var.project_id
  repository_id = "gcf-artifacts"
}
