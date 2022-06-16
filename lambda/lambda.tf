data "aws_caller_identity" "current" {}

resource "null_resource" "_" {
  provisioner "local-exec" {
    command     = "/bin/bash ./scripts/build.sh"
    working_dir = "${path.module}/"
  }

  triggers = {
    dependencies_versions = filemd5("${path.module}/src/requirements.txt")
    everytime             = timestamp()
  }
}

data "archive_file" "_" {
  source_dir  = "${path.module}/build/"
  output_path = "${path.module}/dist/lambda.zip"
  type        = "zip"
  depends_on  = [null_resource._]
}


resource "aws_lambda_function" "_" {
  function_name    = "${var.project}-${var.env}-lambda"
  description      = "Lambda to scale ASG."
  filename         = data.archive_file._.output_path
  source_code_hash = data.archive_file._.output_base64sha256

  role = aws_iam_role.lambda_role.arn

  handler     = "main.handler"
  runtime     = "python3.8"
  memory_size = 128
  timeout     = 900

  # Create log group first
  depends_on = [
    aws_cloudwatch_log_group._,
    null_resource._
  ]

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "_" {
  name              = "/aws/lambda/${var.project}-${var.env}-lambda"
  retention_in_days = 7
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = var.trigger_queue_arn
  enabled          = true
  function_name    = aws_lambda_function._.arn
  batch_size       = 1
}

output "lambda_function_name" {
  value = aws_lambda_function._.function_name
}
