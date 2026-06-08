output "bucket_name" { value = aws_s3_bucket.frontend.id }
output "website_url" { value = aws_s3_bucket_website_configuration.frontend.website_endpoint }
output "cdn_domain"  { value = var.enable_cdn ? aws_cloudfront_distribution.cdn[0].domain_name : "" }
