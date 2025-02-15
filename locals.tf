locals {
    environments = {
      dev = {
        db_name   = "wordpress1dev"
        s3_suffix = "dev"
      },
      prod = {
        db_name   = "wordpress1prod"
        s3_suffix = "prod"
      }
    }
  }

locals {
  rds_resource_ids = { for env, mod in module.rds : env => mod.rds_resource_id }
}
