# Example: Deploy from Hugging Face Hub (hf.co/models)

```hcl
module "huggingface_sagemaker" {
  source               = "philschmid/sagemaker-huggingface/aws"
  version              = "0.5.0"
  endpoint_name_prefix = "tiny-llama"
  hf_model_id          = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
  instance_type        = "ml.g5.xlarge"
  instance_count       = 1 # default is 1

  tgi_config = {
    max_input_tokens       = 4000
    max_total_tokens       = 4096
    max_batch_total_tokens = 6144
  }
}
```
