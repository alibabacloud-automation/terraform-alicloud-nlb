Alicloud Network Load Balancer (NLB) Terraform Module

# terraform-alicloud-nlb

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-nlb/blob/main/README-CN.md)

Terraform module which creates Network Load Balancer (NLB) resources on Alibaba Cloud. This module provides a comprehensive solution for deploying and managing Network Load Balancers, including load balancer instances, server groups, listeners, security policies, and server attachments. Network Load Balancer is a high-performance load balancing service that operates at the transport layer (Layer 4) and supports TCP, UDP, and TCPSSL protocols. For more information about Network Load Balancer, see [Network Load Balancer Product Overview](https://www.alibabacloud.com/help/en/server-load-balancer/latest/nlb-product-overview).

## Usage

This module creates a Network Load Balancer with associated server groups and listeners. The module supports flexible configuration options including multiple listeners, health checks, SSL termination, and cross-zone load balancing.

```terraform
data "alicloud_nlb_zones" "default" {}

data "alicloud_resource_manager_resource_groups" "default" {}

module "nlb" {
  source = "alibabacloud-automation/nlb/alicloud"

  # Load Balancer configuration
  load_balancer_config = {
    load_balancer_name = "my-nlb"
    load_balancer_type = "Network"
    address_type       = "Internet"
    address_ip_version = "Ipv4"
    vpc_id             = "vpc-xxxxxxxxxx"
    resource_group_id  = data.alicloud_resource_manager_resource_groups.default.ids[0]
    cross_zone_enabled = true
  }

  # Zone mappings
  zone_mappings = [
    {
      zone_id    = data.alicloud_nlb_zones.default.zones[0].id
      vswitch_id = "vsw-xxxxxxxxxx"
    },
    {
      zone_id    = data.alicloud_nlb_zones.default.zones[1].id
      vswitch_id = "vsw-yyyyyyyyyy"
    }
  ]

  # Server Group configuration
  server_group_config = {
    server_group_name = "my-server-group"
    server_group_type = "Instance"
    vpc_id            = "vpc-xxxxxxxxxx"
    scheduler         = "Wrr"
    protocol          = "TCP"
  }

  # Listeners configuration
  listeners_config = {
    "http" = {
      listener_protocol = "TCP"
      listener_port     = 80
    }
  }
}
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-nlb/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.191.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | >= 1.191.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_nlb_listener.listeners](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nlb_listener) | resource |
| [alicloud_nlb_load_balancer.nlb](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nlb_load_balancer) | resource |
| [alicloud_nlb_load_balancer_security_group_attachment.security_group_attachments](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nlb_load_balancer_security_group_attachment) | resource |
| [alicloud_nlb_security_policy.security_policies](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nlb_security_policy) | resource |
| [alicloud_nlb_server_group.server_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nlb_server_group) | resource |
| [alicloud_nlb_server_group_server_attachment.server_attachments](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nlb_server_group_server_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_nlb"></a> [create\_nlb](#input\_create\_nlb) | Whether to create a new Network Load Balancer. If false, an existing NLB ID must be provided. | `bool` | `true` | no |
| <a name="input_create_server_group"></a> [create\_server\_group](#input\_create\_server\_group) | Whether to create a new server group. If false, an existing server group ID must be provided. | `bool` | `true` | no |
| <a name="input_listeners_config"></a> [listeners\_config](#input\_listeners\_config) | Map of listener configurations. Each listener must have listener\_protocol and listener\_port. | <pre>map(object({<br/>    listener_protocol    = string<br/>    listener_port        = number<br/>    listener_description = optional(string, null)<br/><br/>    # Port range configurations<br/>    start_port = optional(number, null)<br/>    end_port   = optional(number, null)<br/><br/>    # TCP/UDP configurations<br/>    idle_timeout           = optional(number, 900)<br/>    proxy_protocol_enabled = optional(bool, false)<br/>    cps                    = optional(number, null)<br/>    mss                    = optional(number, null)<br/><br/>    # TCPSSL configurations<br/>    alpn_enabled       = optional(bool, false)<br/>    alpn_policy        = optional(string, null)<br/>    ca_enabled         = optional(bool, false)<br/>    ca_certificate_ids = optional(list(string), null)<br/>    certificate_ids    = optional(list(string), null)<br/>    security_policy_id = optional(string, null)<br/><br/>    # Monitoring<br/>    sec_sensor_enabled = optional(bool, false)<br/><br/>    # Tags<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_load_balancer_config"></a> [load\_balancer\_config](#input\_load\_balancer\_config) | Configuration for the Network Load Balancer. The attributes 'load\_balancer\_name', 'load\_balancer\_type', 'address\_type', 'address\_ip\_version', and 'vpc\_id' are required. | <pre>object({<br/>    load_balancer_name = string<br/>    load_balancer_type = string<br/>    address_type       = string<br/>    address_ip_version = string<br/>    vpc_id             = string<br/><br/>    # Optional configurations<br/>    resource_group_id    = optional(string, null)<br/>    bandwidth_package_id = optional(string, null)<br/>    cross_zone_enabled   = optional(bool, null)<br/>    ipv6_address_type    = optional(string, null)<br/>    cps                  = optional(number, null)<br/>    security_group_ids   = optional(set(string), null)<br/><br/>    # Protection configurations<br/>    deletion_protection_enabled    = optional(bool, false)<br/>    deletion_protection_reason     = optional(string, null)<br/>    modification_protection_status = optional(string, "NonProtection")<br/>    modification_protection_reason = optional(string, null)<br/><br/>    # Tags<br/>    tags = optional(map(string), {})<br/>  })</pre> | <pre>{<br/>  "address_ip_version": "Ipv4",<br/>  "address_type": "Internet",<br/>  "load_balancer_name": null,<br/>  "load_balancer_type": "Network",<br/>  "vpc_id": null<br/>}</pre> | no |
| <a name="input_nlb_id"></a> [nlb\_id](#input\_nlb\_id) | The ID of an existing Network Load Balancer. Required when create\_nlb is false. | `string` | `null` | no |
| <a name="input_security_group_attachments_config"></a> [security\_group\_attachments\_config](#input\_security\_group\_attachments\_config) | Map of security group attachment configurations. | <pre>map(object({<br/>    security_group_id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_security_policies_config"></a> [security\_policies\_config](#input\_security\_policies\_config) | Map of security policy configurations for TCPSSL listeners. | <pre>map(object({<br/>    security_policy_name = string<br/>    resource_group_id    = optional(string, null)<br/>    ciphers              = list(string)<br/>    tls_versions         = list(string)<br/>    tags                 = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_server_attachments_config"></a> [server\_attachments\_config](#input\_server\_attachments\_config) | Map of server attachment configurations. | <pre>map(object({<br/>    server_type = string<br/>    server_id   = string<br/>    server_ip   = optional(string, null)<br/>    port        = optional(number, null)<br/>    weight      = optional(number, 100)<br/>    description = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_server_group_config"></a> [server\_group\_config](#input\_server\_group\_config) | Configuration for the server group. The attributes 'server\_group\_name', 'server\_group\_type', 'vpc\_id', 'scheduler', and 'protocol' are required. | <pre>object({<br/>    server_group_name = string<br/>    server_group_type = string<br/>    vpc_id            = string<br/>    scheduler         = string<br/>    protocol          = string<br/><br/>    # Optional configurations<br/>    address_ip_version         = optional(string, "Ipv4")<br/>    resource_group_id          = optional(string, null)<br/>    connection_drain_enabled   = optional(bool, false)<br/>    connection_drain_timeout   = optional(number, 300)<br/>    preserve_client_ip_enabled = optional(bool, false)<br/>    any_port_enabled           = optional(bool, false)<br/><br/>    # Health check configurations<br/>    health_check_enabled         = optional(bool, true)<br/>    health_check_type            = optional(string, "TCP")<br/>    health_check_connect_port    = optional(number, 0)<br/>    healthy_threshold            = optional(number, 2)<br/>    unhealthy_threshold          = optional(number, 2)<br/>    health_check_connect_timeout = optional(number, 5)<br/>    health_check_interval        = optional(number, 10)<br/>    health_check_domain          = optional(string, null)<br/>    health_check_url             = optional(string, null)<br/>    health_check_http_code       = optional(list(string), ["http_2xx"])<br/>    http_check_method            = optional(string, "GET")<br/><br/>    # Tags<br/>    tags = optional(map(string), {})<br/>  })</pre> | <pre>{<br/>  "protocol": "TCP",<br/>  "scheduler": "Wrr",<br/>  "server_group_name": null,<br/>  "server_group_type": "Instance",<br/>  "vpc_id": null<br/>}</pre> | no |
| <a name="input_server_group_id"></a> [server\_group\_id](#input\_server\_group\_id) | The ID of an existing server group. Required when create\_server\_group is false. | `string` | `null` | no |
| <a name="input_zone_mappings"></a> [zone\_mappings](#input\_zone\_mappings) | List of zone mappings for the Network Load Balancer. At least two zones are required. | <pre>list(object({<br/>    zone_id              = string<br/>    vswitch_id           = string<br/>    allocation_id        = optional(string, null)<br/>    private_ipv4_address = optional(string, null)<br/>    ipv6_address         = optional(string, null)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_listener_ids"></a> [listener\_ids](#output\_listener\_ids) | List of listener IDs |
| <a name="output_listeners"></a> [listeners](#output\_listeners) | Map of listener information including IDs and regions |
| <a name="output_nlb_create_time"></a> [nlb\_create\_time](#output\_nlb\_create\_time) | The creation time of the Network Load Balancer |
| <a name="output_nlb_dns_name"></a> [nlb\_dns\_name](#output\_nlb\_dns\_name) | The DNS name of the Network Load Balancer |
| <a name="output_nlb_id"></a> [nlb\_id](#output\_nlb\_id) | The ID of the Network Load Balancer |
| <a name="output_nlb_load_balancer_business_status"></a> [nlb\_load\_balancer\_business\_status](#output\_nlb\_load\_balancer\_business\_status) | The business status of the Network Load Balancer |
| <a name="output_nlb_region_id"></a> [nlb\_region\_id](#output\_nlb\_region\_id) | The region ID where the Network Load Balancer is deployed |
| <a name="output_nlb_status"></a> [nlb\_status](#output\_nlb\_status) | The status of the Network Load Balancer |
| <a name="output_nlb_zone_mappings"></a> [nlb\_zone\_mappings](#output\_nlb\_zone\_mappings) | The zone mappings of the Network Load Balancer |
| <a name="output_security_group_attachment_ids"></a> [security\_group\_attachment\_ids](#output\_security\_group\_attachment\_ids) | List of security group attachment IDs |
| <a name="output_security_group_attachments"></a> [security\_group\_attachments](#output\_security\_group\_attachments) | Map of security group attachment IDs |
| <a name="output_security_policies"></a> [security\_policies](#output\_security\_policies) | Map of security policy information including IDs and status |
| <a name="output_security_policy_ids"></a> [security\_policy\_ids](#output\_security\_policy\_ids) | List of security policy IDs |
| <a name="output_server_attachment_ids"></a> [server\_attachment\_ids](#output\_server\_attachment\_ids) | List of server attachment IDs |
| <a name="output_server_attachments"></a> [server\_attachments](#output\_server\_attachments) | Map of server attachment information including IDs, status, and zone IDs |
| <a name="output_server_group_id"></a> [server\_group\_id](#output\_server\_group\_id) | The ID of the server group |
| <a name="output_server_group_region_id"></a> [server\_group\_region\_id](#output\_server\_group\_region\_id) | The region ID where the server group is deployed |
| <a name="output_server_group_status"></a> [server\_group\_status](#output\_server\_group\_status) | The status of the server group |
<!-- END_TF_DOCS -->

## Submit Issues

If you have any problems when using this module, please opening
a [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend opening an issue on this repo.

## Authors

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## License

MIT Licensed. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)