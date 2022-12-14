### Creation of IAM Role for Cluster ###

resource "aws_iam_role" "eks-cluster" {
  name = "eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [ "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
                          "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
                          "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
                          "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
                          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecr-access",
                          "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  tags = {
    Terraform   = "true"
    Environment = var.aws_environment
  }
}

### ECR Access Policy

resource "aws_iam_policy" "ecr-access" {
  name        = "ecr-access"
  path        = "/"
  description = "allows access to ecr for eks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

### instance profile for karpenter ###

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = var.eks_node_group_iam_role
}