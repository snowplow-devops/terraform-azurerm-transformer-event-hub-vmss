output "vmss_id" {
  value       = module.transformer_service.vmss_id
  description = "ID of the VM scale-set"
}

output "nsg_id" {
  value       = module.transformer_service.nsg_id
  description = "ID of the network security group attached to the Transformer Server nodes"
}
