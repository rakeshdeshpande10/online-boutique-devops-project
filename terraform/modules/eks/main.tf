resource "aws_iam_role" "eks_cluster_role" {
    name ="eks-cluster-role"

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
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_group_role" {
    name = "eks-node-group-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read_only_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_kms_key" "eks_secrets" {
    description             = "KMS key for EKS cluster"
}

resource "aws_eks_cluster" "eks_cluster" {
    name     = var.cluster_name
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        subnet_ids = var.cluster_subnet_ids
    }

    encryption_config {
        provider {
            key_arn = aws_kms_key.eks_secrets.arn
        }
        resources = ["secrets"]
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster_policy_attachment
    ]
}

resource "aws_eks_node_group" "eks_node_group" {
    cluster_name    = aws_eks_cluster.eks_cluster.name
    node_group_name = "eks-node-group"
    node_role_arn   = aws_iam_role.eks_node_group_role.arn
    subnet_ids      = var.node_subnet_ids
    instance_types  = var.node_instance_types

    scaling_config {
        desired_size = 2
        max_size     = 3
        min_size     = 1
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks_worker_node_policy_attachment,
        aws_iam_role_policy_attachment.eks_cni_policy_attachment,
        aws_iam_role_policy_attachment.eks_ecr_read_only_policy_attachment
    ]
}

