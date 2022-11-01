

# locals {
#   my_function_source = "../path/to/package.zip"
# }

# resource "aws_s3_bucket" "builds" {
#   bucket = "cjd-test-riot-tf-lam"
#   acl    = "private"
# }

# resource "aws_s3_object" "my_function" {
#   bucket = aws_s3_bucket.builds.id
#   key    = "${filemd5(local.my_function_source)}.zip"
#   source = local.my_function_source
# }


# module "lambda_function_existing_package_s3" {
#   source = "terraform-aws-modules/lambda/aws"

#   function_name = "my-lambda-existing-package-local"
#   description   = "My awesome lambda function"
#   handler       = "index.lambda_handler"
#   runtime       = "python3.8"

#   create_package      = false
#   s3_existing_package = {
#     bucket = aws_s3_bucket.builds.id
#     key    = aws_s3_object.my_function.id
#   }
# }