resource "aws_s3_bucket" "wordpress_media" {
  bucket_prefix = var.bucket_name

  tags = {
    Environment = var.bucket_name
  }
    timeouts {
    create = "15m"
  }
}


resource "aws_s3_bucket_public_access_block" "wordpress_media_pab" {
  bucket = aws_s3_bucket.wordpress_media.bucket

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "wordpress_media_policy" {
  bucket = aws_s3_bucket.wordpress_media.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "PublicReadGetObject",
        Effect   = "Allow",
        Principal = "*",
        Action   = "s3:GetObject",
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.wordpress_media.bucket}/*"
        ]
      }
    ]
  })
}

output "bucket_name" {
  value = aws_s3_bucket.wordpress_media.bucket
}
