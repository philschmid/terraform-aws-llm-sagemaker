terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.1.0" # Ensure this is the latest version
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.60.0"
    }
  }
}
