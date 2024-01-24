locals {
  name                 = "transformer-test"
  storage_account_name = "transformertestsa"

  # Windowing is set to 1 minute here purely for a fast test feedback loop
  window_period_min = 1
  ssh_public_key    = "PUBLIC_KEY"
  user_provided_id  = "transformer-module-example@snowplow.io"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = "North Europe"
}

module "eh_namespace" {
  source  = "snowplow-devops/event-hub-namespace/azurerm"
  version = "0.1.1"

  name                = "${local.name}-ehn"
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}

module "enriched_event_hub" {
  source  = "snowplow-devops/event-hub/azurerm"
  version = "0.1.1"

  name                = "${local.name}-enriched-topic"
  namespace_name      = module.eh_namespace.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 1
}

module "queue_event_hub" {
  source  = "snowplow-devops/event-hub/azurerm"
  version = "0.1.1"

  name                = "${local.name}-queue-topic"
  namespace_name      = module.eh_namespace.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 1
}

module "storage_account" {
  source  = "snowplow-devops/storage-account/azurerm"
  version = "0.1.2"

  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}

module "storage_container" {
  source  = "snowplow-devops/storage-container/azurerm"
  version = "0.1.1"

  name                 = "${local.name}-container"
  storage_account_name = module.storage_account.name
}

module "vnet" {
  source  = "snowplow-devops/vnet/azurerm"
  version = "0.1.2"

  name                = "${local.name}-vnet"
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}

module "transformer_service" {
  source = "../.."

  accept_limited_use_license = true

  name                = local.name
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = lookup(module.vnet.vnet_subnets_name_id, "pipeline1")

  enriched_topic_name           = module.enriched_event_hub.name
  enriched_topic_kafka_password = module.enriched_event_hub.read_only_primary_connection_string
  queue_topic_name              = module.queue_event_hub.name
  queue_topic_kafka_password    = module.queue_event_hub.read_write_primary_connection_string
  eh_namespace_name             = module.eh_namespace.name
  kafka_brokers                 = module.eh_namespace.broker

  storage_account_name   = module.storage_account.name
  storage_container_name = module.storage_container.name
  window_period_min      = local.window_period_min

  widerow_file_format = "json"

  ssh_public_key = local.ssh_public_key

  user_provided_id = local.user_provided_id

  depends_on = [azurerm_resource_group.rg, module.storage_container, module.storage_account]
}
