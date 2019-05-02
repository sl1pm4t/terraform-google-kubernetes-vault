# Create the KMS key ring
resource "google_kms_key_ring" "vault" {
  name     = "${local.vault_resource_name}"
  location = "${var.google_region}"
  project  = "${var.google_project}"

  lifecycle {
    prevent_destroy = true
  }
}

# Create the crypto key for encrypting init keys
resource "google_kms_crypto_key" "vault_init" {
  name            = "vault-init"
  key_ring        = "${google_kms_key_ring.vault.id}"
  rotation_period = "604800s"

  lifecycle {
    prevent_destroy = true
  }
}

# Grant service account access to the key
resource "google_kms_crypto_key_iam_member" "vault_init" {
  count         = "${length(var.google_kms_crypto_key_roles)}"
  crypto_key_id = "${google_kms_crypto_key.vault_init.id}"
  role          = "${element(var.google_kms_crypto_key_roles, count.index)}"
  member        = "serviceAccount:${coalesce(var.google_service_account_email, google_service_account.vault_server.email)}"
}
