#Create base zone for DNS
resource "aws_route53_zone" "primary" {
  name = "io.mattjensen.org"
}

#Create record for ALB
resource "aws_route53_record" "quest" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "quest.io.mattjensen.org"
  type    = "A"

  alias {
    name = aws_lb.quest.dns_name
    zone_id = aws_lb.quest.zone_id
    evaluate_target_health = true
  }
}

#Create SSL Certificate
resource "aws_acm_certificate" "quest" {
  domain_name = "io.mattjensen.org"
  subject_alternative_names = ["quest.io.mattjensen.org", "io.mattjensen.org"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#Create DNS records for SSL DNS Verification
resource "aws_route53_record" "dvo" {
  for_each = {
    for dvo in aws_acm_certificate.quest.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.primary.zone_id
}

#Map certificates and validation
resource "aws_acm_certificate_validation" "quest" {
  certificate_arn         = aws_acm_certificate.quest.arn
  validation_record_fqdns = [for record in aws_route53_record.dvo : record.fqdn]
}