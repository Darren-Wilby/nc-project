variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
  default     = "my-vpc"
}

variable "cluster_name" {
  description = "Name of the cluster."
  type        = string
  default     = "my-cluster"
}

variable "desired_size" {
  description = "Desired size of node group."
  type        = number
  default     = 1
}