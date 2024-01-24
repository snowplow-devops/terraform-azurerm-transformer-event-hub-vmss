[![Release][release-image]][release] [![CI][ci-image]][ci] [![License][license-image]][license] [![Registry][registry-image]][registry] [![Source][source-image]][source]

# terraform-azurerm-transformer-event-hub-vmss

A Terraform module which deploys the Transformer EventHub service on VMSS.

*WARNING:* Due to the ability to introduce large numbers of duplicates when scaling this application horizontally we lock the application to a single instance - if you need more throughput from this application you will need to "vertically" scale it by changing the `vm_sku` to a large node type and re-applying the module.  By default this is a `Standard_B2s` which should handle over 100 RPS without needing any scale-up.

## Telemetry

This module by default collects and forwards telemetry information to Snowplow to understand how our applications are being used.  No identifying information about your sub-account or account fingerprints are ever forwarded to us - it is very simple information about what modules and applications are deployed and active.

If you wish to subscribe to our mailing list for updates to these modules or security advisories please set the `user_provided_id` variable to include a valid email address which we can reach you at.

### How do I disable it?

To disable telemetry simply set variable `telemetry_enabled = false`.

### What are you collecting?

For details on what information is collected please see this module: https://github.com/snowplow-devops/terraform-snowplow-telemetry

## Usage

Transformer takes data from a enriched input topic and transforms this data and writes it into Cloud Storage. There are two type of transformations - Wide row JSON, and Wide row Parquet. When wide row JSON is activated, it only converts event to JSON format. When Wide row Parquet is activated, it converts the event to Parquet format.

