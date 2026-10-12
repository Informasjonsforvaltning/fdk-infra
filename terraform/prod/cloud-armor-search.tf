resource "google_compute_security_policy" "search" {
  # Layer 7 DDoS defence, opted in per policy via enable_ddos.
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = var.cloud_armor_policies.search.enable_ddos
      rule_visibility = "STANDARD"
    }
  }

  name    = var.cloud_armor_policies.search.name
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
    action      = "allow"
    description = "Allow / form http to redirect"

    match {
      expr {
        expression = "request.headers['host'] == 'www.fellesdatakatalog.digdir.no' || request.headers['host'] == 'fellesdatakatalog.digdir.no' || request.headers['host'] == 'data.transportportal.no'"
      }
    }

    priority = 1999
  }

  rule {
    action = "deny(403)"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.search_additional
      }
    }

    preview  = var.cloud_armor_policies.search.preview
    priority = 1001
  }

  rule {
    action = "deny(403)"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.search
      }
    }

    preview  = var.cloud_armor_policies.search.preview
    priority = 1000
  }

  # Priority sits after the WAF rules and ahead of the deny below.
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
    priority = 1090
  }

  # Expression lives in Secret Manager. This deny must be evaluated before the
  # host allow in this file, so keep its priority lower than that rule's. The
  # /robots.txt allow above is the one deliberate exception. The pinned
  # preview is deliberate too.
  rule {
    action = "deny(403)"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.search_block
      }
    }

    preview  = false
    priority = 1100
  }

  type = "CLOUD_ARMOR"
}
