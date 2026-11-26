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

  # Exempts trusted sources, so server-side token calls from the frontends are
  # not counted.
  rule {
    action      = "allow"
    description = "Trusted sources, exempt from the request limits"

    match {
      config {
        src_ip_ranges = var.cloud_armor_trusted_ranges
      }

      versioned_expr = "SRC_IPS_V1"
    }

    priority = 1300
  }

  dynamic "rule" {
    for_each = local.keycloak_login_limits

    content {
      action      = "rate_based_ban"
      description = "Request limit for Keycloak ${rule.key}"

      match {
        expr {
          expression = "request.path.urlDecode().lower().matches('^/+realms/+[^/]+/+${rule.value.path}')"
        }
      }

      priority = rule.value.priority

      rate_limit_options {
        ban_duration_sec = 600
        conform_action   = "allow"
        enforce_on_key   = "IP"
        exceed_action    = "deny(429)"

        ban_threshold {
          count        = rule.value.count * 2
          interval_sec = 60
        }

        rate_limit_threshold {
          count        = rule.value.count
          interval_sec = 60
        }
      }
    }
  }

  type = "CLOUD_ARMOR"
}

locals {
  # Per-IP limits per minute on the login and token endpoints. A client over
  # the limit gets 429, and one that reaches twice the limit or more is banned
  # for ten minutes.
  # The token limit leaves room for the end-to-end tests, which log in to
  # staging from CI runners.
  keycloak_login_limits = {
    "login-actions" = { priority = 1400, path = "login-actions/", count = 30 }
    "token"         = { priority = 1401, path = "protocol/+openid-connect/+token(?:/|$)", count = 600 }
  }
}
