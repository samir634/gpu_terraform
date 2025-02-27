provider "aws" {
  region = var.aws_region
}

data "aws_ami" "eks_gpu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-*x86_64-nvidia-*"] 
  }
}

# Create IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

# Create IAM Role for GPU Nodes
resource "aws_iam_role" "gpu_node_role" {
  name = "${var.cluster_name}-gpu-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "gpu_nodes_policy_eks" {
  role       = aws_iam_role.gpu_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "gpu_nodes_policy_ec2" {
  role       = aws_iam_role.gpu_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "gpu_nodes_cni_policy" {
  role       = aws_iam_role.gpu_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.gpu_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_launch_template" "gpu_lt" {
  name_prefix   = "${var.cluster_name}-gpu-lt"
  image_id      = data.aws_ami.eks_gpu.id # Fetches the latest GPU-enabled AMI
  instance_type = var.gpu_instance_type

  # User Data Script (Base64 Encoded)
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Running startup script" > /var/log/user_data.log
    yum update -y
    yum install -y nvidia-driver-525 cuda
    nvidia-smi > /var/log/nvidia-check.log
    echo "Startup complete" >> /var/log/user_data.log
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-gpu-node"
    }
  }
}


# Create GPU Node Group
resource "aws_eks_node_group" "gpu_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-gpu-nodes"
  node_role_arn   = aws_iam_role.gpu_node_role.arn
  subnet_ids      = var.subnet_ids

  # Attach the launch template
  launch_template {
    id      = aws_launch_template.gpu_lt.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.node_count
    min_size     = 1
    max_size     = var.max_node_count
  }

  ami_type       = "AL2_x86_64_GPU"
  capacity_type  = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.gpu_nodes_policy_eks,
    aws_iam_role_policy_attachment.gpu_nodes_policy_ec2,
    aws_iam_role_policy_attachment.gpu_nodes_cni_policy
  ]
}

