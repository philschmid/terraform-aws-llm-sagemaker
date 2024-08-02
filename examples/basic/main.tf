# ---------------------------------------------------------------------------------------------------------------------
# Example Deploy from HuggingFace Hub
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region  = "us-east-1"
  profile = "hf-sm"
}

module "sagemaker_endpoint" {
  source               = "../.."
  endpoint_name_prefix = "tiny-llama"
  hf_model_id          = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
  instance_type        = "ml.g5.xlarge"

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
