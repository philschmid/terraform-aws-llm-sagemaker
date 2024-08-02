
# ------------------------------------------------------------------------------
# Local configurations
# ------------------------------------------------------------------------------

data "aws_region" "current" {}

locals {
  image_uri = var.llm_container != null ? var.llm_container : "763104351884.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/huggingface-pytorch-tgi-inference:2.3.0-gpu-py310-cu121-ubuntu22.04"
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
  name  = "${var.endpoint_name_prefix}-sagemaker-execution-role-${random_string.suffix.result}"
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
    environment = merge(
      {
        HF_MODEL_ID            = var.hf_model_id
        SM_NUM_GPUS            = local.num_gpus
        MAX_INPUT_LENGTH       = var.tgi_config.max_input_tokens
        MAX_TOTAL_TOKENS       = var.tgi_config.max_total_tokens
        MAX_BATCH_TOTAL_TOKENS = var.tgi_config.max_batch_total_tokens
        MESSAGES_API_ENABLED   = "true"
      },
      var.hf_token != null ? { HF_TOKEN = var.hf_token } : {}
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# SageMaker Endpoint configuration
# ------------------------------------------------------------------------------

resource "aws_sagemaker_endpoint_configuration" "llm" {
  name = "${var.endpoint_name_prefix}-config-${random_string.suffix.result}"
  tags = var.tags

  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.huggingface_hub_model.name
    initial_instance_count = var.instance_count
    instance_type          = var.instance_type
  }
}

# ------------------------------------------------------------------------------
# SageMaker Endpoint
# ------------------------------------------------------------------------------


resource "aws_sagemaker_endpoint" "llm" {
  name = "${var.endpoint_name_prefix}-ep-${random_string.suffix.result}"
  tags = var.tags

  endpoint_config_name = aws_sagemaker_endpoint_configuration.llm.name
}

# ------------------------------------------------------------------------------
# AutoScaling configuration
# ------------------------------------------------------------------------------


locals {
  use_autoscaling = var.autoscaling.max_capacity != null && var.autoscaling.scaling_target_invocations != null ? 1 : 0
}

resource "aws_appautoscaling_target" "sagemaker_target" {
  count              = local.use_autoscaling
  min_capacity       = var.autoscaling.min_capacity
  max_capacity       = var.autoscaling.max_capacity
  resource_id        = "endpoint/${aws_sagemaker_endpoint.llm.name}/variant/AllTraffic"
  scalable_dimension = "sagemaker:variant:DesiredInstanceCount"
  service_namespace  = "sagemaker"
}

resource "aws_appautoscaling_policy" "sagemaker_policy" {
  count              = local.use_autoscaling
  name               = "${var.endpoint_name_prefix}-scaling-target-${random_string.suffix.result}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sagemaker_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.sagemaker_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.sagemaker_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "SageMakerVariantInvocationsPerInstance"
    }
    target_value       = var.autoscaling.scaling_target_invocations
    scale_in_cooldown  = var.autoscaling.scale_in_cooldown
    scale_out_cooldown = var.autoscaling.scale_out_cooldown
  }
}
