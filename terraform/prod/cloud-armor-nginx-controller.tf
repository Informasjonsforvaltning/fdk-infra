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

  # Parameters live in Secret Manager, as with the rules above.
  rule {
    action = "rate_based_ban"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.nginx_controller_throttle
      }
    }

    rate_limit_options {
      ban_duration_sec = var.cloud_armor_rate_limits.nginx_controller.ban_duration_sec
      conform_action   = "allow"
      enforce_on_key   = "ALL"
      exceed_action    = "deny(429)"

      ban_threshold {
        count        = var.cloud_armor_rate_limits.nginx_controller.ban_threshold_count
        interval_sec = var.cloud_armor_rate_limits.nginx_controller.ban_threshold_interval_sec
      }

      rate_limit_threshold {
        count        = var.cloud_armor_rate_limits.nginx_controller.threshold_count
        interval_sec = var.cloud_armor_rate_limits.nginx_controller.threshold_interval_sec
      }
    }

    preview  = var.cloud_armor_rate_limits.nginx_controller.preview
    priority = 1100
  }

  type = "CLOUD_ARMOR"
}
