
#TODO: Fine tune and tailor the permissions to only the actions and resources it needs

locals {
  lambda_api_role_name = "riot-api-lambda-${var.environment}"
}

resource "aws_iam_role" "lambda_api" {
  name = local.lambda_api_role_name
  assume_role_policy = data.aws_iam_policy_document.api_role_trust.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
  ]

  inline_policy {
    name = "primary"
    policy = data.aws_iam_policy_document.api_inline_policy.json
  }

}


data "aws_iam_policy_document" "api_inline_policy" {
  statement {
    actions   = ["ec2:DescribeAccountAttributes"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "api_role_trust" {
  statement {
    actions   = ["sts:AssumeRole"]
    principals {
        type = "Service"
        identifiers =["lambda.amazonaws.com"]
    }
  }
}