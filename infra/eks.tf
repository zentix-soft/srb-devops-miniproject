module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "soraban-eks"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }

  fargate_profiles = {
    web = {
      selectors = [
        { namespace = "web" }
      ]
    }
    sidekiq = {
      selectors = [
        { namespace = "sidekiq" }
      ]
    }
  }


  tags = {
    Project = "soraban"
  }
}