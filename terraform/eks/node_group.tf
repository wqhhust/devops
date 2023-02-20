resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.example[*].id
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # optional
  instance_types  = ["t2.micro"]
  node_group_name = "example"

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}
