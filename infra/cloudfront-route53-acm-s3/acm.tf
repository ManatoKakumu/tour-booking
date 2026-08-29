resource "aws_acm_certificate" "cloudfront" {
  provider          = aws.us_east_1
  domain_name       = "sample-sample.jp"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "alb" {
  domain_name       = "sample-sample.jp"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
