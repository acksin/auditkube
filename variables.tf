variable "environment_name" {
  type        = string
  description = "Name of the environment to create AWS resources"
}

variable "cluster_version" {
  default     = "1.30"
  description = "Desired Kubernetes master version"
}

variable "cluster_authentication_mode" {
  default     = "API"
  description = "Desired Kubernetes authentication. API or API_AND_CONFIG_MAP"

}

variable "cloudwatch_retention_in_days" {
  default     = 30
  description = "How long to keep CloudWatch logs in days"
}

variable "cloudwatch_pod_logs_enabled" {
  default     = false
  type        = bool
  description = "Stream EKS pod logs to cloudwatch"
}

variable "aws_load_balancer_controller_enabled" {
  default     = true
  description = "Enable ALB controller by default"
}

variable "cluster_encryption_config" {
  type        = list(any)
  default     = ["secrets"]
  description = "Cluster Encryption Config Resources to encrypt, e.g. ['secrets']"
}

variable "cluster_kms_policy" {
  type        = string
  default     = null
  description = "Cluster Encryption Config KMS Key Resource argument - key policy"
}

variable "cluster_logging" {
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]
  description = " List of the desired control plane logging to enable. https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html"
}

variable "cluster_private_access" {
  default     = true
  description = "Whether the Amazon EKS private API server endpoint is enabled"
}

variable "cluster_public_access" {
  default     = true
  description = "Whether the Amazon EKS private API server endpoint is enabled"
}

variable "cluster_public_access_cidrs" {
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks. Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled"
}

variable "cidr_block" {
  description = "The CIDR block used by the VPC"
  default     = "10.2.0.0/16"
}

variable "cidr_block_public_subnet" {
  description = "The CIDR block used by the private subnet"
  default = [
    "10.2.0.0/24",
    "10.2.1.0/24"
  ]
}

variable "cidr_block_private_subnet" {
  description = "The CIDR block used by the private subnet"
  default = [
    "10.2.2.0/24",
    "10.2.3.0/24"
  ]
}

variable "enable_ipv6" {
  default     = false
  description = "Enable an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC"
}

variable "nat_enabled" {
  default     = true
  description = "Whether the NAT gateway is enabled"
}

variable "enable_egress_only_internet_gateway" {
  default     = false
  description = "Create an egress-only Internet gateway for your VPC0"
}

variable "zones" {
  default     = ["us-west-2a", "us-west-2b"]
  description = "AZs for the subnets"
}

variable "eips" {
  default     = []
  description = "List of Elastic IPs"
}

variable "iam_users" {
  default     = []
  description = "List of IAM users"
}

variable "redis_enabled" {
  default     = false
  description = "Whether the redis cluster is enabled"
}

variable "redis_node_type" {
  default     = "cache.t4g.micro"
  description = "Instance class of the redis cluster to be used"
}

variable "redis_engine_version" {
  default     = "7.1"
  description = "Version number of the cache engine to be used for the cache clusters in this replication group"
}

variable "redis_num_nodes" {
  default     = 1
  description = "Number of nodes for redis"
}

variable "sql_cluster_enabled" {
  default     = false
  description = "Whether the sql cluster is enabled"
}

variable "sql_iam_auth_enabled" {
  default     = true
  description = "Specifies whether or not mappings of IAM accounts to database accounts is enabled"
}

variable "sql_rds_multi_az" {
  default     = false
  description = "Specify if the RDS instance is enabled multi-AZ"
}

variable "sql_engine" {
  default     = "aurora-postgresql"
  description = "The name of the database engine to be used for this DB cluster"
}

variable "sql_engine_mode" {
  default     = "provisioned"
  description = "The database engine mode"
}

variable "sql_node_count" {
  default     = 0
  description = "The number of instances to be used for this DB cluster"
}

variable "sql_instance_class" {
  default     = "db.t4g.micro"
  description = "The instance type of the RDS instance."
}

variable "sql_database_name" {
  default     = ""
  description = "The name of the database to create when the DB instance is created"
}

