# Download the encrypted root token to disk
data "google_storage_object_signed_url" "root_token" {
  bucket = "${google_storage_bucket.vault.name}"
  path   = "root-token.enc"

  credentials = "${base64decode(google_service_account_key.vault.private_key)}"
}

# Download the encrypted file
data "http" "root_token" {
  url = "${data.google_storage_object_signed_url.root_token.signed_url}"

  depends_on = ["kubernetes_stateful_set.vault"]
}

# Decrypt the secret
data "google_kms_secret" "root_token" {
  crypto_key = "${google_kms_crypto_key.vault_init.id}"
  ciphertext = "${data.http.root_token.body}"
}

output "token" {
  value = "${data.google_kms_secret.root_token.plaintext}"
}

output "token_decrypt_command" {
  value = "gsutil cat gs://${google_storage_bucket.vault.name}/root-token.enc | base64 --decode | gcloud kms decrypt --project ${var.google_project} --location ${var.google_region} --keyring ${google_kms_key_ring.vault.name} --key ${google_kms_crypto_key.vault_init.name} --ciphertext-file - --plaintext-file -"
}
