resource "aws_s3_bucket" "terraform_state" {
  bucket = "training-tfstate-slavakharchenko"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "Terraform state"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}