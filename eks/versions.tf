
terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"

    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.2"
    }
  }
}
