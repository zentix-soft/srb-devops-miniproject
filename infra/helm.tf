provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.auth.token
  }
}

data "aws_eks_cluster_auth" "auth" {
  name = module.eks.cluster_name
}

# if vault in EKS
resource "helm_release" "vault" {
  name       = "vault"
  namespace  = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.27.0"

  values = [
    file("${path.module}/helm-values/vault-values.yaml")
  ]
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.34.0"

  values = [
    file("${path.module}/helm-values/karpenter-values.yaml")
  ]
}

resource "helm_release" "fluentbit" {
  name       = "fluent-bit"
  namespace  = "logging"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.46.8"

  values = [
    file("${path.module}/helm-values/fluentbit-values.yaml")
  ]
}

resource "helm_release" "prometheus" {
  name       = "kube-prometheus-stack"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.2"

  values = [
    file("${path.module}/helm-values/prometheus-values.yaml")
  ]
}

resource "helm_release" "redis" {
  name       = "redis"
  namespace  = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "19.4.3"

  create_namespace = true

  values = [
    file("${path.module}/../helm-values/redis-values.yaml")
  ]

  set {
    name  = "auth.password"
    value = var.redis_password
  }
}

variable "redis_password" {
  description = "Redis password for ElastiCache or Bitnami Redis chart"
  type        = string
  sensitive   = true
}