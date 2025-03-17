provider "aws"{
    region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state-19890101"
    key            = "workspaces-example/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}

resource "aws_s3_bucket" "terraform_state"{
    bucket = "terraform-up-and-running-state-19890101"
    lifecycle{
        prevent_destroy = true
    }
}

################# Enable versioning, encryption and public access block #################
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
}
################# Enable encryption #################
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
################# Enable public access block #################
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}
################# Dynamo DB Table #################
resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-up-and-running-locks_example"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
      name = "LockID"
      type = "S"
    }
}

