variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "trigger_queue_arn" {
  type = string
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnets" {
  type    = list(string)
  default = []
}

variable "asg_name" {
  type = string
}