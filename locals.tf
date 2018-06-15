# Generate a random id name to use in resource names
resource "random_string" "random" {
  length  = "8"
  special = false
  upper   = false
}

locals {
  create_service_account = "${length(var.google_service_account_email) == 0 ? 1 : 0}"
  vault_resource_name    = "vault-${random_string.random.result}"
}
