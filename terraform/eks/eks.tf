provider "aws" {
  region = "us-east-2"
}

resource "aws_eks_cluster" "cluster" {
  # required
  name     = var.eks_cluster_name
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

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}
