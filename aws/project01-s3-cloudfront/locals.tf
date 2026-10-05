locals {
  common_tags = {
    source = "terraform"
    owner  = "gustavo"
    type   = "project01-static-website"
  }
  s3_origin_id = "S3Origin"
}