resource "aws_iam_role" "node" {
  name = "${var.environment_name}-node"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:${local.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:${local.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:${local.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_role_policies" {
  count      = length(var.node_role_policies)
  policy_arn = var.node_role_policies[count.index]
  role       = aws_iam_role.node.name
}


resource "aws_iam_policy" "eks_pod_logs_to_cloudwatch" {
  count       = var.cloudwatch_pod_logs_enabled ? 1 : 0
  name        = "${var.environment_name}-EksPodLogsToCloudwatch"
  description = "Used by fluentbit agent to send eks pods logs to cloudwatch"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "node_eks_pod_logs_to_cloudwatch" {
  count      = var.cloudwatch_pod_logs_enabled ? 1 : 0
  policy_arn = aws_iam_policy.eks_pod_logs_to_cloudwatch[count.index].arn
  role       = aws_iam_role.node.name
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.environment_name}-node"
  role = aws_iam_role.node.name
  tags = local.tags
}

resource "aws_iam_role" "eks_auto" {
  count = var.eks_auto_mode_enabled ? 1 : 0
  name  = "${var.environment_name}-eks-auto-mode-node"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "EKSAutoNodeAssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : [
          "sts:TagSession",
          "sts:AssumeRole"
        ]
      }
    ]
  })

  tags = local.tags
}

locals {
  iam_role_policy_prefix = "arn:${local.partition}:iam::aws:policy"
  # EKS cluster with EKS auto mode enabled
  eks_auto_mode_iam_role_policies = { for k, v in {
    AmazonEKSClusterPolicy       = "${local.iam_role_policy_prefix}/AmazonEKSClusterPolicy"
    AmazonEKSComputePolicy       = "${local.iam_role_policy_prefix}/AmazonEKSComputePolicy"
    AmazonEKSBlockStoragePolicy  = "${local.iam_role_policy_prefix}/AmazonEKSBlockStoragePolicy"
    AmazonEKSLoadBalancingPolicy = "${local.iam_role_policy_prefix}/AmazonEKSLoadBalancingPolicy"
    AmazonEKSNetworkingPolicy    = "${local.iam_role_policy_prefix}/AmazonEKSNetworkingPolicy"
  } : k => v if var.eks_auto_mode_enabled }
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in {
    AmazonEKSWorkerNodeMinimalPolicy   = "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodeMinimalPolicy",
    AmazonEC2ContainerRegistryPullOnly = "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryPullOnly",
  } : k => v if var.eks_auto_mode_enabled }

  policy_arn = each.value
  role       = aws_iam_role.eks_auto[0].name
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = { for k, v in merge(
    local.eks_auto_mode_iam_role_policies,
  ) : k => v if var.eks_auto_mode_enabled }

  policy_arn = each.value
  role       = aws_iam_role.cluster.name
}

data "aws_iam_policy_document" "custom" {
  count = var.eks_auto_mode_enabled ? 1 : 0

  dynamic "statement" {
    for_each = var.eks_auto_mode_enabled ? [1] : []

    content {
      sid = "Compute"
      actions = [
        "ec2:CreateFleet",
        "ec2:RunInstances",
        "ec2:CreateLaunchTemplate",
      ]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }

      condition {
        test     = "StringLike"
        variable = "aws:RequestTag/eks:kubernetes-node-class-name"
        values   = ["*"]
      }

      condition {
        test     = "StringLike"
        variable = "aws:RequestTag/eks:kubernetes-node-pool-name"
        values   = ["*"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.eks_auto_mode_enabled ? [1] : []

    content {
      sid = "Storage"
      actions = [
        "ec2:CreateVolume",
        "ec2:CreateSnapshot",
      ]
      resources = [
        "arn:${local.partition}:ec2:*:*:volume/*",
        "arn:${local.partition}:ec2:*:*:snapshot/*",
      ]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.eks_auto_mode_enabled ? [1] : []

    content {
      sid       = "Networking"
      actions   = ["ec2:CreateNetworkInterface"]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:kubernetes-cni-node-name"
        values   = ["*"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.eks_auto_mode_enabled ? [1] : []

    content {
      sid = "LoadBalancer"
      actions = [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateRule",
        "ec2:CreateSecurityGroup",
      ]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.eks_auto_mode_enabled ? [1] : []

    content {
      sid       = "ShieldProtection"
      actions   = ["shield:CreateProtection"]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.eks_auto_mode_enabled ? [1] : []

    content {
      sid       = "ShieldTagResource"
      actions   = ["shield:TagResource"]
      resources = ["arn:${local.partition}:shield::*:protection/*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }
}

resource "aws_iam_policy" "custom" {
  count = var.eks_auto_mode_enabled ? 1 : 0

  name   = "${var.environment_name}-eks-auto-mode-cluster"
  policy = data.aws_iam_policy_document.custom[0].json

}

resource "aws_iam_role_policy_attachment" "custom" {
  count = var.eks_auto_mode_enabled ? 1 : 0

  policy_arn = aws_iam_policy.custom[0].arn
  role       = aws_iam_role.cluster.name
}