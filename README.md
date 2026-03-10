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
    health_check_enabled = true
  }
  
  # Listeners configuration
  listeners_config = {
    "http" = {
      listener_protocol = "TCP"
      listener_port     = 80
      idle_timeout      = 900
    }
  }
}
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-nlb/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
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