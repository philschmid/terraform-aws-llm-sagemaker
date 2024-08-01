
# ------------------------------------------------------------------------------
# Local configurations
# ------------------------------------------------------------------------------

provider "aws" {
  region = var.region
}

locals {
  role_arn  = var.sagemaker_execution_role != null ? var.sagemaker_execution_role : aws_iam_role.sagemaker_role.arn
  image_uri = var.llm_container != null ? var.llm_container : "763104351884.dkr.ecr.${var.region}.amazonaws.com/huggingface-pytorch-tgi-inference:2.3.0-gpu-py310-cu121-ubuntu22.04"
  instance_gpu_count = {
    "ml.g5.xlarge"    = 1
    "ml.g5.2xlarge"   = 1
    "ml.g5.4xlarge"   = 1
    "ml.g5.12xlarge"  = 4
    "ml.g5.48xlarge"  = 8
    "ml.g6.xlarge"    = 1
    "ml.g6.2xlarge"   = 1
    "ml.g6.4xlarge"   = 1
    "ml.g6.12xlarge"  = 4
    "ml.g6.48xlarge"  = 8
    "ml.p4d.24xlarge" = 8
    "ml.p5.48xlarge"  = 8
  }
  num_gpus = local.instance_gpu_count[var.instance_type]
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# ------------------------------------------------------------------------------
# Permission
# ------------------------------------------------------------------------------

resource "aws_iam_role" "new_role" {
  count = var.sagemaker_execution_role == null ? 1 : 0 # Creates IAM role if not provided
  name  = "${var.name_prefix}-sagemaker-execution-role-${random_string.resource_id.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "terraform-inferences-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "cloudwatch:PutMetricData",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:CreateLogGroup",
            "logs:DescribeLogStreams",
            "s3:GetObject",
            "s3:PutObject",
            "s3:ListBucket",
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage"
          ],
          Resource = "*"
        }
      ]
    })

  }

  tags = var.tags
}

data "aws_iam_role" "get_role" {
  count = var.sagemaker_execution_role != null ? 1 : 0 # Creates IAM role if not provided
  name  = var.sagemaker_execution_role
}

locals {
  role_arn = var.sagemaker_execution_role != null ? data.aws_iam_role.get_role[0].arn : aws_iam_role.new_role[0].arn
}


# ------------------------------------------------------------------------------
# SageMaker Model
# ------------------------------------------------------------------------------

resource "aws_sagemaker_model" "huggingface_hub_model" {
  name               = "${var.endpoint_name_prefix}-model-${random_string.suffix.result}"
  execution_role_arn = local.role_arn
  tags               = var.tags

  primary_container {
    image = local.image_uri
    environment = {
      HF_MODEL_ID            = var.hf_model_id
      SM_NUM_GPUS            = local.num_gpus
      MAX_INPUT_LENGTH       = var.max_input_tokens
      MAX_TOTAL_TOKENS       = var.max_total_tokens
      MAX_BATCH_TOTAL_TOKENS = var.MAX_BATCH_TOTAL_TOKENS
      MESSAGES_API_ENABLED   = "true"
      HUGGING_FACE_HUB_TOKEN = var.hf_token != null ? var.hf_token : ""
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

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
