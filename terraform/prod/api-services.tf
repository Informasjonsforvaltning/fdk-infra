# Google Cloud API Services
# These APIs are required for the FDK infrastructure to function properly

# Core Infrastructure APIs
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  project = var.project_id
  service = "iam.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"

  disable_on_destroy = false
}

# Database APIs
resource "google_project_service" "sqladmin" {
  project = var.project_id
  service = "sqladmin.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "sql_component" {
  project = var.project_id
  service = "sql-component.googleapis.com"

  disable_on_destroy = false
}

# Storage APIs
resource "google_project_service" "storage_api" {
  project = var.project_id
  service = "storage-api.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "storage_component" {
  project = var.project_id
  service = "storage-component.googleapis.com"

  disable_on_destroy = false
}

# Artifact Registry
resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"

  disable_on_destroy = false
}

# Monitoring & Logging
resource "google_project_service" "logging" {
  project = var.project_id
  service = "logging.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "monitoring" {
  project = var.project_id
  service = "monitoring.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "clouderrorreporting" {
  project = var.project_id
  service = "clouderrorreporting.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "cloudtrace" {
  project = var.project_id
  service = "cloudtrace.googleapis.com"

  disable_on_destroy = false
}

# Security & Identity
resource "google_project_service" "iamcredentials" {
  project = var.project_id
  service = "iamcredentials.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "containersecurity" {
  project = var.project_id
  service = "containersecurity.googleapis.com"

  disable_on_destroy = false
}

# GKE Related APIs
resource "google_project_service" "gkeconnect" {
  project = var.project_id
  service = "gkeconnect.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "gkehub" {
  project = var.project_id
  service = "gkehub.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "containerfilesystem" {
  project = var.project_id
  service = "containerfilesystem.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "containerregistry" {
  project = var.project_id
  service = "containerregistry.googleapis.com"

  disable_on_destroy = false
}

# Networking & DNS
resource "google_project_service" "dns" {
  project = var.project_id
  service = "dns.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "networkconnectivity" {
  project = var.project_id
  service = "networkconnectivity.googleapis.com"

  disable_on_destroy = false
}

# Service Management
resource "google_project_service" "servicemanagement" {
  project = var.project_id
  service = "servicemanagement.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "serviceusage" {
  project = var.project_id
  service = "serviceusage.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "cloudapis" {
  project = var.project_id
  service = "cloudapis.googleapis.com"

  disable_on_destroy = false
}

# Additional APIs used by the platform
resource "google_project_service" "cloudbuild" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "cloudfunctions" {
  project = var.project_id
  service = "cloudfunctions.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "certificatemanager" {
  project = var.project_id
  service = "certificatemanager.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "oslogin" {
  project = var.project_id
  service = "oslogin.googleapis.com"

  disable_on_destroy = false
}