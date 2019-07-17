data "aws_ami" "opszero_eks" {
  most_recent = true

  filter {
    name   = "name"
    values = ["opszero-eks-*"]
  }

  owners = ["self"]
}

data "aws_ami" "foxpass_vpn" {

  most_recent = true

  filter {
    name   = "name"
    values = ["foxpass-ipsec-vpn *"]
  }
  owners = ["679593333241"]
}
