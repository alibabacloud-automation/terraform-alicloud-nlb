# Control variables for resource creation
variable "create_nlb" {
  description = "Whether to create a new Network Load Balancer. If false, an existing NLB ID must be provided."
  type        = bool
  default     = true
}

variable "create_server_group" {
  description = "Whether to create a new server group. If false, an existing server group ID must be provided."
  type        = bool
  default     = true
}

# External resource IDs (when create_* is false)
variable "nlb_id" {
  description = "The ID of an existing Network Load Balancer. Required when create_nlb is false."
  type        = string
  default     = null
}

variable "server_group_id" {
  description = "The ID of an existing server group. Required when create_server_group is false."
  type        = string
  default     = null
}

# Load Balancer configuration
variable "load_balancer_config" {
  description = "Configuration for the Network Load Balancer. The attributes 'load_balancer_name', 'load_balancer_type', 'address_type', 'address_ip_version', and 'vpc_id' are required."
  type = object({
    load_balancer_name = string
    load_balancer_type = string
    address_type       = string
    address_ip_version = string
    vpc_id             = string

    # Optional configurations
    resource_group_id    = optional(string, null)
    bandwidth_package_id = optional(string, null)
    cross_zone_enabled   = optional(bool, null)
    ipv6_address_type    = optional(string, null)
    cps                  = optional(number, null)
    security_group_ids   = optional(set(string), null)

    # Protection configurations
    deletion_protection_enabled    = optional(bool, false)
    deletion_protection_reason     = optional(string, null)
    modification_protection_status = optional(string, "NonProtection")
    modification_protection_reason = optional(string, null)

    # Tags
    tags = optional(map(string), {})
  })
  default = {
    load_balancer_name = null
    load_balancer_type = "Network"
    address_type       = "Internet"
    address_ip_version = "Ipv4"
    vpc_id             = null
  }
}

# Zone mappings configuration
variable "zone_mappings" {
  description = "List of zone mappings for the Network Load Balancer. At least two zones are required."
  type = list(object({
    zone_id              = string
    vswitch_id           = string
    allocation_id        = optional(string, null)
    private_ipv4_address = optional(string, null)
    ipv6_address         = optional(string, null)
  }))
  default = []
}

# Server Group configuration
variable "server_group_config" {
  description = "Configuration for the server group. The attributes 'server_group_name', 'server_group_type', 'vpc_id', 'scheduler', and 'protocol' are required."
  type = object({
    server_group_name = string
    server_group_type = string
    vpc_id            = string
    scheduler         = string
    protocol          = string

    # Optional configurations
    address_ip_version         = optional(string, "Ipv4")
    resource_group_id          = optional(string, null)
    connection_drain_enabled   = optional(bool, false)
    connection_drain_timeout   = optional(number, 300)
    preserve_client_ip_enabled = optional(bool, false)
    any_port_enabled           = optional(bool, false)

    # Health check configurations
    health_check_enabled         = optional(bool, true)
    health_check_type            = optional(string, "TCP")
    health_check_connect_port    = optional(number, 0)
    healthy_threshold            = optional(number, 2)
    unhealthy_threshold          = optional(number, 2)
    health_check_connect_timeout = optional(number, 5)
    health_check_interval        = optional(number, 10)
    health_check_domain          = optional(string, null)
    health_check_url             = optional(string, null)
    health_check_http_code       = optional(list(string), ["http_2xx"])
    http_check_method            = optional(string, "GET")

    # Tags
    tags = optional(map(string), {})
  })
  default = {
    server_group_name = null
    server_group_type = "Instance"
    vpc_id            = null
    scheduler         = "Wrr"
    protocol          = "TCP"
  }
}

# Listeners configuration
variable "listeners_config" {
  description = "Map of listener configurations. Each listener must have listener_protocol and listener_port."
  type = map(object({
    listener_protocol    = string
    listener_port        = number
    listener_description = optional(string, null)

    # Port range configurations
    start_port = optional(number, null)
    end_port   = optional(number, null)

    # TCP/UDP configurations
    idle_timeout           = optional(number, 900)
    proxy_protocol_enabled = optional(bool, false)
    cps                    = optional(number, null)
    mss                    = optional(number, null)

    # TCPSSL configurations
    alpn_enabled       = optional(bool, false)
    alpn_policy        = optional(string, null)
    ca_enabled         = optional(bool, false)
    ca_certificate_ids = optional(list(string), null)
    certificate_ids    = optional(list(string), null)
    security_policy_id = optional(string, null)

    # Monitoring
    sec_sensor_enabled = optional(bool, false)

    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

# Security policies configuration
variable "security_policies_config" {
  description = "Map of security policy configurations for TCPSSL listeners."
  type = map(object({
    security_policy_name = string
    resource_group_id    = optional(string, null)
    ciphers              = list(string)
    tls_versions         = list(string)
    tags                 = optional(map(string), {})
  }))
  default = {}
}

# Server attachments configuration
variable "server_attachments_config" {
  description = "Map of server attachment configurations."
  type = map(object({
    server_type = string
    server_id   = string
    server_ip   = optional(string, null)
    port        = optional(number, null)
    weight      = optional(number, 100)
    description = optional(string, null)
  }))
  default = {}
}

# Security group attachments configuration
variable "security_group_attachments_config" {
  description = "Map of security group attachment configurations."
  type = map(object({
    security_group_id = string
  }))
  default = {}
}