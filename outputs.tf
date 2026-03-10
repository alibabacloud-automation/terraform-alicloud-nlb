# Network Load Balancer outputs
output "nlb_id" {
  description = "The ID of the Network Load Balancer"
  value       = local.this_nlb_id
}

output "nlb_dns_name" {
  description = "The DNS name of the Network Load Balancer"
  value       = var.create_nlb ? (length(alicloud_nlb_load_balancer.nlb) > 0 ? alicloud_nlb_load_balancer.nlb[0].dns_name : null) : null
}

output "nlb_status" {
  description = "The status of the Network Load Balancer"
  value       = var.create_nlb ? (length(alicloud_nlb_load_balancer.nlb) > 0 ? alicloud_nlb_load_balancer.nlb[0].status : null) : null
}

output "nlb_create_time" {
  description = "The creation time of the Network Load Balancer"
  value       = var.create_nlb ? (length(alicloud_nlb_load_balancer.nlb) > 0 ? alicloud_nlb_load_balancer.nlb[0].create_time : null) : null
}

output "nlb_region_id" {
  description = "The region ID where the Network Load Balancer is deployed"
  value       = var.create_nlb ? (length(alicloud_nlb_load_balancer.nlb) > 0 ? alicloud_nlb_load_balancer.nlb[0].region_id : null) : null
}

output "nlb_load_balancer_business_status" {
  description = "The business status of the Network Load Balancer"
  value       = var.create_nlb ? (length(alicloud_nlb_load_balancer.nlb) > 0 ? alicloud_nlb_load_balancer.nlb[0].load_balancer_business_status : null) : null
}

output "nlb_zone_mappings" {
  description = "The zone mappings of the Network Load Balancer"
  value       = var.create_nlb ? (length(alicloud_nlb_load_balancer.nlb) > 0 ? alicloud_nlb_load_balancer.nlb[0].zone_mappings : null) : null
}

# Server Group outputs
output "server_group_id" {
  description = "The ID of the server group"
  value       = local.this_server_group_id
}

output "server_group_status" {
  description = "The status of the server group"
  value       = var.create_server_group ? (length(alicloud_nlb_server_group.server_group) > 0 ? alicloud_nlb_server_group.server_group[0].status : null) : null
}

output "server_group_region_id" {
  description = "The region ID where the server group is deployed"
  value       = var.create_server_group ? (length(alicloud_nlb_server_group.server_group) > 0 ? alicloud_nlb_server_group.server_group[0].region_id : null) : null
}

# Listeners outputs
output "listeners" {
  description = "Map of listener information including IDs and regions"
  value = {
    for k, v in alicloud_nlb_listener.listeners : k => {
      id        = v.id
      region_id = v.region_id
    }
  }
}

output "listener_ids" {
  description = "List of listener IDs"
  value       = values(alicloud_nlb_listener.listeners)[*].id
}

# Security Policies outputs
output "security_policies" {
  description = "Map of security policy information including IDs and status"
  value = {
    for k, v in alicloud_nlb_security_policy.security_policies : k => {
      id     = v.id
      status = v.status
    }
  }
}

output "security_policy_ids" {
  description = "List of security policy IDs"
  value       = values(alicloud_nlb_security_policy.security_policies)[*].id
}

# Server Attachments outputs
output "server_attachments" {
  description = "Map of server attachment information including IDs, status, and zone IDs"
  value = {
    for k, v in alicloud_nlb_server_group_server_attachment.server_attachments : k => {
      id      = v.id
      status  = v.status
      zone_id = v.zone_id
    }
  }
}

output "server_attachment_ids" {
  description = "List of server attachment IDs"
  value       = values(alicloud_nlb_server_group_server_attachment.server_attachments)[*].id
}

# Security Group Attachments outputs
output "security_group_attachments" {
  description = "Map of security group attachment IDs"
  value = {
    for k, v in alicloud_nlb_load_balancer_security_group_attachment.security_group_attachments : k => {
      id = v.id
    }
  }
}

output "security_group_attachment_ids" {
  description = "List of security group attachment IDs"
  value       = values(alicloud_nlb_load_balancer_security_group_attachment.security_group_attachments)[*].id
}