# ---------------------------------------------------------------------------------------------------------------------
# Example Deploy from HuggingFace Hub
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

module "sagemaker_endpoint" {
  source               = "../.."
  endpoint_name_prefix = "llama3"
  hf_model_id          = "meta-llama/Meta-Llama-3-8B-Instruct"
  instance_type        = "ml.g5.2xlarge"

  tgi_config = {
    max_input_tokens       = 4000
    max_total_tokens       = 4096
    max_batch_total_tokens = 6144
  }
}

output "endpoint_name" {
  value = module.sagemaker_endpoint.sagemaker_endpoint_name
}

output "container" {
  value = module.sagemaker_endpoint.container
}
