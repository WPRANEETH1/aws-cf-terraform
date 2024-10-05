output "cloudfront_url" {
  description = "The URL of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website_distribution.domain_name
}