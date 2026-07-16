terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Create S3 Bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = "sanket-devops-resume-bucket-2026"
  force_destroy = true
}

# 2. Configure public access settings (The correct singular 'block_public_policy')
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 3. Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# 4. Apply S3 Bucket Policy to allow public reading of index.html
resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

# 5. Upload index.html to S3 automatically
resource "aws_s3_object" "upload_index" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

# 6. Output the S3 Website URL to the console
output "website_url" {
  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint
  description = "Access your live DevOps resume here!"
}