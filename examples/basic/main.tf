module "sagemaker_endpoint" {
  source = "../.."

  # All variables have default values, so we don't need to specify anything here.
  # However, you can override any variable if needed, for example:
  # region         = "us-east-1"
  # model_name     = "custom-model"
  # endpoint_name  = "custom-endpoint"
}

output "endpoint_name" {
  value = module.sagemaker_endpoint.endpoint_name
}

output "endpoint_arn" {
  value = module.sagemaker_endpoint.endpoint_arn
}

output "model_name" {
  value = module.sagemaker_endpoint.model_name
}

output "model_arn" {
  value = module.sagemaker_endpoint.model_arn
}
