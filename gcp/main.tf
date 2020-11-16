locals {
  region           = "us-central1"
  project          = "tom-straub-tfe"
  credentials      = "/Users/tstraub/.gcp/tom-straub-tfe.json"
  bucket_name      = "tstraub-network-mirror"
  mirror_directory = "../mirror"

  tags = {
    owner = "straub"
    acl   = "public-storage.objectViewer"
  }
}

provider "google" {
  version     = "~> 3.0"
  credentials = file(local.credentials)
  region      = local.region
  project     = local.project
}

resource "google_storage_bucket" "mirror" {
  name          = local.bucket_name
  location      = local.region
  force_destroy = true # for debugging
  labels        = local.tags
}

# Make sure all objects are public - you can lock this down
resource "google_storage_bucket_iam_member" "mirror-public" {
  bucket = google_storage_bucket.mirror.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_object" "mirror_objects" {
  for_each = fileset(local.mirror_directory, "**")

  bucket = google_storage_bucket.mirror.name
  name   = each.key
  source = format("%s/%s", local.mirror_directory, each.value)

  # Hacky way to check for .json to set content type (JSON files MUST have this set)
  content_type = replace(each.value, ".json", "") != each.value ? "application/json" : ""
}

output "terraform-mirror-url" {
  value = format("https://storage.googleapis.com/%s/", google_storage_bucket.mirror.name)
}
