locals {
  name                 = "transformer-test"
  storage_account_name = "transformertestsa"

  # Windowing is set to 1 minute here purely for a fast test feedback loop
  window_period_min = 1
  ssh_public_key    = "PUBLIC_KEY"
  user_provided_id  = "transformer-module-example@snowplow.io"

  # This is your cluster "Bootstrap Server"
  kafka_brokers = "<SET_ME>"
  # This is your cluster API Key (Key + Secret)
  kafka_username = "<SET_ME>"
  kafka_password = "<SET_ME>"

  # Default names for topics (note: change if you used different denominations)
  enriched_topic_name = "enriched"
  queue_topic_name    = "queue"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = "North Europe"
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

  name                = local.name
  resource_group_name = azurerm_resource_group.rg.name

  subnet_id = lookup(module.vnet.vnet_subnets_name_id, "pipeline1")

  enriched_topic_name           = local.enriched_topic_name
  enriched_topic_kafka_username = local.kafka_username
  enriched_topic_kafka_password = local.kafka_password
  queue_topic_name              = local.queue_topic_name
  queue_topic_kafka_username    = local.kafka_username
  queue_topic_kafka_password    = local.kafka_password
  kafka_brokers                 = local.kafka_brokers

  kafka_source = "confluent_cloud"

  storage_account_name   = module.storage_account.name
  storage_container_name = module.storage_container.name
  window_period_min      = local.window_period_min

  widerow_file_format = "json"

  ssh_public_key = local.ssh_public_key

  user_provided_id = local.user_provided_id

  depends_on = [azurerm_resource_group.rg, module.storage_container, module.storage_account]
}
