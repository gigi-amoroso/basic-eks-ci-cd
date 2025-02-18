variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "wordpress_namespace" {

}

variable "aws_region" {
  default = "us-east-1"
}