variable "sql_master_username" {
  default     = ""
  description = "Username for the master DB user"
}

variable "sql_master_password" {
  default     = ""
  description = "Password for the master DB user"
}

variable "sql_skip_final_snapshot" {
  default     = false
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
}

variable "sql_serverless_seconds_until_auto_pause" {
  default     = 300
  description = "The time, in seconds, before the DB cluster in serverless mode is paused"
}

variable "sql_instance_enabled" {
  default     = false
  description = "Whether the sql instance is enabled"
}

variable "sql_instance_engine" {
  default     = "postgres"
  description = "The database engine to use"
}

variable "sql_subnet_group_include_public" {
  description = "Include public subnets as part of the clusters subnet configuration."
  default     = false
}

variable "sql_instance_allocated_storage" {
  default     = 20
  description = "The allocated storage in gibibytes"
}

variable "sql_storage_type" {
  default     = "gp3"
  description = "The allocated storage type for DB Instance"
}

variable "sql_instance_max_allocated_storage" {
  default     = 200
  description = "the upper limit to which Amazon RDS can automatically scale the storage of the DB instance"
}

variable "sql_engine_version" {
  default     = "15.3"
  description = "The SQL engine version to use"
}

variable "sql_encrypted" {
  default     = true
  description = "Specify whether the DB instance is encrypted"
}

variable "sql_identifier" {
  description = "The name of the database"
  default     = ""
}

variable "sql_parameter_group_name" {
  default     = ""
  description = "Name of the DB parameter group to associate"
}

variable "sql_performance_insights_enabled" {
  default     = false
  description = " Specifies whether Performance Insights are enabled. Defaults to false"
}

variable "sql_cluster_monitoring_role_arn" {
  default     = null
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
}

variable "sql_cluster_monitoring_interval" {
  default     = null
  description = "Monitoring Interval for SQL Cluster"
}

variable "vpc_flow_logs_enabled" {
  default     = false
  description = "Specify whether the vpc flow log is enabled"
}

variable "efs_enabled" {
  default     = false
  description = "Specify whether the EFS is enabled on the EKS cluster"
}

variable "iam_roles" {
  default = {
    #   "arn:${local.partition}:iam::12345:role/AWSReservedSSO_AD-EKS-Admins_b2abd90bad1696ac" = {
    #     rbac_groups = [
    #       "system:masters"
    #     }
    #   }
  }
  description = "Terraform object of the IAM roles"
}

variable "node_role_policies" {
  default     = []
  description = "A list of The ARN of the policies you want to attach"
}

variable "fargate_selector" {
  default = {
    serverless = {
      // role_arn =
    },
  }
  description = "Terraform object to create the EKS fargate profiles"
}

variable "metrics_server_version" {
  default     = "3.11.0"
  description = "The version of the metric server helm chart"
}

variable "asg_nodes" {
  description = "Map of ASG node configurations"
  type = map(object({
    instance_type          = string
    max_instance_lifetime  = number
    nodes_desired_capacity = number
    nodes_max_size         = number
    nodes_min_size         = number
    nodes_in_public_subnet = bool
    node_disk_size         = number
    node_enabled_metrics   = list(string)
    spot_price             = string
    subnet_ids             = list(string)
  }))
  default = {
    #   nodegreen = {
    #     instance_type           = "t2.micro"
    #     max_instance_lifetime   = 7200
    #     nodes_desired_capacity  = 2
    #     nodes_max_size          = 3
    #     nodes_min_size          = 1
    #     nodes_in_public_subnet  = true
    #     node_disk_size          = 20
    #     node_enabled_metrics    = [
    #       "GroupDesiredCapacity",
    #       "GroupInServiceCapacity",
    #       "GroupInServiceInstances",
    #       "GroupMaxSize",
    #       "GroupMinSize",
    #       "GroupPendingCapacity",
    #       "GroupPendingInstances",
    #       "GroupStandbyCapacity",
    #       "GroupStandbyInstances",
    #       "GroupTerminatingCapacity",
    #       "GroupTerminatingInstances",
    #       "GroupTotalCapacity",
    #       "GroupTotalInstances"
    #     ]
    #     spot_price              = "0.05"
    #     subnet_ids              = []
    #   }
  }
}

