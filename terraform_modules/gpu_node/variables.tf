variable "instance_count" {
  description = "Number of GPU instances to create"
  type        = number
  default     = 1
}

variable "ami" {
  description = "AMI ID for the GPU instance"
  type        = string
}

variable "instance_type" {
  description = "Type of GPU instance"
  type        = string
  default     = "g4dn.xlarge"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security group is created"
  type        = string
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 100
}

variable "user_data" {
  description = "Startup script"
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "Base name for instances"
  type        = string
}
