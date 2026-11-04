# Minimum TLS version for the load balancers. Gateways attach it via
# GCPGatewayPolicy.
import {
  to = google_compute_ssl_policy.tls
  id = "projects/${var.project_id}/global/sslPolicies/${var.project_id}-tls"
}

resource "google_compute_ssl_policy" "tls" {
  min_tls_version = "TLS_1_2"
  name            = "${var.project_id}-tls"
  profile         = "RESTRICTED"
  project         = var.project_id
}
