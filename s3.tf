resource "random_id" "bucket_suffix" {
  byte_length = 4
  # random_id.bucket_suffix.hex = # random_id.bucket_suffix.hex
}

resource "aws_s3_bucket" "static_website" {
  bucket = "terraform-course-project-${random_id.bucket_suffix.hex}"

  force_destroy = true
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static_website_public_read" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadObjects",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

output "production_url" {
  value = "Your website is available at: http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}"
}

resource "aws_s3_object" "index_html" {
    bucket = aws_s3_bucket.static_website.id
    key    = "index.html"
    source = "${path.module}/build/index.html"
    etag   = filemd5("${path.module}/build/index.html")
    content_type = "text/html"
}

resource "aws_s3_object" "error_html" {
    bucket = aws_s3_bucket.static_website.id
    key    = "error.html"
    source = "${path.module}/build/error.html"
    etag   = filemd5("${path.module}/build/error.html")
    content_type = "text/html"
}