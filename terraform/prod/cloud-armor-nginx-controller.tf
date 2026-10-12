resource "google_compute_security_policy" "nginx_controller" {
  # Layer 7 DDoS defence, opted in per policy via enable_ddos.
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = var.cloud_armor_policies.nginx_controller.enable_ddos
      rule_visibility = "STANDARD"
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

  # Priority sits after the WAF rule and ahead of the deny below.
  # robots.txt only has effect if it can be fetched.
  rule {
    action      = "allow"
    description = "Allow /robots.txt"

    match {
      expr {
        expression = "request.path == '/robots.txt'"
      }
    }

    preview  = false
    priority = 1085
  }

  # Expression lives in Secret Manager. The pinned preview is deliberate.
  # It is the last rule before the default allow.
  rule {
    action = "deny(403)"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.nginx_controller_block
      }
    }

    preview  = false
    priority = 1090
  }

  type = "CLOUD_ARMOR"
}
