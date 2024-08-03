# Example: Deploy from Hugging Face Hub (hf.co/models)

```hcl
module "huggingface_sagemaker" {
  source               = "philschmid/llm-sagemaker/aws"
  version              = "0.1.0"
  endpoint_name_prefix = "llama3"
  hf_model_id          = "meta-llama/Meta-Llama-3.1-8B-Instruct"
  hf_token             = "YOUR_HF_TOKEN_WITH_ACCESS_TO_THE_MODEL"
  instance_type        = "ml.g5.2xlarge"
  instance_count       = 1 # default is 1

  tgi_config = {
    max_input_tokens       = 4000
    max_total_tokens       = 4096
    max_batch_total_tokens = 6144
  }
}
```
