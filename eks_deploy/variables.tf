variable "aws_region" {
  description = "AWS region"
  type        = string
  default = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "gpu_instance_type" {
  description = "EC2 instance type for GPU nodes"
  type        = string
  default     = "g4dn.xlarge"
}

variable "node_count" {
  description = "Desired number of GPU nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of GPU nodes for autoscaling"
  type        = number
  default     = 4
}
