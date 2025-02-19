locals {
  environments = {
    dev = {
      db_name   = "wordpress1dev"
      s3_suffix = "dev"
      namespace = "wordpress-dev"
    },
    prod = {
      db_name   = "wordpress1prod"
      s3_suffix = "prod"
      namespace = "wordpress-prod"
    }
  }

  rds_resource_ids = { for env, mod in module.rds : env => mod.rds_resource_id }
  rds_addresses    = { for env, mod in module.rds : env => mod.rds_addresses }
  s3_bucket_names  = { for env, mod in module.s3 : env => mod.bucket_name }
}
