variable "aws_region" {
  description = "AWS region for the validation-only blueprint."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "enterprise-cloud-devops-platform"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must use lowercase letters, digits, and hyphens."
  }
}

variable "environment" {
  type    = string
  default = "portfolio"
}

variable "vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be valid IPv4 CIDR notation."
  }
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.30.1.0/24", "10.30.2.0/24"]
  validation {
    condition     = length(var.public_subnet_cidrs) == 2 && alltrue([for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "Exactly two valid public subnet CIDRs are required."
  }
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.30.11.0/24", "10.30.12.0/24"]
  validation {
    condition     = length(var.private_subnet_cidrs) == 2 && alltrue([for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "Exactly two valid private subnet CIDRs are required."
  }
}
