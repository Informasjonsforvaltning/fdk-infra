resource "google_compute_security_policy" "search" {
  # Layer 7 DDoS defence, opted in per policy via enable_ddos.
  dynamic "adaptive_protection_config" {
    for_each = var.cloud_armor_policies.search.enable_ddos ? [1] : []
    content {
      layer_7_ddos_defense_config {
        enable          = true
        rule_visibility = "STANDARD"
      }
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

  # Expression lives in Secret Manager, as with the rules above. What matters
  # about the priority is that it stays below the allow at 1999: that rule
  # allows the very hosts this one has to cover, so anything above it would
  # match there first and let the traffic through. It also does not follow the
  # policy-level preview toggle, and stays enforcing during a dry run.
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
