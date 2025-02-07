variable "domain_name" {
  description = "Base domain name for the ACM certificate"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID used for DNS validation"
  type        = string
}
