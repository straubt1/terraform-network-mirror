locals {
  aws_region       = "us-west-1"
  s3_bucket_name   = "tstraub-network-mirror"
  mirror_directory = "../mirror"

  tags = {
    owner = "straub"
    acl   = "public-read"
  }
}

provider "aws" {
  region = local.aws_region
}

resource "aws_s3_bucket" "mirror" {
  bucket = local.s3_bucket_name
  acl    = "public-read"
  tags   = local.tags
}

resource "aws_s3_bucket_object" "mirror_objects" {
  for_each = fileset(local.mirror_directory, "**")

  bucket        = aws_s3_bucket.mirror.id
  key           = each.key
  source        = format("%s/%s", local.mirror_directory, each.value)
  force_destroy = true
  acl           = "public-read"

  # Hacky way to check for .json to set content type (JSON files MUST have this set)
  content_type = replace(each.value, ".json", "") != each.value ? "application/json" : ""

  # Set etag to pick up changes to files
  etag = filemd5(format("%s/%s", local.mirror_directory, each.value))
}

output "terraform-mirror-url" {
  value = format("https://%s/", aws_s3_bucket.mirror.bucket_domain_name)
}
