terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
  }
  required_version = ">= 0.14.9"
  cloud {
    organization = "LabsDevOpsCloud"
    workspaces {
      name = "event-driven"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "Consumer-SendEmail"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "app.handler"
  role             = "arn:aws:iam::880017691108:role/LabRole"
  runtime          = "nodejs14.x"
}

data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_dir = "${path.module}/src"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_cloudwatch_event_rule" "event_rule" {
	name_prefix = "eventbridge-lambda-"
  event_pattern = <<EOF
{
  "detail-type": ["transaction"],
  "source": ["custom.myApp"],
  "detail": {
	"location": [{
	  "prefix": "EUR-"
	}]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "target_lambda_function" {
  rule = aws_cloudwatch_event_rule.event_rule.name
  arn  = aws_lambda_function.lambda_function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}

output "Consumer-SendEmail" {
  value       = aws_lambda_function.lambda_function.arn
  description = "Consumer-SendEmail Function"
}

