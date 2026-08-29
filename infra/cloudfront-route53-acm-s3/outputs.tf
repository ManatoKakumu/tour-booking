output "image_bucket_arn" {
  value = aws_s3_bucket.image_bucket.arn
}

output "alb_certificate_arn" {
  value = aws_acm_certificate.alb.arn
}
