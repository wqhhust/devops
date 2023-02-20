provider "aws" {
  region = "us-east-2"
}


resource "aws_eks_cluster" "example" {
  # required
  name     = "example"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = aws_subnet.example[*].id
  }

  # optional

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy
  ]
}

data "aws_vpc" "selected" {
}

output "endpoint" {
  value = aws_eks_cluster.example.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.example.certificate_authority[0].data
}

output "vpc" {
  value = data.aws_vpc.selected
}
