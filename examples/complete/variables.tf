variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "nlb-example"
}

variable "image_id" {
  description = "Image ID for ECS instances"
  type        = string
  default     = "ubuntu_18_04_x64_20G_alibase_20220428.vhd" # Default Ubuntu image
}

variable "instance_type" {
  description = "Instance type for ECS instances"
  type        = string
  default     = "ecs.c6.large" # More widely available instance type
}

variable "instance_password" {
  description = "Password for ECS instances"
  type        = string
  default     = "YourPassword123!" # Default password
  sensitive   = true
}

variable "security_policy_id" {
  description = "Security policy ID for listeners"
  type        = string
  default     = "" # Leave empty for default
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
  default     = "cn-shanghai"
}

