variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-2"
}

variable "endpoint_name_prefix" {
  description = "Prefix for the name of the SageMaker endpoint"
  type        = string
}

variable "llm_container" {
  description = "URI of the Docker image containing the model"
  type        = string
  default     = "763104351884.dkr.ecr.us-west-2.amazonaws.com/pytorch-inference:1.5.1-cpu-py3"
}

variable "hf_model_id" {
  description = "The Hugging Face model ID to deploy"
  type        = string
}

variable "hf_token" {
  description = "The Hugging Face API token"
  type        = string
  default     = null
}

variable "max_input_tokens" {
  description = "The maximum number of tokens that can be passed to the model"
  type        = number
  default     = 2048
}

variable "max_total_tokens" {
  description = "The maximum number of tokens the model can generate"
  type        = number
  default     = 4096
}

variable "MAX_BATCH_TOTAL_TOKENS" {
  description = "The maximum number of tokens in batch for continous batching"
  type        = number
  default     = 8192
}

variable "instance_type" {
  description = "The EC2 instance type to deploy this Model to. For example, `ml.g5.xlarge`."
  type        = string
  default     = null
}

variable "instance_count" {
  description = "The initial number of instances to run in the Endpoint created from this Model. Defaults to 1."
  type        = number
  default     = 1
}

variable "sagemaker_execution_role" {
  description = "An AWS IAM role Name to access training data and model artifacts. After the endpoint is created, the inference code might use the IAM role if it needs to access some AWS resources. If not specified, the role will created with with the `CreateModel` permissions from the [documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-roles.html#sagemaker-roles-createmodel-perms)"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}

# variable "autoscaling" {
#   description = "A Object which defines the autoscaling target and policy for our SageMaker Endpoint. Required keys are `max_capacity` and `scaling_target_invocations` "
#   type = object({
#     min_capacity               = optional(number),
#     max_capacity               = number,
#     scaling_target_invocations = optional(number),
#     scale_in_cooldown          = optional(number),
#     scale_out_cooldown         = optional(number),
#   })

#   default = {
#     min_capacity               = 1
#     max_capacity               = null
#     scaling_target_invocations = null
#     scale_in_cooldown          = 300
#     scale_out_cooldown         = 66
#   }
# }
