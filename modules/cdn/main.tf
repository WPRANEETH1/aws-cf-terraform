resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "bucket_object" {
  bucket       = aws_s3_bucket.website_bucket.bucket
  key          = "index.html"
  source       = "./modules/cdn/index.html"
  acl          = "private"
  content_type = "text/html"

  tags = merge(
    {
      Name = join("-", [var.bucket_name]),
    },
    var.tags
  )
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access to the S3 bucket via CloudFront"
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.website_bucket.arn}/*",
        Principal = {
          AWS = "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"
        }
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website_bucket.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = var.dns_name # NLB DNS name
    origin_id   = "nlb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # Only allow HTTP traffic
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website_bucket.bucket

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*" # Example: Traffic to /api/* goes to NLB
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "nlb-origin"

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "allow-all" # Allow HTTP and HTTPS traffic from the viewer
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(
    {
      Name = "website-cloudfront-distribution"
    },
    var.tags
  )
}
