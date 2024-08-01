resource "random_string" "bucket_name" {
  length  = 8
  special = false
}

output "bucket_name" {
  value = random_string.bucket_name.result
}


# provider "aws" {
#   region = var.region
# }

# data "aws_caller_identity" "current" {}

# resource "aws_sagemaker_model" "model" {
#   name               = var.model_name
#   execution_role_arn = aws_iam_role.sagemaker_role.arn

#   primary_container {
#     image = var.model_image_uri
#   }
# }

# resource "aws_sagemaker_endpoint_configuration" "config" {
#   name = var.endpoint_config_name

#   production_variants {
#     variant_name           = "default"
#     model_name             = aws_sagemaker_model.model.name
#     initial_instance_count = var.instance_count
#     instance_type          = var.instance_type
#   }
# }

# resource "aws_sagemaker_endpoint" "endpoint" {
#   name                 = var.endpoint_name
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.config.name
# }

# resource "aws_iam_role" "sagemaker_role" {
#   name = "sagemaker-execution-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "sagemaker.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
#   role       = aws_iam_role.sagemaker_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
# }
