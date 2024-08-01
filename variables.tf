variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-west-2"
}

variable "model_name" {
  description = "Name of the SageMaker model"
  type        = string
  default     = "sample-model"
}

variable "model_image_uri" {
  description = "URI of the Docker image containing the model"
  type        = string
  default     = "763104351884.dkr.ecr.us-west-2.amazonaws.com/pytorch-inference:1.5.1-cpu-py3"
}

variable "endpoint_config_name" {
  description = "Name of the SageMaker endpoint configuration"
  type        = string
  default     = "sample-endpoint-config"
}

variable "endpoint_name" {
  description = "Name of the SageMaker endpoint"
  type        = string
  default     = "sample-endpoint"
}

variable "instance_count" {
  description = "Number of instances to launch for the endpoint"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Type of instance to launch for the endpoint"
  type        = string
  default     = "ml.t2.medium"
}
