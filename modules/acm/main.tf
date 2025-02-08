resource "aws_acm_certificate" "certificate" {
  domain_name               = "*.${var.domain_name}"
  subject_alternative_names = [var.domain_name]
  validation_method         = "DNS"
  tags = {
    Name = var.domain_name
  }
}

data "aws_route53_zone" "selected" {
  zone_id = var.hosted_zone_id
} 

# We reference only the first element of the ACM certificate's domain_validation_options instead of using a for_each loop,
# because the computed set contains duplicate values (from both the wildcard and apex domains) and using for_each would
# force Terraform to attempt creating the same DNS record twice.

resource "aws_route53_record" "cert_validation" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  ttl     = 60
  records = [tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value]
  
  lifecycle {
    ignore_changes = [records]
  }
}



resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

output "certificate_arn" {
  value = aws_acm_certificate.certificate.arn
}
