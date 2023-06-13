locals {
  name                    = "transformer-test"
  resource_group_name     = "transformer-test-rg"
  namespace_name          = "transformer-test-eh-namespace"
  enriched_event_hub_name = "transformer-test-eh-enriched"
  queue_event_hub_name    = "transformer-test-queue"
  storage_account_name    = "transformertestsa"
  storage_conatiner_name  = "transformer-test-container"
  # Windowing is set to 1 minute here puurely for a fast test feedback loop
  windowing      = "1 minute"
  ssh_public_key = "PUBLIC_KEY"
}

## Resource dependencies:

resource "azurerm_resource_group" "group" {
  name     = local.resource_group_name
  location = "North Europe"
}

module "eh_namespace" {
  source = "snowplow-devops/event-hub-namespace/azurerm"

  name                = local.namespace_name
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

  name                 = local.storage_conatiner_name
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

## Transformer service:

module "transformer_service" {
  source = "../.."

  name                                 = local.name
  resource_group_name                  = local.resource_group_name
  subnet_id                            = tolist(azurerm_virtual_network.vnet.subnet)[0].id
  ssh_public_key                       = local.ssh_public_key
  event_hub_broker_string              = "${module.eh_namespace.name}.servicebus.windows.net:9093"
  enriched_event_hub_name              = local.enriched_event_hub_name
  enriched_event_hub_connection_string = module.enriched_event_hub.read_write_primary_connection_string
  queue_event_hub_name                 = module.queue_event_hub.name
  queue_event_hub_connection_string    = module.queue_event_hub.read_write_primary_connection_string
  storage_account_name                 = module.storage_account.name
  storage_container_name               = module.storage_container.name
  windowing                            = local.windowing

  depends_on = [azurerm_resource_group.group, module.storage_container, module.storage_account]
}
