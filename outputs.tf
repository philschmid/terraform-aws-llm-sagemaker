# ------------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------------

output "iam_role" {
  description = "IAM role used in the endpoint"
  value       = local.role_arn
}

output "container" {
  value = local.image_uri
}

output "sagemaker_model" {
  description = "created Amazon SageMaker model resource"
  value       = aws_sagemaker_model.huggingface_hub_model
}

output "sagemaker_endpoint_configuration" {
  description = "created Amazon SageMaker endpoint configuration resource"
  value       = aws_sagemaker_endpoint_configuration.llm
}

output "sagemaker_endpoint" {
  description = "created Amazon SageMaker endpoint resource"
  value       = aws_sagemaker_endpoint.llm
}

output "sagemaker_endpoint_name" {
  description = "Name of the created Amazon SageMaker endpoint, used for invoking the endpoint, with sdks"
  value       = aws_sagemaker_endpoint.llm.name
}

output "tags" {
  value = var.tags
}
