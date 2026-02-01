variable "aws_region" {
  type=string
  default="us-west-1"
}

variable "ami_id" {
  type=string
}

variable "instance_type" {
  type=string
  default="t3.micro"
}

variable "sns_email" {
  type=string
  default=""
}

variable "my_ip_cidr" {
  type=string
  default=""
}