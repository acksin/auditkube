# Terraform version
terraform {
  required_version = ">= 1.5.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.10.0, < 2.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0, < 3.0.0"
    }
  }
}