
# Network Load Balancer instance
resource "alicloud_nlb_load_balancer" "nlb" {
  count = var.create_nlb ? 1 : 0

  load_balancer_name = var.load_balancer_config.load_balancer_name
  load_balancer_type = var.load_balancer_config.load_balancer_type
  address_type       = var.load_balancer_config.address_type
  address_ip_version = var.load_balancer_config.address_ip_version
  vpc_id             = var.load_balancer_config.vpc_id

  # Optional configurations
  resource_group_id    = var.load_balancer_config.resource_group_id
  bandwidth_package_id = var.load_balancer_config.bandwidth_package_id
  cross_zone_enabled   = var.load_balancer_config.cross_zone_enabled
  ipv6_address_type    = var.load_balancer_config.ipv6_address_type
  cps                  = var.load_balancer_config.cps
  security_group_ids   = var.load_balancer_config.security_group_ids

  # Deletion protection
  deletion_protection_enabled = var.load_balancer_config.deletion_protection_enabled
  deletion_protection_reason  = var.load_balancer_config.deletion_protection_reason

  # Modification protection
  modification_protection_status = var.load_balancer_config.modification_protection_status
  modification_protection_reason = var.load_balancer_config.modification_protection_reason

  # Zone mappings
  dynamic "zone_mappings" {
    for_each = length(var.zone_mappings) > 0 ? var.zone_mappings : []
    content {
      zone_id              = zone_mappings.value.zone_id
      vswitch_id           = zone_mappings.value.vswitch_id
      allocation_id        = lookup(zone_mappings.value, "allocation_id", null)
      private_ipv4_address = lookup(zone_mappings.value, "private_ipv4_address", null)
      ipv6_address         = lookup(zone_mappings.value, "ipv6_address", null)
    }
  }

  tags = var.load_balancer_config.tags
}

# Server Group for NLB
resource "alicloud_nlb_server_group" "server_group" {
  count = var.create_server_group ? 1 : 0

  server_group_name  = var.server_group_config.server_group_name
  server_group_type  = var.server_group_config.server_group_type
  vpc_id             = var.server_group_config.vpc_id
  scheduler          = var.server_group_config.scheduler
  protocol           = var.server_group_config.protocol
  address_ip_version = var.server_group_config.address_ip_version
  resource_group_id  = var.server_group_config.resource_group_id

  # Connection drain configuration
  connection_drain_enabled = var.server_group_config.connection_drain_enabled
  connection_drain_timeout = var.server_group_config.connection_drain_timeout

  # Preserve client IP
  preserve_client_ip_enabled = var.server_group_config.preserve_client_ip_enabled

  # Any port forwarding
  any_port_enabled = var.server_group_config.any_port_enabled

  # Health check configuration
  dynamic "health_check" {
    for_each = var.server_group_config.health_check_enabled ? [1] : []
    content {
      health_check_enabled         = var.server_group_config.health_check_enabled
      health_check_type            = var.server_group_config.health_check_type
      health_check_connect_port    = var.server_group_config.health_check_connect_port
      healthy_threshold            = var.server_group_config.healthy_threshold
      unhealthy_threshold          = var.server_group_config.unhealthy_threshold
      health_check_connect_timeout = var.server_group_config.health_check_connect_timeout
      health_check_interval        = var.server_group_config.health_check_interval
      health_check_domain          = var.server_group_config.health_check_domain
      health_check_url             = var.server_group_config.health_check_url
      health_check_http_code       = var.server_group_config.health_check_http_code
      http_check_method            = var.server_group_config.http_check_method
    }
  }

  tags = var.server_group_config.tags
}

# NLB Listeners
resource "alicloud_nlb_listener" "listeners" {
  for_each = var.listeners_config

  load_balancer_id     = local.this_nlb_id
  server_group_id      = local.this_server_group_id
  listener_protocol    = each.value.listener_protocol
  listener_port        = each.value.listener_port
  listener_description = each.value.listener_description

  # Optional configurations
  start_port = each.value.start_port
  end_port   = each.value.end_port

  # TCP/UDP configurations
  idle_timeout           = each.value.idle_timeout
  proxy_protocol_enabled = each.value.proxy_protocol_enabled
  cps                    = each.value.cps
  mss                    = each.value.mss

  # TCPSSL configurations
  alpn_enabled       = each.value.alpn_enabled
  alpn_policy        = each.value.alpn_policy
  ca_enabled         = each.value.ca_enabled
  ca_certificate_ids = each.value.ca_certificate_ids
  certificate_ids    = each.value.certificate_ids
  security_policy_id = each.value.security_policy_id

  # Monitoring
  sec_sensor_enabled = each.value.sec_sensor_enabled

  tags = each.value.tags
}

# Security Policy for TCPSSL listeners
resource "alicloud_nlb_security_policy" "security_policies" {
  for_each = var.security_policies_config

  security_policy_name = each.value.security_policy_name
  resource_group_id    = each.value.resource_group_id
  ciphers              = each.value.ciphers
  tls_versions         = each.value.tls_versions

  tags = each.value.tags
}

# Server Group Server Attachments
resource "alicloud_nlb_server_group_server_attachment" "server_attachments" {
  for_each = var.server_attachments_config

  server_group_id = local.this_server_group_id
  server_type     = each.value.server_type
  server_id       = each.value.server_id
  server_ip       = each.value.server_ip
  port            = each.value.port
  weight          = each.value.weight
  description     = each.value.description
}

# Load Balancer Security Group Attachments
resource "alicloud_nlb_load_balancer_security_group_attachment" "security_group_attachments" {
  for_each = var.security_group_attachments_config

  load_balancer_id  = local.this_nlb_id
  security_group_id = each.value.security_group_id
}

# Local values for resource IDs
locals {
  # NLB ID - use created resource if create_nlb is true, otherwise use provided ID
  this_nlb_id = var.create_nlb ? (length(alicloud_nlb_load_balancer.nlb) > 0 ? alicloud_nlb_load_balancer.nlb[0].id : null) : var.nlb_id

  # Server Group ID - use created resource if create_server_group is true, otherwise use provided ID
  this_server_group_id = var.create_server_group ? (length(alicloud_nlb_server_group.server_group) > 0 ? alicloud_nlb_server_group.server_group[0].id : null) : var.server_group_id
}