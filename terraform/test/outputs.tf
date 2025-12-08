# Outputs for Performance Testing Cluster

output "cluster_name" {
  description = "The name of the test cluster"
  value       = google_container_cluster.test.name
}

output "cluster_endpoint" {
  description = "The endpoint of the test cluster"
  value       = google_container_cluster.test.endpoint
  sensitive   = true
}

output "cluster_location" {
  description = "The location of the test cluster"
  value       = google_container_cluster.test.location
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --zone=${var.zone} --project=${var.project_id}"
}

output "test_namespace" {
  description = "The Kubernetes namespace for testing"
  value       = kubernetes_namespace.test.metadata[0].name
}