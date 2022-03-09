data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
  count      = var.karpenter_enabled ? 1 : 0

  role       = aws_iam_role.node.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
}

resource "aws_iam_instance_profile" "karpenter" {
  count = var.karpenter_enabled ? 1 : 0

  name  = "KarpenterNodeInstanceProfile-${aws_eks_cluster.cluster.name}"
  role  = aws_iam_role.node.name
}

module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "karpenter-controller-${var.environment_name}"
  provider_url                  = replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")
  oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]
}

resource "aws_iam_role_policy" "karpenter_contoller" {
  name = "karpenter-policy-${var.environment_name}"
  role = module.iam_assumable_role_karpenter.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "iam:PassRole",
          "ec2:TerminateInstances",
          "ec2:DescribeLaunchTemplates",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "helm_release" "karpenter" {
  count            = var.karpenter_enabled ? 1 : 0

  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = var.karpenter_version

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_karpenter.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.name
  }

  set {
    name  = "clusterEndpoint"
    value = aws_eks_cluster.cluster.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter[0].name
  }
}

# data "template_file" "your_template" {
#   template = "${file("${path.module}/templates/<.yaml>")}"
# }

# resource "null_resource" "karpenter_crd" {
#   count            = var.karpenter_enabled ? 1 : 0

#   triggers = {
#     manifest_sha1 = "${sha1("${data.template_file.your_template.rendered}")}"
#   }

#   provisioner "local-exec" {
#     command = "kubectl create -f -<<EOF\n${data.template_file.your_template.rendered}\nEOF"
#   }

#   depends_on = [
#     helm_release.karpenter
#   ]
# }
