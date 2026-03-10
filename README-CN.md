阿里云网络负载均衡器（NLB）Terraform 模块

# terraform-alicloud-nlb

[English](https://github.com/alibabacloud-automation/terraform-alicloud-nlb/blob/main/README.md) | 简体中文

在阿里云上创建网络负载均衡器（NLB）资源的 Terraform 模块。该模块提供了一个全面的解决方案，用于部署和管理网络负载均衡器，包括负载均衡器实例、服务器组、监听器、安全策略和服务器挂载。网络负载均衡器是一种高性能的负载均衡服务，工作在传输层（第四层），支持 TCP、UDP 和 TCPSSL 协议。有关网络负载均衡器的更多信息，请参阅[网络负载均衡器产品概述](https://www.alibabacloud.com/help/en/server-load-balancer/latest/nlb-product-overview)。

## 使用方法

此模块创建一个网络负载均衡器以及相关的服务器组和监听器。该模块支持灵活的配置选项，包括多个监听器、健康检查、SSL 终止和跨可用区负载均衡。

```terraform
data "alicloud_nlb_zones" "default" {}

data "alicloud_resource_manager_resource_groups" "default" {}

module "nlb" {
  source = "alibabacloud-automation/nlb/alicloud"
  
  # 负载均衡器配置
  load_balancer_config = {
    load_balancer_name = "my-nlb"
    load_balancer_type = "Network"
    address_type       = "Internet"
    address_ip_version = "Ipv4"
    vpc_id             = "vpc-xxxxxxxxxx"
    resource_group_id  = data.alicloud_resource_manager_resource_groups.default.ids[0]
    cross_zone_enabled = true
  }
  
  # 可用区映射
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
  
  # 服务器组配置
  server_group_config = {
    server_group_name = "my-server-group"
    server_group_type = "Instance"
    vpc_id            = "vpc-xxxxxxxxxx"
    scheduler         = "Wrr"
    protocol          = "TCP"
    health_check_enabled = true
  }
  
  # 监听器配置
  listeners_config = {
    "http" = {
      listener_protocol = "TCP"
      listener_port     = 80
      idle_timeout      = 900
    }
  }
}
```

## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-nlb/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## 提交问题

如果您在使用此模块时遇到任何问题，请提交一个 [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) 并告知我们。

**注意：** 不建议在此仓库中提交问题。

## 作者

由阿里云 Terraform 团队创建和维护(terraform@alibabacloud.com)。

## 许可证

MIT 许可。有关完整详细信息，请参阅 LICENSE。

## 参考

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)