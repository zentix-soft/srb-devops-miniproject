module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  name    = "soraban-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  target_groups = [
    {
      name_prefix      = "rails"
      backend_protocol = "HTTP"
      backend_port     = 3000
      target_type      = "ip"
    }
  ]

  security_groups = [aws_security_group.lb.id]

  tags = {
    Project = "soraban"
  }
}