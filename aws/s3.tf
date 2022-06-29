resource "aws_s3_bucket" "mlflow_s3" {
  bucket = var.s3_bucketname
}

resource "aws_s3_bucket_acl" "mlflow_s3" {
   bucket = aws_s3_bucket.mlflow_s3.id
   acl = "private"
}

resource "aws_s3_object" "object1" {
  for_each = fileset("uploads/", "*")
  bucket = aws_s3_bucket.mlflow_s3.id
  key = each.value
  source = "uploads/${each.value}"
}

resource "aws_s3_bucket_public_access_block" "app" {
bucket = aws_s3_bucket.mlflow_s3.id
block_public_acls       = var.s3_block_public_acls
block_public_policy     = var.s3_block_public_policy
ignore_public_acls      = var.s3_ignore_public_acls
restrict_public_buckets = var.s3_restrict_public_buckets
}