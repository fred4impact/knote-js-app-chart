variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for instances"
  type        = string
  default     = "ec2-aws-key"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "bilarn-vpc"
}
variable "cluster_name" {
  type    = string
  default = "bilarn-cluster"
}

variable "instance_type" {
  type    = string
  default = "t2.xlarge"
}
variable "instance_name" {
  type    = string
  default = "Dev-Server"
}



