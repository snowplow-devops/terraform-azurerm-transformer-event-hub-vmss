[![Release][release-image]][release] [![CI][ci-image]][ci] [![License][license-image]][license] [![Registry][registry-image]][registry] [![Source][source-image]][source]

# terraform-azurerm-transformer-event-hub-vmss

A Terraform module which deploys Snowplow Enrich service on VMSS.

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
module "transformer_service" {
  source = "snowplow-devops/transformer-event-hub-vmss/azurerm"

  name                                 = local.name
  resource_group_name                  = local.resource_group_name
  subnet_id                            = local.subnet_id
  ssh_public_key                       = local.ssh_public_key
  event_hub_broker_string              = "${local.eh_namespace_name}.servicebus.windows.net:9093"
  enriched_event_hub_name              = local.enriched_event_hub_name
  enriched_event_hub_connection_string = local.enriched_event_hub_connection_string
  queue_event_hub_name                 = local.queue_event_hub.name
  queue_event_hub_connection_string    = local.queue_event_hub_connection_string
  storage_account_name                 = local.storage_account_name
  storage_container_name               = local.storage_container_name
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.39.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.58.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.39.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.61.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service"></a> [service](#module\_service) | snowplow-devops/service-vmss/azurerm | 0.1.0 |
| <a name="module_telemetry"></a> [telemetry](#module\_telemetry) | snowplow-devops/telemetry/snowplow | 0.5.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_application.transformer_app_registration](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.transformer_app_pasword](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.transformer_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
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
| <a name="input_enriched_event_hub_connection_string"></a> [enriched\_event\_hub\_connection\_string](#input\_enriched\_event\_hub\_connection\_string) | Connection string for the enriched event hub. Must permit read access at minimum | `string` | n/a | yes |
| <a name="input_enriched_event_hub_name"></a> [enriched\_event\_hub\_name](#input\_enriched\_event\_hub\_name) | Name of the enriched event hub stream | `string` | n/a | yes |
| <a name="input_event_hub_broker_string"></a> [event\_hub\_broker\_string](#input\_event\_hub\_broker\_string) | Broker string for the enriched event hub's kafka protocol. Typically this value is {event\_hub\_namespave\_name}.servicebus.windows.net:9093 | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A name which will be pre-pended to the resources created | `string` | n/a | yes |
| <a name="input_queue_event_hub_connection_string"></a> [queue\_event\_hub\_connection\_string](#input\_queue\_event\_hub\_connection\_string) | Connection string for the queue event hub. Must permit write access at minimum | `string` | n/a | yes |
| <a name="input_queue_event_hub_name"></a> [queue\_event\_hub\_name](#input\_queue\_event\_hub\_name) | Name of the queue event hub stream | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to deploy the service into | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The SSH public key attached for access to the servers | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the output storage account | `string` | n/a | yes |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | Name of the output storage container | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet id to deploy the service into | `string` | n/a | yes |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to assign a public ip address to this instance | `bool` | `true` | no |
| <a name="input_custom_iglu_resolvers"></a> [custom\_iglu\_resolvers](#input\_custom\_iglu\_resolvers) | The custom Iglu Resolvers that will be used by Enrichment to resolve and validate events | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    uri             = string<br>    api_key         = string<br>    vendor_prefixes = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_default_iglu_resolvers"></a> [default\_iglu\_resolvers](#input\_default\_iglu\_resolvers) | The default Iglu Resolvers that will be used by Enrichment to resolve and validate events | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    uri             = string<br>    api_key         = string<br>    vendor_prefixes = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "api_key": "",<br>    "name": "Iglu Central",<br>    "priority": 10,<br>    "uri": "http://iglucentral.com",<br>    "vendor_prefixes": []<br>  },<br>  {<br>    "api_key": "",<br>    "name": "Iglu Central - Mirror 01",<br>    "priority": 20,<br>    "uri": "http://mirror01.iglucentral.com",<br>    "vendor_prefixes": []<br>  }<br>]</pre> | no |
| <a name="input_java_opts"></a> [java\_opts](#input\_java\_opts) | Custom JAVA Options | `string` | `"-Dorg.slf4j.simpleLogger.defaultLogLevel=info -XX:MinRAMPercentage=50 -XX:MaxRAMPercentage=75"` | no |
| <a name="input_ssh_ip_allowlist"></a> [ssh\_ip\_allowlist](#input\_ssh\_ip\_allowlist) | The comma-seperated list of CIDR ranges to allow SSH traffic from | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to append to this resource | `map(string)` | `{}` | no |
| <a name="input_telemetry_enabled"></a> [telemetry\_enabled](#input\_telemetry\_enabled) | Whether or not to send telemetry information back to Snowplow Analytics Ltd | `bool` | `true` | no |
| <a name="input_user_provided_id"></a> [user\_provided\_id](#input\_user\_provided\_id) | An optional unique identifier to identify the telemetry events emitted by this stack | `string` | `""` | no |
| <a name="input_vm_instance_count"></a> [vm\_instance\_count](#input\_vm\_instance\_count) | The instance count to use | `number` | `1` | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | The instance type to use | `string` | `"Standard_B2s"` | no |
| <a name="input_windowing"></a> [windowing](#input\_windowing) | Windowing period for the application. Configures how often we attempt to write to storage | `string` | `"10 minutes"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id) | ID of the network security group attached to the Transformer Server nodes |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | ID of the VM scale-set |

# Copyright and license

The Terraform Azurerm Transformer Event Hub VMSS project is Copyright 2023-present Snowplow Analytics Ltd.

Licensed under the [Apache License, Version 2.0][license] (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[release]: https://github.com/snowplow-devops/terraform-azurerm-transformer-event-hub-vmss/releases/latest
[release-image]: https://img.shields.io/github/v/release/snowplow-devops/terraform-azurerm-transformer-event-hub-vmss

[ci]: https://github.com/snowplow-devops/terraform-azurerm-transformer-event-hub-vmss/actions?query=workflow%3Aci
[ci-image]: https://github.com/snowplow-devops/terraform-azurerm-transformer-event-hub-vmss/workflows/ci/badge.svg

[license]: https://www.apache.org/licenses/LICENSE-2.0
[license-image]: https://img.shields.io/badge/license-Apache--2-blue.svg?style=flat

[registry]: https://registry.terraform.io/modules/snowplow-devops/transformer-event-hub-vmss/azurerm/latest
[registry-image]: https://img.shields.io/static/v1?label=Terraform&message=Registry&color=7B42BC&logo=terraform
