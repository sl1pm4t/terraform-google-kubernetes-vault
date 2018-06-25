# Write the TLS secret
resource "kubernetes_secret" "vault_tls" {
  metadata {
    name      = "vault-tls"
    namespace = "${var.kubernetes_namespace}"
  }

  data {
    "vault.crt" = "${coalesce(local.decoded_tls_cert, local.generated_tls_cert_chain)}"
    "vault.key" = "${coalesce(local.decoded_tls_key, local.generated_tls_key)}"
  }
}

# Write the Service Account secret
resource "kubernetes_secret" "vault_service_account" {
  metadata {
    name      = "vault-service-account"
    namespace = "${var.kubernetes_namespace}"
  }

  data {
    "service-account.json" = "${base64decode(google_service_account_key.vault.private_key)}"
  }
}

# Write the configmap
resource "kubernetes_config_map" "vault" {
  metadata {
    name      = "vault"
    namespace = "${var.kubernetes_namespace}"
  }

  data {
    load_balancer_address = "${google_compute_address.vault.address}"
    gcs_bucket_name       = "${google_storage_bucket.vault.name}"
    kms_key_id            = "${google_kms_crypto_key.vault_init.id}"
  }
}
