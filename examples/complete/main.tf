
# Get resource groups
data "alicloud_resource_manager_resource_groups" "default" {}

# Get available zones for NLB
data "alicloud_nlb_zones" "default" {}

# Create VPC for the example
resource "alicloud_vpc" "example" {
  vpc_name   = var.name
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = var.name
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}

# Create VSwitches in different zones
resource "alicloud_vswitch" "example" {
  count = 2

  vpc_id       = alicloud_vpc.example.id
  cidr_block   = "10.0.${count.index + 1}.0/24"
  zone_id      = data.alicloud_nlb_zones.default.zones[count.index].zone_id
  vswitch_name = "${var.name}-vswitch-${count.index + 1}"

  tags = {
    Name        = "${var.name}-vswitch-${count.index + 1}"
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}

# Create security group
resource "alicloud_security_group" "example" {
  security_group_name = "${var.name}-sg"
  vpc_id              = alicloud_vpc.example.id

  tags = {
    Name        = "${var.name}-sg"
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}

# Create security group rules
resource "alicloud_security_group_rule" "allow_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alicloud_security_group.example.id
  cidr_ip           = "10.0.0.0/16"
}

resource "alicloud_security_group_rule" "allow_https" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 1
  security_group_id = alicloud_security_group.example.id
  cidr_ip           = "10.0.0.0/16"
}

# Create ECS instances as backend servers
resource "alicloud_instance" "backend_servers" {
  count = 2

  image_id                   = var.image_id
  instance_type              = var.instance_type
  security_groups            = [alicloud_security_group.example.id]
  vswitch_id                 = alicloud_vswitch.example[count.index].id
  instance_name              = "${var.name}-backend-${count.index + 1}"
  internet_max_bandwidth_out = 10
  password                   = var.instance_password

  tags = {
    Name        = "${var.name}-backend-${count.index + 1}"
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}

# Create elastic network interfaces for the ECS instances
resource "alicloud_network_interface" "eni" {
  count = 2

  network_interface_name = "${var.name}-eni-${count.index + 1}"
  vswitch_id             = alicloud_vswitch.example[count.index].id
  security_group_ids     = [alicloud_security_group.example.id]
  primary_ip_address     = cidrhost(alicloud_vswitch.example[count.index].cidr_block, 100 + count.index)

  tags = {
    Name        = "${var.name}-eni-${count.index + 1}"
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}

# Attach network interfaces to ECS instances
resource "alicloud_network_interface_attachment" "attachment" {
  count = 2

  instance_id          = alicloud_instance.backend_servers[count.index].id
  network_interface_id = alicloud_network_interface.eni[count.index].id
}

# Use the NLB module
module "nlb" {
  source = "../../"

  # Load Balancer configuration
  load_balancer_config = {
    load_balancer_name = var.name
    load_balancer_type = "Network"
    address_type       = "Intranet"
    address_ip_version = "Ipv4"
    vpc_id             = alicloud_vpc.example.id
    resource_group_id  = data.alicloud_resource_manager_resource_groups.default.ids[0]
    cross_zone_enabled = true

    # Protection settings
    deletion_protection_enabled    = false
    modification_protection_status = "NonProtection"

    tags = {
      Name        = var.name
      Environment = "example"
      ManagedBy   = "Terraform"
    }
  }

  # Zone mappings
  zone_mappings = [
    {
      zone_id    = data.alicloud_nlb_zones.default.zones[0].zone_id
      vswitch_id = alicloud_vswitch.example[0].id
    },
    {
      zone_id    = data.alicloud_nlb_zones.default.zones[1].zone_id
      vswitch_id = alicloud_vswitch.example[1].id
    }
  ]

  # Server Group configuration
  server_group_config = {
    server_group_name = "${var.name}-server-group"
    server_group_type = "Instance"
    vpc_id            = alicloud_vpc.example.id
    scheduler         = "Wrr"
    protocol          = "TCP"
    resource_group_id = data.alicloud_resource_manager_resource_groups.default.ids[0]

    # Connection drain
    connection_drain_enabled = true
    connection_drain_timeout = 300

    # Health check
    health_check_enabled         = true
    health_check_type            = "TCP"
    health_check_connect_port    = 0
    healthy_threshold            = 2
    unhealthy_threshold          = 2
    health_check_connect_timeout = 5
    health_check_interval        = 10

    tags = {
      Name        = "${var.name}-server-group"
      Environment = "example"
      ManagedBy   = "Terraform"
    }
  }

  # Add listeners configuration
  listeners_config = {
    tcp_listener = {
      listener_name     = "${var.name}-tcp-listener"
      listener_protocol = "TCP"
      listener_port     = 80
      server_group_id   = module.nlb.server_group_id # Reference the server group from the module output
      description       = "TCP listener for ${var.name}"

      # Listener-specific configurations
      acl_config = {
        acl_type   = "white"
        acl_status = "on"
      }

      # Connection idle timeout
      idle_time_out = 900

      # Bandwidth
      bandwidth = -1

      # Security policy
      security_policy_id = var.security_policy_id
    }
  }
}