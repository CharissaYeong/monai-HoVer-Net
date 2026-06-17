output "s3_bucket_id" {
  description = "The name of the S3 bucket created for image uploads"
  value       = module.images_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket (useful for IAM role configuration)"
  value       = module.images_bucket.s3_bucket_arn
}