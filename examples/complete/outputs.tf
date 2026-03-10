# VPC outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.example.id
}

output "vswitch_ids" {
  description = "List of VSwitch IDs"
  value       = alicloud_vswitch.example[*].id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = alicloud_security_group.example.id
}

# NLB module outputs
output "nlb_id" {
  description = "The ID of the Network Load Balancer"
  value       = module.nlb.nlb_id
}

output "nlb_dns_name" {
  description = "The DNS name of the Network Load Balancer"
  value       = module.nlb.nlb_dns_name
}

output "nlb_status" {
  description = "The status of the Network Load Balancer"
  value       = module.nlb.nlb_status
}

output "server_group_id" {
  description = "The ID of the server group"
  value       = module.nlb.server_group_id
}

output "listener_ids" {
  description = "List of listener IDs"
  value       = module.nlb.listener_ids
}

output "listeners" {
  description = "Map of listener information"
  value       = module.nlb.listeners
}