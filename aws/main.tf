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

# Make sure all objects are public, Demo only - you can lock this down if you like
resource "aws_s3_bucket" "mirror" {
  bucket = local.s3_bucket_name
  acl    = "public-read"
  tags   = local.tags
}

# Loop through the mirror directory and upload it as-is to the bucket
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

# Output the url needed in the Terraform CLI config
output "terraform-mirror-url" {
  value = format("https://%s/", aws_s3_bucket.mirror.bucket_domain_name)
}
