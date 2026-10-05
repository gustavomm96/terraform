# Front Door 

# Configurando o origin
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "gm-s3-static-website-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4" # sigv4a = multi-region - sigv4 = regional
}

# Front Door configuration
resource "aws_cloudfront_distribution" "cf_site" {
  origin {
    domain_name              = aws_s3_bucket.site.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Static site - ${var.project_name}"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

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

  # Pode restrigir por pais que pode acessar, criar whitelist e blacklist
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  # Esta usando o certificado da aws
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  # Caso queira usar o certificado proprio bloco de exemplo  
  # viewer_certificate {
  #   acm_certificate_arn      = aws_acm_certificate.cert.arn
  #   ssl_support_method       = "sni-only"
  #   minimum_protocol_version = "TLSv1.2_2021"
  # }
  tags = merge(local.common_tags, {
    Name = "cf-gm-website"
  })
}

