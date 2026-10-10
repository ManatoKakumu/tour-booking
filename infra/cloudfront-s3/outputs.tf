output "image_bucket_arn" {
  value = aws_s3_bucket.image_bucket.arn
}

output "image_bucket_name" {
  value = aws_s3_bucket.image_bucket.bucket
}
