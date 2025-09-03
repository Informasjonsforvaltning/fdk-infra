
resource "google_compute_security_policy" "nginx_controller" {
  dynamic "adaptive_protection_config" {
    for_each = var.cloud_armor_policies.nginx_controller.enable_ddos ? [1] : []
    content {
      layer_7_ddos_defense_config {
        enable = true
      }
    }
  }

  name    = var.cloud_armor_policies.nginx_controller.name
  project = var.project_id

  rule {
    action      = "allow"
    description = "Default rule, higher priority overrides it"

    match {
      config {
        src_ip_ranges = ["*"]
      }

      versioned_expr = "SRC_IPS_V1"
    }

    priority = 2147483647
  }

  rule {
    action = "deny(403)"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.nginx_controller
      }
    }

    preview  = var.cloud_armor_policies.nginx_controller.preview
    priority = 1000
  }

  type = "CLOUD_ARMOR"
}
