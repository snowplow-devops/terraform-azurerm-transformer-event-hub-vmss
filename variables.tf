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

variable "vm_instance_count" {
  description = "The instance count to use"
  type        = number
  default     = 1
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
  default     = "-Dorg.slf4j.simpleLogger.defaultLogLevel=info -XX:MinRAMPercentage=50 -XX:MaxRAMPercentage=75"
  type        = string
}

# --- Configuration options

variable "event_hub_broker_string" {
  description = "Broker string for the enriched event hub's kafka protocol. Typically this value is {event_hub_namespave_name}.servicebus.windows.net:9093"
  type        = string
}

variable "enriched_event_hub_name" {
  description = "Name of the enriched event hub stream"
  type        = string
}

variable "enriched_event_hub_connection_string" {
  description = "Connection string for the enriched event hub. Must permit read access at minimum"
  type        = string
}

variable "queue_event_hub_name" {
  description = "Name of the queue event hub stream"
  type        = string
}

variable "queue_event_hub_connection_string" {
  description = "Connection string for the queue event hub. Must permit write access at minimum"
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

variable "windowing" {
  description = "Windowing period for the application. Configures how often we attempt to write to storage"
  default     = "10 minutes"
  type        = string

  validation {
    condition     = can(regex("\\d+ (ns|nano|nanos|nanosecond|nanoseconds|us|micro|micros|microsecond|microseconds|ms|milli|millis|millisecond|milliseconds|s|second|seconds|m|minute|minutes|h|hour|hours|d|day|days)", var.windowing))
    error_message = "Invalid period formant."
  }
}

variable "ouput_compression" {
  description = "File compression for writing to Storage"
  default     = "GZIP"
  type        = string
}

variable "output_file_format" {
  description = "Output file format - acceptable values are 'json' or 'parquet'"
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
