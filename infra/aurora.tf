provider "vault" {
  address = "https://<your-vault-address>"
  token   = var.vault_token  # Ideally, use a more secure method like Vault Agent or environment variables
}

data "vault_kv_secret_v2" "aurora_postgres" {
  name = "aurora/postgres"
  mount = abspath()
}

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  name    = "soraban-db"
  engine  = "aurora-postgresql"
  engine_mode = "provisioned"

  master_username = data.vault_kv_secret_v2.aurora_postgres.data["username"]
  master_password = data.vault_kv_secret_v2.aurora_postgres.data["password"]

  instances = {
    writer = {
      instance_class = "db.serverless"
    }
    reader1 = {
      instance_class = "db.serverless"
    }
  }

  vpc_id                 = module.vpc.vpc_id
  db_subnet_group_name   = module.vpc.database_subnet_group

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 4.0
  }

  storage_encrypted = true

  tags = {
    Project = "soraban"
  }
}