variable "node_groups" {
  description = "Terraform object to create the EKS node groups"
  default = {
    # "t2.micro" = {
    #   instance_types        = ["t2.micro"],
    #   capacity_type         = "ON_DEMAND"
    #   nodes_in_public_subnet = false,
    #   subnet_ids = [],
    #   node_disk_size        = 20,
    #   node_desired_capacity = 1,
    #   nodes_max_size        = 1,
    #   nodes_min_size        = 1
    #
    # },
    # "t3.small" = {
    #   instance_types        = ["t3.small"],
    #   capacity_type         = "SPOT"
    #   nodes_in_public_subnet = true,
    #   node_disk_size        = 20,
    #   node_desired_capacity = 1,
    #   nodes_max_size        = 1,
    #   nodes_min_size        = 1
    # },

  }
}

variable "node_group_cpu_threshold" {
  default     = "70"
  description = "The value of the CPU threshold"
}

variable "karpenter_enabled" {
  default     = false
  description = "Specify whether the karpenter is enabled"
}

variable "karpenter_version" {
  default     = "1.0.1"
  description = "The version of the karpenter helm chart"
}

variable "karpenter_ami_family" {
  description = "AMI family to use for the EC2 Node Class. Possible values: AL2 or Bottlerocket"
  type        = string
  default     = "Bottlerocket"
}

variable "csi_secrets_store_enabled" {
  default     = false
  description = "Specify whether the CSI driver is enabled on the EKS cluster"
}

variable "csi_enabled_namespaces" {
  type    = list(string)
  default = []
}

variable "csi_secrets_store_version" {
  default     = "1.4.6"
  description = "The version of the CSI store helm chart"
}

variable "tags" {
  description = "Terraform map to create custom tags for the AWS resources"
  default     = {}
}

variable "alb_controller_version" {
  type        = string
  description = "The chart version of the ALB controller helm chart"
  default     = "1.4.4"
}

variable "calico_enabled" {
  type        = bool
  description = "Whether calico add-on is installed"
  default     = false
}

variable "calico_version" {
  default     = "v3.26.1"
  description = "The version of the calico helm chart"
}


# aws --profile opszero eks list-access-policies
variable "access_policies" {
  # [
  #   {
  #     principal_arn = "arn:aws:iam::111111111111:role/github-deployer"
  #     policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  #     access_scope_type = {
  #       type = "cluster"
  #     }
  #   }
  # ]
  description = "access policies"
  default     = []
}

variable "s3_csi_driver_enabled" {
  description = "Enable or disable the S3 CSI driver"
  type        = bool
  default     = false
}

variable "s3_csi_bucket_names" {
  description = "The name of the S3 bucket for the CSI driver"
  type        = list(string)
  default     = [""]
}

variable "karpenter_metadata_options" {
  description = "Metadata options for the EC2NodeClass"
  default = {
    httpEndpoint            = "enabled"
    httpProtocolIPv6        = "disabled"
    httpPutResponseHopLimit = 5
    httpTokens              = "required"
  }
}

variable "karpenter_block_device_mappings" {
  description = "Block device mappings for the EC2NodeClass"
  default = [
    {
      deviceName = "/dev/xvda"
      ebs = {
        volumeSize = "20Gi"
        volumeType = "gp3"
        encrypted  = true
      }
    },
    {
      deviceName = "/dev/xvdb"
      ebs = {
        volumeSize = "50Gi"
        volumeType = "gp3"
        encrypted  = true
      }
    }
  ]
}

variable "karpenter_ami_selector_terms" {
  description = "AMI selector terms for the EC2NodeClass"
  default = [
    { alias = "bottlerocket@latest" }
  ]
}

variable "eks_auto_mode_enabled" {
  description = "Enable Auto Mode for EKS cluster"
  type        = bool
  default     = true
}