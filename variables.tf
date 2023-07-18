variable "name" {
  description = "A name which will be pre-pended to the resources created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the service into"
  type        = string
}

variable "subnet_id" {
  description = "The subnet id to deploy the service into"
  type        = string
}

variable "vm_sku" {
  description = "The instance type to use"
  type        = string
  default     = "Standard_B2s"
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public ip address to this instance"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "The SSH public key attached for access to the servers"
  type        = string
}

variable "ssh_ip_allowlist" {
  description = "The comma-seperated list of CIDR ranges to allow SSH traffic from"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "The tags to append to this resource"
  default     = {}
  type        = map(string)
}

variable "java_opts" {
  description = "Custom JAVA Options"
  default     = "-XX:InitialRAMPercentage=75 -XX:MaxRAMPercentage=75"
  type        = string
}

# --- Configuration options

variable "enriched_topic_name" {
  description = "The name of the enriched Event Hubs topic that transformer will pull data from"
  type        = string
}

variable "enriched_topic_connection_string" {
  description = "The connection string to use for reading from the enriched topic"
  type        = string
}

variable "queue_topic_name" {
  description = "The name of the queue Event Hubs topic that the transformer will push messages to for the loader"
  type        = string
}

variable "queue_topic_connection_string" {
  description = "The connection string to use for writing to the queue topic"
  type        = string
}

variable "eh_namespace_name" {
  description = "The name of the Event Hubs namespace"
  type        = string
}

variable "eh_namespace_broker" {
  description = "The broker to configure for access to the Event Hubs namespace"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the output storage account"
  type        = string
}

variable "storage_container_name" {
  description = "Name of the output storage container"
  type        = string
}

variable "transformer_compression" {
  description = "Transformer output compression, GZIP or NONE"
  default     = "GZIP"
  type        = string
}

variable "window_period_min" {
  description = "Frequency to emit loading finished message - 5,10,15,20,30,60 etc minutes"
  type        = number
}

variable "widerow_file_format" {
  description = "The output file_format from the widerow transformation_type selected (json or parquet)"
  default     = "json"
  type        = string
}

# --- Iglu Resolver

variable "default_iglu_resolvers" {
  description = "The default Iglu Resolvers that will be used by Enrichment to resolve and validate events"
  default = [
    {
      name            = "Iglu Central"
      priority        = 10
      uri             = "http://iglucentral.com"
      api_key         = ""
      vendor_prefixes = []
    },
    {
      name            = "Iglu Central - Mirror 01"
      priority        = 20
      uri             = "http://mirror01.iglucentral.com"
      api_key         = ""
      vendor_prefixes = []
    }
  ]
  type = list(object({
    name            = string
    priority        = number
    uri             = string
    api_key         = string
    vendor_prefixes = list(string)
  }))
}

variable "custom_iglu_resolvers" {
  description = "The custom Iglu Resolvers that will be used by Enrichment to resolve and validate events"
  default     = []
  type = list(object({
    name            = string
    priority        = number
    uri             = string
    api_key         = string
    vendor_prefixes = list(string)
  }))
}

# --- Telemetry

variable "telemetry_enabled" {
  description = "Whether or not to send telemetry information back to Snowplow Analytics Ltd"
  type        = bool
  default     = true
}

variable "user_provided_id" {
  description = "An optional unique identifier to identify the telemetry events emitted by this stack"
  type        = string
  default     = ""
}
