resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for ${var.project_name} static site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  comment             = "Static site for ${var.project_name}"
  price_class         = var.price_class
  web_acl_id          = var.web_acl_id

  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_id                = "S3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  dynamic "origin" {
    for_each = var.alb_dns_name != null ? [1] : []
    content {
      domain_name = var.alb_dns_name
      origin_id   = var.alb_dns_name
      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
        ip_address_type        = "ipv4"
      }
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = var.min_ttl
    default_ttl = var.default_ttl
    max_ttl     = var.max_ttl
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.alb_dns_name != null ? [1] : []
    content {
      path_pattern             = var.api_path_pattern
      target_origin_id         = var.alb_dns_name
      allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods           = ["GET", "HEAD"]
      viewer_protocol_policy   = "redirect-to-https"
      compress                 = true
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"

    }
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = var.error_response_page
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = var.error_response_page
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.tags, { Name = "${var.project_name}-distribution" })
}

resource "aws_s3_bucket_policy" "static" {
  bucket = var.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${var.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}
