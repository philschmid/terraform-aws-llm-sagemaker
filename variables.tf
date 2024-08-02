variable "endpoint_name_prefix" {
  description = "Prefix for the name of the SageMaker endpoint"
  type        = string
}

variable "llm_container" {
  description = "URI of the Docker image containing the model"
  type        = string
  default     = null
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

variable "tgi_config" {
  description = "The configuration for the TGI model"
  type = object({
    max_input_tokens       = number
    max_total_tokens       = number
    max_batch_total_tokens = number
  })
  default = {
    max_input_tokens       = 2048
    max_total_tokens       = 4096
    max_batch_total_tokens = 8192
  }
}

variable "instance_type" {
  description = "The EC2 instance type to deploy this Model to. For example, `ml.g5.xlarge`."
  type        = string
  default     = null

  validation {
    condition     = contains(["ml.g5.xlarge", "ml.g5.2xlarge", "ml.g5.4xlarge", "ml.g5.12xlarge", "ml.g5.48xlarge", "ml.g6.xlarge", "ml.g6.2xlarge", "ml.g6.4xlarge", "ml.g6.12xlarge", "ml.g6.48xlarge", "ml.p4d.24xlarge", "ml.p5.48xlarge"], var.instance_type)
    error_message = "Valid values for instance_type are ml.g5.xlarge, ml.g5.2xlarge, ml.g5.4xlarge, ml.g5.12xlarge, ml.g5.48xlarge, ml.g6.xlarge, ml.g6.2xlarge, ml.g6.4xlarge, ml.g6.12xlarge, ml.g6.48xlarge, ml.p4d.24xlarge, ml.p5.48xlarge"
  }
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

variable "autoscaling" {
  description = "A Object which defines the autoscaling target and policy for our SageMaker Endpoint. Required keys are `max_capacity` and `scaling_target_invocations` "
  type = object({
    min_capacity               = optional(number),
    max_capacity               = number,
    scaling_target_invocations = optional(number),
    scale_in_cooldown          = optional(number),
    scale_out_cooldown         = optional(number),
  })

  default = {
    min_capacity               = 1
    max_capacity               = null
    scaling_target_invocations = null
    scale_in_cooldown          = 300
    scale_out_cooldown         = 66
  }
}
