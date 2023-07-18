locals {
  name                = "transformer-test"
  resource_group_name = "transformer-test-rg"

  eh_namespace_name       = "transformer-test-eh-namespace"
  enriched_event_hub_name = "transformer-test-eh-enriched"
  queue_event_hub_name    = "transformer-test-queue"

  storage_account_name   = "transformertestsa"
  storage_container_name = "transformer-test-container"

  # Windowing is set to 1 minute here purely for a fast test feedback loop
  window_period_min = 1
  ssh_public_key    = "PUBLIC_KEY"
  user_provided_id = "transformer-module-example@snowplow.io"
}

resource "azurerm_resource_group" "group" {
  name     = local.resource_group_name
  location = "North Europe"
}

module "eh_namespace" {
  source = "snowplow-devops/event-hub-namespace/azurerm"

  name                = local.eh_namespace_name
  resource_group_name = local.resource_group_name

  depends_on = [azurerm_resource_group.group]
}

module "enriched_event_hub" {
  source = "snowplow-devops/event-hub/azurerm"

  name                = local.enriched_event_hub_name
  namespace_name      = module.eh_namespace.name
  resource_group_name = local.resource_group_name
  partition_count     = 1
}

module "queue_event_hub" {
  source = "snowplow-devops/event-hub/azurerm"

  name                = local.queue_event_hub_name
  namespace_name      = module.eh_namespace.name
  resource_group_name = local.resource_group_name
  partition_count     = 1
}

module "storage_account" {
  source = "snowplow-devops/storage-account/azurerm"

  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.group.name

  depends_on = [azurerm_resource_group.group]
}

module "storage_container" {
  source = "snowplow-devops/storage-container/azurerm"

  name                 = local.storage_container_name
  storage_account_name = module.storage_account.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }
}

module "transformer_service" {
  source = "../.."

  name                = local.name
  resource_group_name = local.resource_group_name
  subnet_id           = tolist(azurerm_virtual_network.vnet.subnet)[0].id

  enriched_topic_name              = module.enriched_event_hub.name
  enriched_topic_connection_string = module.enriched_event_hub.read_only_primary_connection_string
  queue_topic_name                 = module.queue_event_hub.name
  queue_topic_connection_string    = module.queue_event_hub.read_write_primary_connection_string
  eh_namespace_name                = module.eh_namespace.name
  eh_namespace_broker              = module.eh_namespace.broker

  storage_account_name   = module.storage_account.name
  storage_container_name = module.storage_container.name
  window_period_min      = local.window_period_min

  widerow_file_format = "json"

  ssh_public_key = local.ssh_public_key

  user_provided_id = local.user_provided_id

  depends_on = [azurerm_resource_group.group, module.storage_container, module.storage_account]
}
