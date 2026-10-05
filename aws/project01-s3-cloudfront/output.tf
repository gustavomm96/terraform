# S3 website
output "s3_name_website" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.site.bucket_domain_name
}
# S3 replica
output "s3_name_website_replica" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.site_replica.bucket_domain_name
}

# Cloud front URL
output "cf_url" {
  description = "URL de acesso do Cloud Front"
  value       = aws_cloudfront_distribution.cf_site.domain_name
}