```hcl
module "eh_namespace" {
  source  = "snowplow-devops/event-hub-namespace/azurerm"
  version = "0.1.1"

  name                = "snowplow-pipeline"
  resource_group_name = var.resource_group_name
}

module "enriched_eh_topic" {
  source  = "snowplow-devops/event-hub/azurerm"
  version = "0.1.1"

  name                = "enriched-topic"
  namespace_name      = module.eh_namespace.name
  resource_group_name = var.resource_group_name
}

module "queue_eh_topic" {
  source  = "snowplow-devops/event-hub/azurerm"
  version = "0.1.1"

  name                = "queue-topic"
  namespace_name      = module.eh_namespace.name
  resource_group_name = var.resource_group_name
}

module "storage_account" {
  source = "snowplow-devops/storage-account/azurerm"
  version = "0.1.2"

  name                = "snowplow-storage"
  resource_group_name = var.resource_group_name
}

module "storage_container" {
  source = "snowplow-devops/storage-container/azurerm"
  version = "0.1.1"

  name                 = "transformer-storage"
  storage_account_name = module.storage_account.name
}

module "transformer_service" {
  source = "snowplow-devops/transformer-event-hub-vmss/azurerm"
  
  accept_limited_use_license = true

  name                = "transformer-server"
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_for_servers

  enriched_topic_name           = module.enriched_eh_topic.name
  enriched_topic_kafka_password = module.enriched_eh_topic.read_only_primary_connection_string
  queue_topic_name              = module.queue_eh_topic.name
  queue_topic_kafka_password    = module.queue_eh_topic.read_write_primary_connection_string
  eh_namespace_name             = module.eh_namespace.name
  kafka_brokers                 = module.eh_namespace.broker

  storage_account_name   = module.storage_account.name
  storage_container_name = module.storage_container.name
  window_period_min      = 10

  ssh_public_key   = "your-public-key-here"
  ssh_ip_allowlist = ["0.0.0.0/0"]

  # Linking in the custom Iglu Server here
  custom_iglu_resolvers = [
    {
      name            = "Iglu Server"
      priority        = 0
      uri             = "http://your-iglu-server-endpoint/api"
      api_key         = var.iglu_super_api_key
      vendor_prefixes = []
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.39.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.58.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 2.39.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.58.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service"></a> [service](#module\_service) | snowplow-devops/service-vmss/azurerm | 0.1.1 |
| <a name="module_telemetry"></a> [telemetry](#module\_telemetry) | snowplow-devops/telemetry/snowplow | 0.5.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_application.transformer_app_registration](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.transformer_app_pasword](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.transformer_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_eventhub_consumer_group.enriched_topic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.egress_tcp_443](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.egress_tcp_80](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.egress_udp_123](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.ingress_tcp_22](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_role_assignment.transformer_app_ra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_container.sc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_container) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enriched_topic_kafka_password"></a> [enriched\_topic\_kafka\_password](#input\_enriched\_topic\_kafka\_password) | Password for connection to Kafka cluster under PlainLoginModule (note: as default the EventHubs topic connection string for reading is expected) | `string` | n/a | yes |
| <a name="input_enriched_topic_name"></a> [enriched\_topic\_name](#input\_enriched\_topic\_name) | The name of the enriched Event Hubs topic that transformer will pull data from | `string` | n/a | yes |
| <a name="input_kafka_brokers"></a> [kafka\_brokers](#input\_kafka\_brokers) | The brokers to configure for access to the Kafka Cluster (note: as default the EventHubs namespace broker) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A name which will be pre-pended to the resources created | `string` | n/a | yes |
| <a name="input_queue_topic_kafka_password"></a> [queue\_topic\_kafka\_password](#input\_queue\_topic\_kafka\_password) | Password for connection to Kafka cluster under PlainLoginModule (note: as default the EventHubs topic connection string for writing is expected) | `string` | n/a | yes |
| <a name="input_queue_topic_name"></a> [queue\_topic\_name](#input\_queue\_topic\_name) | The name of the queue Event Hubs topic that the transformer will push messages to for the loader | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to deploy the service into | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The SSH public key attached for access to the servers | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the output storage account | `string` | n/a | yes |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | Name of the output storage container | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet id to deploy the service into | `string` | n/a | yes |
| <a name="input_window_period_min"></a> [window\_period\_min](#input\_window\_period\_min) | Frequency to emit loading finished message - 5,10,15,20,30,60 etc minutes | `number` | n/a | yes |
| <a name="input_accept_limited_use_license"></a> [accept\_limited\_use\_license](#input\_accept\_limited\_use\_license) | Acceptance of the SLULA terms (https://docs.snowplow.io/limited-use-license-1.0/) | `bool` | `false` | no |
| <a name="input_app_version"></a> [app\_version](#input\_app\_version) | Transformer app version to use. This variable facilitates dev flow, the modules may not work with anything other than the default value. | `string` | `"5.7.1"` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to assign a public ip address to this instance | `bool` | `true` | no |
| <a name="input_custom_iglu_resolvers"></a> [custom\_iglu\_resolvers](#input\_custom\_iglu\_resolvers) | The custom Iglu Resolvers that will be used by Enrichment to resolve and validate events | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    uri             = string<br>    api_key         = string<br>    vendor_prefixes = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_default_iglu_resolvers"></a> [default\_iglu\_resolvers](#input\_default\_iglu\_resolvers) | The default Iglu Resolvers that will be used by Enrichment to resolve and validate events | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    uri             = string<br>    api_key         = string<br>    vendor_prefixes = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "api_key": "",<br>    "name": "Iglu Central",<br>    "priority": 10,<br>    "uri": "http://iglucentral.com",<br>    "vendor_prefixes": []<br>  },<br>  {<br>    "api_key": "",<br>    "name": "Iglu Central - Mirror 01",<br>    "priority": 20,<br>    "uri": "http://mirror01.iglucentral.com",<br>    "vendor_prefixes": []<br>  }<br>]</pre> | no |
| <a name="input_eh_namespace_name"></a> [eh\_namespace\_name](#input\_eh\_namespace\_name) | The name of the Event Hubs namespace (note: if you are not using EventHubs leave this blank) | `string` | `""` | no |
| <a name="input_enriched_topic_kafka_username"></a> [enriched\_topic\_kafka\_username](#input\_enriched\_topic\_kafka\_username) | Username for connection to Kafka cluster under PlainLoginModule (default: '$ConnectionString' which is used for EventHubs) | `string` | `"$ConnectionString"` | no |
| <a name="input_java_opts"></a> [java\_opts](#input\_java\_opts) | Custom JAVA Options | `string` | `"-XX:InitialRAMPercentage=75 -XX:MaxRAMPercentage=75"` | no |
| <a name="input_kafka_source"></a> [kafka\_source](#input\_kafka\_source) | The source providing the Kafka connectivity (def: azure\_event\_hubs) | `string` | `"azure_event_hubs"` | no |
| <a name="input_queue_topic_kafka_username"></a> [queue\_topic\_kafka\_username](#input\_queue\_topic\_kafka\_username) | Username for connection to Kafka cluster under PlainLoginModule (default: '$ConnectionString' which is used for EventHubs) | `string` | `"$ConnectionString"` | no |
| <a name="input_ssh_ip_allowlist"></a> [ssh\_ip\_allowlist](#input\_ssh\_ip\_allowlist) | The comma-seperated list of CIDR ranges to allow SSH traffic from | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to append to this resource | `map(string)` | `{}` | no |
| <a name="input_telemetry_enabled"></a> [telemetry\_enabled](#input\_telemetry\_enabled) | Whether or not to send telemetry information back to Snowplow Analytics Ltd | `bool` | `true` | no |
| <a name="input_transformer_compression"></a> [transformer\_compression](#input\_transformer\_compression) | Transformer output compression, GZIP or NONE | `string` | `"GZIP"` | no |
| <a name="input_user_provided_id"></a> [user\_provided\_id](#input\_user\_provided\_id) | An optional unique identifier to identify the telemetry events emitted by this stack | `string` | `""` | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | The instance type to use | `string` | `"Standard_B2s"` | no |
| <a name="input_widerow_file_format"></a> [widerow\_file\_format](#input\_widerow\_file\_format) | The output file\_format from the widerow transformation\_type selected (json or parquet) | `string` | `"json"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id) | ID of the network security group attached to the Transformer Server nodes |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | ID of the VM scale-set |

# Copyright and license

Copyright 2023-present Snowplow Analytics Ltd.

Licensed under the [Snowplow Limited Use License Agreement][license]. _(If you are uncertain how it applies to your use case, check our answers to [frequently asked questions][license-faq].)_

[release]: https://github.com/snowplow-devops/terraform-azurerm-transformer-event-hub-vmss/releases/latest
[release-image]: https://img.shields.io/github/v/release/snowplow-devops/terraform-azurerm-transformer-event-hub-vmss

[ci]: https://github.com/snowplow-devops/terraform-azurerm-transformer-event-hub-vmss/actions?query=workflow%3Aci
[ci-image]: https://github.com/snowplow-devops/terraform-azurerm-transformer-event-hub-vmss/workflows/ci/badge.svg

[license]: https://docs.snowplow.io/limited-use-license-1.0/
[license-image]: https://img.shields.io/badge/license-Snowplow--Limited--Use-blue.svg?style=flat
[license-faq]: https://docs.snowplow.io/docs/contributing/limited-use-license-faq/

[registry]: https://registry.terraform.io/modules/snowplow-devops/transformer-event-hub-vmss/azurerm/latest
[registry-image]: https://img.shields.io/static/v1?label=Terraform&message=Registry&color=7B42BC&logo=terraform

[source]: https://github.com/snowplow/snowplow-rdb-loader
[source-image]: https://img.shields.io/static/v1?label=Snowplow&message=Transformer%20Kafka&color=0E9BA4&logo=GitHub
