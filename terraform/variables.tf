
variable "aws_region" {
  type = string
}

variable "tf_role_arn" {
  type        = string
  description = "Role arn for terraform plan/apply to use"
}

variable "cidr_block" {
  type        = string
  description = "IPv4 CIDR block for the VPC"
  default     = "10.0.0.16"
}

variable "subnet_cidr_block" {
  type        = string
  description = "IPv4 CIDR block for the VPC subnets"
  default     = "10.0.128.0/17"
}

variable "availability_zones" {
  type        = list(string)
  description = "Names of availbility zones to use"
  default     = ["us-east-1a"]
}

variable "kms_key_id" {
  type = string
  description = "KMS key to manage db master password"
}
variable "domain_name" {
  type        = string
  description = "The domain name to access el_demo"
}

variable "api_image" {
  type        = string
  description = "Docker image for el demo api container"
}
