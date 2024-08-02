# LLM SageMaker Module

Terraform module for easily deploy open LLMs from [Hugging Face](hf.co/models) to [Amazon SageMaker](https://aws.amazon.com/de/sagemaker/) real-time endpoints. This module will create all the necessary resources to deploy a model to Amazon SageMaker including IAM roles, if not provided, SageMaker Model, SageMaker Endpoint Configuration, SageMaker endpoint.

With this module you can deploy Llama 3, Mistral, Mixtral, Command and many more models from Hugging Face to Amazon SageMaker.

## Usage

**basic example**

```hcl
module "sagemaker-huggingface" {
  source               = "philschmid/sagemaker-huggingface/aws"
  version              = "0.1.0"
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

**examples:**

- [Basic Example deploy Llama 3](./examples/basic/README.md)

## Run Tests

```bash
AWS_PROFILE=hf-sm AWS_DEFAULT_REGION=us-east-1 go test -v
```

## License

MIT License. See [LICENSE](LICENSE) for full details.

## Requirements

| Name                                                            | Version |
| --------------------------------------------------------------- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement_aws)          | 5.60.0  |
| <a name="requirement_random"></a> [random](#requirement_random) | 3.1.0   |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)          | 5.60.0  |
| <a name="provider_random"></a> [random](#provider_random) | 3.1.0   |

## Modules

No modules.

## Resources

| Name                                                                                                                                                     | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_appautoscaling_policy.sagemaker_policy](https://registry.terraform.io/providers/hashicorp/aws/5.60.0/docs/resources/appautoscaling_policy)          | resource    |
| [aws_appautoscaling_target.sagemaker_target](https://registry.terraform.io/providers/hashicorp/aws/5.60.0/docs/resources/appautoscaling_target)          | resource    |
| [aws_iam_role.new_role](https://registry.terraform.io/providers/hashicorp/aws/5.60.0/docs/resources/iam_role)                                            | resource    |
| [aws_sagemaker_endpoint.llm](https://registry.terraform.io/providers/hashicorp/aws/5.60.0/docs/resources/sagemaker_endpoint)                             | resource    |
| [aws_sagemaker_endpoint_configuration.llm](https://registry.terraform.io/providers/hashicorp/aws/5.60.0/docs/resources/sagemaker_endpoint_configuration) | resource    |
| [aws_sagemaker_model.huggingface_hub_model](https://registry.terraform.io/providers/hashicorp/aws/5.60.0/docs/resources/sagemaker_model)                 | resource    |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/3.1.0/docs/resources/string)                                             | resource    |
| [aws_iam_role.get_role](https://registry.terraform.io/providers/hashicorp/aws/5.60.0/docs/data-sources/iam_role)                                         | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/5.60.0/docs/data-sources/region)                                              | data source |

## Inputs

| Name                                                                                                      | Description                                                                                                                                                                                                                                                                                                                                                                                           | Type                                                                                                                                                                                                                               | Default                                                                                                                                                               | Required |
| --------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_autoscaling"></a> [autoscaling](#input_autoscaling)                                        | A Object which defines the autoscaling target and policy for our SageMaker Endpoint. Required keys are `max_capacity` and `scaling_target_invocations`                                                                                                                                                                                                                                                | <pre>object({<br> min_capacity = optional(number),<br> max_capacity = number,<br> scaling_target_invocations = optional(number),<br> scale_in_cooldown = optional(number),<br> scale_out_cooldown = optional(number),<br> })</pre> | <pre>{<br> "max_capacity": null,<br> "min_capacity": 1,<br> "scale_in_cooldown": 300,<br> "scale_out_cooldown": 66,<br> "scaling_target_invocations": null<br>}</pre> |    no    |
| <a name="input_endpoint_name_prefix"></a> [endpoint_name_prefix](#input_endpoint_name_prefix)             | Prefix for the name of the SageMaker endpoint                                                                                                                                                                                                                                                                                                                                                         | `string`                                                                                                                                                                                                                           | n/a                                                                                                                                                                   |   yes    |
| <a name="input_hf_model_id"></a> [hf_model_id](#input_hf_model_id)                                        | The Hugging Face model ID to deploy                                                                                                                                                                                                                                                                                                                                                                   | `string`                                                                                                                                                                                                                           | n/a                                                                                                                                                                   |   yes    |
| <a name="input_hf_token"></a> [hf_token](#input_hf_token)                                                 | The Hugging Face API token                                                                                                                                                                                                                                                                                                                                                                            | `string`                                                                                                                                                                                                                           | `null`                                                                                                                                                                |    no    |
| <a name="input_instance_count"></a> [instance_count](#input_instance_count)                               | The initial number of instances to run in the Endpoint created from this Model. Defaults to 1.                                                                                                                                                                                                                                                                                                        | `number`                                                                                                                                                                                                                           | `1`                                                                                                                                                                   |    no    |
| <a name="input_instance_type"></a> [instance_type](#input_instance_type)                                  | The EC2 instance type to deploy this Model to. For example, `ml.g5.xlarge`.                                                                                                                                                                                                                                                                                                                           | `string`                                                                                                                                                                                                                           | `null`                                                                                                                                                                |    no    |
| <a name="input_llm_container"></a> [llm_container](#input_llm_container)                                  | URI of the Docker image containing the model                                                                                                                                                                                                                                                                                                                                                          | `string`                                                                                                                                                                                                                           | `null`                                                                                                                                                                |    no    |
| <a name="input_sagemaker_execution_role"></a> [sagemaker_execution_role](#input_sagemaker_execution_role) | An AWS IAM role Name to access training data and model artifacts. After the endpoint is created, the inference code might use the IAM role if it needs to access some AWS resources. If not specified, the role will created with with the `CreateModel` permissions from the [documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-roles.html#sagemaker-roles-createmodel-perms) | `string`                                                                                                                                                                                                                           | `null`                                                                                                                                                                |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                             | A map of tags (key-value pairs) passed to resources.                                                                                                                                                                                                                                                                                                                                                  | `map(string)`                                                                                                                                                                                                                      | `{}`                                                                                                                                                                  |    no    |
| <a name="input_tgi_config"></a> [tgi_config](#input_tgi_config)                                           | The configuration for the TGI model                                                                                                                                                                                                                                                                                                                                                                   | <pre>object({<br> max_input_tokens = number<br> max_total_tokens = number<br> max_batch_total_tokens = number<br> })</pre>                                                                                                         | <pre>{<br> "max_batch_total_tokens": 8192,<br> "max_input_tokens": 2048,<br> "max_total_tokens": 4096<br>}</pre>                                                      |    no    |

## Outputs

| Name                                                                                                                                | Description                                                                              |
| ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| <a name="output_container"></a> [container](#output_container)                                                                      | n/a                                                                                      |
| <a name="output_iam_role"></a> [iam_role](#output_iam_role)                                                                         | IAM role used in the endpoint                                                            |
| <a name="output_sagemaker_endpoint"></a> [sagemaker_endpoint](#output_sagemaker_endpoint)                                           | created Amazon SageMaker endpoint resource                                               |
| <a name="output_sagemaker_endpoint_configuration"></a> [sagemaker_endpoint_configuration](#output_sagemaker_endpoint_configuration) | created Amazon SageMaker endpoint configuration resource                                 |
| <a name="output_sagemaker_endpoint_name"></a> [sagemaker_endpoint_name](#output_sagemaker_endpoint_name)                            | Name of the created Amazon SageMaker endpoint, used for invoking the endpoint, with sdks |
| <a name="output_sagemaker_model"></a> [sagemaker_model](#output_sagemaker_model)                                                    | created Amazon SageMaker model resource                                                  |
| <a name="output_tags"></a> [tags](#output_tags)                                                                                     | n/a                                                                                      |
