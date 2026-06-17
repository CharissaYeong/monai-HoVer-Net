module "data_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 4.0"

  name = "${var.project}-data-table"

  billing_mode = "PAY_PER_REQUEST"

  hash_key = "image_id"

  attributes = [
    {
      name = "image_id"
      type = "S"
    }
  ]

  server_side_encryption_enabled = true

  tags = {
    Deployment = "Database"
  }
}