variable "rds_addresses" {
  description = "Map of RDS addresses"
  type        = map(string)
}

variable "db_username" {
  description = "Database username (same for both envs)"
  type        = string
  default     = "admin"
}

variable "dev_db_name" {
  description = "Database dev_db_name"
  type        = string
}

variable "prod_db_name" {
  description = "Database prod_db_name"
  type        = string
}

variable "domain_name" {  
}

variable "service_account_dev_word" {
}

variable "service_account_prod_word" {
}

variable "argocd_release_id" {
  description = "ID of the ArgoCD release to depend on"
  type        = string
}