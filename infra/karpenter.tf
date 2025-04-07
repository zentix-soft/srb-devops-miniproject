module "karpenter" {
  source = "terraform-aws-modules/karpenter/aws"

  cluster_name = module.eks.cluster_name
  irsa_name    = "karpenter-controller"
  subnet_ids   = module.vpc.private_subnets
  tags = {
    Project = "soraban"
  }
}