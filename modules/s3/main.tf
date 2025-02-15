resource "aws_s3_bucket" "wordpress_media" {
  bucket_prefix = var.bucket_name

  tags = {
    Environment = var.bucket_name
  }
    timeouts {
    create = "15m"
  }
}

output "bucket" {
  value = aws_s3_bucket.wordpress_media.bucket
}
