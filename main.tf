locals {
  module_name    = "transformer-event-hub-vmss"
  module_version = "0.1.0"

  app_name = "transformer-kafka"
  # TODO: Change once 5.7.0 is published
  app_version = "5.7.0-rc1-distroless"

  local_tags = {
    Name           = var.name
    app_name       = local.app_name
    app_version    = local.app_version
    module_name    = local.module_name
    module_version = local.module_version
  }

  tags = merge(
    var.tags,
    local.local_tags
  )
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

module "telemetry" {
  source  = "snowplow-devops/telemetry/snowplow"
  version = "0.5.0"

  count = var.telemetry_enabled ? 1 : 0

  user_provided_id = var.user_provided_id
  cloud            = "AZURE"
  region           = data.azurerm_resource_group.rg.location
  app_name         = local.app_name
  app_version      = local.app_version
  module_name      = local.module_name
  module_version   = local.module_version
}

# --- Network: Security Group Rules

resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = var.resource_group_name

  tags = local.tags
}

resource "azurerm_network_security_rule" "ingress_tcp_22" {
  name                        = "${var.name}_ingress_tcp_22"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.ssh_ip_allowlist
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "egress_tcp_80" {
  name                        = "${var.name}_egress_tcp_80"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "egress_tcp_443" {
  name                        = "${var.name}_egress_tcp_443"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Needed for clock synchronization
resource "azurerm_network_security_rule" "egress_udp_123" {
  name                        = "${var.name}_egress_udp_123"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "123"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# --- Authentication & Credentials

# Lookup current user
data "azuread_client_config" "current" {}

resource "azuread_application" "transformer_app_registration" {
  display_name = "${var.name}-app-registration"
  # Assign current user as owner, otherwise we won't be able to modify or delete after creation (Active directory admins can also modify)
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "transformer_app_pasword" {
  application_object_id = azuread_application.transformer_app_registration.object_id
}

resource "azuread_service_principal" "transformer_sp" {
  application_id = azuread_application.transformer_app_registration.application_id
  use_existing   = true
}

# Look up our container's resource ID
data "azurerm_storage_container" "sc" {
  name                 = var.storage_container_name
  storage_account_name = var.storage_account_name
}

resource "azurerm_role_assignment" "transformer_app_ra" {
  scope                = data.azurerm_storage_container.sc.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.transformer_sp.object_id
}

# --- VMSS Transformer Service

module "service" {
  source  = "snowplow-devops/service-vmss/azurerm"
  version = "0.1.0"

  # Config is passed via user data script - both defined in config.tf
  user_supplied_script = local.user_data
  name                 = var.name
  resource_group_name  = var.resource_group_name

  subnet_id                   = var.subnet_id
  network_security_group_id   = azurerm_network_security_group.nsg.id
  associate_public_ip_address = var.associate_public_ip_address
  admin_ssh_public_key        = var.ssh_public_key

  sku            = var.vm_sku
  instance_count = var.vm_instance_count

  tags = local.tags
}
