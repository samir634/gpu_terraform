provider "aws" {
  region = var.aws_region
}

module "eks_gpu" {
  source            = "../terraform_modules/eks_gpu"
  aws_region        = var.aws_region
  cluster_name      = var.cluster_name
  gpu_instance_type = var.gpu_instance_type
  node_count        = var.node_count
  subnet_ids        = var.subnet_ids
}
