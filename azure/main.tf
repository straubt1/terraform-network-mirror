locals {
  region              = "centralus"
  resource_group_name = "tstraub-ptfe-binaries-rg"
  bucket_name         = "tstraubnetworkmirror"
  mirror_directory    = "../mirror"

  tags = {
    owner = "straub"
    acl   = "public-storage.objectViewer"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "mirror" {
  resource_group_name      = local.resource_group_name
  name                     = local.bucket_name
  location                 = local.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true

  tags = local.tags
}

resource "azurerm_storage_container" "mirror" {
  storage_account_name  = azurerm_storage_account.mirror.name
  name                  = "providers"
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "mirror_objects" {
  for_each               = fileset(local.mirror_directory, "**")
  storage_account_name   = azurerm_storage_account.mirror.name
  storage_container_name = azurerm_storage_container.mirror.name
  type                   = "Block"
  name                   = each.key
  source                 = format("%s/%s", local.mirror_directory, each.value)
  # Hacky way to check for .json to set content type (JSON files MUST have this set)
  content_type = replace(each.value, ".json", "") != each.value ? "application/json" : ""
}

output "terraform-mirror-url" {
  value = format("%s%s/", azurerm_storage_account.mirror.primary_blob_endpoint, azurerm_storage_container.mirror.name)
}
