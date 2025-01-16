data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

module "karpenter" {
  count = var.karpenter_enabled ? 1 : 0

  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.31.4"

  cluster_name = var.environment_name

  enable_irsa                     = true
  irsa_oidc_provider_arn          = aws_iam_openid_connect_provider.cluster.arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  create_iam_role = true
  iam_role_name   = substr("${var.environment_name}-karpenter-controller", 0, 37)

  create_node_iam_role          = false
  node_iam_role_use_name_prefix = false
  node_iam_role_arn             = aws_iam_role.node.arn

  create_instance_profile = true
  create_access_entry     = false

  queue_name = "${var.environment_name}-spot-termination"

  tags = local.tags
}

resource "helm_release" "karpenter" {
  count = var.karpenter_enabled ? 1 : 0

  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version

  set {
    name  = "settings.clusterName"
    value = aws_eks_cluster.cluster.name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = aws_eks_cluster.cluster.endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter[0].iam_role_arn
  }

  depends_on = [
    helm_release.karpenter_crd
  ]
}

resource "helm_release" "karpenter_crd" {
  count = var.karpenter_enabled ? 1 : 0

  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter-crd"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter-crd"
  version    = var.karpenter_version
}

resource "kubectl_manifest" "karpenter_ec2_node_class" {
  count = var.karpenter_enabled ? 1 : 0

  yaml_body = <<EOT
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
spec:
  metadataOptions:
    httpEndpoint: ${var.karpenter_metadata_options.httpEndpoint}
    httpProtocolIPv6: ${var.karpenter_metadata_options.httpProtocolIPv6}
    httpPutResponseHopLimit: ${var.karpenter_metadata_options.httpPutResponseHopLimit}
    httpTokens: ${var.karpenter_metadata_options.httpTokens}
  blockDeviceMappings:
  %{for mapping in var.karpenter_block_device_mappings}
    - deviceName: ${mapping.deviceName}
      ebs:
        volumeSize: ${mapping.ebs.volumeSize}
        volumeType: ${mapping.ebs.volumeType}
        encrypted: ${mapping.ebs.encrypted}
  %{endfor}
  amiFamily: ${var.karpenter_ami_family}
  role: ${aws_iam_role.node.name}
  securityGroupSelectorTerms:
  - id: ${aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id}
  subnetSelectorTerms:
  - id: ${aws_subnet.public[0].id}
  - id: ${aws_subnet.public[1].id}
  amiSelectorTerms:
  %{for term in var.karpenter_ami_selector_terms}
    - alias: ${term.alias}
  %{endfor}
EOT

  depends_on = [
    aws_eks_cluster.cluster,
    helm_release.karpenter_crd,
    helm_release.karpenter
  ]
}