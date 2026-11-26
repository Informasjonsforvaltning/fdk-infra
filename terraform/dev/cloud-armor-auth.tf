resource "google_compute_security_policy" "auth" {
  # Layer 7 DDoS defence, opted in per policy via enable_ddos.
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = var.cloud_armor_policies.auth.enable_ddos
      rule_visibility = "STANDARD"
    }
  }

  name    = var.cloud_armor_policies.auth.name
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

  # Reuses the nginx-controller WAF expression, so Keycloak gets the same rules
  # as on ingress-nginx.
  rule {
    action = "deny(403)"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.nginx_controller
      }
    }

    preview  = var.cloud_armor_policies.auth.preview
    priority = 1000
  }

  # Admins reach the admin console and the master realm through localhost, so
  # the public host answers 404 for them, as for metrics, traversal and ';'.
  rule {
    action      = "deny(404)"
    description = "Keycloak metrics, admin and master realm are internal"

    match {
      expr {
        expression = "request.path.urlDecode().lower().matches('^/+(?:metrics|admin(?:/|$)|realms/+master(?:/|$))|/[.][.]?(?:/|$)|;')"
      }
    }

    priority = 1200
  }

  type = "CLOUD_ARMOR"
}
