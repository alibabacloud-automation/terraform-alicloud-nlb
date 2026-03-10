terraform {
  required_version = ">= 1.0"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = ">= 1.191.0"
    }
  }
}

provider "alicloud" {
  region = var.region
  # Configuration will be provided by environment variables or shared credentials
  # export ALICLOUD_ACCESS_KEY="your-access-key"
  # export ALICLOUD_SECRET_KEY="your-secret-key"
  # export ALICLOUD_REGION="your-region"
}