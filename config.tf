locals {
  resolvers_raw = concat(var.default_iglu_resolvers, var.custom_iglu_resolvers)

  resolvers_open = [
    for resolver in local.resolvers_raw : merge(
      {
        name           = resolver["name"],
        priority       = resolver["priority"],
        vendorPrefixes = resolver["vendor_prefixes"],
        connection = {
          http = {
            uri = resolver["uri"]
          }
        }
      }
    ) if resolver["api_key"] == ""
  ]

  resolvers_closed = [
    for resolver in local.resolvers_raw : merge(
      {
        name           = resolver["name"],
        priority       = resolver["priority"],
        vendorPrefixes = resolver["vendor_prefixes"],
        connection = {
          http = {
            uri    = resolver["uri"]
            apikey = resolver["api_key"]
          }
        }
      }
    ) if resolver["api_key"] != ""
  ]

  resolvers = flatten([
    local.resolvers_open,
    local.resolvers_closed
  ])

  iglu_config = templatefile("${path.module}/templates/iglu_config.json.tmpl", { resolvers = jsonencode(local.resolvers) })

  # transformer_config = templatefile("${path.module}/templates/config.hocon.tmpl", {
  transformer_config = templatefile("${path.module}/templates/config.hocon.tmpl", {

    event_hub_broker_string = var.event_hub_broker_string

    enriched_event_hub_name              = var.enriched_event_hub_name
    enriched_event_hub_connection_string = var.enriched_event_hub_connection_string

    storage_account_name   = var.storage_account_name
    storage_container_name = var.storage_container_name
    ouput_compression      = var.ouput_compression
    output_file_format     = var.output_file_format

    queue_event_hub_name              = var.queue_event_hub_name
    queue_event_hub_connection_string = var.queue_event_hub_connection_string

    windowing = var.windowing

    telemetry_disable          = !var.telemetry_enabled
    telemetry_collector_uri    = join("", module.telemetry.*.collector_uri)
    telemetry_collector_port   = 443
    telemetry_secure           = true
    telemetry_user_provided_id = var.user_provided_id
    telemetry_auto_gen_id      = join("", module.telemetry.*.auto_generated_id)
    telemetry_module_name      = local.module_name
    telemetry_module_version   = local.module_version
  })

  user_data = templatefile("${path.module}/templates/user-data.sh.tmpl", {
    tenant_id     = azuread_service_principal.transformer_sp.application_tenant_id
    client_id     = azuread_application.transformer_app_registration.application_id
    client_secret = azuread_application_password.transformer_app_pasword.value

    transformer_config_b64 = base64encode(local.transformer_config)
    iglu_config_b64        = base64encode(local.iglu_config)



    telemetry_script = join("", module.telemetry.*.azurerm_ubuntu_22_04_user_data)

    java_opts = var.java_opts
  })


}
