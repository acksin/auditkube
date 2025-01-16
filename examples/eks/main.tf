provider "aws" {
  # TODO: Change this
  profile = "opszero"
  # TODO: Change this
  region = "us-west-2"
}

locals {
  environment_name = "appcensus-dev"
  profile          = "appcensus-staging"
}

provider "aws" {
  profile = local.profile
  region  = "us-east-1"
}

provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
  }
}

provider "kubernetes" {
  config_path = "./kubeconfig"
}



module "opszero-eks" {
  source = "github.com/opszero/terraform-aws-kubespot"

  zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  cluster_version  = "1.31"
  environment_name = local.environment_name
  iam_users = {
    "abhi@opszero.com" = {
      rbac_groups = [
        "system:masters"
      ]
    },
    "bitbucket-deployer" = {
      rbac_groups = [
        "system:masters"
      ]
    },

  }
  cidr_block = "10.3.0.0/16"
  cidr_block_public_subnet = [
    "10.3.0.0/18",
    "10.3.64.0/18",
  ]
  cidr_block_private_subnet = [
    "10.3.128.0/18",
    "10.3.192.0/18",
  ]

  node_groups = {
    "t3a-medium-spot" = {
      # Have to use a custom launch template to get encrypted root volumes.
      instance_types = [
        "t3a.medium",
      ]
      capacity_type          = "SPOT"
      nodes_in_public_subnet = false
      node_desired_capacity  = 3,
      nodes_max_size         = 3,
      nodes_min_size         = 3
      ami_type               = "CUSTOM"
      node_disk_encrypted    = true
    },
    "t3a-medium-spot2" = {
      instance_types = [
        "t3a.medium",
      ]
      node_disk_size         = 32
      nodes_in_public_subnet = false
      node_desired_capacity  = 1,
      nodes_max_size         = 1,
      nodes_min_size         = 1
      node_disk_encrypted    = true
    }
  }

  redis_enabled        = false
  sql_cluster_enabled  = false
  sql_instance_enabled = false

  nat_enabled           = true
  vpc_flow_logs_enabled = false
  efs_enabled           = false
  #csi
  s3_csi_driver_enabled = false
  s3_csi_bucket_names   = ["test-6647373dd"] #name of s3
}

module "helm-common" {
  source             = "github.com/opszero/terraform-helm-kubespot"
  cert_manager_email = "ops@opszero.com"

  nginx_min_replicas = 1
  nginx_max_replicas = 3
}

