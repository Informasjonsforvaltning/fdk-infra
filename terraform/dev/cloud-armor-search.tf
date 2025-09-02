
resource "google_compute_security_policy" "search" {
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
    action = "allow"

    match {
      expr {
        expression = "request.headers['host'] == 'www.staging.fellesdatakatalog.digdir.no' || request.headers['host'] == 'www.demo.fellesdatakatalog.digdir.no' || request.headers['host'] == 'staging.fellesdatakatalog.digdir.no' || request.headers['host'] == 'demo.fellesdatakatalog.digdir.no'"
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

  type = "CLOUD_ARMOR"
}
