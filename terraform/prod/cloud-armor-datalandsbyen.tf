resource "google_compute_security_policy" "datalandsbyen" {
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = var.cloud_armor_policies.datalandsbyen.enable_ddos
    }
  }

  advanced_options_config {
    json_parsing = "STANDARD"
  }

  name    = var.cloud_armor_policies.datalandsbyen.name
  project = var.project_id

  recaptcha_options_config {
    redirect_site_key = var.recaptcha_site_key
  }

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
    action      = "redirect"
    description = "reCaptcha for innlogging utenfor Norge"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.datalandsbyen
      }
    }

    priority = 1000

    redirect_options {
      type = "GOOGLE_RECAPTCHA"
    }
  }

  type = "CLOUD_ARMOR"
}
