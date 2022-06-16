provider "aws" {
  region = "us-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "4.18.0"
    }
  }
  required_version = ">=1.0.7"
}

locals {
  region  = "us-west-2"
  project = "ec2-scale-by-trigger"
  env     = "dev"
}

module "vpc" {
  source = "./vpc/"

  # vpc
  cidr_block      = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  region  = local.region
  project = local.project
  env     = local.env

  tags = {
    Project     = local.project
    Environment = local.env
  }
}

module "asg" {
  source = "./asg/"

  project = local.project
  region  = local.region
  env     = local.env

  subnets = module.vpc.private_subnets
  vpc_id  = module.vpc.vpc_id

  tags = {
    Project     = local.project
    Environment = local.env
  }
}

resource "aws_sqs_queue" "this" {
  name                       = "${local.project}-${local.env}-queue"
  delay_seconds              = 0
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 900

  tags = {
    Project     = local.project
    Environment = local.env
  }
}

module "lambda" {
  source = "./lambda/"

  project = local.project
  region  = local.region
  env     = local.env

  trigger_queue_arn = aws_sqs_queue.this.arn
  asg_name          = module.asg.asg_name

  tags = {
    Project     = local.project
    Environment = local.env
  }
}

############
# This command can be used to publish messages to SQS queue from EC2 machine located in private subnet, and --endpoint-url speeds up the process significantly:
# aws sqs send-message --queue-url <SQS HTTP Url> --endpoint-url https://sqs.us-west-2.amazonaws.com/ --message-body 0
############