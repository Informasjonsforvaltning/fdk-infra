locals {
  # Health and metrics endpoints are for the cluster only.
  cloud_armor_internal_paths = "request.path.urlDecode().lower().matches('^/+(?:ping|ready|prometheus|actuator|metrics)|/(?:ping|ready|prometheus|actuator|metrics)(?:[/;.]|$)')"

  # Forum paths carry user-chosen slugs that can contain these words.
  cloud_armor_internal_path_prefixes = "request.path.urlDecode().lower().matches('^/+(?:ping|ready|prometheus|actuator|metrics)|/[.][.]?(?:/|$)|;')"

  # Per-host request limits matching the ingress-nginx annotations, counted per
  # client IP: limit-rps becomes count per 10 s, limit-rpm count per 60 s.
  cloud_armor_throttles = {
    admin = {
      "catalog-admin-service.staging.fellesdatakatalog.digdir.no" = { priority = 1400, count = 60, interval_sec = 10 }
      "catalog-history.staging.fellesdatakatalog.digdir.no"       = { priority = 1401, count = 10, interval_sec = 10 }
      "cms.staging.fellesdatakatalog.digdir.no"                   = { priority = 1402, count = 100, interval_sec = 10 }
      "catalog-admin-service.demo.fellesdatakatalog.digdir.no"    = { priority = 1410, count = 60, interval_sec = 10 }
      "catalog-history.demo.fellesdatakatalog.digdir.no"          = { priority = 1411, count = 10, interval_sec = 10 }
    }
    # The admin GUI requests the status of every datasource at once when its
    # list loads, so harvest-admin.api allows more than its annotation.
    harvesters = {
      "harvest-admin.api.staging.fellesdatakatalog.digdir.no" = { priority = 1400, count = 500, interval_sec = 10 }
      "harvest-admin.api.demo.fellesdatakatalog.digdir.no"    = { priority = 1410, count = 500, interval_sec = 10 }
    }
    registration = {
      "begrepskatalog.staging.fellesdatakatalog.digdir.no" = { priority = 1400, count = 500, interval_sec = 10 }
      "catalog.api.staging.fellesdatakatalog.digdir.no"    = { priority = 1401, count = 100, interval_sec = 10 }
      "begrepskatalog.demo.fellesdatakatalog.digdir.no"    = { priority = 1410, count = 500, interval_sec = 10 }
      "catalog.api.demo.fellesdatakatalog.digdir.no"       = { priority = 1411, count = 100, interval_sec = 10 }
    }
    search = {
      "search.api.staging.fellesdatakatalog.digdir.no" = { priority = 1400, count = 100, interval_sec = 10 }
      "search.api.demo.fellesdatakatalog.digdir.no"    = { priority = 1410, count = 100, interval_sec = 10 }
    }
    services = {
      "aisearch.api.staging.fellesdatakatalog.digdir.no"             = { priority = 1400, count = 10, interval_sec = 60 }
      "data-service-catalog.api.staging.fellesdatakatalog.digdir.no" = { priority = 1401, count = 100, interval_sec = 10 }
      "resource.api.staging.fellesdatakatalog.digdir.no"             = { priority = 1402, count = 100, interval_sec = 10 }
      "statistics.api.staging.fellesdatakatalog.digdir.no"           = { priority = 1403, count = 40, interval_sec = 10 }
      "aisearch.api.demo.fellesdatakatalog.digdir.no"                = { priority = 1410, count = 10, interval_sec = 60 }
      "data-service-catalog.api.demo.fellesdatakatalog.digdir.no"    = { priority = 1411, count = 100, interval_sec = 10 }
      "resource.api.demo.fellesdatakatalog.digdir.no"                = { priority = 1412, count = 50, interval_sec = 10 }
      "statistics.api.demo.fellesdatakatalog.digdir.no"              = { priority = 1413, count = 40, interval_sec = 10 }
    }
  }
}
