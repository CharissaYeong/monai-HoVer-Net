module "images_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.0"

  bucket = "${var.project}-storage"

  lifecycle_rule = [
    {
      id      = "archive-old-images"
      enabled = true

      transition = [
        {
          days          = var.glacier_transition_days
          storage_class = "GLACIER"
        }
      ]

      abort_incomplete_multipart_upload_days = 7
    }
  ]

  versioning = {
    enabled = true
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}